--[[ Controlls the Kraylor invasion
--Depends on: stations
--]]

wh_kraylor = {}

require "luax.lua"
require "utils.lua"

function wh_kraylor:init()

	self.shipScores= {
		["Drone"]= 5,
		["Rockbreaker"]= 22,
		["Rockbreaker Merchant"]= 25,
		["Rockbreaker Murderer"]= 26,
		["Rockbreaker Mercenary"]= 28,
		["Rockbreaker Marauder"]= 30,
		["Rockbreaker Military"]= 32,
		["Spinebreaker"]= 24,
		["Deathbringer"]= 47,
		["Painbringer"]= 50,
		["Doombringer"]= 65,
	}
	self.shipClasses = {
		["fighter"] = {
			"Drone"
		},
		["cruiser"] = {
			"Rockbreaker",
			"Rockbreaker Merchant",
			"Rockbreaker Murderer",
			"Rockbreaker Mercenary",
			"Rockbreaker Marauder",
			"Rockbreaker Military",
			"Spinebreaker",
		},
		["dread"] = {
			"Deathbringer",
			"Painbringer",
			"Doombringer",
		},
	}

	self.fleetList = {}
	self.ownedStations = {}
	self.reinforcement_x = 220000	-- line where reinforecemts arrive
	self.resource = 300 -- point each turn
	self:populateTargetStations()
	addGMFunction("Kraylor invasion", self.triggerKraylorStart)
	getScriptStorage().wh_kraylor = self 
end

function wh_kraylor:populateTargetStations()
	self.targetStations = {}
	local targets = {}
	for _,station in ipairs(wh_stations.stations) do
		local x,y = station:getPosition()
		if station:getFaction() ~= "Kraylor" then
			table.insert(targets, {station.size_factor, x, station})
		end
	end
	table.sort(targets, function(o1,o2)
		local a,b,c	= table.unpack(o1)
		local c,d,e = table.unpack(o2)
		if a < c then return true end
		if a == c and b <= d then return true end
		return false
	end) -- the less important targets are first!
	for _,target in ipairs(targets) do
		local _,_,station = table.unpack(target)
		table.insert(self.targetStations, station)
	end
	return #self.targetStations > 0
end

function wh_kraylor:getTarget()
	if #self.targetStations == 0 then
		if not self:populateTargetStations() then
			return
		end
	end
	local target = table.remove(self.targetStations)	-- pop from back
	if target ~= nil and target:isValid() and target:getFaction() ~= "Kraylor" then
		return target
	else
		return self:getTarget()
	end
end

function wh_kraylor:populateOwnedStations()
	self.ownedStations = {}
	for _,station in ipairs(wh_stations.stations) do
		if station ~= nil and station:isValid() and station:getFaction() == "Kraylor" then
			table.insert(self.ownedStations, station)
		end
	end
	table.shuffle(self.ownedStations)
	return #self.ownedStations
end

function wh_kraylor:spawn_enemies_kraylor(xOrigin, yOrigin, enemyStrength)
	local totalStrength = 0
	local enemyNameList = {}
	local enemyList = {}

	local enemyPosition = 0
	local sp = irandom(500,700)			--random spacing of spawned group

	local formationLeader = nil
	local formationSecond = nil
	local smallFormations = {}

	-- one dreadnought
	if enemyStrength >= 50 then
		local shipTemplateType = tableSelectRandom(self.shipClasses["dread"])
		table.insert(enemyNameList, shipTemplateType)
		enemyStrength = enemyStrength - self.shipScores[shipTemplateType]
		totalStrength = totalStrength + self.shipScores[shipTemplateType]
	end
	-- fill with cruisers
	while enemyStrength > 20 do
		local shipTemplateType = tableSelectRandom(self.shipClasses["cruiser"])
		table.insert(enemyNameList, shipTemplateType)
		enemyStrength = enemyStrength - self.shipScores[shipTemplateType]
		totalStrength = totalStrength + self.shipScores[shipTemplateType]
	end

	-- here other formation or spawn logic is possible. E.g. Hangar code
	for index,shipTemplateType in ipairs(enemyNameList) do
		local ship = CpuShip():setFaction("Kraylor"):setScannedByFaction("Kraylor", true):setTemplate(shipTemplateType):orderRoaming()
		enemyPosition = enemyPosition + 1
		ship:setPosition(xOrigin+sp*enemyPosition, yOrigin+sp*enemyPosition)
		formationLeader, formationSecond = script_formation.buildFormationIncremental(ship, enemyPosition, formationLeader, formationSecond)
		table.insert(enemyList, ship)
	end

	-- drones
	local droneNum = math.ceil(enemyStrength / 5)
	if droneNum > 0 and #enemyList > 0 then
		script_hangar.create(enemyList[1], "Drone", droneNum)
		totalStrength = totalStrength + 5 * droneNum
	end
	return enemyList, totalStrength
end


function wh_kraylor:spawnKraylorFleet(xOrigin, yOrigin, power, danger)
	if danger == nil then 
		danger = 1
	end
	enemyStrength = math.max(power * danger * difficulty, 5)	-- difficulty must be global
	local enemyList, fleetPower = self:spawn_enemies_kraylor(xOrigin, yOrigin, enemyStrength)
	fleetPower = math.max(fleetPower/danger/difficulty, 5)
	return enemyList, fleetPower
end

function wh_kraylor:spawnDefensiveFleets(resource)
	local station = tableRemoveRandom(self.ownedStations)
	while station ~= nil and resource > 0 do
		if station:isValid() and station:getFaction() == "Kraylor" then
			local fleetPower
			if resource > 120 then
				fleetPower = random(80,120)
			else
				fleetPower = 120
			end
			local f1bx, f1by = station:getPosition()
			local fleet
			fleet, fleetPower = self:spawnKraylorFleet(f1bx, f1by, fleetPower, station.size_factor)
			local leader = fleet[1]
			if leader ~= nil and leader:isValid() then
				leader:orderDefendTarget(station)
			end
			table.insert(self.fleetList,fleet)
			resource = resource - fleetPower
		end
		if resource > 0 then
			station = tableRemoveRandom(self.ownedStations)
		end
	end
	return resource 
end

function wh_kraylor:spawnReinforcementFleets(resource)
	local station = tableRemoveRandom(self.ownedStations)
	while station ~= nil and resource > 0 do
		if station:isValid() and station:getFaction() == "Kraylor" then
			local fleetPower
			if resource > 120 then
				fleetPower = random(80,120)
			else
				fleetPower = 120
			end
			local f1bx, f1by = station:getPosition()
			local fleet
			fleet, fleetPower = self:spawnKraylorFleet(self.reinforcement_x, f1by, fleetPower, 1)
			local leader = fleet[1]
			if leader ~= nil and leader:isValid() then
				leader:orderDefendTarget(station)
			end
			table.insert(self.fleetList,fleet)
			resource = resource - fleetPower
		end
		if resource > 0 then
			station = tableRemoveRandom(self.ownedStations)
		end
	end
	return resource 
end

function wh_kraylor:spawnInvaderFleets(resource)
	while resource > 0 do
		local fleetPower
		if resource > 120 then
			fleetPower = random(80,120)
		else
			fleetPower = 120
		end
		local fleet
		fleet, fleetPower = self:spawnKraylorFleet(self.reinforcement_x, random(-50000,50000), fleetPower, 1)
		local leader = fleet[1]

		if leader ~= nil and leader:isValid() then
			local target = self:getTarget()
			if target ~= nil and target:isValid() then
				leader:orderDefendTarget(target)
			end
		end
		-- do not insert into fleet list. This fleet loses aggro after capturing the stations
		-- it will gain aggro, when stations gets destroyed or leader dies
		resource = resource - fleetPower
	end
	return resource
end

function wh_kraylor:makeFleetAggro()
	local fleet = nil
	fleet = tableRemoveRandom(self.fleetList)
	local count = 0
	local sector = nil
	local first_target = nil
	local first_attacker = nil
	if fleet ~= nil and #fleet > 0 then
		local leader = fleet[1]
		if leader ~= nil and leader:isValid() then
			local target = self:getTarget()
			sector = leader:getSectorName()
			if target ~= nil and target:isValid() and target:getFaction() ~= "Kraylor" then
				leader:orderDefendTarget(target)
				if first_target == nil then
					first_target = target
					first_attacker = leader
				end
			end
			count = #fleet
		end
	end
	if first_target ~= nil and first_attacker:isValid() then
		msg = string.format("Kraylor %s %s: Feeble Arlenians and unworthy Humans - we will take what is rightfully ours! Surrender station %s in sector %s or prepare to be eliminated! Any resistance will be crushed!", first_attacker:getTypeName(), first_attacker:getCallSign(), first_target:getCallSign(), first_target:getSectorName())
		sendMessageToCampaignServer("kraylor-comms", msg)
	end
	--[[
	for _, sat in ipairs(scenario.spySats) do
		if sat ~= nil and sat:isValid() and count > 1 then
			sendMessageToCampaignServer(string.format("spyReport:%s detected %s %s ships in sector %s setting course to attack.", sat:getCallSign(), count, faction, sector))
		end
	end
	--]]
	return count, sector 
end


-- called onPause
function wh_kraylor.spawnWave()
	local resource = wh_kraylor.resource
	local owned = wh_kraylor:populateOwnedStations()
	local remain 
	if owned > 0 then
		-- there are stations owned by us, distrubute 1/3 resource directly towards them
		remain = wh_kraylor:spawnDefensiveFleets(resource/3)
		-- distrubute 1/3 resource as reinforcements
		remain = remain + wh_kraylor:spawnReinforcementFleets(resource/3)
		-- distrubute 1/3 as invading fleet
		resource = resource/3 + remain
	end
	-- if we do not have stations, distribute all to invaders!
	wh_kraylor:spawnInvaderFleets(resource)
end

-- called onTurn
function wh_kraylor.commandAttack()
	local fleetsToUse = #wh_kraylor.fleetList /4
	repeat
		wh_kraylor:makeFleetAggro()
		fleetsToUse = fleetsToUse -1
	until fleetsToUse <= 0
end

function wh_kraylor.triggerKraylorStart()
	wh_turns:addOnStart("kraylorAttack", wh_kraylor.commandAttack)
	wh_turns:addOnPause("kraylorSpawn", wh_kraylor.spawnWave)
	wh_kraylor.spawnWave()
	removeGMFunction("Kraylor invasion")
	addGMFunction("Kraylor Spawn", wh_kraylor.spawnWave)
	addGMFunction("Kraylor Attack", wh_kraylor.commandAttack)
end

function wh_kraylor:update(delta)
	-- stations surrender
	for _,station in ipairs(wh_stations.stations) do
		if station ~= nil and station:isValid() and station:getFaction() == "Arlenians" then
			local threatened = false
			local defended = false
			for _, obj in ipairs(station:getObjectsInRange(7500)) do
				if obj.typeName == "CpuShip" or obj.typeName == "PlayerSpaceship" then
					if station:isEnemy(obj) then
						threatened = true
					else
						defended = true
						break
					end
				end
			end
			if threatened and not defended then
				if 100*station:getHull()/station:getHullMax() < station.surrender_hull_threshold then
					-- reduce threshold
					station.surrender_hull_threshold = station.surrender_hull_threshold / 2
					if station.comms_data == nil then
						station.comms_data = {}
					end
					mergeTables(station.comms_data, {
						surrender_hull_threshold = station.surrender_hull_threshold
					})
					-- change faction
					station:setFaction("Kraylor")
				end
			end
		end
	end
end
