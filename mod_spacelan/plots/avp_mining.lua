require("utils.lua")

avp_mining = {
	mining_stations = {}
}

-- for all Asteroids and VisualAsteroids in max radius distance to obj:
-- return closest one to obj
function avp_mining:findAsteroid(obj, radius)
	local x, y = obj:getPosition()
	local asteroids = {}
	local dist
	local bestObject 
	for _, object in pairs(getObjectsInRadius(x, y, radius)) do
		if object:isValid() and (object.typeName == "Asteroid" or object.typeName == "VisualAsteroid") then
			table.insert(asteroids, object)
		end
	end
	if #asteroids == 0 then
		return nil
	else
		dist = distance(obj, asteroids[1])
		bestObject = asteroids[1]
	end
	for _,ast in ipairs(asteroids) do
		local d = distance(obj, ast)
		if d < dist then
			dist = d
			bestObject = ast 
		end
	end
	return bestObject
end

function avp_mining:activateMining(station, search_range, interval, mine_range)
	station.mining = {
		state = "search",
		last_state_change = 0,
		last_fired = 0,
		firing_interval = 2,
		interval = interval or 120,
		mine_range = mine_range or 5000,
		search_range = search_range or 20000
	}
	table.insert(self.mining_stations, station)
end

function avp_mining:updateMiningStation(station, time, dt)
	local m = station.mining
	if m.last_state_change + m.interval < time then
		if m.target == nil or not m.target:isValid() then
			m.state = "search"
		end
--		print(m.state)
		if m.state == "search" then
			local ast = self:findAsteroid(station, m.mine_range)
			if ast then
				m.target = ast
				m.state = "mine"
			else
				ast = self:findAsteroid(station, m.search_range)
				if ast then
					m.target = ast
					m.state = "move"
				else
					return false -- no more asteroids near, stop mining
				end
			end
			m.last_state_change = time
		elseif m.state == "move" then
			if distance(station, m.target) < 3000 then
				m.state = "search"
				m.last_state_change = time
			else
				assert(station.typeName == "SpaceStation", station.typeName)	-- FIXME: implementation for moving objects
				local rot = angleRotation(station, m.target) 
				local x,y = radialPosition(station, 10*dt, rot)	-- at least 200 sec until target reached
				station:setPosition(x,y)
			end
		elseif m.state == "mine" then
			if m.last_fired + m.firing_interval < time then
				local effect = BeamEffect()
				effect:setSource(station,0,0,-100):setTarget(m.target,0,0,-20)
				effect:setTexture("texture/beam_blue.png")
				effect:setDuration(2*m.firing_interval)
				effect:setRing(false)
				m.last_fired = time
				if m.last_state_change + 2*m.interval < time then
					m.state = "explode"
				end
			end														  
		elseif m.state == "explode" then
			local effect = ExplosionEffect()
			local x,y = m.target:getPosition()
			effect:setPosition(x,y):setSize(m.target:getSize()):setOnRadar(true)
			m.target:destroy()
			m.state = "search"
			m.last_state_change = time
		end
	end
	return true -- continue mining
end

function avp_mining:update(dt)
	local time = getScenarioTime()
	for idx=#self.mining_stations, 1, -1 do	--reverse, so we can remove station from the inside
		local station = self.mining_stations[idx]
		if station == nil or not station:isValid() then
			table.remove(self.mining_stations, idx)
		elseif not self:updateMiningStation(station, time, dt) then
			table.remove(self.mining_stations, idx)
		end
	end
end


--[[ leagcy: mining ships 
-- order a ship to mine asteroids around homeStation
function avp_mining:orderMiner(ship, homeStation)
	local config = {}
	local state = {}
	config.timeToUnload = 15
	config.timeToMine = 15
	config.timeToGoHome = 900
	config.mineDistance = ship:getBeamWeaponRange(0)
	config.maxDistanceFromHome = getLongRangeRadarRange()
	config.maxDistanceToNext = getLongRangeRadarRange() / 2
	config.maxCargo = 1
	state.homeStation = homeStation
	state.cargo = 0
	ship.mining_config = config
	ship.mining_state = state
	table.insert(mining_ships, ship)
end


--State machine:
-- find asteroid
-- fly to asteroid
-- mine asteroid
-- check if full
-- fly home
-- unload
function avp_mining:update(dt)
	for _,ship in ipairs(mining_ships) do
		if not ship:isValid() then
			table.remove(mining_ships, ship)
		else:
			local config = ship.mining_config
			local state = ship.mining_state
			local target = ship.getTarget()
			local homeStation = state.homeStation
			if not homeStation:isValid() then
				ship:orderIdle()
			end

			if target == nil or not target:isValid() then
				-- if empty: to asteroid
				-- if full:  to home
				if state.cargo < config.maxCargo then
					target = self:findAsteroid(ship, homeStation, config.maxDistanceFromHome)
					if target == nil then
						ship:orderDock(homeStation)	--sets target
					else
						ship:orderAttack(target)	--sets target
					end
				else
					ship:orderDock(homeStation)	--sets target
				end
			elseif target == homeStation then
				if ship:isDocked(homeStation) then
					if state.timeToUnload == nil then
						state.timeToUnload = config.timeToUnload
					else
						state.timeToUnload = state.timeToUnload - dt
					end
					if state.timeToUnload <= 0 then
						state.timeToUnload = nil
						state.cargo = 0
						--add stations cargo here
						state.timeToGoHome = nil
						ship:orderIdle() --sets target to nil
					end
				end
			elseif target.typeName == "Asteroid" then
				if state.timeToGoHome == nil then
					state.timeToGoHome = config.timeToGoHome
				else
					state.timeToGoHome = state.timeToGoHome - dt
				end
				if state.timeToGoHome < 0 then
					ship:orderDock(homeStation)	--sets target
					state.timeToGoHome = nil
					state.timeToUnload = nil
				elseif distance(ship, target) <= config.mineDistance then
					if state.timeToMine == nil then
						state.timeToMine = config.timeToMine
					else
						state.timeToMine = state.timeToMine - dt
					end
					if state.timeToMine <= 0 then
						state.timeToMine = nil
						state.cargo = state.cargo + 1
						local x, y = target:getPosition()
						ExplosionEffect():setPosition(x, y):setSize(150)
						target:destroy()
					end
				end
			end
		end
	end
end
--]]
