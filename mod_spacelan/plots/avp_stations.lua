--[[ Stations 
Manages stations

* Places stations inside terrain modules
* update station rep
* manages stations trade
* manages stations quests


Design goal:
* Exploration & Expansion: find suitable stations and take them.

Derived from that:
* Neutral stations can be captured. Low Artifact/Rep cost. There must be a clearly communicated reward.
* Enemy stations should be capturable by combat and have a higher value than neutral ones.
* Arlenian stations want to be united (or can not be captured directly?) to share their serviced
* Independent/HN stations want to establish trade routes that need to be defended to share their services.


--]]
avp_stations = {
	stations = {},
}

require "place_station_scenario_utility.lua"
require "luax.lua"

function avp_stations:init()
	self.characters = {
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

    self.mission_goods = {}
    self.ordnance_missions = {
        "Homing","Nuke","EMP","Mine","HVLI",
    }
    for i,mission in ipairs(self.ordnance_missions) do
        self.mission_goods[mission] = {"nickel","platinum","gold","dilithium","tritanium","cobalt","circuit","filament"}
    end
    table.insert(self.mission_goods.Homing,"sensor")
    table.insert(self.mission_goods.Nuke,"sensor")
    table.insert(self.mission_goods.EMP,"sensor")
	assert (vapor_goods ~= nil)	-- from xansta_mods

end

function avp_stations:createArlenianStation(template, terrain_module)
	local groups = {"Generic", "RandomHumanNeutral", "Random"}
	for _,grpname in ipairs(groups) do
		local group, station = pickStation(grpname)
		if station ~= nil then
			station:setFaction("Arlenians"):setTemplate(template)
			avp_stations:apply_comms_script(station, terrain_module)
			table.insert(self.stations, station)
			return station
		end
	end
end

function avp_stations:createEnemyStation(templates, name_groups, terrain_module)
	local template = tableSelectRandom(templates)
	for _,grpname in ipairs(name_groups) do
		local group, station = pickStation(grpname)
		if station ~= nil then
			station:setTemplate(template)
			avp_stations:apply_comms_script(station, terrain_module)
			table.insert(self.stations, station)
			return station
		end
	end
end

function avp_stations:createExuariCarrier()
	local groups = {"Sinister", "RandomGenericSinister", "Random"}
	for _,grpname in ipairs(groups) do
		local group, station = pickStation(grpname)
		if station ~= nil then
			carrier = CpuShip():setCallSign(station:getCallSign()):setDescription(station:getDescription())
			carrier.comms_data = station.comms_data
			station:destroy()
			local stationSizeRandom = random(1,100)
			local sizeTemplate
			if stationSizeRandom <= 66 then
				sizeTemplate = "Craver"
			else
				sizeTemplate = "Ridge"
			end
			carrier:setFaction("Exuari"):setTemplate(sizeTemplate):orderStandGround()
			for idx,grp in ipairs({"frigates", "artillery", "strikers", "fighters"}) do
				for i = idx, idx*2+1 do
					local template = EnemyModuleExuari:getClassTemplate(grp)
					if i == idx then
						script_hangar:create(carrier, template, i)	-- one bay per class
					else
						script_hangar:append(carrier, template, i)
					end
				end
				script_hangar:config(carrier, "cooldownMax", 60/idx)
				script_hangar:config(carrier, "triggerRange", 50000 - 10000*idx)
			end	
			table.insert(self.stations, carrier)
			return carrier 
		end
	end
end

function avp_stations:createIndependentStation(terrain_module)
	-- call sub-functions from the utility
	local group, station = pickStation("RandomHumanNeutral")	-- could also be a group or a name
	station:setFaction("Independent")
	local sizeTemplate = szt()
	station:setTemplate(sizeTemplate)
	
	-- place station
	if terrain_module ~= nil then
		terrain_module:insertStation(station)
		if terrain_module.terrain_type == "asteroids" then
			avp_mining:activateMining(station, 2*terrain_module.radius)
		end
	end

	avp_stations:apply_comms_script(station, terrain_module)
	table.insert(self.stations, station)
	return station
end

-- modify comms_data to fit to our missions
function avp_stations:apply_comms_script(station, terrain_module)
	comms_vf_station.entry:set_as_comms_function(station)
	local hull_modifier = station:getHullMax() / 100
	-- small: 1.5
	-- medium: 4
	-- large: 5
	-- huge: 8

	station.surrender_hull_threshold = math.random(40,80)	-- for wh_kraylor

	-- do not use most of the comms data from the utility,
	-- keep description, general, history as they are descriptive.
	
	-- these are are the same for all stations. just remove them and add them later
	station.comms_data.services = nil
	station.comms_data.service_available = {}
	station.comms_data.service_cost = {}

	-- disable xanstas trade system, since I dont really like it
	station.comms_data.goods = {}
	station.comms_data.trade = nil

	-- patch in case it is missing
	if station.comms_data.reputation_cost_multipliers == nil then
		station.comms_data.reputation_cost_multipliers = {
			friend = 			1.0, 
			neutral = 			irandom(2,3),	-- is given by utility per station
		}
	end
	-- we never call placeStation, so some data is missing:
	-- removed faction_matters, but keep size_matters
	local size_matters = hull_modifier * 5
	station:setSharesEnergyWithDocked(random(1,100) <= (50 + size_matters))
	station:setRepairDocked(random(1,100) <= (55 + size_matters))
	station:setRestocksScanProbes(random(1,100) <= (45 + size_matters))
	station.comms_data.system_repair = {}
--	station.comms_data.coolant_pump_repair = {}
	local system_list = {"reactor","beamweapons","missilesystem","maneuver","impulse","warp","jumpdrive","frontshield","rearshield"}
	for i, system in ipairs(system_list) do
		local chance = 60 + size_matters
		local eval = random(1,100)
		station.comms_data.system_repair[system] = eval <= chance
		--eval = random(1,100)
		--station.comms_data.coolant_pump_repair[system] = eval <= chance
	end
	-- we currently don't use function_repair, so leave it missing
	
	-- don't know if needed:
	--station:setSharesEnergyWithDocked(station.comms_data.services.share_energy ~= false)
	--station:setRepairDocked(station.comms_data.services.repair_docked ~= false)
	--station:setRestocksScanProbes(station.comms_data.services.restock_probes ~= false)

	self:setRepairMissions(station)

	-- weapons:
	-- some weapons are enabled or disabled due to the faction description by the place utility. Most of them get randomly enabled by the difficulty setting at the beginning of the game (when the first call of pickStation occures).
	-- Let's use them as a suggestion of weapons, they still have in store, but to a limited and very scarce amount.

	assert(station.comms_data.weapon_available)
	for weapon, avail in pairs(station.comms_data.weapon_available) do
		if avail then
			station.comms_data.weapon_available[weapon] = math.ceil(hull_modifier)
		end
	end

	-- stations procude weapons, depending on the terrain. They always sell those.
	-- warning: Independent stations are not placed in mines and planets!
	assert(terrain_module)
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



	local character = table.remove(self.characters)	-- pop one into this station
	if character ~= nil then
		station.characters = {character}
	end


	

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

	-- all the specific services are available for friends only
	for _, service in ipairs(services) do
		station.comms_data.services[service] = false--"friend"
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
function avp_stations:setRepairMissions(station)
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

	station.mission_goods = {}
	for j,m_type in ipairs(self.ordnance_missions) do
		station.mission_goods[m_type] = tableSelectRandom(self.mission_goods[m_type])
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
	--[[ don't know what this is for...
    local mission_stations = self.stations
    local missions_stations_goods = {}
    for i,station in ipairs(mission_stations) do
		if station.comms_data ~= nil and station.comms_data.goods ~= nil then
			for station_good,details in pairs(station.comms_data.goods) do
				for mission,mission_goods in pairs(self.mission_goods) do
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
                    self.mission_goods[mission] = {good}
                    table.insert(already_selected_good,good)
                    selected_station.selected_mission_good = good
                end
            else
                mission_good[mission] = {good = good, station = selected_station}
                self.mission_goods[mission] = {good}
                table.insert(already_selected_good,good)
                selected_station.selected_mission_good = good
            end
        end
    end
    --    complete goods selection for missions
    for mission,goods in pairs(self.mission_goods) do
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
end
function avp_stations:update(delta)
	for _, station in ipairs(self.stations) do
		if station:isValid() then
			-- stations produce their buy value in one hour
			local gain = station:getHullMax() * 4 / 3600
			station:addReputationPoints(gain*delta)
		end
	end
end
