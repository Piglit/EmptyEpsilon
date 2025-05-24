-- Player Ship utility for Shattered Horizon
noNetwork = true	-- igonre failed httpPost requests	
player_ships_util = {
	PLAYER_SHIPS = {
	["Artful Dodger"]=		{"Y2K",			"Leichter corellianischer Y2K Peregrine Frachter von Leanti Meva."},
	["Batnar Galaar"]=		{"HWK-290",		"Modifizierter leichter Frachter HWK-290 von Mirsh Beskaryc"},
	["Black Bantha"]=		{"YV-330",		"YV-330 Frachter von Cooper"},
	["Calamity"]=			{"Gozanti",		"Gozanti Cruiser von Lt. Adrien"},
	["Cropdust Nomad"]=		{"Gozanti",		"Gozanti Cruiser von Kell Murtry"},
	["Drexl"]=				{"Lambda T-4a",	"Lambda Shuttle von Endira Vask und Treuton Otro"},
	["Greedy Wampa"]=		{"GR-75",		"Umgebauter GR-75 Frachter von Kei Prine"},
	["Harlekin"]=			{"Allanar N3",	"Leichter Allanar N3 Frachter von Viveka Torra"},
	["Kyr'yc Laar"]=		{"ARC-170",		"Aggressive-ReConnaisance Fighter von Kali Myk"},
	["Last Dawn"]=			{"Peregrine yacht",	"Peregrin-Klasse Raumjacht von Atenbi"},
	["Lightning"]=			{"Sheathipede",	"Sheathipede von Endor Sky Marshal Ran Korra"},
	["Lonestar"]=			{"Kuat D7",		"Kuat D7 Patrol von Colton Steele"},
	["Nightbrother"]=		{"Kom'rk",		"Kom'rk Klasse von Fenn Bralor"},
	["Sicaria"]=			{"A-24",		"A-24 Sleuth Scout von Viveca Torra"},
	["TIE/rp 7901"]=		{"TIE-Reaper",	"TIE Reaper von Flight Lieutenant Ron Jelran"},
	["Thunderbolt"]=		{"VCX-100",		"VCX-100 von Dash Meero"},
	["Trummermove"]=		{"CX-9",		"Eine CX-9 von Crimson Dawn"},
	["Udesla"]=				{"YT-1300",		"Corellianischer leichter Frachter YT-1300 von Mn'Taru und Tetsu-gunjin"},
	["VV-Frightning"]=		{"Lambda T-4a",	"Lambda Shuttle von Val'Kinor"},
	["Winner"]=				{"X-Wing",		"Generic X-Wing"},
	["BX-15"]=				{"X-Wing",		""},
	["XW-65"]=				{"X-Wing",		"T-65B X-Wing von Tiv Ohan"},
	["Zegema Beach"]=		{"Gozanti Mk Ic",	"Gozanti von Gabber'lok"},
	["Xylon"]=				{"G9",			"Eine G9 von Crimson Dawn"},
	["H.I.V.E."]=			{"Lambda T-4a", "Ein Lambda Shuttle des Galaktischen Imperiums"},
	["Zoomer"]=				{"UT-60D",		"Ein U-Wing der Neuen Republik"},
	},
	ground_station = nil,
	active_ships = {},
	http_post_send_queue = {},
	active_ships_by_faction = {},
	pdu_settings_by_faction = {},
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
	ship.previous_docking_state = 0
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

	if self.pdu_settings_by_faction[faction] ~= nil then
		self:set_ship_pdu(ship, self.pdu_settings_by_faction[faction])
		self.pdu_settings_by_faction[faction] = nil
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
		for i = 1, 3 do
			-- faction encodes in what simulator room the ship is
			addGMFunction(_("buttonGM", "in simulator "..i), function()
				clearGMFunctions()
				for shipname, data in pairs(player_ships_util.PLAYER_SHIPS) do
					addGMFunction(_("buttonGM", shipname), function()
						player_ships_util:spawn_player_ship(shipname, data[1], data[2], "Transport"..i)
						plot_manager.gm_main_menu()
					end)
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
	addGMFunction(_("buttonGM", "Spawn Special Player Ship"), function()
		clearGMFunctions()
		addGMFunction(_("buttonGM", "Calamity @ Rim @ Sim 2"), function()
			-- start at freighter
			local shipname = "Calamity"
			local data = player_ships_util.PLAYER_SHIPS[shipname]
			local sim = "2"
    		local px,py = map_shattered.freighter_imp:getPosition()
			local ship = player_ships_util:spawn_player_ship(shipname, data[1], data[2], "Transport"..sim)
			ship:setPosition(px+750,py-500)
			ship:commandAbortDock()
			ship:commandDock(map_shattered.freighter_imp)
			ship:setFaction("Imperial")
			plot_manager.gm_main_menu()
		end)
		addGMFunction(_("buttonGM", "XB-4 @ Hyper @ Sim 3"), function()
			-- crash land sequence
			-- in radar view of Calamity @ 1:05
			-- in radar view of FC @ 1:23
			-- leave belt @ 2:40
			-- enter atmo @ 3:35
			-- crash @ 3:46
			local shipname = "BX-15"
			local data = player_ships_util.PLAYER_SHIPS[shipname]
			local sim = "3"
    		local px,py = 75000, -140000
			local ship = player_ships_util:spawn_player_ship(shipname, data[1], data[2], "Transport"..sim)
			ship:commandAbortDock()
			ship:setPosition(px,py):setRotation(210-90):commandTargetRotation(210-90)
			ship:setWarpDrive(true):commandWarp(1)
			ship:setMaxCoolant(0)
			ship:setFaction("New Republic")
			plot_shattered_crashlander.ship = ship
			plot_shattered_crashlander.shipname = shipname
			plot_manager.gm_main_menu()
		end)

		gm_menu_back()
	end)
end

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


function player_ships_util:updatePlayerShip(delta, ship)
	local timestamp = getScenarioTime()
	player_ships_util:logFuelConsumption(ship, timestamp, false)
	if ship:getDockingState() == 2 then
		if ship.previous_docking_state == 0 then	-- catches nil for other ships
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
				perma_damage_util:sendDamageReport(ship)
				player_ships_util:logFuelConsumption(ship, timestamp, true)
				player_ships_util:sendFuelConsumptionReport(ship)
			end
		end
	else
		if ship.previous_docking_state == 2 then	-- catches nil for other ships
			ship.previous_docking_state = 0 
			local data = {
				callsign = ship:getCallSign(),
				timestamp = timestamp,
				state = "undocked",
			}
			player_ships_util:http_post("/ship_state", toJSON(data))
			player_ships_util:logFuelConsumption(ship, timestamp, true)
		end
		if ship.tuner ~= nil then
			self:tuner_update(delta, ship)
		end
	end
end

function player_ships_util:http_post(endpoint, data)
	-- send data to endpoint
	-- if request failes, store it for the next update
	if httpPost("127.0.0.1", 8002, endpoint, data) == false then
		if noNetwork == true then
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
		ship:removeCustom("pdu_caption")
		ship:removeCustom("pdu_caption_plus")
		ship:removeCustom("pdu_info")
		ship:removeCustom("pdu_info_plus")
		ship:removeCustom("pdu_note")
		ship:removeCustom("pdu_note_plus")
		ship:removeCustom("pdu_note2")
		ship:removeCustom("pdu_note2_plus")
		print("Sabotage active on "..ship:getCallSign())
		ship.tuner_state = ship.tuner_state + delta
	elseif ship.tuner_state < 10 then
		ship.tuner_state = ship.tuner_state + delta
		if ship.tuner_state > 2 then
			ship:addCustomInfo("Engineering","pdu_caption","EVE-Fehler:", 20)
			ship:addCustomInfo("Engineering+","pdu_caption_plus","EVE-Fehler:", 20)
		end
		if ship.tuner_state > 4 then
			ship:addCustomInfo("Engineering","pdu_info","Sabotage festgestellt", 21)
			ship:addCustomInfo("Engineering+","pdu_info_plus","Sabotage festgestellt", 21)
		end
		if ship.tuner_state > 6 then
			ship:addCustomInfo("Engineering","pdu_note","Energieverteilung blockiert", 22)
			ship:addCustomInfo("Engineering+","pdu_note_plus","Energieverteilung blockiert", 22)
		end
		if ship.tuner_state > 8 then
			ship:addCustomInfo("Engineering","pdu_note2","Hauptleitung überprüfen!", 23)
			ship:addCustomInfo("Engineering+","pdu_note2_plus","Hauptleitung überprüfen!", 23)
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
		ship:addCustomInfo("Engineering","pdu_caption","EVE-Fehler:", 20)
		ship:addCustomInfo("Engineering+","pdu_caption_plus","EVE-Fehler:", 20)
		ship:addCustomInfo("Engineering","pdu_info",pdu_msgs[args.error], 21)
		ship:addCustomInfo("Engineering+","pdu_info_plus",pdu_msgs[args.error], 21)
		ship:commandSetAlertLevel("yellow")
	elseif args.warning ~= "" then
		assert(pdu_msgs[args.warning] ~= nil)
		ship:addCustomInfo("Engineering","pdu_caption","EVE-Warnung:", 20)
		ship:addCustomInfo("Engineering+","pdu_caption_plus","EVE-Warnung:", 20)
		ship:addCustomInfo("Engineering","pdu_info",pdu_msgs[args.warning], 21)
		ship:addCustomInfo("Engineering+","pdu_info_plus",pdu_msgs[args.warning], 21)
		ship:commandSetAlertLevel("normal")
	else
		ship:removeCustom("pdu_caption")
		ship:removeCustom("pdu_caption_plus")
		ship:removeCustom("pdu_info")
		ship:removeCustom("pdu_info_plus")
		ship:commandSetAlertLevel("normal")
	end
	if args.note ~= "" then
		assert(pdu_msgs[args.note] ~= nil)
		ship:addCustomInfo("Engineering","pdu_note",pdu_msgs[args.note], 22)
		ship:addCustomInfo("Engineering+","pdu_note_plus",pdu_msgs[args.note], 22)
	else
		ship:removeCustom("pdu_note")
		ship:removeCustom("pdu_note_plus")
	end
	if args.note2 ~= "" then
		assert(pdu_msgs[args.note2] ~= nil)
		ship:addCustomInfo("Engineering","pdu_note2",pdu_msgs[args.note2], 23)
		ship:addCustomInfo("Engineering+","pdu_note2_plus",pdu_msgs[args.note2], 23)
	else
		ship:removeCustom("pdu_note2")
		ship:removeCustom("pdu_note2_plus")
	end

end
