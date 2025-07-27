--[[ Stations 
Manages stations

* Places stations inside terrain modules
* update station rep
* manages stations trade
* manages stations quests

--]]
avp_stations = {
	stations = {},
}

require "place_station_scenario_utility.lua"
require "luax.lua"

function avp_stations:init()
	local characters = {
		{name = "Frank Brown", subject_pronoun = "he", object_pronoun = "him", possessive_adjective = "his"},
		{name = "Joyce Miller", subject_pronoun = "she", object_pronoun = "her", possessive_adjective = "her"},
		{name = "Harry Jones", subject_pronoun = "he", object_pronoun = "him", possessive_adjective = "his"},
		{name = "Emma Davis", subject_pronoun = "she", object_pronoun = "her", possessive_adjective = "her"},
		{name = "Zhang Wei Chen", subject_pronoun = "he", object_pronoun = "him", possessive_adjective = "his"},
		{name = "Yu Yan Li", subject_pronoun = "she", object_pronoun = "her", possessive_adjective = "her"},
		{name = "Li Wei Wang", subject_pronoun = "he", object_pronoun = "him", possessive_adjective = "his"},
		{name = "Li Na Zhao", subject_pronoun = "she", object_pronoun = "her", possessive_adjective = "her"},
		{name = "Sai Laghari", subject_pronoun = "he", object_pronoun = "him", possessive_adjective = "his"},
		{name = "Anaya Khatri", subject_pronoun = "she", object_pronoun = "her", possessive_adjective = "her"},
		{name = "Vihaan Reddy", subject_pronoun = "he", object_pronoun = "him", possessive_adjective = "his"},
		{name = "Trisha Varma", subject_pronoun = "she", object_pronoun = "her", possessive_adjective = "her"},
		{name = "Henry Gunawan", subject_pronoun = "he", object_pronoun = "him", possessive_adjective = "his"},
		{name = "Putri Febrian", subject_pronoun = "she", object_pronoun = "her", possessive_adjective = "her"},
		{name = "Stanley Hartono", subject_pronoun = "he", object_pronoun = "him", possessive_adjective = "his"},
		{name = "Citra Mulyadi", subject_pronoun = "she", object_pronoun = "her", possessive_adjective = "her"},
		{name = "Bashir Pitafi", subject_pronoun = "he", object_pronoun = "him", possessive_adjective = "his"},
		{name = "Hania Kohli", subject_pronoun = "she", object_pronoun = "her", possessive_adjective = "her"},
		{name = "Gohar Lehri", subject_pronoun = "he", object_pronoun = "him", possessive_adjective = "his"},
		{name = "Sohelia Lau", subject_pronoun = "she", object_pronoun = "her", possessive_adjective = "her"},
		{name = "Gabriel Santos", subject_pronoun = "he", object_pronoun = "him", possessive_adjective = "his"},
		{name = "Ana Melo", subject_pronoun = "she", object_pronoun = "her", possessive_adjective = "her"},
		{name = "Lucas Barbosa", subject_pronoun = "he", object_pronoun = "him", possessive_adjective = "his"},
		{name = "Juliana Rocha", subject_pronoun = "she", object_pronoun = "her", possessive_adjective = "her"},
		{name = "Habib Oni", subject_pronoun = "he", object_pronoun = "him", possessive_adjective = "his"},
		{name = "Chinara Adebayo", subject_pronoun = "she", object_pronoun = "her", possessive_adjective = "her"},
		{name = "Tanimu Ali", subject_pronoun = "he", object_pronoun = "him", possessive_adjective = "his"},
		{name = "Naija Bello", subject_pronoun = "she", object_pronoun = "her", possessive_adjective = "her"},
		{name = "Shamim Khan", subject_pronoun = "he", object_pronoun = "him", possessive_adjective = "his"},
		{name = "Barsha Tripura", subject_pronoun = "she", object_pronoun = "her", possessive_adjective = "her"},
		{name = "Sumon Das", subject_pronoun = "he", object_pronoun = "him", possessive_adjective = "his"},
		{name = "Farah Munsi", subject_pronoun = "she", object_pronoun = "her", possessive_adjective = "her"},
		{name = "Denis Popov", subject_pronoun = "he", object_pronoun = "him", possessive_adjective = "his"},
		{name = "Pasha Sokolov", subject_pronoun = "she", object_pronoun = "her", possessive_adjective = "her"},
		{name = "Burian Ivanov", subject_pronoun = "he", object_pronoun = "him", possessive_adjective = "his"},
		{name = "Radka Vasiliev", subject_pronoun = "she", object_pronoun = "her", possessive_adjective = "her"},
		{name = "Jose Hernandez", subject_pronoun = "he", object_pronoun = "him", possessive_adjective = "his"},
		{name = "Victoria Garcia", subject_pronoun = "she", object_pronoun = "her", possessive_adjective = "her"},
		{name = "Miguel Lopez", subject_pronoun = "he", object_pronoun = "him", possessive_adjective = "his"},
		{name = "Renata Rodriguez", subject_pronoun = "she", object_pronoun = "her", possessive_adjective = "her"},
	}
--[[
	repeat		
		local ox, oy = vectorFromAngle(random(0,360),random(40000,100000))
		ox = ox + center_x
		oy = oy + center_y
		local obj_list = getObjectsInRadius(ox, oy, 20000)
		if #obj_list == 0 then
			local station = placeStation(ox, oy, "RandomHumanNeutral", "Arlenians")	-- random size
			if station ~= nil then
				station:setCommsScript("comms_station_sandbox.lua")
				local character = table.remove(characters)	-- pop one into this station
				if character ~= nil then
					station.characters = {character}
				end
				table.insert(self.stations, station)
				station.surrender_hull_threshold = math.random(40,80)	-- for avp_kraylor
			else
				break
			end
		end
		placement_attempt_count = placement_attempt_count + 1
	until(placement_attempt_count > 500)

	-- distribute remaining characters, if any
	while #characters > 0 do
		local station = tableSelectRandom(self.stations)
		table.insert(station.characters, table.remove(characters))
	end


	self:setRepairMissions()
	getScriptStorage().avp_stations = self 
--]]
end


function avp_stations:createInTerrain(terrain_module)
	-- call sub-functions from the utility
	local group, station = pickStation("RandomHumanNeutral")	-- could also be a group or a name
	station:setFaction("Independent")
	local sizeTemplate = szt()
--	if TEST then
--		sizeTemplate = "Huge Station"
--	end
	station:setTemplate(sizeTemplate)

	-- place station
	terrain_module:insertStation(station)

	-- do not use most of the comms data from the utility,
	-- keep description, general, history as they are descriptive

	-- disable weapons:
	station.comms_data.weapon_available = {
		Homing =			false,
		HVLI =				false,
		Mine =				false,
		Nuke =				false,
		EMP =				false,
	}

	-- this table is for isAllowedTo, it understands "friend" and "neutral" - everything else is denied.
	-- disable all as default, enable selected later
	station.comms_data.services = {	
		reinforcements = false,
		supplydrop = false,	-- TODO "friend", when contents match our docking services.
		jumpsupplydrop = false,
		subsystem_repair = false,	-- TODO were different ones for every subsystem
		system_repair = false,		-- TODO were different ones for every system
		coolant_pump_repair = false,	-- TODO were different ones for every system
		jump_overcharge = false,
		share_energy = false,
		repair_docked = false,
		restock_probes = false,
		sell_weapons = false,	-- TODO checked before weapon_available
	}
	station.comms_data.service_cost = {
		supplydrop =		math.random(80,120), 
		reinforcements =	math.random(125,175),
		jumpsupplydrop =	math.random(110,140),
		subsystem_repair =	math.random(2,8),
		system_repair =		math.random(4,18),
		coolant_pump_repair = math.random(3,12),
		jump_overcharge =	math.random(20,40),
		share_energy =		math.random(10,20),
		repair_docked =		math.random(10,30),
		restock_probes =	math.random(10,20),
	}

	--[[ unmodified
	station.comms_data.reputation_cost_multipliers = {
		friend = 			1.0, 
		neutral = 			irandom(2,3),	-- is given by utility per station
	}
	--]]

	-- disable xanstas trade system, since I dont really like it
	station.comms_data.goods = {}
	station.comms_data.trade = nil

	-- services depend on terrain type:
	local services = {}
	local all_services = {
		"reinforcements",
		"supplydrop",
		"jumpsupplydrop",
		"subsystem_repair",
		"system_repair",
		"coolant_pump_repair",
		"jump_overcharge",
		"share_energy",
		"repair_docked",
		"restock_probes",
		"sell_weapons",
	}
	if terrain_module.terrain_type == "asteroids" then
		station.comms_data.weapon_available.HVLI = true
		services = {"repair_docked", "sell_weapons"}
	elseif terrain_module.terrain_type == "nebulae" then
		station.comms_data.weapon_available.Homing = true
		services = {"coolant_pump_repair", "restock_probes", "sell_weapons"}
	elseif terrain_module.terrain_type == "mines" then
		station.comms_data.weapon_available.Mine = true
		services = {"sell_weapons", "jump_overcharge"}
	elseif terrain_module.terrain_type == "blackholes" then
		station.comms_data.weapon_available.EMP = true
		services = {"subsystem_repair", "sell_weapons", "share_energy"}
	elseif terrain_module.terrain_type == "planets" then
		station.comms_data.weapon_available.Nuke = true
		services = {"reinforcements", "system_repair", "repair_docked", "sell_weapons"}
	elseif terrain_module.terrain_type == "wormholes" then
		services = {"restock_probes", "supplydrop", "jumpsupplydrop"}
	end

	-- all the specific services are available for friends only
	for _, service in ipairs(services) do
		station.comms_data.services[service] = "friend"
	end

	-- choose few of the services for neutrals
	arrayShuffle(services)
	arrayShuffle(all_services)
	local amount = 2	-- default
	if sizeTemplate == "Small Station" then
		amount = 1
	elseif sizeTemplate == "Medium Station" then
		amount = 2
	elseif sizeTemplate == "Large Station" then
		amount = 3
	elseif sizeTemplate == "Huge Station" then
		amount = 4
	end
	for i=1, amount do
		local service = table.remove(services)
		if service == nil then	-- all local services used up, add common ones
			service = table.remove(all_services)
		end
		station.comms_data.services[service] = "neutral"
	end
	
	station:setSharesEnergyWithDocked(station.comms_data.services.share_energy ~= false)
	station:setRepairDocked(station.comms_data.services.repair_docked ~= false)
	station:setRestocksScanProbes(station.comms_data.services.restock_probes ~= false)

	return station
end



--[[
function avp_stations:initTest()
	local x,y = self.stations[1]:getPosition()
	local ship = PlayerSpaceship():setTemplate("Adder MK7"):setCallSign("Station Visitor"):setPosition(x,y):setRotation(90):commandTargetRotation(90)
	ship:setResourceAmount("Station Command Team", 1)
	ship:setResourceAmount("Station Boarding Pod", 1)
	ship:setResourceAmount("Diplomatic Crew", 1)
	ship:setResourceAmount("Xenolinguistic Team", 1)
end
--]]
--[[
function avp_stations:setRepairMissions()
    local mission_reasons = {
        ["energy"] = {
            [_("situationReport-comms", "A recent reactor failure has put us on auxiliary power, so we cannot recharge ships.")] = {
                "nickel","platinum","gold","dilithium","tritanium","cobalt","optic","filament","sensor","lifter","software","circuit","battery"
            },
            [_("situationReport-comms", "A damaged power coupling makes it too dangerous to recharge ships.")] = {
                "nickel","platinum","gold","dilithium","tritanium","cobalt","optic","filament","sensor","lifter","circuit","battery"
            },
            [_("situationReport-comms", "An asteroid strike damaged our solar cells and we are short on power, so we can't recharge ships right now.")] = {
                "nickel","platinum","gold","dilithium","tritanium","cobalt","optic","filament","sensor","circuit","battery"
            },
        },
        ["hull"] = {
            [_("situationReport-comms", "We're out of the necessary materials and supplies for hull repair.")] = {
                "nickel","platinum","dilithium","tritanium","cobalt","lifter","filament","sensor","circuit","repulsor","nanites","shield"
            },
            [_("situationReport-comms", "Hull repair automation unavailable while it is undergoing maintenance.")] = {
                "nickel","platinum","gold","dilithium","tritanium","cobalt","optic","filament","sensor","lifter","software","circuit","android","robotic","nanites"
            },
            [_("situationReport-comms", "All hull repair technicians quarantined to quarters due to illness.")] = {
                "medicine","transporter","sensor","communication","autodoc","android","nanites"
            },
        },
        ["restock_probes"] = {
            [_("situationReport-comms", "Cannot replenish scan probes due to fabrication unit failure.")] = {
                "nickel","platinum","gold","dilithium","tritanium","cobalt","optic","filament","sensor","lifter","software","circuit","battery"
            },
            [_("situationReport-comms", "Parts shortage prevents scan probe replenishment.")] = {
                "optic","filament","shield","impulse","warp","sensor","lifter","circuit","battery","communication"
            },
            [_("situationReport-comms", "Station management has curtailed scan probe replenishment for cost cutting reasons.")] = {
                "nickel","platinum","gold","dilithium","tritanium","cobalt","luxury"
            },
        }
    }
    local mission_goods = {}
    local ordnance_missions = {
        "Homing","Nuke","EMP","Mine","HVLI",
    }
    for i,mission in ipairs(ordnance_missions) do
        mission_goods[mission] = {"nickel","platinum","gold","dilithium","tritanium","cobalt","circuit","filament"}
    end
    table.insert(mission_goods.Homing,"sensor")
    table.insert(mission_goods.Nuke,"sensor")
    table.insert(mission_goods.EMP,"sensor")
	assert (vapor_goods ~= nil)	-- from xansta_mods

    local mission_stations = self.stations
    for i,station in ipairs(mission_stations) do
		station.mission_goods = {}
		for j,m_type in ipairs(ordnance_missions) do
			station.mission_goods[m_type] = tableSelectRandom(mission_goods[m_type])
		end
		if not station:getRestocksScanProbes() then
				local reason_list = {
					_("situationReport-comms", "Cannot replenish scan probes due to fabrication unit failure."),
					_("situationReport-comms", "Parts shortage prevents scan probe replenishment."),
					_("situationReport-comms", "Station management has curtailed scan probe replenishment for cost cutting reasons."),
				}
				station.probe_fail_reason = reason_list[math.random(1,#reason_list)]
				station.mission_goods["restock_probes"] = tableSelectRandom(mission_reasons["restock_probes"][station.probe_fail_reason])
		end
		if not station:getRepairDocked() then
				reason_list = {
					_("situationReport-comms", "We're out of the necessary materials and supplies for hull repair."),
					_("situationReport-comms", "Hull repair automation unavailable while it is undergoing maintenance."),
					_("situationReport-comms", "All hull repair technicians quarantined to quarters due to illness."),
				}
				station.repair_fail_reason = reason_list[math.random(1,#reason_list)]
				station.mission_goods["hull"] = tableSelectRandom(mission_reasons["hull"][station.repair_fail_reason])
		end
		if not station:getSharesEnergyWithDocked() then
				reason_list = {
					_("situationReport-comms", "A recent reactor failure has put us on auxiliary power, so we cannot recharge ships."),
					_("situationReport-comms", "A damaged power coupling makes it too dangerous to recharge ships."),
					_("situationReport-comms", "An asteroid strike damaged our solar cells and we are short on power, so we can't recharge ships right now."),
				}
				station.energy_fail_reason = reason_list[math.random(1,#reason_list)]
				station.mission_goods["energy"] = tableSelectRandom(mission_reasons["energy"][station.energy_fail_reason])
		end

		--remove what is sold here
		if station.comms_data ~= nil and station.comms_data.goods ~= nil then
			for station_good,details in pairs(station.comms_data.goods) do
				for mission,mission_good in pairs(station.mission_goods) do
					if mission_good == station_good then
						station.mission_goods[mission] = tableSelectRandom(vapor_goods)
					end
				end
			end
		end
    end
	--[[ don't know what this is for...
    local missions_stations_goods = {}
    for i,station in ipairs(mission_stations) do
		if station.comms_data ~= nil and station.comms_data.goods ~= nil then
			for station_good,details in pairs(station.comms_data.goods) do
				for mission,mission_goods in pairs(mission_goods) do
					for k,mission_good in ipairs(mission_goods) do
						if mission_good == station_good then
							if missions_stations_goods[mission] == nil then
								missions_stations_goods[mission] = {}
							end
							if missions_stations_goods[mission][station] == nil then
								missions_stations_goods[mission][station] = {}
							end
							table.insert(missions_stations_goods[mission][station],mission_good)
						end
					end
				end
			end
        end
    end
    mission_good = {}
    --    Pick goods for missions
    local already_selected_station = {}
    local already_selected_good = {}
    for mission,stations_goods in pairs(missions_stations_goods) do
        local station_pool = {}
        for station,goods in pairs(stations_goods) do
            if #already_selected_station > 0 then
                local exclude = false
                for i,previous_station in ipairs(already_selected_station) do
                    if station == previous_station then
                        exclude = true
                    end
                end
                if not exclude then
                    table.insert(station_pool,station)
                end
            else
                table.insert(station_pool,station)
            end
        end
        if #station_pool > 0 then
            local selected_station = station_pool[math.random(1,#station_pool)]
            table.insert(already_selected_station,selected_station)
            local good = stations_goods[selected_station][math.random(1,#stations_goods[selected_station])]
            if #already_selected_good > 0 then
                local good_selected = false
                for i,previous_good in ipairs(already_selected_good) do
                    if previous_good == good then
                        good_selected = true
                        break
                    end
                end
                if not good_selected then
                    mission_good[mission] = {good = good, station = selected_station}
                    mission_goods[mission] = {good}
                    table.insert(already_selected_good,good)
                    selected_station.selected_mission_good = good
                end
            else
                mission_good[mission] = {good = good, station = selected_station}
                mission_goods[mission] = {good}
                table.insert(already_selected_good,good)
                selected_station.selected_mission_good = good
            end
        end
    end
    --    complete goods selection for missions
    for mission,goods in pairs(mission_goods) do
        local selected_good = nil
        if #goods > 1 then
            local good_pool = {}
            for i,good in ipairs(goods) do
                local good_selected = false
                for j,previous_good in ipairs(already_selected_good) do
                    if good == previous_good then
                        good_selected = true
                        break
                    end
                end
                if not good_selected then
                    table.insert(good_pool,good)
                end
            end
            if #good_pool > 0 then
                selected_good = good_pool[math.random(1,#good_pool)]
                mission_good[mission] = {good = selected_good}
                table.insert(already_selected_good,selected_good)
            else
                selected_good = goods[math.random(1,#goods)]
                mission_good[mission] = {good = selected_good}
            end
        else
            selected_good = goods[1]
        end
    end
    for mission,details in pairs(mission_good) do
        if details.station == nil then
            for i,station in ipairs(mission_stations) do
				if station.selected_mission_good == nil then
					if station.comms_data.goods == nil then
						station.comms_data.goods = {}
					end
					station.comms_data.goods[details.good] = {quantity = math.random(3,8), cost = math.random(40,80)}
					station.selected_mission_good = details.good
					details.station = station
					break
				end
            end
        end
    end
    print("Missions and goods final:")
    for mission,details in pairs(mission_good) do
        local out_station = "None"
        if details.station ~= nil then
            out_station = details.station:getCallSign()
        end
        print("Mission:",mission,"Good:",details.good,"Station:",out_station)
    end
	--]]
--end
--]]
function avp_stations:update(delta)
	for _, station in ipairs(self.stations) do
		if station:isValid() then
			-- stations produce their buy value in one hour
			--local gain = station:getHullMax() * 4 / 3600
			--station:addReputationPoints(gain*delta)
		end
	end
end
