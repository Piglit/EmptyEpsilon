-- Name: Training: Mine Layer 
-- Type: Mission
-- Description: Mine Layer Training Course
---
--- Objective: Destroy all enemy ships in the area.
---
--- Description:
--- In this training you will use mines to defend a station against an enemy carrier ship.
---
--- Your ship is a Nautilus Mine Layer - a jump-driven cruiser without missiles but multiple mine tubes.
---
--- This is a short mission for players who like to lay mines.

-- secondary goal: test and example for script_hangar (with configuration)


require "utils.lua"
require "script_hangar.lua"

function createFreighter()
    return CpuShip():setTemplate("Goods Freighter 3"):setFaction("Exuari")
end

function createCarrier()
    return CpuShip():setTemplate("Ryder"):setFaction("Exuari")
end

function createRevenge()
    return CpuShip():setTemplate("Flash"):setFaction("Exuari")
end

function createWingman()
    return CpuShip():setFaction("Human Navy"):setTemplate("Phobos T3"):setScannedByFaction("Human Navy", true)
end

function createPlayerShip()
    return PlayerSpaceship():setTemplate("Nautilus"):setFaction("Human Navy")
end

function init()
    allowNewPlayerShips(false)
    enemyList = {}
    enemyFightersList = {}
    revenge_active = false

    timer = 0
    finishedTimer = 5
    finishedFlag = false

    gu = 5000   -- grid unit for enemy spawns

    player = createPlayerShip():setPosition(0, 0):setHeading(90)
    player:setLongRangeRadarRange(30000)
    player:addReputationPoints(100.0)

    station = SpaceStation():setTemplate('Medium Station'):setCallSign("Maintainance Dock"):setRotation(random(0, 360)):setFaction("Human Navy"):setPosition(-800, 1200)
    wingman = createWingman():setCallSign("June"):orderIdle():setPosition(400, 400)

    freighter = createFreighter()
    freighter:setPosition(0, 5*gu):setRotation(-90):orderFlyTowardsBlind(0, -4*gu):setCallSign("Lambda")
    table.insert(enemyList, freighter)

    revenge = createRevenge()
    revenge:setPosition(0, 6*gu):setRotation(-90):orderDefendTarget(freighter):setCallSign("Kappa")
    table.insert(enemyList, revenge)

    enemy_station = createCarrier()
    enemy_station:setPosition(0, -5*gu):setRotation(90):orderDefendLocation(0, -4*gu):setCallSign("Omega")

    script_hangar.create(enemy_station, "Dagger", 3)
    script_hangar.append(enemy_station, "Blade", 3)
    script_hangar.config(enemy_station, "onLaunch", addToEnemiesList)
    script_hangar.config(enemy_station, "callSignPrefix", "Zeta-")
    script_hangar.config(enemy_station, "launchDistance", 900)

    script_hangar.create(enemy_station, "Gunner", 3)
    script_hangar.append(enemy_station, "Shooter", 3)
    script_hangar.append(enemy_station, "Jagger", 3)
    script_hangar.config(enemy_station, "triggerRange", gu*2)
    script_hangar.config(enemy_station, "onLaunch", addToEnemiesList)
    script_hangar.config(enemy_station, "callSignPrefix", "Gamma-")
    script_hangar.config(enemy_station, "launchDistance", 900)
    table.insert(enemyList, enemy_station)
    
    --createObjectsOnLine(rr/2, rr/4, rr/4, rr/2, 1000, Mine, 2)
    --createRandomAlongArc(Asteroid, 100, 0, 0, rr-2000, 180, 270, 1000)
    --createRandomAlongArc(VisualAsteroid, 100, 0, 0, rr-2000, 180, 270, 1000)
    placeRandomAroundPoint(Asteroid, 50, 0, gu, -gu, 0)
    placeRandomAroundPoint(VisualAsteroid, 50, 0, gu, -gu, 0)
    placeRandomAroundPoint(Asteroid, 50, 0, gu,  gu, 0)
    placeRandomAroundPoint(VisualAsteroid, 50, 0, gu,  gu, 0)
    
    --spwanNextWave()
    --instructions()
    wingman:sendCommsMessage(player, [[This is Commander Saberhagen.

In this training you will defend our stations against a carrier ship.
Your ship will be a Nautilus mine layer.
Try to defeat all enemies with your mines. Your beam turrets will not help you much here.
The key to success might be the clever use of your impulse and jump drives.

Commander Saberhagen out.]])
    enemyCountStart = #enemyList
    enemyFightersRemaining = 15

end

function addToEnemiesList(_, ship, _)
    table.insert(enemyFightersList, ship)
    enemyFightersRemaining = enemyFightersRemaining - 1
end

function finished(delta)
    finishedTimer = finishedTimer - delta
    if finishedTimer < 0 then
        victory("Human Navy")
    end
    if finishedFlag == false then
        finishedFlag = true
        local bonusString = "survived."
        if not station2:isValid() then
            bonusString = "was destroyed."
        end
        globalMessage([[Mission Complete.
Your Time: ]]..formatTime(timer)..[[
Civilian Station]]..bonusString..[[

If you feel ready for a challenge and you liked the ship, play 'close the gaps'.
If you want to try another ship, play another training mission.]])
    end
end

function update(delta)
    script_hangar.update(delta)
    timer = timer + delta
    local enemyCountChanged = false

	for i, enemy in ipairs(enemyList) do
		if enemy == nil or not enemy:isValid() then
			table.remove(enemyList, i)
            enemyCountChanged = true
			-- Note: table.remove() inside iteration causes the next element to be skipped.
			-- This means in each update-cycle max half of the elements are removed.
			-- It does not matter here, since update is called regulary.
		end
	end
	for i, enemy in ipairs(enemyFightersList) do
		if enemy == nil or not enemy:isValid() then
			table.remove(enemyFightersList, i)
            enemyCountChanged = true
		end
	end

    if enemyCountChanged then
        local targetNumber = enemyCountStart + 15
        local remaining = #enemyList + #enemyFightersList
        if enemy_station ~= nil and enemy_station:isValid() then
            remaining = remaining + enemyFightersRemaining
        end
        local progress = 100 - 100 * (remaining / targetNumber)
        sendMessageToCampaignServer(string.format("setProgress:%.0f%%", progress))
    end

    if #enemyList == 0 and #enemyFightersList == 0 then
        finished(delta)
    end

    if revenge:isValid() and not revenge_active then
        if not freighter:isValid() or not enemy_station:isValid() then
            revenge_active = true
            revenge:orderAttack(player)
        end
        if enemy_station:isValid() and enemy_station:getHull() < enemy_station:getHullMax() then
            revenge_active = true
            revenge:orderAttack(player)
        end
    end
end

