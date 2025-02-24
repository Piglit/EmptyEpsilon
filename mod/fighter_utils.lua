fighter_utils = {
	ships_templates_fighters = {
		"TIE Fighter",
		"TIE Interceptor",
		"TIE Bomber",
	},
	carriers = {},
	docked_number = 0,
	squadron_number = 1,
	default_faction = "Imperial",
	enemy_faction = "Team Red",
}

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
	addGMFunction("Spawn TF (enemy)", function()
		 PlayerSpaceship():setFaction(fighter_utils.enemy_faction):setTemplate("TIE Fighter"):setCallSign("Alpha-"..fighter_utils.squadron_number)
		 fighter_utils.squadron_number = fighter_utils.squadron_number +1
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

function fighter_utils:onNewPlayerShip(ship)
	if arrayContains(self.ships_templates_fighters, ship:getTypeName()) then
		local faction = ship:getFaction()	-- setFaction must be called before setTemplate for this to work. Otherwise the faction here is Human Navy
		ship:setAutoCoolant(true)
		ship:setAutoRepair(true)
		if faction == self.enemy_faction then
			ship:setWeaponTubeExclusiveFor(0, "laser_red")
			ship:setWeaponTubeExclusiveFor(1, "laser_red")
			ship:setWeaponStorageMax("laser_green", 0)
			ship:setWeaponStorageMax("laser_red", 99)
			ship:setWeaponStorage("laser_green", 0)
			ship:setWeaponStorage("laser_red", 99)
			ship:commandLoadTube(0, "laser_red")
			ship:commandLoadTube(1, "laser_red")
		else
			ship:commandLoadTube(0, "laser_green")
			ship:commandLoadTube(1, "laser_green")
		end
		ship:setAutoMissileReload(0, true)
		ship:setAutoMissileReload(1, true)

		local carrier = self.carriers[faction]
		if carrier ~= nil and carrier:isValid() then
			local x0,y0 = carrier:getPosition()
			local rot = carrier:getRotation()
			-- turn backwards, + 10 deg per ship, alternating left and right
			rot = rot + 180 + self.docked_number * 10 * ((self.docked_number % 2) * 2 - 1)
			local x1,y1 = vectorFromAngle(rot, 100)
			ship:setPosition(x0+x1,y0+y1):setRotation(rot):commandDock(carrier)
			self.docked_number = self.docked_number +1 
		end
	end
end
