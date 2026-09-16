local ccc = common_comms_conditions	-- from lib_comms_nodes
comms_vf_military = {}

--[[
	Reinforcements
--]]

--- Initializes the persistent communication data used by the reinforcement service.
---
--- Creates reinforcement costs, reputation thresholds, and the initial set of
--- reinforcement offers if they do not already exist. The generated data is
--- stored in `env.target.comms_data` and therefore persists for the station.
---
--- Reinforcement availability is based on the station's friendliness and each
--- ship type's friendliness threshold. Costs and stock availability are generated
--- once when the reinforcement data is first initialized.
---
--- Also ensures that the reinforcement service itself has no additional service
--- cost; individual reinforcement requests are charged through their own
--- reputation cost.
function comms_vf_military.ensure_comms_data_reinforcements(env)
	local comms_data = env.target.comms_data
	-- we always use blue ones here. for no reason at all. This should be factional instead.
	-- TODO we need a global factional ship database, where the data here can be defined
	-- it needs to be used for enemies, too - variation of the ship template list.
	-- A possible implementation could be this:
	-- {template = "Blue Hornet", cost = {80, 120}, threshold = 33},
	if comms_data.reinforcement_cost == nil then
		comms_data.reinforcement_cost = {
			["Blue Hornet"] = math.random(80,120),
			["Blue Lindworm"] = math.random(80,120),
			["Blue Adder"] = math.random(125,175),
			["Phobos Vanguard"] = math.random(200,250),
			["Phobos Rear-Guard"] = math.random(200,250),
			["Piranha Vanguard"] = math.random(200,250),
			["Piranha Rear-Guard"] = math.random(200,250),
			["Nirvana Vanguard"] = math.random(200,250),
			["Nirvana Rear-Guard"] = math.random(200,250),
		}
	end
	if comms_data.reinforcement_threshold == nil then
		comms_data.reinforcement_threshold = {
			["Blue Hornet"] = 33,
			["Blue Lindworm"] = 50,
			["Blue Adder"] = 20,
			["Phobos Vanguard"] = 66,
			["Phobos Rear-Guard"] = 66,
			["Piranha Vanguard"] = 75,
			["Piranha Rear-Guard"] = 75,
			["Nirvana Vanguard"] = 70,
			["Nirvana Rear-Guard"] = 70,
		}
	end
	-- derived from the two above
	if comms_data.reinforcement_info == nil then
		comms_data.reinforcement_info = {}
		for template, cost in pairs(env.target.comms_data.reinforcement_cost) do
			local info = {
				desc = template,
				template = template,
				threshold = env.target.comms_data.reinforcement_threshold[template],
				cost = math.ceil(env.target.comms_data.reinforcement_cost[template]),
				stocked = true, --math.random(1,100) <= 72 -- dafuq? always have 72% chance for every type?
			}
			info.selectable = stocked and (info.threshold == nil or comms_data.friendlyness > info.threshold)	-- assume the stats above are immutable
			table.insert(comms_data.reinforcement_info, info)
		end
	end
	if comms_data.service_cost ~= nil then
		comms_data.service_cost["reinforcements"] = 0
	end
end

--- Comms service for requesting a military reinforcement ship.
---
--- The service is available only at friendly stations. When selected, it presents
--- the reinforcement ship types currently available to the station and allows
--- the player to select one. The selected reinforcement is then passed to
--- `with_reinforcement_info`, which handles waypoint selection and dispatch.
---
--- Reinforcement availability is determined by the station's persistent
--- reinforcement data, including ship stock and the station's friendliness.
--- This availability is only evaluates once - changes to those values do not automatically
--- effect the availability of the ships.
comms_vf_military.reinforcements = CommsNodeServiceAvailable:new({
	service_name = "reinforcements",
	select_choice_line = function(self, env)
		return arraySelectRandom({
			_("Send reinforcements"),
			_("Request friendly warship"),
			_("Send military help"),
			_("Get a ship to help us"),
		})
	end,
	select_message = function(self, env)
		return arraySelectRandom({
            _("What kind of reinforcement ship?"),
            _("What kind of ship should we send?"),
            _("Specify ship type"),
            _("Identify desired type of ship"),
        })
	end,
	_show_choices = function(self, env)
		comms_vf_military.ensure_comms_data_reinforcements(env)
		local reinforcement_info = env.target.comms_data.reinforcement_info
		assert(reinforcement_info)
		local avail = false
		for idx, info in ipairs(reinforcement_info) do
			if info.selectable then
				avail = true
				addCommsReply(string.format(_("stationAssist-comms","%s (%d reputation)"),info.desc,info.cost), self.with_reinforcement_info:_as_comms_reply(env, info))
			end
		end
		if not avail then
			local insufficient_reinforcements = {
				_("No reinforcements available"),
				_("We don't have any reinforcements"),
				_("No military ships in our inventory, sorry"),
				_("Reinforcements unavailable"),
			}
			setCommsMessage(arraySelectRandom(insufficient_reinforcements))	-- unclean
		end
		comms_vf_military.reinforcements.super()._show_choices(self, env)
	end,
	with_reinforcement_info = CommsNodeWaypointSelect:new({
		-- Carries the player's selected reinforcement into the waypoint-selection part of the comms flow.
		effect = function(env)
			env.reinforcement_info = env.args
		end,
		with_waypoint = CommsNode:new({
			select_message = function(self, env)
				local cs = env.reinforcement_callsign
				local waypoint = env.args
				assert(waypoint, type(env.args))
				return arraySelectRandom({
					string.format(_("We have dispatched %s to assist at waypoint %s"),cs,waypoint),
					string.format(_("%s is heading for waypoint %s"),cs,waypoint),
					string.format(_("%s has been sent to waypoint %s"),cs,waypoint),
					string.format(_("We ordered %s to help at waypoint %s"),cs,waypoint),
				})
			end,
		})
	}),
})
comms_vf_military.reinforcements:add_condition(ccc.friendly_faction)
comms_vf_military.reinforcements.with_reinforcement_info:add_test_setup(function(env)
	env.args = {
		desc = "test",
		template = "test",
		threshold = 27,
		cost = 28,
		stocked = true,
		available = true,
	}
end)


--- with_waypoint:
--- Requests a waypoint and dispatches the selected reinforcement there.
---
--- The selected reinforcement is charged to the player using reputation points.
--- On success, a ship is created at the station and ordered to defend the selected waypoint.
--- On failure, the player is informed that they do not have enough reputation.
comms_vf_military.reinforcements.with_reinforcement_info.with_waypoint:add_effect(function(self, env)
	local info = env.reinforcement_info
	return env.source:takeReputationPoints(info.cost), _("Insufficient reputation")
end)

comms_vf_military.reinforcements.with_reinforcement_info.with_waypoint:add_effect(function(self, env)
	local info = env.reinforcement_info
	local waypoint = env.args
	local ship = CpuShip():setFactionId(env.target:getFactionId()):setPosition(env.target:getPosition()):setTemplate(info.template):setScanned(true):orderDefendLocation(env.source:getWaypoint(waypoint))
	if generateCallSign ~= nil then
		suffix_index = math.random(11,77)	-- needs to be global for generateCallSign
		ship:setCallSign(generateCallSign(nil,env.target:getFaction()))
	end
	env.reinforcement_callsign = ship:getCallSign()
	return true
end)

comms_vf_military.reinforcements.with_reinforcement_info.with_waypoint:add_condition(ccc.friendly_faction)

comms_vf_military.reinforcements.with_reinforcement_info.with_waypoint:add_test_setup(function(env) 
	env.target.comms_data.service_available["reinforcements"] = true
	env.reinforcement_info = {
		desc = "test",
		template = "test",
		threshold = 27,
		cost = 28,
		stocked = true,
		available = true,
	}
	env.target.getFactionId = function(self) assert(self); return 1 end
	env.args = 2
	env.reinforcement_callsign = "test"
end)

comms_vf_military.reinforcements.with_reinforcement_info.with_waypoint:add_test(function(self, env)
	env.args = 1
	env.reinforcement_callsign = "test"
	env.reinforcement_info = {
		desc = "test",
		template = "test",
		threshold = 27,
		cost = 28,
		stocked = true,
		available = true,
	}
	self:_apply_effects(env)
	env.reinforcement_info.stocked = false
	self:_apply_effects(env)
	generateCallSign = function() return "1" end
	env.reinforcement_info.stocked = true
	env.source.takeReputationPoints = function() return false end
	self:_apply_effects(env)
	env.source.takeReputationPoints = function() return true end
	self:_apply_effects(env)
end)

-- test for the outer node:
comms_vf_military.reinforcements:add_test_setup(function(env)
	comms_vf_military.ensure_comms_data_reinforcements(env)
	env.target.comms_data.service_available.reinforcements = true
	env.target.comms_data.friendlyness = 50
end)

comms_vf_military.reinforcements:add_test(function(self, env)
	env.target.comms_data.reinforcement_info = nil
	env.target.comms_data.friendlyness = 1
	comms_vf_military.ensure_comms_data_reinforcements(env)
	self:_show_choices(env)
	env.target.comms_data.reinforcement_info = {
	{
		desc = "test",
		template = "test",
		threshold = 27,
		cost = 28,
		stocked = true,
		selectable = false,
	},
	{
		desc = "test2",
		template = "test2",
		threshold = 27,
		cost = 28,
		stocked = true,
		selectable = true,
	}}
	env.target.comms_data.friendlyness = 100
	self:_show_choices(env)
	env.target.comms_data.reinforcement_info.selectable = true
	self:_show_choices(env)
end)

--[[
	Defense Fleet
--]]

--- Generates the station's initial defense fleet.
---
--- The fleet is generated only once and must not already exist when this
--- function is called. The number and composition of ships are determined by
--- `comms_data.defense_fleet_chances` and modified by the station's maximum
--- hull value.
---
--- Fleet generation stops at the first failed probability check. Consequently,
--- ships later in the fleet configuration are progressively less likely to
--- occur.
local function generate_defense_fleet(station)
	local comms_data = station.comms_data
	assert(comms_data.idle_defense_fleet == nil)
	comms_data.idle_defense_fleet = {["DF1"] =  "MT52 Hornet"}
	for i,data in ipairs(comms_data.defense_fleet_chances) do
		local ship = data.ship
		local chance = data.chance + station:getHullMax() / 100 -- assume hullMax of stations is not near 10,000
		if math.random(1,100) < chance then
			comms_data.idle_defense_fleet["DF"..tostring(i+1)] = ship
		else
			break	-- Abort after the first check fails. This causes low occurences of the last ship in the list.
		end
	end
end

--- Initializes the persistent communication data used by the station defense fleet.
---
--- Initializes the defense fleet configuration if necessary and generates the
--- defense fleet composition when the station has not generated one yet.
---
--- `idle_defense_fleet == nil` means that the station has not generated its
--- fleet yet. An empty table means that the fleet has already been launched
--- and is currently unavailable; it must therefore not be regenerated here.
function comms_vf_military.ensure_comms_data_defense_fleet(env)
	local comms_data = env.target.comms_data

	-- TODO we use yellow ones here, for no reason at all. Should be factional. Definitely for Arlenians!
	if comms_data.defense_fleet_chances == nil then
		comms_data.defense_fleet_chances = {
            {ship = "Yellow Hornet", chance = 95},
            {ship = "Yellow Adder MK4", chance = 90},
            {ship = "Phobos T3", chance = 85},
            {ship = "Yellow Adder MK5", chance = 80},
            {ship = "Nirvana R3", chance = 75},
            {ship = "Yellow Lindworm", chance = 70},
            {ship = "Piranha F12", chance = 65},
        }
	end

	if comms_data.idle_defense_fleet == nil then
		generate_defense_fleet(env.target)
	end
end

--- Starts one defensive ship through the station defense script.
---
--- This function bridges the military comms module and
--- `border_defend_station.lua`. The station and ship information is passed to
--- the script through script variables.
local function launch_defensive_ship(name, template, station)
	local script = Script()
	local position_x, position_y = station:getPosition()
	script:setVariable("position_x", position_x):setVariable("position_y", position_y)
	script:setVariable("station_name",station:getCallSign())
	script:setVariable("name",name)
	script:setVariable("template",template)
	script:setVariable("faction_id",station:getFactionId())
	script:run("border_defend_station.lua")
end

--- Comms service for activating a station's idle defense fleet.
---
--- The service is available only at friendly stations and when the station has at least
--- one idle defense ship. Selecting the service charges the configured
--- station-defense reputation cost and dispatches every ship currently stored
--- in `idle_defense_fleet`.
---
--- The fleet itself is generated separately by `ensure_comms_data_defense_fleet()`.
--- Once launched, the idle fleet is cleared and is not regenerated by this node.
comms_vf_military.defense = CommsNodeServiceBuyable:new({
	service_name = "activatedefensefleet",
	message = _("Activating station defense fleet"),
	select_choice_line = function(self,env)
		local cost = self:service_cost(env)
		local fleet_prompts = {
			string.format(_("Activate station defense fleet (%s rep)"),cost),
			string.format(_("Launch station defense fleet (%s rep)"),cost),
			string.format(_("Send out station defense fleet (%s rep)"),cost),
			string.format(_("Launch %s defenders (%s rep)"),env.target:getCallSign(),cost),
			string.format(_("Enable %s defenders (%s rep)"),env.target:getCallSign(),cost),
		}
		return(arraySelectRandom(fleet_prompts))
	end,
})

comms_vf_military.defense:add_condition(ccc.friendly_faction)
comms_vf_military.defense:add_condition(function(env)
	-- the defense fleet will retreat, when there are no enemies for 5 Minutes;
	-- they can be launched again, if they were not destroyed
	comms_vf_military.ensure_comms_data_defense_fleet(env)
	return next(env.target.comms_data.idle_defense_fleet) ~= nil	-- next() returns the first key-value pair
end)

comms_vf_military.defense:add_effect(function(self, env)
	-- idle_defense_fleet:
	-- `nil`: fleet has not been generated yet.
	-- non-empty table: fleet is idle and can be launched.
	-- empty table: fleet has been launched and is currently unavailable.
	-- The border_defend_station script is responsible for restoring the fleet later.
	assert(env.target.comms_data.idle_defense_fleet)
	for name, template in pairs(env.target.comms_data.idle_defense_fleet) do
		launch_defensive_ship(name, template, env.target)
	end
	env.target.comms_data.idle_defense_fleet = {}
	return true
end)

comms_vf_military.defense:add_test_setup(function(env)
	env.target.comms_data.service_cost["activatedefensefleet"] = 32
	env.target.getFactionId = function(self) assert(self); return 1 end
end)

comms_vf_military.defense:add_test(function(self, env)
	comms_vf_military.ensure_comms_data_defense_fleet(env) -- in test
	env.target.isFriendly = function(self) assert(self); return true end
	self:_can_select(env)
	assert(env.target.comms_data.idle_defense_fleet)
end)


-- insert links into comms tree:
comms_vf_station.automatic.ensure_comms_data:add_comms_data_initialiser_function(comms_vf_military.ensure_comms_data_reinforcements)

comms_vf_military.reinforcements:add_choice_to_all_children(CommsBack, true, true)
comms_vf_station.main:add_choice(comms_vf_military.defense)	

comms_vf_station.automatic.ensure_comms_data:add_comms_data_initialiser_function(comms_vf_military.ensure_comms_data_defense_fleet)
comms_vf_military.defense:add_choice_to_all_children(CommsBack, true, true)
comms_vf_station.main:add_choice(comms_vf_military.reinforcements)
