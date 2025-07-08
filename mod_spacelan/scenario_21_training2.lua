-- Name: Frigates Testing Ground
-- Type: Training
-- Short Description: Frigate Training Ground
-- Objective: Destroy all enemy ships in the area.
-- Duration: 30 minutes
-- Difficulty: easy-medium
-- Description: Use the capabilities of different specialised ships agains different enemies.
-- Setting[Ships]: Sets up what kind of ship types are available
-- Ships[Frigates|Default]: All Frigates and a Scout are available
-- Ships[Corvettes]: Heavier Corvettes are available

-- secondary objective: show the basic usage of some script modules

require("utils.lua")
require("luax.lua")	-- table.filter

require("script_formation.lua")	-- script_formation.spawnFormation
require("script_hangar.lua")	-- script_hangar.create
require("util_swap_ships.lua")
require("plots/campaign.lua")
require("plots/wh_util_rota.lua")

--- Ship creation functions

function createHumanShip(template, posx, posy, arc)
	return {CpuShip():setFaction("Human Navy"):setTemplate(template):setPosition(posx, posy):setRotation(arc):orderIdle():setScanned(true)}
end

function createHumanScoutShip(posx, posy, arc)
	return createHumanShip(" Adder MK7", posx, posy, arc)
end

function createHumanBeamShip(posx, posy, arc)
	return createHumanShip(" Hathcock", posx, posy, arc)
end

function createHumanMissileShip(posx, posy, arc)
	return createHumanShip(" Piranha M5P", posx, posy, arc)
end

function createHumanMineShip(posx, posy, arc)
	return createHumanShip(" Nautilus", posx, posy, arc)
end

function createHumanBeamShipHeavy(posx, posy, arc)
	return createHumanShip(" Maverick", posx, posy, arc)
end

function createHumanMissileShipHeavy(posx, posy, arc)
	return createHumanShip(" Crucible", posx, posy, arc)
end

function createExuariFighterSquad(posx, posy, arc)
	local enemyList = script_formation.spawnFormation("Dagger", 2, posx, posy, "Exuari", "Beta-")
	enemyList[1]:orderDefendLocation(posx, posy)
	return enemyList
end

function createExuariBomberSquad(posx, posy, arc)
	local enemyList = script_formation.spawnFormation("Gunner", 2, posx, posy, "Exuari", "Gamma-")
	enemyList[1]:orderDefendLocation(posx, posy)
	return enemyList
end

function createKraylorBeamship(posx, posy, arc)
	return {CpuShip():setFaction("Kraylor"):setTemplate("Spinebreaker"):setPosition(posx, posy):setRotation(arc):orderDefendLocation(posx, posy)}
end

function createKraylorGunship(posx, posy, arc)
	return {CpuShip():setFaction("Kraylor"):setTemplate("Rockbreaker"):setPosition(posx, posy):setRotation(arc):orderDefendLocation(posx, posy)}
end

function createKraylorDreadnought(posx, posy, arc)
	local ship = CpuShip():setFaction("Kraylor"):setTemplate("Deathbringer"):setPosition(posx, posy):setRotation(arc):orderDefendLocation(posx, posy)
	script_hangar.create(ship, "Drone", 2, insertDrone)
	return {ship}
end

function createKraylorDreadnoughtCarrier(posx, posy, arc)
	local ship = CpuShip():setFaction("Kraylor"):setTemplate("Painbringer"):setPosition(posx, posy):setRotation(arc):orderDefendLocation(posx, posy):setJumpDrive(false)
	script_hangar.create(ship, "Drone", 4, insertDrone)
	return {ship}
end

function createExuariSmallSniper(posx, posy, arc)
	return {CpuShip():setTemplate("Ranger"):setFaction("Exuari"):setPosition(posx, posy):orderDefendLocation(posx, posy):setRotation(arc)}
end

function createExuariNormalSniper(posx, posy, arc)
	return {CpuShip():setTemplate("Flash"):setFaction("Exuari"):setPosition(posx, posy):orderDefendLocation(posx, posy):setRotation(arc)}
end

function insertDrone(mother, newShip, idx)
	table.insert(dronesList, newShip)
end

-- init
function init()
	wh_rota:init()
	local terrain_radius = 22000
	local player_ship_radius = 4000
	local enemies_inner_radius = 18000
	local enemies_outer_radius = 32000

	-- global vars
	finishedTimer = 5
	finishedFlag = false
	dronesList = {}
	enemyList = {}
	humanList = {}

	-- place terrain
	local r = terrain_radius
	local x,y = radialPosition(0,0, r, 45)
	placeRandomAroundPoint(Asteroid, 100, 0, r*0.5, x, y)
	placeRandomAroundPoint(VisualAsteroid, 100, 0, r*0.5, x, y)
	local x_0,y_0 = radialPosition(0,0, r*0.8, 45+90)
	local x_1,y_1 = radialPosition(0,0, r*1.2, 45+90)
	createObjectsOnLine(x_0, y_0, x_1, y_1, 1000, Mine, 2)
	x,y = radialPosition(0,0, r, 45+180)
	placeRandomAroundPoint(Nebula, 4, 0, r*0.5, x, y)
	x,y = radialPosition(0,0, r, 45+270)
	BlackHole():setPosition(x, y)
	local art = campaign:placeArtifact(x,y, "Black Hole Orbiter", "A bunch of space debris, trapped near the event horizon of a black hole. It was in range of the gravitational pull of the black hole, but it's speed was sufficient to keep it in a stable orbit.")
	art:setPosition(x+4000,y)
	wh_rota:add_object(art, 2, x,y)

	-- place ships
	local spawn_funcs = {
		{createHumanBeamShip, createExuariFighterSquad, createExuariBomberSquad},
		{createHumanMissileShip, createKraylorBeamship, createKraylorGunship},
		{createHumanMineShip, createKraylorDreadnought, createKraylorDreadnoughtCarrier},
		{createHumanScoutShip, createExuariSmallSniper, createExuariNormalSniper},
	}

	-- place enemies
	for i,funcs in ipairs(spawn_funcs) do
		local arc = i*360/#spawn_funcs
		if funcs[1] ~= nil then
			x,y = radialPosition(0,0, player_ship_radius, arc)
			table.extend(humanList, funcs[1](x,y,arc))
		end
		x,y = radialPosition(0,0, enemies_inner_radius, arc)
		table.extend(enemyList, funcs[2](x,y,arc-180))
		x,y = radialPosition(0,0, enemies_outer_radius, arc)
		table.extend(enemyList, funcs[3](x,y,arc-180))
	end

	if getScenarioSetting("Ships") == "Corvettes" then
		local arc = 45
		x,y = radialPosition(0,0, player_ship_radius, arc)
		table.extend(humanList, createHumanBeamShipHeavy(x,y,arc))
		arc = 180+45
		x,y = radialPosition(0,0, player_ship_radius, arc)
		table.extend(humanList, createHumanMissileShipHeavy(x,y,arc))
	end
	enemyCountStart = #enemyList

	-- place space station
	station = SpaceStation():setTemplate("Medium Station"):setCallSign("Dock"):setFaction("Human Navy"):setPosition(0,0)
	player = PlayerSpaceship():setTemplate("Pod"):setPosition(-500,500):setRotation(60):commandTargetRotation(60)
	station.comms_data = {docked_comms_functions = {commsSwapShip}}
	campaign:requestReputation()
	campaign:initScore()
	station:sendCommsMessage(player, [[This is Commander Saberhagen.

You are here to try out different ship types agains different types of enemy ships in this frigate testing compound.
Dock the crew pod you are currently in with the central station 'Dock'. When you are docked, contact the station, so we can move you on board of any ship you like.]])
end

function commsSwapShip(comms_source, comms_target)
	table.filter(humanList, function(obj)
		return obj:isValid()
	end)
	local avail = {}
	for _,ship in ipairs(humanList) do
		if distance(ship, comms_target) <= 5000 then
			table.insert(avail, ship)
		end
	end
	if #humanList > 0 then
		addCommsReply("Transfer us to another ship", function()
			if #avail == 0 then
				setCommsMessage("We can only transfer you to Human Navy ships that are in 5U range.\nContact the ship you want and make sure it gets closer to 5U of this station.")
			else
				setCommsMessage("We can transfer your crew to any Human Navy ship that is within 5U range.\nIf you need information on the ship types, ask your science officer to look them up in the database.\nWhat ship do you want to command?")
				for _,ship in ipairs(avail) do
					addCommsReply(string.format("%s %s", ship:getTypeName(), ship:getCallSign()), function()
						setCommsMessage("Transfer in progress. Your crew should arrive on the target ship in a few seconds.")
						if comms_source:getTypeName() == "Pod"  then
							swapCountdown(boardCpuShip, comms_source, ship, function(nps,_)
								player = nps
								player:onDestruction(onPlayerDestroyed)
								if player:getRepairCrewCount() < 1 then
									player:setRepairCrewCount(1)
								end
							end)
					   	else
							local ncs
							swapCountdown(swapPlayerAndCpuShip, comms_source, ship, function(nps, ncs)
								player = nps
								player:onDestruction(onPlayerDestroyed)
								table.insert(humanList, ncs)
								if instr_first_board ~= nil then
									instr_first_board()
								end
								if player:getRepairCrewCount() < 1 then
									player:setRepairCrewCount(1)
								end
							end)
					   	end
					end)
				end
			end
		end)
	end
end

function onPlayerDestroyed(playership, instigator)
	player = PlayerSpaceship():setTemplate("Pod"):setPosition(-500,500):setRotation(60):commandTargetRotation(60)
	return playership
end

function instr_first_board()
	if station ~=nil and station:isValid() and player ~= nil and player:isValid() then
		station:sendCommsMessage(player, [[Welcome to your new ship.
Feel free to navigate the sector and attack any enemy ship you like. The enemies closes to your current position should be the easiest to handle for your kind of ship.
You may also call the other ships for help, if you are in trouble.
If you want to try another ship, feel free to dock with the station and request to be transferred to another ship.
If your current ship is destroyed, you will leave in an escape pod - in this case, also dock with the station and look for a new ship. to command.]])
		instr_first_board = nil
	end
end

function finished(delta)
	finishedTimer = finishedTimer - delta
	if finishedTimer < 0 then
		victory("Human Navy")
	end
	if finishedFlag == false then
		finishedFlag = true
		campaign:victoryScore()
	end
end

function update(delta)
    local enemyCount = campaign:progressEnemyCount(enemyList, true, function()
		-- on change
		if player and player:isValid() and player:getTypeName() ~= "Pod" then
			sendMessageToCampaignServer("unlockShip", player:getTypeName())
		end
	end)
	table.filter(dronesList, function(obj)
		return obj:isValid()
	end)

	if enemyCount == 0 and #dronesList == 0 then
		finished(delta)
	end

	wh_rota:update(delta)
	updateSwapCountdown(delta)
end

