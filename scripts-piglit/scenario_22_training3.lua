-- Name: Training: Missile Cruiser
-- Type: Mission
-- Description: Advanced Training Course
---
--- Objective: Capture a enemy maintainance dock and destroy all incomming enemy ships in the area.
---
--- Description:
--- During this training your will learn to navigate and use a jumpdrive, destroy enemies with broadside missile tubes and you will coordinate your attack with an allied beam cruiser.
---
--- Your ship is a Piranha missile cruiser - a jump-driven cruiser with broadside missiles, but without beam weapons.
---
--- This is a short mission for players who prefer tactical combat.
-- Variation[Hard]: Every enemy ship has drones.

-- secondary goal: Test and example for script_hangar (Hard variation)

require "utils.lua"
require "script_hangar.lua"

function createKraylorGunship()
    return CpuShip():setFaction("Kraylor"):setTemplate("Rockbreaker")
end

function createKraylorBeamship()
    return CpuShip():setFaction("Kraylor"):setTemplate("Spinebreaker")
end

function createKraylorDreadnought()
    return CpuShip():setFaction("Kraylor"):setTemplate("Deathbringer")
end

function createPlayerShip()
    return PlayerSpaceship():setTemplate("Piranha M5P"):setFaction("Human Navy")
end

function createWingman()
    return CpuShip():setFaction("Human Navy"):setTemplate("Nirvana R5A"):setScannedByFaction("Human Navy", true)
end

function init()
    allowNewPlayerShips(false)
    enemyList = {}
    timer = 0
    stationTakenTime = 0
    stationDestroyedTime = 0

    finishedTimer = 5
    finishedFlag = false
    instr1 = false
    instr2 = false
    instr3 = false
    instr4 = false
    boss = nil

    gu = 7500   -- grid unit for enemy spawns

    --player ship
    player = createPlayerShip():setCallSign("Rookie 1"):setPosition(gu/6, -gu/6):setHeading(90)
    player:setLongRangeRadarRange(30000)
    player:addReputationPoints(240.0)

    --wingman
    command = createWingman():setCallSign("April"):setPosition(-gu/6, gu/6):setHeading(90):orderIdle()

    --target station
    stationPosx = 2*gu
    stationPosy = 0
    station = SpaceStation():setTemplate('Small Station'):setCallSign("Maintainance Dock"):setRotation(random(0, 360)):setFaction("Kraylor"):setPosition(stationPosx,stationPosy)
    station.comms_data = {friendlyness = 80, surrender_hull_threshold = 80}


    --enemies
    enemyList[#enemyList+1] = createKraylorGunship():setPosition(2*gu, -4*gu):orderFlyTowards(stationPosx, stationPosy):setCallSign("Tau")
    enemyList[#enemyList+1] = createKraylorBeamship():setPosition(2*gu, 4*gu):orderFlyTowards(stationPosx, stationPosy):setCallSign("Sigma")
    enemyList[#enemyList+1] = createKraylorDreadnought():setPosition(8*gu, 0*gu):orderFlyTowards(stationPosx, stationPosy):setCallSign("Rho")

    --terrain
    createRandomAlongArc(Asteroid, 80, 2*gu, -4*gu, gu, 85, 340, 200)
    createRandomAlongArc(VisualAsteroid, 100, 2*gu, -4*gu, gu, 80, 360, 300)
    placeRandomAroundPoint(Nebula, 2, 2*gu, gu, 2*gu, 4*gu)

    if getScenarioVariation() == "Hard" then
        for _, enemy in ipairs(enemyList) do
            script_hangar.create(enemy, "Drone", 3)
        end
        script_hangar.create(station, "Drone", 1)
    end
end

function promoteToBoss()
    for _, enemy in ipairs(enemyList) do
        if enemy:isValid() then
            boss = enemy
        end
    end
    script_hangar.create(boss, "Drone", 6)
    boss:orderAttack(player)
    boss:setHullMax(boss:getHullMax() + 100)
    boss:setHull(boss:getHull() + 100)
    boss:setWeaponStorage("EMP", 1)
    boss:setWeaponTubeCount(boss:getWeaponTubeCount()+1)
    enemyList = {}
end

function commsInstr()
    if command:isValid() then
        if not instr1 and timer > 8.0 then
            instr1 = true
            command:sendCommsMessage(player, [[This is Commander Saberhagen onboard the Escort Cruiser April.

In this training mission you will practice more advanced tactics using an Piranha missile cruiser.

Use your jump drive and your missiles to ambush a Kraylor maintainance dock. Break the shields of the station and demand their surrender. We need resources and missiles from the maintainance dock, so do not destroy it.

Notice that your ship does not have any beam weapons.

Commander Saberhagen out.]])
        end
        if not instr2 and station:isValid() and stationTakenTime > 0 and timer - stationTakenTime > 2.0 then
            instr2 = true
            command:sendCommsMessage(player, [[This is Commander Saberhagen.

Good work capturing that station. Some Kraylor ships are approaching. Ambush them before they notice something is wrong.

Use probes and science scans to find them and jump into a good firing position. It you run into trouble, escape and attack from a different angle or refill your missiles at the maintainance dock.

Plan each attack run carefully - a jump gone wrong will cost you much time and energy.

If you need beam weapons, feel free ask the April for support.

Commander Saberhagen out.]])
        end
        if not instr2 and not station:isValid() then
            instr2 = true
            instr3 = true
            command:sendCommsMessage(player, [[This is Commander Saberhagen.

The maintainance dock was destroyed. There is no way for you now to restock your missiles.

Some Kraylor ships are approaching. Ambush them before they notice something is wrong.

Use probes and science scans to find them and jump into a good firing position. It you run into trouble, escape and attack from a different angle or refill your missiles at the maintainance dock.

Plan each attack run carefully - a jump gone wrong will cost you much time and energy.

If you need beam weapons, feel free ask the April for support.

Commander Saberhagen out.]])
        end
        if not instr3 and not station:isValid() and timer - stationDestroyedTime > 2.0 then
            instr3 = true
            command:sendCommsMessage(player, [[This is Commander Saberhagen.

The maintainance dock was destroyed. There is no way for you now to restock your missiles or to repair your hull.

You may still be able to destroy the incomming enemies with your existing resources. Good Luck.

Commander Saberhagen out.]])
        end
    end
    if not instr4 and boss ~= nil then
        instr4 = true
        command:sendCommsMessage(player, [[This is Commander Saberhagen.

Only one enemy ship is remaining. This one looks more challenging than the others.

Commander Saberhagen out.]])
    end
end


function finished(delta)
    finishedTimer = finishedTimer - delta
    if finishedTimer < 0 then
        victory("Human Navy")
    end
    if not finishedFlag then
        finishedFlag = true
        local bonusString = "has survived."
        if not station:isValid() then
            bonusString = "was destroyed."
        end
        globalMessage([[Mission Complete.
Your Time: ]]..formatTime(timer)..[[

Maintainance Dock ]]..bonusString)
    end
end


function update(delta)
    timer = timer + delta

    -- Count all surviving enemies.
    for i, enemy in ipairs(enemyList) do
        if not enemy:isValid() then
            table.remove(enemyList, i)
            -- Note: table.remove() inside iteration causes the next element to be skipped.
            -- This means in each update-cycle max half of the elements are removed.
            -- It does not matter here, since update is called regulary.
        end
    end

    -- story
    if #enemyList == 1 then
        promoteToBoss()
    elseif #enemyList == 0 and boss ~= nil and not boss:isValid() then
        finished(delta)
    end

    --station
    if station:isValid() and station:getFaction() == "Independent" then
        station:setFaction("Human Navy")
        stationTakenTime = timer
    end
    if not station:isValid() then
        stationDestroyedTime = timer
    end

    --util scripts
    script_hangar.update(delta)
    commsInstr()
end

