vf_trade_network = {
	stations = {},
	transporters = {},
	next_station_idx = 0
}


function vf_trade_network:next_station()
	self.next_station_idx = self.next_station_idx +1
	if self.stations[self.next_station_idx] == nil then
		arrayShuffle(self.stations)
		self.next_station_idx = 1
	end	
	return self.stations[self.next_station_idx]	-- could still be nil if empty
end

function vf_trade_network:send_ship(ship)
	local target = self:next_station()
	ship.undock_delay = math.random(5, 30)
	if target ~= nil and target:isValid() then
		ship:orderDock(target)
	end
end

function vf_trade_network:load_ship(ship, station)
	ship.source = station
	-- get features
	-- just trading weapons for now
	ship.weapons_cargo = {}
	if station.comms_data ~= nil and
	station.trade_power ~= nil and
	station.comms_data.weapon_available ~= nil then
		for service, avail in pairs(station.comms_data.weapon_available) do
			if avail == true then
				ship.weapons_cargo[service] = ship.length * station.trade_power
				-- trade_power: 2-8
				-- length: 1-5, capped by trade_power/2 of original station. (-> 1-4)
				-- result: 2 - 32
			end
		end

	--	ship.services = {}
	--	for service, avail in pairs(station.comms_data.service_available) do
	--		if avail then
	--			table.insert(ship.services, service)
	--		end
	--	end
	end
	self:send_ship(ship)
end

function vf_trade_network:unload_ship(ship, station)
	if station ~= ship.source and
	ship.weapons_cargo ~= nil then
		-- apply features, only if we are at a different station
		for weapon, count in pairs(ship.weapons_cargo) do
			-- if the station already has unlimited supply, do nothing.
			-- the weapon type will be loaded in load ship.
			-- if the station has lower trade_power, the transported result will be lower.
			if station.comms_data ~= nil and station.comms_data.weapon_available ~= nil then
				if station.comms_data.weapon_available[weapon] == false then
					station.comms_data.weapon_available[weapon] = count
				elseif type(station.comms_data.weapon_available[weapon]) == "number" then
					station.comms_data.weapon_available[weapon] = station.comms_data.weapon_available[weapon] + count
				end
			end
		end
		-- it would be nice, if trade would have more impact
	end
	self:load_ship(ship, station)
end

function vf_trade_network:add_station(station)
	-- Launch trade ships towards other stations.
	station.trade_power = math.ceil(station:getHullMax() / 100)	-- 2-8
	local amount = math.max(station.trade_power, #vf_trade_network.stations)
	local arc = math.random(0,360)
	for i = 1, amount do
		assert(amount ~= 0)
		arc = arc + 360/amount
		local ship = self:spawn_trade_ship(math.ceil(station.trade_power/2))
		local x,y = station:getPosition()
		setCirclePos(ship, x,y, arc, 1000)
   		ship:setRotation(arc)
		ship:setScannedByFaction(station:getFaction(), true)
		table.insert(self.transporters, ship)
		self:load_ship(ship, station)
	end
	-- insert happens after the launch, since one single station does nothing.
	table.insert(self.stations, station)
	-- second stations will send all ships to first one
end

function vf_trade_network:spawn_trade_ship(length)
	length = math.max(math.min(length, 5), 1)
	local name = arraySelectRandom({"Personnel", "Goods", "Garbage", "Equipment", "Fuel"})
	if length >= 3 and math.random(1, 100) < 30 then
		name = name .. " Jump Freighter " .. length
	else
		name = name .. " Freighter " .. length 
	end
	local ship = CpuShip():setTemplate(name):setFaction("Blue Star")
	-- they will be attacked by Kraylor and Criminals,
	-- not by Exuari, Hive or GITM											 
	ship.length = length
	return ship
end

function vf_trade_network:update(delta)
	arrayFilter(self.transporters, function(obj)
		return obj:isValid()
	end)
	arrayFilter(self.stations, function(obj)
		return obj:isValid()
	end)

	for _, ship in ipairs(self.transporters) do
		-- ships target may be influenced by players
		local order = ship:getOrder()
		if order == "Dock" then
			local target = ship:getOrderTarget()
			if target ~= nil and target:isValid() then
				if ship:isDocked(target) then
					if ship.undock_delay > 0 then
						ship.undock_delay = ship.undock_delay - delta
					else
					-- after docking, go on; trading is must continue, even if docked with a station that is not in the trade network
						self:unload_ship(ship, target)
					end
				end
			else
				-- target became invalid
				self:send_ship(ship)
			end
		elseif order == "Roaming" or order == "Idle" then
			self:send_ship(ship)
        end
    end
end
