--[[ Fighter and carrier script
* Carrier can (re-)spawn TIEs
* There can be up to 4 TIEs/Pilots (RHO 1-4) - may be redifined...
* if one is destroyed, a pod with the same callsign is created.
* if no more entity with that callsign is there, the TIE can be respawned
* GM can add to the TIE contingent (for each TIE-type)
* Callsigns are specific for TIE types
* TA RHO are player ships, others are CPU ships. (what if we had a bomber pilot?)
--]]


fighter_utils = {
	number_of_rhos = 4,
	rho_ships = {},	-- contains ship objects with index; also tracks pods
--	ships_templates_fighters = {
--		"TIE Fighter",
--		"TIE Interceptor",
--		"TIE Bomber",
--	},
--	carriers = {},
--	docked_number = 0,
--	squadron_number = 1,
--	default_faction = "Imperial",
--	enemy_faction = "Team Red",
}

-- grant green lasers and load them
function fighter_utils:makeImperialFighterReady(ship)
	ship:setAutoCoolant(true)
	ship:setAutoRepair(true)
	ship:setRepairCrewCount(0)
	ship:setAutoMissileReload(0, true)
	ship:setAutoMissileReload(1, true)
	ship:commandLoadTube(0, "laser_green")
	ship:commandLoadTube(1, "laser_green")
	ship:setSystemPowerFactor("reactor", -10)
end

-- order in a circle around the carriers heck
function fighter_utils:placeFighterInCarrier(ship, carrier, idx)
	if carrier ~= nil and carrier:isValid() then
		local x0,y0 = carrier:getPosition()
		local rot = carrier:getRotation()
		-- turn backwards, + 10 deg per ship, alternating left and right
		rot = rot + 180 + idx * 10 * ((idx % 2) * 2 - 1)
		local x1,y1 = vectorFromAngle(rot, 100)
		ship:setPosition(x0+x1,y0+y1):setRotation(rot)
		ship:commandDock(carrier)
	end
end

function fighter_utils:createRho(idx)
	local rho = PlayerSpaceship():setTemplate("TIE Interceptor"):setCallSign("Rho-"..idx):setFaction("Imperial")
	fighter_utils:makeImperialFighterReady(rho)
	self.rho_ships[idx] = rho
	return rho
end

function fighter_utils:update(dt)
	for idx = 1, self.number_of_rhos do
		removeGMFunction("Spawn Rho-"..idx)
		local rho = self.rho_ships[idx]
		if rho == nil or not rho:isValid() then
			rho = nil
			local rho_idx = getPlayerShipIndex("Rho-"..idx)
			if rho_idx > 0 then
				rho = getPlayerShip(rho_idx)
				if rho ~= nil and rho:isValid() then
					self.rho_ships[idx] = rho
				else
					rho = nil
				end
			end
		end
		if rho == nil then
			addGMFunction("Spawn Rho-"..idx, function()
				onGMClick(function(x,y)
					local rho = self.rho_ships[idx]
					if rho == nil or not rho:isValid() then
						rho = fighter_utils:createRho(idx)
						rho:setPosition(x,y)
					end	
					onGMClick(nil)
				end)		
			end)
		end
	end
end

--[[
function fighter_utils:init()
	addGMFunction("Spawn TI Point", function()
		 PlayerSpaceship():setFaction(fighter_utils.default_faction):setTemplate("TIE Interceptor"):setCallSign("Rho-"..fighter_utils.squadron_number):setLongRangeRadarRange(10000):setCanScan(false)
		 fighter_utils.squadron_number = fighter_utils.squadron_number +1
	end)
	addGMFunction("Spawn TI Wing", function()
		 PlayerSpaceship():setFaction(fighter_utils.default_faction):setTemplate("TIE Interceptor"):setCallSign("Rho-"..fighter_utils.squadron_number):setLongRangeRadarRange(15000):setCanScan(true)
		 fighter_utils.squadron_number = fighter_utils.squadron_number +1
	end)
	addGMFunction("Spawn TB", function()
		 PlayerSpaceship():setFaction(fighter_utils.default_faction):setTemplate("TIE Bomber"):setCallSign("Gamma")
	end)
	addGMFunction("Spawn TB (CPU)", function()
		local tb = CpuShip():setFaction(fighter_utils.default_faction):setTemplate("TIE Bomber"):setCallSign("Gamma"):setScanStateByFaction(fighter_utils.default_faction, "fullscan"):setCanBeDestroyed(false)
		fighter_utils:onNewPlayerShip(tb)
	end)

	addGMFunction("Spawn TF (enemy)", function()
		 PlayerSpaceship():setFaction(fighter_utils.enemy_faction):setTemplate("TIE Fighter"):setCallSign("Alpha-"..fighter_utils.squadron_number)
		 fighter_utils.squadron_number = fighter_utils.squadron_number +1
	end)
	addGMFunction("Spawn TF (enemy, CPU)", function()
		 local tf = CpuShip():setFaction(fighter_utils.enemy_faction):setTemplate("TIE Fighter"):setCallSign("Alpha-"..fighter_utils.squadron_number):setScanStateByFaction(fighter_utils.enemy_faction, "fullscan")
		 fighter_utils.squadron_number = fighter_utils.squadron_number +1
		 fighter_utils:onNewPlayerShip(tf)
	end)

end

function fighter_utils:spawnCarrier()
	local carrier = PlayerSpaceship():setTemplate("Gozanti"):setCallSign("GZ-1"):setFaction(self.default_faction):setCanBeDestroyed(false)
	self.carriers[self.default_faction] = carrier
	return carrier
end

function fighter_utils:spawnFreighter()
	local carrier = PlayerSpaceship():setTemplate("Action IV"):setCallSign("FA-2"):setFaction(self.enemy_faction):setCanBeDestroyed(false)
	self.carriers[self.enemy_faction] = carrier
	return carrier
end

function fighter_utils:spawnCarrierStation()
	local carrier = SpaceStation():setTemplate("Small Station"):setCallSign("Hangar"):setFaction(self.default_faction):setCanBeDestroyed(false)
	self.carriers[self.default_faction] = carrier
	return carrier
end

function fighter_utils:onNewPlayerShip(ship)
	if arrayContains(self.ships_templates_fighters, ship:getTypeName()) then
		local faction = ship:getFaction()	-- setFaction must be called before setTemplate for this to work. Otherwise the faction here is Human Navy
		if faction == self.enemy_faction then
			ship:setWeaponTubeExclusiveFor(0, "laser_red")
			ship:setWeaponTubeExclusiveFor(1, "laser_red")
			ship:setWeaponStorageMax("laser_green", 0)
			ship:setWeaponStorageMax("laser_red", 99)
			ship:setWeaponStorage("laser_green", 0)
			ship:setWeaponStorage("laser_red", 99)
			if ship.typeName == "PlayerSpaceship" then
				ship:commandLoadTube(0, "laser_red")
				ship:commandLoadTube(1, "laser_red")
			end
		elseif ship.typeName == "PlayerSpaceship" then
			ship:commandLoadTube(0, "laser_green")
			ship:commandLoadTube(1, "laser_green")
		end
		if ship.typeName == "PlayerSpaceship" then
			ship:setAutoCoolant(true)
			ship:setAutoRepair(true)
			ship:setRepairCrewCount(0)
			ship:setAutoMissileReload(0, true)
			ship:setAutoMissileReload(1, true)
		end

		local carrier = self.carriers[faction]
		if carrier ~= nil and carrier:isValid() then
			local x0,y0 = carrier:getPosition()
			local rot = carrier:getRotation()
			-- turn backwards, + 10 deg per ship, alternating left and right
			rot = rot + 180 + self.docked_number * 10 * ((self.docked_number % 2) * 2 - 1)
			local x1,y1 = vectorFromAngle(rot, 100)
			ship:setPosition(x0+x1,y0+y1):setRotation(rot)
			self.docked_number = self.docked_number +1 
			if ship.typeName == "PlayerSpaceship" then
		  		ship:commandDock(carrier)
			else
		  		ship:orderDock(carrier)
			end
		end
	end
end
	--]]
