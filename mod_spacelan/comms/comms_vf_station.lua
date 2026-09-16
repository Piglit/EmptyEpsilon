--[[
Entry
├── Automatic / Greeting
│   ├── Update Science Database
│   ├── Panic Check
│   ├── Docked Greeting
│   └── Undocked Greeting
│
Main
├── Information
│   ├── Report Station Status
│   ├── (Station Information)
│   ├── Gossip -> terrain_module
│   ├── General Information -> general
│   ├── Station History	-> history
│	├──	Station Services -> services
│	├──	Weapons available -> comms_vf_weapons
│   └── Missions / Service Improvements
│	    ├──	Dispatch Office / Missions
│		└── Service Improvements
├── Docked
│   ├── Restock Ordnance -> comms_vf_weapons.lua
			why is it so expensive (neutral)
				Change Faction
			dont you have more?
				Change Faction
				Service Improvements
│   ├── Repair Systems
│   │   ├── Probe Launcher
│   │   ├── Hacking
│   │   ├── Scanners
│   │   ├── Combat Maneuver
│   │   ├── Self Destruct
│   │   └── Missile Tubes
│   ├── Refit Drive
│   ├── Enhance Ship / Upgrades
│   ├──	Dispatch Office / Missions
│   ├── Change Faction (neutral)
│   └── Service Improvements
│      ├── probes
│      ├── hull
│      ├── energy
│      ├── homing
│      ├── hvli
│      ├── mine
│      ├── emp
│      └── nuke
├── Undocked
│   ├── Supply Drop
│	│   ├── Impulse Supply Drop
│	│   ├── Jump Supply Drop
├── Military (friendly)	-> comms_vf_military.lua
│   ├── Request Reinforcements
│   └── Activate Station Defense Fleet
└── Enemy
    └── Intimidate Station / Change Faction


Note: some features are defined in other modules (like comms_vf_weapons.lua).
Those modules insert their nodes into the station main and automatic tree.
To use the nodes defined in these modules, they need to be require() from the scenario or comms script.
This module is designed to work with or without them.
That way you can enable feature-subtrees for specific scenarios just by requireing the module.
--]]


--[[
Note
some functions need access to specific values of comms_data.
Those can be set on various points, like in the place station utility depending on the stations name or in the place station scenario script, depending on the surrounding terrain.
So in the functions here we can not assume, that a key in comms_data exists.
--]]



local ccc = common_comms_conditions	-- from lib_comms_nodes

-- categories. None of these should be comms nodes, but only tables.
comms_vf_station = {
	automatic = {},
	info = {},
	docked = {},
	undocked = {},
	enemy = {},
}

--====================================================
-- Utility functions, can be used multiple times
--====================================================

-- services and station improvements
-- they belong together, since they need to check the same things, and services states what improvements can fix.

local function ensure_failure_reasons(env)
	-- called by catalogMessage
	-- updates the station state to keep that message
	if not env.target:getRestocksScanProbes() and env.target.probe_fail_reason == nil then
		local reason_list = {
			_("situationReport-comms", "Cannot replenish scan probes due to fabrication unit failure."),
			_("situationReport-comms", "Parts shortage prevents scan probe replenishment."),
			_("situationReport-comms", "Station management has curtailed scan probe replenishment for cost cutting reasons."),
		}
		env.target.probe_fail_reason = reason_list[math.random(#reason_list)]
	end

	if not env.target:getRepairDocked() and env.target.repair_fail_reason == nil then
		local reason_list = {
			_("situationReport-comms", "We're out of the necessary materials and supplies for hull repair."),
			_("situationReport-comms", "Hull repair automation unavailable while it is undergoing maintenance."),
			_("situationReport-comms", "All hull repair technicians quarantined to quarters due to illness."),
		}
		env.target.repair_fail_reason = reason_list[math.random(#reason_list)]
	end

	if not env.target:getSharesEnergyWithDocked() and env.target.energy_fail_reason == nil then
		local reason_list = {
			_("situationReport-comms", "A recent reactor failure has put us on auxiliary power, so we cannot recharge ships."),
			_("situationReport-comms", "A damaged power coupling makes it too dangerous to recharge ships."),
			_("situationReport-comms", "An asteroid strike damaged our solar cells and we are short on power, so we can't recharge ships right now."),
		}
		env.target.energy_fail_reason = reason_list[math.random(#reason_list)]
	end
end

function failure_messages(env, include_nominal)
	ensure_failure_reasons(env)
	local msg = ""
	if env.target:getRestocksScanProbes() then
		if include_nominal then
			msg = string.format(_("situationReport-comms","%s\nWe replenish scan probes."), msg)
		end
	else
		msg = string.format("%s\n%s", msg, env.target.probe_fail_reason)
	end

	if env.target:getRepairDocked() then
		if include_nominal then
			msg = string.format(_("situationReport-comms","%s\nWe repair your ship hull."), msg)
		end
	else
		msg = string.format("%s\n%s", msg, env.target.repair_fail_reason)
	end

	if env.target:getSharesEnergyWithDocked() then
		if include_nominal then
			msg = string.format(_("situationReport-comms","%s\nWe recharge ship energy stores."), msg)
		end
	else
		msg = string.format("%s\n%s", msg, env.target.energy_fail_reason)
	end
	return msg
end

local function services_message(env)
	-- called by services
	comms_vf_station.automatic.ensure_comms_data:_apply_effects(env)
	local msg = _("We provide the following services:")
	msg = string.format("%s\n%s", msg, failure_messages(env, true))

	--[[ disabled for now
	if env.target.comms_data.system_repair ~= nil then
		local system_list_desc = {
			reactor       = _("situationReport-comms","reactor"),
			beamweapons   = _("situationReport-comms","beam weapons"),
			missilesystem = _("situationReport-comms","missile system"),
			maneuver      = _("situationReport-comms","maneuver"),
			impulse       = _("situationReport-comms","impulse"),
			warp          = _("situationReport-comms","warp drive"),
			jumpdrive     = _("situationReport-comms","jump drive"),
			frontshield   = _("situationReport-comms","front shield"),
			rearshield    = _("situationReport-comms","rear shield"),
		}

		local major_repairs = {}
		for system, desc in pairs(system_list_desc) do
			if env.target.comms_data.system_repair[system] then
				table.insert(major_repairs, desc)
			end
		end

		if #major_repairs > 0 then
			if #major_repairs == 9 then
				msg = string.format("%s\n\n %s.",
				msg,
				_("situationReport-comms","We repair all major systems"))
			else
				msg = string.format("%s\n\n%s %s.",
				msg,
				_("situationReport-comms","We repair these major systems:"),
				table.concat(major_repairs, ", "))
			end
		end
	end

	assert(env.target.comms_data.function_repair ~= nil)
	local minor_repairs = {}
	for system, avail in pairs(env.target.comms_data.function_repair) do
		if avail and
			env.target.comms_data.service_desc ~= nil and 
			env.target.comms_data.service_desc[system] ~= nil then
			table.insert(minor_repairs,env.target.comms_data.service_desc[system])
		end
	end
	if #minor_repairs > 0 then
		msg = string.format("%s\n%s %s.",
		msg,
		_("situationReport-comms","Repair these minor systems:"),
		table.concat(minor_repairs, ", "))
	end
	--]]

	--local overcharge_service = ""
	--if env.target.comms_data.jump_overcharge then
	--    overcharge_service = "jump drive"
	--end
	--if env.target.comms_data.shield_overcharge then
	--    if overcharge_service == "" then
	--        overcharge_service = "shields"
	--    else
	--        overcharge_service = "jump drive and shields"
	--    end
	--end
	--if overcharge_service ~= "" then
	--    msg = string.format("%s\nOvercharge service available for %s",msg,overcharge_service)
	--end

	return msg
end

--local function service_improvements(env)
--	local improvements = {}
--
--	if not env.target:getRestocksScanProbes() then
--		table.insert(improvements, "restock_probes")
--	end
--
--	if not env.target:getRepairDocked() then
--		table.insert(improvements, "hull")
--	end
--
--	if not env.target:getSharesEnergyWithDocked() then
--		table.insert(improvements, "energy")
--	end
--
--	if env.target.comms_data.system_repair ~= nil then
--		for system, data in pairs(env.target.comms_data.system_repair) do
--			if not data.avail then
--				table.insert(improvements, system)
--			end
--		end
--	end
--
--	if env.target.comms_data.function_repair ~= nil then
--		local secondary_systems = {
--			"scan_repair",
--			"combat_maneuver_repair",
--			"hack_repair",
--			"probe_launch_repair",
--			"tube_slow_down_repair",
--			"self_destruct_repair",
--		}
--		for _, system in ipairs(secondary_systems) do
--			if not env.target.comms_data.function_repair[system] then
--				table.insert(improvements, system)
--			end
--		end
--	end
--
--	if env.target.comms_data.weapon_available ~= nil then
--		for _, weapon in ipairs(MISSILE_TYPES) do
--			if not env.target.comms_data.weapon_available[weapon] then
--				table.insert(improvements, weapon)
--			end
--		end
--	end
--
--	return improvements
--end

local function services_test_data(env, avail)
	-- keep fail reasons nil
	if avail ~= nil then
		env.target.comms_data = {
			system_repair = {
				reactor       = avail,
				beamweapons   = avail,
				missilesystem = avail,
				maneuver      = avail,
				impulse       = avail,
				warp          = avail,
				jumpdrive     = avail,
				frontshield   = avail,
				rearshield    = avail,
			},

			function_repair = {
				scan_repair = avail,
				combat_maneuver_repair = avail,
				hack_repair = avail,
				probe_launch_repair = avail,
				tube_slow_down_repair = avail,
				self_destruct_repair = avail,
			},

			weapon_available = {
				Nuke = avail,
				EMP = avail,
				Homing = avail,
				Mine = avail,
				HVLI = avail,
			},
			
			raise_weapon_cost = avail,
		}
	
	else
		env.target.comms_data = {}
		avail = true
	end
	env.target.getRestocksScanProbes = function(self) assert(self); return avail end
	env.target.getRepairDocked = function(self) assert(self); return avail end
	env.target.getSharesEnergyWithDocked = function(self) assert(self); return avail end
end


--====================================================
-- Automatic / Greeting
--====================================================
-- the following nodes are called automatically in comms_vf_station.automatic.pipeline

comms_vf_station.automatic.ensure_comms_data = CommsNode:new({
	skip_in_back_stack = true,
	initialisers = {},
	add_comms_data_initialiser_function = function(self, fun)
		table.insert(self.initialisers, fun)
	end,
}):add_effect(function(self, env)
	if env.target.comms_data == nil then
		env.target.comms_data = {}
	end
	local comms_data = env.target.comms_data
	-- single variables
	if comms_data.friendlyness == nil then	-- this typo is present from the original api
		comms_data.friendlyness = math.random(0,100)
	end
	-- ensure_comms_data from other modules must be inserted using add_comms_data_initialiser_function.
	for _,fun in ipairs(self.initialisers) do
		fun(env)
	end
	return true 
end)

function comms_vf_station.ensure_comms_data_repair(env)
	local comms_data = env.target.comms_data
	if comms_data._repair_init then
		return
	end
	comms_data._repair_init = true
	if comms_data.system_repair == nil then
		comms_data.system_repair = {
			reactor       = false,
			beamweapons   = false,
			missilesystem = false,
			maneuver      = false,
			impulse       = false,
			warp          = false,
			jumpdrive     = false,
			frontshield   = false,
			rearshield    = false,
		}
	end
	if comms_data.function_repair == nil then
		comms_data.function_repair = {
			scan_repair = false,
			combat_maneuver_repair = false,
			hack_repair = false,
			probe_launch_repair = false,
			tube_slow_down_repair = false,
			self_destruct_repair = false,
		}
	end
end
--comms_vf_station.automatic.ensure_comms_data:add_comms_data_initialiser_function(comms_vf_station.ensure_comms_data_repair)

comms_vf_station.ensure_comms_data_services = function(env)
	local comms_data = env.target.comms_data
	if comms_data._services_init then
		return
	end
	comms_data._services_init = true
	if comms_data.reputation_cost_multipliers == nil then
		comms_data.reputation_cost_multipliers = {
			friend = 1.0,
			neutral = 3.0,
		}
	end
	if comms_data.service_available == nil then
		comms_data.service_available = {}
	end
	local default_service_cost = {
			supplydrop = math.random(80,120),
			jumpsupplydrop = math.random(110,140),
			flingsupplydrop = math.random(140,170),
			activatedefensefleet = math.random(20, 40),
			--servicejonque = math.random(100,150),
			--probe_launch_repair = math.random(1,4) + math.random(1,5),
			--hack_repair = math.random(1,4) + math.random(1,5),
			--scan_repair = math.random(1,4) + math.random(1,5),
			--combat_maneuver_repair = math.random(1,4) + math.random(1,5),
			--self_destruct_repair = math.random(1,4) + math.random(1,5),
			--tube_slow_down_repair = math.random(1,4) + math.random(1,5),
			--refitDrive = 150,
			surrender = env.target:getHullMax() * 2 -- this is 300 - 1600.
		}
	if comms_data.service_cost == nil then
		comms_data.service_cost = {}
	end
	for service, cost in pairs(default_service_cost) do
		if comms_data.service_available[service] == nil then
			comms_data.service_available[service] = false
		end
		if comms_data.services then	-- from place_station_scenario_utility
			if comms_data.services[service] then -- can be string like "friend"
				comms_data.service_available[service] = true
			end
		end
		if comms_data.service_cost[service] == nil then
			assert(default_service_cost[service] ~= nil)
			comms_data.service_cost[service] = cost
		end
	end
	if comms_data.service_desc == nil then
		comms_data.service_desc = {
			supplydrop =			_("scienceDB","Drop supplies"),
			jumpsupplydrop =		_("scienceDB","Jump ship drops supplies"),
			flingsupplydrop =		_("scienceDB","Flinger drops supplies"),
			reinforcements =		_("scienceDB","Reinforcements"),
--				hornet_reinforcements =	_("scienceDB","Hornet reinforcements"),
--				phobos_reinforcements =	_("scienceDB","Phobos reinforcements"),
--				stalker_reinforcements =_("scienceDB","Stalker reinforcements"),
--				amk8_reinforcements =	_("scienceDB","Adder8 reinforcements"),
			activatedefensefleet =	_("scienceDB","Activate defense fleet"),
--			servicejonque =			_("scienceDB","Provide service jonque"),
--			shield_overcharge =		_("scienceDB","Overcharge shield"),
--			jump_overcharge =		_("scienceDB","Overcharge jump drive"),
--			scan_repair =           _("situationReport-comms","scanners"),
--			combat_maneuver_repair =_("situationReport-comms","combat maneuver"),
--			hack_repair =           _("situationReport-comms","hacking"),
--			probe_launch_repair =   _("situationReport-comms","probe launch"),
--			tube_slow_down_repair = _("situationReport-comms","slow tube"),
--			self_destruct_repair =  _("situationReport-comms","self destruct"),
		}
	end
end
comms_vf_station.automatic.ensure_comms_data:add_comms_data_initialiser_function(comms_vf_station.ensure_comms_data_services)

comms_vf_station.automatic.ensure_comms_data:add_test(function(self, env)
		comms_vf_station.automatic.ensure_comms_data:_apply_effects(env)
		env.target.comms_data = nil
		comms_vf_station.automatic.ensure_comms_data:_apply_effects(env)
		env.target.comms_data = {}
		comms_vf_station.automatic.ensure_comms_data:_apply_effects(env)
	end
)

comms_vf_station.automatic.update_database = CommsNode:new({
	--message = "Update Science Database",
	skip_in_back_stack = true,
	effect = function(env)
		local station = env.target
		assert(station.comms_data)
		-- The old version had issues with multiple fations.
		-- in this version the faction is used as key.
		--    Assumes all player ships will be the same faction
		-- TODO test handle faction change

		local stations_key = _("scienceDB","Stations")
		local stations_db = queryScienceDatabase(stations_key)
		if stations_db == nil then
			stations_db = ScienceDatabase():setName(stations_key)
		end

		local station_db = nil
		local station_key = station:getCallSign()
		local first_time_entry = false

		local faction_key = station:getFaction()
		local faction_db = queryScienceDatabase(stations_key, faction_key)
		if faction_db == nil then
			stations_db:addEntry(faction_key)
			faction_db = queryScienceDatabase(stations_key, faction_key)
			local attitude_msg = ""
			if station:isFriendly(env.source) then
				attitude_msg = _("scienceDB","Friendly stations share their short range telemetry with your ship on the Relay and Strategic Map consoles. The service costs are lower compared to neutral stations.")
			elseif not station:isEnemy(env.source) then
				attitude_msg = _("scienceDB","Neutral stations don't share their short range telemetry with your ship, but they do allow for docking. They will not sell you many EMPs or Nukes and service costs will be higher compared to friendly stations.")
			end
			faction_db:setLongDescription(string.format(
				_("scienceDB","Known stations belonging to the %s faction.\n%s"),
				faction_key,
				attitude_msg
			))
		end
		assert(faction_db)

		-- add to db
		station_db = queryScienceDatabase(stations_key, faction_key, station_key)
		if station_db == nil then
			faction_db:addEntry(station_key)
			station_db = queryScienceDatabase(stations_key, faction_key, station_key)
			first_time_entry = true
		end

		-- remove the old ones after faction change
		-- assume there are not two stations with the same callsign
		for _, faction_db in ipairs(stations_db:getEntries()) do
			if faction_db:getName() ~= faction_key then
				local old_station_db = queryScienceDatabase(
					stations_key,
					faction_db:getName(),
					station_key
				)
				if old_station_db ~= nil then
					old_station_db:destroy()
				end
			end
		end

		if first_time_entry then
			local out = ""
			if station:getDescription() ~= nil then
				out = station:getDescription()
			end
			if station.comms_data.general ~= nil and station.comms_data.general ~= "" then
				out = string.format(_("scienceDB","%s\n\nGeneral Information: %s"),out,station.comms_data.general)
			end
			if station.comms_data.history ~= nil and station.comms_data.history ~= "" then
				out = string.format(_("scienceDB","%s\n\nHistory: %s"),out,station.comms_data.history)
			end
			if out ~= "" then
				station_db:setLongDescription(out)
			end

			local station_type = station:getTypeName()
			local template_db = queryScienceDatabase(stations_key, station_type)

			if template_db ~= nil then
				station_db:setImage(template_db:getImage())
				station_db:setModelDataName(template_db:getModelDataName())
			end
		end
		assert(station_db)

		local dock_service = {}
		local service_count = 0
		if station:getSharesEnergyWithDocked() then
			table.insert(dock_service, _("scienceDB","share energy"))
		end
		if station:getRepairDocked() then
			table.insert(dock_service, _("scienceDB","repair hull"))
		end
		if station:getRestocksScanProbes() then
			table.insert(dock_service, _("scienceDB","replenish probes"))
		end
		if #dock_service > 0 then
			local docking_services_key = _("scienceDB","Docking Services")
			if #dock_service == 1 then
				docking_services_key = _("scienceDB","Docking Service")
			end
			station_db:setKeyValue(docking_services_key, table.concat(dock_service, ", "))
		end

		if comms_vf_weapons then
			for i,missile in ipairs(comms_vf_weapons.get_available_weapons(env)) do
				-- get_available_weapons ensure
				local cost = comms_vf_weapons.get_weapon_cost(env, missile)
				if type(cost) == "number" then
					local val = string.format(_("scienceDB","%d reputation each"),cost)
					station_db:setKeyValue(missile,val)
				end
			end
		end
--		assert(station.comms_data.function_repair ~= nil)
--		for func, avail in pairs(station.comms_data.function_repair) do
--			if avail then
--				if station.comms_data.service_desc[func] then
--					if station.comms_data.service_cost[func] ~= nil then
--						local key = string.format(_("scienceDB","Repair %s"), station.comms_data.service_desc[func])
--						local val = string.format(_("scienceDB","%s reputation"),station.comms_data.service_cost[func])
--						station_db:setKeyValue(key,val)
--					end
--				end
--			end
--		end
		assert(station.comms_data.service_available ~= nil)
		for serv, avail in pairs(station.comms_data.service_available) do
			if avail and
			station.comms_data.service_desc[serv] then
				local key = station.comms_data.service_desc[serv]
				local val = "available"
				if station.comms_data.service_cost[serv] ~= nil then
					if station.comms_data.service_cost[serv] > 0 then
						val = string.format(_("scienceDB","%s reputation"),station.comms_data.service_cost[serv])
					end
				end
				station_db:setKeyValue(key,val)
			end
		end
	end,
}):add_test_setup(function(env)
	comms_vf_station.automatic.ensure_comms_data:_apply_effects(env)
end):add_test(function(self, env)
	local old_faction = env.target.getFaction
	env.target.isFriendly = function(self, obj) assert(self); assert(obj); return false end
	env.target.isEnemy = function(self, obj) assert(self); assert(obj); return false end
	env.target.getFaction = function(self) assert(self); return "Independent" end
	self.effect(env)
	env.target.getRestocksScanProbes = function(self) assert(self); return false end
	env.target.getRepairDocked = function(self) assert(self); return false end
	env.target.isFriendly = function(self, obj) assert(self); assert(obj); return true end
	env.target.getFaction = function(self) assert(self); return "Human Navy" end
	local stations_db = queryScienceDatabase(_("scienceDB","Stations"))
	stations_db:addEntry("Small Station")
	self.effect(env)
end):add_condition(ccc.docked)
comms_vf_station.automatic.update_database:add_test_setup(function(env)
	env.target.getRestocksScanProbes = function(self) assert(self); return true end
	env.target.getRepairDocked = function(self) assert(self); return true end
	env.target.getSharesEnergyWithDocked = function(self) assert(self); return true end
	env.target.getDescription = function(self) assert(self); return "Descr" end
	env.target.getLongDescription = function(self) assert(self); return "Description" end
	env.target.getCallSign = function(self) assert(self); return "Le station" end
	env.target.getTypeName = function(self) assert(self); return "Small Station" end
	env.target.comms_data.general = "general"
	env.target.comms_data.history = "history"
	--env.target.comms_data.function_repair.scan_repair = true
	env.target.comms_data.service_desc.scan_repair = _("situationReport-comms","scanners")
	env.target.comms_data.service_cost.scan_repair = 12
	env.target.comms_data.service_available.supplydrop = true
	env.target.comms_data.service_desc.supplydrop = _("scienceDB","supplydrop")
	env.target.comms_data.service_cost.supplydrop = 14
end)

comms_vf_station.automatic.greeter = CommsRedirection:new({})

comms_vf_station.automatic.docked_greeting = CommsNodeGreeter:new({
--	message = "Docked Greeting",
	messages = {
		_("greeted-by-station-docked",
		"Hello, space traveler!  It's a pleasure to see {source_callsign} docking with us.  How can we make your stay on {target_callsign} more comfortable?"),
		_("greeted-by-station-docked",
		"Greetings, cosmic colleague!  {source_callsign}'s docking is a cause for celebration here on {target_callsign}.  Any messages or updates to share?"),
		_("greeted-by-station-docked",
		"Good day, starfaring friend!  Your arrival is like a cosmic reunion for {target_callsign}.  Any tales from your travels?"),
		_("greeted-by-station-docked",
		"Salutations, fellow communicator!  {source_callsign} has reached {target_callsign} safe and sound.  Anything exciting to share from your journey?"),
		_("greeted-by-station-docked",
		"Hello there!  Welcome to {target_callsign}.  It's fantastic to have you on board."),
		_("greeted-by-station-docked",
		"Hello, astral envoy!  {source_callsign} has made a stellar entrance.  Any interesting discoveries on your voyage to {target_callsign}?"),
		_("greeted-by-station-docked",
		"Salutations, space traveler!  {source_callsign}'s arrival marks another chapter in {target_callsign}'s cosmic adventures.  How can we assist you today?"),
		_("greeted-by-station-docked",
		"Welcome, {source_callsign}!  It's a pleasure to see you docking with {target_callsign}.  How's the cosmic voyage treating you?"),
		_("greeted-by-station-docked",
		"Hello there, {source_callsign}!  Your arrival brings a new energy to {target_callsign}.  How was your journey?"),
		_("greeted-by-station-docked",
		"Greetings, {source_callsign}!  Welcome to our space station.  It's an honor to have you on board."),
		_("greeted-by-station-docked",
		"Hello, relay officer.  I suppose we should acknowledge the docking of {source_callsign}, as unremarkable as it may be."),
		_("greeted-by-station-docked",
		"Welcome, spacefaring communicator.  {source_callsign} docks, and the cosmos barely flinches.  How typical."),
		_("greeted-by-station-docked",
		"Ah, the celestial messenger has arrived.  Do enlighten us with tales of {source_callsign}'s travels, if you must."),
		_("greeted-by-station-docked",
		"Well, well, if it isn't {source_callsign}.  I trust your journey was at least mildly tolerable."),
		_("greeted-by-station-docked",
		"Ah, the starship {source_callsign} graces us with its presence.  How quaint.  Welcome to our humble space station."),
		_("greeted-by-station-docked",
		"Welcome, spacefaring communicator.  I hope {source_callsign}'s visit won't disrupt {target_callsign}'s delicate equilibrium too much."),
		_("greeted-by-station-docked",
		"Salutations, celestial correspondent.  {source_callsign}'s docking disrupted our routine.  What urgent message do you bring, if any?"),
		_("greeted-by-station-docked",
		"Hello there, {source_callsign}.  Your arrival was as eagerly anticipated as a space debris collision.  What's the news?"),
		_("greeted-by-station-docked",
		"Well, look who decided to drop by.  What cosmic inconvenience brings {source_callsign} to {target_callsign} today?"),
		_("greeted-by-station-docked",
		"Oh, joy.  The starship {source_callsign} has graced us with their presence.  What brings you here?"),
		_("greeted-by-station-docked",
		"Greetings, stellar correspondent.  {source_callsign}'s docking is a source of mild irritation.  What cosmic drama unfolds now?"),
		_("greeted-by-station-docked",
		"Welcome aboard, cosmic messenger.  {source_callsign}'s docking better have a good reason.  We have enough on our plate without your cosmic theatrics."),
		_("greeted-by-station-docked",
		"Hello, starbound emissary.  {source_callsign}'s presence is less of a pleasure and more of a cosmic headache.  What brings you to {target_callsign}?"),
		_("greeted-by-station-docked",
		"Salutations, interstellar nuisance.  {source_callsign}'s docking is the last thing we needed.  What pressing crisis are you here to address?"),
	},
}):add_condition(ccc.docked)


comms_vf_station.automatic.undocked_greeting = CommsNodeGreeter:new({
	message = "Undocked Greeting",
	skip_in_back_stack = true,
	messages = {
		_("greeted-by-station-undocked", "This is {target_callsign}'s communications officer.  Go ahead, {source_callsign}.  We're listening."),
		_("greeted-by-station-undocked", "{target_callsign} to {source_callsign}, receiving your communication.  Proceed with your message."),
		_("greeted-by-station-undocked", "Confirmed, {source_callsign}.  You're connected to {target_callsign}.  Go ahead."),
		_("greeted-by-station-undocked", "This is the {target_callsign} communications officer.  Go ahead, {source_callsign}."),
		_("greeted-by-station-undocked", "{target_callsign} acknowledges {source_callsign}'s communication.  Pray, don't keep us in suspense any longer."),
		_("greeted-by-station-undocked", "{source_callsign}, it is positively thrilling to be the recipient of your undoubtedly important message.  Please enlighten us."),
		_("greeted-by-station-undocked", "Acknowledged, {source_callsign}.  Try not to waste our time.  What do you want?"),
		_("greeted-by-station-undocked", "What is it now, {source_callsign}?  Make it quick; we're not here for small talk."),
		_("greeted-by-station-undocked", "{target_callsign} reluctantly acknowledges your communication.  Make it snappy, {source_callsign}."),
	},
}):add_condition(ccc.undocked):add_condition(ccc.not_enemy_faction)

comms_vf_station.automatic.enemy_greeting = CommsNode:new({
	message = _("special-comms", "You are our declared enemy. What do you want?"),
	skip_in_back_stack = true,
}):add_condition(ccc.enemy_faction)

comms_vf_station.automatic.pipeline = CommsPipeline:new()
comms_vf_station.automatic.pipeline:add_choice(comms_vf_station.automatic.ensure_comms_data)
comms_vf_station.automatic.pipeline:add_choice(comms_vf_station.automatic.update_database)
--comms_vf_station.automatic.pipeline:add_choice(comms_vf_station.automatic.panic_check) -- no benefit to gameplay
comms_vf_station.automatic.pipeline:add_choice(comms_vf_station.automatic.greeter)
comms_vf_station.automatic.greeter:add_choice(comms_vf_station.automatic.docked_greeting)
comms_vf_station.automatic.greeter:add_choice(comms_vf_station.automatic.undocked_greeting)
comms_vf_station.automatic.pipeline:add_choice(comms_vf_station.automatic.enemy_greeting)
--comms_vf_station.automatic.pipeline should be the entry point of the comms function!

--====================================================
-- Information
--====================================================
comms_vf_station.info.main = CommsNode:new({
	select_choice_line = function(self, env)
		return arraySelectRandom({
			_("Information"),
			_("I need information"),
			_("Ask questions"),
			_("I need to know what you know"),
		})
	end,
	select_message = function(self, env)
		return arraySelectRandom({
			_("station-comms","What kind of information do you want?"),
			_("station-comms","What kind of information do you need?"),
			_("station-comms","What kind of information do you seek?"),
			_("station-comms","What kind of information are you looking for?"),
			_("station-comms","What kind of information are you interested in?"),
		})
	end,
}):add_condition(ccc.not_enemy_faction)

comms_vf_station.info.status = CommsNode:new({
	choice_line = _("Report station status"),
	select_message = function(self, env)
		local comms_target = env.target
		local msg = _("Here is our status:\n")
        msg = msg .. string.format(_("situationReport-comms","Hull:%s%%    "),math.floor(comms_target:getHull() / comms_target:getHullMax() * 100))
        local shields = comms_target:getShieldCount()
        if shields == 1 then
            msg = string.format(_("situationReport-comms","%s  Shield:%s%%"),msg,math.floor(comms_target:getShieldLevel(0) / comms_target:getShieldMax(0) * 100))
        else
            for n=0,shields-1 do
                msg = string.format(_("situationReport-comms","%s  Shield %s:%s%%"),msg,n,math.floor(comms_target:getShieldLevel(n) / comms_target:getShieldMax(n) * 100))
            end
        end
		msg = string.format("%s\n%s", msg, failure_messages(env, false))
		-- TODO panic active, missions, services, ... at least if there is something
		return msg
	end,
	test = function(self, env)
		env.target.getHull = function(self) assert(self); return 40 end
		env.target.getHullMax = function(self) assert(self); return 80 end
		env.target.getShieldLevel = function() return 20 end
		env.target.getShieldMax = function() return 20 end
		env.target.getShieldCount = function() return 1 end
		comms_vf_station.info.status.super().test(self,env)
		env.target.getShieldCount = function() return 2 end
		comms_vf_station.info.status.super().test(self,env)
		env.target.getShieldCount = function() return 3 end
		comms_vf_station.info.status.super().test(self,env)
	end
}):add_condition(ccc.not_enemy_faction)


--comms_vf_station.info.station_information = CommsNode:new({
--	choice_line = "Station Information",
--})

comms_vf_station.info.gossip = CommsNode:new({
	choice_line = _("Gossip"),
	select_message = function(self, env)
		if env.target.comms_data.gossip then
			return table.concat(env.target.comms_data.gossip, "\n\n")
		end
	end,
	-- TODO populate
}):add_condition(function(env)
	local gossip = env.target.comms_data.gossip
	return type(gossip) == "table" and
		#gossip > 0
end):add_test_setup(function(env)
	env.target.comms_data.gossip = {
		"gossip1",
		"gossip2",
	}
end)

comms_vf_station.info.general = CommsNode:new({
	choice_line = _("General Information"),
	select_message = function(self, env)
		return env.target.comms_data.general
	end
}):add_condition(function(env)
	return env.target.comms_data.general ~= nil and
		env.target.comms_data.general ~= ""
end)

comms_vf_station.info.history = CommsNode:new({
	choice_line = _("Station History"),
	select_message = function(self, env)
		return env.target.comms_data.history
	end
}):add_condition(function(env)
	return env.target.comms_data.history ~= nil and
		env.target.comms_data.history ~= ""
end)

comms_vf_station.info.services = CommsNode:new({
	choice_line = _("Station Services"),
	select_message = function(self, env)
        return services_message(env)
	end,
	test = function(self, env)
		services_test_data(env, nil)
		self:select_message(env)
		services_test_data(env, false)
		self:select_message(env)
		services_test_data(env, true)
		self:select_message(env)
		env.target.comms_data.system_repair.frontshield = nil
		env.target.comms_data.services = {
			supplydrop = true
		}
		self:select_message(env)
		comms_vf_station.automatic.ensure_comms_data:_apply_effects(env)
		comms_vf_station.info.services.super().test(self,env)
	end
})


comms_vf_station.info.missions = CommsNode:new({
	choice_line = "Missions / Service Improvements",
	-- TODO
}):add_condition(ccc.disabled)


--====================================================
-- Docked
--====================================================

-- Restock Ordnance

-- Repair Systems

comms_vf_station.docked.repair = CommsNode:new({
	choice_line = "Repair Systems",
}):add_condition(ccc.docked):add_condition(ccc.disabled)

comms_vf_station.docked.repair.probes = CommsNode:new({
	choice_line = "Probe Launcher",
})

comms_vf_station.docked.repair.hacking = CommsNode:new({
	choice_line = "Hacking",
})

comms_vf_station.docked.repair.scanners = CommsNode:new({
	choice_line = "Scanners",
})

comms_vf_station.docked.repair.combat = CommsNode:new({
	choice_line = "Combat Maneuver",
})

comms_vf_station.docked.repair.self_destruct = CommsNode:new({
	choice_line = "Self Destruct",
})

comms_vf_station.docked.repair.tubes = CommsNode:new({
	choice_line = "Missile Tubes",
})


comms_vf_station.docked.refit = CommsNode:new({
	choice_line = "Refit Drive",
}):add_condition(ccc.docked):add_condition(ccc.disabled)
-- TODO

comms_vf_station.docked.enhance = CommsNode:new({
	choice_line = "Enhance Ship / Upgrades",
}):add_condition(ccc.docked):add_condition(ccc.disabled)
-- TODO

comms_vf_station.docked.dispatch = CommsNode:new({
	choice_line = "Dispatch Office / Missions",
}):add_condition(ccc.docked):add_condition(ccc.disabled)
-- TODO

comms_vf_station.docked.faction = CommsNode:new({
	choice_line = "Change Faction",
}):add_condition(ccc.docked):add_condition(ccc.disabled)
-- TODO


comms_vf_station.docked.improvements = CommsNode:new({
	choice_line = "Service Improvements",
}):add_condition(ccc.docked):add_condition(ccc.disabled)
-- TODO

comms_vf_station.docked.improvements.probes = CommsNode:new({
	choice_line = "Probes",
})

comms_vf_station.docked.improvements.hull = CommsNode:new({
	choice_line = "Hull",
})

comms_vf_station.docked.improvements.energy = CommsNode:new({
	choice_line = "Energy",
})

comms_vf_station.docked.improvements.homing = CommsNode:new({
	choice_line = "Homing",
})

comms_vf_station.docked.improvements.hvli = CommsNode:new({
	choice_line = "HVLI",
})

comms_vf_station.docked.improvements.mine = CommsNode:new({
	choice_line = "Mine",
})

comms_vf_station.docked.improvements.emp = CommsNode:new({
	choice_line = "EMP",
})

comms_vf_station.docked.improvements.nuke = CommsNode:new({
	choice_line = "Nuke",
})


--====================================================
-- Undocked
--====================================================

comms_vf_station.undocked.supply = CommsNode:new({
	choice_line = _("Supply Drop"),
	message = _("What kind of supply drop do you want?")
}):add_condition(ccc.undocked):add_test(function(self, env)
	env.target.comms_data.service_available["supplydrop"] = false
	env.target.comms_data.service_available["jumpsupplydrop"] = false
	env.target.comms_data.service_available["flingsupplydrop"] = false
	self:_can_select(env)
end)
:add_condition(ccc.not_enemy_faction)

local function ready_supply_drop_script(env)
	local waypoint = env.args
	assert(type(waypoint) == "number", type(waypoint))
	local position_x, position_y = env.target:getPosition()
	local target_x, target_y = env.source:getWaypoint(waypoint)
	local script = Script()
	script:setVariable("position_x", position_x):setVariable("position_y", position_y)
	script:setVariable("target_x", target_x):setVariable("target_y", target_y)
	script:setVariable("faction_id", env.target:getFactionId())
	return script
end


comms_vf_station.undocked.supply.impulse_supply = CommsNodeWaypointSelect:new({
	select_choice_line = function(self, env)
		local supply_drop_cost = math.ceil(env.target.comms_data.service_cost["supplydrop"])
		return arraySelectRandom({
            string.format(_("Normal (%d reputation)"),supply_drop_cost),
            string.format(_("Regular (%d reputation)"),supply_drop_cost),
            string.format(_("Plain (%d reputation)"),supply_drop_cost),
            string.format(_("Simple (%d reputation)"),supply_drop_cost),
		})
	end,
	with_waypoint = CommsNodeServiceBuyable:new{
		service_name = "supplydrop",
		effect = function(env)
			ready_supply_drop_script(env):run("supply_drop.lua")
		end,
		select_message = function(self,env)
			local n = env.args
			assert(type(env.args) == "number", type(env.args))
			local supply_ship_en_route = {
				string.format(_("We have dispatched a supply ship toward waypoint %d."),n),
				string.format(_("We sent a supply ship to waypoint %d."),n),
				string.format(_("There's a ship headed for %d with your supplies."),n),
				string.format(_("A ship should be arriving soon at waypoint %d with your supplies."),n)
			}
			return(arraySelectRandom(supply_ship_en_route))
		end,
	}
}):add_condition(ccc.undocked):add_condition(function(env)
	return env.target.comms_data.service_available and
	env.target.comms_data.service_cost and
	env.target.comms_data.service_available["supplydrop"] == true and type(env.target.comms_data.service_cost["supplydrop"]) == "number"
end):add_test_setup(function(env)
	env.target.comms_data.service_available.supplydrop = true
	env.target.comms_data.service_cost.supplydrop = 14
end)
comms_vf_station.undocked.supply.impulse_supply.with_waypoint:add_test_setup(function(env)
	env.target.getFactionId = function(self) assert(self); return 1 end
	env.target.comms_data.service_available.supplydrop = true
	env.target.comms_data.service_cost.supplydrop = 14
	env.args = 2
end)

comms_vf_station.undocked.supply.jump_supply = CommsNodeWaypointSelect:new({
	select_choice_line = function(self,env)
		local cost = math.ceil(env.target.comms_data.service_cost["jumpsupplydrop"])
		local jump_drop_cost = {
                string.format(_("Delivered by jump ship (%d reputation)"), cost),
                string.format(_("Jump ship drop (%d reputation)"), cost),
                string.format(_("Deliver with jump ship (%d reputation)"), cost),
                string.format(_("Jump ship supply drop (%d reputation)"), cost),
            }
		return arraySelectRandom(jump_drop_cost)
	end,
	with_waypoint = CommsNodeServiceBuyable:new{
		service_name = "jumpsupplydrop",
		effect = function(env)
			ready_supply_drop_script(env):setVariable("jump_freighter","yes"):run("supply_drop.lua")
		end,
		select_message = function(self,env)
			local n = env.args
			assert(type(env.args) == "number", type(env.args))
			local supply_ship_en_route = {
				string.format(_("We have dispatched a supply ship toward waypoint %d."),n),
				string.format(_("We sent a supply ship to waypoint %d."),n),
				string.format(_("There's a ship headed for %d with your supplies."),n),
				string.format(_("A ship should be arriving soon at waypoint %d with your supplies."),n)
			}
			return(arraySelectRandom(supply_ship_en_route))
		end,
	}
}):add_condition(ccc.undocked):add_condition(function(env)
	return env.target.comms_data.service_available and
	env.target.comms_data.service_cost and
	env.target.comms_data.service_available["jumpsupplydrop"] == true and type(env.target.comms_data.service_cost["jumpsupplydrop"]) == "number"
end):add_condition(function(env)
	return env.target.comms_data.friendlyness > 20
end):add_test_setup(function(env)
	env.target.comms_data.service_available.jumpsupplydrop = true
	env.target.comms_data.service_cost.jumpsupplydrop = 14
end)
comms_vf_station.undocked.supply.jump_supply.with_waypoint:add_test_setup(function(env)
	comms_vf_station.automatic.ensure_comms_data:_apply_effects(env)
	env.target.getFactionId = function(self) assert(self); return 1 end
	env.target.comms_data.service_available.jumpsupplydrop = true
	env.target.comms_data.service_cost.jumpsupplydrop = 14
	env.args = 2
end)


-- not implemented
comms_vf_station.undocked.supply.fling_supply = CommsNode:new({
	choice_line = _("Fling Supply Drop"),
}):add_condition(ccc.undocked):add_condition(ccc.disabled)



--====================================================
-- Enemy
--====================================================

comms_vf_station.enemy.intimidate = CommsNodeServiceAvailable:new({
	service_name = "surrender",
	choice_line = _("intimidate-station", "Surrender to us!"),
	message = _("We are willing to negotiatiate our surrender."),
})
:add_condition(ccc.enemy_faction)
:add_check(function(self, env)
	return env.target:areEnemiesInRange(5000), _("intimidate-station", "We will not surrender while we are not under immediate threat.")
end)
:add_check(function(self, env)
	return env.target:getHull() < env.target:getHullMax(), _("intimidate-station", "We will not surrender while our hull remains undamaged.")
end)
:add_check(function(self, env)
	for __, obj in ipairs(env.target:getObjectsInRange(10000)) do
		if obj ~= env.target and obj:isValid() and env.source:isEnemy(obj) then
			return false, _("intimidate-station", "We will not surrender while your enemies remain close enough to help us.")
		end
	end
	return true
end)
:add_test_setup(function(env)
	env.source.getFactionId = function() return 1 end
	env.target.setFactionId = function() end
end)

comms_vf_station.enemy.intimidate_confirm = CommsNodeServiceBuyable:new({
	service_name = "surrender",
	select_choice_line = function(self, env)
		local cost = self:service_cost(env)
		return string.format(_("intimidate-station", "Surrender now! [Cost: %d Rep.]"), cost)
	end,
	message = _("intimidate-station", "Understood. We surrender."),
	effect = function(env)
		if env.target.comms_data.orig_faction == nil then
			env.target.comms_data.orig_faction = env.target:getFaction()
		end
		env.target:setFaction("Independent")
		if vf_bescheid ~= nil then
			vf_bescheid:sag_bescheid("convertable_station", {
				callsign_ship=env.source:getCallSign(),
				callsign_station=env.target:getCallSign(),
				sector=env.target:getSectorName(),
			})
		end
	end,
})
:add_condition(ccc.enemy_faction)
:add_test_setup(function(env)
	env.target.setFaction = function() end
	env.target.comms_data.service_cost["surrender"] = 270
end)


comms_vf_station.enemy.intimidate:add_choice(comms_vf_station.enemy.intimidate_confirm)

--====================================================
-- Build Tree
--====================================================

comms_vf_station.main = CommsNode:new({
	choice_line = "Main",
})
comms_vf_station.automatic.pipeline:add_choice(comms_vf_station.main)

comms_vf_station.main:add_choice(comms_vf_station.info.main)

-- Information
--comms_vf_station.info.main:add_choice(comms_vf_station.info.station_information)
comms_vf_station.info.main:add_choice(comms_vf_station.info.status)
comms_vf_station.info.main:add_choice(comms_vf_station.info.services)
-- weapons info 
comms_vf_station.info.main:add_choice(comms_vf_station.info.missions)
comms_vf_station.info.main:add_choice(comms_vf_station.info.general)
comms_vf_station.info.main:add_choice(comms_vf_station.info.history)
comms_vf_station.info.main:add_choice(comms_vf_station.info.gossip)


comms_vf_station.info.missions:add_choice(comms_vf_station.docked.dispatch)
comms_vf_station.info.missions:add_choice(comms_vf_station.docked.improvements)

-- Docked
comms_vf_station.main:add_choice(comms_vf_station.docked.repair)
comms_vf_station.main:add_choice(comms_vf_station.docked.refit)
comms_vf_station.main:add_choice(comms_vf_station.docked.enhance)
comms_vf_station.main:add_choice(comms_vf_station.docked.dispatch)			-- also from info
comms_vf_station.main:add_choice(comms_vf_station.docked.faction)
comms_vf_station.main:add_choice(comms_vf_station.docked.improvements)		-- also from info

comms_vf_station.docked.repair:add_choice(comms_vf_station.docked.repair.probes)
comms_vf_station.docked.repair:add_choice(comms_vf_station.docked.repair.hacking)
comms_vf_station.docked.repair:add_choice(comms_vf_station.docked.repair.scanners)
comms_vf_station.docked.repair:add_choice(comms_vf_station.docked.repair.combat)
comms_vf_station.docked.repair:add_choice(comms_vf_station.docked.repair.self_destruct)
comms_vf_station.docked.repair:add_choice(comms_vf_station.docked.repair.tubes)

comms_vf_station.docked.improvements:add_choice(comms_vf_station.docked.improvements.probes)
comms_vf_station.docked.improvements:add_choice(comms_vf_station.docked.improvements.hull)
comms_vf_station.docked.improvements:add_choice(comms_vf_station.docked.improvements.energy)
comms_vf_station.docked.improvements:add_choice(comms_vf_station.docked.improvements.homing)
comms_vf_station.docked.improvements:add_choice(comms_vf_station.docked.improvements.hvli)
comms_vf_station.docked.improvements:add_choice(comms_vf_station.docked.improvements.mine)
comms_vf_station.docked.improvements:add_choice(comms_vf_station.docked.improvements.emp)
comms_vf_station.docked.improvements:add_choice(comms_vf_station.docked.improvements.nuke)

-- Undocked
comms_vf_station.main:add_choice(comms_vf_station.undocked.supply)			-- only undocked

comms_vf_station.undocked.supply:add_choice(comms_vf_station.undocked.supply.impulse_supply)
comms_vf_station.undocked.supply:add_choice(comms_vf_station.undocked.supply.jump_supply)
comms_vf_station.undocked.supply:add_choice(comms_vf_station.undocked.supply.fling_supply)	
comms_vf_station.undocked.supply:add_condition(function(env)
	return comms_vf_station.undocked.supply.impulse_supply:_can_select(env) or
		comms_vf_station.undocked.supply.jump_supply:_can_select(env) or
		comms_vf_station.undocked.supply.fling_supply:_can_select(env)
end)	



-- Enemy
comms_vf_station.main:add_choice(comms_vf_station.enemy.intimidate)

comms_vf_station.main:add_choice_to_all_children(CommsBack, true)
comms_vf_station.entry = comms_vf_station.automatic.pipeline
