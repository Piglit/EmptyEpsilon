-- Player Ship utility for Shattered Horizon
local NO_NETWORK = true 	-- igonre failed httpPost requests	
local ENABLE_PDU = false	-- feature flag for sabotage and tuning unit (hardware)
local ENABLE_LOG = false	-- feature flag for ship damage and consumption log
local ENABLE_UPGRADES = true	-- feature flag for ship upgrades
local ENABLE_HELP = true	-- feature flag for interactive help (engineering)

require("utils_customElements.lua")	-- customElements (unified custom info)

player_ships_util = {
	PLAYER_SHIPS = {
	{"Artful Dodger",		"Y2K",			"Leichter corellianischer Y2K Peregrine Frachter von Leanti Meva"},
	{"Batnor Senaar",		"C70",			"Umgebauter Consular Charger C70 Retrifit von Mirsh Beskaryc"},
--	{"Batnar Galaar",		"HWK-290  ",	"Modifizierter leichter Frachter HWK-290 von Mirsh Beskaryc"},
	{"Beacon of Civility",	"CSS-1",		"Corellian Star Shuttle von Xiphias Talexecum"},
	{"Beacon Runner",		"EML-850",		"Ziviles Rettungsschiff EML-850 von Dalen Voss"},
	{"Black Bantha",		"YV-330",		"YV-330 Frachter von Sorc"},
--	{"Calamity",			"Gozanti",		"Gozanti Cruiser von Lt. Adrien"},
	{"Cribana",				"Gozanti C-ROC","C-ROC Gozanti Cruiser von Valen Andrian Serris"},
	{"Cropdust Nomad",		"Gozanti ",		"Gozanti Cruiser von Kell Murtry"},
	{"Drexl",				"Lambda T-4a ",	"Lambda Shuttle von Endira Vask und Treuton Otro"},
	{"Elza",				"DX-9",			"Umgebauter DX-9 Stormtrooper Transport von Andan Hearch"},
	{"Greedy Wampa",		"GR-75",		"Umgebauter GR-75 Frachter von Kei Prine"},
--	{"Harlekin",			"Allanar N3",	"Leichter Allanar N3 Frachter von Viveka Torra"},
	{"Hinterhand",			"UT-60D",		"UT-60D U-Wing von Tiv Ohan"},
	{"Kyr'yc Laar",			"ARC-170",		"Aggressive-ReConnaisance Fighter von Kali Myk"},
	{"Last Dawn",			"Peregrine yacht",	"Peregrin-Klasse Raumjacht von Atenbi"},
	{"Crimson Thunder",		"Peregrine yacht",	"Peregrin-Klasse Raumjacht von Atenbi"},
--	{"Lightning",			"Sheathipede",	"Sheathipede von Endor Sky Marshal Ran Korra"},
--	{"Lonestar",			"Kuat D7",		"Kuat D7 Patrol von Colton Steele"},
	{"Miss Understanding",	"HWK-1000",		"Leichter Frachter HWK-1000 von Varik Jeroos"},
--	{"Nightbrother",		"Kom'rk",		"Kom'rk Klasse von Fenn Bralor"},
	{"Rho-1",				"TIE-Interceptor",	"TIE-Interceptor der Rho-Staffel"},
	{"Rho-2",				"TIE-Interceptor",	"TIE-Interceptor der Rho-Staffel"},
	{"Rho-3",				"TIE-Interceptor",	"TIE-Interceptor der Rho-Staffel"},
	{"Rho-4",				"TIE-Interceptor",	"TIE-Interceptor der Rho-Staffel"},
	{"Ronin",				"Action IV",	"Modifizierter Action IV Frachter von Draic FeenX Professional Services"},
	{"Sapphire",			"GX1  ",		"GX1 Short Hauler von Aurora Var'Rel"},
	{"Sicaria",				"A-24",			"A-24 Sleuth Scout von Viveka Torra"},
--	{"Spite",				"HWK-290 ",		"Sehr alter leichter Frachter HWK-290 von Seris Veynar"},
	{"Still Moving",		"GX1 ",			"GX1 Short Hauler von Korrun Khell und Rovan Tesk"},
	{"TIE/rp 7901",			"TIE-Reaper",	"TIE Reaper Attack Lander von Ron Jelran"},
	{"Thunderbolt",			"VCX-100",		"VCX-100 von Dash Meero"},
--	{"Trummermove",			"CX-9",			"Eine CX-9 von Crimson Dawn"},
	{"Udesla",				"YT-1300",		"Corellianischer leichter Frachter YT-1300-B von Mn'Taru und Jin-Tetsu"},
	{"Vengence",			"StarViper",	"Star Viper Angriffsjäger von Fenn Bralor"},
	{"Vigilant",			"UT-60D",		"UT-60D U-Wing von Kalen Dorn"},
	{"VV-Frightning",		"Lambda T-4a",	"Lambda Shuttle von Val'Kinor"},
--	{"Winner",				"X-Wing",		"Generic X-Wing"},
--	{"BX-15",				"X-Wing",		""},
	{"XW-65",				"X-Wing",		"T-65B X-Wing von Tiv Ohan"},
--	{"Zegema Beach",		"Gozanti Mk Ic",	"Gozanti von Gabber'lok"},
	{"Xylon",				"G9",			"Eine G9 von Crimson Dawn"},
	{"H.I.V.E.",			"Lambda T-4a",	"Lambda Shuttle des Galaktischen Imperiums"},
	{"Zoomer",				"UT-60D",		"Ein U-Wing der Neuen Republik"},
	},
	ground_station = nil,
	active_ships = {},
	http_post_send_queue = {},
	active_ships_by_faction = {},
	pdu_settings_by_faction = {},
	upgrades_by_ship = {
		["Cropdust Nomad"] = {["Laser"]=1, ["Antrieb"]=1, ["Kühlung"]=1},
	},
	possible_upgrades = {
		"Laser",
		"Schild",
		"Antrieb",
		"Manöver",
		"Kühlung",
	},
	custom_elements_index_base = {
		pdu = 10,		-- +3
		help = 80,		-- +4
		upgrade = 20,	-- +70
	},
}

function player_ships_util:init()
	local storage = getScriptStorage()
	storage["player_ships_util"] = self
end

function player_ships_util:spawn_player_ship(shipname, template, description, faction)
	print("Create " .. template .. " " .. shipname)
    local cs = string.sub(template, 1, 1) .. string.sub(shipname, 1, 1) .. "-" .. tostring(10+string.len(shipname))
	local ship = PlayerSpaceship()
	local rotation = -90
	ship:setTemplate(template)
	ship:setCallSign(cs)
	ship:setDescription(shipname .. " - " .. description)
	ship:setFaction(faction)
	ship:setRotation(rotation)
	ship:commandTargetRotation(rotation)
	ship:setCanBeDestroyed(false)
	ship:setCanSelfDestruct(false)
	ship:addReputationPoints(50)
	ship:setSystemPowerFactor("reactor", -20)
	if self.ground_station ~= nil and self.ground_station:isValid() then
		local px,py = self.ground_station:getPosition()
		local offset = #getActivePlayerShips() -1
		if offset % 2 == 1 then
			offset = -offset
		end
		ship:setPosition(px+(100*offset),py-600)
		ship:commandDock(self.ground_station)
	end
	self.active_ships[shipname] = ship
	self.active_ships_by_faction[faction] = ship
	ship.shipname = shipname
	ship.previous_docking_state = 0

	if ENABLE_LOG then
		local data = {
			callsign = ship:getCallSign(),
			shipname = shipname,
			template = template,
			description = description,
		}
		player_ships_util:http_post("/register_ship", toJSON(data))
		data = {
			callsign = ship:getCallSign(),
			timestamp = getScenarioTime(),
			state = "created",
		}
		player_ships_util:http_post("/ship_state", toJSON(data))

		ship.fuel_consumption_log = {}
		ship.last_fuel_consumption_timestamp = 0
		ship.activate_fuel_consumption_log = false
	end

	if ENABLE_PDU and self.pdu_settings_by_faction[faction] ~= nil then
		self:set_ship_pdu(ship, self.pdu_settings_by_faction[faction])
		self.pdu_settings_by_faction[faction] = nil
	end

	if ENABLE_UPGRADES then
		ship.upgrade_changed = true
		ship.beam_weapon_data = {}
		ship.shield_data = {}
		ship.impulse_data = {}
		ship.maneuver_data = nil
		ship.coolant_data = nil
		ship.system_power_factor = {}
		ship.system_coolant_rates = {}
	end
	return ship
end

function player_ships_util:despawn_player_ship(shipname)
	local ship = self.active_ships[shipname]
	local data = {
		callsign = ship:getCallSign(),
		timestamp = getScenarioTime(),
		state = "deleted",
	}
	player_ships_util:http_post("/ship_state", toJSON(data))
	self.active_ships_by_faction[ship:getFaction()] = nil
	ship:destroy()
	self.active_ships[shipname] = nil
end

function player_ships_util:gm_menu()
	addGMFunction(_("buttonGM", "Spawn Player Ship"), function()
		clearGMFunctions()
		for i = 1, 4 do
			-- faction encodes in what simulator room the ship is
			addGMFunction(_("buttonGM", "in simulator "..i), function()
				clearGMFunctions()
				for idx, data in pairs(player_ships_util.PLAYER_SHIPS) do
					if self.active_ships[data[1]] == nil then
						addGMFunction(_("buttonGM", data[1]), function()
							player_ships_util:spawn_player_ship(data[1], data[2], data[3],"Transport"..i)
							plot_manager.gm_main_menu()
						end, idx)
					end
				end
				gm_menu_back()
			end)
		end
		gm_menu_back()
	end)
	addGMFunction(_("buttonGM", "Despawn Player Ship"), function()
		clearGMFunctions()
		for shipname, ship in pairs(player_ships_util.active_ships) do
			addGMFunction(_("buttonGM", shipname), function()
				player_ships_util:despawn_player_ship(shipname)
				plot_manager.gm_main_menu()
			end)
		end
		gm_menu_back()
	end)
	if ENABLE_UPGRADES then
		addGMFunction(_("buttonGM", "Upgrade Player Ship"), function()
			clearGMFunctions()
			for idx, data in pairs(player_ships_util.PLAYER_SHIPS) do
				local shipname = data[1]
				addGMFunction(_("buttonGM", shipname), function()
					player_ships_util:upgrades_gm_menu(shipname)
				end, idx)
			end
			gm_menu_back()
		end)
	end
	--addGMFunction(_("buttonGM", "Spawn Special Player Ship"), function()
	--	clearGMFunctions()
		--addGMFunction(_("buttonGM", "Calamity @ Rim @ Sim 2"), function()
		--	-- start at freighter
		--	local shipname = "Calamity"
		--	local data = player_ships_util.PLAYER_SHIPS[shipname]	-- FIXME is now index based
		--	local sim = "2"
    	--	local px,py = map_shattered.freighter_imp:getPosition()
		--	local ship = player_ships_util:spawn_player_ship(shipname, data[1], data[2], "Transport"..sim)
		--	ship:setPosition(px+750,py-500)
		--	ship:commandAbortDock()
		--	ship:commandDock(map_shattered.freighter_imp)
		--	ship:setFaction("Imperial")
		--	plot_manager.gm_main_menu()
		--end)
		--addGMFunction(_("buttonGM", "XB-4 @ Hyper @ Sim 3"), function()
		--	-- crash land sequence
		--	-- in radar view of Calamity @ 1:05
		--	-- in radar view of FC @ 1:23
		--	-- leave belt @ 2:40
		--	-- enter atmo @ 3:35
		--	-- crash @ 3:46
		--	local shipname = "BX-15"
		--	local data = player_ships_util.PLAYER_SHIPS[shipname]-- FIXME is now index based
		--	local sim = "3"
    	--	local px,py = 75000, -140000
		--	local ship = player_ships_util:spawn_player_ship(shipname, data[1], data[2], "Transport"..sim)
		--	ship:commandAbortDock()
		--	ship:setPosition(px,py):setRotation(210-90):commandTargetRotation(210-90)
		--	ship:setWarpDrive(true):commandWarp(1)
		--	ship:setMaxCoolant(0)
		--	ship:setFaction("New Republic")
		--	plot_shattered_crashlander.ship = ship
		--	plot_shattered_crashlander.shipname = shipname
		--	plot_manager.gm_main_menu()
		--end)

	--	gm_menu_back()
	--end)
end

if ENABLE_LOG then
	function player_ships_util:logFuelConsumption(ship, timestamp, forced_by_dock)
		if ship.activate_fuel_consumption_log ~= true then	-- catches nil for other ships
			return
		end

		if forced_by_dock then
			-- force insertion of zero velocity when docking or undocking
			table.insert(ship.fuel_consumption_log, {timestamp, 0})
			ship.last_fuel_consumption_timestamp = timestamp
			return
		end
		if timestamp < (ship.last_fuel_consumption_timestamp + 1.0) then
			return
		end

		local timestamp_log = math.floor(timestamp)
		local velx,vely = ship:getVelocity()
		local avel = ship:getAngularVelocity()
		local total = math.floor(velx*velx + vely*vely + avel*avel)

		if #ship.fuel_consumption_log > 0 then
			local last_entry = ship.fuel_consumption_log[#ship.fuel_consumption_log]
			if last_entry[2] ~= total then
				table.insert(ship.fuel_consumption_log, {timestamp_log, total})
			end
		else
			table.insert(ship.fuel_consumption_log, {timestamp_log, total})
		end
		ship.last_fuel_consumption_timestamp = timestamp
	end

	function player_ships_util:sendFuelConsumptionReport(ship, timestamp)
		if #ship.fuel_consumption_log > 0 then
			local data = {
				callsign = ship:getCallSign(),
				data = ship.fuel_consumption_log,
			}
			print(toJSON(data))
			player_ships_util:http_post("/fuelconsumption", toJSON(data))
			ship.fuel_consumption_log = {}	-- clear after send
		end
	end
end

function player_ships_util:updatePlayerShip(delta, ship)
	local timestamp = getScenarioTime()
	if ENABLE_LOG then
		player_ships_util:logFuelConsumption(ship, timestamp, false)
	end
	if ship:getDockingState() == 2 then	-- docked
		if ENABLE_LOG and ship.previous_docking_state == 0 then	-- catches nil for other ships
			local vx, vy = ship:getVelocity()
			if vx*vx + vy*vy <= 1.0 then
				ship.activate_fuel_consumption_log = true
				ship.previous_docking_state = 2
				local data = {
					callsign = ship:getCallSign(),
					timestamp = timestamp,
					state = "docked",
				}
				player_ships_util:http_post("/ship_state", toJSON(data))
				player_ships_util:logFuelConsumption(ship, timestamp, true)
				player_ships_util:sendFuelConsumptionReport(ship)
				perma_damage_util:sendDamageReport(ship)
			end
		end
	else
		if ENABLE_LOG and ship.previous_docking_state == 2 then	-- catches nil for other ships
			ship.previous_docking_state = 0
			local data = {
				callsign = ship:getCallSign(),
				timestamp = timestamp,
				state = "undocked",
			}
			player_ships_util:http_post("/ship_state", toJSON(data))
			player_ships_util:logFuelConsumption(ship, timestamp, true)
		end
		if ENABLE_PDU and ship.tuner ~= nil then
			self:tuner_update(delta, ship)
		end
	end
	if ENABLE_UPGRADES and ship.upgrade_changed then
		local upgrade_levels = self.upgrades_by_ship[ship.shipname]
		if upgrade_levels ~= nil then
			self:upgrades_engineering_menu(ship, upgrade_levels)
		end
	end
	if ENABLE_HELP then
		if map_shattered.atmo:isInside(ship) then
			local density = (20000 - distance(ship, map_shattered.planet)) / 5800
			customElements:addCustomInfo(ship, "Helms","help_helm_atmo_1", string.format("Atmosphärendichte: %.0f%%", 100*math.min(1.0,density)), self.custom_elements_index_base.help)
			if ship:getSystemPower("impulse") < 1+density then
				customElements:addCustomInfo(ship, "Helms","help_helm_atmo_2","Antriebsleistung unzureichend", self.custom_elements_index_base.help + 1)
			else
				customElements:removeCustom(ship, "help_helm_atmo_2")
			end
		else
			customElements:removeCustom(ship, "help_helm_atmo_1")
			customElements:removeCustom(ship, "help_helm_atmo_2")
		end
		local energy = ship:getEnergyLevel() / ship:getEnergyLevelMax()
		if energy < 0.3 then
			customElements:addCustomInfo(ship, "Engineering","help_engi_energy_0","Warnung: Energie niedrig", self.custom_elements_index_base.help)
			customElements:addCustomInfo(ship, "Engineering","help_engi_energy_1","Mögliche Maßnahmen:", self.custom_elements_index_base.help + 1)
			customElements:addCustomInfo(ship, "Engineering","help_engi_energy_2","Reaktorleistung erhöhen", self.custom_elements_index_base.help + 2)
			if energy < 0.1 then
				customElements:addCustomInfo(ship, "Engineering","help_engi_energy_0","Energielevel kritisch", self.custom_elements_index_base.help)
				customElements:addCustomInfo(ship, "Engineering","help_engi_energy_3","Systeme herunterfahren", self.custom_elements_index_base.help + 3)
			else
				customElements:removeCustom(ship, "help_engi_energy_3")
			end
			if ship:getShieldsActive() then
				customElements:addCustomInfo(ship, "Engineering","help_engi_energy_4","Schilde deaktivieren", self.custom_elements_index_base.help + 4)
			else
				customElements:removeCustom(ship, "help_engi_energy_4")
			end
		else
			customElements:removeCustom(ship, "help_engi_energy_0")
			customElements:removeCustom(ship, "help_engi_energy_1")
			customElements:removeCustom(ship, "help_engi_energy_2")
			customElements:removeCustom(ship, "help_engi_energy_3")
			customElements:removeCustom(ship, "help_engi_energy_4")
		end
	end	
end

function player_ships_util:http_post(endpoint, data)
	-- send data to endpoint
	-- if request failes, store it for the next update
	if httpPost("127.0.0.1", 8002, endpoint, data) == false then
		if NO_NETWORK == true then
			return false
		end
		table.insert(self.http_post_send_queue, {
			endpoint = endpoint,
			data = data,
		})
		return false
	end
	return true
end

function player_ships_util:update(delta)
	if #self.http_post_send_queue > 0 then
		if httpPost("127.0.0.1", 8002, "/pingpost", "") == true then
			local failed = {}
			for id=1, #self.http_post_send_queue do
				local entry = self.http_post_send_queue[id]
				if self:http_post(entry.endpoint, entry.data) == false then
					table.insert(failed, entry)
				end
			end
			self.http_post_send_queue = failed
		end
	end
end

if ENABLE_PDU then
	function player_ships_util.set_pdu(args)
		local faction = args.faction
		local ship = player_ships_util.active_ships_by_faction[faction]
		if ship ~= nil and ship:isValid() then
			player_ships_util:set_ship_pdu(ship, args)
			player_ships_util.pdu_settings_by_faction[faction] = nil
		else
			player_ships_util.pdu_settings_by_faction[faction] = args
		end
	end

	function player_ships_util:tuner_update(delta, ship)
		if ship.tuner_state == 0 then
			if ship.tuner == 2 then
				-- tuner 2 activates on 200% power and locks it
				-- will probably happen during launch
				for _,system in ipairs(SYSTEMS) do
					if ship:getSystemPower(system) >= 2 then
						ship:setSystemPowerRate(system, 0)
						ship.tuner_state = 1
					end
				end
			elseif ship.tuner == 3 then
				-- tuner 3 activates on system damage
				-- will happen during combat on when fighters overheat their drives
				-- locks all power settings!
				for _,system in ipairs(SYSTEMS) do
					if ship:getSystemHealth(system) < 1 then
						ship.tuner_state = 1
					end
				end
				if ship.tuner_state == 1 then
					for _,system in ipairs(SYSTEMS) do
						ship:setSystemPowerRate(system, 0)
					end
				end
			end
		elseif ship.tuner_state == 1 then
			-- happened last update
			customElements:removeCustom(ship, "pdu_caption")
			customElements:removeCustom(ship, "pdu_info")
			customElements:removeCustom(ship, "pdu_note")
			customElements:removeCustom(ship, "pdu_note2")
			print("Sabotage active on "..ship:getCallSign())
			ship.tuner_state = ship.tuner_state + delta
		elseif ship.tuner_state < 10 then
			ship.tuner_state = ship.tuner_state + delta
			if ship.tuner_state > 2 then
				customElements:addCustomInfo(ship, "Engineering","pdu_caption","EVE-Fehler:", self.custom_elements_index_base.pdu)
			end
			if ship.tuner_state > 4 then
				customElements:addCustomInfo(ship, "Engineering","pdu_info","Sabotage festgestellt", self.custom_elements_index_base.pdu + 1)
			end
			if ship.tuner_state > 6 then
				customElements:addCustomInfo(ship, "Engineering","pdu_note","Energieverteilung blockiert", self.custom_elements_index_base.pdu + 2)
			end
			if ship.tuner_state > 8 then
				customElements:addCustomInfo(ship, "Engineering","pdu_note2","Hauptleitung überprüfen!", self.custom_elements_index_base.pdu + 3)
				ship.tuner_state = 10
			end
		end			
	end

	function player_ships_util:set_ship_pdu(ship, args)
		print("Received PDU settings of "..ship:getCallSign() .. ": " .. args.error .. args.warning)
		if ship.tuner_state ~= nil and ship.tuner_state ~= 0 and ship.tuner_state ~= 99 then
			if args.active then
				-- must plug it out an in again to reset sabotage
				return
			end
			ship.tuner_state = 99
			print("Sabotage inactive on "..ship:getCallSign())
		end

		ship:setSystemPowerRate(  "beamweapons",	args.weapons_rate)
		ship:setSystemCoolantRate("beamweapons",	args.weapons_cool)
		ship:setSystemPowerFactor("beamweapons",	args.weapons_consume)
		ship:setSystemPowerRate(  "missilesystem",	args.weapons_rate)
		ship:setSystemCoolantRate("missilesystem",	args.weapons_cool)
		ship:setSystemPowerFactor("missilesystem",	args.weapons_consume/3)
		ship:setSystemPowerRate(  "impulse",		args.drive_rate)
		ship:setSystemCoolantRate("impulse",		args.drive_cool)
		ship:setSystemPowerFactor("impulse",		args.drive_consume)
		ship:setSystemPowerRate(  "maneuver",		args.drive_rate)
		ship:setSystemCoolantRate("maneuver",		args.drive_cool)
		ship:setSystemPowerFactor("maneuver",		args.drive_consume/2)
		ship:setSystemPowerRate(  "frontshield",	args.shields_rate)
		ship:setSystemCoolantRate("frontshield",	args.shields_cool)
		ship:setSystemPowerFactor("frontshield",	args.shields_consume)
		ship:setSystemPowerRate(  "rearshield",		args.shields_rate)
		ship:setSystemCoolantRate("rearshield",		args.shields_cool)
		ship:setSystemPowerFactor("rearshield",		args.shields_consume)

		if args.tuner >= 2 then
			if ship.tuner_state == nil then
				print("Tuner "..tostring(args.tuner).." detected on "..ship:getCallSign())
				ship.tuner = args.tuner
				ship.tuner_state = 0
			end
		end
		local pdu_msgs= {
			["Main line not connected"] =	"Hauptleitung unterbrochen",
			["Energy distribution not possible"] =	"Energieverteilung unmöglich",
			["System overclocked"] = 		"Systeme übertaktet:",
			["weapons rate"] = 				"Energieverteilung - Waffen",
			["weapons coolant"] = 			"Kühlmittelpumpe - Waffen",
			["drives rate"] = 				"Energieverteilung - Antriebe",
			["drives coolant"] = 			"Kühlmittelpumpe - Antriebe",
			["shields rate"] = 				"Energieverteilung - Schilde",
			["shields coolant"] = 			"Kühlmittelpumpe - Schilde",
			["Drive line not connected"] =	"Antriebsenergie unterbrochen",
			["Shield line not connected"] =	"Schildenergie unterbrochen",
			["Weapon line not connected"] =	"Waffenenergie unterbrochen",
			["No power distribution"] = 	"Energieverteilung unmöglich",
			["Non-standard energy consumption"] = "Energieverteilung umgesteckt",
			[""] = "",
		}
		if args.error ~= "" then
			assert(pdu_msgs[args.error] ~= nil)
			customElements:addCustomInfo(ship, "Engineering","pdu_caption","EVE-Fehler:", self.custom_elements_index_base.pdu)
			customElements:addCustomInfo(ship, "Engineering","pdu_info",pdu_msgs[args.error], self.custom_elements_index_base.pdu + 1)
			ship:commandSetAlertLevel("yellow")
		elseif args.warning ~= "" then
			assert(pdu_msgs[args.warning] ~= nil)
			customElements:addCustomInfo(ship, "Engineering","pdu_caption","EVE-Warnung:", self.custom_elements_index_base.pdu)
			customElements:addCustomInfo(ship, "Engineering","pdu_info",pdu_msgs[args.warning], self.custom_elements_index_base.pdu + 1)
			ship:commandSetAlertLevel("normal")
		else
			customElements:removeCustom(ship, "pdu_caption")
			customElements:removeCustom(ship, "pdu_info")
			ship:commandSetAlertLevel("normal")
		end
		if args.note ~= "" then
			assert(pdu_msgs[args.note] ~= nil)
			customElements:addCustomInfo(ship, "Engineering","pdu_note",pdu_msgs[args.note], self.custom_elements_index_base.pdu + 2)
		else
			customElements:removeCustom(ship, "pdu_note")
		end
		if args.note2 ~= "" then
			assert(pdu_msgs[args.note2] ~= nil)
			customElements:addCustomInfo(ship, "Engineering","pdu_note2",pdu_msgs[args.note2], self.custom_elements_index_base.pdu + 3)
		else
			customElements:removeCustom(ship, "pdu_note2")
		end
	end
end

if ENABLE_UPGRADES then
	function player_ships_util:upgrades_gm_menu(shipname)
		clearGMFunctions()
		addGMFunction(_("buttonGM", "Upgrades for ") .. shipname, function()
			player_ships_util:upgrades_gm_menu(shipname)
		end, 0)		--just an info
		local current_upgrades = player_ships_util.upgrades_by_ship[shipname]
		if current_upgrades == nil then
			current_upgrades = {}
		end
		for up_idx, up_name in ipairs(player_ships_util.possible_upgrades) do
			local level = current_upgrades[up_name] or 0
			addGMFunction(_("buttonGM", up_name) .. " " .. level, function()
				clearGMFunctions()
				addGMFunction(_("buttonGM", "Set ") .. up_name .. _(" for ") .. shipname, function()
					player_ships_util:upgrades_gm_menu(shipname)
				end, 0)	--just an info
				for i=0,2 do	
					addGMFunction(tostring(i), function() 
						player_ships_util:set_player_ship_upgrade_level(shipname, up_name, i)
						player_ships_util:upgrades_gm_menu(shipname)
					end, i+1)
				end
				gm_menu_back()
			end, up_idx)
		end
		gm_menu_back()
	end

	function player_ships_util:set_player_ship_upgrade_level(shipname, up_name, level)
		if self.upgrades_by_ship[shipname] == nil then
			self.upgrades_by_ship[shipname] = {}
		end
		self.upgrades_by_ship[shipname][up_name] = level
		if self.active_ships[shipname] ~= nil then
			self.active_ships[shipname].upgrade_changed = true	-- also set when ship spawns
		end
	end

	function player_ships_util:upgrades_engineering_menu(ship, upgrade_levels)
		-- update the menu for engineering
		if ship.upgrades_active == nil then
			ship.upgrades_active = {}
		end
		for idx, up_name in ipairs(self.possible_upgrades) do
			local level = upgrade_levels[up_name]
		   	if level == nil or level == 0 then
				customElements:removeCustom(ship, "activate_"..up_name)
			else
				if ship.upgrades_active[up_name] ~= nil then
					local effects = ship.upgrades_active[up_name][2]
					-- show effects and deactivation button
					customElements:addCustomInfo(ship, "Engineering", "status_"..up_name, up_name .. _("-Boost ist aktiv"), self.custom_elements_index_base.upgrade + idx*10)
					for e_idx,effect in ipairs(effects) do
						customElements:addCustomInfo(ship, "Engineering", "effect_"..up_name..tostring(e_idx), effect, self.custom_elements_index_base.upgrade + idx*10+e_idx)
					end
					customElements:addCustomButton(ship, "Engineering", "deactivate_"..up_name, up_name .. _("-Boost stoppen"), function()
						player_ships_util:deactivate_upgrade(ship, up_name)
					end, self.custom_elements_index_base.upgrade + idx*10+3)
					customElements:removeCustom(ship, "activate_"..up_name)
				else
					if level > 0 then
						-- show activation button
						customElements:addCustomButton(ship, "Engineering", "activate_"..up_name, up_name .. _("-Boost starten"), function()
							player_ships_util:activate_upgrade(ship, up_name, level)
						end, self.custom_elements_index_base.upgrade + 60+idx)
					end
					customElements:removeCustom(ship, "status_"..up_name)
					for i=1,5 do
						customElements:removeCustom(ship, "effect_"..up_name..tostring(i))
					end
					customElements:removeCustom(ship, "deactivate_"..up_name)
				end
			end
		end
		ship.upgrade_changed = false
	end

	function player_ships_util:activate_upgrade(ship, up_name, level)
		print("activate_upgrade", ship.shipname, up_name, level)
		if level < 1 then
			player_ships_util:deactivate_upgrade(ship, up_name)
		end
		if level > 2 then
			ship.upgrade_changed = true
			ship.upgrades_active[up_name] = nil
			error("upgrade level too high!")
			return
		end
		local effects = {}
		if up_name == "Laser" then
			for idx=0,7 do
				ship.beam_weapon_data[idx] = {
					arc = ship:getBeamWeaponArc(idx),
					dir = ship:getBeamWeaponDirection(idx),
					rng = ship:getBeamWeaponRange(idx),
					cyc = ship:getBeamWeaponCycleTime(idx),
					dmg = ship:getBeamWeaponDamage(idx),
				}
				ship:setBeamWeapon(idx,
							 ship.beam_weapon_data[idx].arc,
							 ship.beam_weapon_data[idx].dir,
							 ship.beam_weapon_data[idx].rng*(1 + level*0.2),
							 ship.beam_weapon_data[idx].cyc*(1 + level*0.5),
							 ship.beam_weapon_data[idx].dmg)
			end
			ship.system_power_factor.beamweapons = ship:getSystemPowerFactor("beamweapons")
			ship:setSystemPowerFactor("beamweapons", ship.system_power_factor.beamweapons*(1 + level*0.5))
			if level == 1 then
				effects = {"+50% Feuerrate", "+20% Reichweite", "+50% Energieverbrauch"}
			elseif level == 2 then
				effects = {"+100% Feuerrate", "+40% Reichweite", "+100% Energieverbrauch"}
			end
		elseif up_name == "Schild" then
			for idx=0,ship:getShieldCount() -1 do
				ship.shield_data[idx] = ship:getShieldMax(idx)
			end
			local shields = {}
			for idx, shield in pairs(ship.shield_data) do
				table.insert(shields, shield * (1+level))
			end
			ship:setShieldsMax(table.unpack(shields))
			ship.system_power_factor.frontshield = ship:getSystemPowerFactor("frontshield")
			ship.system_power_factor.rearshield = ship:getSystemPowerFactor("rearshield")
			ship:setSystemPowerFactor("frontshield", ship.system_power_factor.frontshield*(1 + level*0.2))
			ship:setSystemPowerFactor("rearshield", ship.system_power_factor.rearshield*(1 + level*0.2))
			if level == 1 then
				effects = {"+100% Schildkapazität", "+20% Energieverbrauch"}
			elseif level == 2 then
				effects = {"+200% Schildkapazität", "+40% Energieverbrauch"}
			end
		elseif up_name == "Antrieb" then
			ship.impulse_data.fwd, ship.impulse_data.rev = ship:getImpulseMaxSpeed()
			ship.impulse_data.acc_fwd, ship.impulse_data.acc_rev = ship:getAcceleration()
			ship:setImpulseMaxSpeed(
					ship.impulse_data.fwd * (1+level*0.25),
				   	ship.impulse_data.rev * (1+level*0.25))
			ship:setAcceleration(
					ship.impulse_data.acc_fwd * (1+level*0.4),
				   	ship.impulse_data.acc_rev * (1+level*0.4))
			ship.system_power_factor.impulse = ship:getSystemPowerFactor("impulse")
			ship:setSystemPowerFactor("impulse", ship.system_power_factor.impulse*(1 + level*0.5))
			if level == 1 then
				effects = {"+40% Höchstgeschwindigkeit", "+25% Beschleunigung", "+50% Energieverbrauch"}
			elseif level == 2 then
				effects = {"+80% Höchstgeschwindigkeit", "+50% Beschleunigung", "+100% Energieverbrauch"}
			end
		elseif up_name == "Manöver" then
			ship.maneuver_data = ship:getRotationMaxSpeed()
			ship:setRotationMaxSpeed(ship.maneuver_data * (1+level*0.2))
			ship.system_power_factor.maneuver = ship:getSystemPowerFactor("maneuver")
			ship:setSystemPowerFactor("maneuver", ship.system_power_factor.maneuver*(1 + level*0.5))
			if level == 1 then
				effects = {"+20% Manövrierbarkeit", "+50% Energieverbrauch"}
			elseif level == 2 then
				effects = {"+40% Manövrierbarkeit", "+100% Energieverbrauch"}
			end
		elseif up_name == "Kühlung" then
			ship.coolant_data = ship:getMaxCoolant()
			ship:setMaxCoolant(ship.coolant_data * (1+level*0.3))
			for _,sys in ipairs({"reactor", "beamweapons", "missilesystem", "frontshield", "rearshield", "impulse", "maneuver", "warp", "jumpdrive"}) do
				ship.system_coolant_rates[sys] = ship:getSystemCoolantRate(sys)
				ship:setSystemCoolantRate(sys, ship.system_coolant_rates[sys] * (1-level*0.2) )
			end
			if level == 1 then
				effects = {"+30% Kühlmittel", "-20% Pumpgeschwindigkeit"}
			elseif level == 2 then
				effects = {"+60% Kühlmittel", "-40% Pumpgeschwindigkeit"}
			end
		end
		ship.upgrades_active[up_name] = {level, effects}
		ship.upgrade_changed = true
	end

	function player_ships_util:deactivate_upgrade(ship, up_name)
		print("deactivate_upgrade", ship.shipname, up_name)
		if up_name == "Laser" then
			for idx=0,7 do
				ship:setBeamWeapon(idx,
							 ship.beam_weapon_data[idx].arc,
							 ship.beam_weapon_data[idx].dir,
							 ship.beam_weapon_data[idx].rng,
							 ship.beam_weapon_data[idx].cyc,
							 ship.beam_weapon_data[idx].dmg)
			end
			ship:setSystemPowerFactor("beamweapons", ship.system_power_factor.beamweapons)
		elseif up_name == "Schild" then
			local shields = {}
			for idx, shield in pairs(ship.shield_data) do
				table.insert(shields, shield)
			end
			ship:setShieldsMax(table.unpack(shields))
			ship:setSystemPowerFactor("frontshield", ship.system_power_factor.frontshield)
			ship:setSystemPowerFactor("rearshield", ship.system_power_factor.rearshield)
		elseif up_name == "Antrieb" then
			ship:setImpulseMaxSpeed(
					ship.impulse_data.fwd,
				   	ship.impulse_data.rev)
			ship:setAcceleration(
					ship.impulse_data.acc_fwd,
				   	ship.impulse_data.acc_rev)
			ship:setSystemPowerFactor("impulse", ship.system_power_factor.impulse)
		elseif up_name == "Manöver" then
			ship:setRotationMaxSpeed(ship.maneuver_data)
			ship:setSystemPowerFactor("maneuver", ship.system_power_factor.maneuver)
		elseif up_name == "Kühlung" then
			ship:setMaxCoolant(ship.coolant_data)
			for _,sys in ipairs({"reactor", "beamweapons", "missilesystem", "frontshield", "rearshield", "impulse", "maneuver", "warp", "jumpdrive"}) do
				ship:setSystemCoolantRate(sys, ship.system_coolant_rates[sys])
			end
		end
		ship.upgrades_active[up_name] = nil
		ship.upgrade_changed = true
	end
end
