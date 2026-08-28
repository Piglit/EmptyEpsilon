--[[
Station management
==================

Provides access to special agreements with the station.

The player can:
* Start a navigation buoy for reputation.
* Sign an exclusive Human Navy contract for reputation or artifacts.
This changes the station's faction to the Human Navy.
* Join the Trade Network for reputation. This causes trade ships to be sent towards other stations.
]]

-- FIXME: wording mentions Human Navy, but means your current faction.

local ccc = common_comms_conditions	-- from lib_comms_nodes
assert(wh_rota)
comms_vf_station_management = {}

local SERVICE_DEFINITIONS = {
	-- Defensive contract
	clear_area = {
		one_time = true,
	},
	-- Navigation buoy
	navigation_buoy = {
		cost = 50,
		require_neutral_faction = true,
		one_time = false,
	},
	-- Sensor buoy
	sensor_buoy = {
		cost = 100,
		favor_required = 1,
		one_time = false,
	},
	-- Repair docking service
	repair_docking_service = {
		artifact_cost = 1,
		favor_required = 2,
		one_time = true,
	},
	-- Weapons subscription
	weapons_subscription = {
		cost = 200,
		require_neutral_faction = true,
		favor_required = 2,
		one_time = true,
	},
	-- Trade Network
	trade_network = {
		cost = function(size_factor)
			return 100 * size_factor
		end,
		favor_required = 3,
		one_time = true,
	},
	-- Exclusive faction contract
	-- Warning: can have both: cost and artifact_cost
	-- TODO: test that 0 artifact cost can not be chosen
	change_faction = {
		cost = function(size_factor)
			return 200 * size_factor
		end,
		artifact_cost = function(size_factor)
			return math.floor(0.5 * size_factor)
		end,
		require_neutral_faction = true,
		favor_required = function(size_factor)
			return math.ceil(0.5 * size_factor)
		end,
		one_time = true,
	},
}

-- helper for costs that depend on the station size 
local function resolve_service_value(value, size_factor)
	if type(value) == "function" then
		return value(size_factor)
	end
	return value
end


--[[
* ensure_comms_data:
*   Initializes the station management service-related comms_data.
*
* service_available controls whether a service is offered.
* service_cost contains the reputation cost for each service.
* service_artifact_cost contains the artifact cost where applicable.
--]]
function comms_vf_station_management.ensure_comms_data(env)
	local comms_data = env.target.comms_data
	assert(comms_data)
	if comms_data._management_initialized then
		return true
	end

	comms_data.size_factor = env.target:getHullMax() / 100	-- 1.5 to 8

	if comms_data.orig_faction == nil then
		comms_data.orig_faction = env.target:getFaction()
	end

	if comms_data.favor == nil then
		comms_data.favor = 0
	end

	assert(comms_data.service_available)
	assert(comms_data.service_cost)
	if comms_data.service_artifact_cost == nil then
		comms_data.service_artifact_cost = {}
	end
	if comms_data.service_favor_required == nil then
		comms_data.service_favor_required = {}
	end

	for service_name, definition in pairs(SERVICE_DEFINITIONS) do
		if comms_data.service_available[service_name] == nil then
			comms_data.service_available[service_name] =
			comms_data.orig_faction == "Independent"
		end

		if definition.cost ~= nil and
			comms_data.service_cost[service_name] == nil then
			comms_data.service_cost[service_name] =
			resolve_service_value(
				definition.cost,
				comms_data.size_factor
			)
		end

		if definition.artifact_cost ~= nil and
			comms_data.service_artifact_cost[service_name] == nil then
			comms_data.service_artifact_cost[service_name] =
			resolve_service_value(
				definition.artifact_cost,
				comms_data.size_factor
			)
		end

		if definition.favor_required ~= nil and
			comms_data.service_favor_required[service_name] == nil then
			comms_data.service_favor_required[service_name] =
			resolve_service_value(
				definition.favor_required,
				comms_data.size_factor
			)
		end

	end

	if comms_data.satellites == nil then
		comms_data.satellites = {}	-- store buoys
	end

	comms_data._management_initialized = true
	return true	-- used as condition
end


local function create_station_management_service(config)
	assert(config.service_name)
	local node = CommsNodeServiceAvailable:new({
		skip_in_back_stack = true,
		service_name = config.service_name,
		choice_line = config.choice_line,
		message = config.message,
	})
	:add_condition(ccc.docked)
	:add_condition(function(env)
		return env.target.comms_data.orig_faction == "Independent"
	end)
	:add_condition(function(env)
		local favor_required = env.target.comms_data.service_favor_required[config.service_name]
		return favor_required == nil or
			env.target.comms_data.favor >= favor_required
	end)
	:add_test_setup(function(env)
		env.target.getFaction = function() return "Independent" end
		env.target.comms_data.orig_faction = "Independent"
	end)
	:add_test_setup(comms_vf_station_management.ensure_comms_data)

	local definition = SERVICE_DEFINITIONS[config.service_name]
	assert(definition, config.service_name)

	if definition.require_neutral_faction then
		node:add_condition(ccc.neutral_faction)
	end

	local confirm_options = {}
	if definition.cost ~= nil then
		table.insert(confirm_options, CommsNodeServiceBuyable:new({}))
	end

	if definition.artifact_cost ~= nil then
		table.insert(confirm_options, CommsNodeServiceBuyableArtifacts:new({}))
	end
	
	if definition.cost == nil and definition.artifact_cost == nil then
		table.insert(confirm_options, CommsNode:new({}))
	end

	for __, confirm in ipairs(confirm_options) do
		confirm.service_name = config.service_name
		confirm.message = config.confirm_message
		if confirm.service_cost ~= nil then
			confirm.select_choice_line = function(self, env)
				return string.format(config.confirm_choice_line, self:service_cost(env))	-- careful: rep or arts
			end
		end
		confirm:add_condition(ccc.docked)
		confirm:add_effect(function(self,env)
			env.target.comms_data.favor = env.target.comms_data.favor + 1
			-- make them a bit more friendly
			env.target.comms_data.friendlyness = env.target.comms_data.friendlyness + 10
			-- After receiving favor, enemies will attack here
			if avp_story ~= nil then
				avp_story:spawn_threat(env.target, env.source)
			end
			if vf_bescheid ~= nil then
				vf_bescheid:sag_bescheid("gained_favor", {
					callsign_ship=env.source:getCallSign(),
					callsign_station=env.target:getCallSign(),
					sector=env.target:getSectorName(),
				})
			end
			return true
		end)
		if definition.one_time then
			confirm:add_effect(function(self, env)
				env.target.comms_data.service_available[self.service_name] = false
				return true
			end)
		end
		confirm:add_test_setup(comms_vf_station_management.ensure_comms_data)

		if definition.require_neutral_faction then
			confirm:add_condition(ccc.neutral_faction)
		end
		node:add_choice(confirm)
	end

	node.confirm_options = confirm_options
	if #confirm_options == 1 then
		node.confirm = confirm_options[1]
	end
	return node
end




comms_vf_station_management.main = CommsNode:new({
	choice_line = _("I want to talk to the station management"),
	message = _("Station management is available.\nWe are looking forward working more closely with the Human Navy.\nWould you like to discuss something we have to offer?"),
}):add_condition(ccc.docked):add_condition(function(env)
	if env.target.comms_data.orig_faction == nil then
		env.target.comms_data.orig_faction = env.target:getFaction()
	end	
	return env.target.comms_data.orig_faction == "Independent"
	-- no management for converted stations
end)


-- ============================================================================
-- Clear area
-- ============================================================================

comms_vf_station_management.clear_area = create_station_management_service({
	service_name = "clear_area",
	choice_line = _("Defensive contract"),
	message = _("It would be beneficial for both of us if threats that endanger space travel near our station would vanish.\nWe would greatly appreciate if you would clear the area of enemy raiders.\nWe will consider working more closely with you if you keep us clear of any threats."),
	confirm_message = _("We greatly appreciate your effort. We will consider this in our future offers."),
})
comms_vf_station_management.clear_area.confirm.choice_line = _("We will keep the area free of enemy ships"),
comms_vf_station_management.clear_area.confirm:add_check(function(self,env)
	local range = 30000
	for __,obj in ipairs(env.target:getObjectsInRange(range)) do
		-- check against players enemies, not stations. Station is independent and has less enemies.
		if obj:isValid() and obj.isEnemy and obj:isEnemy(env.source) then
			return false, _("We appreciate your offer. Our sensors currently show enemy presence within 30u.")
		end
	end
	return true
end)
:add_test_setup(function(env)
	env.target.getObjectsInRange = function(self, range)
		return {
			{
				isValid = function(self) assert(self); return true end,
				getCallSign = function(self) assert(self); return "testobj" end,
				isEnemy = function(self, other) assert(self); assert(other); return true end,
			}
		}
	end
end)
:add_test(function(self,env)
	env.target.getObjectsInRange = function(self, range)
		return {}
	end
	self:_call(env)
end)

if comms_vf_ship ~= nil then
	comms_vf_station_management.clear_area:add_choice(comms_vf_ship.info.enemies_nearby)
end

-- ============================================================================
-- Navigation buoy
-- ============================================================================

local function launch_buoy(env)
	local buoy = CpuShip():setTemplate("NavSat"):setFactionId(env.source:getFactionId())
	buoy:setScannedByFaction(env.source:getFaction(), true)	
	buoy:setCommsScript(""):setCommsFunction(nil)
	wh_rota:add_object(buoy, 2, env.target)
	arrayFilter(env.target.comms_data.satellites, function(obj)
		return obj ~= nil and obj:isValid()
	end)
	table.insert(env.target.comms_data.satellites, buoy)
	buoy.distance = 4000
	buoy.angle = 360 / #env.target.comms_data.satellites
	if #env.target.comms_data.satellites > 1 then
		buoy.angle = buoy.angle + env.target.comms_data.satellites[1].angle
	end
	return buoy
end

comms_vf_station_management.navigation_buoy = create_station_management_service({
	service_name = "navigation_buoy",
	choice_line = _("Navigation buoy"),
	message = _("Other ships may have trouble finding our station out here.\nWe could launch a buoy, that will show the station and its surroundings on your tactical maps.\nThis would be a first step in a mutually beneficial relationship between us."),
	confirm_message = _("We started a navigation buoy for the Human Navy.\nNow all your ships should be able to find us."),
	confirm_choice_line = _("Start a navigation buoy for %d reputation."),
})
comms_vf_station_management.navigation_buoy.confirm
:add_effect(function(self, env)
	-- Start the actual navigation buoy.
	launch_buoy(env):setShortRangeRadarRange(5000)
	return true
end)
:add_check(function(self, env)
	arrayFilter(env.target.comms_data.satellites, function(obj)
		return obj ~= nil and obj:isValid()
	end)
	return #env.target.comms_data.satellites == 0, _("We already launched a satellite for you.\nOne should be enough for now.\nIf you need more radar coverage, consider buying a radar satellite from us.")
end)
:add_test_setup(function(env)
	env.source.getFactionId = function(self) assert(self); return 1 end
	env.target.comms_data.satellites = {
		{isValid = function(self) assert(self) return false end}
	}
	env.target.comms_data.service_available["navigation_buoy"] = true
	env.target.comms_data.service_cost["navigation_buoy"] = 1
end)

comms_vf_station_management.sensor_buoy = create_station_management_service({
	service_name = "sensor_buoy",
	choice_line = _("Radar satellite"),
	message = _("Considering your recently shown interest in our neighbourhood, we could launch a radar satellite for you.\nIt will reveal a larger area around our station on your tactical maps, giving your ships better awareness of their surroundings."),
	confirm_message = _("We started a radar satellite for you.\nYour ships should now have a much better view of the area around our station."),
	confirm_choice_line = _("Start a radar satellite for %d reputation."),
})
comms_vf_station_management.sensor_buoy.confirm:add_effect(function(self, env)
	-- Start the actual sensor buoy.
	launch_buoy(env):setShortRangeRadarRange(20000)
	return true
end)
	
-- ============================================================================
-- Repair docking service
-- ============================================================================

local function docking_service_needs_repair(env)
	return not (env.target:getRestocksScanProbes() and
		env.target:getRepairDocked() and
		env.target:getSharesEnergyWithDocked())
end
comms_vf_station_management.repair_docking_service = create_station_management_service({
	service_name = "repair_docking_service",
	choice_line = _("Repair our docking services"),
	message = _("The facilities that provide our docking services are currently not working.\nIf you can provide an artifact to help us repair it, we can restore the services.\nYour generosity would also improve our opinion of your faction and make future negotiations considerably easier."),
	confirm_message = _("The artifact has been put to good use.\nWe have repaired our damaged equipment.\nYour assistance has earned our lasting gratitude, and future negotiations with us will be much easier."),
	confirm_choice_line = _("Give %d artifact to repair the docking services."),
})
:add_condition(docking_service_needs_repair)
comms_vf_station_management.repair_docking_service.confirm:add_effect(function(self, env)
	-- Repair the broken docking services.
	env.target:setRestocksScanProbes(true)
	env.target:setRepairDocked(true)
	env.target:setSharesEnergyWithDocked(true)
	return true
end)
:add_condition(docking_service_needs_repair)
:add_test_setup(function(env)
	env.target.setSharesEnergyWithDocked = function(self, bool) assert(self); assert(type(bool) == "boolean") end
	env.target.setRepairDocked = function(self, bool) assert(self); assert(type(bool) == "boolean") end
	env.target.setRestocksScanProbes = function(self, bool) assert(self); assert(type(bool) == "boolean") end
end)


-- ============================================================================
-- Weapons subscription
-- ============================================================================

comms_vf_station_management.weapons_subscription = create_station_management_service({
	service_name = "weapons_subscription",
	choice_line = _("Weapons supply subscription"),
	message = _("We can offer you a weapons supply subscription.\nThis will give your ships access to our hidden weapons stocks and allow them to purchase ordnance on better terms.\nAs part of the agreement, the restrictions on how much ordnance your ships can load will also be lifted."),
	confirm_message = _("The weapons supply agreement is now active.\nYour ships will receive better prices, access to our hidden weapons stocks, and can load their weapon storage to full capacity."),
	confirm_choice_line = _("Subscribe to the weapons supply for %d reputation."),

})
:add_condition(function(env)
	return comms_vf_weapons ~= nil and
	env.target.comms_data.weapon_available ~= nil
end)
comms_vf_station_management.weapons_subscription.confirm:add_effect(function(self,env)
	-- Reduce the factional weapons cost modifier.
	CommsNodeServiceBuyable.adjust_factional_modifier(env, 0.5)
	-- Make hidden weapon stocks available.
	comms_vf_weapons.increase_available_weapons(env)
	-- Remove the factional restriction that prevents the ship from loading its weapon storage fully.
	comms_vf_weapons.disable_weapon_factional_limit(env)
	return true
end)
:add_test(function(self, env)
	env.target.comms_data.service_available["weapons_subscription"] = true
	env.target.comms_data.service_cost["weapons_subscription"] = 1
--	env.source.getReputationPoints = function() return 500 end
	env.target.comms_data.reputation_cost_multipliers.friend = nil
	env.target.comms_data.reputation_cost_multipliers.neutral = 2
	--self.effect(env)
	self:_apply_effects(env)
	env.target.comms_data.reputation_cost_multipliers.friend = 1
	self:_apply_effects(env)
	env.target.comms_data.signed_weapons_subscription = true
	self:_call(env)
end)


-- ============================================================================
-- Trade Network
-- ============================================================================

-- also applies to friendly stations
comms_vf_station_management.trade_network = create_station_management_service({
	service_name = "trade_network",
	choice_line = _("Tell me about the Trade Network"),
	message = _("We can connect this station to the Trade Network.\nThis will allow trade ships to travel between us and other stations in the network, bringing new goods to improve our services and weapons you can buy to this station."),
	confirm_message = _("We are now connected to the Trade Network.\nTrade ships will begin travelling between this station and other network stations."),
	confirm_choice_line = _("Join the Trade Network for %d reputation."),
})
:add_condition(function(env)
	return vf_trade_network ~= nil
end)
:add_test_setup(function(env)
	vf_trade_network = {}
end)
comms_vf_station_management.trade_network.confirm:add_effect(function(self, env)
	vf_trade_network:add_station(env.target)
	return true
end)	
:add_test_setup(function(env)
	vf_trade_network = {
		stations = {},
		add_station = function() end
	}
end)
:add_test(function(self,env)
	env.target.comms_data.service_available["trade_network"] = true
	env.target.comms_data.service_cost["trade_network"] = 1
	env.target.comms_data.joined_trade_network = true
	self:_call(env)
end)


-- ============================================================================
-- Exclusive Faction contract
-- ============================================================================

comms_vf_station_management.change_faction = create_station_management_service({
	service_name = "change_faction",
	choice_line = _("Exclusive contract for the Human Navy"),
	message = _("We are prepared to enter an exclusive contract with the Human Navy.\nIn return for your support, we will align ourselves with the Human Navy and no longer offer our services to other factions.\nYou will get the best prices and may use this station for military purposes."),
	confirm_message = _("The contract is signed.\nThis station is now operating exclusively for the Human Navy."),
	confirm_choice_line = _("Sign an exclusive contract for %d reputation."),
})

for __, confirm in ipairs(comms_vf_station_management.change_faction.confirm_options) do
	confirm
	:add_effect(function(self,env)
		-- Change the station's faction to the Human Navy.
		env.target:setFactionId(env.source:getFactionId())
		if vf_bescheid ~= nil then
			vf_bescheid:sag_bescheid("turned_independent_friendly", {
				callsign_station=env.target:getCallSign(),
			})
		end
		return true
	end)
	:add_check(function(self,env)
		return ccc.neutral_faction.condition(env), self.message
	end)
	:add_test_setup(comms_vf_station_management.ensure_comms_data):add_test_setup(function(env)
		env.target.setFactionId = function(self, id) assert(self); assert(type(id) == "number") end
		env.source.getFactionId = function(self) assert(self); return 1 end
		env.target.comms_data.service_available["change_faction"] = true
		env.target.comms_data.service_cost["change_faction"] = 1
	end)
end

comms_vf_station_management.change_faction.confirm_options[2].select_choice_line = function(self, env)
	return string.format(
		_("Sign an exclusive Human Navy contract for %d artifacts."),
		self:service_cost(env)
	)
end


-- ============================================================================
-- main tree
-- ============================================================================
comms_vf_station_management.main:add_choice(comms_vf_station_management.clear_area)
comms_vf_station_management.main:add_choice(comms_vf_station_management.navigation_buoy)
comms_vf_station_management.main:add_choice(comms_vf_station_management.sensor_buoy)
comms_vf_station_management.main:add_choice(comms_vf_station_management.repair_docking_service)
comms_vf_station_management.main:add_choice(comms_vf_station_management.weapons_subscription)
comms_vf_station_management.main:add_choice(comms_vf_station_management.trade_network)
comms_vf_station_management.main:add_choice(comms_vf_station_management.change_faction)


comms_vf_station.automatic.ensure_comms_data:add_comms_data_initialiser_function(comms_vf_station_management.ensure_comms_data)
comms_vf_station_management.main:add_choice_to_all_children(CommsBack, true, true)
comms_vf_station.main:add_choice(comms_vf_station_management.main)
