-- Name: Training: Battlecruiser
-- Type: Mission
-- Description: Combat Training Course
---
--- Objective: Destroy all enemy ships in the area.
---
--- Description:
--- In this training you will face different armed oppenents that you must destroy one by one. The difficulty will start low and will increase slowly with every destroyed enemy.
---
--- Your ship is a Hathcock Battle Cruiser - a warp-driven cruiser with great beam power and few missiles.
---
--- This is a short mission for inexperienced players who prefer close combat.
-- Variation[Test Formations]: All enemies (and more stonger ones) are present at the beginning of the scenario. This is for testing formations.

-- secondary design goal: Test and example for script_formation


require "utils.lua"
require "script_formation.lua"

function init()
    allowNewPlayerShips(false)

    player = PlayerSpaceship():setTemplate("Hathcock"):setCallSign("Rookie 1"):setFaction("Human Navy"):setPosition(0, 0):setHeading(90)
    rr = player:getLongRangeRadarRange()
    player:addReputationPoints(140.0)

    enemies = {
        "Yellow Hornet",
        "Blue Lindworm",
        "Red Adder MK4",
        "Phobos M3",
        "Nirvana Thunder Child",
        "Solar Storm",
    }
    spawnPositions = {
        {rr, 0},
        {0, rr},
        {-rr, 0},
        {0, -rr},
        {rr*0.7, rr*0.7},
        {-rr*0.7, rr*0.7},
    }
    enemiesNames = {
        "Alpha-",
        "Beta-",
        "Gamma-",
        "Rho-",
        "Sigma-",
        "Tau-",
    }

    enemiesIndex = 1
    enemyList = {}
    
    instr1 = false
    timer = 0
    finishedTimer = 5
    finishedFlag = false

    station = SpaceStation():setTemplate('Small Station'):setCallSign("Maintainance Dock"):setRotation(random(0, 360)):setFaction("Human Navy"):setPosition(-800, 1200)
    wingman = CpuShip():setTemplate("Nirvana R5M"):setCallSign("Wingman"):setFaction("Human Navy"):setPosition(-800, -1700):setHeading(250):setScannedByFaction("Human Navy", true):orderDefendTarget(station)
    
    bonus = CpuShip():setTemplate("Flavia Express"):setCallSign("Bonus"):setFaction("Criminals"):setShieldsMax(200, 200):setShields(200, 200):setPosition(rr+2000, -rr-2000):setHeading(225):orderFlyTowardsBlind(-rr, rr)
    
    createObjectsOnLine(rr/2, rr/4, rr/4, rr/2, 1000, Mine, 2)
    createRandomAlongArc(Asteroid, 100, 0, 0, rr-2000, 180, 270, 1000)
    createRandomAlongArc(VisualAsteroid, 100, 0, 0, rr-2000, 180, 270, 1000)
    placeRandomAroundPoint(Nebula, 4, 10000, 10000, rr*0.75, -rr*0.75)
    
    spwanNextWave()
    instructions()
end

function spwanNextWave()
    if enemiesIndex > #enemies then
        return false
    end
    
    local enemyTempl = enemies[enemiesIndex]
    local name = enemiesNames[enemiesIndex]
    local pos = spawnPositions[enemiesIndex]
    local posx, posy = player:getPosition()
    posx = posx + pos[1]
    posy = posy + pos[2]

    local amount
    if getScenarioVariation() == "Test Formations" then
        amount = enemiesIndex + 1
    else
        amount = enemiesIndex % 4 + 1
    end
    enemyList = script_formation.spawnFormation(enemyTempl, amount, posx, posy, "Criminals", name)
    enemiesIndex = enemiesIndex + 1
    return true
end
    
function instructions()
    if wingman:isValid() then
        if enemiesIndex == 2 then
            wingman:sendCommsMessage(player, [[This is Commander Saberhagen.

In this combat training you will practise your abilities with a Hathcock battlecruiser.
The Hathcock is a ship for those who seek close combat. Rely on her beams and the high turn rate.

You will fight against small groups of enemies.
Whenever you destroy an opponent, the next one will appear just in sensor range.
Each group will be more difficult then the previous one.

Engage with your warp drive, when you are ready.

Commander Saberhagen out.]])
        elseif enemiesIndex == 4 and station:isValid() then
            wingman:sendCommsMessage(player, [[This is Commander Saberhagen.

Do not forget to restore your energy at the Maintainance Dock.
If you need repairs, that station will also be of some help.

You may have noticed that every destroyed energy raises your reputation. When your reputation is high enough, make sure to call for reinforcements at the Maintainance Dock.

The Human Navy is only stong when working together!

Commander Saberhagen out.
]])
        elseif enemiesIndex == 5 then
            wingman:sendCommsMessage(player, [[This is Commander Saberhagen.

Remember to use all of your capabilities to your advantage: Hacking, shield and beam frequencies, the database, energy management, your wingman etc.

Commander Saberhagen out.
]])
        end
    end
end


function finished(delta)
    if getScenarioVariation() == "Test Formations" then
        return
    end
    finishedTimer = finishedTimer - delta
    if finishedTimer < 0 then
        victory("Human Navy")
    end
    if finishedFlag == false then
        finishedFlag = true
        local bonusString = "escaped."
        if not bonus:isValid() then
            bonusString = "destroyed."
        end
        globalMessage([[Mission Complete.
Your Time: ]]..formatTime(timer)..[[
Bonus target ]]..bonusString..[[

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

    if #enemyList == 0 or getScenarioVariation() == "Test Formations" then
        if not spwanNextWave() then
            finished(delta)
        else
            instructions()
        end
    end
    
    if bonusSpawned and bonus:isValid() and distance(bonus, -rr, rr) < 100 then
        bonus:setWarpDrive(true)
        bonus:orderFlyTowardsBlind(-1000*rr, 1000*rr)
    end
end

