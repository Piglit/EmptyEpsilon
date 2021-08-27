-- Name: Training: Battlecruiser
-- Type: Mission
-- Description: Close Combat Training Course
---
--- Objective: Defend your mothership against enemy fighters and destroy the enemy carrier.
---
--- Description:
--- In this training you will face different armed oppenents that you must destroy one by one. The difficulty will start low and will increase slowly with every destroyed enemy squadron.
---
--- Your ship is a warp-driven Hathcock Battle Cruiser - a cruiser with great beam power but few missiles.
---
--- This is a short mission for players who prefer close combat.
-- Variation[Easy]: Each enemy wave consists of only one single ship. Intedned for inexperienced players.
-- Variation[Only Homings]: Your ship has more homing missiles, but no other ordnance.
-- Variation[Hard]: More enemies, and they are present at the beginning of the scenario.

-- secondary design goal: Test and example for utils_formations

require "utils.lua"
require "utils_formations.lua"

--- Ship creation functions

function createExuariStrikerSquad(amount, posx, posy)
    local enemyList = formations:spawn("Dash", amount, posx, posy, "Exuari", "factional", "Alpha-")
    for _,ship in ipairs(enemyList) do
        ship:setWarpDrive(false)
    end
    return enemyList
end

function createExuariFighterSquad(amount, posx, posy)
    local enemyList = formations:spawn("Dagger", amount, posx, posy, "Exuari", "factional", "Beta-")
    return enemyList
end

function createExuariBomberSquad(amount, posx, posy)
    local enemyList = formations:spawn("Gunner", amount, posx, posy, "Exuari", "factional", "Gamma-")
    return enemyList
end

function createExuariArtillerySquad(amount, posx, posy)
    local enemyList = formations:spawn("Ranger", amount, posx, posy, "Exuari", "factional", "Delta-")
    return enemyList
end

function createExuariDefense()
    return CpuShip():setFaction("Exuari"):setTemplate("Warden")
end

function createExuariMothership()
    return CpuShip():setFaction("Exuari"):setTemplate("Ryder")
end

function createHumanMothership()
    local ship = CpuShip():setFaction("Human Navy"):setTemplate("Jump Carrier"):setScannedByFaction("Human Navy", true)
    ship:setTypeName("Steamroller"):setJumpDrive(false):setJumpDrive(false)
    ship:setHullMax(200):setHull(200):setShieldsMax(100,100):setShields(100,100)
    ship:setWeaponTubeCount(2):setTubeLoadTime(0, 10.0):setTubeLoadTime(1, 10.0):setWeaponStorage("HVLI", 20)
    ship:setBeamWeapon(0, 90, -10, 2000, 8, 11):setBeamWeapon(1, 90, 10, 2000, 8, 11)
    return ship
end

function createPlayerShip()
    local ship = PlayerSpaceship():setTemplate("Hathcock"):setFaction("Human Navy")
    ship:setJumpDrive(false):setWarpDrive(true)
    if getScenarioVariation() == "Only Homings" then
        ship:setWeaponStorageMax("Nuke", 0):setWeaponStorage("Nuke", 0)
        ship:setWeaponStorageMax("Mine", 0):setWeaponStorage("Mine", 0)
        ship:setWeaponStorageMax("EMP", 0):setWeaponStorage("EMP", 0)
        ship:setWeaponStorageMax("HVLI", 0):setWeaponStorage("HVLI", 0)
        ship:setWeaponStorageMax("Homing", 16):setWeaponStorage("Homing", 16)
    end
    return ship
end

function init()
    gu = 5000   -- grid unit for enemy spawns

    -- boss and guard
    bossposx = 10*gu
    bossposy = 0
    boss = createExuariMothership():setCallSign("Omega"):setPosition(bossposx, bossposy):orderDefendLocation(bossposx, bossposy)
    guard = createExuariDefense():setCallSign("Omicron"):setPosition(bossposx, bossposy+1000):orderDefendTarget(boss)

    -- player and ally
    allowNewPlayerShips(false)
    player = createPlayerShip()
    player:setCallSign("Rookie 1"):setPosition(gu/4, -gu/4):setHeading(90):setLongRangeRadarRange(5*gu):addReputationPoints(140.0)
    dread = createHumanMothership():setCallSign("Liberator"):setPosition(-gu/4, gu/4):setHeading(90):orderAttack(boss)
    dreadSpeed = dread:getImpulseMaxSpeed()
 
    -- terrain
    createRandomAlongArc(Asteroid, 100, 2*gu, -1*gu, gu, 60, 220, 200)
    createRandomAlongArc(VisualAsteroid, 100, 2*gu, -1*gu, gu, 400, 270, 400)
    placeRandomAroundPoint(Nebula, 4, gu, 2*gu, 3.5*gu, 1.5*gu)
    placeRandomAroundPoint(Nebula, 4, gu, 3*gu, 6*gu, -2.5*gu)
    createRandomAlongArc(Asteroid, 80, 7*gu, 2*gu, 1.5*gu, 180, 270, 400)
    createRandomAlongArc(VisualAsteroid, 100, 7*gu, 2*gu, 1.5*gu, 180, 270, 1000)
    createObjectsOnLine(8*gu, -gu, 8*gu, gu, 1000, Mine, 2)

    -- scenario script details
    enemyWaveIndex = 0
    enemyList = {}
    dreadNextPosx = 0
    dreadProgress = 0

    instr1 = false
    timer = 0
    finishedTimer = 5
    finishedFlag = false

    -- start action
    spwanNextWave()
    if getScenarioVariation() == "Hard" then
        spwanNextWave()
        spwanNextWave()
        spwanNextWave()
        spwanNextWave()
    end
    instructions()
    dread:orderFlyTowardsBlind(dreadNextPosx, dreadPosy)
end

function spwanNextWave()
    -- waves are:
    -- 1. slow Striker
    -- 2. Fighter Squad (attacking player)
    -- 3. Bomber Squad
    -- 4. Artillery
    -- 5. Boss (already present)

    enemyWaveIndex = enemyWaveIndex + 1

    local amount
    if getScenarioVariation() == "Hard" then
        amount = enemyWaveIndex * 2
    elseif getScenarioVariation() == "Easy" then
        amount = 1
    else
        amount = enemyWaveIndex
    end

    -- spwan and determine squad leaders target
    if enemyWaveIndex == 1 then
        enemyList = createExuariStrikerSquad(amount, 2*gu, -1*gu)
        enemyList[1]:orderRoaming()
    elseif enemyWaveIndex == 2 then
        enemyList = createExuariFighterSquad(amount, 3.5*gu, 1.5*gu)
        enemyList[1]:orderAttack(player)
    elseif enemyWaveIndex == 3 then
        enemyList = createExuariBomberSquad(amount, 6*gu, -2.5*gu)
        enemyList[1]:orderAttack(dread)
    elseif enemyWaveIndex == 4 then
        enemyList = createExuariArtillerySquad(amount, 7*gu, 2*gu)
        enemyList[1]:orderAttack(dread)
    elseif enemyWaveIndex == 5 then
        -- only boss may be left
        enemyList = {boss, guard}
        if dread:isValid() then
            -- restore full fire power, in case some was fired upon fighters
            dread:setWeaponStorage("HVLI", 20) 
        end
    end

    -- half of each squad attack the player
    -- but only if the wave is big enough; depends on difficulty
    -- in exuari sqads, fighter with index 4 follows index 3.
    -- Index higher than 5 follow index 5.
    if dread:isValid() then
        if #enemyList > 2 then
            enemyList[math.ceil(#enemyList/2)+1]:orderAttack(player)
        end
    end

    dread:setImpulseMaxSpeed(dreadSpeed)
    return true
end

function instructions()
    if dread:isValid() and not instr1 then
        if getScenarioVariation() == "Hard" then
            instr1 = true
            dread:sendCommsMessage(player, [[This is Commander Saberhagen onboard the Liberator.

Your goal is to keep yourself and the Liberator alive until the enemy carrier and it's guards are destroyed. You chose the hard mode, so prepare for some resistance.

Commander Saberhagen out.]])
        elseif enemyWaveIndex == 1 then
            dread:sendCommsMessage(player, [[This is Commander Saberhagen onboard the Liberator.

In this combat training you will practise your abilities with a Hathcock battlecruiser.
The Hathcock is a ship for those who seek close combat. Rely on her beams and the high turn rate.

The Liberator is pursuing an Exuari carrier ship in this sector.
Your goal is to keep yourself and the Liberator alive until the carrier and it's guards are destroyed.

We will face several small groups of enemies that will target you or the Liberator.
Each group will be more difficult then the previous one.

Commander Saberhagen out.]])
        elseif enemyWaveIndex == 2 and dread:isValid() then
            dread:sendCommsMessage(player, [[This is Commander Saberhagen.

You can dock at the Liberator if you need to restore your energy or if you need repairs.

If you run into more trouble than you can handle, feel free to contact us for help.

Commander Saberhagen out.
]])

        elseif enemyWaveIndex == 3 then
            dread:sendCommsMessage(player, [[This is Commander Saberhagen.

Remember to use all of your capabilities to your advantage: warp drive, hacking, shield and beam frequencies, the database, energy management etc.

Commander Saberhagen out.
]])
        elseif enemyWaveIndex == 4 then
            dread:sendCommsMessage(player, [[This is Commander Saberhagen.

We need you to find a way for the Liberator to get across that mine-field ahead.

Commander Saberhagen out.
]])
        elseif enemyWaveIndex == 5 then
            instr1 = true
            dread:sendCommsMessage(player, [[This is Commander Saberhagen.

The final battle lies ahead of us. Try to distract the enemy guard frigate while the Liberator attacks the carrier.

Commander Saberhagen out.
]])

        end
    end
end

function update_dread(delta)
    if dread:isValid() then
        local dreadPosx, dreadPosy = dread:getPosition()
        if dreadPosx > dreadNextPosx then
            -- target reached
            dreadProgress = dreadProgress + 1
            dreadNextPosx = dreadProgress * gu
            if dreadProgress > 8 or enemyWaveIndex >= 5 then
                -- fight boss
                if boss:isValid() then
                    dread:orderAttack(boss)
                else
                    dread:orderRoaming()
                end
                dread:setImpulseMaxSpeed(dreadSpeed)
            else
                -- still in waves
                dread:orderFlyTowardsBlind(dreadNextPosx, dreadPosy)
                if enemyWaveIndex*2 > dreadProgress then
                    dread:setImpulseMaxSpeed(dreadSpeed)
                elseif enemyWaveIndex*2 == dreadProgress then
                    dread:setImpulseMaxSpeed(dreadSpeed/2)
                else
                    dread:setImpulseMaxSpeed(dreadSpeed/4)
                end
            end
        end
    end
end

-- thoughts:
-- D ->-> C ->-> C ...
-- P x E
-- progress story: when enemies are defeated, progress story




function finished(delta)
    finishedTimer = finishedTimer - delta
    if finishedTimer < 0 then
        victory("Human Navy")
    end
    if finishedFlag == false then
        finishedFlag = true
        local bonusString = "has survived."
        if not dread:isValid() then
            bonusString = "was destroyed."
        end
        globalMessage([[Mission Complete.
Your Time: ]]..formatTime(timer)..[[

Liberator ]]..bonusString..[[




If you feel ready for combat and you liked the ship, play 'the mining outpost'.
If you want to try another ship, play another training mission.]])
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

    if #enemyList == 0 then
        spwanNextWave() 
        instructions()
    end

    -- Adjust mothership speed, depending on player progress
    update_dread(delta)

    if enemyWaveIndex >= 5 then
        if #enemyList == 0 then
            finished(delta)
        end
    end
end

