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
	["XW-65"]=				{"X-Wing",		"T-65B X-Wing von Tiv Ohan"},
	["Zegema Beach"]=		{"Gozanti Mk Ic",	"Gozanti von Gabber'lok"},
	["Xylon"]=				{"G9",			"Eine G9 von Crimson Dawn"},
	["Yaq"]=				{"Lambda T-4a", "Ein Lambda Shuttle des Galaktischen Imperiums"},
	["Zoomer"]=				{"UT-60D",		"Ein U-Wing der Neuen Republik"},
	},
	ground_station = nil,
	active_ships = {},
	http_post_send_queue = {},
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
