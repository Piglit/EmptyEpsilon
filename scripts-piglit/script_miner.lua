mining = {}
local mining_ships = {}

-- for all Asteroids and VisualAsteroids in max radius distance to station:
-- return closest one to ship
local function findAsteroid(ship, station, radius)
	local x, y = station:getPosition()

	local objects = {}
	local distance
	local bestObject 
	for _, object in pairs(getObjectsInRadius(x, y, radius)) do
		if target:isValid() and (target.typeName == "Asteroid" or target.typeName == "VisualAsteroid") then
			table.insert(objects, object)
		end
	end
	if #objects == 0 then
		return nil
	else
		distance = distance(ship, objects[1])
		bestObject = objects[1]
	end
	for _,object in ipairs(objects) do
		local d = distance(ship, object)
		if d < distance then
			distance = d
			bestObject = object
		end
	end
	return bestObject
end

-- order a ship to mine asteroids around homeStation
function mining.orderMiner(ship, homeStation)
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
function miners.update(dt)
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
					target = findAsteroid(ship, homeStation, config.maxDistanceFromHome)
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
