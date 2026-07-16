local ccc = common_comms_conditions	-- from lib_comms_nodes
comms_vf_military = {}

function comms_vf_military.ensure_comms_data_reinforcements(env)
	local comms_data = env.target.comms_data
	-- we always use blue ones here. for no reason at all. This should be factional instead.
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
				desc = _("stationAssist-comms",template),
				template = template,
				threshold = env.target.comms_data.reinforcement_threshold[template],
				cost = math.ceil(env.target.comms_data.reinforcement_cost[template]),
				stocked = math.random(1,100) <= 72 -- dafuq? always have 72% chance for every type?
			}
			info.choice_line = string.format(_("stationAssist-comms","%s (%d reputation)"),info.desc,info.cost)
			table.insert(comms_data.reinforcement_info, info)
		end
	end
	if comms_data.service_cost ~= nil then
		-- FIXME order was wrong
		comms_data.service_cost["reinforcements"] = 0
	end
end

-- reinforcements
comms_vf_military.reinforcements = CommsNodeServiceAvailable:new({
	service_name = "reinforcements",
	select_choice_line = function(self, env)
		return arraySelectRandom({
			"Send reinforcements",
			"Request friendly warship",
			"Send military help",
			"Get a ship to help us",
		})
	end,
	select_message = function(self, env)
		return arraySelectRandom({
            "What kind of reinforcement ship?",
            "What kind of ship should we send?",
            "Specify ship type",
            "Identify desired type of ship",
        })
	end,
	_show_choices = function(self, env)
		comms_vf_military.ensure_comms_data_reinforcements(env)
		local reinforcement_info = env.target.comms_data.reinforcement_info
		assert(reinforcement_info)
		local avail_count = 0
		for idx, info in ipairs(reinforcement_info) do
			if info.stocked and
			env.target.comms_data.friendlyness > info.threshold then
				avail_count = avail_count + 1
				addCommsReply(info.choice_line, self.with_reinforcecement_info:_as_comms_reply(env, info))
			end
		end
		if avail_count < 1 then
			local insufficient_reinforcements = {
				"No reinforcements available",
				"We don't have any reinforcements",
				"No military ships in our inventory, sorry",
				"Reinforcements unavailable",
			}
			setCommsMessage(arraySelectRandom(insufficient_reinforcements))	-- unclean
		end
		comms_vf_military.reinforcements.super()._show_choices(self, env)
	end,
	with_reinforcecement_info = CommsNodeWaypointSelect:new({
		effect = function(env)
			env.reinforcement_info = env.args
		end,
		with_waypoint = CommsNode:new({
			effect = function(env)
				-- unclean: message and effect are both in here - together with the buy check
				local info = env.reinforcement_info
				local waypoint = env.args
				assert(info)
				assert(waypoint)
				if env.source:takeReputationPoints(info.cost) then
					local ship = CpuShip():setFactionId(env.target:getFactionId()):setPosition(env.target:getPosition()):setTemplate(info.template):setScanned(true):orderDefendLocation(env.source:getWaypoint(waypoint))
					if generateCallSign ~= nil then
						suffix_index = math.random(11,77)	-- needs to be global for generateCallSign
						ship:setCallSign(generateCallSign(nil,env.target:getFaction()))
					end
					local sent_reinforcements = {
						string.format("We have dispatched %s to assist at waypoint %s",ship:getCallSign(),waypoint),
						string.format("%s is heading for waypoint %s",ship:getCallSign(),waypoint),
						string.format("%s has been sent to waypoint %s",ship:getCallSign(),waypoint),
						string.format("We ordered %s to help at waypoint %s",ship:getCallSign(),waypoint),
					}
					setCommsMessage(arraySelectRandom(sent_reinforcements))
				else
					local insufficient_rep_responses = {
						"Insufficient reputation",
						"Not enough reputation",
						"You need more reputation",
						string.format("You need more than %i reputation",math.floor(env.source:getReputationPoints())),
						"You don't have enough reputation",
					}
					setCommsMessage(arraySelectRandom(insufficient_rep_responses))
				end
			end
		})
	}),
}):add_condition(ccc.friendly_faction):add_test_setup(function(env)
	comms_vf_station.automatic.ensure_comms_data:_call(env)
	env.target.comms_data.service_available.reinforcements = true
	env.target.comms_data.friendlyness = 50
end)
comms_vf_military.reinforcements:add_test(function(self, env)
	env.target.comms_data.reinforcement_info = nil
	env.target.comms_data.friendlyness = 1
	comms_vf_station.automatic.ensure_comms_data:_call(env)
	self:_show_choices(env)
	env.target.comms_data.reinforcement_info = {
		desc = "test",
		template = "test",
		threshold = 27,
		cost = 28,
		stocked = true
	}
	env.target.comms_data.friendlyness = 100
	self:_show_choices(env)
	env.target.comms_data.reinforcement_info.stocked = false
end)

comms_vf_military.reinforcements.with_reinforcecement_info.with_waypoint:add_test_setup(function(env) 
	env.target.comms_data.service_available["reinforcements"] = true
end):add_test_setup(function(env)
	env.reinforcement_info = {
		desc = "test",
		template = "test",
		threshold = 27,
		cost = 28,
		stocked = true
	}
	env.target.getFactionId = function(self) assert(self); return 1 end
	env.args = 1
end)
comms_vf_military.reinforcements.with_reinforcecement_info.with_waypoint.test = function(self, env)
	env.reinforcement_info = {
		desc = "test",
		template = "test",
		threshold = 27,
		cost = 28,
		stocked = true
	}
	self.effect(env)
	env.reinforcement_info.stocked = false
	self.effect(env)
	generateCallSign = function() return "1" end
	env.reinforcement_info.stocked = true
	env.source.takeReputationPoints = function() return false end
	self.effect(env)
	env.source.takeReputationPoints = function() return true end
	comms_vf_military.reinforcements.with_reinforcecement_info.with_waypoint.super().test(self, env)
end

-- defense fleet
function comms_vf_military.ensure_comms_data_defense_fleet(env)
	-- TODO we use yellow ones here, for no reason at all. Should be factional. Definitely for Arlenians!
	local station = env.target
	station.comms_data.idle_defense_fleet = {["DF1"] =  "MT52 Hornet"}
	local station_type = station:getTypeName()
	if station.comms_data.defense_fleet_chances == nil then
		station.comms_data.defense_fleet_chances = {
            {ship = "Yellow Hornet", chance = 95},
            {ship = "Yellow Adder MK4", chance = 90},
            {ship = "Phobos T3", chance = 85},
            {ship = "Yellow Adder MK5", chance = 80},
            {ship = "Nirvana R3", chance = 75},
            {ship = "Yellow Lindworm", chance = 70},
            {ship = "Piranha F12", chance = 65},
        }
	end

	for i,data in ipairs(station.comms_data.defense_fleet_chances) do
		local ship = data.ship
		local chance = data.chance + station:getHullMax() / 100 -- assume hullMax of stations is not near 10,000
		if math.random(1,100) < chance then
			station.comms_data.idle_defense_fleet["DF"..tostring(i+1)] = ship
		else
			break
		end
	end
end

comms_vf_military.defense = CommsNodeServiceBuyable:new({
	service_name = "activatedefensefleet",
	select_choice_line = function(self,env)
		local cost = self:service_cost(env)
		local fleet_prompts = {
			string.format("Activate station defense fleet (%s rep)",cost),
			string.format("Launch station defense fleet (%s rep)",cost),
			string.format("Send out station defense fleet (%s rep)",cost),
			string.format("Launch %s defenders (%s rep)",env.target:getCallSign(),cost),
			string.format("Enable %s defenders (%s rep)",env.target:getCallSign(),cost),
		}
		return(arraySelectRandom(fleet_prompts))
	end,
})
comms_vf_military.defense:add_condition(ccc.friendly_faction)
comms_vf_military.defense:add_condition(function(env)
	-- the defense fleet will retreat, when there are no enemies for 5 Minutes;
	-- they can be launched again, if they were not destroyed
	comms_vf_military.ensure_comms_data_defense_fleet(env)
	assert(env.target.comms_data.idle_defense_fleet)
	local defense_fleet_count = 0
	for name, template in pairs(env.target.comms_data.idle_defense_fleet) do
		defense_fleet_count = defense_fleet_count + 1
	end
	return defense_fleet_count > 0
end)
comms_vf_military.defense:add_effect(function(self, env)
	assert(env.target.comms_data.idle_defense_fleet)
	for name, template in pairs(env.target.comms_data.idle_defense_fleet) do
		local script = Script()
		local position_x, position_y = env.target:getPosition()
		local station_name = env.target:getCallSign()
		script:setVariable("position_x", position_x):setVariable("position_y", position_y)
		script:setVariable("station_name",station_name)
		script:setVariable("name",name)
		script:setVariable("template",template)
		script:setVariable("faction_id",env.target:getFactionId())
		script:run("border_defend_station.lua")
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
