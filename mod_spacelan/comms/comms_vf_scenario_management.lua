--[[

WARNING: AI-generated draft

Station management
==================

Provides access to special agreements with the station.

The player can:
* Start a navigation buoy for reputation.
* Sign an exclusive Human Navy contract for reputation or artifacts.
This changes the station's faction to the Human Navy.
* Join the Trade Network for reputation. This causes trade ships to be sent towards other stations.
]]

local ccc = common_comms_conditions	-- from lib_comms_nodes
comms_vf_station_management = {}

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
	--if comms_data._station_management_checked then
	--	return
	--end
	comms_data.size_factor = env.target:getHullMax() / 100	-- 1.5 to 8
	local is_independent = env.target:getFaction() == "Independent"
	local is_arlenian = env.target:getFaction() == "Arlenian"

	local default_service_costs = {
		navigation_buoy = 50,
		sensor_buoy = 100,
		weapons_subscription = 200,
		trade_network = 100 * comms_data.size_factor,
		exclusive_human_navy = 200 * comms_data.size_factor,
	}

	local default_artifact_costs = {
		exclusive_human_navy = math.floor(0.5 * comms_data.size_factor),
		repair_docking_service = 1,
	}

	comms_data.favor = 0

	if comms_data.service_available == nil then
		comms_data.service_available = {}
	end
	if comms_data.service_cost == nil then
		comms_data.service_cost = {}
	end
	if comms_data.service_artifact_cost == nil then
		comms_data.service_artifact_cost = {}
	end

	local services = {
		"navigation_buoy",
		"sensor_buoy",
		"exclusive_human_navy",
		"repair_docking_service",
		"trade_network",
		"weapons_subscription",
	}

	for _, service in ipairs(services) do
		if comms_data.service_available[service] == nil then
			comms_data.service_available[service] = is_independent
		end

		if comms_data.service_cost[service] == nil then
			comms_data.service_cost[service] = default_service_costs[service]
		end
	end

	if comms_data.service_artifact_cost.exclusive_human_navy == nil then
		comms_data.service_artifact_cost.exclusive_human_navy =
		default_artifact_costs.exclusive_human_navy
	end

	if comms_data.service_artifact_cost.repair_docking_service == nil then
		comms_data.service_artifact_cost.repair_docking_service =
		default_artifact_costs.repair_docking_service
	end

	comms_data.satellites = {}	-- store buoys
	comms_data._station_management_checked = true
end



comms_vf_station_management.main = CommsNode:new({
	choice_line = "Talk to station management",
	message = "Station management is available. We are looking forward working closer with the Human Navy. Would you like to discuss something we have to offer?",
}):add_condition(ccc.docked)


-- ============================================================================
-- Navigation buoy
-- ============================================================================

local function launch_bouy(env)
	local buoy = CpuShip():setTemplate("NavSat"):setFactionId(env.source:getFactionId())
	wh_rota:add_object(buoy, 0.25, env.target)
	buoy.distance = 4000
	buoy.angle = math.random(0, 360)
	table.insert(env.target.comms_data.satellites, buoy)
	return buoy
end

comms_vf_station_management.navigation_buoy = CommsNode:new({
	choice_line = "Navigation buoy",
	message = "Other ships may have trouble finding our station out here. We could launch a buoy, that will show the station and its the surroundings on your tactical maps. This would be a first step in a mutually beneficial relationship between us.",
}):add_condition(ccc.docked):add_condition(ccc.neutral_faction):add_test_setup(comms_vf_station_management.ensure_comms_data)

comms_vf_station_management.navigation_buoy_confirm = CommsNodeServiceBuyable:new({
	service_name = "navigation_buoy",
	message = "We started a navigation buoy for the Human Navy. Now all your ships should be able to find us.",
	select_choice_line = function(self, env)
		return string.format(
			"Start a navigation buoy for %d reputation.",
			self:service_cost(env)
		)
	end,
	effect = function(env)
		-- Start the actual navigation buoy.
		launch_bouy(env):setShortRangeRadarRange(5000)
		-- Add favor
		env.target.comms_data.favor = env.target.comms_data.favor + 1
	end
}):add_condition(ccc.docked):add_condition(ccc.neutral_faction):add_test_setup(comms_vf_station_management.ensure_comms_data):add_test_setup(function(env)
	env.source.getFactionId = function(self) assert(self); return 1 end
end)

comms_vf_station_management.navigation_buoy:add_choice(comms_vf_station_management.navigation_buoy_confirm)
-- ============================================================================
-- Sensor buoy
-- ============================================================================

comms_vf_station_management.sensor_buoy = CommsNode:new({
	choice_line = "Sensor buoy",
	message = "We could launch a sensor buoy to support your operations in this area. It will reveal a larger area around our station on your tactical maps, giving your ships better awareness of their surroundings."
}):add_condition(ccc.docked):add_condition(function(env)
	-- need 0 favor for small
	-- need 1 favor for medium and large
	-- need 2 favor for huge
	local favor = env.target.comms_data.favor
	return favor >= 1
end)


comms_vf_station_management.sensor_buoy_confirm = CommsNodeServiceBuyable:new({
	service_name = "sensor_buoy",
	message = "We started a sensor buoy for the Human Navy. Your ships should now have a much better view of the area around our station.",
	select_choice_line = function(self, env)
		return string.format(
			"Start a sensor buoy for %d reputation.",
			self:service_cost(env)
		)
	end,
	effect = function(env)
		-- Start the actual sensor buoy.
		launch_bouy(env):setShortRangeRadarRange(20000)
		-- Add favor
		env.target.comms_data.favor = env.target.comms_data.favor + 1
	end
}):add_condition(ccc.docked):add_test_setup(comms_vf_station_management.ensure_comms_data)

comms_vf_station_management.sensor_buoy:add_choice(
	comms_vf_station_management.sensor_buoy_confirm
)
-- ============================================================================
-- Weapons subscription
-- ============================================================================

comms_vf_station_management.weapons_subscription = CommsNode:new({
	choice_line = "Weapons supply subscription",
	message = "We can offer you a weapons supply subscription. This will give your ships access to our hidden weapons stocks and allow them to purchase ordnance on better terms. As part of the agreement, the restrictions on how much ordnance your ships can load will also be lifted."
}):add_condition(ccc.docked):add_condition(ccc.neutral_faction):add_condition(function(env)
	-- need 0 favor for small
	-- need 1 favor for medium and large
	-- need 2 favor for huge
	local favor = env.target.comms_data.favor
	local size = env.target.comms_data.size_factor
	return favor * 4 + 2 >= size
end):add_test_setup(comms_vf_station_management.ensure_comms_data)


comms_vf_station_management.weapons_subscription_confirm = CommsNodeServiceBuyable:new({
	service_name = "weapons_subscription",
	message = "The weapons supply agreement is now active. Your ships will receive better prices, access to our hidden weapons stocks, and can load their weapon storage to full capacity.",
	select_choice_line = function(self, env)
		return string.format(
			"Subscribe to the weapons supply for %d reputation.",
			self:service_cost(env)
		)
	end,
	effect = function(env)
		-- Reduce the factional weapons cost modifier.
		if env.target.comms_data.reputation_cost_multipliers ~= nil then
			if env.target.comms_data.reputation_cost_multipliers.friend then
				env.target.comms_data.reputation_cost_multipliers.neutral = math.max(env.target.comms_data.reputation_cost_multipliers.friend, env.target.comms_data.reputation_cost_multipliers.neutral / 2 )
			elseif env.target.comms_data.reputation_cost_multipliers.neutra then
				env.target.comms_data.reputation_cost_multipliers.neutral = env.target.comms_data.reputation_cost_multipliers.neutral / 2
			end
		end
		-- Make hidden weapon stocks available.
		for missile, avail in pairs(env.target.comms_data.weapon_available) do
			if avail == false then
				env.target.comms_data.weapon_available[missile] = math.floor(math.random(1,5) * env.target.comms_data.size_factor)
			elseif type(avail) == "number" then
				env.target.comms_data.weapon_available[missile] = env.target.comms_data.weapon_available[missile] + math.floor(math.random(5,10) * env.target.comms_data.size_factor)
			end
		end
		-- Remove the factional restriction that prevents the ship from loading its weapon storage fully.
		env.target.comms_data.weapon_factional_limit = false
		-- Add favor
		env.target.comms_data.favor = env.target.comms_data.favor + 1
	end
}):add_condition(ccc.docked):add_condition(ccc.neutral_faction):add_test_setup(comms_vf_station_management.ensure_comms_data)

comms_vf_station_management.weapons_subscription:add_choice(
	comms_vf_station_management.weapons_subscription_confirm
)

-- ============================================================================
-- Repair docking service
-- ============================================================================

comms_vf_station_management.repair_docking_service = CommsNode:new({
	choice_line = "Repair a docking service",
	message = "One of our docking services is badly damaged. If you can provide an artifact to help us repair it, we can restore the service. Your generosity would also greatly improve our opinion of your faction and make future negotiations considerably easier."
}):add_condition(ccc.docked):add_condition(ccc.neutral_faction):add_condition(function(env)
	local favor = env.target.comms_data.favor
	return favor >= 1
end):add_test_setup(comms_vf_station_management.ensure_comms_data)

comms_vf_station_management.repair_docking_service_confirm = CommsNodeServiceBuyableArtifacts:new({
	service_name = "repair_docking_service",
	message = "The artifact has been put to good use. We have repaired our damaged equipment. Your assistance has earned our lasting gratitude, and future negotiations with us will be much easier.",
	select_choice_line = function(self, env)
		return "Give an artifact to repair the docking services."
	end,

	effect = function(env)
		-- Repair the broken docking services.
		env.target:setRestocksScanProbes(true)
		env.target:setRepairDocked(true)
		env.target:setSharesEnergyWithDocked(true)
		-- Greatly increase the station's faction/favor value.
		env.target.comms_data.favor = env.target.comms_data.favor + 2
	end
}):add_condition(ccc.docked):add_condition(ccc.neutral_faction):add_condition(function(env)
	return not (env.target:getRestocksScanProbes() and
		env.target:getRepairDocked() and
		env.target:getSharesEnergyWithDocked())
end):add_test_setup(comms_vf_station_management.ensure_comms_data):add_test_setup(function(env)
	env.target.setSharesEnergyWithDocked = function(self, bool) assert(self); assert(type(bool) == "boolean") end
	env.target.setRepairDocked = function(self, bool) assert(self); assert(type(bool) == "boolean") end
	env.target.setRestocksScanProbes = function(self, bool) assert(self); assert(type(bool) == "boolean") end
end)

comms_vf_station_management.repair_docking_service:add_choice(
	comms_vf_station_management.repair_docking_service_confirm
)

-- ============================================================================
-- Trade Network
-- ============================================================================

-- also applies to friendly stations
comms_vf_station_management.trade_network = CommsNode:new({
	choice_line = "Tell me about the Trade Network",
	message = "We can connect this station to the Trade Network. This will allow trade ships to travel between us and other stations in the network, bringing new goods to improve our services and weapons you can buy to this station."
}):add_condition(ccc.docked):add_condition(function(env)
	-- need 1 favor for small and medium
	-- need 2 favor for large and huge
	local favor = env.target.comms_data.favor
	local size = env.target.comms_data.size_factor
	return favor * 4 >= size
end):add_test_setup(comms_vf_station_management.ensure_comms_data)


comms_vf_station_management.trade_network_confirm = CommsNodeServiceBuyable:new({
	service_name = "trade_network",
	message = "We are now connected to the Trade Network. Trade ships will begin travelling between this station and other network stations.",
	select_choice_line = function(self, env)
		return string.format(
			"Join the Trade Network for %d reputation.",
			self:service_cost(env)
		)
	end,
	effect = function(env)
		vf_trade_network:add_station(env.target)
		-- Add favor
		env.target.comms_data.favor = env.target.comms_data.favor + 1
	end
}):add_condition(ccc.docked):add_condition(ccc.neutral_faction):add_condition(function(env)
	return vf_trade_network ~= nil
end):add_test_setup(comms_vf_station_management.ensure_comms_data):add_test_setup(function(env)
	vf_trade_network = {
		stations = {},
		add_station = function() end
	}
end)

comms_vf_station_management.trade_network:add_choice(
	comms_vf_station_management.trade_network_confirm
)

-- ============================================================================
-- Exclusive Human Navy contract
-- ============================================================================

comms_vf_station_management.exclusive_human_navy = CommsNode:new({
	choice_line = "Exclusive contract for the Human Navy",
	message = "We are prepared to enter an exclusive contract with the Human Navy. In return for your support, we will align ourselves with the Human Navy and no longer offer our services to other factions. You will get the best prices and may use this station for military purposes."
}):add_condition(ccc.docked):add_condition(ccc.neutral_faction):add_condition(function(env)
	-- need 1 favor for small
	-- need 2 favor for medium
	-- need 3 favor for large
	-- need 4 favor for huge
	local favor = env.target.comms_data.favor
	local size = env.target.comms_data.size_factor
	return favor * 2 >= size
end):add_test_setup(comms_vf_station_management.ensure_comms_data)

comms_vf_station_management.exclusive_human_navy_confirm = CommsNodeServiceBuyable:new({
	service_name = "exclusive_human_navy",
	message = "The contract is signed. This station is now operating exclusively for the Human Navy.",
	select_choice_line = function(self, env)
		return string.format(
			"Sign an exclusive Human Navy contract for %d reputation.",
			self:service_cost(env)
		)
	end,
	effect = function(env)
		-- Change the station's faction to the Human Navy.
		env.target:setFactionId(env.source:getFactionId())
		-- Add favor
		env.target.comms_data.favor = env.target.comms_data.favor + 1
	end
}):add_condition(ccc.docked):add_condition(ccc.neutral_faction):add_test_setup(comms_vf_station_management.ensure_comms_data):add_test_setup(function(env)
	env.target.setFactionId = function(self, id) assert(self); assert(type(id) == "number") end
	env.source.getFactionId = function(self) assert(self); return 1 end
end)

comms_vf_station_management.exclusive_human_navy_artifacts_confirm = CommsNodeServiceBuyableArtifacts:new({
	service_name = "exclusive_human_navy",
	message = "The contract is signed. This station is now operating exclusively for the Human Navy.",
	select_choice_line = function(self, env)
		return string.format(
			"Sign an exclusive Human Navy contract for %d artifacts.",
			self:service_cost(env)
		)
	end,
	effect = function(env)
		-- Change the station's faction to the Human Navy.
		env.target:setFactionId(env.source:getFactionId())
		-- Add favor
		env.target.comms_data.favor = env.target.comms_data.favor + 1
	end
}):add_condition(ccc.docked):add_condition(ccc.neutral_faction):add_test_setup(comms_vf_station_management.ensure_comms_data)

comms_vf_station_management.exclusive_human_navy:add_choice(
	comms_vf_station_management.exclusive_human_navy_artifacts_confirm
)

comms_vf_station_management.exclusive_human_navy:add_choice(
	comms_vf_station_management.exclusive_human_navy_confirm
)


