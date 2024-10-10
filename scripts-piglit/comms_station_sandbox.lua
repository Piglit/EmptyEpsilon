require "utils.lua"
require "luax.lua"
require "generate_call_sign_scenario_utility.lua"

require "xansta_mods.lua"
init_constants_xansta()

require("serpent.lua")
function table.dump(...)
	print(serpent.block(...))
end

local system_list = {"reactor","beamweapons","missilesystem","maneuver","impulse","warp","jumpdrive","frontshield","rearshield"}

function tableSelectRandom(array)
    local array_item_count = #array
    if array_item_count == 0 then
        return nil
    end
    return array[math.random(1,#array)]    
end

-- for story comms: call this function after adding functions to station.comms_data.comms_functions
function runCommsFunctionsSimple(comms_source, comms_target)
    for _,f in ipairs(comms_target.comms_data.comms_functions) do
        f(comms_source, comms_target)
	end
end
function runCommsFunctions(functions, comms_source, comms_target)
    ret = nil
	oMsg = ""
    for i,f in ipairs(functions) do
        ret = f(comms_source, comms_target, oMsg)
        if ret ~= nil then
			if type(ret) == "string" then
				oMsg = ret
			else
				-- bool: return immediately
				return ret
			end
        end
    end
    return ret
end

-- unused
function onEnterFunction(name, identifier)
	local found = false
	for i=1, #comms_source.callstack do
		local elem_name, elem_identifier = table.unpack(comms_source.callstack[i])
		if found or elem_name == name or elem_identifier == identifier then
			found = true
		end
		if found then
			-- invalidate newer part of the stack
			comms_source.callstack[i] = nil
		end
	end
	table.insert(comms_source.callstack, {name, identifier})
end

-- unused
function back()
	for i=#comms_source.callstack, 1, -1 do
		local name, identifier = table.unpack(comms_source.callstack[i])
        addCommsReply(string.format("Back to %s",name),identifier)
	end
end

-----------------------------
--    Station communication  --
-----------------------------
function commsStation(comms_source, comms_target)
	comms_source.callstack = {}
    if comms_target.comms_data == nil then
        comms_target.comms_data = {}
    end
    mergeTables(comms_target.comms_data, {
        friendlyness = random(0.0, 100.0),
        surrender_hull_threshold = math.random(40,80),
        weapons = {
            Homing = "neutral",
            HVLI = "neutral",
            Mine = "neutral",
            Nuke = "friend",
            EMP = "friend",
        },
        weapon_cost = {
            Homing = math.random(1,4),
            HVLI = math.random(1,3),
            Mine = math.random(2,5),
            Nuke = math.random(12,18),
            EMP = math.random(7,13),
        },
        services = {
            supplydrop = "friend",
            jumpsupplydrop = "friend",
            flingsupplydrop = "friend",
            reinforcements = "friend",
            sensor_boost = "neutral",
            preorder = "friend",
            activatedefensefleet = "friend",
            servicejonque = "neutral",
        },
        service_cost = {
            supplydrop = math.random(80,120),
            jumpsupplydrop = math.random(110,140),
            flingsupplydrop = math.random(140,170),
            activatedefensefleet = 20,
            servicejonque = math.random(100,150),
            probe_launch_repair = math.random(1,4) + math.random(1,5),
            hack_repair = math.random(1,4) + math.random(1,5),
            scan_repair = math.random(1,4) + math.random(1,5),
            combat_maneuver_repair = math.random(1,4) + math.random(1,5),
            self_destruct_repair = math.random(1,4) + math.random(1,5),
            tube_slow_down_repair = math.random(1,4) + math.random(1,5),
            refitDrive = 150,
        },
        reinforcement_cost = {
            ["Blue Hornet"] = math.random(80,120),
            ["Blue Lindworm"] = math.random(80,120),
            ["Blue Adder"] = math.random(125,175),
            ["Phobos Vanguard"] = math.random(200,250),
            ["Phobos Rear-Guard"] = math.random(200,250),
            ["Piranha Vanguard"] = math.random(200,250),
            ["Piranha Rear-Guard"] = math.random(200,250),
            ["Nirvana Vanguard"] = math.random(200,250),
            ["Nirvana Rear-Guard"] = math.random(200,250),
        },
        reinforcement_threshold = {
            ["Blue Hornet"] = 33,
            ["Blue Lindworm"] = 50,
            ["Blue Adder"] = 20,
            ["Phobos Vanguard"] = 66,
            ["Phobos Rear-Guard"] = 66,
            ["Piranha Vanguard"] = 75,
            ["Piranha Rear-Guard"] = 75,
            ["Nirvana Vanguard"] = 70,
            ["Nirvana Rear-Guard"] = 70,
        },
        defense_fleet_chances = {
            {ship = "Yellow Hornet", chance = 95},
            {ship = "Yellow Adder MK4", chance = 90},
            {ship = "Phobos T3", chance = 85},
            {ship = "Yellow Adder MK5", chance = 80},
            {ship = "Nirvana R3", chance = 75},
            {ship = "Yellow Lindworm", chance = 70},
            {ship = "Piranha F12", chance = 65},
        },
        reputation_cost_multipliers = {
            friend = 1.0,
            neutral = 3.0,
        },
        max_weapon_refill_amount = {
            friend = 1.0,
            neutral = 0.5,
        },
        --[[Usage of those comms functions:
        Such a function can add replies and set messages.
        If the function returns true, no further function is called.
        If it returns false, the comms target will hang close comms.
        If it returns nil, the next function will be called.
		If it returns a string, the next function will be called with that string as oMsg.
        --]]

		panic_range = getPanicRange(comms_target)
    })
	-- FIXME: issue - if this is defined in comms data, the functions get deleted when the script gets deleted, but the reference remains.
	-- if it is defined like below, noone can add a function
    comms_target.comms_data.docked_comms_functions = {addStationToDatabase, commsPanic, dockedGreeting, androidDockedStationComms, dockedLightPanic}
    comms_target.comms_data.undocked_comms_functions = {commsPanic, undockedGreeting, androidUndockedStationComms, undockedLightPanic}
    comms_target.comms_data.enemy_comms_functions = {intimidateStationComms}
    comms_data = comms_target.comms_data

    -- enemy stations
    local ret = nil
    if comms_source:isEnemy(comms_target) then
        if #comms_data.enemy_comms_functions == 0 then
            return false
        end
        return runCommsFunctions(comms_data.enemy_comms_functions, comms_source, comms_target)
    end

    -- neutral or friend
    if not comms_source:isDocked(comms_target) then
        return runCommsFunctions(comms_data.undocked_comms_functions, comms_source, comms_target)
    else
        return runCommsFunctions(comms_data.docked_comms_functions, comms_source, comms_target)
    end
    return true
end

function getPanicRange(station)
	local panic_range = 5000
    local temp_type = station:getTypeName()
    local range_divisor = {
        ["Small Station"]    = 2,
        ["Medium Station"]    = 3,
        ["Large Station"]    = 4,
        ["Huge Station"]    = 5,
    }
    if temp_type == nil or range_divisor[temp_type] == nil then
        print("template name nil for:",comms_target:getCallSign(),"defaulting panic range to 5000")
    else
        panic_range = comms_target:getShortRangeRadarRange()/range_divisor[temp_type]    
    end
    if panic_range == nil then
        print("calculating panic range failed. Defaulting to 5000")
        panic_range = 5000
    end
	return panic_range
end

--    docked and undocked communication functions
function commsPanic(comms_source, comms_target)
	local panic_range = comms_target.comms_data.panic_range
    if comms_target:areEnemiesInRange(panic_range) then
        local busy_messages = {
            string.format("[Automated Response]\nWe're sorry, but we cannot take your take your call right now. All personnel are busy at emergency stations due to hostile entities within %.1f units",panic_range/1000),
            "[Automated Response]\nRelay officer temporarily reassigned to damage control team in anticipation of enemy attack. Call back later",
            "[Automated Response]\nGone to designated battle station (shield support team). Try again later",
            string.format("[Automated Response]\nRelay officer reassigned to %s hull breach emergency response team",comms_target:getCallSign()),
        }
        setCommsMessage(tableSelectRandom(busy_messages))
        if isAllowedTo(comms_target.comms_data.services.activatedefensefleet) then
            stationDefenseFleet()
        end
        return true
    end
end

function addStationToDatabase(comms_source, station)
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
    if station:isFriendly(comms_source) then
        local friendly_key = _("scienceDB","Friendly")
        local friendly_db = queryScienceDatabase(stations_key,friendly_key)
        if friendly_db == nil then
            stations_db:addEntry(friendly_key)
            friendly_db = queryScienceDatabase(stations_key,friendly_key)
            friendly_db:setLongDescription(_("scienceDB","Friendly stations share their short range telemetry with your ship on the Relay and Strategic Map consoles. The service costs are lower compared to neutral stations. These are the known friendly stations."))
        end
        station_db = queryScienceDatabase(stations_key,friendly_key,station_key)
        if station_db == nil then
            friendly_db:addEntry(station_key)
            station_db = queryScienceDatabase(stations_key,friendly_key,station_key)
            first_time_entry = true
        end
		local neutral_key = "Neutral"
        local neutral_db = queryScienceDatabase(stations_key,neutral_key)
        if neutral_db ~= nil then
			rm_station_db = queryScienceDatabase(stations_key,neutral_key,station_key)
			if rm_station_db ~= nil then
				rm_station_db:destroy()
			end
		end
    elseif not station:isEnemy(comms_source) then
        local neutral_key = "Neutral"
        local neutral_db = queryScienceDatabase(stations_key,neutral_key)
        if neutral_db == nil then
            stations_db:addEntry(neutral_key)
            neutral_db = queryScienceDatabase(stations_key,neutral_key)
            neutral_db:setLongDescription(_("scienceDB","Neutral stations don't share their short range telemetry with your ship, but they do allow for docking. They will not sell you EMPs or Nukes and service costs will be higher compared to friendly stations. These are the known neutral stations."))
        end
        station_db = queryScienceDatabase(stations_key,neutral_key,station_key)
        if station_db == nil then
            neutral_db:addEntry(station_key)
            station_db = queryScienceDatabase(stations_key,neutral_key,station_key)
            first_time_entry = true
        end
        local friendly_key = _("scienceDB","Friendly")
        local friendly_db = queryScienceDatabase(stations_key,friendly_key)
        if friendly_db ~= nil then
			rm_station_db = queryScienceDatabase(stations_key,friendly_key,station_key)
			if rm_station_db ~= nil then
				rm_station_db:destroy()
			end
		end
	else	-- isEnemy
		local neutral_key = "Neutral"
        local neutral_db = queryScienceDatabase(stations_key,neutral_key)
        if neutral_db ~= nil then
			rm_station_db = queryScienceDatabase(stations_key,neutral_key,station_key)
			if rm_station_db ~= nil then
				rm_station_db:destroy()
			end
		end
        local friendly_key = _("scienceDB","Friendly")
        local friendly_db = queryScienceDatabase(stations_key,friendly_key)
        if friendly_db ~= nil then
			rm_station_db = queryScienceDatabase(stations_key,friendly_key,station_key)
			if rm_station_db ~= nil then
				rm_station_db:destroy()
			end
		end
    end
    if first_time_entry then
        local out = ""
        if station:getDescription() ~= nil then
            out = station:getDescription()
        end
        if station.comms_data ~= nil then
            if station.comms_data.general ~= nil and station.comms_data.general ~= "" then
                out = string.format(_("scienceDB","%s\n\nGeneral Information: %s"),out,station.comms_data.general)
            end
            if station.comms_data.history ~= nil and station.comms_data.history ~= "" then
                out = string.format(_("scienceDB","%s\n\nHistory: %s"),out,station.comms_data.history)
            end
        end
        if out ~= "" then
            station_db:setLongDescription(out)
        end
        local station_type = station:getTypeName()
        local size_value = ""
        local small_station_key = _("scienceDB","Small Station")
        local medium_station_key = _("scienceDB","Medium Station")
        local large_station_key = _("scienceDB","Large Station")
        local huge_station_key = _("scienceDB","Huge Station")
        if station_type == small_station_key then
            size_value = _("scienceDB","Small")
            local small_db = queryScienceDatabase(stations_key,small_station_key)
            if small_db ~= nil then
                station_db:setImage(small_db:getImage())
            end
            station_db:setModelDataName("space_station_4")
        elseif station_type == medium_station_key then
            size_value = _("scienceDB","Medium")
            local medium_db = queryScienceDatabase(stations_key,medium_station_key)
            if medium_db ~= nil then
                station_db:setImage(medium_db:getImage())
            end
            station_db:setModelDataName("space_station_3")
        elseif station_type == large_station_key then
            size_value = _("scienceDB","Large")
            local large_db = queryScienceDatabase(stations_key,large_station_key)
            if large_db ~= nil then
                station_db:setImage(large_db:getImage())
            end
            station_db:setModelDataName("space_station_2")
        elseif station_type == huge_station_key then
            size_value = _("scienceDB","Huge")
            local huge_db = queryScienceDatabase(stations_key,huge_station_key)
            if huge_db ~= nil then
                station_db:setImage(huge_db:getImage())
            end
            station_db:setModelDataName("space_station_1")
        end
        if size_value ~= "" then
            local size_key = _("scienceDB","Size")
            station_db:setKeyValue(size_key,size_value)
        end
    end
    if station_db ~= nil then
        local dock_service = ""
        local service_count = 0
        if station:getSharesEnergyWithDocked() then
            dock_service = _("scienceDB","share energy")
            service_count = service_count + 1
        end
        if station:getRepairDocked() then
            if dock_service == "" then
                dock_service = _("scienceDB","repair hull")
            else
                dock_service = string.format(_("scienceDB","%s, repair hull"),dock_service)
            end
            service_count = service_count + 1
        end
        if station:getRestocksScanProbes() then
            if dock_service == "" then
                dock_service = _("scienceDB","replenish probes")
            else
                dock_service = string.format(_("scienceDB","%s, replenish probes"),dock_service)
            end
            service_count = service_count + 1
        end
        if service_count > 0 then
            local docking_services_key = _("scienceDB","Docking Services")
            if service_count == 1 then
                docking_services_key = _("scienceDB","Docking Service")
            end
            station_db:setKeyValue(docking_services_key,dock_service)
        end
        if station.comms_data ~= nil then
            if station.comms_data.weapon_available ~= nil then
                if station.comms_data.weapon_cost == nil then
                    station.comms_data.weapon_cost = {
                        Homing = math.random(1,4),
                        HVLI = math.random(1,3),
                        Mine = math.random(2,5),
                        Nuke = math.random(12,18),
                        EMP = math.random(7,13),
                    }
                end
                if station.comms_data.reputation_cost_multipliers == nil then
                    station.comms_data.reputation_cost_multipliers = {
                        friend = 1.0,
                        neutral = 3.0,
                    }
                end
                local station_missiles = {
                    {name = "Homing",    key = _("scienceDB","Restock Homing")},
                    {name = "HVLI",        key = _("scienceDB","Restock HVLI")},
                    {name = "Mine",        key = _("scienceDB","Restock Mine")},
                    {name = "Nuke",        key = _("scienceDB","Restock Nuke")},
                    {name = "EMP",        key = _("scienceDB","Restock EMP")},
                }
                for i,sm in ipairs(station_missiles) do
                    if station.comms_data.weapon_available[sm.name] then
                        if station.comms_data.weapon_cost[sm.name] ~= nil then
                            local val = string.format(_("scienceDB","%i reputation each"),math.ceil(station.comms_data.weapon_cost[sm.name] * station.comms_data.reputation_cost_multipliers["friend"]))
                            station_db:setKeyValue(sm.key,val)
                        end
                    end
                end
            end
            local secondary_system_repair = {
                {name = "scan_repair",                key = _("scienceDB","Repair scanners")},
                {name = "combat_maneuver_repair",    key = _("scienceDB","Repair combat maneuver")},
                {name = "hack_repair",                key = _("scienceDB","Repair hacking")},
                {name = "probe_launch_repair",        key = _("scienceDB","Repair probe launch")},
                {name = "tube_slow_down_repair",    key = _("scienceDB","Repair slow tube")},
                {name = "self_destruct_repair",        key = _("scienceDB","Repair self destruct")},
            }
            for i,ssr in ipairs(secondary_system_repair) do
                if station.comms_data[ssr.name] then
                    if station.comms_data.service_cost[ssr.name] ~= nil then
                        local val = string.format(_("scienceDB","%s reputation"),station.comms_data.service_cost[ssr.name])
                        station_db:setKeyValue(ssr.key,val)
                    end
                end
            end
            if station.comms_data.service_available ~= nil then
                local general_service = {
                    {name = "supplydrop",                key = _("scienceDB","Drop supplies")},
                    {name = "jumpsupplydrop",            key = _("scienceDB","Jump ship drops supplies")},
                    {name = "flingsupplydrop",            key = _("scienceDB","Flinger drops supplies")},
                    {name = "reinforcements",            key = _("scienceDB","Standard reinforcements")},
                    {name = "hornet_reinforcements",    key = _("scienceDB","Hornet reinforcements")},
                    {name = "phobos_reinforcements",    key = _("scienceDB","Phobos reinforcements")},
                    {name = "stalker_reinforcements",    key = _("scienceDB","Stalker reinforcements")},
                    {name = "amk8_reinforcements",        key = _("scienceDB","Adder8 reinforcements")},
                    {name = "activatedefensefleet",        key = _("scienceDB","Activate defense fleet")},
                    {name = "servicejonque",            key = _("scienceDB","Provide service jonque")},
                    {name = "shield_overcharge",        key = _("scienceDB","Overcharge shield")},
                    {name = "jump_overcharge",            key = _("scienceDB","Overcharge jump drive")},
                }
                for i,gs in ipairs(general_service) do
                    if station.comms_data.service_available[gs.name] then
                        local val = "available"
                        if station.comms_data.service_cost[gs.name] ~= nil then
                            if station.comms_data.service_cost[gs.name] > 0 then
                                val = string.format(_("scienceDB","%s reputation"),station.comms_data.service_cost[gs.name])
                            end
                        end
                        station_db:setKeyValue(gs.key,val)
                    end
                end
            end
        end
    end
end

function stationStatusReport(calling_function)
    local status_prompts = {
        "Report status",
        "Report station status",
        string.format("Report station %s status",comms_target:getCallSign()),
        "What is your status?",
        string.format("What is the condition of station %s?",comms_target:getCallSign()),
    }
    addCommsReply(tableSelectRandom(status_prompts), function()
        msg = string.format(_("situationReport-comms","Hull:%s    "),math.floor(comms_target:getHull() / comms_target:getHullMax() * 100))
        local shields = comms_target:getShieldCount()
        if shields == 1 then
            msg = string.format(_("situationReport-comms","%s  Shield:%s"),msg,math.floor(comms_target:getShieldLevel(0) / comms_target:getShieldMax(0) * 100))
        else
            for n=0,shields-1 do
                msg = string.format(_("situationReport-comms","%s  Shield %s:%s"),msg,n,math.floor(comms_target:getShieldLevel(n) / comms_target:getShieldMax(n) * 100))
            end
        end
        local improvements = {}
        msg, improvements = catalogImprovements(msg)
        system_list_desc = {
            ["reactor"] =         _("situationReport-comms","reactor"),
            ["beamweapons"] =    _("situationReport-comms","beam weapons"),
            ["missilesystem"] =    _("situationReport-comms","missile system"),
            ["maneuver"] =        _("situationReport-comms","maneuver"),
            ["impulse"] =        _("situationReport-comms","impulse"),
            ["warp"] =            _("situationReport-comms","warp drive"),
            ["jumpdrive"] =        _("situationReport-comms","jump drive"),
            ["frontshield"] =    _("situationReport-comms","front shield"),
            ["rearshield"] =    _("situationReport-comms","rear shield"),
        }
        local major_repairs = _("situationReport-comms","Repair these major systems:")
        for i,system in ipairs(system_list) do
            if comms_target.comms_data.system_repair[system].avail then
                if major_repairs == _("situationReport-comms","Repair these major systems:") then
                    major_repairs = string.format("%s %s",major_repairs,system_list_desc[system])
                else
                    major_repairs = string.format("%s, %s",major_repairs,system_list_desc[system])
                end
            end
        end
        if major_repairs ~= _("situationReport-comms","Repair these major systems:") then
            msg = string.format("%s\n%s.",msg,major_repairs)
        end
        local secondary_system_repair_desc = {
            {name = "scan_repair",                desc = _("situationReport-comms","scanners")},
            {name = "combat_maneuver_repair",    desc = _("situationReport-comms","combat maneuver")},
            {name = "hack_repair",                desc = _("situationReport-comms","hacking")},
            {name = "probe_launch_repair",        desc = _("situationReport-comms","probe launch")},
            {name = "tube_slow_down_repair",    desc = _("situationReport-comms","slow tube")},
            {name = "self_destruct_repair",        desc = _("situationReport-comms","self destruct")},
        }
        local minor_repairs = _("situationReport-comms","Repair these minor systems:")
        for i,system in ipairs(secondary_system_repair_desc) do
            if comms_target.comms_data[system.name] then
                if minor_repairs == _("situationReport-comms","Repair these minor systems:") then
                    minor_repairs = string.format("%s %s",minor_repairs,system.desc)
                else
                    minor_repairs = string.format("%s, %s",minor_repairs,system.desc)
                end
            end
        end
        if minor_repairs ~= _("situationReport-comms","Repair these minor systems:") then
            msg = string.format("%s\n%s.",msg,minor_repairs)
        end
        local overcharge_service = ""
        if comms_target.comms_data.jump_overcharge then
            overcharge_service = "jump drive"
        end
        if comms_target.comms_data.shield_overcharge then
            if overcharge_service == "" then
                overcharge_service = "shields"
            else
                overcharge_service = "jump drive and shields"
            end
        end
        if overcharge_service ~= "" then
            msg = string.format("%s\nOvercharge service available for %s",msg,overcharge_service)
        end
        setCommsMessage(msg)
        if #improvements > 0 and (comms_target.comms_data.friendlyness > 33 or comms_source:isDocked(comms_target)) then
            improveStationService(improvements)
        end
        addCommsReply(string.format("Back to %s",calling_function.name),calling_function.identifier)
        addCommsReply(_("Back to station communication"), commsStation)
    end)
end

function populateDefenseFleet(station)
	station.comms_data.idle_defense_fleet = {["DF1"] =  "MT52 Hornet"}
	local station_type = comms_target:getTypeName()
	local size_matters = {
		["Small Station"] = -5,
		["Medium Station"] = 0,
		["Large Station"] = 5,
		["Huge Station"] = 10,
	}
	local adjustment = size_matters[station_type]    --problem child - adjustment nil
	if adjustment == nil then
		adjustment = 0
	end

	for i,data in ipairs(station.comms_data.defense_fleet_chances) do
		local ship = data.ship
		local chance = data.chance + adjustment
		if random(1,100) < chance then
			comms_target.comms_data.idle_defense_fleet["DF"..tostring(i+1)] = ship
		else
			break
		end
	end
end

function stationDefenseFleet(calling_function)
	-- the defense fleet will retreat, when there are no enemies for 5 Minutes;
	-- they can be launched again, if they were not destroyed
    if comms_target.comms_data.idle_defense_fleet == nil then
		populateDefenseFleet(comms_target)
    end
    local defense_fleet_count = 0
    for name, template in pairs(comms_target.comms_data.idle_defense_fleet) do
        defense_fleet_count = defense_fleet_count + 1
    end
    if defense_fleet_count > 0 then
        local fleet_prompts = {
            string.format("Activate station defense fleet (%s rep)",getServiceCost("activatedefensefleet")),
            string.format("Launch station defense fleet (%s rep)",getServiceCost("activatedefensefleet")),
            string.format("Send out station defense fleet (%s rep)",getServiceCost("activatedefensefleet")),
            string.format("Launch %s defenders (%s rep)",comms_target:getCallSign(),getServiceCost("activatedefensefleet")),
            string.format("Enable %s defenders (%s rep)",comms_target:getCallSign(),getServiceCost("activatedefensefleet")),
        }
        addCommsReply(tableSelectRandom(fleet_prompts),function()
            if comms_source:takeReputationPoints(getServiceCost("activatedefensefleet")) then
                for name, template in pairs(comms_target.comms_data.idle_defense_fleet) do
                    local script = Script()
                    local position_x, position_y = comms_target:getPosition()
                    local station_name = comms_target:getCallSign()
                    script:setVariable("position_x", position_x):setVariable("position_y", position_y)
                    script:setVariable("station_name",station_name)
                    script:setVariable("name",name)
                    script:setVariable("template",template)
                    script:setVariable("faction_id",comms_source:getFactionId())
                    script:run("border_defend_station.lua")
                    comms_target.comms_data.idle_defense_fleet[name] = nil
                end
                local launched_responses = {
                    "Defense fleet activated",
                    "Defenders launched",
                    string.format("%s defense fleet activated",comms_target:getCallSign()),
                    string.format("Station %s defenders engaged",comms_target:getCallSign()),
                    string.format("%s defenders enabled",comms_target:getCallSign()),
                }
                setCommsMessage(tableSelectRandom(launched_responses))
            else
                local insufficient_rep_responses = {
                    "Insufficient reputation",
                    "Not enough reputation",
                    "You need more reputation",
                    string.format("You need more than %i reputation",math.floor(comms_source:getReputationPoints())),
                    "You don't have enough reputation",
                }
                setCommsMessage(tableSelectRandom(insufficient_rep_responses))
            end
            if calling_function ~= nil then
                addCommsReply(string.format("Back to %s",calling_function.name),calling_function.identifier)
                addCommsReply(_("Back to station communication"), commsStation)
            else
                addCommsReply("Back", commsStation)
            end
        end)
    end
end

--    undocked communication functions
function undockedGreeting(comms_source, comms_target, oMsg)
    local station_greeting_prompt = {
        {thresh = 90,    text = string.format(_("station-comms","This is %s's communications officer. Go ahead, %s. We're listening."),comms_target:getCallSign(),comms_source:getCallSign())},
        {thresh = 80,    text = string.format(_("station-comms","%s to %s, receiving your communication. Proceed with your message."),comms_target:getCallSign(),comms_source:getCallSign())},
        {thresh = 70,    text = string.format(_("station-comms","Confirmed, %s. You're connected to %s. Go ahead."),comms_source:getCallSign(),comms_target:getCallSign())},
        {thresh = 60,    text = string.format(_("station-comms","This is the %s communications officer. Go ahead, %s."),comms_target:getCallSign(),comms_source:getCallSign())},
        {thresh = 50,    text = string.format(_("station-comms","%s acknowledges %s's communication. Pray, don't keep us in suspense any longer."),comms_target:getCallSign(),comms_source:getCallSign())},
        {thresh = 40,    text = string.format(_("station-comms","%s, it is positively thrilling to be the recipient of your undoubtably important message. Please enlighten us."),comms_source:getCallSign())},
        {thresh = 30,    text = string.format(_("station-comms","Acknowledged, %s. Try not to waste our time. What do you want?"),comms_source:getCallSign())},
        {thresh = 20,    text = string.format(_("station-comms","What is it now, %s? Make it quick; we're not here for small talk."),comms_source:getCallSign())},
        {thresh = 10,    text = string.format(_("station-comms","%s reluctantly acknowledges your communication. Make it snappy, %s."),comms_target:getCallSign(),comms_source:getCallSign())},
    }
    for i,prompt in ipairs(station_greeting_prompt) do
        if comms_target.comms_data.friendlyness > prompt.thresh then
            oMsg = string.format("%s Communications Portal\n%s",comms_target:getCallSign(),prompt.text)
            break
        else
			--friendlyness <= 10
            oMsg = _("station-comms","Well?")
        end
    end
    setCommsMessage(oMsg)
	return oMsg
end

function undockedLightPanic(comms_source, comms_target, oMsg)
    local interactive = false
    local no_relay_panic_responses = {
        "No communication officers available due to station emergency.",
        "Relay officers unavailable during station emergency.",
        "Relay officers reassigned for station emergency.",
        "Station emergency precludes response from relay officer.",
    }
	local panic_range = comms_target.comms_data.panic_range
    if comms_target:areEnemiesInRange(panic_range*1.5) then
        if comms_target.comms_data.friendlyness > 20 then
            oMsg = string.format(_("station-comms","%s\n%s"),oMsg,tableSelectRandom(no_relay_panic_responses))
            setCommsMessage(oMsg)
        end
    elseif comms_target:areEnemiesInRange(panic_range*2) then
        if comms_target.comms_data.friendlyness > 75 then
            local quick_relay_responses = {
                "Please be quick. Sensors detect enemies.",
                "I have to go soon since there are enemies nearby.",
                "Talk fast. Enemies approach.",
                "Enemies are coming so talk fast.",
            }
            oMsg = string.format(_("station-comms","%s\n%s"),oMsg,tableSelectRandom(quick_relay_responses))
            setCommsMessage(oMsg)
            interactive = true
        else
            if comms_target.comms_data.friendlyness > 40 then
                oMsg = string.format(_("station-comms","%s\n%s"),oMsg,tableSelectRandom(no_relay_panic_responses))
                setCommsMessage(oMsg)
            end
        end
    elseif comms_target:areEnemiesInRange(panic_range*2.5) then
        if comms_target.comms_data.friendlyness > 33 then
            if comms_target.comms_data.friendlyness > 75 then
                local distracted_units_responses = {
                    string.format("Please forgive us if we seem distracted. Our sensors detect enemies within %i units",math.floor(panic_range*2.5/1000)),
                    string.format("Enemies at %i units. Things might get busy soon. Business?",math.floor(panic_range*2.5/1000)),
                    string.format("A busy day here at %s: Enemies are %s units away and my boss is reviewing emergency procedures. I'm a bit distracted.",comms_target:getCallSign(),math.floor(panic_range*2.5/1000)),
                    string.format("If I seem distracted, it's only because of the enemies showing up at %i units.",math.floor(panic_range*2.5/1000)),
                }
                oMsg = string.format(_("station-comms","%s\n%s"),oMsg,tableSelectRandom(distracted_units_responses))
                setCommsMessage(oMsg)
            elseif comms_target.comms_data.friendlyness > 50 then
                local distracted_responses = {
                    "Please forgive us if we seem distracted. Our sensors detect enemies nearby.",
                    string.format("Enemies are close to %s. We might get busy. Business?",comms_target:getCallSign()),
                    "We're quite busy preparing for enemies: evaluating cross training, checking emergency procedures, etc. I'm a little distracted.",
                    string.format("%s is likely going to be attacked soon. Everyone is running around getting ready, distracting me.",comms_target:getCallSign()),
                }
                oMsg = string.format(_("station-comms","%s\n%s"),oMsg,tableSelectRandom(distracted_responses))
                setCommsMessage(oMsg)
            end
            interactive = true
        end
    else
        if comms_target.comms_data.friendlyness > 33 then
            interactive = true
        end    
    end

--	oMsg = string.format("(DEBUG: friendlyness: %f)\n%s", comms_target.comms_data.friendlyness, oMsg) -- TODO remove (debug)
--	table.dump(comms_target.comms_data)-- TODO remove (debug)
    setCommsMessage(oMsg)
	if interactive then
		addCommsReply("Interact with station relay officer on duty",interactiveUndockedStationCommsMeat)
	end
end

function androidUndockedStationComms()
	print("in androidUndockedStationComms")
	addCommsReply(_("station-comms","Automated station communication"),androidUndockedStationCommsMeat)
end

function androidUndockedStationCommsMeat()
	print("in androidUndockedStationCommsMeat")
    setCommsMessage(_("station-comms","Select:"))
    stationStatusReport({identifier=androidUndockedStationCommsMeat,name="automated station communication"})
    if isAllowedTo(comms_target.comms_data.services.activatedefensefleet) then
        stationDefenseFleet({identifier=androidUndockedStationCommsMeat,name="automated station communication"})
    end
    if isAllowedTo(comms_target.comms_data.services.reinforcements) then
        requestReinforcements({identifier=androidUndockedStationCommsMeat,name="automated station communication"})
    end
    addCommsReply(_("Back"), commsStation)    --problem child - no setCommsMessage?
end

function interactiveUndockedStationCommsMeat()
    local help_prompts = {
        "What can I do for you?",
        "How may I help?",
        "What do you need or want?",
        string.format("Go ahead, %s",comms_source:getCallSign()),
        string.format("How can %s serve you today?",comms_target:getCallSign()),
    }
    local the_prompt = tableSelectRandom(help_prompts)
    if the_prompt ~= nil then
        setCommsMessage(the_prompt)
    else
        setCommsMessage("What can I do for you?")
    end
    stationStatusReport({identifier=interactiveUndockedStationCommsMeat,name="interactive relay officer"})
    if isAllowedTo(comms_target.comms_data.services.activatedefensefleet) then
        stationDefenseFleet({identifier=interactiveUndockedStationCommsMeat,name="interactive relay officer"})
    end
    requestSupplyDrop({identifier=interactiveUndockedStationCommsMeat,name="interactive relay officer"})
    if isAllowedTo(comms_target.comms_data.services.reinforcements) then
        requestReinforcements({identifier=interactiveUndockedStationCommsMeat,name="interactive relay officer"})
    end
--[[RM    if comms_target.comms_data.service_available ~= nil then
        if comms_target.comms_data.service_available.servicejonque ~= nil and comms_target.comms_data.service_available.servicejonque then
            requestJonque()
        end
    end
	if comms_target:isFriendly(comms_source) and comms_target.comms_data.friendlyness > 33 then
		requestExpediteDock({identifier=interactiveUndockedStationCommsMeat,name="interactive relay officer"})
	elseif not comms_target:isEnemy(comms_source) and comms_target.comms_data.friendlyness > 66 then
		requestExpediteDock({identifier=interactiveUndockedStationCommsMeat,name="interactive relay officer"})
	end
    --]]
    if comms_target.comms_data.friendlyness > 50 then
        commercialOptions({identifier=interactiveUndockedStationCommsMeat,name="interactive relay officer"})
    end
    addCommsReply("Back",commsStation)
end

function catalogImprovements(msg)
    local improvements = {}
    if msg == nil then
        msg = ""
    end
    if comms_target:getRestocksScanProbes() then
        msg = string.format(_("situationReport-comms","%s\nReplenish scan probes: nominal."),msg)
    else
        if comms_target.probe_fail_reason == nil then
            local reason_list = {
                _("situationReport-comms", "Cannot replenish scan probes due to fabrication unit failure."),
                _("situationReport-comms", "Parts shortage prevents scan probe replenishment."),
                _("situationReport-comms", "Station management has curtailed scan probe replenishment for cost cutting reasons."),
            }
            comms_target.probe_fail_reason = reason_list[math.random(1,#reason_list)]
        end
        msg = string.format("%s\n%s",msg,comms_target.probe_fail_reason)
        table.insert(improvements,"restock_probes")
    end
    if comms_target:getRepairDocked() then
        msg = string.format(_("situationReport-comms","%s\nRepair ship hull: nominal."),msg)
    else
        if comms_target.repair_fail_reason == nil then
            reason_list = {
                _("situationReport-comms", "We're out of the necessary materials and supplies for hull repair."),
                _("situationReport-comms", "Hull repair automation unavailable while it is undergoing maintenance."),
                _("situationReport-comms", "All hull repair technicians quarantined to quarters due to illness."),
            }
            comms_target.repair_fail_reason = reason_list[math.random(1,#reason_list)]
        end
        msg = string.format("%s\n%s",msg,comms_target.repair_fail_reason)
        table.insert(improvements,"hull")
    end
    if comms_target:getSharesEnergyWithDocked() then
        msg = string.format(_("situationReport-comms","%s\nRecharge ship energy stores: nominal."),msg)
    else
        if comms_target.energy_fail_reason == nil then
            reason_list = {
                _("situationReport-comms", "A recent reactor failure has put us on auxiliary power, so we cannot recharge ships."),
                _("situationReport-comms", "A damaged power coupling makes it too dangerous to recharge ships."),
                _("situationReport-comms", "An asteroid strike damaged our solar cells and we are short on power, so we can't recharge ships right now."),
            }
            comms_target.energy_fail_reason = reason_list[math.random(1,#reason_list)]
        end
        msg = string.format("%s\n%s",msg,comms_target.energy_fail_reason)
        table.insert(improvements,"energy")
    end
    local provides_some_missiles = false
    local missile_provision_msg = _("situationReport-comms","Ordnance available:")
    local missile_types_desc = {
        {name = "Nuke",        desc = _("situationReport-comms","nukes")},
        {name = "EMP",        desc = _("situationReport-comms","EMPs")},
        {name = "Homing",    desc = _("situationReport-comms","homings")},
        {name = "Mine",        desc = _("situationReport-comms","mines")},
        {name = "HVLI",        desc = _("situationReport-comms","HVLIs")},
    }
    for i,m_type in ipairs(missile_types_desc) do
        if comms_target.comms_data.weapon_available == nil then
            print("weapon available for station",comms_target:getCallSign(),"is nil")
        else
            if comms_target.comms_data.weapon_available[m_type.name] then    --problem child weapon_available is nil
                if missile_provision_msg == _("situationReport-comms","Ordnance available:") then
                    missile_provision_msg = string.format(_("situationReport-comms","%s %s@%i rep"),missile_provision_msg,m_type.desc,getWeaponCost(m_type.name))
                else
                    missile_provision_msg = string.format(_("situationReport-comms","%s, %s@%i rep"),missile_provision_msg,m_type.desc,getWeaponCost(m_type.name))
                end
            else
                table.insert(improvements,m_type.name)
            end
        end
    end
    if missile_provision_msg == _("situationReport-comms","Ordnance available:") then
        msg = string.format(_("situationReport-comms","%s\nNo ordnance available."),msg)
    else
        msg = string.format("%s\n%s.",msg,missile_provision_msg)
    end
    return msg,improvements    
end
function improveStationService(improvements)
	-- assume setRepairMissions was called when creating the stations
    addCommsReply(_("situationReport-comms","Improve station services"),function()
        local improve_what_service_prompts = {
            "What station service would you like to improve?",
            "Which of these station services would you like to improve?",
            "You could improve any of these station services:",
            "Certain station services could use improvement. Which one are you interested in?",
            string.format("Which %s service can %s help improve?",comms_target:getCallSign(),comms_source:getCallSign()),
        }
        if #improvements == 1 then
            improve_what_service_prompts = {
                "Would you like to improve this service?",
                "This service could use improvement:",
                string.format("%s can help %s by improving this service:",comms_source:getCallSign(),comms_target:getCallSign()),
                "Can you help by improving this service?",
            }
        end
        setCommsMessage(tableSelectRandom(improve_what_service_prompts))
        local improvement_prompt = {
            ["restock_probes"] = {
                "Restocking of docked ship's scan probes",
                "Replenishing docked ship's scan probes",
                "Resupplying scan probes of docked ship",
            },
            ["hull"] = {
                "Repairing of docked ship's hull",
                "Repairing hull of docked ship",
                "Fixing docked ship's hull",
            },
            ["energy"] = {
                "Charging of docked ship's energy reserves",
                "Charge batteries of docked ship",
                "Restore energy reserves on docked ship",
            },
            ["Nuke"] = {
                "Replenishment of nuclear ordnance on docked ship",
                "Replenish docked ship's nukes",
                "Restock nukes of docked ship",
                "Resupply nukes on docked ship",
            },
            ["EMP"] = {
                "Replenishment of EMP missiles on docked ship",
                "Replenish docked ship's EMPs",
                "Provide replacement Electro-Magnetic Pulse missiles",
                "Restock EMPs on docked ship",
            },
            ["Homing"] = {
                "Replenishment of homing missiles",
                "Restock homing missiles of docked ship",
                "Resupply homing missiles for docked ship",
                "Provide homing missiles to docked ship",
            },
            ["HVLI"] = {
                "Replenishment of High Velocity Lead Impactors",
                "Restock HVLI missiles for docked ship",
                "Resupply High Velocity Lead Impactors on docked ship",
                "Provide HVLIs for docked ship",
            },
            ["Mine"] = {
                "Replenishment of mines",
                "Replace mines on docked ship",
                "Restock mines on docked ship",
                "Resupply mines to docked ship",
            },
        }
        for i,improvement in ipairs(improvements) do
            if improvement_prompt[improvement] == nil then
                print("Unable to show improvements. Improvement value:",improvement)
            else
                addCommsReply(tableSelectRandom(improvement_prompt[improvement]),function()    
                    local needed_good = comms_target.mission_goods[improvement]
                    setCommsMessage(string.format(_("situationReport-comms","%s could be improved with %s. You may be able to get %s from stations or transports."),tableSelectRandom(improvement_prompt[improvement]),needed_good,needed_good))
                    if comms_source.goods ~= nil then
                        if comms_source.goods[needed_good] ~= nil and comms_source.goods[needed_good] > 0 and comms_source:isDocked(comms_target) then
                            addCommsReply(string.format(_("situationReport-comms","Provide %s to station %s"),needed_good,comms_target:getCallSign()),function()
                                if comms_source:isDocked(comms_target) then
                                    comms_source.goods[needed_good] = comms_source.goods[needed_good] - 1
                                    comms_source.cargo = comms_source.cargo + 1
                                    local improvement_msg = _("situationReport-comms","There was a problem with the improvement process")
                                    local friendliness_bonus_lo = 3
                                    local friendliness_bonus_hi = 9
                                    if improvement == "energy" then
                                        if comms_source.instant_energy == nil then	-- TODO make it work!
                                            comms_source.instant_energy = {}
                                        end
                                        table.insert(comms_source.instant_energy,comms_target)
                                        comms_target:setSharesEnergyWithDocked(true)
                                        improvement_msg = _("situationReport-comms","We can recharge again! Come back any time to have your batteries recharged.")
                                        comms_target.comms_data.friendlyness = math.min(comms_target.comms_data.friendlyness + random(friendliness_bonus_lo,friendliness_bonus_hi),100)
                                    elseif improvement == "hull" then
                                        if comms_source.instant_hull == nil then
                                            comms_source.instant_hull = {}
                                        end
                                        table.insert(comms_source.instant_hull,comms_target)
                                        comms_target:setRepairDocked(true)
                                        improvement_msg = _("situationReport-comms","We can repair hulls again! Come back any time to have your hull repaired.")
                                        comms_target.comms_data.friendlyness = math.min(comms_target.comms_data.friendlyness + random(friendliness_bonus_lo,friendliness_bonus_hi),100)
                                    elseif improvement == "restock_probes" then
                                        if comms_source.instant_probes == nil then
                                            comms_source.instant_probes = {}
                                        end
                                        table.insert(comms_source.instant_probes,comms_target)
                                        comms_target:setRestocksScanProbes(true)
                                        improvement_msg = _("situationReport-comms","We can restock scan probes again! Come back any time to have your scan probes restocked.")
                                        comms_target.comms_data.friendlyness = math.min(comms_target.comms_data.friendlyness + random(friendliness_bonus_lo,friendliness_bonus_hi),100)
                                    elseif improvement == "Nuke" then
                                        if comms_source.nuke_discount == nil then
                                            comms_source.nuke_discount = {}
                                        end
                                        table.insert(comms_source.nuke_discount,comms_target)
                                        comms_target.comms_data.weapon_available.Nuke = true
                                        comms_target.comms_data.weapons["Nuke"] = "neutral"
                                        comms_target.comms_data.max_weapon_refill_amount.neutral = 1
                                        improvement_msg = _("situationReport-comms","We can replenish nukes again! Come back any time to have your supply of nukes replenished.")
                                        comms_target.comms_data.friendlyness = math.min(comms_target.comms_data.friendlyness + random(friendliness_bonus_lo,friendliness_bonus_hi),100)
                                    elseif improvement == "EMP" then
                                        if comms_source.emp_discount == nil then
                                            comms_source.emp_discount = {}
                                        end
                                        table.insert(comms_source.emp_discount,comms_target)
                                        comms_target.comms_data.weapon_available.EMP = true
                                        comms_target.comms_data.weapons["EMP"] = "neutral"
                                        comms_target.comms_data.max_weapon_refill_amount.neutral = 1
                                        improvement_msg = _("situationReport-comms","We can replenish EMPs again! Come back any time to have your supply of EMPs replenished.")
                                        comms_target.comms_data.friendlyness = math.min(comms_target.comms_data.friendlyness + random(friendliness_bonus_lo,friendliness_bonus_hi),100)
                                    elseif improvement == "Homing" then
                                        if comms_source.homing_discount == nil then
                                            comms_source.homing_discount = {}
                                        end
                                        table.insert(comms_source.homing_discount,comms_target)
                                        comms_target.comms_data.weapon_available.Homing = true
                                        comms_target.comms_data.max_weapon_refill_amount.neutral = 1
                                        improvement_msg = _("situationReport-comms","We can replenish homing missiles again! Come back any time to have your supply of homing missiles replenished.")
                                        comms_target.comms_data.friendlyness = math.min(comms_target.comms_data.friendlyness + random(friendliness_bonus_lo,friendliness_bonus_hi),100)
                                    elseif improvement == "Mine" then
                                        if comms_source.mine_discount == nil then
                                            comms_source.mine_discount = {}
                                        end
                                        table.insert(comms_source.mine_discount,comms_target)
                                        comms_target.comms_data.weapon_available.Mine = true
                                        comms_target.comms_data.weapons["Mine"] = "neutral"
                                        comms_target.comms_data.max_weapon_refill_amount.neutral = 1
                                        improvement_msg = _("situationReport-comms","We can replenish mines again! Come back any time to have your supply of mines replenished.")
                                        comms_target.comms_data.friendlyness = math.min(comms_target.comms_data.friendlyness + random(friendliness_bonus_lo,friendliness_bonus_hi),100)
                                    elseif improvement == "HVLI" then
                                        if comms_source.hvli_discount == nil then
                                            comms_source.hvli_discount = {}
                                        end
                                        table.insert(comms_source.hvli_discount,comms_target)
                                        comms_target.comms_data.weapon_available.HVLI = true
                                        comms_target.comms_data.max_weapon_refill_amount.neutral = 1
                                        improvement_msg = _("situationReport-comms","We can replenish HVLIs again! Come back any time to have your supply of high velocity lead impactors replenished.")
                                        comms_target.comms_data.friendlyness = math.min(comms_target.comms_data.friendlyness + random(friendliness_bonus_lo,friendliness_bonus_hi),100)
                                    end
                                    setCommsMessage(improvement_msg)
                                else
                                    setCommsMessage(_("situationReport-comms","Can't do that when you're not docked"))
                                end
                                addCommsReply(_("Back"), commsStation)
                            end)
                        end
                    end
                    addCommsReply(_("Back"), commsStation)
                end)
            end
        end
        addCommsReply(_("Back"), commsStation)
    end)
end

function requestReinforcements(calling_function)
    local send_reinforcements_prompt = {
        "Send reinforcements",
        "Request friendly warship",
        "Send military help",
        "Get a ship to help us",
    }
    addCommsReply(tableSelectRandom(send_reinforcements_prompt),function()
        local reinforcement_type = {
            "What kind of reinforcement ship?",
            "What kind of ship should we send?",
            "Specify ship type",
            "Identify desired type of ship",
        }
        setCommsMessage(tableSelectRandom(reinforcement_type))
        if comms_target.comms_data.reinforcement_cost == nil then
            print("no reinforcement cost!")
        end
        if comms_target.comms_data.service_available == nil then
            comms_target.comms_data.service_available = {}
        end
        local reinforcement_info = {}
        for template, cost in pairs(comms_target.comms_data.reinforcement_cost) do
            comms_target.comms_data.service_available[template] = random(1,100) < 72
            table.insert(reinforcement_info, {
                desc = _("stationAssist-comms",template),
                template = template,
                threshold = comms_target.comms_data.reinforcement_threshold[template],
                cost = math.ceil(comms_target.comms_data.reinforcement_cost[template]),
                avail = comms_target.comms_data.service_available[template]
            })
        end
        local avail_count = 0
        for i, info in ipairs(reinforcement_info) do
            if info.avail and comms_target.comms_data.friendlyness > info.threshold then
                avail_count = avail_count + 1
                addCommsReply(string.format(_("stationAssist-comms","%s (%d reputation)"),info.desc,info.cost), function()
                    if comms_source:getWaypointCount() < 1 then
                        local set_reinforcement_waypoint = {
                            "You need to set a waypoint before you can request reinforcements.",
                            "Set a waypoint so that we can direct your reinforcements.",
                            "Reinforcements require a waypoint as a destination.",
                            "Before requesting reinforcements, you need to set a waypoint.",
                        }
                        setCommsMessage(tableSelectRandom(set_reinforcement_waypoint))
                    else
                        local direct_to_what_waypoint = {
                            "To which waypoint should we dispatch the reinforcements?",
                            "Where should we send the reinforcements?",
                            "Specify reinforcement rendezvous waypoint",
                            "Where should the reinforcements go?"
                        }
                        setCommsMessage(tableSelectRandom(direct_to_what_waypoint))
                        for n = 1, comms_source:getWaypointCount() do
                            addCommsReply(string.format(_("stationAssist-comms", "Waypoint %d"), n),function()
                                if comms_source:takeReputationPoints(info.cost) then
                                    local ship = CpuShip():setFactionId(comms_target:getFactionId()):setPosition(comms_target:getPosition()):setTemplate(info.template):setScanned(true):orderDefendLocation(comms_source:getWaypoint(n))
                                    suffix_index = math.random(11,77)
                                    ship:setCallSign(generateCallSign(nil,comms_target:getFaction()))
                                    local sent_reinforcements = {
                                        string.format("We have dispatched %s to assist at waypoint %s",ship:getCallSign(),n),
                                        string.format("%s is heading for waypoint %s",ship:getCallSign(),n),
                                        string.format("%s has been sent to waypoint %s",ship:getCallSign(),n),
                                        string.format("We ordered %s to help at waypoint %s",ship:getCallSign(),n),
                                    }
                                    setCommsMessage(tableSelectRandom(sent_reinforcements))
                                else
                                    local insufficient_rep_responses = {
                                        "Insufficient reputation",
                                        "Not enough reputation",
                                        "You need more reputation",
                                        string.format("You need more than %i reputation",math.floor(comms_source:getReputationPoints())),
                                        "You don't have enough reputation",
                                    }
                                    setCommsMessage(tableSelectRandom(insufficient_rep_responses))
                                end
                                addCommsReply(_("Back"), commsStation)
                            end)
                        end
                    end
                    addCommsReply(_("Back"), commsStation)
                end)
            end
        end
        if avail_count < 1 then
            local insufficient_reinforcements = {
                "No reinforcements available",
                "We don't have any reinforcements",
                "No military ships in our inventory, sorry",
                "Reinforcements unavailable",
            }
            setCommsMessage(tableSelectRandom(insufficient_reinforcements))
        end
        addCommsReply(string.format("Back to %s",calling_function.name),calling_function.identifier)
        addCommsReply(_("Back to station communication"), commsStation)
    end)
end
function requestSupplyDrop(calling_function)
    local supply_drop_request = {
        "Request supply drop",
        "We need some supplies delivered",
        "Could you drop us some supplies?",
        "We could really use a supply drop",
    }
    addCommsReply(tableSelectRandom(supply_drop_request),function()
        local supply_drop_type = {
            "What kind of supply drop would you like?",
            "Supply drop type?",
            "In what way would you like your supplies delivered?",
            "Supply drop method?",
        }
        setCommsMessage(tableSelectRandom(supply_drop_type))
        local supply_drop_cost = math.ceil(getServiceCost("supplydrop"))
        local normal_drop_cost = {
            string.format("Normal (%i reputation)",supply_drop_cost),
            string.format("Regular (%i reputation)",supply_drop_cost),
            string.format("Plain (%i reputation)",supply_drop_cost),
            string.format("Simple (%i reputation)",supply_drop_cost),
        }
        addCommsReply(tableSelectRandom(normal_drop_cost),function()
            if comms_source:getWaypointCount() < 1 then
                local set_supply_waypoint = {
                    "You need to set a waypoint before you can request supplies.",
                    "Set a waypoint so that we can place your supplies.",
                    "Supplies require a waypoint as a target.",
                    "Before requesting supplies, you need to set a waypoint.",
                }
                setCommsMessage(tableSelectRandom(set_supply_waypoint))
            else
                local point_supplies = {
                    "To which waypoint should we deliver your supplies?",
                    "Identify the supply delivery waypoint",
                    "Where do you want your supplies?",
                    "Where do the supplies go?",
                }
                setCommsMessage(tableSelectRandom(point_supplies))
                for n=1,comms_source:getWaypointCount() do
                    addCommsReply(string.format(_("stationAssist-comms","Waypoint %i"),n), function()
                        if comms_source:takeReputationPoints(getServiceCost("supplydrop")) then
                            local position_x, position_y = comms_target:getPosition()
                            local target_x, target_y = comms_source:getWaypoint(n)
                            local script = Script()
                            script:setVariable("position_x", position_x):setVariable("position_y", position_y)
                            script:setVariable("target_x", target_x):setVariable("target_y", target_y)
                            script:setVariable("faction_id", comms_source:getFactionId()):run("supply_drop.lua")
                            local supply_ship_en_route = {
                                string.format("We have dispatched a supply ship toward waypoint %d",n),
                                string.format("We sent a supply ship to waypoint %i",n),
                                string.format("There's a ship headed for %i with your supplies",n),
                                string.format("A ship should be arriving soon at waypoint %i with your supplies",n)
                            }
                            setCommsMessage(tableSelectRandom(supply_ship_en_route))
                        else
                            local insufficient_rep_responses = {
                                "Insufficient reputation",
                                "Not enough reputation",
                                "You need more reputation",
                                string.format("You need more than %i reputation",math.floor(comms_source:getReputationPoints())),
                                "You don't have enough reputation",
                            }
                            setCommsMessage(tableSelectRandom(insufficient_rep_responses))
                        end
                        addCommsReply(_("Back"), commsStation)
                    end)
                end
            end
            addCommsReply(_("Back"), commsStation)
        end)
        if comms_target.comms_data.friendlyness > 20 then
            local jump_drop_cost = {
                string.format("Delivered by jump ship (%d reputation)",getServiceCost("jumpsupplydrop")),
                string.format("Jump ship drop (%i reputation)",getServiceCost("jumpsupplydrop")),
                string.format("Deliver with jump ship (%i reputation)",getServiceCost("jumpsupplydrop")),
                string.format("Jump ship supply drop (%i reputation)",getServiceCost("jumpsupplydrop")),
            }
            addCommsReply(tableSelectRandom(jump_drop_cost),function()
                if comms_source:getWaypointCount() < 1 then
                    local set_supply_waypoint = {
                        "You need to set a waypoint before you can request supplies.",
                        "Set a waypoint so that we can place your supplies.",
                        "Supplies require a waypoint as a target.",
                        "Before requesting supplies, you need to set a waypoint.",
                    }
                    setCommsMessage(tableSelectRandom(set_supply_waypoint))
                else
                    local point_supplies = {
                        "To which waypoint should we deliver your supplies?",
                        "Identify the supply delivery waypoint",
                        "Where do you want your supplies?",
                        "Where do the supplies go?",
                    }
                    setCommsMessage(tableSelectRandom(point_supplies))
                    for n=1,comms_source:getWaypointCount() do
                        addCommsReply(string.format(_("stationAssist-comms","Waypoint %i"),n), function()
                            if comms_source:takeReputationPoints(getServiceCost("jumpsupplydrop")) then
                                local position_x, position_y = comms_target:getPosition()
                                local target_x, target_y = comms_source:getWaypoint(n)
                                local script = Script()
                                script:setVariable("position_x", position_x):setVariable("position_y", position_y)
                                script:setVariable("target_x", target_x):setVariable("target_y", target_y)
                                script:setVariable("jump_freighter","yes")
                                script:setVariable("faction_id", comms_source:getFactionId()):run("supply_drop.lua")
                                local supply_ship_en_route = {
                                    string.format("We have dispatched a supply ship toward waypoint %d",n),
                                    string.format("We sent a supply ship to waypoint %i",n),
                                    string.format("There's a ship headed for %i with your supplies",n),
                                    string.format("A ship should be arriving soon at waypoint %i with your supplies",n)
                                }
                                setCommsMessage(tableSelectRandom(supply_ship_en_route))
                            else
                                local insufficient_rep_responses = {
                                    "Insufficient reputation",
                                    "Not enough reputation",
                                    "You need more reputation",
                                    string.format("You need more than %i reputation",math.floor(comms_source:getReputationPoints())),
                                    "You don't have enough reputation",
                                }
                                setCommsMessage(tableSelectRandom(insufficient_rep_responses))
                            end
                            addCommsReply(_("Back"), commsStation)
                        end)
                    end
                end
                addCommsReply(_("Back"), commsStation)
            end)
        end
        if comms_target.comms_data.friendlyness > 66 then
            local flinger_drop_cost = {
                string.format("Delivered by flinger (%d reputation)",getServiceCost("flingsupplydrop")),
                string.format("Flinger drop (%i reputation)",getServiceCost("flingsupplydrop")),
                string.format("Flinger supply drop (%i reputation)",getServiceCost("flingsupplydrop")),
                string.format("Fling supplies to the drop point (%i reputation)",getServiceCost("flingsupplydrop")),
            }
            addCommsReply(tableSelectRandom(flinger_drop_cost),function()
                local add_supplies_prompt = {
                    "Do you want the standard 500 energy, 1 nuke, 4 homings, 2 mines, 1 EMP supply package or would you like to add something?",
                    "Would you like the standard package (500 energy, 1 nuke, 4 homings, 2 mines, 1 EMP) or would you like to add something?",
                    "Add to standard package (500 energy, 1 nuke, 4 homings, 2 mines, 1 EMP) or not?",
                    "Standard supply package (500 energy, 1 nuke, 4 homings, 2 mines, 1 EMP) or more?",
                }
                setCommsMessage(tableSelectRandom(add_supplies_prompt))
                local standard_only = {
                    string.format("Standard (%d reputation, no change)",getServiceCost("flingsupplydrop")),
                    string.format("Just the standard package (%i reputation)",getServiceCost("flingsupplydrop")),
                    string.format("Standard only (%s reputation)",getServiceCost("flingsupplydrop")),
                    string.format("Standard package alone (%s reputation)",getServiceCost("flingsupplydrop")),
                }
                addCommsReply(tableSelectRandom(standard_only),function()
                    if comms_source:getWaypointCount() < 1 then
                        local set_supply_waypoint = {
                            "You need to set a waypoint before you can request supplies.",
                            "Set a waypoint so that we can place your supplies.",
                            "Supplies require a waypoint as a target.",
                            "Before requesting supplies, you need to set a waypoint.",
                        }
                        setCommsMessage(tableSelectRandom(set_supply_waypoint))
                    else
                        local point_supplies = {
                            "To which waypoint should we deliver your supplies?",
                            "Identify the supply delivery waypoint",
                            "Where do you want your supplies?",
                            "Where do the supplies go?",
                        }
                        setCommsMessage(tableSelectRandom(point_supplies))
                        for n=1,comms_source:getWaypointCount() do
                            addCommsReply(string.format(_("stationAssist-comms","Waypoint %i"),n), function()
                                if comms_source:takeReputationPoints(getServiceCost("flingsupplydrop")) then
                                    local target_x, target_y = comms_source:getWaypoint(n)
                                    local target_angle = random(0,360)
                                    local flinger_miss = random(100,5000)
                                    local landing_x, landing_y = vectorFromAngle(target_angle,flinger_miss)
                                    local sd = SupplyDrop():setFactionId(comms_target:getFactionId()):setPosition(target_x + landing_x, target_y + landing_y):setEnergy(500):setWeaponStorage("Nuke", 1):setWeaponStorage("Homing", 4):setWeaponStorage("Mine", 2):setWeaponStorage("EMP", 1)
                                    local supply_location = {
                                        string.format("Supplies delivered %.1f units from waypoint, bearing %.1f.",flinger_miss/1000,target_angle),
                                        string.format("Supplies have been launched. You can find them %.1f units from waypoint %i on bearing %.1f",flinger_miss/1000,n,target_angle),
                                        string.format("Our flinger has launched your supplies at waypoint %i. Look for them at %.1f units from waypoint, bearing %.1f",n,flinger_miss/1000,target_angle),
                                        string.format("Flung. Find supplies %.1f units from waypoint %i on bearing %.1f",flinger_miss/1000,n,target_angle),
                                    }
                                    setCommsMessage(tableSelectRandom(supply_location))
                                else
                                    local insufficient_rep_responses = {
                                        "Insufficient reputation",
                                        "Not enough reputation",
                                        "You need more reputation",
                                        string.format("You need more than %i reputation",math.floor(comms_source:getReputationPoints())),
                                        "You don't have enough reputation",
                                    }
                                    setCommsMessage(tableSelectRandom(insufficient_rep_responses))
                                end
                            end)
                        end
                    end
                end)
                addCommsReply(string.format(_("stationAssist-comms","Add HVLIs (%d rep + %d rep = %d rep)"),getServiceCost("flingsupplydrop"),getWeaponCost("HVLI")*5,getServiceCost("flingsupplydrop") + (getWeaponCost("HVLI")*5)),function()
                    if comms_source:getWaypointCount() < 1 then
                        local set_supply_waypoint = {
                            "You need to set a waypoint before you can request supplies.",
                            "Set a waypoint so that we can place your supplies.",
                            "Supplies require a waypoint as a target.",
                            "Before requesting supplies, you need to set a waypoint.",
                        }
                        setCommsMessage(tableSelectRandom(set_supply_waypoint))
                    else
                        local point_supplies = {
                            "To which waypoint should we deliver your supplies?",
                            "Identify the supply delivery waypoint",
                            "Where do you want your supplies?",
                            "Where do the supplies go?",
                        }
                        setCommsMessage(tableSelectRandom(point_supplies))
                        for n=1,comms_source:getWaypointCount() do
                            addCommsReply(string.format(_("stationAssist-comms","Waypoint %i"),n), function()
                                if comms_source:takeReputationPoints(getServiceCost("flingsupplydrop") + (getWeaponCost("HVLI")*5)) then
                                    local target_x, target_y = comms_source:getWaypoint(n)
                                    local target_angle = random(0,360)
                                    local flinger_miss = random(100,5000)
                                    local landing_x, landing_y = vectorFromAngle(target_angle,flinger_miss)
                                    local sd = SupplyDrop():setFactionId(comms_target:getFactionId()):setPosition(target_x + landing_x, target_y + landing_y):setEnergy(500):setWeaponStorage("HVLI",5):setWeaponStorage("Nuke", 1):setWeaponStorage("Homing", 4):setWeaponStorage("Mine", 2):setWeaponStorage("EMP", 1)
                                    local supply_location = {
                                        string.format("Supplies delivered %.1f units from waypoint, bearing %.1f.",flinger_miss/1000,target_angle),
                                        string.format("Supplies have been launched. You can find them %.1f units from waypoint %i on bearing %.1f",flinger_miss/1000,n,target_angle),
                                        string.format("Our flinger has launched your supplies at waypoint %i. Look for them at %.1f units from waypoint, bearing %.1f",n,flinger_miss/1000,target_angle),
                                        string.format("Flung. Find supplies %.1f units from waypoint %i on bearing %.1f",flinger_miss/1000,n,target_angle),
                                    }
                                    setCommsMessage(tableSelectRandom(supply_location))
                                else
                                    local insufficient_rep_responses = {
                                        "Insufficient reputation",
                                        "Not enough reputation",
                                        "You need more reputation",
                                        string.format("You need more than %i reputation",math.floor(comms_source:getReputationPoints())),
                                        "You don't have enough reputation",
                                    }
                                    setCommsMessage(tableSelectRandom(insufficient_rep_responses))
                                end
                            end)
                        end
                    end
                end)
                addCommsReply(string.format(_("stationAssist-comms","Add hull repair (%d rep + %d rep = %d rep)"),getServiceCost("flingsupplydrop"),100,getServiceCost("flingsupplydrop") + 100),function()
                    if comms_source:getWaypointCount() < 1 then
                        local set_supply_waypoint = {
                            "You need to set a waypoint before you can request supplies.",
                            "Set a waypoint so that we can place your supplies.",
                            "Supplies require a waypoint as a target.",
                            "Before requesting supplies, you need to set a waypoint.",
                        }
                        setCommsMessage(tableSelectRandom(set_supply_waypoint))
                    else
                        local point_supplies = {
                            "To which waypoint should we deliver your supplies?",
                            "Identify the supply delivery waypoint",
                            "Where do you want your supplies?",
                            "Where do the supplies go?",
                        }
                        setCommsMessage(tableSelectRandom(point_supplies))
                        for n=1,comms_source:getWaypointCount() do
                            addCommsReply(string.format(_("stationAssist-comms","Waypoint %i"),n), function()
                                if comms_source:takeReputationPoints(getServiceCost("flingsupplydrop") + 100) then
                                    local target_x, target_y = comms_source:getWaypoint(n)
                                    local target_angle = random(0,360)
                                    local flinger_miss = random(100,5000)
                                    local landing_x, landing_y = vectorFromAngle(target_angle,flinger_miss)
                                    local sd = SupplyDrop():setFactionId(comms_target:getFactionId()):setPosition(target_x + landing_x, target_y + landing_y):setEnergy(500):setWeaponStorage("Nuke", 1):setWeaponStorage("Homing", 4):setWeaponStorage("Mine", 2):setWeaponStorage("EMP", 1)
                                    sd:onPickUp(function(self,player)
                                        string.format("")
                                        player:setHull(player:getHullMax())
                                    end)
                                    local supply_location = {
                                        string.format("Supplies delivered %.1f units from waypoint, bearing %.1f.",flinger_miss/1000,target_angle),
                                        string.format("Supplies have been launched. You can find them %.1f units from waypoint %i on bearing %.1f",flinger_miss/1000,n,target_angle),
                                        string.format("Our flinger has launched your supplies at waypoint %i. Look for them at %.1f units from waypoint, bearing %.1f",n,flinger_miss/1000,target_angle),
                                        string.format("Flung. Find supplies %.1f units from waypoint %i on bearing %.1f",flinger_miss/1000,n,target_angle),
                                    }
                                    setCommsMessage(tableSelectRandom(supply_location))
                                else
                                    local insufficient_rep_responses = {
                                        "Insufficient reputation",
                                        "Not enough reputation",
                                        "You need more reputation",
                                        string.format("You need more than %i reputation",math.floor(comms_source:getReputationPoints())),
                                        "You don't have enough reputation",
                                    }
                                    setCommsMessage(tableSelectRandom(insufficient_rep_responses))
                                end
                            end)
                        end
                    end
                end)
                addCommsReply(string.format(_("stationAssist-comms","Add probes (%d rep + %d rep = %d rep)"),getServiceCost("flingsupplydrop"),20,getServiceCost("flingsupplydrop") + 20),function()
                    if comms_source:getWaypointCount() < 1 then
                        local set_supply_waypoint = {
                            "You need to set a waypoint before you can request supplies.",
                            "Set a waypoint so that we can place your supplies.",
                            "Supplies require a waypoint as a target.",
                            "Before requesting supplies, you need to set a waypoint.",
                        }
                        setCommsMessage(tableSelectRandom(set_supply_waypoint))
                    else
                        local point_supplies = {
                            "To which waypoint should we deliver your supplies?",
                            "Identify the supply delivery waypoint",
                            "Where do you want your supplies?",
                            "Where do the supplies go?",
                        }
                        setCommsMessage(tableSelectRandom(point_supplies))
                        for n=1,comms_source:getWaypointCount() do
                            addCommsReply(string.format(_("stationAssist-comms","Waypoint %i"),n), function()
                                if comms_source:takeReputationPoints(getServiceCost("flingsupplydrop") + 20) then
                                    local target_x, target_y = comms_source:getWaypoint(n)
                                    local target_angle = random(0,360)
                                    local flinger_miss = random(100,5000)
                                    local landing_x, landing_y = vectorFromAngle(target_angle,flinger_miss)
                                    local sd = SupplyDrop():setFactionId(comms_target:getFactionId()):setPosition(target_x + landing_x, target_y + landing_y):setEnergy(500):setWeaponStorage("Nuke", 1):setWeaponStorage("Homing", 4):setWeaponStorage("Mine", 2):setWeaponStorage("EMP", 1)
                                    sd:onPickUp(function(self,player)
                                        string.format("")
                                        player:setScanProbeCount(player:getMaxScanProbeCount())
                                    end)
                                    local supply_location = {
                                        string.format("Supplies delivered %.1f units from waypoint, bearing %.1f.",flinger_miss/1000,target_angle),
                                        string.format("Supplies have been launched. You can find them %.1f units from waypoint %i on bearing %.1f",flinger_miss/1000,n,target_angle),
                                        string.format("Our flinger has launched your supplies at waypoint %i. Look for them at %.1f units from waypoint, bearing %.1f",n,flinger_miss/1000,target_angle),
                                        string.format("Flung. Find supplies %.1f units from waypoint %i on bearing %.1f",flinger_miss/1000,n,target_angle),
                                    }
                                    setCommsMessage(tableSelectRandom(supply_location))
                                else
                                    local insufficient_rep_responses = {
                                        "Insufficient reputation",
                                        "Not enough reputation",
                                        "You need more reputation",
                                        string.format("You need more than %i reputation",math.floor(comms_source:getReputationPoints())),
                                        "You don't have enough reputation",
                                    }
                                    setCommsMessage(tableSelectRandom(insufficient_rep_responses))
                                end
                            end)
                        end
                    end
                end)
                if comms_target.comms_data.available_repair_crew == nil then
                    comms_target.comms_data.available_repair_crew = math.random(0,5)
                    comms_target.comms_data.available_repair_crew_cost_friendly_needy_over_66 = math.random(30,60)
                    comms_target.comms_data.available_repair_crew_cost_neutral_needy_over_66 = math.random(45,90)
                    comms_target.comms_data.available_repair_crew_cost_excess = math.random(15,30)
                    comms_target.comms_data.available_repair_crew_cost_under_66 = math.random(15,30)
                end
                if comms_target.comms_data.available_repair_crew > 0 then
                    local hire_cost = 0
                    if comms_source:isFriendly(comms_target) then
                        hire_cost = comms_target.comms_data.available_repair_crew_cost_friendly_needy_over_66
                    else
                        hire_cost = comms_target.comms_data.available_repair_crew_cost_neutral_needy_over_66
                    end
                    if comms_target.comms_data.friendlyness <= 66 then
                        hire_cost = hire_cost + comms_target.comms_data.available_repair_crew_cost_under_66
                    end
                    if comms_source:getRepairCrewCount() >= comms_source.maxRepairCrew then
                        hire_cost = hire_cost + comms_target.comms_data.available_repair_crew_cost_excess
                    end
                    addCommsReply(string.format(_("stationAssist-comms","Add android repair crew (%d rep + %d rep = %d rep)"),getServiceCost("flingsupplydrop"),hire_cost,getServiceCost("flingsupplydrop") + hire_cost),function()
                        if comms_source:getWaypointCount() < 1 then
                            local set_supply_waypoint = {
                                "You need to set a waypoint before you can request supplies.",
                                "Set a waypoint so that we can place your supplies.",
                                "Supplies require a waypoint as a target.",
                                "Before requesting supplies, you need to set a waypoint.",
                            }
                            setCommsMessage(tableSelectRandom(set_supply_waypoint))
                        else
                            local point_supplies = {
                                "To which waypoint should we deliver your supplies?",
                                "Identify the supply delivery waypoint",
                                "Where do you want your supplies?",
                                "Where do the supplies go?",
                            }
                            setCommsMessage(tableSelectRandom(point_supplies))
                            for n=1,comms_source:getWaypointCount() do
                                addCommsReply(string.format(_("stationAssist-comms","Waypoint %i"),n), function()
                                    local hire_cost = 0
                                    if comms_source:isFriendly(comms_target) then
                                        hire_cost = comms_target.comms_data.available_repair_crew_cost_friendly_needy_over_66
                                    else
                                        hire_cost = comms_target.comms_data.available_repair_crew_cost_neutral_needy_over_66
                                    end
                                    if comms_target.comms_data.friendlyness <= 66 then
                                        hire_cost = hire_cost + comms_target.comms_data.available_repair_crew_cost_under_66
                                    end
                                    if comms_source:getRepairCrewCount() >= comms_source.maxRepairCrew then
                                        hire_cost = hire_cost + comms_target.comms_data.available_repair_crew_cost_excess
                                    end
                                    if comms_source:takeReputationPoints(getServiceCost("flingsupplydrop") + hire_cost) then
                                        local target_x, target_y = comms_source:getWaypoint(n)
                                        local target_angle = random(0,360)
                                        local flinger_miss = random(100,5000)
                                        local landing_x, landing_y = vectorFromAngle(target_angle,flinger_miss)
                                        local sd = SupplyDrop():setFactionId(comms_target:getFactionId()):setPosition(target_x + landing_x, target_y + landing_y):setEnergy(500):setWeaponStorage("Nuke", 1):setWeaponStorage("Homing", 4):setWeaponStorage("Mine", 2):setWeaponStorage("EMP", 1)
                                        comms_target.comms_data.available_repair_crew = comms_target.comms_data.available_repair_crew - 1
                                        sd:onPickUp(function(self,player)
                                            string.format("")
                                            player:setRepairCrewCount(player:getRepairCrewCount() + 1)
                                        end)
                                        local supply_location = {
                                            string.format("Supplies delivered %.1f units from waypoint, bearing %.1f.",flinger_miss/1000,target_angle),
                                            string.format("Supplies have been launched. You can find them %.1f units from waypoint %i on bearing %.1f",flinger_miss/1000,n,target_angle),
                                            string.format("Our flinger has launched your supplies at waypoint %i. Look for them at %.1f units from waypoint, bearing %.1f",n,flinger_miss/1000,target_angle),
                                            string.format("Flung. Find supplies %.1f units from waypoint %i on bearing %.1f",flinger_miss/1000,n,target_angle),
                                        }
                                        setCommsMessage(tableSelectRandom(supply_location))
                                    else
                                        local insufficient_rep_responses = {
                                            "Insufficient reputation",
                                            "Not enough reputation",
                                            "You need more reputation",
                                            string.format("You need more than %i reputation",math.floor(comms_source:getReputationPoints())),
                                            "You don't have enough reputation",
                                        }
                                        setCommsMessage(tableSelectRandom(insufficient_rep_responses))
                                    end
                                end)
                            end
                        end
                    end)
                end
                if comms_target.comms_data.coolant_inventory == nil then
                    comms_target.comms_data.coolant_inventory = math.random(0,5)*2
                    comms_target.comms_data.coolant_inventory_cost_friendly_needy_over_66 = math.random(30,60)
                    comms_target.comms_data.coolant_inventory_cost_neutral_needy_over_66 = math.random(45,90)
                    comms_target.comms_data.coolant_inventory_excess = math.random(15,30)
                    comms_target.comms_data.coolant_inventory_under_66 = math.random(15,30)
                end
                if comms_target.comms_data.coolant_inventory > 0 then
                    local coolant_cost = 0
                    if comms_source:isFriendly(comms_target) then
                        coolant_cost = comms_target.comms_data.coolant_inventory_cost_friendly_needy_over_66
                    else
                        coolant_cost = comms_target.comms_data.coolant_inventory_cost_neutral_needy_over_66
                    end
                    if comms_target.comms_data.friendlyness <= 66 then
                        coolant_cost = coolant_cost + comms_target.comms_data.coolant_inventory_under_66
                    end
                    if comms_source:getMaxCoolant() >= comms_source.initialCoolant then
                        coolant_cost = coolant_cost + comms_target.comms_data.coolant_inventory_excess
                    end
                    addCommsReply(string.format(_("stationAssist-comms","Add coolant (%d rep + %d rep = %d rep)"),getServiceCost("flingsupplydrop"),coolant_cost,getServiceCost("flingsupplydrop") + coolant_cost),function()
                        if comms_source:getWaypointCount() < 1 then
                            local set_supply_waypoint = {
                                "You need to set a waypoint before you can request supplies.",
                                "Set a waypoint so that we can place your supplies.",
                                "Supplies require a waypoint as a target.",
                                "Before requesting supplies, you need to set a waypoint.",
                            }
                            setCommsMessage(tableSelectRandom(set_supply_waypoint))
                        else
                            local point_supplies = {
                                "To which waypoint should we deliver your supplies?",
                                "Identify the supply delivery waypoint",
                                "Where do you want your supplies?",
                                "Where do the supplies go?",
                            }
                            setCommsMessage(tableSelectRandom(point_supplies))
                            for n=1,comms_source:getWaypointCount() do
                                addCommsReply(string.format(_("stationAssist-comms","Waypoint %i"),n), function()
                                    local coolant_cost = 0
                                    if comms_source:isFriendly(comms_target) then
                                        coolant_cost = comms_target.comms_data.coolant_inventory_cost_friendly_needy_over_66
                                    else
                                        coolant_cost = comms_target.comms_data.coolant_inventory_cost_neutral_needy_over_66
                                    end
                                    if comms_target.comms_data.friendlyness <= 66 then
                                        coolant_cost = coolant_cost + comms_target.comms_data.coolant_inventory_under_66
                                    end
                                    if comms_source:getMaxCoolant() >= comms_source.initialCoolant then
                                        coolant_cost = coolant_cost + comms_target.comms_data.coolant_inventory_excess
                                    end
                                    if comms_source:takeReputationPoints(getServiceCost("flingsupplydrop") + coolant_cost) then
                                        local target_x, target_y = comms_source:getWaypoint(n)
                                        local target_angle = random(0,360)
                                        local flinger_miss = random(100,5000)
                                        local landing_x, landing_y = vectorFromAngle(target_angle,flinger_miss)
                                        local sd = SupplyDrop():setFactionId(comms_target:getFactionId()):setPosition(target_x + landing_x, target_y + landing_y):setEnergy(500):setWeaponStorage("Nuke", 1):setWeaponStorage("Homing", 4):setWeaponStorage("Mine", 2):setWeaponStorage("EMP", 1)
                                        comms_target.comms_data.coolant_inventory = comms_target.comms_data.coolant_inventory - 2
                                        sd:onPickUp(function(self,player)
                                            string.format("")
                                            player:setMaxCoolant(player:getMaxCoolant() + 2)
                                        end)
                                        local supply_location = {
                                            string.format("Supplies delivered %.1f units from waypoint, bearing %.1f.",flinger_miss/1000,target_angle),
                                            string.format("Supplies have been launched. You can find them %.1f units from waypoint %i on bearing %.1f",flinger_miss/1000,n,target_angle),
                                            string.format("Our flinger has launched your supplies at waypoint %i. Look for them at %.1f units from waypoint, bearing %.1f",n,flinger_miss/1000,target_angle),
                                            string.format("Flung. Find supplies %.1f units from waypoint %i on bearing %.1f",flinger_miss/1000,n,target_angle),
                                        }
                                        setCommsMessage(tableSelectRandom(supply_location))
                                    else
                                        local insufficient_rep_responses = {
                                            "Insufficient reputation",
                                            "Not enough reputation",
                                            "You need more reputation",
                                            string.format("You need more than %i reputation",math.floor(comms_source:getReputationPoints())),
                                            "You don't have enough reputation",
                                        }
                                        setCommsMessage(tableSelectRandom(insufficient_rep_responses))
                                    end
                                end)
                            end
                        end
                    end)
                end
                addCommsReply(_("Back"), commsStation)
            end)
            local deliver_type_explain_prompt = {
                "Explain supply drop delivery options",
                "What's the difference between the supply drop options?",
                "Please explain the different supply drop options",
                "I don't understand the supply drop delivery options",
            }
            addCommsReply(tableSelectRandom(deliver_type_explain_prompt),function()
                setCommsMessage(_("stationAssist-comms","A normal supply drop delivery is loaded onto a standard freighter and sent to the specified destination. Delivered by jump ship means it gets there quicker if it's farther away because the freighter is equipped with a jump drive. The flinger launches the supply drop using the station's flinger. The supply drop arrives quickly, but the flinger's not as accurate as a freighter."))
                addCommsReply(_("Back"), commsStation)
            end)
        end
        addCommsReply(string.format("Back to %s",calling_function.name),calling_function.identifier)
        addCommsReply(_("Back to station communication"), commsStation)
    end)
end
--[[RM
function serviceJonque(enemyFaction)
	local ship = CpuShip():setTemplate("Equipment Jump Freighter 4")
	if enemyFaction ~= nil then
		ship:setFaction(enemyFaction)
	end
	ship:setTypeName("Service Jonque"):setCommsScript(""):setCommsFunction(commsServiceJonque) --TODO
	return ship
end

function requestJonque()
    local send_jonque = {
        "Please send a service jonque for repairs",
        "We need a service jonque for repairs",
        "We could use a service jonque for repairs",
        "Please dispatch a service jonque for us",
    }
    addCommsReply(tableSelectRandom(send_jonque), function()
        local jonque_meet_method_cost = {
            string.format("Would you like the service jonque to come to you directly or would you prefer to set up a rendezvous via a waypoint? Either way, you will need %.1f reputation.",getServiceCost("servicejonque")),
            string.format("%.1f reputation required. What should we tell the service jonque - meet you directly or go to a waypoint?",getServiceCost("servicejonque")),
            string.format("Should the service jonque travel directly to you or go to a designated waypoint? The cost is the same: %.1f reputation.",getServiceCost("servicejonque")),
            string.format("Do you want the service jonque to go to you or to a waypoint? In either case, it will cost %.1f reputation.",getServiceCost("servicejonque")),
        }
        local out = string.format(tableSelectRandom(jonque_meet_method_cost))
        local jonque_direct_to_ship = {
            "Direct",
            string.format("Go directly to %s",comms_source:getCallSign()),
            "Meet us directly",
            string.format("Meet %s directly",comms_source:getCallSign()),
        }
        addCommsReply(tableSelectRandom(jonque_direct_to_ship),function()
            if comms_source:takeReputationPoints(getServiceCost("servicejonque")) then
                ship = serviceJonque(comms_target:getFaction()):setPosition(comms_target:getPosition()):setCallSign(generateCallSign(nil,comms_target:getFaction())):setScanned(true):orderDefendTarget(comms_source)
                ship.comms_data = {
                    friendlyness = random(0.0, 100.0),
                    weapons = {
                        Homing = comms_target.comms_data.weapons.Homing,
                        HVLI = comms_target.comms_data.weapons.HVLI,
                        Mine = comms_target.comms_data.weapons.Mine,
                        Nuke = comms_target.comms_data.weapons.Nuke,
                        EMP = comms_target.comms_data.weapons.EMP,
                    },
                    weapon_cost = {
                        Homing = comms_target.comms_data.weapon_cost.Homing * 2,
                        HVLI = comms_target.comms_data.weapon_cost.HVLI * 2,
                        Mine = comms_target.comms_data.weapon_cost.Mine * 2,
                        Nuke = comms_target.comms_data.weapon_cost.Nuke * 2,
                        EMP = comms_target.comms_data.weapon_cost.EMP * 2,
                    },
                    weapon_inventory = {
                        Homing = 40,
                        HVLI = 40,
                        Mine = 20,
                        Nuke = 10,
                        EMP = 10,
                    },
                    weapon_inventory_max = {
                        Homing = 40,
                        HVLI = 40,
                        Mine = 20,
                        Nuke = 10,
                        EMP = 10,
                    },
                    reputation_cost_multipliers = {
                        friend = comms_target.comms_data.reputation_cost_multipliers.friend,
                        neutral = math.max(comms_target.comms_data.reputation_cost_multipliers.friend,comms_target.comms_data.reputation_cost_multipliers.neutral/2)
                    },
                }
                local dispatched_jonque = {
                    string.format("We have dispatched %s to come to you to help with repairs",ship:getCallSign()),
                    string.format("Service jonque %s is heading for you to help with repairs",ship:getCallSign()),
                    string.format("We are sending %s to you to help with repairs",ship:getCallSign()),
                    string.format("We directed service jonque %s to you to help with repairs",ship:getCallSign()),
                }
                setCommsMessage(tableSelectRandom(dispatched_jonque))
            else
                local insufficient_rep_responses = {
                    "Insufficient reputation",
                    "Not enough reputation",
                    "You need more reputation",
                    string.format("You need more than %i reputation",math.floor(comms_source:getReputationPoints())),
                    "You don't have enough reputation",
                }
                setCommsMessage(tableSelectRandom(insufficient_rep_responses))
            end
        end)
        if comms_source:getWaypointCount() < 1 then
            local waypoint_addendum = {
                "\n\nNote: if you want to use a waypoint, you will have to back out, set one and return.",
                "\n\nTo use a waypoint, set one, then back out and return to use the rendezvous at waypoint option.",
                "\n\nYou will need to set a waypoint, back out and return if you want the service jonque to meet you at a waypoint.",
                "\n\nNote: set waypoint, back out and return to send the service jonque to a waypoint.",
            }
            out = string.format("%s%s",out,tableSelectRandom(waypoint_addendum))
        else
            for n=1,comms_source:getWaypointCount() do
                local rendezvous_prompts = {
                    string.format("Rendezvous at waypoint %i",n),
                    string.format("Tell jonque to meet at waypoint %i",n),
                    string.format("Jonque to rendezvous at waypoint %i",n),
                    string.format("Have the service jonque meet us at waypoint %i",n)
                }
                addCommsReply(tableSelectRandom(rendezvous_prompts),function()
                    if comms_source:takeReputationPoints(getServiceCost("servicejonque")) then
                        ship = serviceJonque(comms_target:getFaction()):setPosition(comms_target:getPosition()):setCallSign(generateCallSign(nil,comms_target:getFaction())):setScanned(true):orderDefendLocation(comms_source:getWaypoint(n))
                        ship.comms_data = {
                            friendlyness = random(0.0, 100.0),
                            weapons = {
                                Homing = comms_target.comms_data.weapons.Homing,
                                HVLI = comms_target.comms_data.weapons.HVLI,
                                Mine = comms_target.comms_data.weapons.Mine,
                                Nuke = comms_target.comms_data.weapons.Nuke,
                                EMP = comms_target.comms_data.weapons.EMP,
                            },
                            weapon_cost = {
                                Homing = comms_target.comms_data.weapon_cost.Homing * 2,
                                HVLI = comms_target.comms_data.weapon_cost.HVLI * 2,
                                Mine = comms_target.comms_data.weapon_cost.Mine * 2,
                                Nuke = comms_target.comms_data.weapon_cost.Nuke * 2,
                                EMP = comms_target.comms_data.weapon_cost.EMP * 2,
                            },
                            weapon_inventory = {
                                Homing = 40,
                                HVLI = 40,
                                Mine = 20,
                                Nuke = 10,
                                EMP = 10,
                            },
                            weapon_inventory_max = {
                                Homing = 40,
                                HVLI = 40,
                                Mine = 20,
                                Nuke = 10,
                                EMP = 10,
                            },
                            reputation_cost_multipliers = {
                                friend = comms_target.comms_data.reputation_cost_multipliers.friend,
                                neutral = math.max(comms_target.comms_data.reputation_cost_multipliers.friend,comms_target.comms_data.reputation_cost_multipliers.neutral/2)
                            },
                        }
                        local jonque_sent_to_waypoint = {
                            string.format("We have dispatched %s to rendezvous at waypoint %i",ship:getCallSign(),n),
                            string.format("Service jonque %s is heading for waypoint %i",ship:getCallSign(),n),
                            string.format("We directed %s to meet you at waypoint %i",ship:getCallSign(),n),
                            string.format("Service jonque %s will rendezvous at waypoint %i",ship:getCallSign(),n),
                        }
                        setCommsMessage(tableSelectRandom(jonque_sent_to_waypoint))
                    else
                        local insufficient_rep_responses = {
                            "Insufficient reputation",
                            "Not enough reputation",
                            "You need more reputation",
                            string.format("You need more than %i reputation",math.floor(comms_source:getReputationPoints())),
                            "You don't have enough reputation",
                        }
                        setCommsMessage(tableSelectRandom(insufficient_rep_responses))
                    end
                    addCommsReply(_("Back"), commsStation)
                end)
            end
        end
        setCommsMessage(out)
        addCommsReply(_("Back"), commsStation)
    end)
end
function requestExpediteDock(calling_function)
    local expedite_dock_prompts = {
        "Expedite dock",
        "Speedy dock",
        "Fast dock",
        "Decrease dock time",
    }
    addCommsReply(tableSelectRandom(expedite_dock_prompts),function()
        if comms_source.expedite_dock == nil then
            local explain_expedite_dock = {
                "We can have workers standing by in the docking bay to rapidly service your ship when you dock. However, they won't wait around forever. When do you think you will dock?",
                string.format("We can direct dock workers to be ready to service your docked ship. They won't wait for long. How long before you dock with %s?",comms_target:getCallSign()),
                "To expedite your dock, we can have dock workers ready to load supplies and service your ship as soon as you dock. The workers won't hang around forever. When will you dock?",
                string.format("To reduce time spent docked at %s, we can hire dock workers to rapidly load and service %s as soon as you dock. However, we can only hire them for a limited period of time. When are you docking?",comms_target:getCallSign(),comms_source:getCallSign()),
            }
            setCommsMessage(tableSelectRandom(explain_expedite_dock))
            local short_minutes = 3
            local short_reputation = 10
            local short_prompts = {
                string.format("Soon (%i minutes max, %i reputation)",short_minutes,short_reputation),
                string.format("Quickly (less than %i minutes, %i reputation)",short_minutes,short_reputation),
                string.format("Shortly (%i reputation, < %i minutes)",short_reputation,short_minutes),
                string.format("We're nearby (%i reputation, %i minutes max)",short_reputation,short_minutes),
            }
            addCommsReply(tableSelectRandom(short_prompts),function()
                if comms_source:takeReputationPoints(short_reputation) then
                    comms_source.expedite_dock = {["limit"] = short_minutes*60}
                    setExpediteDock()
                else
                    local insufficient_rep_responses = {
                        "Insufficient reputation",
                        "Not enough reputation",
                        "You need more reputation",
                        string.format("You need more than %i reputation",math.floor(comms_source:getReputationPoints())),
                        "You don't have enough reputation",
                    }
                    setCommsMessage(tableSelectRandom(insufficient_rep_responses))
                    addCommsReply(_("Back"), commsStation)
                end
            end)
            local medium_minutes = 5
            local medium_reputation = 15
            local medium_prompts = {
                string.format("In a little while (%i minutes max, %i reputation)",medium_minutes,medium_reputation),
                string.format("Soon-ish (less than %i minutes, %i reputation)",medium_minutes,medium_reputation),
                string.format("Less than %i minutes (%i reputation)",medium_minutes,medium_reputation),
                string.format("Soon, I think (%i reputation, < %i minutes)",medium_reputation,medium_minutes),
            }
            addCommsReply(tableSelectRandom(medium_prompts),function()
                if comms_source:takeReputationPoints(medium_reputation) then
                    comms_source.expedite_dock = {["limit"] = medium_minutes*60}
                    setExpediteDock()
                else
                    local insufficient_rep_responses = {
                        "Insufficient reputation",
                        "Not enough reputation",
                        "You need more reputation",
                        string.format("You need more than %i reputation",math.floor(comms_source:getReputationPoints())),
                        "You don't have enough reputation",
                    }
                    setCommsMessage(tableSelectRandom(insufficient_rep_responses))
                    addCommsReply(_("Back"), commsStation)
                end
            end)
            local long_minutes = 8
            local long_reputation = 20
            local long_prompts = {
                string.format("We're far away (%i minutes max, %i reputation)",long_minutes,long_reputation),
                string.format("Less than %i minutes (%i reputation)",long_minutes,long_reputation),
                string.format("Hard to tell (less than %i minutes, %i reputation)",long_minutes,long_reputation),
                string.format("It'll be a bit (< %i minutes, %i reputation)",long_minutes,long_reputation),
            }
            addCommsReply(tableSelectRandom(long_prompts),function()
                if comms_source:takeReputationPoints(long_reputation) then
                    comms_source.expedite_dock = {["limit"] = long_minutes*60}
                    setExpediteDock()
                else
                    local insufficient_rep_responses = {
                        "Insufficient reputation",
                        "Not enough reputation",
                        "You need more reputation",
                        string.format("You need more than %i reputation",math.floor(comms_source:getReputationPoints())),
                        "You don't have enough reputation",
                    }
                    setCommsMessage(tableSelectRandom(insufficient_rep_responses))
                    addCommsReply(_("Back"), commsStation)
                end
            end)
            addCommsReply(string.format("Back to %s",calling_function.name),calling_function.identifier)
            addCommsReply(_("Back to station communication"), commsStation)
        else
            setExpediteDock()
        end
    end)
end
--]]
--[[ REMOVED
function setExpediteDock()
    --    energy, hull, probes, missiles, repair crew, coolant
    if comms_source.expedite_dock == nil then
        setCommsMessage(_("station-comms","Communications glitch. Please try again."))
        addCommsReply(_("Back"), commsStation)
    else
        if comms_source.expedite_dock.limit == nil then
            setCommsMessage(_("station-comms","Communications glitch. Please try again."))
            addCommsReply(_("Back"), commsStation)
        else
            local out = ""
            if comms_source.expedite_dock.expire == nil then
                comms_source.expedite_dock.expire = getScenarioTime() + comms_source.expedite_dock.limit
                if expedite_dock_players == nil then
                    expedite_dock_players = {}
                end
                expedite_dock_players[comms_source] = true
                comms_source.expedite_dock.station = comms_target
                local standard_service_count = 0
                if comms_target:getSharesEnergyWithDocked() then
                    comms_source.expedite_dock.energy = true
                    standard_service_count = standard_service_count + 1
                    out = _("station-comms","energy")
                end
                if comms_target:getRepairDocked() then
                    comms_source.expedite_dock.hull = true
                    standard_service_count = standard_service_count + 1
                    if out == "" then
                        out = _("station-comms","hull repair")
                    else
                        out = string.format(_("station-comms","%s, hull repair"),out)
                    end
                end
                if comms_target:getRestocksScanProbes() then
                    comms_source.expedite_dock.probes = true
                    standard_service_count = standard_service_count + 1
                    if out == "" then
                        out = _("station-comms","restock probes")
                    else
                        out = string.format(_("station-comms","%s, restock probes"),out)
                    end
                end
                local additional_services = {
                    "What additional service would you like expedited?",
                    "Would you like to add a service to your expedited services list?",
                    "Might we expedite another service for you?",
                    "We could expedite another service if you wish.",
                }
                if standard_service_count > 1 then
                    local plural_existing_services = {
                        "Standard expedited services:",
                        "Normal expedited services:",
                        "Regular expedited services:",
                        "Complimentary expedited services:",
                    }
                    out = string.format("%s %s. %s",tableSelectRandom(plural_existing_services),out,tableSelectRandom(additional_services))
                elseif standard_service_count > 0 then
                    local singular_existing_service = {
                        "Standard expedited service:",
                        "Normal expedited service:",
                        "Regular expedited service:",
                        "Complimentary expedited service:",
                    }
                    out = string.format("%s %s. %s",tableSelectRandom(singular_existing_service),out,tableSelectRandom(additional_services))
                else
                    local expedite_something = {
                        "What service would you like expedited?",
                        "Can we expedite a service for you?",
                        "Is there a service you'd like expedited?",
                        "Specify the service to expedite",
                    }
                    out = tableSelectRandom(expedite_something)
                end
            else
                if comms_source.expedite_dock.station ~= comms_target then
                    if comms_source.expedite_dock.station:isValid() then
                        local what_about_current_contract = {
                            string.format("I represent station %s.\nI see that you have an expedited docking contract with station %s.\nWould you like to cancel it?",comms_target:getCallSign(),comms_source.expedite_dock.station:getCallSign()),
                            string.format("Considering an expedited docking contract with %s, eh? What should be done about your existing expedited contract with %s? Cancel it?",comms_target:getCallSign(),comms_source.expedite_dock.station:getCallSign()),
                            string.format("Want a fast dock with %s? What should be done about your current agreement with %s? Should it be cancelled?",comms_target:getCallSign(),comms_source.expedite_dock.station:getCallSign()),
                            string.format("You can't set up a quick dock with %s until your quick dock with %s is done or cancelled. Shall I cancel it?",comms_target:getCallSign(),comms_source.expedite_dock.station:getCallSign()),
                        }
                        setCommsMessage(tableSelectRandom(what_about_current_contract))
                        local cancel_fast_dock_prompt = {
                            string.format("Yes, cancel expedited docking contract with %s",comms_source.expedite_dock.station:getCallSign()),
                            string.format("Abandon fast dock plan with %s",comms_source.expedite_dock.station:getCallSign()),
                            string.format("Cancel planned quick dock with %s",comms_source.expedite_dock.station:getCallSign()),
                            string.format("Please cancel the fast dock contract with %s",comms_source.expedite_dock.station:getCallSign()),
                        }
                        addCommsReply(tableSelectRandom(cancel_fast_dock_prompt),function()
                            local fast_dock_contract_cancelled = {
                                string.format("Expedited docking contract with %s has been cancelled.",comms_source.expedite_dock.station:getCallSign()),
                                string.format("Fast dock cancelled with %s",comms_source.expedite_dock.station:getCallSign()),
                                string.format("Ok, we just cancelled your expedited docking contract with %s",comms_source.expedite_dock.station:getCallSign()),
                                string.format("%s fast dock contract cancelled",comms_source.expedite_dock.station:getCallSign()),
                            }
                            setCommsMessage(tableSelectRandom(fast_dock_contract_cancelled))
                            expedite_dock_players[comms_source] = nil
                            comms_source.expedite_dock = nil
                            addCommsReply(_("Back"), commsStation)
                        end)
                        local keep_fast_dock_contract = {
                            string.format("No, keep existing expedited docking contract with %s",comms_source.expedite_dock.station:getCallSign()),
                            string.format("Oops, I forgot about that. I need to keep the fast dock contract with %s",comms_source.expedite_dock.station:getCallSign()),
                            string.format("I'd better keep the existing quick dock contract with %s",comms_source.expedite_dock.station:getCallSign()),
                            string.format("Keep the fast dock plan with %s. Let's not waste the reputation already spent there",comms_source.expedite_dock.station:getCallSign()),
                        }
                        addCommsReply(tableSelectRandom(keep_fast_dock_contract),function()
                            local fast_dock_contract_kept = {
                                string.format("Ok, we left the fast dock contract in place with %s",comms_source.expedite_dock.station:getCallSign()),
                                string.format("Kept the quick dock contract with %s",comms_source.expedite_dock.station:getCallSign()),
                                string.format("The expedited dock contract with %s remains in effect",comms_source.expedite_dock.station:getCallSign()),
                                string.format("Maintaining the fast dock contract with %s",comms_source.expedite_dock.station:getCallSign()),
                            }
                            setCommsMessage(tableSelectRandom(fast_dock_contract_kept))
                            addCommsReply(_("Back"), commsStation)
                        end)
                    else
                        local handled_invalid_contract = {
                            "An expedited docking contract with a now defunct station has been cancelled.",
                            "The station you had a fast dock contract with is gone. Contract cancelled.",
                            "Since the station you were planning to fast dock with no longer exists, the contract has been cancelled.",
                            "Your former fast dock station has ceased to exist. Expedited contract cancelled.",
                        }
                        setCommsMessage(tableSelectRandom(handled_invalid_contract))
                        expedite_dock_players[comms_source] = nil
                        comms_source.expedite_dock = nil
                        addCommsReply(_("Back"), commsStation)
                    end
                end
            end
            if comms_source.expedite_dock.station == comms_target then
                local service_to_add_count = 0
                if out == "" then
                    local minutes = 0
                    local seconds = comms_source.expedite_dock.expire - getScenarioTime()
                    if seconds > 60 then
                        minutes = seconds / 60
                        seconds = seconds % 60
                        out = string.format(_("station-comms","Expected dock with %s in %i:%.2i"),comms_target:getCallSign(),math.floor(minutes),math.floor(seconds))
                    else
                        out = string.format(_("station-comms","Expected dock with %s in 0:%.2i"),comms_target:getCallSign(),math.floor(seconds))
                    end
                end
                service_list = _("station-comms","Expedited service list:")
                if comms_source.expedite_dock.energy then
                    service_list = string.format(_("station-comms","%s energy"),service_list)
                else
                    local replenish_energy_fast_dock_prompt = {
                        "Replenish energy (5 reputation)",
                        "Charge batteries (5 reputation)",
                        "Recharge power (5 reputation)",
                        "Replenish power reserves (5 reputation)",
                    }
                    addCommsReply(tableSelectRandom(replenish_energy_fast_dock_prompt),function()
                        if comms_source:takeReputationPoints(5) then
                            comms_source.expedite_dock.energy = true
                            setExpediteDock()
                        else
                            local insufficient_rep_responses = {
                                "Insufficient reputation",
                                "Not enough reputation",
                                "You need more reputation",
                                string.format("You need more than %i reputation",math.floor(comms_source:getReputationPoints())),
                                "You don't have enough reputation",
                            }
                            setCommsMessage(tableSelectRandom(insufficient_rep_responses))
                            addCommsReply(_("station-comms","Back to expedited dock negotiation"),setExpediteDock)
                            addCommsReply(_("station-comms","Back to station communication"),commsStation)
                        end
                    end)
                    service_to_add_count = service_to_add_count + 1
                end
                if comms_source.expedite_dock.hull then
                    if service_list == _("station-comms","Expedited service list:") then
                        service_list = string.format(_("station-comms","%s hull"),service_list)
                    else
                        service_list = string.format(_("station-comms","%s, hull"),service_list)
                    end
                else
                    local repair_hull_fast_dock_prompt = {
                        "Repair hull (10 reputation)",
                        "Fix hull (10 reputation)",
                        "Restore hull (10 reputation)",
                        "Refurbish hull (10 reputation)",
                    }
                    addCommsReply(tableSelectRandom(repair_hull_fast_dock_prompt),function()
                        if comms_source:takeReputationPoints(10) then
                            comms_source.expedite_dock.hull = true
                            setExpediteDock()
                        else
                            local insufficient_rep_responses = {
                                "Insufficient reputation",
                                "Not enough reputation",
                                "You need more reputation",
                                string.format("You need more than %i reputation",math.floor(comms_source:getReputationPoints())),
                                "You don't have enough reputation",
                            }
                            setCommsMessage(tableSelectRandom(insufficient_rep_responses))
                            addCommsReply(_("station-comms","Back to expedited dock negotiation"),setExpediteDock)
                            addCommsReply(_("station-comms","Back to station communication"),commsStation)
                        end
                    end)
                    service_to_add_count = service_to_add_count + 1
                end
                if comms_source.expedite_dock.probes then
                    if service_list == _("station-comms","Expedited service list:") then
                        service_list = string.format(_("station-comms","%s probes"),service_list)
                    else
                        service_list = string.format(_("station-comms","%s, probes"),service_list)
                    end
                else
                    local restock_probes_fast_dock_prompt = {
                        "Replenish probes (5 reputation)",
                        "Restock probes (5 reputation)",
                        "Refill probes (5 reputation)",
                        "Restore probe inventory (5 reputation)",
                    }
                    addCommsReply(tableSelectRandom(restock_probes_fast_dock_prompt),function()
                        if comms_source:takeReputationPoints(5) then
                            comms_source.expedite_dock.probes = true
                            setExpediteDock()
                        else
                            local insufficient_rep_responses = {
                                "Insufficient reputation",
                                "Not enough reputation",
                                "You need more reputation",
                                string.format("You need more than %i reputation",math.floor(comms_source:getReputationPoints())),
                                "You don't have enough reputation",
                            }
                            setCommsMessage(tableSelectRandom(insufficient_rep_responses))
                            addCommsReply(_("station-comms","Back to expedited dock negotiation"),setExpediteDock)
                            addCommsReply(_("station-comms","Back to station communication"),commsStation)
                        end
                    end)
                    service_to_add_count = service_to_add_count + 1
                end
                if comms_source.expedite_dock.nuke ~= nil then
                    if service_list == _("station-comms","Expedited service list:") then
                        if comms_source.expedite_dock.nuke > 1 then
                            service_list = string.format(_("station-comms","%s %s nukes"),service_list,comms_source.expedite_dock.nuke)
                        else
                            service_list = string.format(_("station-comms","%s one nuke"),service_list)
                        end
                    else
                        if comms_source.expedite_dock.nuke > 1 then
                            service_list = string.format(_("station-comms","%s, %s nukes"),service_list,comms_source.expedite_dock.nuke)
                        else
                            service_list = string.format(_("station-comms","%s, one nuke"),service_list)
                        end
                    end
                else
                    if comms_target.comms_data.weapon_available.Nuke and isAllowedTo(comms_target.comms_data.weapons.Nuke) then
                        local max_nuke = comms_source:getWeaponStorageMax("Nuke")
                        if max_nuke > 0 then
                            local current_nuke = comms_source:getWeaponStorage("Nuke")
                            if current_nuke < max_nuke then
                                local full_nuke = max_nuke - current_nuke
                                local replenish_nukes_fast_dock_prompt = {
                                    string.format("Replenish nukes (%d reputation)",getWeaponCost("Nuke")*full_nuke),
                                    string.format("Restock nukes (%s reputation)",getWeaponCost("Nuke")*full_nuke),
                                    string.format("Refill nukes (%s reputation)",getWeaponCost("Nuke")*full_nuke),
                                    string.format("Refill nukes (%s reputation, %i nuke(s))",getWeaponCost("Nuke")*full_nuke,full_nuke),
                                }
                                addCommsReply(tableSelectRandom(replenish_nukes_fast_dock_prompt),function()
                                    if comms_source:takeReputationPoints(getWeaponCost("Nuke")*full_nuke) then
                                        comms_source.expedite_dock.nuke = full_nuke
                                        setExpediteDock()
                                    else
                                        local insufficient_rep_responses = {
                                            "Insufficient reputation",
                                            "Not enough reputation",
                                            "You need more reputation",
                                            string.format("You need more than %i reputation",math.floor(comms_source:getReputationPoints())),
                                            "You don't have enough reputation",
                                        }
                                        setCommsMessage(tableSelectRandom(insufficient_rep_responses))
                                        addCommsReply(_("station-comms","Back to expedited dock negotiation"),setExpediteDock)
                                        addCommsReply(_("station-comms","Back to station communication"),commsStation)
                                    end
                                end)
                                service_to_add_count = service_to_add_count + 1
                            end
                        end
                    end
                end
                if comms_source.expedite_dock.homing ~= nil then
                    if service_list == _("station-comms","Expedited service list:") then
                        if comms_source.expedite_dock.homing > 1 then
                            service_list = string.format(_("station-comms","%s %s homing missiles"),service_list,comms_source.expedite_dock.homing)
                        else
                            service_list = string.format(_("station-comms","%s one homing missile"),service_list)
                        end
                    else
                        if comms_source.expedite_dock.homing > 1 then
                            service_list = string.format(_("station-comms","%s, %s homing missiles"),service_list,comms_source.expedite_dock.homing)
                        else
                            service_list = string.format(_("station-comms","%s, one homing missile"),service_list)
                        end
                    end
                else
                    if comms_target.comms_data.weapon_available.Homing and isAllowedTo(comms_target.comms_data.weapons.Homing) then
                        local max_homing = comms_source:getWeaponStorageMax("Homing")
                        if max_homing > 0 then
                            local current_homing = comms_source:getWeaponStorage("Homing")
                            if current_homing < max_homing then
                                local full_homing = max_homing - current_homing
                                local refill_homing_fast_dock_prompt = {
                                    string.format("Replenish homing missiles (%d reputation)",getWeaponCost("Homing")*full_homing),
                                    string.format("Restock homing missiles (%d reputation)",getWeaponCost("Homing")*full_homing),
                                    string.format("Refill homing missiles (%d reputation)",getWeaponCost("Homing")*full_homing),
                                    string.format("Restore homing missiles inventory (%d rep)",getWeaponCost("Homing")*full_homing),
                                }
                                addCommsReply(tableSelectRandom(refill_homing_fast_dock_prompt),function()
                                    if comms_source:takeReputationPoints(getWeaponCost("Homing")*full_homing) then
                                        comms_source.expedite_dock.homing = full_homing
                                        setExpediteDock()
                                    else
                                        local insufficient_rep_responses = {
                                            "Insufficient reputation",
                                            "Not enough reputation",
                                            "You need more reputation",
                                            string.format("You need more than %i reputation",math.floor(comms_source:getReputationPoints())),
                                            "You don't have enough reputation",
                                        }
                                        setCommsMessage(tableSelectRandom(insufficient_rep_responses))
                                        addCommsReply(_("station-comms","Back to expedited dock negotiation"),setExpediteDock)
                                        addCommsReply(_("station-comms","Back to station communication"),commsStation)
                                    end
                                end)
                                service_to_add_count = service_to_add_count + 1
                            end
                        end
                    end
                end
                if comms_source.expedite_dock.emp ~= nil then
                    if service_list == _("station-comms","Expedited service list:") then
                        if comms_source.expedite_dock.emp > 1 then
                            service_list = string.format(_("station-comms","%s %s EMP missiles"),service_list,comms_source.expedite_dock.emp)
                        else
                            service_list = string.format(_("station-comms","%s one EMP missile"),service_list)
                        end
                    else
                        if comms_source.expedite_dock.emp > 1 then
                            service_list = string.format(_("station-comms","%s, %s EMP missiles"),service_list,comms_source.expedite_dock.emp)
                        else
                            service_list = string.format(_("station-comms","%s, one EMP missile"),service_list)
                        end
                    end
                else
                    if comms_target.comms_data.weapon_available.EMP and isAllowedTo(comms_target.comms_data.weapons.EMP) then
                        local max_emp = comms_source:getWeaponStorageMax("EMP")
                        if max_emp > 0 then
                            local current_emp = comms_source:getWeaponStorage("EMP")
                            if current_emp < max_emp then
                                local full_emp = max_emp - current_emp
                                local restock_emp_fast_dock_prompt = {
                                    string.format("Replenish EMP missiles (%d reputation)",getWeaponCost("EMP")*full_emp),
                                    string.format("Restock EMP missiles (%d reputation)",getWeaponCost("EMP")*full_emp),
                                    string.format("Refill EMP missiles (%d reputation)",getWeaponCost("EMP")*full_emp),
                                    string.format("Restore EMP missiles inventory (%d rep)",getWeaponCost("EMP")*full_emp),
                                }
                                addCommsReply(tableSelectRandom(restock_emp_fast_dock_prompt),function()
                                    if comms_source:takeReputationPoints(getWeaponCost("EMP")*full_emp) then
                                        comms_source.expedite_dock.emp = full_emp
                                        setExpediteDock()
                                    else
                                        local insufficient_rep_responses = {
                                            "Insufficient reputation",
                                            "Not enough reputation",
                                            "You need more reputation",
                                            string.format("You need more than %i reputation",math.floor(comms_source:getReputationPoints())),
                                            "You don't have enough reputation",
                                        }
                                        setCommsMessage(tableSelectRandom(insufficient_rep_responses))
                                        addCommsReply(_("station-comms","Back to expedited dock negotiation"),setExpediteDock)
                                        addCommsReply(_("station-comms","Back to station communication"),commsStation)
                                    end
                                end)
                                service_to_add_count = service_to_add_count + 1
                            end
                        end
                    end
                end
                if comms_source.expedite_dock.mine ~= nil then
                    if service_list == _("station-comms","Expedited service list:") then
                        if comms_source.expedite_dock.mine > 1 then
                            service_list = string.format(_("station-comms","%s %s mines"),service_list,comms_source.expedite_dock.mine)
                        else
                            service_list = string.format(_("station-comms","%s one mine"),service_list)
                        end
                    else
                        if comms_source.expedite_dock.mine > 1 then
                            service_list = string.format(_("station-comms","%s, %s mines"),service_list,comms_source.expedite_dock.mine)
                        else
                            service_list = string.format(_("station-comms","%s, one mine"),service_list)
                        end
                    end
                else
                    if comms_target.comms_data.weapon_available.Mine and isAllowedTo(comms_target.comms_data.weapons.Mine) then
                        local max_mine = comms_source:getWeaponStorageMax("Mine")
                        if max_mine > 0 then
                            local current_mine = comms_source:getWeaponStorage("Mine")
                            if current_mine < max_mine then
                                local full_mine = max_mine - current_mine
                                local restock_mines_fast_dock_prompt = {
                                    string.format("Replenish mines (%d reputation)",getWeaponCost("Mine")*full_mine),
                                    string.format("Restock mines (%d reputation)",getWeaponCost("Mine")*full_mine),
                                    string.format("Refill mines (%d reputation)",getWeaponCost("Mine")*full_mine),
                                    string.format("Restore inventory of mines (%d rep)",getWeaponCost("Mine")*full_mine),
                                }
                                addCommsReply(tableSelectRandom(restock_mines_fast_dock_prompt),function()
                                    if comms_source:takeReputationPoints(getWeaponCost("Mine")*full_mine) then
                                        comms_source.expedite_dock.mine = full_mine
                                        setExpediteDock()
                                    else
                                        local insufficient_rep_responses = {
                                            "Insufficient reputation",
                                            "Not enough reputation",
                                            "You need more reputation",
                                            string.format("You need more than %i reputation",math.floor(comms_source:getReputationPoints())),
                                            "You don't have enough reputation",
                                        }
                                        setCommsMessage(tableSelectRandom(insufficient_rep_responses))
                                        addCommsReply(_("station-comms","Back to expedited dock negotiation"),setExpediteDock)
                                        addCommsReply(_("station-comms","Back to station communication"),commsStation)
                                    end
                                end)
                                service_to_add_count = service_to_add_count + 1
                            end
                        end
                    end
                end
                if comms_source.expedite_dock.hvli ~= nil then
                    if service_list == _("station-comms","Expedited service list:") then
                        if comms_source.expedite_dock.hvli > 1 then
                            service_list = string.format(_("station-comms","%s %s HVLI missiles"),service_list,comms_source.expedite_dock.hvli)
                        else
                            service_list = string.format(_("station-comms","%s one HVLI missile"),service_list)
                        end
                    else
                        if comms_source.expedite_dock.hvli > 1 then
                            service_list = string.format(_("station-comms","%s, %s HVLI missiles"),service_list,comms_source.expedite_dock.hvli)
                        else
                            service_list = string.format(_("station-comms","%s, one HVLI missile"),service_list)
                        end
                    end
                else
                    if comms_target.comms_data.weapon_available.HVLI and isAllowedTo(comms_target.comms_data.weapons.HVLI) then
                        local max_hvli = comms_source:getWeaponStorageMax("HVLI")
                        if max_hvli > 0 then
                            local current_hvli = comms_source:getWeaponStorage("HVLI")
                            if current_hvli < max_hvli then
                                local full_hvli = max_hvli - current_hvli
                                local refill_hvli_quick_dock_prompt = {
                                    string.format("Replenish HVLI missiles (%d reputation)",getWeaponCost("HVLI")*full_hvli),
                                    string.format("Restock HVLI missiles (%d reputation)",getWeaponCost("HVLI")*full_hvli),
                                    string.format("Refill HVLI missiles (%d reputation)",getWeaponCost("HVLI")*full_hvli),
                                    string.format("Restore HVLI missiles inventory (%d rep)",getWeaponCost("HVLI")*full_hvli),
                                }
                                addCommsReply(tableSelectRandom(refill_hvli_quick_dock_prompt),function()
                                    if comms_source:takeReputationPoints(getWeaponCost("HVLI")*full_hvli) then
                                        comms_source.expedite_dock.hvli = full_hvli
                                        setExpediteDock()
                                    else
                                        local insufficient_rep_responses = {
                                            "Insufficient reputation",
                                            "Not enough reputation",
                                            "You need more reputation",
                                            string.format("You need more than %i reputation",math.floor(comms_source:getReputationPoints())),
                                            "You don't have enough reputation",
                                        }
                                        setCommsMessage(tableSelectRandom(insufficient_rep_responses))
                                        addCommsReply(_("station-comms","Back to expedited dock negotiation"),setExpediteDock)
                                        addCommsReply(_("station-comms","Back to station communication"),commsStation)
                                    end
                                end)
                                service_to_add_count = service_to_add_count + 1
                            end
                        end
                    end
                end
                if comms_source.expedite_dock.repair_crew then
                    if service_list == _("station-comms","Expedited service list:") then
                        service_list = string.format(_("station-comms","%s one repair crew"),service_list)
                    else
                        service_list = string.format(_("station-comms","%s, one repair crew"),service_list)
                    end
                else
                    if comms_target.comms_data.available_repair_crew == nil then
                        comms_target.comms_data.available_repair_crew = math.random(0,5)
                        comms_target.comms_data.available_repair_crew_cost_friendly_needy_over_66 = math.random(30,60)
                        comms_target.comms_data.available_repair_crew_cost_neutral_needy_over_66 = math.random(45,90)
                        comms_target.comms_data.available_repair_crew_cost_excess = math.random(15,30)
                        comms_target.comms_data.available_repair_crew_cost_under_66 = math.random(15,30)
                    end
                    if comms_target.comms_data.available_repair_crew > 0 then    --station has repair crew available
                        local hire_cost = 0
                        if comms_source:isFriendly(comms_target) then
                            hire_cost = comms_target.comms_data.available_repair_crew_cost_friendly_needy_over_66
                        else
                            hire_cost = comms_target.comms_data.available_repair_crew_cost_neutral_needy_over_66
                        end
                        if comms_target.comms_data.friendlyness <= 66 then
                            hire_cost = hire_cost + comms_target.comms_data.available_repair_crew_cost_under_66
                        end
                        if comms_source:getRepairCrewCount() >= comms_source.maxRepairCrew then
                            hire_cost = hire_cost + comms_target.comms_data.available_repair_crew_cost_excess
                        end
                        local hire_repair_crew_fast_dock_prompt = {
                            string.format("Hire one repair crew (%d reputation)",hire_cost),
                            string.format("Add to repair crew (%d reputation)",hire_cost),
                            string.format("Hire additional repair crew (%d reputation)",hire_cost),
                            string.format("Get one repair crew (%d reputation)",hire_cost),
                        }
                        addCommsReply(tableSelectRandom(hire_repair_crew_fast_dock_prompt),function()
                            local hire_cost = 0
                            if comms_source:isFriendly(comms_target) then
                                hire_cost = comms_target.comms_data.available_repair_crew_cost_friendly_needy_over_66
                            else
                                hire_cost = comms_target.comms_data.available_repair_crew_cost_neutral_needy_over_66
                            end
                            if comms_target.comms_data.friendlyness <= 66 then
                                hire_cost = hire_cost + comms_target.comms_data.available_repair_crew_cost_under_66
                            end
                            if comms_source:getRepairCrewCount() >= comms_source.maxRepairCrew then
                                hire_cost = hire_cost + comms_target.comms_data.available_repair_crew_cost_excess
                            end
                            if comms_source:takeReputationPoints(hire_cost) then
                                comms_source.expedite_dock.repair_crew = true
                                setExpediteDock()
                            else
                                local insufficient_rep_responses = {
                                    "Insufficient reputation",
                                    "Not enough reputation",
                                    "You need more reputation",
                                    string.format("You need more than %i reputation",math.floor(comms_source:getReputationPoints())),
                                    "You don't have enough reputation",
                                }
                                setCommsMessage(tableSelectRandom(insufficient_rep_responses))
                                addCommsReply(_("station-comms","Back to expedited dock negotiation"),setExpediteDock)
                                addCommsReply(_("station-comms","Back to station communication"),commsStation)
                            end
                        end)
                        service_to_add_count = service_to_add_count + 1
                    end
                end
                if comms_source.expedite_dock.coolant then
                    if service_list == _("station-comms","Expedited service list:") then
                        service_list = string.format(_("station-comms","%s add coolant"),service_list)
                    else
                        service_list = string.format(_("station-comms","%s, add coolant"),service_list)
                    end
                else
                    if comms_target.comms_data.coolant_inventory == nil then
                        comms_target.comms_data.coolant_inventory = math.random(0,5)*2
                        comms_target.comms_data.coolant_inventory_cost_friendly_needy_over_66 = math.random(30,60)
                        comms_target.comms_data.coolant_inventory_cost_neutral_needy_over_66 = math.random(45,90)
                        comms_target.comms_data.coolant_inventory_excess = math.random(15,30)
                        comms_target.comms_data.coolant_inventory_under_66 = math.random(15,30)
                    end
                    if comms_target.comms_data.coolant_inventory > 0 then
                        local coolant_cost = 0
                        if comms_source:isFriendly(comms_target) then
                            coolant_cost = comms_target.comms_data.coolant_inventory_cost_friendly_needy_over_66
                        else
                            coolant_cost = comms_target.comms_data.coolant_inventory_cost_neutral_needy_over_66
                        end
                        if comms_target.comms_data.friendlyness <= 66 then
                            coolant_cost = coolant_cost + comms_target.comms_data.coolant_inventory_under_66
                        end
                        if comms_source:getMaxCoolant() >= comms_source.initialCoolant then
                            coolant_cost = coolant_cost + comms_target.comms_data.coolant_inventory_excess
                        end
                        local get_coolant_fast_dock_prompt = {
                            string.format("Get additional coolant (%d rep)",coolant_cost),
                            string.format("Get more coolant (%d rep)",coolant_cost),
                            string.format("Add coolant (%d rep)",coolant_cost),
                            string.format("Acquire coolant (%d rep)",coolant_cost),
                        }
                        addCommsReply(tableSelectRandom(get_coolant_fast_dock_prompt),function()
                            local coolant_cost = 0
                            if comms_source:isFriendly(comms_target) then
                                coolant_cost = comms_target.comms_data.coolant_inventory_cost_friendly_needy_over_66
                            else
                                coolant_cost = comms_target.comms_data.coolant_inventory_cost_neutral_needy_over_66
                            end
                            if comms_target.comms_data.friendlyness <= 66 then
                                coolant_cost = coolant_cost + comms_target.comms_data.coolant_inventory_under_66
                            end
                            if comms_source:getMaxCoolant() >= comms_source.initialCoolant then
                                coolant_cost = coolant_cost + comms_target.comms_data.coolant_inventory_excess
                            end
                            if comms_source:takeReputationPoints(coolant_cost) then
                                comms_source.expedite_dock.coolant = true
                                setExpediteDock()
                            else
                                local insufficient_rep_responses = {
                                    "Insufficient reputation",
                                    "Not enough reputation",
                                    "You need more reputation",
                                    string.format("You need more than %i reputation",math.floor(comms_source:getReputationPoints())),
                                    "You don't have enough reputation",
                                }
                                setCommsMessage(tableSelectRandom(insufficient_rep_responses))
                                addCommsReply(_("station-comms","Back to expedited dock negotiation"),setExpediteDock)
                                addCommsReply(_("station-comms","Back to station communication"),commsStation)
                            end
                        end)
                        service_to_add_count = service_to_add_count + 1
                    end
                end
                if service_to_add_count > 0 then
                    local more_services_addendum = {
                        "Would you like some additional expedited docking services?",
                        "Do you want to expedite another service?",
                        "Would you like to add to your list of expedited services?",
                        "How about another expedited service?",
                    }
                    if service_list == _("station-comms","Expedited service list:") then
                        out = string.format("%s\n%s",out,tableSelectRandom(more_services_addendum))
                    else
                        out = string.format("%s\n%s.\n%s",out,service_list,tableSelectRandom(more_services_addendum))
                    end
                else
                    local no_more_services_addendum = {
                        "There are no additional expedited docking services available.",
                        "There are no more expeditable services available.",
                        "We cannot expedite any more services.",
                        "No more services are available for fast dock.",
                    }
                    if service_list == _("station-comms","Expedited service list:") then
                        out = string.format("%s\n%s",out,tableSelectRandom(no_more_services_addendum))
                    else
                        out = string.format("%s\n%s.\n%s",out,service_list,tableSelectRandom(no_more_services_addendum))
                    end
                end
                setCommsMessage(out)
                addCommsReply(_("Back"), commsStation)
            end
        end
    end
end--]]
function commercialOptions(calling_function)
    --    goods, passengers, residents' cargo, other stations
    local commercial_options_prompt = {
        string.format("Investigate commercial options at %s",comms_target:getCallSign()),
        string.format("Look into %s commercial options",comms_target:getCallSign()),
        string.format("Check out %s commercial options",comms_target:getCallSign()),
        string.format("Explore commercial options at %s",comms_target:getCallSign()),
    }
    addCommsReply(tableSelectRandom(commercial_options_prompt),function()
        local good_sale_count = 0
        local good_sale_list = ""
        for good, good_data in pairs(comms_target.comms_data.goods) do
            if good_data.quantity ~= nil and good_data.quantity > 0 then
                good_sale_count = good_sale_count + 1
                if good_sale_list == "" then
                    good_sale_list = good_desc[good]
                else
                    good_sale_list = string.format("%s, %s",good_sale_list,good_desc[good])
                end
            end
        end
        local out = ""
        if good_sale_count > 0 then
            out = string.format(_("station-comms","We sell goods (%s)."),good_sale_list)
            local buy_prompt = {
                string.format("Buy %s",good_sale_list),
                string.format("Buy %s info",good_sale_list),
                string.format("Buy %s details",good_sale_list),
                string.format("Buy %s report",good_sale_list),
            }
            addCommsReply(tableSelectRandom(buy_prompt),function()
                local sell_header = {
                    "Goods for sale (good name, quantity, reputation cost):",
                    string.format("List of goods being sold by %s:\n(good name, quantity, reputation cost)",comms_target:getCallSign()),
                    string.format("%s sells these goods:\n(good name, quantity, reputation cost)",comms_target:getCallSign()),
                    string.format("You can buy these goods at %s:\n(good name, quantity, reputation cost)",comms_target:getCallSign()),
                }
                local sell_out = tableSelectRandom(sell_header)
                for good, good_data in pairs(comms_target.comms_data.goods) do
                    sell_out = string.format("%s\n%s, %s, %s",sell_out,good_desc[good],good_data.quantity,good_data.cost)
                end
                setCommsMessage(sell_out)
                addCommsReply(string.format("Back to %s",calling_function.name),calling_function.identifier)
                addCommsReply(_("station-comms","Back to station communication"),commsStation)
            end)
        end
        if comms_target.comms_data.buy ~= nil then
            local good_buy_list = ""
            local match_good_buy_list = ""
            for good, price in pairs(comms_target.comms_data.buy) do
                if good_buy_list == "" then
                    good_buy_list = good_desc[good]
                else
                    string.format("%s, %s",good_buy_list,good_desc[good])
                end
                if comms_source.goods ~= nil and comms_source.goods[good] ~= nil and comms_source.goods[good] > 0 then
                    if match_good_buy_list == "" then
                        match_good_buy_list = good_desc[good]
                    else
                        match_good_buy_list = string.format("%s, %s",match_good_buy_list,good_desc[good])
                    end
                end
            end
            if out == "" then
                out = string.format(_("station-comms","We buy goods (%s)."),good_buy_list)
            else
                out = string.format(_("station-comms","%s We buy goods (%s)."),out,good_buy_list)
            end
            local sell_prompt = {
                string.format("Sell %s",good_buy_list),
                string.format("Sell %s info",good_buy_list),
                string.format("Sell %s details",good_buy_list),
                string.format("Sell %s report",good_buy_list),
            }
            addCommsReply(tableSelectRandom(sell_prompt),function()
                local buy_header = {
                    string.format("Goods station %s will buy (good name, reputation):",comms_target:getCallSign()),
                    string.format("List of goods %s will buy:\n(good name, reputation)",comms_target:getCallSign()),
                    string.format("%s will buy these goods:\n(good name, reputation)",comms_target:getCallSign()),
                    string.format("You can sell these goods to %s:(good name, reputation)",comms_target:getCallSign()),
                }
                local buy_out = tableSelectRandom(buy_header)
                for good, price in pairs(comms_target.comms_data.buy) do
                    buy_out = string.format("%s\n%s, %s",buy_out,good_desc[good],price)
                end
                if match_good_buy_list == "" then
                    local no_matching_good_addendum = {
                        "You do not have any matching goods in your cargo hold.",
                        "Nothing in your cargo hold matches what they want.",
                        string.format("You have nothing in your cargo hold that %s wants",comms_target:getCallSign()),
                        string.format("%s is not interested in anything in your cargo hold",comms_target:getCallSign()),
                    }
                    buy_out = string.format("%s\n\n%s",buy_out,tableSelectRandom(no_matching_good_addendum))
                else
                    local matching_good_addendum = {
                        "Matching goods in your cargo hold",
                        string.format("%s would buy these goods",comms_target:getCallSign()),
                        string.format("This cargo matches %s's interests",comms_target:getCallSign()),
                        string.format("%s is interested in this cargo",comms_target:getCallSign()),
                    }
                    buy_out = string.format("%s\n\n%s: %s",buy_out,tableSelectRandom(matching_good_addendum),match_good_buy_list)
                end
                setCommsMessage(buy_out)
                addCommsReply(string.format("Back to %s",calling_function.name),calling_function.identifier)
                addCommsReply(_("station-comms","Back to station communication"),commsStation)
            end)
        end
        local trade_good_list = ""
        if comms_target.comms_data.trade ~= nil then
            if comms_target.comms_data.trade.food then
                trade_good_list = good_desc["food"]
            end
            if comms_target.comms_data.trade.medicine then
                if trade_good_list == "" then
                    trade_good_list = good_desc["medicine"]
                else
                    trade_good_list = string.format("%s, %s",trade_good_list,good_desc["medicine"])
                end
            end
            if comms_target.comms_data.trade.luxury then
                if trade_good_list == "" then
                    trade_good_list = good_desc["luxury"]
                else
                    trade_good_list = string.format("%s, %s",trade_good_list,good_desc["luxury"])
                end
            end
        end
        if trade_good_list ~= "" then
            if out == "" then
                out = string.format(_("station-comms","We trade our goods for %s."),trade_good_list)
            else
                out = string.format(_("station-comms","%s We trade our goods for %s."),out,trade_good_list)
            end
        end
        local transport_mission_available = false
        if comms_source.transport_mission == nil then
            transport_mission_available = true
        else
            if comms_source.transport_mission.destination == nil or not comms_source.transport_mission.destination:isValid() then
                transport_mission_available = true
            end
        end
        if transport_mission_available and #comms_target.characters > 0 then
            if out == "" then
                out = _("station-comms","We have potential passengers.")
            else
                out = string.format(_("station-comms","%s We have potential passengers."),out)
            end
        end
        local cargo_mission_available = false
        if comms_source.cargo_mission == nil then
            if comms_target.residents ~= nil and #comms_target.residents > 0 then
                cargo_mission_available = true
            end
        else
            if comms_source.cargo_mission.loaded then
                if comms_source.cargo_mission.destination == nil or not comms_source.cargo_mission.destination:isValid() then
                    cargo_mission_available = true
                end
            else
                if comms_source.cargo_mission.origin == nil or not comms_source.cargo_mission.origin:isValid() then
                    cargo_mission_available = true
                end
            end
        end
        if cargo_mission_available then
            local resident_list = ""
            for i,resident in ipairs(comms_target.residents) do
                if resident_list == "" then
                    resident_list = resident
                else
                    resident_list = string.format("%s, %s",resident_list,resident)
                end
            end
            if out == "" then
                if #comms_target.residents > 1 then
                    out = string.format(_("station-comms","We have residents (%s) wishing to transport cargo."),resident_list)
                else
                    out = string.format(_("station-comms","We have a resident (%s) wishing to transport cargo."),resident_list)
                end
            else
                if #comms_target.residents > 1 then
                    out = string.format(_("station-comms","%s We have residents (%s) wishing to transport cargo."),out,resident_list)
                else
                    out = string.format(_("station-comms","%s We have a resident (%s) wishing to transport cargo."),out,resident_list)
                end
            end
        end
        if out == "" then
            local no_commerce_here = {
                "No commerce options here.",
                "There are no commercial options here.",
                "There's nothing here of commercial interest.",
                "Nothing commercially interesting here.",
            }
            setCommsMessage(tableSelectRandom(no_commerce_here))
        else
            local interest_query_addendum = {
                "What are you interested in?",
                "Does any of this interest you?",
                "See anything interesting?",
                "Are any of these commercial ventures interesting?",
            }
            setCommsMessage(string.format("%s\n%s",out,tableSelectRandom(interest_query_addendum)))
        end
        local external_commerce = {
            "What about commerce options at other stations?",
            "Do you know of commercial options at other stations?",
            "Tell me about commercial ventures at other stations",
            "How about commerce at other stations?",
        }
        addCommsReply(tableSelectRandom(external_commerce),function()
            setCommsMessage("Other stations?")
            if comms_target.comms_data.friendlyness > 66 then
                if comms_target.comms_data.other_station_commerce == nil then
                    local station_pool = {}
                    for i,station in ipairs(regionStations) do
                        if station ~= nil and station:isValid() and station ~= comms_target and not station:isEnemy(comms_source) then
                            local station_type = station:getTypeName()
                            if station_type == "Small Station" or station_type == "Medium Station" or station_type == "Large Station" or station_type == "Huge Station" then
                                table.insert(station_pool,station)
                            end
                        end
                    end
                    comms_target.comms_data.other_station_commerce = {}
                    table.insert(comms_target.comms_data.other_station_commerce,tableSelectRandom(station_pool))
                    if comms_target.comms_data.friendlyness > 70 then
                        table.insert(comms_target.comms_data.other_station_commerce,tableSelectRandom(station_pool))
                    end
                    if comms_target.comms_data.friendlyness > 80 then
                        table.insert(comms_target.comms_data.other_station_commerce,tableSelectRandom(station_pool))
                    end
                    if comms_target.comms_data.friendlyness > 90 then
                        table.insert(comms_target.comms_data.other_station_commerce,tableSelectRandom(station_pool))
                    end
                    if comms_target.comms_data.friendlyness > 95 then
                        table.insert(comms_target.comms_data.other_station_commerce,tableSelectRandom(station_pool))
                    end
                end
                local other_stations = ""
                for i,station in ipairs(comms_target.comms_data.other_station_commerce) do
                    if station ~= nil and station:isValid() then
                        local good_sale_count = 0
                        local good_sale_list = ""
                        local this_station = ""
                        for good, good_data in pairs(station.comms_data.goods) do
                            if good_data.quantity ~= nil and good_data.quantity > 0 then
                                good_sale_count = good_sale_count + 1
                                if good_sale_list == "" then
                                    good_sale_list = good_desc[good]
                                else
                                    good_sale_list = string.format("%s, %s",good_sale_list,good_desc[good])
                                end
                            end
                        end
                        if good_sale_count > 0 then
                            this_station = string.format(_("station-comms","%s in %s sells %s"),station:getCallSign(),station:getSectorName(),good_sale_list)
                        end
                        if station.comms_data.buy ~= nil then
                            local good_buy_list = ""
                            local match_good_buy_list = ""
                            for good, price in pairs(station.comms_data.buy) do
                                if good_buy_list == "" then
                                    good_buy_list = good_desc[good]
                                else
                                    string.format("%s, %s",good_buy_list,good_desc[good])
                                end
                                if comms_source.goods ~= nil and comms_source.goods[good] ~= nil and comms_source.goods[good] > 0 then
                                    if match_good_buy_list == "" then
                                        match_good_buy_list = good_desc[good]
                                    else
                                        match_good_buy_list = string.format("%s, %s",match_good_buy_list,good_desc[good])
                                    end
                                end
                            end
                            if this_station == "" then
                                this_station = string.format(_("station-comms","%s in %s buys %s"),station:getCallSign(),station:getSectorName(),good_buy_list)
                                if match_good_buy_list == "" then
                                    this_station = string.format(_("station-comms","%s (none in cargo hold)"),this_station)
                                else
                                    this_station = string.format(_("station-comms","%s (%s in cargo hold)"),this_station,match_good_buy_list)
                                end
                            else
                                this_station = string.format(_("station-comms","%s and buys %s"),this_station,good_buy_list)
                                if match_good_buy_list == "" then
                                    this_station = string.format(_("station-comms","%s (none in cargo hold)"),this_station)
                                else
                                    this_station = string.format(_("station-comms","%s (%s in cargo hold)"),this_station,match_good_buy_list)
                                end
                            end
                        end
                        local other_commerce_header = {
                            "This is what I know about commerce options at other stations:",
                            "Here's what I know about commerce at other stations:",
                            "My knowledge of commercial ventures at other stations consists of:",
                            "Here's my summation of what you can find in the way of commerce at other stations:",
                        }
                        if this_station == "" then
                            if other_stations == "" then
                                other_stations = string.format("%s\n%s in %s does not buy or sell goods.",tableSelectRandom(other_commerce_header),station:getCallSign(),station:getSectorName())
                            else
                                other_stations = string.format(_("station-comms","%s\n%s in %s does not buy or sell goods."),other_stations,station:getCallSign(),station:getSectorName())
                            end
                        else
                            if other_stations == "" then
                                other_stations = string.format("%s\n%s",tableSelectRandom(other_commerce_header),this_station)
                            else
                                other_stations = string.format("%s\n%s.",other_stations,this_station)
                            end
                        end
                    end
                end
                if other_stations == "" then
                    local commercially_clueless = {
                        "I don't know about commerce options at other stations.",
                        "I know nothing about commercial options anywhere else.",
                        string.format("I only know about %s. Other stations are too far away.",comms_target:getCallSign()),
                        string.format("My knowledge does not extend beyond %s.",comms_target:getCallSign()),
                    }
                    setCommsMessage(tableSelectRandom(commercially_clueless))
                else
                    setCommsMessage(other_stations)
                end
            else
                local commercially_clueless = {
                    "I don't know about commerce options at other stations.",
                    "I know nothing about commercial options anywhere else.",
                    string.format("I only know about %s. Other stations are too far away.",comms_target:getCallSign()),
                    string.format("My knowledge does not extend beyond %s.",comms_target:getCallSign()),
                }
                setCommsMessage(tableSelectRandom(commercially_clueless))
            end
            addCommsReply(string.format("Back to %s",calling_function.name),calling_function.identifier)
            addCommsReply(_("station-comms","Back to station communication"),commsStation)
        end)
        addCommsReply(string.format("Back to %s",calling_function.name),calling_function.identifier)
        addCommsReply(_("station-comms","Back to station communication"),commsStation)
    end)
end
--    circumstantial comms
--[[ REMOVE
function magnasolHeatDiscussion(calling_function)
    local magnasol_protection_prompt = {
        "How can I protect my ship from Magnasol heat?",
        "What can I do about heat from Magnasol?",
        string.format("How can I reduce the heat from Magnasol on %s",comms_source:getCallSign()),
        string.format("Magnasol is roasting %s! What can we do?",comms_source:getCallSign()),
    }
    addCommsReply(tableSelectRandom(magnasol_protection_prompt),function()
        local several_heat_ways = {
            "There are several ways. Which one are you interested in?",
            "You have a few options. Which one interests you?",
            "Which of these heat reduction options are you interested in?",
            "You can reduce Magnasol heat in a number of ways",
        }
        setCommsMessage(tableSelectRandom(several_heat_ways))
        local shields_duh = {
            "Activate shields",
            "Turn on shields",
            "Your shields can help",
            "Raise shields",
        }
        addCommsReply(tableSelectRandom(shields_duh),function()
            local shield_heat_response = {
                "If your shields are active, that cuts out about half the heat that Magnasol emits",
                "Raising your shields cuts Magnasol's heat impact in half",
                "If you put up your shields you'll find that Magnasol's heat is reduced by about half",
                "Your shields protect you from about half of Magnasol's heat impact",
            }
            setCommsMessage(tableSelectRandom(shield_heat_response))
            addCommsReply(string.format("Back to %s",calling_function.name),calling_function.identity)
            addCommsReply("Back to station communication", commsStation)
        end)
        local run_away_prompt = {
            "Increase your distance from Magnasol",
            "Get further away from Magnasol",
            "Keep your distance from Magnasol",
            "Stay away from Magnasol",
        }
        addCommsReply(tableSelectRandom(run_away_prompt),function()
            local distance_explained = {
                "The further you are away from Magnasol, the less impact it has on the heat of your systems. The closer, the hotter.",
                string.format("The closer %s gets to Magnasol, the hotter the heat. Conversely, the farther %s is from Magnasol, the less the heat applies.",comms_source:getCallSign(),comms_source:getCallSign()),
                "The farther away you are from Magnasol, the less its heat impacts your ship systems.",
                string.format("Move %s 100 units or more away from Magnasol and the heat impact goes away. The closer you are to Magnasol, though, the more the heat impacts %s",comms_source:getCallSign(),comms_source:getCallSign()),
            }
            setCommsMessage(tableSelectRandom(distance_explained))
            addCommsReply(string.format("Back to %s",calling_function.name),calling_function.identity)
            addCommsReply("Back to station communication", commsStation)
        end)
        local get_coolant_additive_prompt = {
            "Get coolant additive",
            "Improve coolant performance",
            "Add performance booster to coolant",
            "Invest in better coolant",
        }
        addCommsReply(tableSelectRandom(get_coolant_additive_prompt),function()
            local coolant_additive_explained = {
                "Each station in the area is continually coming up with different concoctions that can be mixed with coolant to make the coolant more effective against Magnasol's radiance. These concoctions vary in their effectiveness and in the duration of their effectiveness.",
                "The stations continue to experiment with coolant additives to help protect against Magnasol's radiance. These experimental concoctions vary in their effectiveness and their duration.",
                "You could try some of the coolant concoctions the stations around here have been working on. The concoctions vary in duration and effectiveness, so they are a temporary but fairly effective solution to Magnasol's heat impact.",
                "The stations that send ships out to work in this heat continue to experiment with coolant additives to reduce the heat impact from Magnasol. The additives vary in terms of effectiveness and duration, but represent a reasonable short term solution.",
            }
            setCommsMessage(tableSelectRandom(coolant_additive_explained))
            local try_additive_prompt = {
                "Do you have one of these coolant additives we could try?",
                "I don't suppose you have a coolant additive for us?",
                "Is there a coolant additive concoction available here?",
                "Have you experimented? If so, can we try your additive?",
            }
            addCommsReply(tableSelectRandom(try_additive_prompt),function()
                if comms_target.comms_data.coolant_additive == nil then
                    local duration_list = {
                        {value = 2, desc = "a couple of"},
                        {value = 5, desc = "a few"},
                        {value = 10, desc = "about ten"},
                    }
                    local duration = duration_list[math.random(1,3)]
                    comms_target.comms_data.coolant_additive = {
                        ["effectiveness"] = math.random(1,3),
                        ["duration"] = duration.value,
                        ["desc"] = duration.desc,
                        ["exchange"] = mineralGoods[math.random(1,#mineralGoods)],
                    }
                end
                local coolant_additive_offer = {
                    string.format("We've got a batch of coolant additive that's level %i effective (the higher the level, the better) that'll last %s minutes. We'll provide you some in exchange for %s.",comms_target.comms_data.coolant_additive.effectiveness,comms_target.comms_data.coolant_additive.desc,comms_target.comms_data.coolant_additive.exchange),
                    string.format("We've got some %i level effective coolant additive. The higher the level, the greater the effectiveness. It lasts %s minutes. If you provide us with %s, we'll provide some for you.",comms_target.comms_data.coolant_additive.effectiveness,comms_target.comms_data.coolant_additive.desc,comms_target.comms_data.coolant_additive.exchange),
                    string.format("We'll give you some level %i coolant additive for some %s. It lasts about %s minutes. The greater the level, the more effective the additive, btw.",comms_target.comms_data.coolant_additive.effectiveness,comms_target.comms_data.coolant_additive.exchange,comms_target.comms_data.coolant_additive.desc),
                    string.format("In exchange for %s we can provide our coolant additive which lasts %s minutes and is rated at %i effective (the higher the rating the more effective",comms_target.comms_data.coolant_additive.exchange,comms_target.comms_data.coolant_additive.desc,comms_target.comms_data.coolant_additive.effectiveness),
                }
                setCommsMessage(tableSelectRandom(coolant_additive_offer))
                if comms_source:isDocked(comms_target) then
                    local get_additive = {
                        "That would be great. We'll take some",
                        "Sounds good, Can we get some?",
                        "We could use that. This heat is bad",
                        "We want to try some of your additive",
                    }
                    addCommsReply(tableSelectRandom(get_additive),function()
                        local exchange_good = comms_target.comms_data.coolant_additive.exchange
                        local function injectCoolantAdditive(exchange_good)
                            local need_good_for_additive = {
                                string.format("We'll need %s before we can provide the coolant additive",exchange_good),
                                string.format("You must provide us with %s before we can provide you the cooland booster",exchange_good),
                                string.format("We will provide you with the coolant additive after you provide us with %s",exchange_good),
                                string.format("Nice try. We need %s before we can give you the coolant booster",exchange_good),
                            }
                            if comms_source.goods ~= nil then
                                if comms_source.goods[exchange_good] ~= nil and comms_source.goods[exchange_good] > 0 then
                                    comms_source.goods[exchange_good] = comms_source.goods[exchange_good] - 1
                                    comms_source.coolant_additive = {
                                        ["effectiveness"] = comms_target.comms_data.coolant_additive.effectiveness,
                                        ["expires"] = comms_target.comms_data.coolant_additive.duration*60 + getScenarioTime(),
                                    }
                                    comms_source.coolant_additive_button_eng = "coolant_additive_button_eng"
                                    comms_source:addCustomButton("Engineering",comms_source.coolant_additive_button_eng,"Check Additive",function()
                                        string.format("")
                                        comms_source.coolant_additive_msg_eng = "coolant_additive_msg_eng"
                                        print("expires:",comms_source.coolant_additive.expires)
                                        if comms_source.coolant_additive.expires > getScenarioTime() then
                                            comms_source:addCustomMessage("Engineering",comms_source.coolant_additive_msg_eng,"Additive has dissipated")
                                            comms_source:removeCustom(comms_source.coolant_additive_button_eng)
                                        else
                                            comms_source:addCustomMessage("Engineering",comms_source.coolant_additive_msg_eng,string.format("Additive functioning.\nEffectiveness level %s.\nExpected remaining duration: %i seconds",comms_source.coolant_additive.effectiveness,math.floor(comms_source.coolant_additive.expires - getScenarioTime())))
                                        end
                                    end,41)
                                    comms_source.coolant_additive_button_plus = "coolant_additive_button_plus"
                                    comms_source:addCustomButton("Engineering+",comms_source.coolant_additive_button_plus,"Check Additive",function()
                                        string.format("")
                                        comms_source.coolant_additive_msg_eng = "coolant_additive_msg_eng"
                                        if comms_source.coolant_additive.expires > getScenarioTime() then
                                            comms_source:addCustomMessage("Engineering+",comms_source.coolant_additive_msg_eng,"Additive has dissipated")
                                            comms_source:removeCustom(comms_source.coolant_additive_button_plus)
                                        else
                                            comms_source:addCustomMessage("Engineering+",comms_source.coolant_additive_msg_eng,string.format("Additive functioning.\nEffectiveness level %s.\nExpected remaining duration: %i seconds",comms_source.coolant_additive.effectiveness,math.floor(comms_source.coolant_additive.expires - getScenarioTime())))
                                        end
                                    end,41)
                                    local added_to_coolant_response = {
                                        string.format("Thanks for the %s. We've injected the coolant additive into your coolant system",exchange_good),
                                        string.format("In exchange for %s, we have added our experimental compound into your coolant system",exchange_good),
                                        string.format("The %s will be useful, thanks. Hopefully, our coolant booster will be useful. It's been added to your coolant",exchange_good),
                                        string.format("For the %s you provided, we have added our flavor of coolant booster to your coolant system.",exchange_good),
                                    }
                                    setCommsMessage(tableSelectRandom(added_to_coolant_response))
                                else
                                    setCommsMessage(tableSelectRandom(need_good_for_additive))
                                end
                            else
                                setCommsMessage(tableSelectRandom(need_good_for_additive))
                            end
                        end
                        if comms_source.coolant_additive == nil then
                            injectCoolantAdditive(exchange_good)
                        else
                            if comms_source.coolant_additive.expires ~= nil and comms_source.coolant_additive.expires < getScenarioTime() then
                                local one_additive_at_a_time = {
                                    "You've already got a coolant additive. These things don't mix well. We've seen ships explode when they try to mix coolant additives. You'll have to wait until your current coolant additive dissipates",
                                    "Do you want to destroy your ship? You need to wait until your current coolant additive runs out before trying another or your ship will very likely explode",
                                    "We can't give you another coolant additive until your current coolant additive expires. Ships have blown up taking stations with them when these coolant boosters were combined.",
                                    "We are not going to put this additive in while your current one is still in effect. That could blow up your ship and the station, too",
                                }
                                setCommsMessage(tableSelectRandom(one_additive_at_a_time))
                            else
                                injectCoolantAdditive(exchange_good)
                            end
                        end
                        addCommsReply(string.format("Back to %s",calling_function.name),calling_function.identity)
                        addCommsReply("Back to station communication", commsStation)
                    end)
                end
                addCommsReply(string.format("Back to %s",calling_function.name),calling_function.identity)
                addCommsReply("Back to station communication", commsStation)
            end)
            addCommsReply(string.format("Back to %s",calling_function.name),calling_function.identity)
            addCommsReply("Back to station communication", commsStation)
        end)
    end)
end
function riptideHossenfelderDiscussion(calling_function)
    local info_on_riptide = {
        "I need information on this region",
        "Tell me about this region",
        string.format("I need to know about the area around %s",comms_target:getCallSign()),
        string.format("What can you tell me about %s's environment",comms_target:getCallSign()),
    }
    addCommsReply(tableSelectRandom(info_on_riptide),function()
        local psamtik_info = {
            string.format("%s is currently in sector %s (Lagrange point 2). It houses the Arlenian Xenobiology Institute.",psamtikStation:getCallSign(),psamtikStation:getSectorName()),
            string.format("At Lagrange point 2 you'll find %s (currently in sector %s). %s hosts the Arlenian Xenobiology Institute.",psamtikStation:getCallSign(),psamtikStation:getSectorName(),psamtikStation:getCallSign()),
            string.format("The home of the Arlenian Xenobiology Institute is on %s in sector %s (Lagrange point 2).",psamtikStation:getCallSign(),psamtikStation:getSectorName()),
            string.format("You can find the Arlenian Xenobiology Institute on %s in sector %s (Lagrange point 2).",psamtikStation:getCallSign(),psamtikStation:getSectorName()),
        }
        local wormhole_to_Icarus = {
            string.format("The wormhole leading back to Icarus is currently in sector %s (Lagrange point 3).",riptideToIcarusWormHole:getSectorName()),
            string.format("The quickest path to Icarus is via the wormhole currently in sector %s (Lagrange point 3).",riptideToIcarusWormHole:getSectorName()),
            string.format("At Lagrange point 3 is the wormhole leading back to Icarus (currently in sector %s).",riptideToIcarusWormHole:getSectorName()),
            string.format("The wormhole at Lagrange point 3 is the fastest way to Icarus. It's currently in sector %s.",riptideToIcarusWormHole:getSectorName()),
        }
        local hossenfelder_info = {
            string.format("%s (this station) is currently in sector %s (Lagrange point 4)",stationHossenfelder:getCallSign(),stationHossenfelder:getSectorName()),
            string.format("We, %s, are currently located in sector %s at Lagrange point 4",stationHossenfelder:getCallSign(),stationHossenfelder:getSectorName()),
            string.format("If you need to find %s again, just go to Lagrange point 4 (currently in sector %s)",stationHossenfelder:getCallSign(),stationHossenfelder:getSectorName()),
            string.format("%s (that's us) is at Lagrange point 4 which is currently located in sector %s",stationHossenfelder:getCallSign(),stationHossenfelder:getSectorName()),
        }
        local l5_info = {
            "Lagrange point 5 can be found by mirroring Lagrange point 4 by the Riptide Alpha - Riptide Gamma axis.",
            "Mirror Lagrange point by the Riptide Alpha to the Riptide Gamma axis to locate Lagrange point 5",
            "Take the Riptide Alpha to the Riptide Gamma axis and mirror Lagrange point 4 to determine the locatio of Lagrange point 5.",
            "Determine the Lagrange point 5 location by mirroring Lagrange point 4 via the Riptide Alpha to Riptide Gamma axis.",
        }
        local l1_info = {
            "Lagrange point 1 is between Riptide Alpha and Riptide Gamma, but there's nothing interesting there.",
            "You can find Lagrange point 1 between Riptide Alpha and Riptide Gamma, but it's not interesting.",
            "And finally, the uninteresting Lagrange point 1 is between Riptide Alpha and Riptide Gamma.",
            "To complete the information set, Lagrange point 1 is between Riptide Alpha and Riptide Gamme. There's nothing of interest there.",
        }
        setCommsMessage(string.format("%s\n%s\n%s\n%s\n%s",tableSelectRandom(psamtik_info),tableSelectRandom(wormhole_to_Icarus),tableSelectRandom(hossenfelder_info),tableSelectRandom(l5_info),tableSelectRandom(l1_info)))
        addCommsReply(string.format("Back to %s",calling_function.name),calling_function.identity)
        addCommsReply("Back to station communication", commsStation)
    end)
end
function lafrinaDiscussion(calling_function)
    local lafrina_stations_info_prompt = {
        "I need information on the Arlenian stations in the area",
        "Tell me about the Arlenian stations around here",
        "Can you help me with info on nearby Arlenian stations?",
        "What do you know about Arlenian stations in the area?",
    }
    addCommsReply(tableSelectRandom(lafrina_stations_info_prompt),function()
        local which_arlenian_stations = {
            "Which station are you interested in?",
            "Which one?",
            "Pick an Arlenian station",
            "Which Arlenian station are you interested in?",
        }
        setCommsMessage(tableSelectRandom(which_arlenian_stations))
        if stationMarielle ~= nil and stationMarielle:isValid() then
            addCommsReply(string.format("Marielle in %s",stationMarielle:getSectorName()),function()
                local marielle_info = {
                    string.format("Marielle is located in %s. It is a medium sized station conducting mining and manufacturing operations.\n\nWould you like a waypoint set on Marielle?",stationMarielle:getSectorName()),
                    string.format("Marielle is a medium sized station in sector %s. Arlenians conduct mining and manufacturing operations at Marielle.\n\nI can set a waypoint in your system on Marielle if you'd like...",stationMarielle:getSectorName()),
                    string.format("You'll find Marielle in sector %s. It's a medium sized station engaged in mining and manufacturing operations.\n\nShould I set a waypoint on Marielle for you?",stationMarielle:getSectorName()),
                    string.format("Marielle is in sector %s. It's a medium sized station. Marielle does mining and manufacturing.\n\nDo you want me to put a waypoint on Marielle for you?",stationMarielle:getSectorName()),
                }
                setCommsMessage(tableSelectRandom(marielle_info))
                local yes_waypoint_marielle_prompt = {
                    "Yes",
                    "Yes, please set a waypoint for Marielle",
                    "Yes, a waypoint on Marielle would be great",
                    "A Marielle waypoint would help. Please proceed",
                }
                addCommsReply(tableSelectRandom(yes_waypoint_marielle_prompt),function()
                    local sx, sy = stationMarielle:getPosition()
                    comms_source:commandAddWaypoint(sx, sy)
                    local marielle_waypoint_set = {
                        string.format("Waypoint %i set on station Marielle",comms_source:getWaypointCount()),
                        string.format("I set waypoint %i on station Marielle for you",comms_source:getWaypointCount()),
                        string.format("Marielle now has waypoint %i set on it",comms_source:getWaypointCount()),
                        string.format("Waypoint %i set for station Marielle",comms_source:getWaypointCount()),
                    }
                    setCommsMessage(tableSelectRandom(marielle_waypoint_set))
                    addCommsReply(string.format("Back to %s",calling_function.name),calling_function.identity)
                    addCommsReply("Back to station communication", commsStation)
                end)
                addCommsReply(string.format("Back to %s",calling_function.name),calling_function.identity)
                addCommsReply("Back to station communication", commsStation)
            end)
        end
        if stationIlorea ~= nil and stationIlorea:isValid() then
            addCommsReply(string.format("Ilorea in %s",stationIlorea:getSectorName()),function()
                local ilorea_info = {
                    string.format("Ilorea is located in %s. It is a small station conducting mining operations and providing resupply services for miners and passing ships.\n\nWould you like a waypoint set on Ilorea?",stationIlorea:getSectorName()),
                    string.format("Ilorea is a small station in sector %s. Arlenians conduct mining operations and provide resupply services there.\n\nI could set a waypoint on Ilorea if you wish...",stationIlorea:getSectorName()),
                    string.format("You can find Ilorea in sector %s. It's a small mining and resupply station.\n\nShould I set a waypoint on Ilorea for you?",stationIlorea:getSectorName()),
                    string.format("Ilorea is in sector %s. It's a small station. Ilorea mines nearby asteroids and resupplies miners and other ships.\n\nDo you want me to put a waypoint on Ilorea for you?",stationIlorea:getSectorName()),
                }
                setCommsMessage(tableSelectRandom(ilorea_info))
                local yes_waypoint_ilorea_prompt = {
                    "Yes",
                    "Yes, please set a waypoint for Ilorea",
                    "Yes, a waypoint on Ilorea would be great",
                    "An Ilorea waypoint would help. Please proceed",
                }
                addCommsReply(tableSelectRandom(yes_waypoint_ilorea_prompt),function()
                    local sx, sy = stationIlorea:getPosition()
                    comms_source:commandAddWaypoint(sx, sy)
                    local ilorea_waypoint_set = {
                        string.format("Waypoint %i set on station Ilorea",comms_source:getWaypointCount()),
                        string.format("I set waypoint %i on station Ilorea for you",comms_source:getWaypointCount()),
                        string.format("Ilorea now has waypoint %i set on it",comms_source:getWaypointCount()),
                        string.format("Waypoint %i set for station Ilorea",comms_source:getWaypointCount()),
                    }
                    setCommsMessage(tableSelectRandom(ilorea_waypoint_set))
                    addCommsReply(string.format("Back to %s",calling_function.name),calling_function.identity)
                    addCommsReply("Back to station communication", commsStation)
                end)
                addCommsReply(string.format("Back to %s",calling_function.name),calling_function.identity)
                addCommsReply("Back to station communication", commsStation)
            end)
        end
        if stationRivelle ~= nil and stationRivelle:isValid() then
            addCommsReply(string.format("Rivelle in %s",stationRivelle:getSectorName()),function()
                local rivelle_info = {
                    string.format("Rivelle is located in %s. It is a small station conducting mining operations.\n\nWould you like a waypoint set on Rivelle?",stationRivelle:getSectorName()),
                    string.format("Rivelle is a small station in sector %s. Arlenians conduct mining operations there.\n\nIf you want, I could set a waypoint on Rivelle...",stationRivelle:getSectorName()),
                    string.format("You'll find Rivelle in sector %s. It's a small mining station.\n\nShould I set a waypoint on Rivelle for you?",stationRivelle:getSectorName()),
                    string.format("Rivelle is in sector %s. It's a small station. They mine nearby asteroids and such.\n\nDo you want a waypoint on Rivelle?",stationRivelle:getSectorName()),                    
                }
                setCommsMessage(tableSelectRandom(rivelle_info))
                local yes_waypoint_rivelle_prompt = {
                    "Yes",
                    "Yes, please set a waypoint for Rivelle",
                    "Yes, a waypoint on Rivelle would be great",
                    "A Rivelle waypoint would help. Please proceed",
                }
                addCommsReply(tableSelectRandom(yes_waypoint_rivelle_prompt),function()
                    local sx, sy = stationRivelle:getPosition()
                    comms_source:commandAddWaypoint(sx, sy)
                    local rivelle_waypoint_set = {
                        string.format("Waypoint %i set on station Rivelle",comms_source:getWaypointCount()),
                        string.format("I set waypoint %i on station Rivelle for you",comms_source:getWaypointCount()),
                        string.format("Rivelle now has waypoint %i set on it",comms_source:getWaypointCount()),
                        string.format("Waypoint %i set for station Rivelle",comms_source:getWaypointCount()),
                    }
                    setCommsMessage(tableSelectRandom(rivelle_waypoint_set))
                    addCommsReply(string.format("Back to %s",calling_function.name),calling_function.identity)
                    addCommsReply("Back to station communication", commsStation)
                end)
                addCommsReply(string.format("Back to %s",calling_function.name),calling_function.identity)
                addCommsReply("Back to station communication", commsStation)
            end)
        end
        if stationBorie ~= nil and stationBorie:isValid() then
            addCommsReply(string.format("Borie in %s",stationBorie:getSectorName()),function()
                local borie_info = {
                    string.format("Borie is located in %s. It is a small station conducting mining operations. The Arlenians also indulge in gambling on this station.\n\nWould you like a waypoint set on Borie?",stationBorie:getSectorName()),
                    string.format("Borie is a small station in sector %s. Arlenians us it as a base for mining and a place for gambling.\n\nI could set a waypoint there for you if you want...",stationBorie:getSectorName()),
                    string.format("You can find Borie in sector %s. It's a small mining and gambling station.\n\nShould I set a waypoint on Borie for you?",stationBorie:getSectorName()),
                    string.format("Borie is in sector %s. It's a small station. It's primary purpose is as a base for mining, but the Arlenians also do some gambling on Borie.\n\nDo you want a waypoint placed on Borie?",stationBorie:getSectorName()),
                }
                setCommsMessage(tableSelectRandom(borie_info))
                local yes_waypoint_borie_prompt = {
                    "Yes",
                    "Yes, please set a waypoint for Borie",
                    "Yes, a waypoint on Borie would be great",
                    "A Borie waypoint would help. Please proceed",
                }
                addCommsReply(tableSelectRandom(yes_waypoint_borie_prompt),function()
                    local sx, sy = stationBorie:getPosition()
                    comms_source:commandAddWaypoint(sx, sy)
                    local borie_waypoint_set = {
                        string.format("Waypoint %i set on station Borie",comms_source:getWaypointCount()),
                        string.format("I set waypoint %i on station Borie for you",comms_source:getWaypointCount()),
                        string.format("Borie now has waypoint %i set on it",comms_source:getWaypointCount()),
                        string.format("Waypoint %i set for station Borie",comms_source:getWaypointCount()),
                    }
                    setCommsMessage(tableSelectRandom(borie_waypoint_set))
                    addCommsReply(string.format("Back to %s",calling_function.name),calling_function.identity)
                    addCommsReply("Back to station communication", commsStation)
                end)
                addCommsReply(string.format("Back to %s",calling_function.name),calling_function.identity)
                addCommsReply("Back to station communication", commsStation)
            end)
        end
        if stationLurive ~= nil and stationLurive:isValid() then
            addCommsReply(string.format("Lurive in %s",stationLurive:getSectorName()),function()
                local lurive_info = {
                    string.format("Lurive is located in %s. It is a small station conducting mining operations and research.\n\nWould you like a waypoint set on Lurive?",stationLurive:getSectorName()),
                    string.format("Lurive is a small station in sector %s. It conducts mining operations as well as research.\n\nI could set a waypoint there if you wish...",stationLurive:getSectorName()),
                    string.format("You'll find Lurive in sector %s. It's a small station where mining and research occurs.\n\nShould I set a waypoint on Lurive for you?",stationLurive:getSectorName()),
                    string.format("Lurive is in sector %s. It's a small sation. Purpose: mining and research.\n\nDo you want a waypoint placed on Lurive?",stationLurive:getSectorName()),
                }
                setCommsMessage(tableSelectRandom(lurive_info))
                local yes_waypoint_lurive_prompt = {
                    "Yes",
                    "Yes, please set a waypoint for Lurive",
                    "Yes, a waypoint on Lurive would be great",
                    "A Lurive waypoint would help. Please proceed",
                }
                addCommsReply(tableSelectRandom(yes_waypoint_lurive_prompt),function()
                    local sx, sy = stationLurive:getPosition()
                    comms_source:commandAddWaypoint(sx, sy)
                    local lurive_waypoint_set = {
                        string.format("Waypoint %i set on station Lurive",comms_source:getWaypointCount()),
                        string.format("I set waypoint %i on station Lurive for you",comms_source:getWaypointCount()),
                        string.format("Lurive now has waypoint %i set on it",comms_source:getWaypointCount()),
                        string.format("Waypoint %i set for station Lurive",comms_source:getWaypointCount()),
                    }
                    setCommsMessage(tableSelectRandom(lurive_waypoint_set))
                    addCommsReply(string.format("Back to %s",calling_function.name),calling_function.identity)
                    addCommsReply("Back to station communication", commsStation)
                end)
                addCommsReply(string.format("Back to %s",calling_function.name),calling_function.identity)
                addCommsReply("Back to station communication", commsStation)
            end)
        end
        if stationVilairre ~= nil and stationVilairre:isValid() then
            addCommsReply(string.format("Vilairre currently in %s",stationVilairre:getSectorName()), function()
                local vilairre_info = {
                    string.format("Vilairre is currently located in %s. It is a small station that handles communication and administration for area operations. It orbits the planet named Wilaux. Wilaux orbits star Balinor in sector T-13.\n\nWould you like a waypoint set on Vilairre?",stationVilairre:getSectorName()),
                    string.format("Vilairre is a small station currently in sector %s. It handles communication and administration for various area operations. It is in orbit around planet Wilaux which is in turn orbiting Balinor in sector T-13.\n\nI could set a waypoint on Vilairre if you wish...",stationVilairre:getSectorName()),
                    string.format("You'll find Vilairre is currently located in sector %s. It's a small station handling communication and administration. It orbits Wilaux which orbits Balinor in sector T-13.\n\nShould I set a waypoint on Vilairre for you?",stationVilairre:getSectorName()),
                    string.format("Vilairre is currently in sector %s. It's a small station. It handles communication and administration. It orbits planet Wilaux. Wilaux orbits star Balinor in sector T-13.\n\nDo you want me to place a waypoint on Vilairre?",stationVilairre:getSectorName()),
                }
                setCommsMessage(tableSelectRandom(vilairre_info))
                local yes_waypoint_vilairre_prompt = {
                    "Yes",
                    "Yes, please set a waypoint for Vilairre",
                    "Yes, a waypoint on Vilairre would be great",
                    "A Vilairre waypoint would help. Please proceed",
                }
                addCommsReply(tableSelectRandom(yes_waypoint_vilairre_prompt),function()
                    local sx, sy = stationVilairre:getPosition()
                    comms_source:commandAddWaypoint(sx, sy)
                    local vilairre_waypoint_set = {
                        string.format("Waypoint %i set on station Vilairre. Since Vilairre orbits Wilaux, this waypoint will become rapidly outdated",comms_source:getWaypointCount()),
                        string.format("I set waypoint %i on station Vilairre. This waypoint will become rapidly outdated since Vilairre orbits Wilaux.",comms_source:getWaypointCount()),
                        string.format("Vilairre now has waypoint %i set on it. Remember, this waypoint will be outdated shortly since the station is in motion.",comms_source:getWaypointCount()),
                        string.format("Waypoint %i has been set for station Vilairre. Note: the waypoint will not move with Vilairre, so it will soon be inaccurate.",comms_source:getWaypointCount()),
                    }
                    setCommsMessage(tableSelectRandom(vilairre_waypoint_set))
                    addCommsReply(string.format("Back to %s",calling_function.name),calling_function.identity)
                    addCommsReply("Back to station communication", commsStation)
                end)
                addCommsReply(string.format("Back to %s",calling_function.name),calling_function.identity)
                addCommsReply("Back to station communication", commsStation)
            end)
        end
        addCommsReply(string.format("Back to %s",calling_function.name),calling_function.identity)
        addCommsReply("Back to station communication", commsStation)
    end)
end

function influenceEnemyDiscussion(calling_function)
    addCommsReply("Explain influencing enemies", function()
        setCommsMessage("--Tenacious Translator 2--     Introductory Training Module\n\nCUF upgraded their ships' communications systems offering relay officers greater flexibility and opportunity when communicating with enemy ships. Features include updated protocols for common enemies (fewer reasons to ignore you), seamless language translation including idioms and integrated reputation usage.")
        addCommsReply("Why do I sometimes get 'No Reply' from enemy ships?", function()
            setCommsMessage("No Reply is when the ship being contacted does not engage their communications system. There's not much Tenacious Translator 2 can do if the ship chooses not to respond. However, the enemy protocol upgrades reduce the chance of this happening.")
            influenceEnemyDiscussion({identifier=interactiveUndockedStationCommsMeat,name="interactive relay officer"})
            addCommsReply(string.format("Back to %s",calling_function.name),calling_function.identifier)
            addCommsReply("Back", commsStation)
        end)
        addCommsReply("Can I try muliple times?", function()
            setCommsMessage("Yes, but each time you try, it irritates the enemy vessel and eventually they simply won't respond. There's not a hard and fast rule about how many times you can try.")
            influenceEnemyDiscussion({identifier=interactiveUndockedStationCommsMeat,name="interactive relay officer"})
            addCommsReply(string.format("Back to %s",calling_function.name),calling_function.identifier)
            addCommsReply("Back", commsStation)
        end)
        addCommsReply("The first option looks insulting", function()
            setCommsMessage("Yes, the first option listed is designed to anger the enemy into attacking you instead of doing whatever it is they are currently doing. Generally, this option has the greatest chance of succeeding. It has obvious consequences if successful, though.")
            influenceEnemyDiscussion({identifier=interactiveUndockedStationCommsMeat,name="interactive relay officer"})
            addCommsReply(string.format("Back to %s",calling_function.name),calling_function.identifier)
            addCommsReply("Back", commsStation)
        end)
        addCommsReply("What do the other options mean?", function()
            setCommsMessage("The options after the first option allow the Relay officer to attempt to influence the enemy to take different actions. Different factions have different susceptibilities to the options presented.")
            addCommsReply("Stop aggression", function()
                setCommsMessage("Successfully persuading an enemy with this option results in the enemy stopping their firing and any tactical maneuvering. You'll see this option labeled with this prompt:\nStop your aggression!")
                influenceEnemyDiscussion({identifier=interactiveUndockedStationCommsMeat,name="interactive relay officer"})
                addCommsReply(string.format("Back to %s",calling_function.name),calling_function.identifier)
                addCommsReply("Back", commsStation)
            end)
            addCommsReply("Cease Fire", function()
                setCommsMessage("If the enemy agrees, its IFF will switch over to Independent preventing mutual weapons targeting by the enemy and you. This option uses the following prompt:\nWe propose a cease fire agreement")
                influenceEnemyDiscussion({identifier=interactiveUndockedStationCommsMeat,name="interactive relay officer"})
                addCommsReply(string.format("Back to %s",calling_function.name),calling_function.identifier)
                addCommsReply("Back", commsStation)
            end)
            addCommsReply("Retreat", function()
                setCommsMessage("Should you convince the enemy ship with this option, they'll leave the area without attacking. This option is labeled:\nI strongly suggest you retreat immediately.")
                influenceEnemyDiscussion({identifier=interactiveUndockedStationCommsMeat,name="interactive relay officer"})
                addCommsReply(string.format("Back to %s",calling_function.name),calling_function.identifier)
                addCommsReply("Back", commsStation)
            end)
            addCommsReply("Defect", function()
                setCommsMessage("Use this option if you want to convince the enemy ship to defect from their faction to your faction. It's labeled:\nJoin us in our worthy cause.")
                influenceEnemyDiscussion({identifier=interactiveUndockedStationCommsMeat,name="interactive relay officer"})
                addCommsReply(string.format("Back to %s",calling_function.name),calling_function.identifier)
                addCommsReply("Back", commsStation)
            end)
            influenceEnemyDiscussion({identifier=interactiveUndockedStationCommsMeat,name="interactive relay officer"})
            addCommsReply(string.format("Back to %s",calling_function.name),calling_function.identifier)
            addCommsReply("Back",commsStation)
        end)
        addCommsReply("Does negotiating actually work?",function()
            setCommsMessage("The testing team for Tenacious Translator 2 proved its effectiveness and success through numerous trials. However, there were observed cases where the enemy ships reverted back to their original orders, so users are cautioned to maintain vigilance. Trials also revealed that things like distance, invested reputation, enemy ship damage and target lock may also influence the enemy ship's decision.")
            addCommsReply("How does distance influence the enemy ship?",function()
                setCommsMessage("If you're within 20 units of the enemy ship, it should not matter, but beyond that, the further away you are, the less impact you have on the enemy.")
                influenceEnemyDiscussion({identifier=interactiveUndockedStationCommsMeat,name="interactive relay officer"})
                addCommsReply(string.format("Back to %s",calling_function.name),calling_function.identifier)
                addCommsReply("Back", commsStation)
            end)
            addCommsReply("What's this about reputation?",function()
                setCommsMessage("Through subtle use of tone, word choice and subliminal messaging, Tenacious Translator 2 can positively influence the enemy decision when you exert your reputation through the software. When you initiate contact, you may choose to inject your reputation into your communication. If you don't wish to spend your reputation, choose 0. The effectiveness of reputation on the negotiation varies from faction to faction.")
                influenceEnemyDiscussion({identifier=interactiveUndockedStationCommsMeat,name="interactive relay officer"})
                addCommsReply(string.format("Back to %s",calling_function.name),calling_function.identifier)
                addCommsReply("Back", commsStation)
            end)
            addCommsReply("What about ship damage?",function()
                setCommsMessage("When the enemy ship is damaged, the stress of the situation often makes them more receptive to the Relay officer's persuasion. The Tenacious Translator 2 test team particularly enjoyed field testing this aspect.")
                influenceEnemyDiscussion({identifier=interactiveUndockedStationCommsMeat,name="interactive relay officer"})
                addCommsReply(string.format("Back to %s",calling_function.name),calling_function.identifier)
                addCommsReply("Back", commsStation)
            end)
            addCommsReply("Can target lock really influence the enemy ship?",function()
                setCommsMessage("It generally has a positive influence. The only exception is when using the defect option (surprise, surprise).")
                influenceEnemyDiscussion({identifier=interactiveUndockedStationCommsMeat,name="interactive relay officer"})
                addCommsReply(string.format("Back to %s",calling_function.name),calling_function.identifier)
                addCommsReply("Back", commsStation)
            end)
            influenceEnemyDiscussion({identifier=interactiveUndockedStationCommsMeat,name="interactive relay officer"})
            addCommsReply(string.format("Back to %s",calling_function.name),calling_function.identifier)
            addCommsReply("Back", commsStation)
        end)
        addCommsReply(string.format("Back to %s",calling_function.name),calling_function.identifier)
        addCommsReply("Back",commsStation)
    end)
end
--]]

--    docked communication functions
function dockedGreeting(comms_source, comms_target, oMsg)
    local friendly_station_greeting_prompt = {
        {thresh = 96,    text = string.format(_("station-comms","Hello, space traveler! It's a pleasure to see %s docking with us. How can we make your stay on %s more comfortable?"),comms_source:getCallSign(),comms_target:getCallSign())},
        {thresh = 92,    text = string.format(_("station-comms","Greetings, cosmic colleague! %s's docking is a cause for celebration here on %s. Any messages or updates to share?"),comms_source:getCallSign(),comms_target:getCallSign())},
        {thresh = 88,    text = string.format(_("station-comms","Good day, starfaring friend! Your arrival is like a cosmic reunion for %s. Any tales from your travels?"),comms_target:getCallSign())},
        {thresh = 84,    text = string.format(_("station-comms","Salutations, fellow communicator! %s has reached %s safe and sound. Anything exciting to share from your journey?"),comms_source:getCallSign(),comms_target:getCallSign())},
        {thresh = 80,    text = string.format(_("station-comms","Hello there! Welcome to %s. It's fantastic to have you on board."),comms_target:getCallSign())},
        {thresh = 76,    text = string.format(_("station-comms","Hello, astral envoy! %s has made a stellar entrance. Any interesting discoveries on your voyage to %s?"),comms_source:getCallSign(),comms_target:getCallSign())},
        {thresh = 72,    text = string.format(_("station-comms","Salutations, space traveler! %s's arrival marks another chapter in %s's cosmic adventures. How can we assist you today?"),comms_source:getCallSign(),comms_target:getCallSign())},
        {thresh = 68,    text = string.format(_("station-comms","Welcome, %s! It's a pleasure to see you docking with %s. How's the cosmic voyage treating you?"),comms_source:getCallSign(),comms_target:getCallSign())},
        {thresh = 64,    text = string.format(_("station-comms","Hello there, %s! Your arrival brings a new energy to %s. How was your journey?"),comms_source:getCallSign(),comms_target:getCallSign())},
        {thresh = 60,    text = string.format(_("station-comms","Greetings, %s! Welcome to our space station. It's an honor to have you on board."),comms_source:getCallSign())},
        {thresh = 56,    text = string.format(_("station-comms","Hello, relay officer. I suppose we should acknowledge the docking of %s, as unremarkable as it may be."),comms_source:getCallSign())},
        {thresh = 52,    text = string.format(_("station-comms","Welcome, spacefaring communicator. %s docks, and the cosmos barely flinches. How typical."),comms_source:getCallSign())},
        {thresh = 48,    text = string.format(_("station-comms","Ah, the celestial messenger has arrived. Do enlighten us with tales of %s's travels, if you must."),comms_source:getCallSign())},
        {thresh = 44,    text = string.format(_("station-comms","Well, well, if it isn't %s. I trust your journey was at least mildly tolerable."),comms_source:getCallSign())},
        {thresh = 40,    text = string.format(_("station-comms","Ah, the starship %s graces us with its presence. How quaint. Welcome to our humble space station."),comms_source:getCallSign())},
        {thresh = 36,    text = string.format(_("station-comms","Welcome, spacefaring communicator. I hope %s's visit won't disrupt %s's delicate equilibrium too much."),comms_source:getCallSign(),comms_target:getCallSign())},
        {thresh = 32,    text = string.format(_("station-comms","Salutations, celestial correspondent. %s's docking disrupted our routine. What urgent message do you bring, if any?"),comms_source:getCallSign())},
        {thresh = 28,    text = string.format(_("station-comms","Hello there, %s. Your arrival was as eagerly anticipated as a space debris collision. What's the news?"),comms_source:getCallSign())},
        {thresh = 24,    text = string.format(_("station-comms","Well, look who decided to drop by. What cosmic inconvenience brings %s to %s today?"),comms_source:getCallSign(),comms_target:getCallSign())},
        {thresh = 20,    text = string.format(_("station-comms","Oh, joy. The starship %s has graced us with their presence. What brings you here?"),comms_source:getCallSign())},
        {thresh = 16,    text = string.format(_("station-comms","Greetings, stellar correspondent. %s's docking is a source of mild irritation. What cosmic drama unfolds now?"),comms_source:getCallSign())},
        {thresh = 12,    text = string.format(_("station-comms","Welcome aboard, cosmic messenger. %s's docking better have a good reason. We have enough on our plate without your cosmic theatrics."),comms_source:getCallSign())},
        {thresh = 8,    text = string.format(_("station-comms","Hello, starbound emissary. %s's presence is less of a pleasure and more of a cosmic headache. What brings you to %s?"),comms_source:getCallSign(),comms_target:getCallSign())},
        {thresh = 4,    text = string.format(_("station-comms","Salutations, interstellar nuisance. %s's docking is the last thing we needed. What pressing crisis are you here to address?"),comms_source:getCallSign())},
    }
    local prompt_index = #friendly_station_greeting_prompt
    for i,prompt in ipairs(friendly_station_greeting_prompt) do
        if comms_target.comms_data.friendlyness > prompt.thresh then
            prompt_index = i
            break
        end
    end
    local prompt_pool = {}
    local lo = prompt_index - 2
    local hi = prompt_index + 2
    if prompt_index >= (#friendly_station_greeting_prompt - 2) then
        lo = #friendly_station_greeting_prompt - 4
        hi = #friendly_station_greeting_prompt
    elseif prompt_index <= 3 then
        lo = 1
        hi = 5
    end
    for i=lo,hi do
        table.insert(prompt_pool,friendly_station_greeting_prompt[i])
    end
    local prompt = tableSelectRandom(prompt_pool)
    oMsg = string.format("%s Communications Portal\n%s",comms_target:getCallSign(),prompt.text)
    setCommsMessage(oMsg)
	return oMsg
end

function dockedLightPanic(comms_source, comms_target, oMsg)
    local interactive = false
    local no_relay_panic_responses = {
        "No communication officers available due to station emergency.",
        "Relay officers unavailable during station emergency.",
        "Relay officers reassigned for station emergency.",
        "Station emergency precludes response from relay officer.",
    }
	local panic_range = comms_target.comms_data.panic_range
    if comms_target:areEnemiesInRange(panic_range*1.5) then
        if comms_target.comms_data.friendlyness > 10 then
            oMsg = string.format(_("station-comms","%s\n%s"),oMsg,tableSelectRandom(no_relay_panic_responses))
        end
    elseif comms_target:areEnemiesInRange(panic_range*2) then
        if comms_target.comms_data.friendlyness > 70 then
            local quick_relay_responses = {
                "Please be quick. Sensors detect enemies.",
                "I have to go soon since there are enemies nearby.",
                "Talk fast. Enemies approach.",
                "Enemies are coming so talk fast.",
            }
            oMsg = string.format(_("station-comms","%s\n%s"),oMsg,tableSelectRandom(quick_relay_responses))
            interactive = true
        else
            if comms_target.comms_data.friendlyness > 20 then
                oMsg = string.format(_("station-comms","%s\n%s"),oMsg,tableSelectRandom(no_relay_panic_responses))
            end
        end
    elseif comms_target:areEnemiesInRange(panic_range*2.5) then
        if comms_target.comms_data.friendlyness > 20 then
            if comms_target.comms_data.friendlyness > 60 then
                local distracted_units_responses = {
                    string.format("Please forgive us if we seem distracted. Our sensors detect enemies within %i units",math.floor(panic_range*2.5/1000)),
                    string.format("Enemies at %i units. Things might get busy soon. Business?",math.floor(panic_range*2.5/1000)),
                    string.format("A busy day here at %s: Enemies are %s units away and my boss is reviewing emergency procedures. I'm a bit distracted.",comms_target:getCallSign(),math.floor(panic_range*2.5/1000)),
                    string.format("If I seem distracted, it's only because of the enemies showing up at %i units.",math.floor(panic_range*2.5/1000)),
                }
                oMsg = string.format(_("station-comms","%s\n%s"),oMsg,tableSelectRandom(distracted_units_responses))
            elseif comms_target.comms_data.friendlyness > 25 then
                local distracted_responses = {
                    "Please forgive us if we seem distracted. Our sensors detect enemies nearby.",
                    string.format("Enemies are close to %s. We might get busy. Business?",comms_target:getCallSign()),
                    "We're quite busy preparing for enemies: evaluating cross training, checking emergency procedures, etc. I'm a little distracted.",
                    string.format("%s is likely going to be attacked soon. Everyone is running around getting ready, distracting me.",comms_target:getCallSign()),
                }
                oMsg = string.format(_("station-comms","%s\n%s"),oMsg,tableSelectRandom(distracted_responses))
            end
            interactive = true
        end
    else
        if comms_target:isFriendly(comms_source) then
            interactive = true
        elseif not comms_target:isEnemy(comms_source) then
            if comms_target.comms_data.friendlyness > 15 then
                interactive = true
            end
        end
    end

--	oMsg = string.format("(DEBUG: friendlyness: %f)\n%s", comms_target.comms_data.friendlyness, oMsg) -- TODO remove (debug)
    setCommsMessage(oMsg)
    if interactive then
        interactiveDockedStationComms()
    end
end

function androidDockedStationComms()
    addCommsReply(_("station-comms","Automated station communication"),androidDockedStationCommsMeat)
end

function androidDockedStationCommsMeat()
    setCommsMessage(_("station-comms","Select:"))
    stationStatusReport({identifier=androidDockedStationCommsMeat,name="automated station communications"})
    if isAllowedTo(comms_target.comms_data.services.activatedefensefleet) then
        stationDefenseFleet({identifier=androidDockedStationCommsMeat,name="automated station communication"})
    end
    if comms_source.goods ~= nil then
        local good_count = 0
        for good, good_quantity in pairs(comms_source.goods) do
            good_count = good_count + good_quantity
        end
        if good_count > 0 then
			local deposit_goods_prompt = {
				"Place goods in deposit hatch",
				"Put goods in hatch marked 'deposits'",
				"Insert goods in external deposit hatch",
				string.format("Put goods in %s's external storage facility",comms_target:getCallSign()),
			}
			addCommsReply(tableSelectRandom(deposit_goods_prompt),giveGoodsToStation)
        end
    end
    addCommsReply(_("Back"), commsStation)    --problem child
end
function giveGoodsToStation()
    local donate_prompt = {
        _("trade-comms","What should we give to the station?"),
        _("trade-comms","What should we give to the station out of the goodness of our heart?"),
        _("trade-comms","What should we donate to the station?"),
        _("trade-comms","What can we give the station that will help them the most?"),
    }
    setCommsMessage(tableSelectRandom(donate_prompt))
    local goods_to_give_count = 0
    for good, good_quantity in pairs(comms_source.goods) do
        if good_quantity > 0 then
            goods_to_give_count = goods_to_give_count + 1
            addCommsReply(good_desc[good], function()
                string.format("")
                comms_source.goods[good] = comms_source.goods[good] - 1
                comms_source.cargo = comms_source.cargo + 1
                local want_it = false
                if comms_target.comms_data.buy ~= nil then
                    for good_buy, price in pairs(comms_target.comms_data.buy) do
                        if good == good_buy then
                            comms_target.comms_data.friendlyness = math.min(100,comms_target.comms_data.friendlyness + price/2)
                            comms_source:addReputationPoints(math.floor(price/2))
                            want_it = true
                            break
                        end
                    end
                end
                if not want_it then
                    comms_target.comms_data.friendlyness = math.min(100,comms_target.comms_data.friendlyness + random(3,9))
                end
                local donated_confirmed = {
                    string.format("One %s donated",good_desc[good]),
                    string.format("We donated one %s to %s",good_desc[good],comms_target:getCallSign()),
                    string.format("We donated a %s",good_desc[good]),
                    string.format("We provided %s with one %s",comms_target:getCallSign(),good_desc[good]),
                }
                setCommsMessage(tableSelectRandom(donated_confirmed))
                addCommsReply(_("Back"), commsStation)
            end)
        end
    end
	if goods_to_give_count == 0 then
		local out_of_goods = {
			"No more goods to donate",
			"There is nothing left in the cargo hold to donate",
			"You've got nothing more available to donate",
			"Your cargo hold is empty, so you cannot donate anything else",
		}
		setCommsMessage(tableSelectRandom(out_of_goods))
		addCommsReply(_("Back"), commsStation)
	end
	addCommsReply(_("Back"), commsStation)
end
function interactiveDockedStationComms()
    addCommsReply("Interact with station relay officer on duty",interactiveDockedStationCommsMeat)
end
function interactiveDockedStationCommsMeat()
    local help_prompts = {
        "What can I do for you?",
        "How may I help?",
        "What do you need or want?",
        string.format("Go ahead, %s",comms_source:getCallSign()),
        string.format("How can %s serve you today?",comms_target:getCallSign()),
    }
    setCommsMessage(tableSelectRandom(help_prompts))
	local information_prompts = {
		"Information",
		"I need information",
		"Ask questions",
		"I need to know what you know",
	}
	addCommsReply(tableSelectRandom(information_prompts),stationInformation)
	local dispatch_prompts = {
		"Dispatch office",
		"Visit the dispatch office",
		"Check on possible missions",
		"Start or complete a mission",
	}
	addCommsReply(tableSelectRandom(dispatch_prompts),dispatchOffice)
	local restock_prompts = {
		"Restock ship",
		string.format("Restock %s",comms_source:getCallSign()),
		"Refill ordnance and other things on the ship",
		string.format("Replenish supplies on %s",comms_source:getCallSign()),
	}
	addCommsReply(tableSelectRandom(restock_prompts),restockShip)
	local repair_ship_prompts = {
		"Repair ship",
		string.format("Repair %s",comms_source:getCallSign()),
		"Fix broken things on the ship",
		string.format("Conduct repairs on %s",comms_source:getCallSign()),
	}
	addCommsReply(tableSelectRandom(repair_ship_prompts),repairShip)
	local enhance_ship_prompts = {
		"Enhance ship",
		string.format("Enhance %s",comms_source:getCallSign()),
		"Make improvements to ship",
		string.format("Improve %s's capabilities",comms_source:getCallSign()),
	}
	addCommsReply(tableSelectRandom(enhance_ship_prompts),enhanceShip)
    if isAllowedTo(comms_target.comms_data.services.activatedefensefleet) then
        stationDefenseFleet()
    end
--[[RM    if comms_target == stationMonocle then
        if random(1,100) < 4 then
            if stationMonocle:getCallSign() == "Monocle" then
                stationMonocle:setCallSign("Arecibo III")
            else
                stationMonocle:setCallSign("Monocle III")
            end
               stationMonocle.comms_data.history = string.format("Established in Nov2020, %s was intended to help Pastern observe asteroids in exchange for information about T'k'nol'g, suspected of biological research using human tissue illicitly obtained. The results of the research so far have yielded an addictive drug that in large enough doses not only kills the consumer but turns their body into a hyper-acidic blob that tends to eat through the hulls of ships and stations. Certain personnel on %s are tasked with watching for T'k'nol'g and reporting any additional sightings or gleaned information",stationMonocle:getCallSign(),stationMonocle:getCallSign())
        end
    end
    if planet_magnasol_star ~= nil and distance(planet_magnasol_star,comms_target) < 120000 then
        magnasolHeatDiscussion({identifier=interactiveDockedStationCommsMeat,name="interactive relay officer"})
    end
    if comms_target == stationHossenfelder then
        riptideHossenfelderDiscussion({identifier=interactiveDockedStationCommsMeat,name="interactive relay officer"})
    end
    if comms_target == stationLafrina then
        lafrinaDiscussion({identifier=interactiveDockedStationCommsMeat,name="interactive relay officer"})
    end
	if not comms_source:isEnemy(comms_target) then
		if comms_source:isFriendly(comms_target) then
			if comms_source.pods ~= comms_source.max_pods then
				unloadEscapePods()
			end
		else
			if comms_source.pods ~= comms_source.max_pods then
				if comms_target.comms_data.escape_pod_cost == nil then
					comms_target.comms_data.escape_pod_cost = math.random(8,12)
				end
				unloadEscapePods(comms_target.comms_data.escape_pod_cost)
			end
		end
	end
    --]]
	local goods_commerce_prompts = {
		"Buy, sell, trade goods, etc.",
		"Buy, sell, trade, etc.",
		"Goods commerce, etc.",
		"Buy, sell, trade, donate, jettison goods",
	}
	addCommsReply(tableSelectRandom(goods_commerce_prompts),goodsCommerce)
	buyStationComms(comms_source, comms_target)
--[[REMOVE    if jump_corridor then
        jumpCorridor()
    end--]]
end
function stationInformation()
    local information_type_prompt = {
        _("station-comms","What kind of information do you want?"),
        _("station-comms","What kind of information do you need?"),
        _("station-comms","What kind of information do you seek?"),
        _("station-comms","What kind of information are you looking for?"),
        _("station-comms","What kind of information are you interested in?"),
    }
    setCommsMessage(tableSelectRandom(information_type_prompt))
    stationStatusReport({identifier=stationInformation,name="information"})
    stationTalk({identifier=stationInformation,name="information"})
    addCommsReply("Back to interactive relay officer",interactiveDockedStationCommsMeat)
    addCommsReply("Back to station communication",commsStation)
end
function stationTalk(calling_function)
    local what_do_you_know_prompts = {
        "I'm not sure. What do you know?",
        "Not sure. Talk to me.",
        "Unsure. Help me out.",
        string.format("Well, what does the %s relay officer know?",comms_target:getCallSign()),
    }
    addCommsReply(tableSelectRandom(what_do_you_know_prompts),function()
        local knowledge_talk_prompt = {
            _("station-comms","I know about the following:"),
            _("station-comms","I know these things:"),
            _("station-comms","I can tell you about the following:"),
            _("station-comms","We could talk about..."),
        }
        setCommsMessage(tableSelectRandom(knowledge_talk_prompt))
        local knowledge_count = 0
        if comms_target.comms_data.gossip ~= nil then	-- TODO if it should be used, it must be filled
            if comms_target.comms_data.friendlyness > 50 + (difficulty * 15) then
                knowledge_count = knowledge_count + 1
                stationGossip(calling_function)
            end
        end
        if comms_target.comms_data.general ~= nil then
            knowledge_count = knowledge_count + 1
            stationGeneralInformation(calling_function)
        end
        if comms_target.comms_data.history ~= nil then
            knowledge_count = knowledge_count + 1
            stationHistory(calling_function)
        end
        if knowledge_count == 0 then
            local lack_of_knowledge_response = {
                _("station-comms","I have no additional knowledge."),
                _("station-comms","I don't know enough to talk about anything."),
                _("station-comms","Nothing interesting."),
            }
            setCommsMessage(tableSelectRandom(lack_of_knowledge_response))
        end
        addCommsReply(string.format("Back to %s",calling_function.name),calling_function.identifier)
        addCommsReply("Back to interactive relay officer",interactiveDockedStationCommsMeat)
        addCommsReply("Back to station communication",commsStation)
    end)
end
function stationGossip(calling_function)
    local gossip_prompts = {
        "Gossip",
        "What dirty little secrets can you share?",
        "I'm looking for inside information",
        "Got any juicy tidbits?",
    }
    addCommsReply(tableSelectRandom(gossip_prompts), function()
        setCommsMessage(comms_target.comms_data.gossip)
        addCommsReply(string.format("Back to %s",calling_function.name),calling_function.identifier)
        addCommsReply("Back to interactive relay officer",interactiveDockedStationCommsMeat)
        addCommsReply(_("Back to station communication"), commsStation)
    end)
end
function stationGeneralInformation(calling_function)
    local general_information_prompts = {
        "General information",
        "Regular information",
        "Standard information",
        "The usual information",
    }
    addCommsReply(tableSelectRandom(general_information_prompts), function()
        setCommsMessage(comms_target.comms_data.general)
        addCommsReply(string.format("Back to %s",calling_function.name),calling_function.identifier)
        addCommsReply("Back to interactive relay officer",interactiveDockedStationCommsMeat)
        addCommsReply(_("Back to station communication"), commsStation)
    end)
end
function stationHistory(calling_function)
    local history_prompts = {
        "Station history",
        "Station historical archives",
        string.format("%s history",comms_target:getCallSign()),
        string.format("Historical information on %s",comms_target:getCallSign()),
    }
    addCommsReply(tableSelectRandom(history_prompts), function()
        setCommsMessage(comms_target.comms_data.history)
        addCommsReply(string.format("Back to %s",calling_function.name),calling_function.identifier)
        addCommsReply("Back to interactive relay officer",interactiveDockedStationCommsMeat)
        addCommsReply(_("Back to station communication"), commsStation)
    end)
end
function dispatchOffice()
    local mission_select_prompts = {
        "Which of these missions and/or tasks are you interested in?",
        "Are you interested in any of thises missions/tasks?",
        "You may select from one of these missions or tasks:",
        "Do any of these missions or tasks interest you?",
    }
    setCommsMessage(tableSelectRandom(mission_select_prompts))
    local improvements = {}
    local msg = ""
    msg, improvements = catalogImprovements(msg)
    if #improvements > 0 and (comms_target.comms_data.friendlyness > 33 or comms_source:isDocked(comms_target)) then
        improveStationService(improvements)
    end
    local mission_options_presented_count = #improvements
    local transport_and_cargo_mission_count = transportAndCargoMissions()
    mission_options_presented_count = mission_options_presented_count + transport_and_cargo_mission_count
    if mission_options_presented_count == 0 then
        local no_missions_responses = {
            "No missions or tasks available here.",
            string.format("No missions or tasks are available here at %s.",comms_target:getCallSign()),
            string.format("%s has no missions or tasks available.",comms_target:getCallSign()),
            "There are currently no missions or tasks available here.",
        }
        setCommsMessage(tableSelectRandom(no_missions_responses))
    end
    addCommsReply("Back to interactive relay officer",interactiveDockedStationCommsMeat)
    addCommsReply("Back to station communications",commsStation)
end

-- transport and cargo missions
function createTransportMission()
	local mission_character = tableRemoveRandom(comms_target.characters)
	local mission_target = nil
	local reward = 0
	if mission_character ~= nil then
		local destination_pool = getScriptStorage().wh_stations.stations
		table.filter(destination_pool, function(o)
			return o ~= nil and o:isValid()
		end)
		local mission_target = tableSelectRandom(destination_pool)
		if mission_target ~= nil and mission_target ~= comms_target and not comms_source:isEnemy(mission_target) then
			comms_target.transport_mission = {
				["destination"] = mission_target,
				["destination_name"] = mission_target:getCallSign(),
				["reward"] = 50,
				["character"] = mission_character,
			}
		else
			table.insert(comms_target.characters, mission_character)
		end
	end
end
function createCargoMission()			
	if comms_target.residents ~= nil then
		local mission_character = tableRemoveRandom(comms_target.residents)
		local mission_origin = nil
		if mission_character ~= nil then
			local origin_pool = getScriptStorage().wh_stations.stations
			table.filter(origin_pool, function(o)
				return o ~= nil and o:isValid()
			end)
			local mission_origin = tableSelectRandom(origin_pool)
			if mission_origin ~= nil and mission_origin ~= comms_target and not comms_source:isEnemy(mission_origin) then
				comms_target.cargo_mission = {
					["origin"] = mission_origin,
					["origin_name"] = mission_origin:getCallSign(),
					["destination"] = comms_target,
					["destination_name"] = comms_target:getCallSign(),
					["reward"] = 50,
					["character"] = mission_character,
				}
			else
				table.insert(comms_target.residents, mission_character)
			end
		end
	end
end

function finishTransportationsMission()
	local who_destination_prompts = {
		string.format("Deliver %s to %s",comms_source.transport_mission.character.name,comms_target:getCallSign()),
		string.format("Escort %s off of %s",comms_source.transport_mission.character.name,comms_source:getCallSign()),
		string.format("Direct %s off the ship to %s",comms_source.transport_mission.character.name,comms_target:getCallSign()),
		string.format("Inform %s of arrival at %s",comms_source.transport_mission.character.name,comms_target:getCallSign()),
	}
	addCommsReply(tableSelectRandom(who_destination_prompts),function()
		if not comms_source:isDocked(comms_target) then
			local stay_docked_to_disembark = {
				"You need to stay docked for that action.",
				string.format("You need to stay docked for %s to disembark.",comms_source.transport_mission.character.name),
				string.format("You must stay docked long enough for %s to get off of %s on to station %s.",comms_source.transport_mission.character.name,comms_source:getCallSign(),comms_target:getCallSign()),
				string.format("You undocked before %s could get off the ship.",comms_source.transport_mission.character.name),
			}
			setCommsMessage(tableSelectRandom(stay_docked_to_disembark))
			return mission_options_presented_count
		end
		local thanks_for_ride_responses = {
			string.format("%s disembarks at %s and thanks you",comms_source.transport_mission.character.name,comms_target:getCallSign()),
			string.format("As %s leaves %s at %s, they turn and say, 'Thanks for the ride.'",comms_source.transport_mission.character.name,comms_source:getCallSign(),comms_target:getCallSign()),
			string.format("%s thanks you as they walk away from %s down the short connecting tunnel to %s.",comms_source.transport_mission.character.name,comms_source:getCallSign(),comms_target:getCallSign()),
			string.format("%s disembarks at %s. You hear, 'I'll miss %s,' as footsteps echo back to %s.",comms_source.transport_mission.character.name,comms_target:getCallSign(),comms_source:getCallSign(),comms_source:getCallSign()),
		}
		setCommsMessage(tableRemoveRandom(thanks_for_ride_responses))
		comms_source:addReputationPoints(comms_source.transport_mission.reward)
		if comms_target.residents == nil then
			comms_target.residents = {}
		end
		table.insert(comms_target.residents,comms_source.transport_mission.character)
		comms_source.transport_mission = nil
		addCommsReply(_("Back"), commsStation)
	end)
end

function abortTransportationMission()
	local alternate_disembarkation = {
		string.format("%s disembarks at %s because %s has been destroyed. You receive %s reputation for your efforts.",comms_source.transport_mission.character.name,comms_target:getCallSign(),comms_source.transport_mission.destination_name,math.floor(comms_source.transport_mission.reward/2)),
		string.format("%s leaves %s here at %s due to the destruction of %s. You still get %s reputation.",comms_source.transport_mission.character.name,comms_source:getCallSign(),comms_target:getCallSign(),comms_source.transport_mission.destination_name,math.floor(comms_source.transport_mission.reward/2)),
		string.format("%s, %s's original destination, has been destroyed. %s disembarks here. You get %s reputation for trying.",comms_source.transport_mission.destination_name,comms_source.transport_mission.character.name,comms_source.transport_mission.character.name,math.floor(comms_source.transport_mission.reward/2)),
		string.format("Since %s has been destroyed, %s gets off here at %s. Your reputation goes up by %s.",comms_source.transport_mission.destination_name,comms_source.transport_mission.character.name,comms_target:getCallSign(),math.floor(comms_source.transport_mission.reward/2)),
	}
	comms_source:addToShipLog(tableRemoveRandom(alternate_disembarkation),"Yellow")
	comms_source:addReputationPoints(math.floor(comms_source.transport_mission.reward/2))
	if comms_target.residents == nil then
		comms_target.residents = {}
	end
	table.insert(comms_target.residents,comms_source.transport_mission.character)
	comms_source.transport_mission = nil
end

function offerTransportMission()
	local transport_passenger_prompts = {
		"Transport Passenger",
		"Give passenger a ride",
		string.format("Transport %s",comms_target.transport_mission.character.name),
		"Take on a passenger",
	}
	addCommsReply(tableSelectRandom(transport_passenger_prompts),function()
		local transport_info = {
			string.format("%s wishes to be transported to %s station %s in sector %s.",comms_target.transport_mission.character.name,comms_target.transport_mission.destination:getFaction(),comms_target.transport_mission.destination_name,comms_target.transport_mission.destination:getSectorName()),
			string.format("%s needs a ride to sector %s, specifically to %s station %s.",comms_target.transport_mission.character.name,comms_target.transport_mission.destination:getSectorName(),comms_target.transport_mission.destination:getFaction(),comms_target.transport_mission.destination_name),
			string.format("%s needs to get to station %s. It's a %s station in sector %s.",comms_target.transport_mission.character.name,comms_target.transport_mission.destination_name,comms_target.transport_mission.destination:getFaction(),comms_target.transport_mission.destination:getSectorName()),
			string.format("Can you take %s to %s station %s in sector %s?",comms_target.transport_mission.character.name,comms_target.transport_mission.destination:getFaction(),comms_target.transport_mission.destination_name,comms_target.transport_mission.destination:getSectorName()),
		}
		local transport_reputation_info = {
			string.format("Transporting %s would increase your reputation by %s.",comms_target.transport_mission.character.name,comms_target.transport_mission.reward),
			string.format("If you take %s to %s, you'd increase your reputation by %s.",comms_target.transport_mission.character.name,comms_target.transport_mission.destination_name,comms_target.transport_mission.reward),
			string.format("You'd get %s reputation if you transported %s.",comms_target.transport_mission.reward,comms_target.transport_mission.character.name),
			string.format("This transportation mission is worth %s reputation.",comms_target.transport_mission.reward),
		}
		local out = string.format("%s %s",tableSelectRandom(transport_info),tableSelectRandom(transport_reputation_info))
		setCommsMessage(out)
		local transport_agree_prompts = {
			string.format("Agree to transport %s to %s station %s",comms_target.transport_mission.character.name,comms_target.transport_mission.destination:getFaction(),comms_target.transport_mission.destination_name),
			string.format("Agree to transport mission to %s in %s",comms_target.transport_mission.destination_name,comms_target.transport_mission.destination:getSectorName()),
			string.format("%s will transport %s to %s in %s",comms_source:getCallSign(),comms_target.transport_mission.character.name,comms_target.transport_mission.destination_name,comms_target.transport_mission.destination:getSectorName()),
			string.format("Take on passenger transport mission to %s",comms_target.transport_mission.destination_name),
		}
		addCommsReply(tableSelectRandom(transport_agree_prompts),function()
			if not comms_source:isDocked(comms_target) then 
				local stay_docked_to_embark = {
					"You need to stay docked for that action.",
					string.format("You need to stay docked for %s to board.",comms_source.transport_mission.character.name),
					string.format("You must stay docked long enough for %s to board %s from station %s.",comms_source.transport_mission.character.name,comms_source:getCallSign(),comms_target:getCallSign()),
					string.format("You undocked before %s could come aboard.",comms_source.transport_mission.character.name),
				}
				setCommsMessage(tableSelectRandom(stay_docked_to_embark))
				return mission_options_presented_count
			end
			comms_source.transport_mission = comms_target.transport_mission
			comms_target.transport_mission = nil
			local boarding_confirmation = {
				string.format("You direct %s to guest quarters and say, 'Welcome aboard the %s'",comms_source.transport_mission.character.name,comms_source:getCallSign()),
				string.format("You welcome %s aboard the %s. 'Let me show you our guest quarters.'",comms_source.transport_mission.character.name,comms_source:getCallSign()),
				string.format("%s boards %s. 'Allow me to show you the guest quarters where you will stay for our journey to %s'",comms_source.transport_mission.character.name,comms_source:getCallSign(),comms_source.transport_mission.destination_name),
				string.format("%s is aboard. You show %s to %s's guest quarters.",comms_source.transport_mission.character.name,comms_source.transport_mission.character.name,comms_source:getCallSign()),
			}
			setCommsMessage(tableSelectRandom(boarding_confirmation))
			addCommsReply(_("Back"), commsStation)
		end)
		local decline_transportation_prompts = {
			"Decline transportation request",
			"Refuse transportation request",
			"Decide against transportation mission",
			"Decline transportation mission",
		}
		addCommsReply(tableSelectRandom(decline_transportation_prompts),function()
			local refusal_responses = {
				string.format("You tell %s that you cannot take on any transportation missions at this time.",comms_target.transport_mission.character.name),
				string.format("You inform %s that you are unable to transport them at this time.",comms_target.transport_mission.character.name),
				string.format("'Sorry, %s. We can't transport you at this time.'",comms_target.transport_mission.character.name),
				string.format("'%s can't transport you right now, %s. Sorry about that. Good luck.'",comms_source:getCallSign(),comms_target.transport_mission.character.name),
			}
			local mission_gone = {
				"The offer disappears from the message board.",
				"The transport mission offer no longer appears on the message board.",
				string.format("%s removes the transport mission offer from the message board.",comms_target.transport_mission.character.name),
				string.format("%s gestures and the transport mission offer disappears from the message board.",comms_target.transport_mission.character.name),
			}
			if random(1,5) <= 1 then
				setCommsMessage(string.format("%s %s",tableSelectRandom(refusal_responses),tableSelectRandom(mission_gone)))
				table.insert(comms_target.residents, comms_target.transport_mission.character)
				comms_target.transport_mission = nil
			else
				setCommsMessage(string.format("%s",tableSelectRandom(refusal_responses)))
			end
			addCommsReply(_("Back"), commsStation)
		end)
		addCommsReply(_("Back"), commsStation)
	end)
end

function finishCargoMission()
	local cargo_delivery_prompts = {
		string.format("Deliver cargo to %s on %s",comms_source.cargo_mission.character.name,comms_target:getCallSign()),
		string.format("Give cargo to %s here on %s",comms_source.cargo_mission.character.name,comms_target:getCallSign()),
		string.format("Offload %s's cargo to station %s",comms_source.cargo_mission.character.name,comms_target:getCallSign()),
		string.format("Unload cargo to %s and inform %s",comms_target:getCallSign(),comms_source.cargo_mission.character.name),
	}
	addCommsReply(tableSelectRandom(cargo_delivery_prompts),function()
		if not comms_source:isDocked(comms_target) then 
			local stay_docked_to_deliver = {
				"You need to stay docked for that action.",
				string.format("You need to stay docked to deliver %s's cargo.",comms_source.cargo_mission.character.name),
				string.format("You must stay docked long enough to unload %s's cargo to %s.",comms_source.cargo_mission.character.name,comms_target:getCallSign()),
				string.format("You undocked before we could deliver cargo for %s.",comms_source.cargo_mission.character.name),
			}
			setCommsMessage(tableSelectRandom(stay_docked_to_deliver))
			return
		end
		local cargo_delivery_confirmation_and_thanks = {
			string.format("%s thanks you for retrieving the cargo.",comms_source.cargo_mission.character.name),
			string.format("%s says, 'Thanks for bringing me my stuff.'",comms_source.cargo_mission.character.name),
			string.format("%s grabs the cargo and waves, clearly happy to have it.",comms_source.cargo_mission.character.name),
			string.format("%s takes receipt of the cargo and is clearly grateful.",comms_source.cargo_mission.character.name),
		}
		setCommsMessage(tableSelectRandom(cargo_delivery_confirmation_and_thanks))
		comms_source:addReputationPoints(comms_source.cargo_mission.reward)
		table.insert(comms_target.characters, comms_source.cargo_mission.character)
		comms_source.cargo_mission = nil
		addCommsReply(_("Back"), commsStation)
	end)
end

function abortCargoMission()
	local station_destroyed_mid_mission = {
		string.format("Automated systems on %s have informed you of the destruction of station %s. Your mission to deliver cargo for %s to %s is no longer valid. You unloaded the cargo and requested the station authorities handle it for the family of %s. You received %s reputation for your efforts. The mission has been removed from your mission log.",comms_target:getCallSign(),comms_source.cargo_mission.destination_name,comms_source.cargo_mission.character.name,comms_source.cargo_mission.destination_name,comms_source.cargo_mission.character,math.floor(comms_source.cargo_mission.reward/2)),
		string.format("Records on %s inform you that %s has been destroyed. Thus, your cargo mission for %s is no longer valid. You unload the cargo for %s authorities to handle it for %s's family. You receive %s reputation for your efforts. The cargo mission has been removed from your mission log.",comms_target:getCallSign(),comms_source.cargo_mission.destination_name,comms_source.cargo_mission.character.name,comms_target:getCallSign(),comms_source.cargo_mission.character.name,math.floor(comms_source.cargo_mission.reward/2)),
		string.format("You see on %s's status board that %s was destroyed. So, you can't deliver %s's cargo. You unload it, asking %s's personnel to take care of it for the family of %s. You still get %s reputation. You remove the mission from your task list.",comms_target:getCallSign(),comms_source.cargo_mission.destination_name,comms_source.cargo_mission.character.name,comms_target:getCallSign(),comms_source.cargo_mission.character.name,math.floor(comms_source.cargo_mission.reward/2)),
		string.format("%s requests %s's cargo on behalf of their family. %s has been destroyed. You unload the cargo and post a message of condolences for %s's family. You receive %s reputation and delete the mission from your task list.",comms_target:getCallSign(),comms_source.cargo_mission.character.name,comms_source.cargo_mission.destination_name,comms_source.cargo_mission.character.name,math.floor(comms_source.cargo_mission.reward/2)),
	}
	comms_source:addToShipLog(tableSelectRandom(station_destroyed_mid_mission),"Yellow")
	comms_source:addReputationPoints(math.floor(comms_source.cargo_mission.reward/2))
	comms_source.cargo_mission = nil
end

function pickUpCargoMission()
	local mid_cargo_mission_pickup_prompts = {
		string.format("Pick up cargo for %s",comms_source.cargo_mission.character.name),
		string.format("Get cargo for %s",comms_source.cargo_mission.character.name),
		string.format("Load cargo from %s for %s",comms_target:getCallSign(),comms_source.cargo_mission.character.name),
		string.format("Load cargo on %s for %s",comms_source:getCallSign(),comms_source.cargo_mission.character.name),
	}
	addCommsReply(tableSelectRandom(mid_cargo_mission_pickup_prompts),function()
		if not comms_source:isDocked(comms_target) then
			local stay_docked_to_get_cargo = {
				"You need to stay docked for that action.",
				string.format("You need to stay docked to get %s's cargo.",comms_source.cargo_mission.character.name),
				string.format("You must stay docked long enough to load %s's cargo on %s.",comms_source.cargo_mission.character.name,comms_source:getCallSign()),
				string.format("You undocked before we could load cargo for %s.",comms_source.cargo_mission.character.name),
			}
			setCommsMessage(tableSelectRandom(stay_docked_to_get_cargo))
			return
		end
		local cargo_loaded_confirmation = {
			string.format("The cargo for %s has been loaded on %s.",comms_source.cargo_mission.character.name,comms_source:getCallSign()),
			string.format("%s's cargo has been loaded from %s to %s.",comms_source.cargo_mission.character.name,comms_target:getCallSign(),comms_source:getCallSign()),
			string.format("You take receipt of cargo from %s destined for %s.",comms_target:getCallSign(),comms_source.cargo_mission.character.name),
			string.format("You load %s's cargo from %s",comms_source.cargo_mission.character.name,comms_target:getCallSign()),
		}
		setCommsMessage(tableSelectRandom(cargo_loaded_confirmation))
		comms_source.cargo_mission.loaded = true
		addCommsReply(_("Back"), commsStation)
	end)
end
function failedCargoMission()
	local station_destroyed_before_getting_cargo = {
		string.format("Automated systems on %s have informed you of the destruction of station %s. Your mission to retrieve cargo for %s from %s is no longer valid and has been removed from your mission log.",comms_target:getCallSign(),comms_source.cargo_mission.origin_name,comms_source.cargo_mission.character.name,comms_source.cargo_mission.origin_name),
		string.format("Records on %s inform you that %s has been destroyed. Thus, your cargo retrieval mission for %s is no longer valid. It's been removed from your mission task list.",comms_target:getCallSign(),comms_source.cargo_mission.origin_name,comms_source.cargo_mission.character.name),
		string.format("You see on %s's status board that %s was destroyed. So, you can't pick up %s's cargo. You remove the mission from your task list.",comms_target:getCallSign(),comms_source.cargo_mission.origin_name,comms_source.cargo_mission.character.name),
		string.format("%s informs you that %s was destroyed. This invalidates your mission to get %s's cargo from %s. You delete the mission from your task list and send an explanatory message to %s",comms_target:getCallSign(),comms_source.cargo_mission.origin_name,comms_source.cargo_mission.character.name,comms_source.cargo_mission.origin_name,comms_source.cargo_mission.character.name),
	}
	comms_source:addToShipLog(tableSelectRandom(station_destroyed_before_getting_cargo),"Yellow")
	if comms_source.cargo_mission.destination:isValid() then
		table.insert(comms_source.cargo_mission.destination.residents,comms_source.cargo_mission.character)
	end
	comms_source.cargo_mission = nil
end

function offerCargoMission()
	local retrieve_cargo_prompts = {
		"Retrieve Cargo",
		string.format("Retrieve cargo for %s",comms_target.cargo_mission.character.name),
		string.format("Get cargo from %s",comms_target.cargo_mission.origin_name),
		string.format("Get cargo for %s from %s",comms_target.cargo_mission.character.name,comms_target.cargo_mission.origin_name),
	}
	addCommsReply(tableSelectRandom(retrieve_cargo_prompts),function()
		local cargo_parameters = {
			string.format("%s wishes you to pick up cargo from %s station %s in sector %s and deliver it here.",comms_target.cargo_mission.character.name,comms_target.cargo_mission.origin:getFaction(),comms_target.cargo_mission.origin_name,comms_target.cargo_mission.origin:getSectorName()),
			string.format("%s wants to hire you to get cargo from %s station %s in %s and deliver it here (%s).",comms_target.cargo_mission.character.name,comms_target.cargo_mission.origin:getFaction(),comms_target.cargo_mission.origin_name,comms_target.cargo_mission.origin:getSectorName(),comms_target:getCallSign()),
			string.format("Mission: Get cargo from %s station %s in sector %s for %s and bring it back here.",comms_target.cargo_mission.origin:getFaction(),comms_target.cargo_mission.origin_name,comms_target.cargo_mission.origin:getSectorName(),comms_target.cargo_mission.character.name),
			string.format("Task: Get cargo for %s from %s and deliver it here. %s is a %s station in sector %s.",comms_target.cargo_mission.character.name,comms_target.cargo_mission.origin_name,comms_target.cargo_mission.origin_name,comms_target.cargo_mission.origin:getFaction(),comms_target.cargo_mission.origin:getSectorName()),
		}
		local cargo_mission_reputation = {
			string.format("Retrieving and delivering this cargo for %s would increase your reputation by %s.",comms_target.cargo_mission.character.name,comms_target.cargo_mission.reward),
			string.format("Getting this cargo from %s for %s would boost your reputation by %s.",comms_target.cargo_mission.origin_name,comms_target.cargo_mission.character.name,comms_target.cargo_mission.reward),
			string.format("Your reputation would go up by %s if you completed this cargo mission for %s.",comms_target.cargo_mission.reward,comms_target.cargo_mission.character.name),
			string.format("You would get %s reputation for getting cargo from %s for %s",comms_target.cargo_mission.reward,comms_target.cargo_mission.origin_name,comms_target.cargo_mission.character.name),
		}
		setCommsMessage(string.format("%s %s",tableSelectRandom(cargo_parameters),tableSelectRandom(cargo_mission_reputation)))
		local agree_to_cargo_mission = {
			string.format("Agree to retrieve cargo for %s",comms_target.cargo_mission.character.name),
			string.format("Sign up to get cargo for %s",comms_target.cargo_mission.character.name),
			string.format("Take on mission to get cargo for %s",comms_target.cargo_mission.character.name),
			string.format("Inform %s that %s will get their cargo",comms_target.cargo_mission.character.name,comms_source:getCallSign())
		}
		addCommsReply(tableSelectRandom(agree_to_cargo_mission),function()
			if not comms_source:isDocked(comms_target) then 
				local stay_docked_to_start_cargo_mission = {
					"You need to stay docked for that action.",
					string.format("You need to stay docked to agree to get %s's cargo.",comms_source.cargo_mission.character.name),
					string.format("You must stay docked long enough to consent to %s's cargo mission.",comms_source.cargo_mission.character.name),
					string.format("You undocked before we could agree to retrieve cargo for %s.",comms_source.cargo_mission.character.name),
				}
				setCommsMessage(tableSelectRandom(stay_docked_to_start_cargo_mission))
				return
			end
			comms_source.cargo_mission = comms_target.cargo_mission
			comms_source.cargo_mission.loaded = false
			comms_target.cargo_mission = nil
			local cargo_agreement_confirmation = {
				string.format("%s thanks you and contacts station %s to let them know that %s will be picking up the cargo.",comms_source.cargo_mission.character.name,comms_source.cargo_mission.origin_name,comms_source:getCallSign()),
				string.format("%s contacts station %s to let them know that %s will be retrieving %s's cargo.",comms_source.cargo_mission.character.name,comms_source.cargo_mission.origin_name,comms_source:getCallSign(),comms_source.cargo_mission.character.name),
				string.format("%s says, 'Thanks %s. I'll let %s know you're picking up my cargo.'",comms_source.cargo_mission.character.name,comms_source:getCallSign(),comms_source.cargo_mission.origin_name),
				string.format("%s says, 'I'll let %s know you're coming for my cargo. Thank you %s.'",comms_source.cargo_mission.character.name,comms_source.cargo_mission.origin_name,comms_source:getCallSign()),
			}
			setCommsMessage(tableSelectRandom(cargo_agreement_confirmation))
			addCommsReply(_("Back"), commsStation)
		end)
		local decline_cargo_mission = {
			"Decline cargo retrieval request",
			"Decline cargo mission",
			"Refuse cargo retrieval request",
			"Decide against cargo retrieval request",
		}
		addCommsReply(tableSelectRandom(decline_cargo_mission),function()
			local cargo_refusal_responses = {
				string.format("You tell %s that you cannot take on any cargo missions at this time.",comms_target.cargo_mission.character.name),
				string.format("You inform %s that you are unable to get any cargo for them at this time.",comms_target.cargo_mission.character.name),
				string.format("'Sorry, %s. We can't retrieve your cargo at this time.'",comms_target.cargo_mission.character.name),
				string.format("'%s can't get cargo for you you right now, %s. Sorry about that. Good luck.'",comms_source:getCallSign(),comms_target.cargo_mission.character.name),
			}
			local cargo_mission_gone = {
				"The offer disappears from the message board.",
				"The cargo mission offer no longer appears on the message board.",
				string.format("%s removes the cargo retrieval mission offer from the message board.",comms_target.cargo_mission.character.name),
				string.format("%s gestures and the cargo mission offer disappears from the message board.",comms_target.cargo_mission.character.name),
			}
			if random(1,5) <= 1 then
				setCommsMessage(string.format("%s %s",tableSelectRandom(cargo_refusal_responses),tableSelectRandom(cargo_mission_gone)))
				table.insert(comms_target.residents,comms_target.cargo_mission.character)
				comms_target.cargo_mission = nil
			else
				setCommsMessage(tableSelectRandom(cargo_refusal_responses))
			end
			addCommsReply(_("Back"), commsStation)
		end)
		addCommsReply(_("Back"), commsStation)
	end)
end

function transportAndCargoMissions()
	--[[
		during station placement about 40 characters were distributed around the stations.
		each station that has at least one character will offer a transport mission.
		when a transport mission is completed, the character is transferred to the station residents.
		when a station has a resident, they will offer cargo missions, to fetch cargo.
		when a resident receives it's cargo, they will become characters again.
		notice: cargo is no trade item and does not take up cargo space.
	--]]
    local mission_options_presented_count = 0
    if comms_source.transport_mission ~= nil then
        if comms_source.transport_mission.destination ~= nil and comms_source.transport_mission.destination:isValid() then
            if comms_source.transport_mission.destination == comms_target then
                mission_options_presented_count = mission_options_presented_count + 1
				finishTransportationsMission()
            end
        else
			abortTransportationMission()
        end
    else    --transport mission is nil
        if comms_target.transport_mission == nil then
			createTransportMission()
        else    --transport mission not nil
            if not comms_target.transport_mission.destination:isValid() then
                if comms_target.residents == nil then
                    comms_target.residents = {}
                end
                table.insert(comms_target.residents,comms_target.transport_mission.character)
                comms_target.transport_mission = nil
            end
        end
        if comms_target.transport_mission ~= nil then
			mission_options_presented_count = mission_options_presented_count + 1
			offerTransportMission()
        end
    end
    if comms_source.cargo_mission ~= nil then
        if comms_source.cargo_mission.loaded then
            if comms_source.cargo_mission.destination ~= nil and comms_source.cargo_mission.destination:isValid() then
                if comms_source.cargo_mission.destination == comms_target then
					mission_options_presented_count = mission_options_presented_count + 1
					finishCargoMission()
                end
            else
				abortCargoMission()
            end
        else    --cargo not loaded
            if comms_source.cargo_mission.origin ~= nil and comms_source.cargo_mission.origin:isValid() then
                if comms_source.cargo_mission.origin == comms_target then
                    mission_options_presented_count = mission_options_presented_count + 1
					pickUpCargoMission()
                end
            else
				failedCargoMission()
            end
        end
    else    --no cargo mission
        if comms_target.cargo_mission == nil then
			createCargoMission()
        else    --cargo mission exists
            if not comms_target.cargo_mission.origin:isValid() then
                table.insert(comms_target.residents,comms_target.cargo_mission.character)
                comms_target.cargo_mission = nil
            end
        end
        if comms_target.cargo_mission ~= nil then
            mission_options_presented_count = mission_options_presented_count + 1
			offerCargoMission()
        end
    end
    return mission_options_presented_count
end

function restockShip()
    comms_source.repairCrewCoolantReturn = {identifier=restockShip,name="restock ship"}
    local restock_type_prompt = {
        _("station-comms","What does your ship need to restock?"),
        _("station-comms","What kind of supplies do you need?"),
        _("station-comms","What type of resupply does your ship need?"),
        _("station-comms","What are you low on?"),
    }
    setCommsMessage(tableSelectRandom(restock_type_prompt))
    local missilePresence = 0
    for i, missile_type in ipairs(missile_types) do
        missilePresence = missilePresence + comms_source:getWeaponStorageMax(missile_type)
    end
    if missilePresence > 0 then
        if     (comms_target.comms_data.weapon_available.Nuke   and comms_source:getWeaponStorageMax("Nuke") > 0)   or 
            (comms_target.comms_data.weapon_available.EMP    and comms_source:getWeaponStorageMax("EMP") > 0)    or 
            (comms_target.comms_data.weapon_available.Homing and comms_source:getWeaponStorageMax("Homing") > 0) or 
            (comms_target.comms_data.weapon_available.Mine   and comms_source:getWeaponStorageMax("Mine") > 0)   or 
            (comms_target.comms_data.weapon_available.HVLI   and comms_source:getWeaponStorageMax("HVLI") > 0)   then
                restockOrdnance()
        end
    end    
    if comms_source:isFriendly(comms_target) then
        getRepairCrewFromStation("friendly")
        getCoolantFromStation("friendly")
    else
        getRepairCrewFromStation("neutral")
        getCoolantFromStation("neutral")
    end
    addCommsReply("Back to interactive relay officer",interactiveDockedStationCommsMeat)
    addCommsReply("Back to station communication",commsStation)
end
function restockOrdnance()
    local ordnance_restock_prompt = {
        "I need ordnance restocked",
        "Restock ordnance",
        string.format("%s needs more ordnance",comms_source:getCallSign()),
        string.format("Please provide ordnance for %s",comms_source:getCallSign()),
    }
    addCommsReply(tableSelectRandom(ordnance_restock_prompt), function()
        local ordnance_type_specification = {
            "What type of ordnance do you need?",
            "Specify the type of ordnance desired",
            string.format("Exactly what kind of ordnance does %s need?",comms_source:getCallSign()),
            string.format("Identify the ordnance type required for %s",comms_source:getCallSign()),
        }
        setCommsMessage(tableSelectRandom(ordnance_type_specification))
        local prompts = {
            ["Nuke"] = {
                _("ammo-comms","Can you supply us with some nukes?"),
                _("ammo-comms","We really need some nukes."),
                _("ammo-comms","Can you restock our nuclear missiles?"),
            },
            ["EMP"] = {
                _("ammo-comms","Please restock our EMP missiles."),
                _("ammo-comms","Got any EMPs?"),
                _("ammo-comms","We need Electro-Magnetic Pulse missiles."),
            },
            ["Homing"] = {
                _("ammo-comms","Do you have spare homing missiles for us?"),
                _("ammo-comms","Do you have extra homing missiles?"),
                _("ammo-comms","Please replenish our homing missiles."),
            },
            ["Mine"] = {
                _("ammo-comms","We could use some mines."),
                _("ammo-comms","How about mines?"),
                _("ammo-comms","Got mines for us?"),
            },
            ["HVLI"] = {
                _("ammo-comms","What about HVLI?"),
                _("ammo-comms","Could you provide HVLI?"),
                _("ammo-comms","We need High Velocity Lead Impactors."),
            },
        }
        for i, missile_type in ipairs(missile_types) do
            if comms_source:getWeaponStorageMax(missile_type) > 0 and comms_target.comms_data.weapon_available[missile_type] then
                addCommsReply(string.format(_("ammo-comms","%s (%d rep each)"),prompts[missile_type][math.random(1,#prompts[missile_type])],getWeaponCost(missile_type)), function()
                    string.format("")
                    handleWeaponRestock(missile_type)
                    addCommsReply("Back to restock ship",restockShip)
                    addCommsReply("Back to interactive relay officer",interactiveDockedStationCommsMeat)
                    addCommsReply(_("Back to station communication"), commsStation)
                end)
            end
        end
        addCommsReply("Back to restock ship",restockShip)
        addCommsReply("Back to interactive relay officer",interactiveDockedStationCommsMeat)
        addCommsReply(_("Back to station communication"), commsStation)
    end)
end
function handleWeaponRestock(weapon)
    local done_with_weapon_restock = false
    if not comms_source:isDocked(comms_target) then
        local stay_docked_for_weapons_restock = {
            "You need to stay docked for that action.",
            string.format("You need to stay docked to get weapon restock from %s.",comms_target:getCallSign()),
            string.format("You must stay docked long enough to receive ordnance restock from %s.",comms_target:getCallSign()),
            string.format("You undocked before we could load ordnance from %s.",comms_target:getCallSign()),
        }
        setCommsMessage(tableSelectRandom(stay_docked_for_weapons_restock))
        done_with_weapon_restock = true
    end
    if not isAllowedTo(comms_data.weapons[weapon]) and not done_with_weapon_restock then
        local no_nukes_on_principle = {
            "We do not deal in weapons of mass destruction.",
            "We don't deal in nukes on principle.",
            "We don't deal in nukes in protest of their misuse.",
            "It's against our beliefs to deal in weapons of mass destruction.",
        }
        local no_emps_on_principle = {
            "We do not deal in weapons of mass disruption.",
            "It's against our beliefs to deal in weapons of mass disruption.",
            "We don't deal in EMPs on principle.",
            "We protest the use of EMPs, so we don't deal in them.",
        }
        local no_weapon_type_on_principle = {
            "We do not deal in those weapons.",
            "We do not deal in those weapons on principle.",
            "Those weapons are anathema to us, so we don't deal in them.",
            "We hate those weapons, so we don't deal in them.",
        }
        if weapon == "Nuke" then setCommsMessage(tableSelectRandom(no_nukes_on_principle))
        elseif weapon == "EMP" then setCommsMessage(tableRemoveRansom(no_emps_on_principle))
        else setCommsMessage(tableSelectRandom(no_weapon_type_on_principle)) end
        done_with_weapon_restock = true
    end
    if not done_with_weapon_restock then
        local points_per_item = getWeaponCost(weapon)
        local item_amount = math.floor(comms_source:getWeaponStorageMax(weapon) * comms_data.max_weapon_refill_amount[getFriendStatus()]) - comms_source:getWeaponStorage(weapon)
        if item_amount <= 0 then
            if weapon == "Nuke" then
                local full_on_nukes = {
                    "All nukes are charged and primed for destruction.",
                    "All nukes are already charged and primed for destruction.",
                    "We double checked and all of your nukes are primed, charged and ready to destroy their targets.",
                    "Every one of your nukes are already fully prepared for launch. Happy explosions to you!",
                }
                setCommsMessage(tableSelectRandom(full_on_nukes))
            else
                local full_on_ordnance = {
                    "Sorry, sir, but you are as fully stocked as I can allow.",
                    "Your magazine is already completely full.",
                    "We can't give you any more because you are already fully loaded.",
                    string.format("Sorry, but there is no more space on %s for this ordnance type.",comms_source:getCallSign()),
                }
                setCommsMessage(tableSelectRandom(full_on_ordnance))
            end
--            addCommsReply("Back to restock ship",restockShip)
--            addCommsReply(_("Back to station communication"), commsStation)
        else
            if comms_source:getReputationPoints() > points_per_item * item_amount then
                if comms_source:takeReputationPoints(points_per_item * item_amount) then
                    comms_source:setWeaponStorage(weapon, comms_source:getWeaponStorage(weapon) + item_amount)
                    if comms_source:getWeaponStorage(weapon) == comms_source:getWeaponStorageMax(weapon) then
                        local restocked_on_ordnance = {
                            "You are fully loaded and ready to explode things.",
                            "You are fully restocked and ready to make things explode.",
                            string.format("%s's %s magazine has been fully restocked",comms_source:getCallSign(),weapon),
                            string.format("We made sure your %s magazine was completely restocked",weapon),
                        }
                        setCommsMessage(tableSelectRandom(restocked_on_ordnance))
                    else
                        local partial_ordnance_restock = {
                            "We generously resupplied you with some weapon charges.",
                            "We gave you some of the ordnance you requested",
                            "You got some of the weapon charges you asked for.",
                            "We were able to provide you with some of the ordnance you requested.",
                        }
                        local good_use = {
                            "Put them to good use.",
                            "Use them well.",
                            "Make good use of them.",
                            "Do the best you can with them.",
                        }
                        setCommsMessage(string.format("%s\n%s",tableSelectRandom(partial_ordnance_restock),tableSelectRandom(good_use)))
                    end
                else
                    local insufficient_rep_responses = {
                        "Insufficient reputation",
                        "Not enough reputation",
                        "You need more reputation",
                        string.format("You need more than %i reputation",math.floor(comms_source:getReputationPoints())),
                        "You don't have enough reputation",
                    }
                    setCommsMessage(tableSelectRandom(insufficient_rep_responses))
                    done_with_weapon_restock = true
                end
            else
                if comms_source:getReputationPoints() > points_per_item then
                    local complete_refill_unavailable = {
                        string.format("You can't afford as many %ss as I'd like to provide to you",weapon),
                        string.format("A full restock of %s costs more than your current reputation",weapon),
                        string.format("You don't have enough reputation for a full restock of %s",weapon),
                        string.format("%i reputation is not enough for a full restock of %s",math.floor(comms_source:getReputationPoints()),weapon),
                    }
                    setCommsMessage(tableSelectRandom(complete_refill_unavailable))
                    local max_affordable = math.floor(comms_source:getReputationPoints()/points_per_item)
                    for i=1,max_affordable do
                        addCommsReply(string.format(_("ammo-comms","Get %i (%i x %i = %i reputation)"),i,i,item_amount,i*item_amount),function()
                            string.format("")
                            if comms_source:takeReputationPoints(i*item_amount) then
                                comms_source:setWeaponStorage(weapon, comms_source:getWeaponStorage(weapon) + i)
                                if comms_source:getWeaponStorage(weapon) == comms_source:getWeaponStorageMax(weapon) then
                                    local restocked_on_selected_ordnance = {
                                        "We loaded the ordnance you requested so you're ready to explode things.",
                                        string.format("We provided the ordnance requested (amount: %i) You are ready to make things explode.",i),
                                        string.format("%s's %s magazine has been restocked as requested (amount:%i)",comms_source:getCallSign(),weapon,i),
                                        string.format("We stocked your %s magazine (amount: %i)",weapon,i),
                                    }
                                    setCommsMessage(tableSelectRandom(restocked_on_selected_ordnance))
                                else
                                    if i == 1 then
                                        local single_restock = {
                                            "We generously resupplied you with one weapon charge.",
                                            "We gave you one of the ordnance type you requested",
                                            "You got one weapon charge of the type you asked for.",
                                            "We were able to provide you with one of the ordnance type you requested.",
                                        }
                                        local one_good_use = {
                                            "Put it to good use.",
                                            "Use it well.",
                                            "Make good use of it.",
                                            "Do the best you can with it.",
                                        }
                                        setCommsMessage(string.format("%s\n%s",tableSelectRandom(single_restock),tableSelectRandom(one_good_use)))
                                    else
                                        local partial_numeric_ordnance_restock = {
                                            string.format("We generously resupplied you with %i weapon charges.",i),
                                            string.format("We gave you %i of the ordnance type you requested",i),
                                            string.format("You got %i of the weapon charges you asked for.",i),
                                            string.format("We were able to provide you with %i of the ordnance type you requested.",i),
                                        }
                                        local good_use = {
                                            "Put them to good use.",
                                            "Use them well.",
                                            "Make good use of them.",
                                            "Do the best you can with them.",
                                        }
                                        setCommsMessage(string.format("%s\n%s",tableSelectRandom(partial_numeric_ordnance_restock),tableSelectRandom(good_use)))
                                    end
                                end
                            else
                                local insufficient_rep_responses = {
                                    "Insufficient reputation",
                                    "Not enough reputation",
                                    "You need more reputation",
                                    string.format("You need more than %i reputation",math.floor(comms_source:getReputationPoints())),
                                    "You don't have enough reputation",
                                }
                                setCommsMessage(tableSelectRandom(insufficient_rep_responses))
                            end
                            addCommsReply("Back to restock ship",restockShip)
                            addCommsReply(_("Back to station communication"), commsStation)
                        end)
                    end
                else
                    setCommsMessage(_("needRep-comms","Not enough reputation."))
--                    addCommsReply("Back to restock ship",restockShip)
--                    addCommsReply(_("Back to station communication"), commsStation)
                end
            end
        end
    end
end
function getRepairCrewFromStation(relationship)
    local presented_option = false
    if comms_target.comms_data.available_repair_crew == nil then
        comms_target.comms_data.available_repair_crew = math.random(0,5)
        comms_target.comms_data.available_repair_crew_cost_friendly_needy_over_66 = math.random(30,60)
        comms_target.comms_data.available_repair_crew_cost_neutral_needy_over_66 = math.random(45,90)
        comms_target.comms_data.available_repair_crew_cost_excess = math.random(15,30)
        comms_target.comms_data.available_repair_crew_cost_under_66 = math.random(15,30)
        print(comms_target:getCallSign(),"available repair crew:",comms_target.comms_data.available_repair_crew)
    end
    if comms_target.comms_data.available_repair_crew > 0 then    --station has repair crew available
        presented_option = true
        local get_repair_crew_prompts = {
            "Recruit repair crew member",
            "Hire repair crew member",
            "Get repair crew member",
            "Add crew member to repair team",
        }
        addCommsReply(tableSelectRandom(get_repair_crew_prompts),function()
            if comms_target.comms_data.crew_available_delay == nil or getScenarioTime() > comms_target.comms_data.crew_available_delay then
                local hire_cost = 0
                if comms_source:isFriendly(comms_target) then
                    hire_cost = comms_target.comms_data.available_repair_crew_cost_friendly_needy_over_66
                else
                    hire_cost = comms_target.comms_data.available_repair_crew_cost_neutral_needy_over_66
                end
                if comms_target.comms_data.friendlyness <= 66 then
                    hire_cost = hire_cost + comms_target.comms_data.available_repair_crew_cost_under_66
                end
                if comms_source:getRepairCrewCount() >= comms_source.maxRepairCrew then
                    hire_cost = hire_cost + comms_target.comms_data.available_repair_crew_cost_excess
                end
                local consider_repair_crew = {
                    "We have a repair crew candidate for you to consider",
                    "There's a repair crew candidate here for you to consider",
                    "Consider hiring this repair crew candidate",
                    "Would you like to hire this repair crew candidate?",
                }
                setCommsMessage(tableSelectRandom(consider_repair_crew).." ("..tostring(comms_target.comms_data.available_repair_crew).." available)")
                local recruit_repair_crew_prompt = {
                    string.format("Recruit repair crew member for %i reputation",hire_cost),
                    string.format("Hire repair crew member for %i reputation",hire_cost),
                    string.format("Spend %i reputation to recruit repair crew member",hire_cost),
                    string.format("Spend %i reuptation to hire repair crew member",hire_cost),
                }
                addCommsReply(tableSelectRandom(recruit_repair_crew_prompt), function()
                    if not comms_source:isDocked(comms_target) then
                        local stay_docked_to_get_repair_crew = {
                            "You need to stay docked for that action.",
                            "You need to stay docked to hire repair crew.",
                            string.format("You must stay docked long enough for your repair crew to board %s",comms_source:getCallSign()),
                            string.format("You undocked before the repair crew you wanted to hire could come aboard from %s",comms_target:getCallSign()),
                        }
                        setCommsMessage(tableSelectRandom(stay_docked_to_get_repair_crew))
                        return
                    end
                    if not comms_source:takeReputationPoints(hire_cost) then
                        local insufficient_rep_responses = {
                            "Insufficient reputation",
                            "Not enough reputation",
                            "You need more reputation",
                            string.format("You need more than %i reputation",math.floor(comms_source:getReputationPoints())),
                            "You don't have enough reputation",
                        }
                        setCommsMessage(tableSelectRandom(insufficient_rep_responses))
                    else
                        comms_source:setRepairCrewCount(comms_source:getRepairCrewCount() + 1)
                        comms_target.comms_data.available_repair_crew = comms_target.comms_data.available_repair_crew - 1
                        if comms_target.comms_data.available_repair_crew <= 0 then
                            comms_target.comms_data.new_repair_crew_delay = getScenarioTime() + random(200,500)
                        end
                        local repair_crew_hired = {
                            "Repair crew member hired",
                            "Repair crew member recruited",
                            string.format("%s has a new repair crew member",comms_source:getCallSign()),
                            string.format("Your new repair crew member boards %s and heads down to damage control",comms_source:getCallSign()),
                        }
                        setCommsMessage(tableSelectRandom(repair_crew_hired))
                        comms_target.comms_data.crew_available_delay_reason = nil
                    end
                    addCommsReply(string.format("Back to %s",comms_source.repairCrewCoolantReturn.name),comms_source.repairCrewCoolantReturn.identifier)
                    addCommsReply("Back to interactive relay officer",interactiveDockedStationCommsMeat)
                    addCommsReply(_("Back to station communication"), commsStation)
                end)
                comms_target.comms_data.crew_available_delay = getScenarioTime() + random(90,300)
            else
                local delay_reason = {
                    _("trade-comms","A possible repair recruit is awaiting final certification. They should be available in "),
                    _("trade-comms","There's one repair crew candidate completing their license application. They should be available in "),
                    _("trade-comms","One repair crew should be getting here from their medical checkout in "),
                }
                if comms_target.comms_data.crew_available_delay_reason == nil then
                    comms_target.comms_data.crew_available_delay_reason = delay_reason[math.random(1,#delay_reason)]
                end
                local delay_seconds = math.floor(comms_target.comms_data.crew_available_delay - getScenarioTime())
                setCommsMessage(string.format(_("trade-comms","%s %i seconds"),comms_target.comms_data.crew_available_delay_reason,delay_seconds))
            end
            addCommsReply(string.format("Back to %s",comms_source.repairCrewCoolantReturn.name),comms_source.repairCrewCoolantReturn.identifier)
            addCommsReply("Back to interactive relay officer",interactiveDockedStationCommsMeat)
            addCommsReply(_("Back to station communication"), commsStation)
        end)
    end
    return presented_option
end
function getCoolantFromStation(relationship)
    local presented_option = false
    if comms_target.comms_data.coolant_inventory == nil then
        comms_target.comms_data.coolant_inventory = math.random(0,5)*2
        comms_target.comms_data.coolant_inventory_cost_friendly_needy_over_66 = math.random(30,60)
        comms_target.comms_data.coolant_inventory_cost_neutral_needy_over_66 = math.random(45,90)
        comms_target.comms_data.coolant_inventory_excess = math.random(15,30)
        comms_target.comms_data.coolant_inventory_under_66 = math.random(15,30)
        print(comms_target:getCallSign(),"coolant inventory:",comms_target.comms_data.coolant_inventory)
    end
    if comms_source.initialCoolant ~= nil and comms_target.comms_data.coolant_inventory > 0 then
        presented_option = true
        local get_coolant_prompts = {
            "Purchase coolant",
            "Get more coolant",
            string.format("Get coolant from %s",comms_target:getCallSign()),
            string.format("Ask for more coolant from %s",comms_target:getCallSign()),
        }
        addCommsReply(tableSelectRandom(get_coolant_prompts),function()
            if comms_target.comms_data.coolant_inventory_delay == nil or getScenarioTime() > comms_target.comms_data.coolant_inventory_delay then
                local coolant_cost = 0
                if comms_source:isFriendly(comms_target) then
                    coolant_cost = comms_target.comms_data.coolant_inventory_cost_friendly_needy_over_66
                else
                    coolant_cost = comms_target.comms_data.coolant_inventory_cost_neutral_needy_over_66
                end
                if comms_target.comms_data.friendlyness <= 66 then
                    coolant_cost = coolant_cost + comms_target.comms_data.coolant_inventory_under_66
                end
                if comms_source:getMaxCoolant() >= comms_source.initialCoolant then
                    coolant_cost = coolant_cost + comms_target.comms_data.coolant_inventory_excess
                end
                local coolant_banter = {
                    "So you want to cool off even more, eh?",
                    "Ship getting too hot for you?",
                    string.format("What makes %s so hot that you need more coolant?",comms_source:getCallSign()),
                    string.format("Is %s experiencing drought conditions?",comms_source:getCallSign()),
                }
                setCommsMessage(tableSelectRandom(coolant_banter))
                local purchase_coolant_prompts = {
                    string.format("Purchase coolant for %i reputation",coolant_cost),
                    string.format("Get additional coolant for %i reputation",coolant_cost),
                    string.format("Purchase coolant from %s (%i reputation)",comms_target:getCallSign(),coolant_cost),
                    string.format("Get coolant from %s for %i reputation",comms_target:getCallSign(),coolant_cost),
                }
                addCommsReply(tableSelectRandom(purchase_coolant_prompts),function()
                    if not comms_source:isDocked(comms_target) then
                        local stay_docked_to_get_coolant = {
                            "You need to stay docked for that action.",
                            "You need to stay docked to get coolant.",
                            string.format("You must stay docked long enough for your coolant to be loaded on to %s",comms_source:getCallSign()),
                            string.format("You undocked before the coolant you wanted could be loaded from %s",comms_target:getCallSign()),
                        }
                        setCommsMessage(tableSelectRandom(stay_docked_to_get_coolant))
                        return
                    end
                    if not comms_source:takeReputationPoints(coolant_cost) then
                        local insufficient_rep_responses = {
                            "Insufficient reputation",
                            "Not enough reputation",
                            "You need more reputation",
                            string.format("You need more than %i reputation",math.floor(comms_source:getReputationPoints())),
                            "You don't have enough reputation",
                        }
                        setCommsMessage(tableSelectRandom(insufficient_rep_responses))
                    else
                        comms_source:setMaxCoolant(comms_source:getMaxCoolant() + 2)
                        comms_target.comms_data.coolant_inventory = comms_target.comms_data.coolant_inventory - 2
                        local got_coolant_confirmation = {
                            "Additional coolant purchased",
                            "You got more coolant",
                            string.format("%s has loaded additional coolant onto %s",comms_target:getCallSign(),comms_source:getCallSign()),
                            string.format("%s has provided you with some additional coolant",comms_target:getCallSign()),
                        }
                        setCommsMessage(tableSelectRandom(got_coolant_confirmation))
                        comms_target.comms_data.coolant_delay_reason = nil
                    end
                    addCommsReply(string.format("Back to %s",comms_source.repairCrewCoolantReturn.name),comms_source.repairCrewCoolantReturn.identifier)
                    addCommsReply("Back to interactive relay officer",interactiveDockedStationCommsMeat)
                    addCommsReply(_("Back to station communication"), commsStation)
                end)
                comms_target.comms_data.coolant_inventory_delay = getScenarioTime() + random(90,300)
            else
                local coolant_delay_reason = {
                    _("trade-comms","We are in the process of making more coolant. It should be available in "),
                    _("trade-comms","More coolant should be available in "),
                    _("trade-comms","We can get more coolant. Check back in "),
                }
                if comms_target.comms_data.coolant_delay_reason == nil then
                    comms_target.comms_data.coolant_delay_reason = tableSelectRandom(coolant_delay_reason)
                end
                local delay_seconds = math.floor(comms_target.comms_data.coolant_inventory_delay - getScenarioTime())
                setCommsMessage(string.format(_("trade-comms","%s %i seconds"),comms_target.comms_data.coolant_delay_reason,delay_seconds))
            end
            addCommsReply(string.format("Back to %s",comms_source.repairCrewCoolantReturn.name),comms_source.repairCrewCoolantReturn.identifier)
            addCommsReply("Back to interactive relay officer",interactiveDockedStationCommsMeat)
            addCommsReply(_("Back to station communication"), commsStation)
        end)
    end
    return presented_option
end
--[[ RM
function getReplacementFighterFromStation(relationship)
    local presented_option = false
    if #comms_source.carrier_ship_inventory > 0 then
        local ship_capacity = 0
        local ship_inventory = 0
        local replacement_templates = {}
        for i,carrier_ship in ipairs(comms_source.carrier_ship_inventory) do
            if carrier_ship.state == "deployed" then
                if carrier_ship.ship ~= nil and carrier_ship.ship:isValid() then
                    ship_inventory = ship_inventory + 1
                else
                    table.insert(replacement_templates,carrier_ship.template)
                end
                ship_capacity = ship_capacity + 1
            else
                ship_capacity = ship_capacity + 1
                ship_inventory = ship_inventory + 1
            end
        end
        if ship_capacity > ship_inventory then
            presented_option = true
            addCommsReply("Replace fighter",function()
                setCommsMessage("Feature under construction. Talk to GM")
                if comms_target.replacement_fighters == nil then
                    comms_target.replacement_fighters = {}
                    for i,template in ipairs(replacement_templates) do
                        table.insert(comms_target.replacement_fighters,{template = template, quantity = math.random(1,3), cost = math.floor(playerShipStats[template].strength * random(3,5))})
                    end
                    local template_pool = {}
                    for template,details in pairs(comms_source.carrier_ship_types) do
                        if details.carry then
                            local in_replacement_list = false
                            for i,replacement in ipairs(comms_target.replacement_fighters) do
                                if replacement.template == template then
                                    in_replacement_list = true
                                    break
                                end
                            end
                            if not in_replacement_list then
                                table.insert(template_pool,template)
                            end
                        end
                    end
                    if random(1,100) < 63 then
                        local selected_template = tableRemoveRandom(template_pool)
                        table.insert(comms_target.replacement_fighters,{template = selected_template, quantity = math.random(1,3), cost = math.floor(playerShipStats[selected_template].strength * random(3,5))})
                        if random(1,100) < 21 then
                            selected_template = tableRemoveRandom(template_pool)
                            table.insert(comms_target.replacement_fighters,{template = selected_template, quantity = math.random(1,3), cost = math.floor(playerShipStats[selected_template].strength * random(3,5))})
                        end
                    end
                end
                print("replacement fighters at",comms_target:getCallSign())
                for i,replacement in ipairs(comms_target.replacement_fighters) do
                    print(replacement.template,"quantity:",replacement.quantity,"cost:",replacement.cost)
                end
                local fighter_available_count = 0
                local unique_templates_available = 0
                for i,replacement in ipairs(comms_target.replacement_fighters) do
                    if replacement.quantity > 0 then
                        unique_templates_available = unique_templates_available + 1
                        fighter_available_count = fighter_available_count + replacement.quantity
                        addCommsReply(string.format("%s %i reputation",replacement.template,replacement.cost),function()
                            if comms_source:takeReputationPoints(replacement.cost) then
                                for i,carrier_ship in ipairs(comms_source.carrier_ship_inventory) do
                                    if carrier_ship.state == "deployed" then
                                        if carrier_ship.ship == nil or not carrier_ship.ship:isValid() then
                                            comms_source.carrier_ship_inventory[i] = comms_source.carrier_ship_inventory[#comms_source.carrier_ship_inventory]
                                            comms_source.carrier_ship_inventory[#comms_source.carrier_ship_inventory] = nil
                                            break
                                        end
                                    end
                                end
                                local ship = comms_source.carrier_ship_types[replacement.template]
                                local ship_name = tableRemoveRandom(carrier_ship_names[replacement.template])
                                if ship_name == nil then
                                    local class_pool = {}
                                    for ship_type_name,ship_type_details in pairs(p.carrier_ship_types) do
                                        if ship.class == ship_type_details.class then
                                            if #carrier_ship_names[ship_type_name] > 0 then
                                                table.insert(class_pool,ship_type_name)
                                            end
                                        end
                                    end
                                    local selected_template = tableRemoveRandom(class_pool)
                                    ship_name = tableRemoveRandom(carrier_ship_names[selected_template])
                                end
                                table.insert(comms_source.carrier_ship_inventory,{
                                    class = ship.class, 
                                    template = ship.name, 
                                    name = ship_name, 
                                    state = "aboard", 
                                    launch_button = string.format("launch_%s",ship_name),
                                    launch_time = carrier_class_launch_time[ship.class],
                                })
                                setCommsMessage(string.format("%s is part of your fighter inventory",ship_name))
                            else
                                setCommsMessage("Insufficient reputation")
                            end
                        end)
                    end
                end
                setCommsMessage(string.format("%i fighters available, %i different types",fighter_available_count,unique_templates_available))
                addCommsReply("Back to interactive relay officer",interactiveDockedStationCommsMeat)
                addCommsReply(_("Back to station communication"), commsStation)
            end)
        end
    end
    return presented_option
end--]]
function repairShip()
    local repair_type_prompt = {
        _("station-comms","What kind of repairs do you need?"),
        _("station-comms","What kind of repairs can we help you with?"),
        _("station-comms","We might be able to help. Let us know what you need."),
    }
    setCommsMessage(tableSelectRandom(repair_type_prompt))
    local options_presented_count = 0
    --    secondary system repair
    local secondary_system = {
        {prompt = _("stationServices-comms","Repair probe launch system (%s Rep)"),    capable = true,    station_avail = comms_target.comms_data.probe_launch_repair,    cost = comms_target.comms_data.service_cost.probe_launch_repair,    ship_avail = comms_source:getCanLaunchProbe(),        enable = "setCanLaunchProbe",    response = _("stationServices-comms", "Your probe launch system has been repaired.")},
        {prompt = _("stationServices-comms","Repair hacking system (%s Rep)"),        capable = true,    station_avail = comms_target.comms_data.hack_repair,            cost = comms_target.comms_data.service_cost.hack_repair,            ship_avail = comms_source:getCanHack(),                enable = "setCanHack",            response = _("stationServices-comms", "Your hacking system has been repaired.")},
        {prompt = _("stationServices-comms","Repair scanning system (%s Rep)"),        capable = true,    station_avail = comms_target.comms_data.scan_repair,            cost = comms_target.comms_data.service_cost.scan_repair,            ship_avail = comms_source:getCanScan(),                enable = "setCanScan",            response = _("stationServices-comms", "Your scanners have been repaired.")},
        {prompt = _("stationServices-comms","Repair combat maneuver (%s Rep)"),        capable = true,    station_avail = comms_target.comms_data.combat_maneuver_repair,    cost = comms_target.comms_data.service_cost.combat_maneuver_repair,    ship_avail = comms_source:getCanCombatManeuver(),    enable = "setCanCombatManeuver",response = _("stationServices-comms", "Your combat maneuver has been repaired.")},
        {prompt = _("stationServices-comms","Repair self destruct system (%s Rep)"),capable = true,    station_avail = comms_target.comms_data.self_destruct_repair,    cost = comms_target.comms_data.service_cost.self_destruct_repair,    ship_avail = comms_source:getCanSelfDestruct(),        enable = "setCanSelfDestruct",    response = _("stationServices-comms", "Your self destruct system has been repaired.")},
    }
    for i,sec in ipairs(secondary_system) do
        print(string.format(sec.prompt,sec.cost),sec.station_avail,sec.cost,sec.ship_avail,sec.response)
    end
    local offer_repair = false
    for i,secondary in ipairs(secondary_system) do
        if secondary.station_avail and not secondary.ship_avail and secondary.capable then
            offer_repair = true
            break
        end
    end
    if offer_repair then
        options_presented_count = options_presented_count + 1
        local repair_secondary_prompts = {
            "Repair secondary ship system",
            "Make repairs to secondary ship system",
            "Fix secondary ship system",
            "Request repairs to secondary ship system",
        }
        addCommsReply(tableSelectRandom(repair_secondary_prompts),function()
            local which_secondary_system = {
                "What system would you like repaired?",
                "What system needs fixing?",
                "Please identify the secondary system that is in need of repair",
                string.format("Poor, poor %s. What part of her is hurting now?",comms_source:getCallSign()),
            }
            setCommsMessage(tableSelectRandom(which_secondary_system))
            local secondary_options_presented_count = 0
            for i,secondary in ipairs(secondary_system) do
                if not secondary.ship_avail then
                    if secondary.capable then
                        secondary_options_presented_count = secondary_options_presented_count + 1
                        addCommsReply(string.format(secondary.prompt,secondary.cost),function()
                            if not comms_source:isDocked(comms_target) then
                                local stay_docked_to_get_repaired = {
                                    "You need to stay docked for that action.",
                                    "You need to stay docked to get repairs.",
                                    string.format("You must stay docked long enough for repairs to %s to be completed.",comms_source:getCallSign()),
                                    string.format("You undocked before %s could complete the repairs you wanted.",comms_target:getCallSign()),
                                }
                                setCommsMessage(tableSelectRandom(stay_docked_to_get_repaired))
                                return
                            end
                            if comms_source:takeReputationPoints(secondary.cost) then
                                if secondary.enable == "setCanLaunchProbe" then
                                    comms_source:setCanLaunchProbe(true)
                                elseif secondary.enable == "setCanHack" then
                                    comms_source:setCanHack(true)
                                elseif secondary.enable == "setCanScan" then
                                    comms_source:setCanScan(true)
                                elseif secondary.enable == "setCanCombatManeuver" then
                                    comms_source:setCanCombatManeuver(true)
                                elseif secondary.enable == "setCanSelfDestruct" then
                                    comms_source:setCanSelfDestruct(true)
                                end
                                setCommsMessage(secondary.response)
                            else
                                local insufficient_rep_responses = {
                                    "Insufficient reputation",
                                    "Not enough reputation",
                                    "You need more reputation",
                                    string.format("You need more than %i reputation",math.floor(comms_source:getReputationPoints())),
                                    "You don't have enough reputation",
                                }
                                setCommsMessage(tableSelectRandom(insufficient_rep_responses))
                            end
                            addCommsReply(_("Back"), commsStation)
                        end)
                    end
                end
            end
        end)
    end
    --    primary system repair
    local system_repair_list = {}
    offer_repair = false
    if comms_target.comms_data.system_repair ~= nil then
        for i, system in ipairs(system_list) do
            if comms_source:hasSystem(system) then
                if comms_source:getSystemHealthMax(system) < 1 then
                    if comms_target.comms_data.system_repair[system].avail then
                        if comms_target.comms_data.system_repair[system].cost > 0 then
                            if comms_target.player_system_repair_service == nil then
                                offer_repair = true
                                table.insert(system_repair_list,system)
                            else
                                if comms_target.player_system_repair_service[comms_source] == nil then
                                    offer_repair = true
                                    table.insert(system_repair_list,system)
                                else
                                    if comms_target.player_system_repair_service[comms_source][system] == nil then
                                        offer_repair = true
                                        table.insert(system_repair_list,system)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    if offer_repair then
        options_presented_count = options_presented_count + 1
        local primary_repair_prompt = {
            "Repair primary ship system",
            "Make repairs to primary ship system",
            string.format("Fix primary system on %s",comms_source:getCallSign()),
            "Fix primary ship system",
        }
        addCommsReply(tableSelectRandom(primary_repair_prompt),function()
            local what_primary_system = {
                "What system would you like repaired?",
                "What system is in need of repair?",
                string.format("What severe wounds on %s can %s help heal?",comms_source:getCallSign(),comms_target:getCallSign()),
                string.format("What primary ship system can %s work on to bring %s back into good working order?",comms_target:getCallSign(),comms_source:getCallSign()),
            }
            setCommsMessage(what_primary_system[math.random(1,#what_primary_system)])
            for index, system in ipairs(system_repair_list) do
                addCommsReply(string.format(_("stationServices-comms","Repair %s max health up to %.1f%% (%i rep)"),pretty_system[system],comms_target.comms_data.system_repair[system].max*100,comms_target.comms_data.system_repair[system].cost), function()
                    if comms_source:takeReputationPoints(comms_target.comms_data.system_repair[system].cost) then
                        if comms_target.player_system_repair_service == nil then
                            comms_target.player_system_repair_service = {}
                        end
                        if comms_target.player_system_repair_service[comms_source] == nil then
                            comms_target.player_system_repair_service[comms_source] = {}
                        end
                        comms_target.player_system_repair_service[comms_source][system] = true
                        local working_on_system = {
                            string.format("We'll start working on your %s maximum health right away.",pretty_system[system]),
                            string.format("We will put %s repair technicians to work on your %s maximum health immediately.",comms_target:getCallSign(),pretty_system[system]),
                            string.format("%s has put repair technicians to work on %s's %s maximum health.",comms_target:getCallSign(),comms_source:getCallSign(),pretty_system[system]),
                            string.format("We put our most qualified repair technicians to work on your %s maximum health.",pretty_system[system]),
                        }
                        setCommsMessage(working_on_system[math.random(1,#working_on_system)])
                    else
                        local insufficient_rep_responses = {
                            "Insufficient reputation",
                            "Not enough reputation",
                            "You need more reputation",
                            string.format("You need more than %i reputation",math.floor(comms_source:getReputationPoints())),
                            "You don't have enough reputation",
                        }
                        setCommsMessage(insufficient_rep_responses[math.random(1,#insufficient_rep_responses)])
                    end
                    addCommsReply(_("Back"), commsStation)
                end)
            end
        end)
    end
    if options_presented_count == 0 then
        local no_applicable_repair_service = {
            "No applicable repair service available",
            string.format("%s has no repair service that %s can use",comms_target:getCallSign(),comms_source:getCallSign()),
            "There's no repair service here that applies to your ship",
            string.format("There's nothing on %s that %s can repair",comms_source:getCallSign(),comms_target:getCallSign()),
        }
        setCommsMessage(tableSelectRandom(no_applicable_repair_service))
    end
    addCommsReply("Back to interactive relay officer",interactiveDockedStationCommsMeat)
    addCommsReply("Back to station communication",commsStation)
end
function enhanceShip()
    comms_source.repairCrewCoolantReturn = {identifier=enhanceShip,name="enhance ship"}
    local enhance_type_prompt = {
        _("station-comms","What kind of enhancements are you interested in?"),
        _("station-comms","Which of these enhancements might you interested in?"),
        _("station-comms","Which kind of enhancement do you crave?"),
        _("station-comms","What enhancement type do you want?"),
    }
    setCommsMessage(tableSelectRandom(enhance_type_prompt))
    local presented_option = false
    if comms_source:isFriendly(comms_target) then
        presented_option = getRepairCrewFromStation("friendly") or presented_option
        presented_option = getCoolantFromStation("friendly") or presented_option
    else
        presented_option = getRepairCrewFromStation("neutral") or presented_option
        presented_option = getCoolantFromStation("neutral") or presented_option
    end
--RM    presented_option = minorUpgrades() or presented_option
    presented_option = overchargeShipSystems() or presented_option
--[[RM
	if comms_target.comms_data.sensor_boost ~= nil then
        if comms_target.comms_data.sensor_boost.cost > 0 then
            boostSensorsWhileDocked()
            presented_option = true
        end
    end
    if comms_source.security_morale < 1 then
        if #security_morale_boosters > 0 then
            if comms_target.security_training == nil then
                comms_target.security_training = (random(1,100) < 77)
            end
            if comms_target.security_training then
                increaseSecurityMorale()
                presented_option = true
            end
        end
    end
    if comms_target.comms_data.fast_probes ~= nil or comms_target.comms_data.remote_warp_jammer ~= nil or comms_target.comms_data.sensor_boost_probes ~= nil or comms_target.comms_data.mine_probes ~= nil then
        if (comms_target.comms_data.fast_probes ~= nil and comms_target.comms_data.fast_probes.quantity > 0) or 
           (comms_target.comms_data.remote_warp_jammer ~= nil and comms_target.comms_data.remote_warp_jammer.quantity > 0) or
           (comms_target.comms_data.sensor_boost_probes ~= nil and comms_target.comms_data.sensor_boost_probes.quantity > 0) or
           (comms_target.comms_data.mine_probes ~= nil and comms_target.comms_data.mine_probes.quantity > 0) then
                   getSpecialtyProbes()
                   presented_option = true
        end
    end
	--]]
    if not presented_option then
        local no_applicable_enhancements = {
            "No ship enhancements available",
            string.format("%s has no ship enhancements available for %s",comms_target:getCallSign(),comms_source:getCallSign()),
            string.format("%s cannot benefit from any ship enhancement on %s",comms_source:getCallSign(),comms_target:getCallSign()),
            string.format("No ship enhancements available for %s on %s",comms_source:getCallSign(),comms_target:getCallSign()),
        }
        setCommsMessage(tableSelectRandom(no_applicable_enhancements))
    end
    addCommsReply("Back to interactive relay officer",interactiveDockedStationCommsMeat)
    addCommsReply(_("Back to station communication"), commsStation)
end
--[[ RM
function presentProximityScanner()
    local proximity_scanner_prompt = {
        "Spare portable automatic proximity scanner",
        "Detachable automatic proximity scanner",
        "Off the shelf automatic proximity scanner",
        "After market automatic proximity scanner",
    }
    addCommsReply(tableSelectRandom(proximity_scanner_prompt),function()
        local proximity_scanner_explained = {
            string.format("We've got this portable automatic proximity scanner here. They are very popular. It automatically performs a simple scan on ships in range (%iU). Would you like to have this installed?",comms_target.proximity_scanner_range),
            string.format("We have an automatic proximity scanner that we are not using. These things are pretty popular right now. When a ship gets in range (%iU), it automatically and instantly performs a simple scan on the ship. Would you like for us to install it on %s?",comms_target.proximity_scanner_range,comms_source:getCallSign()),
            string.format("Available for a limited time, we have the ever popular automatic proximity scanner. Install this baby and ships are instantly and automatically simple scanned when they get in range (%iU). Do you want it installed?",comms_target.proximity_scanner_range),
            string.format("The %s quartermaster tells me that there's a spare automatic proximity scanner without a ship designated for installation. These automated proximity scanners are very popular. They instantly and automatically scan ships that are in range (%iU). Would you like it installed on %s?",comms_target:getCallSign(),comms_target.proximity_scanner_range,comms_source:getCallSign()),
        }
        setCommsMessage(tableSelectRandom(proximity_scanner_explained))
        local price_per_range_unit = 25
        local install_proximity_scanner = {
            string.format("We'll take it (%i reputation)",comms_target.proximity_scanner_range * price_per_range_unit),
            string.format("Install it, please (%i reputation)",comms_target.proximity_scanner_range * price_per_range_unit),
            string.format("It's perfect! Install it (%i reputation)",comms_target.proximity_scanner_range * price_per_range_unit),
            string.format("We could use that. Please install it (%i reputation)",comms_target.proximity_scanner_range * price_per_range_unit),
        }
        addCommsReply(tableSelectRandom(install_proximity_scanner),function()
            if comms_source:takeReputationPoints(comms_target.proximity_scanner_range * price_per_range_unit) then
                local temp_prox_scan = comms_source.prox_scan
                comms_source.prox_scan = comms_target.proximity_scanner_range
                if temp_prox_scan ~= nil and temp_prox_scan > 0 then
                    comms_target.proximity_scanner_range = temp_prox_scan
                else
                    comms_target.proximity_scanner = false
                    comms_target.proximity_scanner_range = nil
                end
                local proximity_scanner_installed_confirmation = {
                    "Installed",
                    string.format("%s has installed the automatic proximity scanner",comms_target:getCallSign()),
                    "It's installed",
                    string.format("%s now has an automatic proximity scanner",comms_source:getCallSign()),
                }
                setCommsMessage(tableSelectRandom(proximity_scanner_installed_confirmation))
            else
                local insufficient_rep_responses = {
                    "Insufficient reputation",
                    "Not enough reputation",
                    "You need more reputation",
                    string.format("You need more than %i reputation",math.floor(comms_source:getReputationPoints())),
                    "You don't have enough reputation",
                }
                setCommsMessage(tableSelectRandom(insufficient_rep_responses))
            end
            addCommsReply("Back to enhance ship",enhanceShip)
            addCommsReply("Back to interactive relay officer",interactiveDockedStationCommsMeat)
            addCommsReply(_("Back to station communication"), commsStation)
        end)
        addCommsReply("Back to enhance ship",enhanceShip)
        addCommsReply("Back to interactive relay officer",interactiveDockedStationCommsMeat)
        addCommsReply(_("Back to station communication"), commsStation)
    end)
end
function presentMaxHealthWidgets()
    local max_health_widget_prompts = {
        "Spare portable max health diagnostic",
        "Detachable max health diagnostic",
        "Off the shelf max health diagnostic",
        "After market max health diagnostic",
    }
    addCommsReply(tableSelectRandom(max_health_widget_prompts),function()
        local max_health_diagnostic_explained = {
            "There's a portable max health diagnostic here that we are not using. Engineers use these to keep close watch on severely damaged systems. Would you like to get this for your engineer?",
            "We've got a max health diagnostic unit here that we are not using. Engineers use these things to keep a close eye on systems that have been severely damaged. Do you think your engineer might want this?",
            "We've got an unused max health diagnostic. It's used by engineers to monitor severely damaged systems. Do you want to get this for your engineer?",
            "We have a spare max health diagnostic unit. Your engineer can use it to monitor severely damaged systems. Interested?",
        }
        setCommsMessage(tableSelectRandom(max_health_diagnostic_explained))
        local get_max_health_diagnostic_prompt = {
            "Yes, that's a great gift (5 reputation)",
            "Yes! Our engineer would love that (5 reputation)",
            "We'll take it (5 reputation)",
            "Please install it (5 reputation)",
        }
        addCommsReply(tableSelectRandom(get_max_health_diagnostic_prompt),function()
            if comms_source:takeReputationPoints(5) then
                comms_source.max_health_widgets = true
                comms_target.max_health_widgets = false
                local max_health_installed_confirmation = {
                    "Installed",
                    string.format("%s has installed the max health diagnostic unit",comms_target:getCallSign()),
                    "It's installed",
                    string.format("%s now has a max health diagnostic unit",comms_source:getCallSign()),
                }
                setCommsMessage(tableSelectRandom(max_health_installed_confirmation))
            else
                local insufficient_rep_responses = {
                    "Insufficient reputation",
                    "Not enough reputation",
                    "You need more reputation",
                    string.format("You need more than %i reputation",math.floor(comms_source:getReputationPoints())),
                    "You don't have enough reputation",
                }
                setCommsMessage(tableSelectRandom(insufficient_rep_responses))
            end
            addCommsReply("Back to enhance ship",enhanceShip)
            addCommsReply("Back to interactive relay officer",interactiveDockedStationCommsMeat)
            addCommsReply(_("Back to station communication"), commsStation)
        end)
        addCommsReply("Back to enhance ship",enhanceShip)
        addCommsReply("Back to interactive relay officer",interactiveDockedStationCommsMeat)
        addCommsReply(_("Back to station communication"), commsStation)
    end)
end
function presentShieldBanner()
    local shield_diagnostic_prompts = {
        "Spare portable shield diagnostic",
        "Detachable shield diagnostic",
        "Off the shelf shield diagnostic",
        "After market shield diagnostic",
    }
    addCommsReply(tableSelectRandom(shield_diagnostic_prompts),function()
        local shield_diagnostic_explained = {
            "We've got a spare portable shield diagnostic if you're interested. Engineers use these to get raw data on shield status. Why? well, sometimes they prefer the raw numbers over the normal percentages that appear. Would you like to get this for your engineer?",
            "We have a shield diagnostic unit without a home. Engineers that prefer raw numbers over the standard percentage values like this tool. Would you like to get this for your engineer?",
            string.format("There's a shield diagnostic unit here that could be installed on %s. Some engineers like the raw numbers it provides better than the standard percentage values. Do you want it installed for your engineer?",comms_source:getCallSign()),
            "We've got a shield diagnostic unit without a designated ship installation slot. What does it do? Well, it provides a readout in raw numbers for the state of the shields rather than the typical percentage value. Some engineers prefer the raw numbers. Do you think your engineer might want this tool?",
        }
        setCommsMessage(tableSelectRandom(shield_diagnostic_explained))
        local install_shield_diagnostic_confirmation_prompt = {
            "Yes, that's a perfect gift (5 reputation)",
            "Yes! Our engineer would love that (5 reputation)",
            "We'll take it (5 reputation)",
            "Please install it (5 reputation)",
        }
        addCommsReply(tableSelectRandom(install_shield_diagnostic_confirmation_prompt),function()
            if comms_source:takeReputationPoints(5) then
                comms_source.shield_banner = true
                comms_target.shield_banner = false
                local shield_diagnostic_installed_confirmation = {
                    "Installed",
                    string.format("%s has installed the shield diagnostic unit",comms_target:getCallSign()),
                    "It's installed",
                    string.format("%s now has a shield diagnostic unit",comms_source:getCallSign()),
                }
                setCommsMessage(tableSelectRandom(shield_diagnostic_installed_confirmation))
            else
                local insufficient_rep_responses = {
                    "Insufficient reputation",
                    "Not enough reputation",
                    "You need more reputation",
                    string.format("You need more than %i reputation",math.floor(comms_source:getReputationPoints())),
                    "You don't have enough reputation",
                }
                setCommsMessage(tableSelectRandom(insufficient_rep_responses))
            end
            addCommsReply("Back to enhance ship",enhanceShip)
            addCommsReply("Back to interactive relay officer",interactiveDockedStationCommsMeat)
            addCommsReply(_("Back to station communication"), commsStation)
        end)
        addCommsReply("Back to enhance ship",enhanceShip)
        addCommsReply("Back to interactive relay officer",interactiveDockedStationCommsMeat)
        addCommsReply(_("Back to station communication"), commsStation)
    end)
end
function presentHullBanner()
    local hull_diagnostic_prompts = {
        "Spare portable hull diagnostic",
        "Detachable hull diagnostic",
        "Off the shelf hull diagnostic",
        "After market hull diagnostic",
    }
    addCommsReply(tableSelectRandom(hull_diagnostic_prompts),function()
        local hull_diagnostic_explained = {
            "We've got a spare portable hull diagnostic if you're interested. Engineers use these to get raw data on hull status. Why? well, sometimes they prefer the raw numbers over the normal percentages that appear. Would you like to get this for your engineer?",
            "We have a hull diagnostic unit without a home. Engineers that prefer raw hull status numbers over the standard percentage values like this tool. Would you like to get this for your engineer?",
            string.format("There's a hull diagnostic unit here that could be installed on %s. Some engineers like the raw numbers it provides better than the standard percentage values. Do you want it installed for your engineer?",comms_source:getCallSign()),
            "We've got a hull diagnostic unit without a designated ship installation slot. What does it do? Well, it provides a readout in raw numbers for the state of the hull rather than the typical percentage value. Some engineers prefer the raw numbers. Do you think your engineer might want this tool?",
        }
        setCommsMessage(tableSelectRandom(hull_diagnostic_explained))
        local install_hull_diagnostic_confirmation_prompt = {
            "Yes, that's a perfect gift (5 reputation)",
            "Yes! Our engineer would love that (5 reputation)",
            "We'll take it (5 reputation)",
            "Please install it (5 reputation)",
        }
        addCommsReply(tableSelectRandom(install_hull_diagnostic_confirmation_prompt),function()
            if comms_source:takeReputationPoints(5) then
                comms_source.hull_banner = true
                comms_target.hull_banner = false
                local hull_diagnostic_installed_confirmation = {
                    "Installed",
                    string.format("%s has installed the hull diagnostic unit",comms_target:getCallSign()),
                    "It's installed",
                    string.format("%s now has a hull diagnostic unit",comms_source:getCallSign()),
                }
                setCommsMessage(tableSelectRandom(hull_diagnostic_installed_confirmation))
            else
                local insufficient_rep_responses = {
                    "Insufficient reputation",
                    "Not enough reputation",
                    "You need more reputation",
                    string.format("You need more than %i reputation",math.floor(comms_source:getReputationPoints())),
                    "You don't have enough reputation",
                }
                setCommsMessage(tableSelectRandom(insufficient_rep_responses))
            end
            addCommsReply("Back to enhance ship",enhanceShip)
            addCommsReply("Back to interactive relay officer",interactiveDockedStationCommsMeat)
            addCommsReply(_("Back to station communication"), commsStation)
        end)
        addCommsReply("Back to enhance ship",enhanceShip)
        addCommsReply("Back to interactive relay officer",interactiveDockedStationCommsMeat)
        addCommsReply(_("Back to station communication"), commsStation)
    end)
end
function presentWaypointDistanceCalculator()
    local waypoint_distance_calc_prompts = {
        "Spare waypoint distance calculator",
        "Detachable waypoint distance calculator",
        "Off the shelf waypoint distance calculator",
        "After market waypoint distance calculator",
    }
    addCommsReply(tableSelectRandom(waypoint_distance_calc_prompts),function()
        local waypoint_distance_calc_explained = {
            "We've got a spare portable waypoint distance calculator if you're interested. Helm or Tactical officers use this to get hyper accurate distance calculations for waypoints placed by Relay or Operations. Would you like to get this for helm/tactical?",
            "We have an unused waypoint distance calculator. Your helm or tactical officer could use this to get hyper-accurate distance calculations for any waypoints placed by your relay or operations officer. Would you like this installed for helm/tactical?",
            "There's a waypoint distance calculator here that could use a home. It's a device used by helm or tactical to calculat hyper accurate distances for waypoints. Interested?",
            string.format("We have a waypoint distance calculator begging to be installed on %s. Helm or Tactical use it for extremely accurate distance calculations on waypoints placed by Relay or Operations. Would this be useful for you?",comms_source:getCallSign()),
        }
        setCommsMessage(tableSelectRandom(waypoint_distance_calc_explained))
        local install_waypoint_distance_calc_confirmation_prompt = {
            "Yes, that's a perfect gift (5 reputation)",
            "We'll take it (5 reputation)",
            "Please install it (5 reputation)",
        }
        if comms_source:hasPlayerAtPosition("Helms") then
            if comms_source:hasPlayerAtPosition("Tactical") then
                table.insert(install_waypoint_distance_calc_confirmation_prompt,"Yes! Helm/Tactical would love that (5 reputation)")
            else
                table.insert(install_waypoint_distance_calc_confirmation_prompt,"Yes! Helm would love that (5 reputation)")
            end
        elseif comms_source:hasPlayerAtPosition("Tactical") then
            table.insert(install_waypoint_distance_calc_confirmation_prompt,"Yes! Tactical would love that (5 reputation)")
        end
        addCommsReply(tableSelectRandom(install_waypoint_distance_calc_confirmation_prompt),function()
            if comms_source:takeReputationPoints(5) then
                comms_source.way_dist = true
                comms_target.way_dist = false
                local waypoint_distance_calc_installed_confirmation = {
                    "Installed",
                    string.format("%s has installed the waypoint distance calculator",comms_target:getCallSign()),
                    "It's installed",
                    string.format("%s now has a waypoint distance calculator",comms_source:getCallSign()),
                }
                setCommsMessage(tableSelectRandom(waypoint_distance_calc_installed_confirmation))
            else
                local insufficient_rep_responses = {
                    "Insufficient reputation",
                    "Not enough reputation",
                    "You need more reputation",
                    string.format("You need more than %i reputation",math.floor(comms_source:getReputationPoints())),
                    "You don't have enough reputation",
                }
                setCommsMessage(tableSelectRandom(insufficient_rep_responses))
            end
            addCommsReply("Back to enhance ship",enhanceShip)
            addCommsReply("Back to interactive relay officer",interactiveDockedStationCommsMeat)
            addCommsReply(_("Back to station communication"), commsStation)
        end)
        addCommsReply("Back to enhance ship",enhanceShip)
        addCommsReply("Back to interactive relay officer",interactiveDockedStationCommsMeat)
        addCommsReply(_("Back to station communication"), commsStation)
    end)
end
function presentBoostSensorRangeWithPower()
    local boost_sensors_with_power_prompts = {
        "Sensor power boost",
        "Funnel power to sensors",
        "Power boost to sensors",
        "Use energy to increase sensor range",
    }
    addCommsReply(tableSelectRandom(boost_sensors_with_power_prompts),function()
        local explain_power_sensor_boost = {
            "We've got a device that can draw power from your batteries into the sensors in order to increase sensor range. It's a way for Science and Engineering to work together to temporarily give Science better situational awareness. The device draws a significant amount of power when it's enabled, but it can be enabled and disabled according to the situation. The device has three boost levels to add to current sensor range: level 1 = interval, level 2 = interval X 2, level 3 = interval X 3. The higher the level the more power used. Would you like this device installed?",
            "There is a sensor boosting device here that draws power from the batteries to increase sensor range. Engineering controls whether it is on or off and how strong it is. Science gets a better sensor range while it is enabled. It draws lots of power while enabled, so Engineering should monitor energy use carefully. The device has three boost levels to add to current sensor range: level 1 = interval, level 2 = interval X 2, level 3 = interval X 3. The higher the level the more power used. Interested in installing it?",
            "We can install a device that uses ship batteries to increase sensor range. Engineering activates the device, sets a level and then Science takes advantage of the increased range. If you install it, be careful since it uses a large amount of power. The device has three boost levels to add to current sensor range: level 1 = interval, level 2 = interval X 2, level 3 = interval X 3. The higher the level the more power used. Interested?",
            "We've got a sensor range booster available. It siphons a large amount of power out of the batteries into the sensors to increase sensor range. Engineering activates it, sets the level and deactivates it so that Science can take advantage of the longer sensor range. The sensor range booster has three boost levels to add to current sensor range: level 1 = interval, level 2 = interval X 2, level 3 = interval X 3. The higher the level the more power used. Is this something you are interested in having installed?",
        }
        setCommsMessage(tableSelectRandom(explain_power_sensor_boost))
        for i,sensor_booster in ipairs(comms_target.installable_sensor_boost_ranges) do
            addCommsReply(string.format("Range interval:%sU Reputation:%s",sensor_booster.interval,sensor_booster.cost),function()
                if comms_source:takeReputationPoints(sensor_booster.cost) then
                    comms_source.power_sensor_interval = sensor_booster.interval
                    comms_target.installable_sensor_boost_ranges[i] = comms_target.installable_sensor_boost_ranges[#comms_target.installable_sensor_boost_ranges]
                    comms_target.installable_sensor_boost_ranges[#comms_target.installable_sensor_boost_ranges] = nil
                    if #comms_target.installable_sensor_boost_ranges == 0 then
                        comms_target.installable_sensor_boost = false
                    end
                    local sensor_booster_installed_confirmation = {
                        "Installed",
                        string.format("%s has installed the sensor booster device",comms_target:getCallSign()),
                        "It's installed",
                        string.format("%s now has a powered sensor booster",comms_source:getCallSign()),
                    }
                    setCommsMessage(tableSelectRandom(sensor_booster_installed_confirmation))
                else
                    local insufficient_rep_responses = {
                        "Insufficient reputation",
                        "Not enough reputation",
                        "You need more reputation",
                        string.format("You need more than %i reputation",math.floor(comms_source:getReputationPoints())),
                        "You don't have enough reputation",
                    }
                    setCommsMessage(tableSelectRandom(insufficient_rep_responses))
                end
                addCommsReply("Back to enhance ship",enhanceShip)
                addCommsReply("Back to interactive relay officer",interactiveDockedStationCommsMeat)
                addCommsReply(_("Back to station communication"), commsStation)
            end)
        end
        addCommsReply("Back to enhance ship",enhanceShip)
        addCommsReply("Back to interactive relay officer",interactiveDockedStationCommsMeat)
        addCommsReply(_("Back to station communication"), commsStation)
    end)
end
function presentReturnMaxHealthWidgets()
    local chunk_max_health_prompt = {
        "Give portable max health diagnostic to repair technicians",
        string.format("Donate max health diagnostic unit to %s",comms_target:getCallSign()),
        "Remove max health diagnostic unit. Give it to station",
        string.format("Transfer max health diagnostic unit from %s to station %s",comms_source:getCallSign(),comms_target:getCallSign()),
    }
    addCommsReply(tableSelectRandom(chunk_max_health_prompt),function()
        local max_health_donation_confirmed = {
            string.format("%s thanks you and says they will put it to good use.",comms_target:getCallSign()),
            string.format("Max health diagnostic unit uninstalled from %s. The technicians at %s say, 'Thanks %s. There are a number of other ships that have been asking for this.'",comms_source:getCallSign(),comms_target:getCallSign(),comms_source:getCallSign()),
            string.format("%s thanks you for the donation of the max health diagnostic unit",comms_target:getCallSign()),
            string.format("The max health diagnostic unit has been transferred from your ship to the parts inventory on station %s. They express their gratitude for your donation.",comms_target:getCallSign()),
        }
        setCommsMessage(tableSelectRandom(max_health_donation_confirmed))
        comms_source.max_health_widgets = false
        comms_target.max_health_widgets = true
        comms_target.comms_data.friendlyness = math.min(100,comms_target.comms_data.friendlyness + random(3,9))
		addCommsReply("Back to enhance ship",enhanceShip)
		addCommsReply("Back to interactive relay officer",interactiveDockedStationCommsMeat)
		addCommsReply(_("Back to station communication"), commsStation)
    end)
end
function presentReturnShieldBanner()
    local remove_shield_diagnostic_prompt = {
        "Give portable shield diagnostic to repair technicians",
        string.format("Donate shield diagnostic unit to %s",comms_target:getCallSign()),
        "Remove shield diagnostic unit. Give it to station",
        string.format("Transfer shield diagnostic unit from %s to station %s",comms_source:getCallSign(),comms_target:getCallSign()),
    }
    addCommsReply(tableSelectRandom(remove_shield_diagnostic_prompt),function()
        local shield_diagnostic_donation_confirmed = {
            string.format("%s thanks you and says they will put it to good use.",comms_target:getCallSign()),
            string.format("Shield diagnostic unit uninstalled from %s. The technicians at %s say, 'Thanks %s. There are a number of other ships that have been asking for this.'",comms_source:getCallSign(),comms_target:getCallSign(),comms_source:getCallSign()),
            string.format("%s thanks you for the donation of the shield diagnostic unit",comms_target:getCallSign()),
            string.format("The shield diagnostic unit has been transferred from your ship to the parts inventory on station %s. They express their gratitude for your donation.",comms_target:getCallSign()),
        }
        setCommsMessage(tableSelectRandom(shield_diagnostic_donation_confirmed))
        comms_source.shield_banner = false
        comms_target.shield_banner = true
        comms_target.comms_data.friendlyness = math.min(100,comms_target.comms_data.friendlyness + random(3,9))
		addCommsReply("Back to enhance ship",enhanceShip)
		addCommsReply("Back to interactive relay officer",interactiveDockedStationCommsMeat)
		addCommsReply(_("Back to station communication"), commsStation)
    end)
end
function presentReturnHullBanner()
    local remove_hull_diagnostic_prompt = {
        "Give portable hull diagnostic to repair technicians",
        string.format("Donate hull diagnostic unit to %s",comms_target:getCallSign()),
        "Remove hull diagnostic unit. Give it to station",
        string.format("Transfer hull diagnostic unit from %s to station %s",comms_source:getCallSign(),comms_target:getCallSign()),
    }
    addCommsReply(tableSelectRandom(remove_hull_diagnostic_prompt),function()
        local hull_diagnostic_donation_confirmed = {
            string.format("%s thanks you and says they will put it to good use.",comms_target:getCallSign()),
            string.format("Hull diagnostic unit uninstalled from %s. The technicians at %s say, 'Thanks %s. There are a number of other ships that have been asking for this.'",comms_source:getCallSign(),comms_target:getCallSign(),comms_source:getCallSign()),
            string.format("%s thanks you for the donation of the hull diagnostic unit",comms_target:getCallSign()),
            string.format("The hull diagnostic unit has been transferred from your ship to the parts inventory on station %s. They express their gratitude for your donation.",comms_target:getCallSign()),
        }
        setCommsMessage(tableSelectRandom(hull_diagnostic_donation_confirmed))
        comms_source.hull_banner = false
        comms_target.hull_banner = true
        comms_target.comms_data.friendlyness = math.min(100,comms_target.comms_data.friendlyness + random(3,9))
		addCommsReply("Back to enhance ship",enhanceShip)
		addCommsReply("Back to interactive relay officer",interactiveDockedStationCommsMeat)
		addCommsReply(_("Back to station communication"), commsStation)
    end)
end
function presentReturnWaypointDistanceCalculator()
    local remove_waypoint_dist_calc_prompt = {
        "Give waypoint distance calculator to repair technicians",
        string.format("Donate waypoint distance calculator to %s",comms_target:getCallSign()),
        "Remove waypoint distance calculator. Give it to station",
        string.format("Transfer waypoint distance calculator from %s to station %s",comms_source:getCallSign(),comms_target:getCallSign()),
    }
    addCommsReply(tableSelectRandom(remove_waypoint_dist_calc_prompt),function()
        local waypoint_distance_calculator_explained = {
            "Not every ship in the fleet has a portable waypoint distance calculator. If you were to give us yours, we could install it on another ship if they wanted it. Would you like to give us your waypoint distance calculator?",
            "If you were to donate your waypoint distance calculator, we could install it on another ship in the fleet. Not every ship has one, you know. Do you want to give us yours?",
            "The waypoint distance calculator is not standard equipment on every ship in the fleet. Giving us yours allows us to install it on another ship. Would you like to donate yours? It's for a worthy cause.",
            "Consider that not every ship has a waypoint distance calculator. We could give another ship in the fleet one if you were to give us yours. What about it?",
        }
        setCommsMessage(tableSelectRandom(waypoint_distance_calculator_explained))
        local confirm_waypoint_dist_donation_prompt = {
            "Yes, we like to help the fleet (add 5 rep)",
            "Yes, we'll donate ours (add 5 rep)",
            "Ok, we will give you ours (add 5 rep)",
            "We'll help the fleet and give you ours (add 5 rep)",
        }
        addCommsReply(tableSelectRandom(confirm_waypoint_dist_donation_prompt),function()
            comms_source:addReputationPoints(5)
            comms_source.way_dist = false
            comms_target.way_dist = true
            comms_target.comms_data.friendlyness = math.min(100,comms_target.comms_data.friendlyness + random(3,9))
            if comms_source.way_distance_button_hlm ~= nil then
                comms_source:removeCustom(comms_source.way_distance_button_hlm)
                comms_source:removeCustom(comms_source.way_distance_button_tac)
                comms_source.way_distance_button_hlm = nil
                comms_source.way_distance_button_tac = nil
            end
            local confirm_uninstalled_waypoint_dist_calc = {
                "Thanks. I'll be sure to give this to the next fleet member that asks.",
                "You have done the fleet an appreciated service. We'll be sure the waypoint distance calculator gets put to good use.",
                string.format("The %s will go down in our records as a generous ship. We'll make sure another fleet member gets good use from your waypoint distance calculator",comms_source:getCallSign()),
                "Your contribution is greatly appreciated. This waypoint distance calculator will make some helm officer very happy",
            }
            setCommsMessage(tableSelectRandom(confirm_uninstalled_waypoint_dist_calc))
			addCommsReply("Back to enhance ship",enhanceShip)
			addCommsReply("Back to interactive relay officer",interactiveDockedStationCommsMeat)
			addCommsReply(_("Back to station communication"), commsStation)
        end)
		addCommsReply("Back to enhance ship",enhanceShip)
		addCommsReply("Back to interactive relay officer",interactiveDockedStationCommsMeat)
		addCommsReply(_("Back to station communication"), commsStation)
    end)
end
function minorUpgrades()
    --    set minor upgrade present or not at station if not yet set
    if comms_target.proximity_scanner == nil then
        if random(1,100) < 55 then
            comms_target.proximity_scanner = true
            comms_target.proximity_scanner_range = math.random(1,5)
        else
            comms_target.proximity_scanner = false
        end
    end
    if comms_target.max_health_widgets == nil then
        if random(1,100) < 50 then
            comms_target.max_health_widgets = true
        else
            comms_target.max_health_widgets = false
        end
    end
    if comms_target.shield_banner == nil then
        if random(1,100) < (60 - difficulty*5) then
            comms_target.shield_banner = true
        else
            comms_target.shield_banner = false
        end
    end
    if comms_target.hull_banner == nil then
        if random(1,100) < 50 then
            comms_target.hull_banner = true
        else
            comms_target.hull_banner = false
        end
    end
    if comms_target.way_dist == nil then
        if random(1,100) < 50 then
            comms_target.way_dist = true
        else
            comms_target.way_dist = false
        end
    end
    if comms_target.installable_sensor_boost == nil then
        if random(1,100) < 32 then
            comms_target.installable_sensor_boost = true
            comms_target.installable_sensor_boost_ranges = {}
            local sensor_boost_ranges_pool = {}
            for i=5,9,.5 do
                table.insert(sensor_boost_ranges_pool,{interval = i,cost=math.random(3,6)*2*i})
            end
            for i=1,3 do
                table.insert(comms_target.installable_sensor_boost_ranges,tableRemoveRandom(sensor_boost_ranges_pool))
            end
        else
            comms_target.installable_sensor_boost = false
        end
    end
    --    set minor upgrade available list based on presence at station, presence on ship and relationship
    local minor_upgrade_choices = {}
    if comms_target.installable_sensor_boost and (comms_source.power_sensor_interval == nil or comms_source.power_sensor_interval == 0) then
        if comms_target:isFriendly(comms_source) then
            if comms_target.comms_data.friendlyness > 30 then
                table.insert(minor_upgrade_choices,presentBoostSensorRangeWithPower)
            end
        elseif not comms_target:isEnemy(comms_source) then
            if comms_target.comms_data.friendlyness > 40 then
                table.insert(minor_upgrade_choices,presentBoostSensorRangeWithPower)
            end
        end
    end
    if comms_target.proximity_scanner and (comms_source.prox_scan == nil or comms_source.prox_scan < comms_target.proximity_scanner_range) then
        if comms_target:isFriendly(comms_source) then
            if comms_target.comms_data.friendlyness > 50 then
                table.insert(minor_upgrade_choices,presentProximityScanner)
            end
        elseif not comms_target:isEnemy(comms_source) then
            if comms_target.comms_data.friendlyness > 15 then
                table.insert(minor_upgrade_choices,presentProximityScanner)
            end
        end
    end
    if comms_target.max_health_widgets and not comms_source.max_health_widgets then
        if comms_target:isFriendly(comms_source) then
            if comms_target.comms_data.friendlyness > 25 then
                table.insert(minor_upgrade_choices,presentMaxHealthWidgets)
            end
        elseif not comms_target:isEnemy(comms_source) then
            if comms_target.comms_data.friendlyness > 45 then
                table.insert(minor_upgrade_choices,presentMaxHealthWidgets)
            end
        end
    end
    if comms_target.shield_banner and not comms_source.shield_banner then
        if comms_target:isFriendly(comms_source) then
            if comms_target.comms_data.friendlyness > 20 then
                table.insert(minor_upgrade_choices,presentShieldBanner)
            end
        elseif not comms_target:isEnemy(comms_source) then
            if comms_target.comms_data.friendlyness > 50 then
                table.insert(minor_upgrade_choices,presentShieldBanner)
            end
        end
    end
    if comms_target.hull_banner and not comms_source.hull_banner then
        if comms_target:isFriendly(comms_source) then
            if comms_target.comms_data.friendlyness > 30 then
                table.insert(minor_upgrade_choices,presentHullBanner)
            end
        elseif not comms_target:isEnemy(comms_source) then
            if comms_target.comms_data.friendlyness > 60 then
                table.insert(minor_upgrade_choices,presentHullBanner)
            end
        end
    end
    if comms_target.way_dist and not comms_source.way_dist then
        if comms_target:isFriendly(comms_source) then
            if comms_target.comms_data.friendlyness > 10 then
                table.insert(minor_upgrade_choices,presentWaypointDistanceCalculator)
            end
        elseif not comms_target:isEnemy(comms_source) then
            if comms_target.comms_data.friendlyness > 20 then
                table.insert(minor_upgrade_choices,presentWaypointDistanceCalculator)
            end
        end
    end
    --    set minor upgrade returns available list
    local return_minor_upgrade_choices = {}
    if not comms_target.max_health_widgets and comms_source.max_health_widgets ~= nil and comms_source.max_health_widgets then
        table.insert(return_minor_upgrade_choices,presentReturnMaxHealthWidgets)
    end
    if not comms_target.shield_banner and comms_source.shield_banner ~= nil and comms_source.shield_banner then
        table.insert(return_minor_upgrade_choices,presentReturnShieldBanner)
    end
    if not comms_target.hull_banner and comms_source.hull_banner ~= nil and comms_source.hull_banner then
        table.insert(return_minor_upgrade_choices,presentReturnHullBanner)
    end
    if not comms_target.way_dist and comms_source.way_dist ~= nil and comms_source.way_dist then
        table.insert(return_minor_upgrade_choices,presentReturnWaypointDistanceCalculator)
    end
    local presented_option = false
    if #minor_upgrade_choices + #return_minor_upgrade_choices > 0 then
        presented_option = true
        local minor_upgrade_prompt = {
            "Minor upgrade",
            "Get a minor upgrade",
            string.format("Minor upgrade for %s",comms_source:getCallSign()),
            string.format("Check minor upgrades on %s",comms_target:getCallSign()),
        }
        addCommsReply(tableSelectRandom(minor_upgrade_prompt),function()
            local minor_upgrades_available = {
                "Which of these are you interested in?",
                "What minor upgrades might you be interested in?",
                "Do any of these minor upgrades interest you?",
                string.format("Here are some minor upgrades available here on %s. Let me know if any of these seem interesting.",comms_target:getCallSign()),
            }
            setCommsMessage(tableRemoveRandom(minor_upgrades_available))
            string.format("")
            local upgrades_presented_count = 0
            for i=1,3 do
                local present_upgrade = tableRemoveRandom(minor_upgrade_choices)
                if present_upgrade ~= nil then
                    present_upgrade()
                    upgrades_presented_count = upgrades_presented_count + 1
                end
            end
            if upgrades_presented_count < 3 then
                --give back options
                local presentation_slots_remaining = 3 - upgrades_presented_count
                for i=1,presentation_slots_remaining do
                    local present_return_upgrade = tableRemoveRandom(return_minor_upgrade_choices)
                    if present_return_upgrade ~= nil then
                        present_return_upgrade()
                    end
                end
            end
			addCommsReply("Back to enhance ship",enhanceShip)
			addCommsReply("Back to interactive relay officer",interactiveDockedStationCommsMeat)
			addCommsReply(_("Back to station communication"), commsStation)
        end)
    end
    return presented_option
end
--]]
function overchargeShipSystems()
    local overcharge_available = false
    local jump_overcharge_available = false
    local front_shield_overcharge_available = false
    local rear_shield_overcharge_available = false
    local max_charge = comms_source.max_jump_range
    if max_charge == nil then
        max_charge = 50000
    end
    if comms_target.comms_data.jump_overcharge and comms_source:hasJumpDrive() then
        if comms_source:getJumpDriveCharge() >= max_charge then
            if comms_target:isFriendly(comms_source) then
                if comms_target.comms_data.friendlyness > 20 then
                    overcharge_available = true
                    jump_overcharge_available = true
                end
            elseif not comms_target:isEnemy(comms_source) then
                if comms_target.comms_data.friendlyness > 33 then
                    overcharge_available = true
                    jump_overcharge_available = true
                end
            end
        end
    end
    if comms_target.comms_data.shield_overcharge and comms_source:getShieldCount() > 0 then
        if comms_source:getShieldLevel(0) == comms_source:getShieldMax(0) then
            if comms_target:isFriendly(comms_source) then
                if comms_target.comms_data.friendlyness > 25 then
                    overcharge_available = true
                    front_shield_overcharge_available = true
                end
            elseif not comms_target:isEnemy(comms_source) then
                if comms_target.comms_data.friendlyness > 40 then
                    overcharge_available = true
                    front_shield_overcharge_available = true
                end
            end
        end
        if comms_source:getShieldCount() > 1 and comms_source:getShieldLevel(1) == comms_source:getShieldMax(1) then
            if comms_target:isFriendly(comms_source) then
                if comms_target.comms_data.friendlyness > 30 then
                    overcharge_available = true
                    rear_shield_overcharge_available = true
                end
            elseif not comms_target:isEnemy(comms_source) then
                if comms_target.comms_data.friendlyness > 50 then
                    overcharge_available = true
                    rear_shield_overcharge_available = true
                end
            end
        end
    end
    local option_presented = false
    if overcharge_available then
        option_presented = true
        local overcharge_system_prompt = {
            "Overcharge system",
            "Overcharge a system",
            string.format("Overcharge a system on %s",comms_source:getCallSign()),
            "Inject extra power into a ship system",
        }
        addCommsReply(tableSelectRandom(overcharge_system_prompt),function()
            local overcharge_what_system = {
                "What shall we overcharge for you?",
                "What system shall we overcharge for you",
                "Into what system shall we inject additional power?",
                "What system do you want overcharged?",
            }
            setCommsMessage(tableSelectRandom(overcharge_what_system))
            if jump_overcharge_available then
                local overcharge_cost = 10
                if comms_target.comms_data.friendlyness > 66 then
                    overcharge_cost = 5
                end
                local overcharge_jump_prompt = {
                    string.format("Overcharge Jump Drive (%i rep)",overcharge_cost),
                    string.format("Overcharge the jump drive (%i rep)",overcharge_cost),
                    string.format("Put extra power in the jump drive (%i rep)",overcharge_cost),
                    string.format("Jump drive (%i reputation)",overcharge_cost),
                }
                addCommsReply(tableSelectRandom(overcharge_jump_prompt),function()
                    if comms_source:takeReputationPoints(overcharge_cost) then
                        comms_source:setJumpDriveCharge(comms_source:getJumpDriveCharge() + max_charge)
                        local jump_drive_overcharged = {
                            string.format("Your jump drive has been overcharged to %ik",math.floor(comms_source:getJumpDriveCharge()/1000)),
                            string.format("%s's jump drive has been overcharged to %ik",comms_source:getCallSign(),math.floor(comms_source:getJumpDriveCharge()/1000)),
                            string.format("We have overcharged your jump drive to %ik",math.floor(comms_source:getJumpDriveCharge()/1000)),
                            string.format("%s's jump drive now has total charge of %ik",comms_source:getCallSign(),math.floor(comms_source:getJumpDriveCharge()/1000)),
                        }
                        setCommsMessage(tableSelectRandom(jump_drive_overcharged))
                    else
                        local insufficient_rep_responses = {
                            "Insufficient reputation",
                            "Not enough reputation",
                            "You need more reputation",
                            string.format("You need more than %i reputation",math.floor(comms_source:getReputationPoints())),
                            "You don't have enough reputation",
                        }
                        setCommsMessage(tableSelectRandom(insufficient_rep_responses))
                    end
					addCommsReply("Back to enhance ship",enhanceShip)
					addCommsReply("Back to interactive relay officer",interactiveDockedStationCommsMeat)
					addCommsReply(_("Back to station communication"), commsStation)
                end)
            end
            if front_shield_overcharge_available then
                local base_front_shield_overcharge_cost = 10
                if comms_target:isFriendly(comms_source) then
                    if comms_target.comms_data.friendlyness > 80 then
                        base_front_shield_overcharge_cost = 5
                    elseif comms_target.comms_data.friendlyness > 70 then
                        base_front_shield_overcharge_cost = 7
                    end
                elseif not comms_target:isEnemy(comms_source) then
                    if comms_target.comms_data.friendlyness > 90 then
                        base_front_shield_overcharge_cost = 5
                    elseif comms_target.comms_data.friendlyness > 75 then
                        base_front_shield_overcharge_cost = 7
                    end
                end
                if comms_source:getReputationPoints() > 2*base_front_shield_overcharge_cost then
                    local front_shield_overcharge_range_prompt = {
                        string.format("Overcharge front shield (%i to %i rep)",base_front_shield_overcharge_cost,base_front_shield_overcharge_cost*4),
                        string.format("Front shield overcharge (%i to %i rep)",base_front_shield_overcharge_cost,base_front_shield_overcharge_cost*4),
                        string.format("Use %i to %i rep to overcharge front shield",base_front_shield_overcharge_cost,base_front_shield_overcharge_cost*4),
                        string.format("Overcharge front shield rep: min:%i, max:%i",base_front_shield_overcharge_cost,base_front_shield_overcharge_cost*4),
                    }
                    addCommsReply(tableSelectRandom(front_shield_overcharge_range_prompt),function()
                        local overcharge_size_options = {
                            "How much of an overcharge would you like on your front shields?",
                            "How much overcharging should we do on your front shields?",
                            "How much of an overcharge do you want added to your front shields?",
                            "How much power should we inject into your front shields to overcharge them?",
                        }
                        setCommsMessage(tableSelectRandom(overcharge_size_options))
                        for i=1,4 do
                            if i*base_front_shield_overcharge_cost <= comms_source:getReputationPoints() then
                                local overcharge_amount_prompts = {
                                    string.format("%i%% overcharge (%i rep)",i*5,i*base_front_shield_overcharge_cost),
                                    string.format("%i%% overcharge (%i reputation",i*5,i*base_front_shield_overcharge_cost),
                                    string.format("%i%% overcharge for %i reputation",i*5,i*base_front_shield_overcharge_cost),
                                    string.format("Power up to %i%% more (%i rep)",i*5,i*base_front_shield_overcharge_cost),
                                }
                                addCommsReply(tableSelectRandom(overcharge_amount_prompts),function()
                                    if comms_source:takeReputationPoints(i*base_front_shield_overcharge_cost) then
                                        if comms_source:getShieldCount() == 1 then
                                            comms_source:setShields(comms_source:getShieldMax(0)*(1 + i*5/100))
                                        else
                                            comms_source:setShields(comms_source:getShieldMax(0)*(1 + i*5/100),comms_source:getShieldLevel(1))
                                        end
                                        local overcharge_front_shield_confirmation = {
                                            "Your front shield has been overcharged",
                                            "Overcharge applied to front shield",
                                            string.format("%s's front shield has now been overcharged",comms_source:getCallSign()),
                                            "Front shield overcharged as requested",
                                        }
                                        setCommsMessage(tableSelectRandom(overcharge_front_shield_confirmation))
                                    else
                                        local insufficient_rep_responses = {
                                            "Insufficient reputation",
                                            "Not enough reputation",
                                            "You need more reputation",
                                            string.format("You need more than %i reputation",math.floor(comms_source:getReputationPoints())),
                                            "You don't have enough reputation",
                                        }
                                        setCommsMessage(tableSelectRandom(insufficient_rep_responses))
                                    end

									addCommsReply("Back to enhance ship",enhanceShip)
									addCommsReply("Back to interactive relay officer",interactiveDockedStationCommsMeat)
									addCommsReply(_("Back to station communication"), commsStation)
                                end)
                            end
                        end
                    end)
                else
                    local front_shield_overcharge_single_prompt = {
                        string.format("Overcharge front shield (%i rep)",base_front_shield_overcharge_cost),
                        string.format("Front shield overcharge (%i rep)",base_front_shield_overcharge_cost),
                        string.format("Use %i rep to overcharge front shield",base_front_shield_overcharge_cost),
                        string.format("Overcharge front shield rep: %i",base_front_shield_overcharge_cost),
                    }
                    addCommsReply(tableSelectRandom(front_shield_overcharge_single_prompt),function()
                        if comms_source:takeReputationPoints(base_front_shield_overcharge_cost) then
                            if comms_source:getShieldCount() == 1 then
                                comms_source:setShields(comms_source:getShieldMax(0)*1.05)
                            else
                                comms_source:setShields(comms_source:getShieldMax(0)*1.05,comms_source:getShieldLevel(1))
                            end
                            local overcharge_front_shield_confirmation = {
                                "Your front shield has been overcharged",
                                "Overcharge applied to front shield",
                                string.format("%s's front shield has now been overcharged",comms_source:getCallSign()),
                                "Front shield overcharged as requested",
                            }
                            setCommsMessage(tableSelectRandom(overcharge_front_shield_confirmation))
                        else
                            local insufficient_rep_responses = {
                                "Insufficient reputation",
                                "Not enough reputation",
                                "You need more reputation",
                                string.format("You need more than %i reputation",math.floor(comms_source:getReputationPoints())),
                                "You don't have enough reputation",
                            }
                            setCommsMessage(tableSelectRandom(insufficient_rep_responses))
                        end
						addCommsReply("Back to enhance ship",enhanceShip)
						addCommsReply("Back to interactive relay officer",interactiveDockedStationCommsMeat)
						addCommsReply(_("Back to station communication"), commsStation)
                    end)
                end
            end
            if rear_shield_overcharge_available then
                local base_rear_shield_overcharge_cost = 10
                if comms_target:isFriendly(comms_source) then
                    if comms_target.comms_data.friendlyness > 80 then
                        base_rear_shield_overcharge_cost = 5
                    elseif comms_target.comms_data.friendlyness > 70 then
                        base_rear_shield_overcharge_cost = 7
                    end
                elseif not comms_target:isEnemy(comms_source) then
                    if comms_target.comms_data.friendlyness > 90 then
                        base_rear_shield_overcharge_cost = 5
                    elseif comms_target.comms_data.friendlyness > 75 then
                        base_rear_shield_overcharge_cost = 7
                    end
                end
                if comms_source:getReputationPoints() > 2*base_rear_shield_overcharge_cost then
                    local rear_shield_overcharge_range_prompt = {
                        string.format("Overcharge rear shield (%i to %i rep)",base_rear_shield_overcharge_cost,base_rear_shield_overcharge_cost*4),
                        string.format("Rear shield overcharge (%i to %i rep)",base_rear_shield_overcharge_cost,base_rear_shield_overcharge_cost*4),
                        string.format("Use %i to %i rep to overcharge rear shield",base_rear_shield_overcharge_cost,base_rear_shield_overcharge_cost*4),
                        string.format("Overcharge rear shield rep: min:%i, max:%i",base_rear_shield_overcharge_cost,base_rear_shield_overcharge_cost*4),
                    }
                    addCommsReply(tableSelectRandom(rear_shield_overcharge_range_prompt),function()
                        local overcharge_rear_size_options = {
                            "How much of an overcharge would you like on your rear shields?",
                            "How much overcharging should we do on your rear shields?",
                            "How much of an overcharge do you want added to your rear shields?",
                            "How much power should we inject into your rear shields to overcharge them?",
                        }
                        setCommsMessage(tableSelectRandom(overcharge_rear_size_options))
                        for i=1,4 do
                            if i*base_rear_shield_overcharge_cost <= comms_source:getReputationPoints() then
                                local overcharge_rear_amount_prompts = {
                                    string.format("%i%% overcharge (%i rep)",i*5,i*base_rear_shield_overcharge_cost),
                                    string.format("%i%% overcharge (%i reputation",i*5,i*base_rear_shield_overcharge_cost),
                                    string.format("%i%% overcharge for %i reputation",i*5,i*base_rear_shield_overcharge_cost),
                                    string.format("Power up to %i%% more (%i rep)",i*5,i*base_rear_shield_overcharge_cost),
                                }
                                addCommsReply(tableSelectRandom(overcharge_rear_amount_prompts),function()
                                    if comms_source:takeReputationPoints(i*base_rear_shield_overcharge_cost) then
                                        comms_source:setShields(comms_source:getShieldLevel(0),comms_source:getShieldMax(1)*(1 + i*5/100))
                                        local overcharge_rear_shield_confirmation = {
                                            "Your rear shield has been overcharged",
                                            "Overcharge applied to rear shield",
                                            string.format("%s's rear shield has now been overcharged",comms_source:getCallSign()),
                                            "Rear shield overcharged as requested",
                                        }
                                        setCommsMessage(tableSelectRandom(overcharge_rear_shield_confirmation))
                                    else
                                        local insufficient_rep_responses = {
                                            "Insufficient reputation",
                                            "Not enough reputation",
                                            "You need more reputation",
                                            string.format("You need more than %i reputation",math.floor(comms_source:getReputationPoints())),
                                            "You don't have enough reputation",
                                        }
                                        setCommsMessage(tableSelectRandom(insufficient_rep_responses))
                                    end
									addCommsReply("Back to enhance ship",enhanceShip)
									addCommsReply("Back to interactive relay officer",interactiveDockedStationCommsMeat)
									addCommsReply(_("Back to station communication"), commsStation)
                                end)
                            end
                        end
                    end)
                else
                    local rear_shield_overcharge_single_prompt = {
                        string.format("Overcharge rear shield (%i rep)",base_rear_shield_overcharge_cost),
                        string.format("Rear shield overcharge (%i rep)",base_rear_shield_overcharge_cost),
                        string.format("Use %i rep to overcharge rear shield",base_rear_shield_overcharge_cost),
                        string.format("Overcharge rear shield rep: %i",base_rear_shield_overcharge_cost),
                    }
                    addCommsReply(tableSelectRandom(rear_shield_overcharge_single_prompt),function()
                        if comms_source:takeReputationPoints(base_rear_shield_overcharge_cost) then
                            comms_source:setShields(comms_source:getShieldLevel(0),comms_source:getShieldMax(1)*1.05)
                            local overcharge_rear_shield_confirmation = {
                                "Your rear shield has been overcharged",
                                "Overcharge applied to rear shield",
                                string.format("%s's rear shield has now been overcharged",comms_source:getCallSign()),
                                "Rear shield overcharged as requested",
                            }
                            setCommsMessage(tableSelectRandom(overcharge_rear_shield_confirmation))
                        else
                            local insufficient_rep_responses = {
                                "Insufficient reputation",
                                "Not enough reputation",
                                "You need more reputation",
                                string.format("You need more than %i reputation",math.floor(comms_source:getReputationPoints())),
                                "You don't have enough reputation",
                            }
                            setCommsMessage(tableSelectRandom(insufficient_rep_responses))
                        end
						addCommsReply("Back to enhance ship",enhanceShip)
						addCommsReply("Back to interactive relay officer",interactiveDockedStationCommsMeat)
						addCommsReply(_("Back to station communication"), commsStation)
                    end)
                end
            end
			addCommsReply("Back to enhance ship",enhanceShip)
			addCommsReply("Back to interactive relay officer",interactiveDockedStationCommsMeat)
			addCommsReply(_("Back to station communication"), commsStation)
        end)
    end
    return option_presented
end
--[[RM
function boostSensorsWhileDocked()
    local temporary_station_sensor_boost_prompt = {
        string.format("Augment scan range with station sensors while docked (%i rep)",comms_target.comms_data.sensor_boost.cost),
        string.format("Increase sensor range via station sensors while docked (%i rep)",comms_target.comms_data.sensor_boost.cost),
        string.format("Tie in to station sensors to boost range while docked (%i rep)",comms_target.comms_data.sensor_boost.cost),
        string.format("Connect to station sensors in docking bay to boost range (%i rep)",comms_target.comms_data.sensor_boost.cost),
    }
    addCommsReply(tableSelectRandom(temporary_station_sensor_boost_prompt),function()
        if comms_source:takeReputationPoints(comms_target.comms_data.sensor_boost.cost) then
            if comms_source.normal_long_range_radar == nil then
                comms_source.normal_long_range_radar = comms_source:getLongRangeRadarRange()
            end
            comms_source.station_sensor_boost = comms_target.comms_data.sensor_boost.value
            local confirm_sensor_boost = {
                string.format("Sensors increased by %i units",math.floor(comms_target.comms_data.sensor_boost.value/1000)),
                string.format("Sensor range increased by %i units",math.floor(comms_target.comms_data.sensor_boost.value/1000)),
                string.format("In conjunction with %s's sensors, our sensor range has been increased by %i units",comms_target:getCallSign(),math.floor(comms_target.comms_data.sensor_boost.value/1000)),
                string.format("%s's and %s's sensors in tandem have increased our sensor range by %i units",comms_source:getCallSign(),comms_target:getCallSign(),math.floor(comms_target.comms_data.sensor_boost.value/1000)),
            }
            setCommsMessage(tableSelectRandom(confirm_sensor_boost))
        else
            local insufficient_rep_responses = {
                "Insufficient reputation",
                "Not enough reputation",
                "You need more reputation",
                string.format("You need more than %i reputation",math.floor(comms_source:getReputationPoints())),
                "You don't have enough reputation",
            }
            setCommsMessage(tableSelectRandom(insufficient_rep_responses))
        end
		addCommsReply("Back to enhance ship",enhanceShip)
		addCommsReply("Back to interactive relay officer",interactiveDockedStationCommsMeat)
		addCommsReply("Back to station communication", commsStation)
    end)
end
function increaseSecurityMorale()
    local select_training_prompt = {
        "Select a morale boosting security training course",
        "Choose a security training course to boost morale",
        "Which morale boosting training course would you like?",
        "What morale boosting security training course do you want?",
    }
    addCommsReply(tableSelectRandom(select_training_prompt),function()
        local security_morale_training_explained = {
            "We have access to some training courses for your security officers. They are designed to boost their morale as well as give them some training. Pick one to be downloaded for 5 reputation into your simulation systems if you're interested.",
            "We have a small library of training courses designed for security officers. They should boost their morale in addition to providing some training. Which one would you like to download into your simulation systems for 5 reputation?",
            "Would you like one of our training course? We've got some that are designed for security personnel. They are intended to boost morale as well as increase competence. We could transmit one to your simulation system for 5 reputation.",
            string.format("There are several security officer training courses in %s's library. They're designed to boost morale and competence. Pick one for 5 reputation to run in your simulation systems if you like.",comms_target:getCallSign()),
        }
        setCommsMessage(tableSelectRandom(security_morale_training_explained))
        for i,title in ipairs(security_morale_boosters) do
            addCommsReply(title,function()
                if comms_source:takeReputationPoints(5) then
                    local got_the_training_module = {
                        string.format("'%s' has been downloaded. Your security officers are already taking advantage of it",title),
                        string.format("%s has transmitted '%s' to your simulation systems. Our reading show that some of your security team is already using it",comms_target:getCallSign(),title),
                        string.format("%s's simulation systems have downloaded '%s.' At least one of your security officers has already started running it.",comms_source:getCallSign(),title),
                        string.format("'%s' has been downloaded to your simulation systems as requested. Your security officers immediately started running it.",title),
                    }
                    setCommsMessage(tableSelectRandom(got_the_training_module))
                    security_morale_boosters[i] = security_morale_boosters[#security_morale_boosters]
                    security_morale_boosters[#security_morale_boosters] = nil
                    comms_source.security_morale = 1
                else
                    local insufficient_rep_responses = {
                        "Insufficient reputation",
                        "Not enough reputation",
                        "You need more reputation",
                        string.format("You need more than %i reputation",math.floor(comms_source:getReputationPoints())),
                        "You don't have enough reputation",
                    }
                    setCommsMessage(tableSelectRandom(insufficient_rep_responses))
                end
				addCommsReply("Back to enhance ship",enhanceShip)
				addCommsReply("Back to interactive relay officer",interactiveDockedStationCommsMeat)
				addCommsReply("Back to station communication", commsStation)
            end)
        end
		addCommsReply("Back to enhance ship",enhanceShip)
		addCommsReply("Back to interactive relay officer",interactiveDockedStationCommsMeat)
		addCommsReply("Back to station communication", commsStation)
    end)
end
function getSpecialtyProbes()
    local get_specialty_probes_prompt = {
        "Get specialty probes",
        "Get some specialty probe kits",
        "Obtain specialty probes",
        string.format("Get specialty probes from %s",comms_target:getCallSign()),
    }
    addCommsReply(tableSelectRandom(get_specialty_probes_prompt),function()
        local specialty_probes = {}
        if comms_target.comms_data.fast_probes ~= nil and comms_target.comms_data.fast_probes.quantity > 0 then
            specialty_probes["fast_probes"] = {
                quantity = comms_target.comms_data.fast_probes.quantity,            
                singular_desc = "One batch of %s type probes",                
                plural_desc = "%i batches of %s type probes",            
                name = comms_target.comms_data.fast_probes.name,            
                cost = comms_target.comms_data.fast_probes.cost,
                increment = 5,
                prompt = "Purchase five %s type probes for %i reputation",
                response = "Five %s type probes have been added",
            }
        end
        if comms_target.comms_data.remote_warp_jammer ~= nil and comms_target.comms_data.remote_warp_jammer.quantity > 0 then
            specialty_probes["remote_warp_jammer"] = {
                quantity = comms_target.comms_data.remote_warp_jammer.quantity,    
                singular_desc = "One remote warp jammer kit of type %s",    
                plural_desc = "%i remote warp jammer kits of type %s",    
                name = comms_target.comms_data.remote_warp_jammer.name,        
                cost = comms_target.comms_data.remote_warp_jammer.cost,        
                increment = 1,
                prompt = "Purchase %s type probe for %i reputation",
                response = "A %s type probe has been added",
            }
        end
        if comms_target.comms_data.sensor_boost_probes ~= nil and comms_target.comms_data.sensor_boost_probes.quantity > 0 then
            specialty_probes["sensor_boost_probes"] = {
                quantity = comms_target.comms_data.sensor_boost_probes.quantity,    
                singular_desc = "One sensor boost probe of type %s",        
                plural_desc = "%i sensor boost probes of type %s",        
                name = comms_target.comms_data.sensor_boost_probes.name,    
                cost = comms_target.comms_data.sensor_boost_probes.cost,    
                increment = 1,
                prompt = "Purchase %s type probe for %s reputation",
                response = "A %s type probe has been added",
            }
        end
        if comms_target.comms_data.mine_probes ~= nil and comms_target.comms_data.mine_probes.quantity > 0 then
            specialty_probes["mine_probes"] = {
                quantity = comms_target.comms_data.mine_probes.quantity,            
                singular_desc = "One mine probe of type %s",                
                plural_desc = "%i mine probes of type %s",                
                name = comms_target.comms_data.mine_probes.name,            
                cost = comms_target.comms_data.mine_probes.cost,            
                increment = 1,
                prompt = "Purchase %s type probe for %s reputation",
                response = "A %s type probe has been added",
            }
        end
        local quantity_message = ""
        local desc = ""
        for specialty_probe,sp in pairs(specialty_probes) do
            if sp.quantity ~= nil and sp.quantity > 0 then
                if sp.quantity > 1 then
                    desc = string.format(sp.plural_desc,sp.quantity,sp.name)
                else
                    desc = string.format(sp.singular_desc,sp.name)
                end
                if quantity_message == "" then
                    quantity_message = string.format("We've got the following specialty probes available:\n    %s",desc)
                else
                    quantity_message = string.format("%s\n    %s",quantity_message,desc)
                end
                addCommsReply(string.format(sp.prompt,sp.name,sp.cost),function()
                    if sp == "mine_probes" and comms_source:getWeaponStorageMax("Mine") < comms_target.comms_data.mine_probes.mines_required then
                        setCommsMessage(string.format("This mine probe kit requires %i mines. Your ship specification maxes out at %i mines. Upgrade your ship to store more mines and come back.",comms_target.comms_data.mine_probes.mines_required,comms_source:getWeaponStorageMax("Mine")))
                    else
                        if comms_source:takeReputationPoints(sp.cost) then
                            comms_target.comms_data[specialty_probe].quantity = comms_target.comms_data[specialty_probe].quantity - 1
                            if comms_source.probe_type_list == nil then
                                comms_source.probe_type_list = {}
                                table.insert(comms_source.probe_type_list,{name = "standard", count = -1})
                            end
                            local matching_index = 0
                            for probe_type_index, probe_type_item in ipairs(comms_source.probe_type_list) do
                                if probe_type_item.name == sp.name then
                                    matching_index = probe_type_index
                                    break
                                end
                            end
                            if matching_index > 0 then
                                comms_source.probe_type_list[matching_index].count = comms_source.probe_type_list[matching_index].count + sp.increment
                            else
                                --    add variants for different probe types
                                if specialty_probe == "remote_warp_jammer" then
                                    table.insert(comms_source.probe_type_list,{name = sp.name, count = sp.increment, speed = comms_target.comms_data.remote_warp_jammer.speed, warp_jam_range = comms_target.comms_data.remote_warp_jammer.warp_jam_range})
                                elseif specialty_probe == "sensor_boost_probes" then
                                    table.insert(comms_source.probe_type_list,{name = sp.name, count = sp.increment, speed = comms_target.comms_data.sensor_boost_probes.speed, boost = comms_target.comms_data.sensor_boost_probes.boost, range = comms_target.comms_data.sensor_boost_probes.range})
                                elseif specialty_probe == "mine_probes" then
                                    table.insert(comms_source.probe_type_list,{name = sp.name, count = sp.increment, speed = comms_target.comms_data.mine_probes.speed, mine_fetus = comms_target.comms_data.mine_probes.mine_fetus, mines_required = comms_target.comms_data.mine_probes.mines_required})
                                else    --fast probes
                                    table.insert(comms_source.probe_type_list,{name = sp.name, count = sp.increment, speed = comms_target.comms_data.fast_probes.speed})
                                end
                            end
                            setCommsMessage(string.format(sp.response,sp.name))
                            if comms_source.probe_type == nil then
                                comms_source.probe_type = "standard"
                            end
                            if comms_source.probe_type_button == nil then
                                comms_source.probe_type_button = "probe_type_button"
                                comms_source:addCustomButton("Relay",comms_source.probe_type_button,"Probes: standard",function()
                                    string.format("")
                                    cycleProbeType(comms_source)
                                end,10)
                            end
                            if comms_source.probe_type_button_ops == nil then
                                comms_source.probe_type_button_ops = "probe_type_button_ops"
                                comms_source:addCustomButton("Operations",comms_source.probe_type_button_ops,"Probes: standard",function()
                                    string.format("")
                                    cycleProbeType(comms_source)
                                end,10)
                            end
                        else
                            local insufficient_rep_responses = {
                                "Insufficient reputation",
                                "Not enough reputation",
                                "You need more reputation",
                                string.format("You need more than %i reputation",math.floor(comms_source:getReputationPoints())),
                                "You don't have enough reputation",
                            }
                            setCommsMessage(tableSelectRandom(insufficient_rep_responses))
                        end
                    end
                    addCommsReply("Back to enhance ship",enhanceShip)
                    addCommsReply("Back to interactive relay officer",interactiveDockedStationCommsMeat)
                    addCommsReply("Back to station communication", commsStation)
                end)
            end
        end
        setCommsMessage(quantity_message)
        addCommsReply("What exactly are specialty probes?",function()
            local kit_description = "Specialty probes are kits that you use in conjunction with your normal probes."
            if comms_target.comms_data.fast_probes ~= nil and comms_target.comms_data.fast_probes.quantity > 0 then
                kit_description = string.format("%s The %s kits come in batches of 5. You attach a kit to one of the probes you launch. The probe then travels at %.1f units per minute to reach its destination. Normal probes travel at 60 units per minute.",kit_description,comms_target.comms_data.fast_probes.name,comms_target.comms_data.fast_probes.speed*60/1000)
            end
            if comms_target.comms_data.remote_warp_jammer ~= nil and comms_target.comms_data.remote_warp_jammer.quantity > 0 then
                kit_description = string.format("%s The %s kits are purchased singly. When attached, the probe travels at %.1f units per minute to reach its destination. Once the probe arrives, it drops a warp jammer with a jamming radius of %i units.",kit_description,comms_target.comms_data.remote_warp_jammer.name,comms_target.comms_data.remote_warp_jammer.speed*60/1000,math.floor(comms_target.comms_data.remote_warp_jammer.warp_jam_range/1000))
            end
            if comms_target.comms_data.sensor_boost_probes ~= nil and comms_target.comms_data.sensor_boost_probes.quantity > 0 then
                kit_description = string.format("%s The %s kits are purchased individually. When attached, the probe enhances sensors by %i units if within %i units. The sensor boost gradually decreases until there is no boost at %i units distance from the probe.",kit_description,comms_target.comms_data.sensor_boost_probes.name,comms_target.comms_data.sensor_boost_probes.boost,comms_target.comms_data.sensor_boost_probes.range/2,comms_target.comms_data.sensor_boost_probes.range)
            end
            if comms_target.comms_data.mine_probes ~= nil and comms_target.comms_data.mine_probes.quantity > 0 then
                kit_description = string.format("%s The %s kits are purchased individually. When attached along with a mine or mines from supply, the probe carries the mine(s) inert to the probe destination. Once it reaches its destination, it enters a 5 second preparation phase. After that, it enters a stealth mode for 5 - 15 seconds. After the stealth mode, it primes the mine(s).",kit_description,comms_target.comms_data.mine_probes.name)
            end
            kit_description = string.format("%s You don't actually get additional probes, rather, you enhance the probes you already have.",kit_description)
            setCommsMessage(kit_description)
			addCommsReply("Back to enhance ship",enhanceShip)
			addCommsReply("Back to interactive relay officer",interactiveDockedStationCommsMeat)
			addCommsReply("Back to station communication", commsStation)
        end)
		addCommsReply("Back to enhance ship",enhanceShip)
		addCommsReply("Back to interactive relay officer",interactiveDockedStationCommsMeat)
		addCommsReply("Back to station communication", commsStation)
    end)
end--]]
--[[REMOVE
function unloadEscapePods(cost)
    if cost == nil then
        local unload_escape_pod_prompt = {
            "Unload retrieved escape pods",
            string.format("Offload the escape pods currently on %s",comms_source:getCallSign()),
            string.format("Release the scape pods into %s's care",comms_target:getCallSign()),
            string.format("Unload the escape pods that %s retrieved earlier",comms_source:getCallSign()),
        }
        addCommsReply(tableSelectRandom(unload_escape_pod_prompt),function()
            local pods_aboard = comms_source.max_pods - comms_source.pods
            comms_source.pods = comms_source.max_pods
            if pods_aboard > 1 then
                local plural_escape_pod_response = {
                    string.format("Escape pods unloaded and placed in the care of station %s. %s may now retrieve up to %i escape pods",comms_target:getCallSign(),comms_source:getCallSign(),comms_source.pods),
                    string.format("%s is now taking care of the escape pods retrieved by %s. With the space freed up, we may now retrieve up to %i escape pods",comms_target:getCallSign(),comms_source:getCallSign(),comms_source.pods),
                    string.format("[%s docking bay supervisor]\n'All escape pods unloaded, %s. We'll take care of them from here.'\nUnloading those escape pods frees us up to pick up as many as %i escape pods",comms_target:getCallSign(),comms_source:getCallSign(),comms_source.pods),
                    string.format("%s has secured all of %s's escape pods. %i open escape pod slots now available.",comms_target:getCallSign(),comms_source:getCallSign(),comms_source.pods),
                }
                setCommsMessage(tableSelectRandom(plural_escape_pod_response))
            else
                if comms_source.max_pods > 1 then
                    local single_unload_plural_available_pods = {
                        string.format("Escape pod unloaded into the care of %s. %s may now retrieve up to %i escape pods",comms_target:getCallSign(),comms_source:getCallSign(),comms_source.pods),
                        string.format("%s is now taking care of the escape pod retrieved by %s. With the space freed up, we may now retrieve up to %i escape pods",comms_target:getCallSign(),comms_source:getCallSign(),comms_source.pods),
                        string.format("[%s docking bay supervisor]\n'Your escape pod has been unloaded, %s. We'll take care of it from here.'\nUnloading those escape pods frees us up to pick up as many as %i escape pods",comms_target:getCallSign(),comms_source:getCallSign(),comms_source.pods),
                        string.format("%s has secured the escape pod from %s. %i open escape pod slots are now available",comms_target:getCallSign(),comms_source:getCallSign(),comms_source.pods),
                    }
                    setCommsMessage(tableSelectRandom(single_unload_plural_available_pods))
                else
                    local single_unload_and_available_pods = {
                        string.format("Escape pod unloaded and placed in the care of station %s. %s may now retrieve one escape pod",comms_target:getCallSign(),comms_source:getCallSign()),
                        string.format("%s is now taking care of the escape pod retrieved by %s. We may now retrieve another escape pod.",comms_target:getCallSign(),comms_source:getCallSign()),
                        string.format("[%s docking bay supervisor]\n'We unloaded your escape pod, %s. We'll take care of it from here.'\nWe may now retrieve another escape pod.",comms_target:getCallSign(),comms_source:getCallSign()),
                        string.format("%s has secured the escape pod from %s. You may retrieve another escape pod if you wish.",comms_target:getCallSign(),comms_source:getCallSign()),
                    }
                    setCommsMessage(tableSelectRandom(single_unload_and_available_pods))
                end
            end
			addCommsReply("Back to interactive relay officer",interactiveDockedStationCommsMeat)
			addCommsReply("Back to station communication",commsStation)
        end)
    else
        local unload_pods_at_cost_prompt = {
            string.format("Unload retrieved escape pods (%i rep per pod)",cost),
            string.format("Unload pods to %s (%i rep per pod)",comms_target:getCallSign(),cost),
            string.format("Unload escape pods (%i reputation per pod)",cost),
            string.format("Unload retrieved escape pods (%i reputation)",cost*(comms_source.max_pods - comms_source.pods)),
        }
        addCommsReply(tableSelectRandom(unload_pods_at_cost_prompt),function()
            if comms_source:takeReputationPoints(cost*(comms_source.max_pods - comms_source.pods)) then
                local pods_aboard = comms_source.max_pods - comms_source.pods
                comms_source.pods = comms_source.max_pods
                if pods_aboard > 1 then
                    local plural_escape_pod_response = {
                        string.format("Escape pods unloaded and placed in the care of station %s. %s may now retrieve up to %i escape pods",comms_target:getCallSign(),comms_source:getCallSign(),comms_source.pods),
                        string.format("%s is now taking care of the escape pods retrieved by %s. With the space freed up, we may now retrieve up to %i escape pods",comms_target:getCallSign(),comms_source:getCallSign(),comms_source.pods),
                        string.format("[%s docking bay supervisor]\n'All escape pods unloaded, %s. We'll take care of them from here.'\nUnloading those escape pods frees us up to pick up as many as %i escape pods",comms_target:getCallSign(),comms_source:getCallSign(),comms_source.pods),
                        string.format("%s has secured all of %s's escape pods. %i open escape pod slots now available.",comms_target:getCallSign(),comms_source:getCallSign(),comms_source.pods),
                    }
                    setCommsMessage(tableSelectRandom(plural_escape_pod_response))
                else
                    if comms_source.max_pods > 1 then
                        local single_unload_plural_available_pods = {
                            string.format("Escape pod unloaded into the care of %s. %s may now retrieve up to %i escape pods",comms_target:getCallSign(),comms_source:getCallSign(),comms_source.pods),
                            string.format("%s is now taking care of the escape pod retrieved by %s. With the space freed up, we may now retrieve up to %i escape pods",comms_target:getCallSign(),comms_source:getCallSign(),comms_source.pods),
                            string.format("[%s docking bay supervisor]\n'Your escape pod has been unloaded, %s. We'll take care of it from here.'\nUnloading those escape pods frees us up to pick up as many as %i escape pods",comms_target:getCallSign(),comms_source:getCallSign(),comms_source.pods),
                            string.format("%s has secured the escape pod from %s. %i open escape pod slots are now available",comms_target:getCallSign(),comms_source:getCallSign(),comms_source.pods),
                        }
                        setCommsMessage(tableSelectRandom(single_unload_plural_available_pods))
                    else
                        local single_unload_and_available_pods = {
                            string.format("Escape pod unloaded and placed in the care of station %s. %s may now retrieve one escape pod",comms_target:getCallSign(),comms_source:getCallSign()),
                            string.format("%s is now taking care of the escape pod retrieved by %s. We may now retrieve another escape pod.",comms_target:getCallSign(),comms_source:getCallSign()),
                            string.format("[%s docking bay supervisor]\n'We unloaded your escape pod, %s. We'll take care of it from here.'\nWe may now retrieve another escape pod.",comms_target:getCallSign(),comms_source:getCallSign()),
                            string.format("%s has secured the escape pod from %s. You may retrieve another escape pod if you wish.",comms_target:getCallSign(),comms_source:getCallSign()),
                        }
                        setCommsMessage(tableSelectRandom(single_unload_and_available_pods))
                    end
                end
            else
                local insufficient_rep_responses = {
                    "Insufficient reputation",
                    "Not enough reputation",
                    "You need more reputation",
                    string.format("You need more than %i reputation",math.floor(comms_source:getReputationPoints())),
                    "You don't have enough reputation",
                }
                setCommsMessage(tableSelectRandom(insufficient_rep_responses))
            end
			addCommsReply("Back to interactive relay officer",interactiveDockedStationCommsMeat)
			addCommsReply("Back to station communication",commsStation)
        end)
    end
end--]]
function goodsCommerce()
    local commerce_available = false
    local station_sells = false
    local station_buys = false
    local station_trades = false
    local player_has_goods = false
    local goods_for_sale = ""
    local will_buy_goods = ""
    local trade_goods = ""
    local player_goods = ""
    if comms_target.comms_data.goods ~= nil then
        for good, good_data in pairs(comms_target.comms_data.goods) do
            if good_data.quantity ~= nil and good_data.quantity > 0 then
                station_sells = true
                commerce_available = true
                if goods_for_sale == "" then
                    goods_for_sale = good_desc[good]
                else
                    goods_for_sale = string.format("%s, %s",goods_for_sale,good_desc[good])
                end
            end
        end
    end
    if comms_target.comms_data.buy ~= nil then
        commerce_available = true
        station_buys = true
        for good, price in pairs(comms_target.comms_data.buy) do
            if will_buy_goods == "" then
                will_buy_goods = good_desc[good]
            else
                will_buy_goods = string.format("%s, %s",will_buy_goods,good_desc[good])
            end
        end
    end
    if comms_target.comms_data.trade ~= nil then
        if station_sells then
            for good,trade_bool in pairs(comms_target.comms_data.trade) do
                if trade_bool then
                    station_trades = true
                    if trade_goods == "" then
                        trade_goods = good_desc[good]
                    else
                        trade_goods = string.format("%s, %s",trade_goods,good_desc[good])
                    end
                end
            end
        end
    end
    if comms_source.goods ~= nil then
        for good, good_quantity in pairs(comms_source.goods) do
            if good_quantity > 0 then
                player_has_goods = true
                commerce_available = true
                if player_goods == "" then
                    player_goods = good_desc[good]
                else
                    player_goods = string.format("%s, %s",player_goods,good_desc[good])
                end
            end
        end
    end
    if commerce_available then
        local commerce_out = ""
        if station_sells then
            commerce_out = string.format(_("trade-comms","%s sells %s."),comms_target:getCallSign(),goods_for_sale)
			local buy_goods_prompts = {
				"Buy goods",
				"Purchase goods",
				string.format("Buy goods from %s",comms_target:getCallSign()),
				string.format("Purchase goods from %s",comms_target:getCallSign()),
			}
			addCommsReply(tableSelectRandom(buy_goods_prompts),buyGoodsFromStation)
        end
        if station_buys then
            if commerce_out == "" then
                commerce_out = string.format(_("trade-comms","%s buys %s."),comms_target:getCallSign(),will_buy_goods)
            else
                commerce_out = string.format(_("trade-comms","%s\n%s buys %s."),commerce_out,comms_target:getCallSign(),will_buy_goods)
            end
            local buy_match = false
            if player_has_goods then
                for buy_good, price in pairs(comms_target.comms_data.buy) do
                    for good, good_quantity in pairs(comms_source.goods) do
                        if good == buy_good then
                            buy_match = true
                            break
                        end
                    end
                end
            end
            if buy_match then
				local sell_goods_prompts = {
					"Sell goods",
					"Sell goods for reputation",
					string.format("Sell goods to %s",comms_target:getCallSign()),
					string.format("Sell goods to %s for reputation",comms_target:getCallSign()),
				}
				addCommsReply(tableSelectRandom(sell_goods_prompts),sellGoodsToStation)
            end
        end
        if station_trades then
            if commerce_out == "" then
                commerce_out = string.format(_("trade-comms","%s trades %s for %s."),comms_target:getCallSign(),goods_for_sale,trade_goods)
            else
                commerce_out = string.format(_("trade-comms","%s\n%s trades %s for %s."),commerce_out,comms_target:getCallSign(),goods_for_sale,trade_goods)
            end
            local trade_match = false
            if player_has_goods then
                for trade_good,trade_bool in pairs(comms_target.comms_data.trade) do
                    for good, good_quantity in pairs(comms_source.goods) do
                        if good == trade_good then
                            trade_match = true
                            break
                        end
                    end
                end 
            end
            if trade_match then
				local trade_goods_prompts = {
					"Trade goods",
					"Exchange goods",
					"Barter goods",
					string.format("Trade goods with %s",comms_target:getCallSign()),
				}
				addCommsReply(tableSelectRandom(trade_goods_prompts),tradeGoodsWithStation)
            end
        end
        if player_has_goods then
            if commerce_out == "" then
                commerce_out = string.format(_("trade-comms","%s has %s aboard."),comms_source:getCallSign(),player_goods)
            else
                commerce_out = string.format(_("trade-comms","%s\n%s has %s aboard."),commerce_out,comms_source:getCallSign(),player_goods)
            end
			local jettison_goods_prompts = {
				"Jettison goods",
				"Throw goods out the airlock",
				"Dispose of goods",
				"Destroy goods",
			}
			addCommsReply(tableSelectRandom(jettison_goods_prompts),jettisonGoodsFromShip)
			local donate_goods_prompts = {
				"Give goods to station",
				"Donate goods to station",
				string.format("Give goods to %s",comms_target:getCallSign()),
				string.format("Donate goods to %s",comms_target:getCallSign()),
			}
			addCommsReply(tableSelectRandom(donate_goods_prompts),giveGoodsToStation)
        end
        local commerce_options_for_goods = {
            string.format("%s\nWhich of these actions related to goods do you wish to take?",commerce_out),
            string.format("%s\nWhich of these goods related actions do you want to take?",commerce_out),
            string.format("%s\nSelect a goods related action",commerce_out),
            string.format("%s\nIn terms of goods, what would you like to do?",commerce_out),
        }
        setCommsMessage(tableSelectRandom(commerce_options_for_goods))
    else
        local no_commerce_options = {
            "No commercial options available",
            "Commerce options not available",
            string.format("No commercial options available at %s",comms_target:getCallSign()),
            string.format("%s has no available commercial options",comms_target:getCallSign()),
        }
        setCommsMessage(tableSelectRandom(no_commerce_options))
    end
	addCommsReply("Back to interactive relay officer",interactiveDockedStationCommsMeat)
	addCommsReply("Back to station communication",commsStation)
end
function tradeGoodsWithStation()
    local trade_goods_prompt = {
        _("trade-comms","Which one of these goods would you like to trade?"),
        _("trade-comms","Which one would you like to trade?"),
        _("trade-comms","Make an offer."),
        _("trade-comms","What do you want to trade?"),
    }
    setCommsMessage(tableSelectRandom(trade_goods_prompt))
    if comms_target.comms_data.trade ~= nil then
        for trade_good, trade_bool in pairs(comms_target.comms_data.trade) do
            if comms_source.goods ~= nil then
                if comms_source.goods[trade_good] ~= nil then
                    if comms_source.goods[trade_good] > 0 then
                        for good, good_data in pairs(comms_target.comms_data.goods) do
                            if good_data.quantity > 0 then
                                addCommsReply(string.format(_("trade-comms","Trade %s for %s"),good_desc[trade_good],good_desc[good]),function()
                                    if not comms_source:isDocked(comms_target) then
                                        local stay_docked_to_trade = {
                                            "You need to stay docked for that action.",
                                            "You need to stay docked to trade.",
                                            string.format("You must stay docked long enough for a trade between %s and %s to be completed.",comms_source:getCallSign(),comms_target:getCallSign()),
                                            string.format("You undocked before %s could complete the trade you wanted.",comms_target:getCallSign()),
                                        }
                                        setCommsMessage(tableSelectRandom(stay_docked_to_trade))
                                        return
                                    end
                                    if good_data.quantity < 1 then
                                        local insufficient_station_inventory = {
                                            "Insufficient station inventory",
                                            "Not enough inventory on the station",
                                            string.format("%s does not have enough inventory",comms_target:getCallSign()),
                                            string.format("Not enough inventory on %s",comms_target:getCallSign()),
                                        }
                                        setCommsMessage(tableSelectRandom(insufficient_station_inventory))
                                    else
                                        good_data.quantity = good_data.quantity - 1
                                        if comms_source.goods[good] == nil then
                                            comms_source.goods[good] = 0
                                        end
                                        comms_source.goods[good] = comms_source.goods[good] + 1
                                        comms_source.goods[trade_good] = comms_source.goods[trade_good] - 1
                                        local trade_confirmation = {
                                            string.format("Traded a %s for a %s",good_desc[trade_good],good_desc[good]),
                                            string.format("You traded one %s for one %s",good_desc[trade_good],good_desc[good]),
                                            string.format("%s agreed to trade a %s for a %s",comms_target:getCallSign(),good_desc[trade_good],good_desc[good]),
                                            string.format("You successfully traded a %s for a %s",good_desc[trade_good],good_desc[good]),
                                        }
                                        setCommsMessage(tableSelectRandom(trade_confirmation))
                                        comms_target.comms_data.friendlyness = math.min(100,comms_target.comms_data.friendlyness + random(2,5))
                                    end
                                    addCommsReply(_("trade-comms","Back to trade options"), tradeGoodsWithStation)
                                    addCommsReply(_("trade-comms","Back to commercial options"),goodsCommerce)
                                    addCommsReply("Back to interactive relay officer",interactiveDockedStationCommsMeat)
                                    addCommsReply(_("Back to station communication"), commsStation)
                                end)
                            end
                        end
                    end
                end
            end
        end
    end
end
function sellGoodsToStation()
    local sell_goods_prompt = {
        _("trade-comms","Which one of these goods would you like to sell?"),
        _("trade-comms","Which one would you like to sell?"),
        _("trade-comms","You may choose from these to sell."),
        _("trade-comms","What do you want to sell?"),
    }
    local good_match_count = 0
    if comms_target.comms_data.buy ~= nil then
        for good, price in pairs(comms_target.comms_data.buy) do
            if comms_source.goods[good] ~= nil and comms_source.goods[good] > 0 then
                good_match_count = good_match_count + 1
                local sell_a_good_prompt = {
                    string.format("Sell one %s for %i reputation",good_desc[good],price),
                    string.format("Sell a %s for %i reputation",good_desc[good],price),
                    string.format("Sell %s and get %i reputation",good_desc[good],price),
                    string.format("For %s reputation, sell a %s",price,good_desc[good]),
                }
                addCommsReply(tableSelectRandom(sell_a_good_prompt), function()
                    if not comms_source:isDocked(comms_target) then
                        local stay_docked_to_sell = {
                            "You need to stay docked for that action.",
                            "You need to stay docked to sell.",
                            string.format("You must stay docked long enough for a sale between %s and %s to be completed.",comms_source:getCallSign(),comms_target:getCallSign()),
                            string.format("You undocked before %s could complete the sale you requested.",comms_target:getCallSign()),
                        }
                        setCommsMessage(tableSelectRandom(stay_docked_to_sell))
                        return
                    end
                    local good_type_label = {
                        string.format("Type: %s",good_desc[good]),
                        string.format("Type of good: %s",good_desc[good]),
                        string.format("Good type: %s",good_desc[good]),
                        string.format("Kind of good: %s",good_desc[good]),
                    }
                    local reputation_price_of_good = {
                        string.format("Reputation price: %i",price),
                        string.format("Price in reputation points: %i",price),
                        string.format("Reputation sale price: %i",price),
                        string.format("Priced at %i reputation",price),
                    }
                    local sale_results = {
                        "One sold",
                        "You sold one",
                        string.format("You sold one to %s",comms_target:getCallSign()),
                        string.format("%s bought one from you",comms_target:getCallSign()),
                    }
                    setCommsMessage(string.format("%s, %s\n%s",tableSelectRandom(good_type_label),tableSelectRandom(reputation_price_of_good),tableSelectRandom(sale_results)))
                    comms_source.goods[good] = comms_source.goods[good] - 1
                    comms_source:addReputationPoints(price)
                    comms_source.cargo = comms_source.cargo + 1
                    addCommsReply(_("trade-comms","Back to sell to station options"),sellGoodsToStation)
                    addCommsReply(_("trade-comms","Back to commercial options"),goodsCommerce)
                    addCommsReply("Back to interactive relay officer",interactiveDockedStationCommsMeat)
                    addCommsReply(_("trade-comms","Back to station communication"), commsStation)
                end)
            end
        end
    else
        local no_goods_to_buy = {
            "This station is no longer in the market to buy goods",
            string.format("%s is no longer in the market to buy goods",comms_target:getCallSign()),
            string.format("%s has left the goods buying market",comms_target:getCallSign()),
            string.format("%s no longer wants to buy any goods",comms_target:getCallSign()),
        }
        setCommsMessage(tableSelectRandom(no_goods_to_buy))
    end
    if good_match_count == 0 then
        local no_matching_sellable_goods = {
            "You no longer have anything the station is interested in.",
            string.format("You have nothing %s is interested in.",comms_target:getCallSign()),
            string.format("%s is not interested in any goods you have.",comms_target:getCallSign()),
            string.format("[%s purchasing agent]\n'Sorry, %s. You have nothing that interests us.'\nYou hear the sound of a ledger book closing just before the mic cuts off.",comms_target:getCallSign(),comms_source:getCallSign()),
        }
        setCommsMessage(tableSelectRandom(no_matching_sellable_goods))
    end
    addCommsReply(_("trade-comms","Back to commercial options"),goodsCommerce)
    addCommsReply("Back to interactive relay officer",interactiveDockedStationCommsMeat)
    addCommsReply(_("Back to station communication"), commsStation)
end
function buyGoodsFromStation()
    local buy_goods_prompt = {
        _("trade-comms","Which one of these goods would you like to buy?"),
        _("trade-comms","Which one would you like to buy?"),
        _("trade-comms","You can choose to buy one of these."),
        _("trade-comms","What do you want to buy?"),
    }
    setCommsMessage(tableSelectRandom(buy_goods_prompt))
    if comms_target.comms_data.goods ~= nil then
        for good, good_data in pairs(comms_target.comms_data.goods) do
            local buy_goods_at_price_prompts = {
                string.format("Buy one %s for %i reputation",good_desc[good],good_data["cost"]),
                string.format("Buy a %s for %i reputation",good_desc[good],good_data["cost"]),
                string.format("Buy %s from %s for %i rep",good_desc[good],comms_target:getCallSign(),good_data["cost"]),
                string.format("Purchase %s for %i reputation",good_desc[good],good_data["cost"]),
            }
            addCommsReply(tableSelectRandom(buy_goods_at_price_prompts), function()
                if not comms_source:isDocked(comms_target) then
                    local stay_docked_to_buy = {
                        "You need to stay docked for that action.",
                        "You need to stay docked to buy.",
                        string.format("You must stay docked long enough for a sale between %s and %s to be completed.",comms_target:getCallSign(),comms_source:getCallSign()),
                        string.format("You undocked before %s could complete the sale you requested.",comms_target:getCallSign()),
                    }
                    setCommsMessage(tableSelectRandom(stay_docked_to_buy))
                    return
                end
                local good_type_label = {
                    string.format("Type: %s",good_desc[good]),
                    string.format("Type of good: %s",good_desc[good]),
                    string.format("Good type: %s",good_desc[good]),
                    string.format("Kind of good: %s",good_desc[good]),
                }
                local reputation_price_of_good = {
                    string.format("Reputation price: %i",good_data["cost"]),
                    string.format("Price in reputation points: %i",good_data["cost"]),
                    string.format("Reputation sale price: %i",good_data["cost"]),
                    string.format("Priced at %i reputation",good_data["cost"]),
                }
                local quantity_of_good = {
                    string.format("Quantity: %s",good_data["quantity"]),
                    string.format("How much inventory: %s",good_data["quantity"]),
                    string.format("%s's quantity: %s",comms_target:getCallSign(),good_data["quantity"]),
                    string.format("Quantity on hand: %s",good_data["quantity"]),
                }
                local purchase_results = {
                    "One bought",
                    "You bought one",
                    string.format("You purchased one from %s",comms_target:getCallSign()),
                    string.format("%s sold one to you",comms_target:getCallSign()),
                }
                local goodTransactionMessage = string.format("%s\n%s\n%s",tableSelectRandom(good_type_label),tableSelectRandom(reputation_price_of_good),tableSelectRandom(quantity_of_good))
                if comms_source.cargo < 1 then
                    local insufficient_cargo_space_addendum = {
                        "Insufficient cargo space for purchase",
                        "You don't have enough room in your cargo hold",
                        string.format("Insufficient room in %s's cargo hold",comms_source:getCallSign()),
                        string.format("%s does not have enough available cargo space",comms_source:getCallSign()),
                    }
                    goodTransactionMessage = string.format("%s\n%s",goodTransactionMessage,tableSelectRandom(insufficient_cargo_space_addendum))
                elseif good_data["cost"] > math.floor(comms_source:getReputationPoints()) then
                    local insufficient_rep_responses = {
                        "Insufficient reputation",
                        "Not enough reputation",
                        "You need more reputation",
                        string.format("You need more than %i reputation",math.floor(comms_source:getReputationPoints())),
                        "You don't have enough reputation",
                    }
                    goodTransactionMessage = string.format("%s\n%s",goodTransactionMessage,tableSelectRandom(insufficient_rep_responses))
                elseif good_data["quantity"] < 1 then
                    local insufficient_station_inventory = {
                        "Insufficient station inventory",
                        "Not enough inventory on the station",
                        string.format("%s does not have enough inventory",comms_target:getCallSign()),
                        string.format("Not enough inventory on %s",comms_target:getCallSign()),
                    }
                    goodTransactionMessage = string.format("%s\n%s",goodTransactionMessage,tableSelectRandom(insufficient_station_inventory))
                else
                    if comms_source:takeReputationPoints(good_data["cost"]) then
                        comms_source.cargo = comms_source.cargo - 1
                        good_data["quantity"] = good_data["quantity"] - 1
                        if comms_source.goods == nil then
                            comms_source.goods = {}
                        end
                        if comms_source.goods[good] == nil then
                            comms_source.goods[good] = 0
                        end
                        comms_source.goods[good] = comms_source.goods[good] + 1
                        goodTransactionMessage = string.format("%s\n%s",goodTransactionMessage,tableSelectRandom(purchase_results))
                    else
                        local insufficient_rep_responses = {
                            "Insufficient reputation",
                            "Not enough reputation",
                            "You need more reputation",
                            string.format("You need more than %i reputation",math.floor(comms_source:getReputationPoints())),
                            "You don't have enough reputation",
                        }
                        goodTransactionMessage = string.format("%s\n%s",goodTransactionMessage,tableSelectRandom(insufficient_rep_responses))
                    end
                end
                setCommsMessage(goodTransactionMessage)
                addCommsReply(_("trade-comms","Back to buy goods from station options"),buyGoodsFromStation)
                addCommsReply(_("trade-comms","Back to commercial options"),goodsCommerce)
                addCommsReply("Back to interactive relay officer",interactiveDockedStationCommsMeat)
                addCommsReply(_("Back to station communication"), commsStation)
            end)
        end
    else
        local insufficient_station_inventory = {
            "Insufficient station inventory",
            "Not enough inventory on the station",
            string.format("%s does not have enough inventory",comms_target:getCallSign()),
            string.format("Not enough inventory on %s",comms_target:getCallSign()),
        }
        setCommsMessage(tableSelectRandom(insufficient_station_inventory))
    end
    addCommsReply(_("trade-comms","Back to commercial options"),goodsCommerce)
    addCommsReply("Back to interactive relay officer",interactiveDockedStationCommsMeat)
    addCommsReply(_("Back to station communication"), commsStation)
end
function jettisonGoodsFromShip()
    local jettison_prompt = {
        _("trade-comms","What should be jettisoned?"),
        _("trade-comms","You pick it and out the airlock it will go."),
        _("trade-comms","What do you want to chunk out the airlock?"),
        _("trade-comms","What shall we toss out the airlock?"),
    }
    setCommsMessage(tableSelectRandom(jettison_prompt))
    local goods_to_toss_count = 0
    for good, good_quantity in pairs(comms_source.goods) do
        if good_quantity > 0 then
            goods_to_toss_count = goods_to_toss_count + 1
            addCommsReply(good_desc[good], function()
                comms_source.goods[good] = comms_source.goods[good] - 1
                comms_source.cargo = comms_source.cargo + 1
                local jettisoned_confirmed = {
                    string.format("One %s jettisoned",good_desc[good]),
                    string.format("One %s has been destroyed",good_desc[good]),
                    string.format("One %s has been tossed out of the airlock",good_desc[good]),
                    string.format("One %s has been placed in the arms of the vacuum of space",good_desc[good]),
                }
                setCommsMessage(tableSelectRandom(jettisoned_confirmed))
                addCommsReply(_("trade-comms","Back to jettison goods"),jettisonGoodsFromShip)
                addCommsReply(_("Back to commercial options"), goodsCommerce)
                addCommsReply("Back to interactive relay officer",interactiveDockedStationCommsMeat)
                addCommsReply(_("Back to station communication"), commsStation)
            end)
        end
    end
    if goods_to_toss_count == 0 then
        local nothing_to_jettison = {
            "No more goods to toss",
            "You've got nothing left to jettison",
            "Your cargo hold is empty so there's nothing else to get rid of",
            "No more goods to jettison",
        }
        setCommsMessage(tableSelectRandom(nothing_to_jettison))
        addCommsReply(_("Back to commercial options"), goodsCommerce)
        addCommsReply("Back to interactive relay officer",interactiveDockedStationCommsMeat)
        addCommsReply(_("Back to station communication"), commsStation)
    end
    addCommsReply(_("trade-comms","Back to commercial options"),goodsCommerce)
    addCommsReply("Back to interactive relay officer",interactiveDockedStationCommsMeat)
    addCommsReply(_("Back to station communication"), commsStation)
end
--[[REMOVE
function jumpCorridor()
    local jump_corridor_list = {
        ["Icarus"] =     {station = stationIcarus,    region = "Icarus (F5)",        spawn_x = 0,        spawn_y = 0,        has_spawned = icarus_color,                                                spawn_terrain =    createIcarusColor,    despawn_terrain = removeIcarusColor,    },
        ["Kentar"] =     {station = stationKentar,    region = "Kentar (R17)",    spawn_x = 250000,    spawn_y = 250000,    has_spawned = kentar_color,                                                spawn_terrain = createKentarColor,    despawn_terrain = removeKentarColor,    },
        ["Astron"] =     {station = stationAstron,    region = "Astron (U33)",    spawn_x = 460500,    spawn_y = 320500,    has_spawned = astron_color,                                                spawn_terrain = ghostNebulaSector,    despawn_terrain = removeAstronColor,    },
        ["Lafrina"] =    {station = stationLafrina,    region = "Lafrina (T-8)",    spawn_x = -237666,    spawn_y = 296975,    has_spawned = universe:hasRegionSpawned(universe.available_regions[5]),    spawn_terrain = lafrinaSector,        despawn_terrain = removeLafrinaColor,    },
        ["Teresh"] =    {station = stationTeresh,    region = "Teresh (K44)",    spawn_x = 800001,    spawn_y = 120001,    has_spawned = teresh_color,                                                spawn_terrain = tereshSector,        despawn_terrain = removeTereshColor,    },
        ["Bask"] =        {station = stationBask,        region = "Bask (R56)",        spawn_x = 1027800,    spawn_y = 251000,    has_spawned = bask_color,                                                spawn_terrain = baskSector,            despawn_terrain = removeBaskColor,        },
    }
    local skeleton_docked = false
    for name, jc_item in pairs(jump_corridor_list) do
        if comms_target == jc_item.station then
            skeleton_docked = true
            break
        end
    end
    if skeleton_docked then
        local all_docked = true
        for i,p in ipairs(getActivePlayerShips()) do
            if not p:isDocked(comms_target) then
                all_docked = false
                break
            end
        end
        if all_docked then
            origin_jc_item = nil
            for name, jc_item in pairs(jump_corridor_list) do
                if string.find(name,comms_target:getCallSign()) then
                    origin_jc_item = jc_item
                    break
                end
            end
            local take_jump_corridor_prompts = {
                "Take jump corridor to another station",
                "Activate jump corridor to another station",
                "Go to another station via the jump corridor",
                "Use jump corridor to go to another station",
            }
            addCommsReply(tableSelectRandom(take_jump_corridor_prompts),function()
                local choose_jump_station = {
                    "What station would you like to take the jump corridor to?",
                    "Select a station as the jump corridor destination",
                    "Select jump corridor destination station",
                    string.format("[%s jump corridor operator]\n'What is your station destination, %s?'\nThe jump corridor operator sounds like a bright and happy sentient being.",comms_target:getCallSign(),comms_source:getCallSign()),
                }
                setCommsMessage(tableSelectRandom(choose_jump_station))
                for name, jc_item in pairs(jump_corridor_list) do
                    if comms_target ~= jc_item.station then
                        addCommsReply(string.format("Take jump corridor to %s",jc_item.station:getCallSign()),function()
                            playerSpawnX = jc_item.spawn_x
                            playerSpawnY = jc_item.spawn_y
                            for i,p in ipairs(getActivePlayerShips()) do
                                p:commandUndock()
                                p:setPosition(playerSpawnX,playerSpawnY)
                                p:commandImpulse(0)
                            end
                            local jt = comms_target:getObjectsInRange(5000)
                            jump_train = {}
                            if #jt > 0 then
                                for index, ship in ipairs(jt) do
                                    if ship:isValid() and ship.typeName == "CpuShip" and ship:isDocked(comms_target) then
                                        ship:orderDefendTarget(getPlayerShip(-1))
    --                                    ship:orderFlyFormation(getPlayerShip(-1),fleetPosDelta1x[index+1]*500,fleetPosDelta1y[index+1]*500)
                                        ship.jump_corridor_x = playerSpawnX+fleetPosDelta1x[index+1]*500
                                        ship.jump_corridor_y = playerSpawnY+fleetPosDelta1y[index+1]*500
                                        ship:setPosition(playerSpawnX+fleetPosDelta1x[index+1]*500,playerSpawnY+fleetPosDelta1y[index+1]*500)
                                        table.insert(jump_train,ship)
                                    end
                                end
                            end
                            startRegion = jc_item.region
                            if not jc_item.has_spawned then
                                jc_item.spawn_terrain()
                            end
                            if origin_jc_item ~= nil then
                                origin_jc_item.despawn_terrain()
                            end
                            local jump_journey_complete = {
                                string.format("Transferred to %s",jc_item.station:getCallSign()),
                                string.format("The jump corridor has transferred you to %s",jc_item.station:getCallSign()),
                                string.format("[Automated message]\n'You have arrived at %s. Thank you for using the flagship product of Jump Corridors R Us. We know you have a choice when traveling. We appreciate your business.'",jc_item.station:getCallSign()),
                                string.format("The jump corridor drops you at %s",jc_item.station:getCallSign()),
                            }
                            setCommsMessage(tableSelectRandom(jump_journey_complete))
                        end)
                    end
                end
				addCommsReply("Back to interactive relay officer",interactiveDockedStationCommsMeat)
				addCommsReply("Back to station communication",commsStation)
            end)
        end
    end
end--]]
function isAllowedTo(state)
    if state == "friend" and comms_source:isFriendly(comms_target) then
        return true
    end
    if state == "neutral" and not comms_source:isEnemy(comms_target) then
        return true
    end
    return false
end
function getWeaponCost(weapon)
    if comms_data.weapon_cost == nil then
        print("comms data weapons cost is nil. Station:",comms_target:getCallSign())
    end
    if comms_data.weapon_cost[weapon] == nil then
        print("comms data weapon cost for weapon",weapon,"is nil. Station:",comms_target:getCallSign())
    end
    return math.ceil(comms_data.weapon_cost[weapon] * comms_data.reputation_cost_multipliers[getFriendStatus()])
end
function getServiceCost(service)
    if comms_data.service_cost == nil then
        print("comms data service cost is nil. Station:",comms_target:getCallSign())
        return 9999
    elseif comms_data.service_cost[service] == nil then
        print("comms data service cost for service",service,"is nil. Station:",comms_target:getCallSign())
        return 9999
    else
        return math.ceil(comms_data.service_cost[service])
    end
end
function getFriendStatus()
    if comms_source:isFriendly(comms_target) then
        return "friend"
    else
        return "neutral"
    end
end
function playerShipCargoInventory(p)
    local out = string.format("%s Current cargo:",p:getCallSign())
    local goodCount = 0
    if p.goods ~= nil then
        for good, goodQuantity in pairs(p.goods) do
            goodCount = goodCount + 1
            out = string.format("%s\n     %s: %i",out,good,goodQuantity)
        end
    end
    if goodCount < 1 then
        out = string.format("%s\n     Empty",out)
    end
    out = string.format("%s\nAvailable space: %i",out,p.cargo)
    out = string.format("%s\nEscape pods: %i   Available pod slots: %i",out,p.max_pods - p.pods,p.pods)
    return out
end
function levelCoolant(p)
    if p:isValid() then
        local installed_systems = {}
        for _, system in ipairs(system_list) do
            if p:hasSystem(system) then
                table.insert(installed_systems,system)
            end
        end
        local level_coolant = p:getMaxCoolant()/#installed_systems
        for _, system in ipairs(installed_systems) do
            p:setSystemCoolant(system,level_coolant)
            p:commandSetSystemCoolantRequest(system,level_coolant)
        end
    end
end

function intimidateStationComms(comms_source, comms_target)
	if (comms_source.special_intimidate_stations or comms_source:getResourceAmount("Station Boarding Pod") > 0) and comms_target:getFaction() ~= "Human Navy" then
		local current_faction = comms_target:getFaction()
		setCommsMessage(_("special-comms", "You are our declared enemy. What do you want?"))
		local cost = special_buy_cost(comms_target, comms_source)
		addCommsReply(string.format(_("special-comms", "Surrender now! [Cost: %s Rep.]"), cost), function()

			if not comms_target:areEnemiesInRange(5000) then
				setCommsMessage(_("needRep-comms", "We will not surrender unless threatened."))
			elseif not (comms_target:getHull() < comms_target:getHullMax()) then
				setCommsMessage(_("needRep-comms", "We will not surrender until our hull is damaged."))
			else
				comms_target:setFaction("Human Navy")
				if comms_target:areEnemiesInRange(5000) then
					comms_target:setFaction(current_faction)
					setCommsMessage(_("needRep-comms", "We will not surrender as long as enemies of the Human Navy are still near."))
				elseif not comms_source:takeReputationPoints(cost) then
					comms_target:setFaction(current_faction)
					setCommsMessage(_("needRep-comms", "Insufficient reputation"))
				else
					comms_target:setFaction("Independent")
					setCommsMessage(_("special-comms", "Station surrendered."))
				end
			end
		end)
	end
end
function buyStationComms(comms_source, comms_target)
	if (comms_source.special_buy_stations or comms_source:getResourceAmount("Station Command Team") > 0) and comms_target:getFaction() ~= "Human Navy" then
		local cost = special_buy_cost(comms_target, comms_source)
		addCommsReply(string.format(_("special-comms", "Submit your station to the Human Navy. [Cost: %s Rep.]"), cost), function()
			if not comms_source:takeReputationPoints(cost) then
				setCommsMessage(_("needRep-comms", "Insufficient reputation"))
			else
				comms_target:setFaction(comms_source:getFaction())
				local gain = comms_target:getHullMax() * 4 / 60
				setCommsMessage(string.format(_("special-comms", "This station now belongs to the Human Navy, Sir.\n\nAs long as the Human Navy keeps the station alive, your reputation will rise by %d per minute."), math.floor(gain)))
			end
		end)
	end
end

-- `comms_source` and `comms_target` are global in comms script.
commsStation(comms_source, comms_target)
