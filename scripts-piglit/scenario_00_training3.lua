-- Name: Training: Missile Cruiser
-- Type: Mission
-- Description: Advanced Training Course
---
--- Objective: Destroy all enemy ships in the area.
---
--- Description:
--- During this training your will learn to navigate and use a jumpdrive, destroy enemies with broadside missile tubes and you will coordinate your attack with an allied beam cruiser.
---
--- Your ship is a Piranha missile cruiser - a jump-driven cruiser with broadside missiles, but without beam weapons.
---
--- This is a short mission for players who prefer tactical combat.
-- Variation[Boss]: Skip to the boss battle.

-- secondary goal: Test and example for script_hangar (simple mothership)

require "utils.lua"
require "script_hangar.lua"

function init()
    allowNewPlayerShips(false)
    enemyList = {}
    timer = 0
    chapter1completed = false
    chapter2started = false
    chapter3started = false
    finishedTimer = 5
    finishedFlag = false
    bonusEscapes = false
    instr1 = false
    instr2 = false
    instr3 = false
    instr4 = false
    instr5 = false
    instr6 = false
    instr7 = false
    boss = nil

    --player ship
    pos0x, pos0y = 0, 0
    player = PlayerSpaceship():setTemplate("Piranha M5P"):setCallSign("Rookie 1"):setFaction("Human Navy"):setPosition(pos0x, pos0y):setHeading(90)
    rr = player:getLongRangeRadarRange()
    player:addReputationPoints(40.0)

    --first encounter within sensor range
    pos1x, pos1y = 0, -rr/2

    --second encounter out of sensor range
    local dir = irandom(60, 120)
    pos2x, pos2y = radialPosition(pos1x, pos1y, rr*2 + 4000, -dir)

    --thirs encounter within extended sensor range
    dir = irandom(60, 120)
    pos3x, pos3y = radialPosition(pos2x, pos2y, rr + irandom(2000, rr-5000), -dir)

    station = SpaceStation():setTemplate('Small Station'):setCallSign("Maintainance Dock"):setRotation(random(0, 360)):setFaction("Human Navy"):setPosition(-800, 1200)
    command = CpuShip():setTemplate("Nirvana R5M"):setCallSign("Escort 1"):setFaction("Human Navy"):setPosition(pos0x-1000, pos0y-1000):setHeading(90):orderIdle():setScannedByFaction("Human Navy", true)

    table.insert(enemyList, CpuShip():setFaction("Kraylor"):setTemplate("Equipment Freighter 3"):setCallSign("FTR Phi1"):setPosition(pos1x+1200, pos1y):setHeading(0):orderStandGround())
    table.insert(enemyList, CpuShip():setFaction("Kraylor"):setTemplate("Equipment Freighter 3"):setCallSign("FTR Phi2"):setPosition(pos1x-1200, pos1y):setHeading(0):orderStandGround())
    table.insert(enemyList, CpuShip():setFaction("Kraylor"):setTemplate("Equipment Freighter 3"):setCallSign("FTR Phi3"):setPosition(pos1x+1000, pos1y-1000):setHeading(0):orderStandGround())
    table.insert(enemyList, CpuShip():setFaction("Kraylor"):setTemplate("Equipment Freighter 3"):setCallSign("FTR Phi4"):setPosition(pos1x-1000, pos1y-1000):setHeading(0):orderStandGround())
    table.insert(enemyList, CpuShip():setFaction("Kraylor"):setTemplate("Equipment Freighter 3"):setCallSign("FTR Phi5"):setPosition(pos1x+800, pos1y-2500):setHeading(0):orderStandGround())
    table.insert(enemyList, CpuShip():setFaction("Kraylor"):setTemplate("Equipment Freighter 3"):setCallSign("FTR Phi6"):setPosition(pos1x-800, pos1y-2500):setHeading(0):orderStandGround())

    chi = CpuShip():setFaction("Kraylor"):setTemplate("Goods Freighter 3"):setCallSign("FTR Chi1"):setPosition(pos2x+1500, pos2y):setHeading(0):orderDefendLocation(pos2x, pos2y)
    table.insert(enemyList, chi)
    table.insert(enemyList, CpuShip():setFaction("Kraylor"):setTemplate("Goods Freighter 3"):setCallSign("FTR Chi2"):setPosition(pos2x-1500, pos2y):setHeading(180):orderDefendLocation(pos2x, pos2y))

    table.insert(enemyList, CpuShip():setFaction("Kraylor"):setTemplate("Fuel Freighter 3"):setCallSign("FTR Psi1"):setPosition(pos3x+1500, pos3y):setHeading(0):orderDefendLocation(pos3x, pos3y))
    table.insert(enemyList, CpuShip():setFaction("Kraylor"):setTemplate("Fuel Freighter 3"):setCallSign("FTR Psi2"):setPosition(pos3x-1500, pos3y):setHeading(180):orderDefendLocation(pos3x, pos3y))

    bonus = CpuShip():setFaction("Kraylor"):setTemplate("Personnel Jump Freighter 3"):setCallSign("FTR bonus"):setPosition(pos1x, pos1y-3000):setHeading(0):orderStandGround()
    if getScenarioVariation() == "Boss" then
        enemyList = {} -- clear
        spawnWave2()
        spawnBoss()
        instr1 = true
        instr2 = true
        instr3 = true
        instr4 = true
        instr5 = true
        instr6 = true
        instr7 = true
        instr8 = true
        local msg = "Forget about the training targets. A pack of drones are comming straight to us. Hunt them down. Then seek and destroy the mothership where these drones came from.", "White"
        command:sendCommsMessage(player, "This is Commander Saberhagen. "..msg.." Commander Saberhagen out.")
    end
end

function spawnWave2()
    chapter2started = true
    local posfx, posfy = radialPosition(player, rr+1000, 90)
    local k1 = CpuShip():setFaction("Kraylor"):setTemplate("Drone"):setCallSign("Kappa1")
    local k2 = CpuShip():setFaction("Kraylor"):setTemplate("Drone"):setCallSign("Kappa2")
    local k3 = CpuShip():setFaction("Kraylor"):setTemplate("Drone"):setCallSign("Kappa3")
    local k4 = CpuShip():setFaction("Kraylor"):setTemplate("Drone"):setCallSign("Kappa4")
    k1:setPosition(posfx, posfy):setHeading(-90)
    k2:setPosition(posfx-300, posfy+300):setHeading(-90)
    k3:setPosition(posfx-300, posfy-300):setHeading(-90)
    k4:setPosition(posfx-600, posfy-600):setHeading(-90)
    k1:orderAttack(player)
    k2:orderFlyFormation(k1, 300, -300)
    k3:orderFlyFormation(k1, 300, 300)
    k4:orderFlyFormation(k3, 300, 300)
    table.insert(enemyList, k1)
    table.insert(enemyList, k2)
    table.insert(enemyList, k3)
    table.insert(enemyList, k4)
end

function spawnBoss()
    chapter3started = true
    local posbx, posby = radialPosition(player, rr*1.5, irandom(80, 100))
    boss = CpuShip():setFaction("Kraylor"):setTemplate("Doombringer"):setCallSign("Omega"):setPosition(posbx, posby):setHeading(-90):orderDefendLocation(posbx, posby)
    script_hangar.create(boss, "Drone", 6)
end

function commsInstr()
    if not instr1 and timer > 8.0 then
        instr1 = true
        command:sendCommsMessage(player, [[This is Commander Saberhagen. In this training mission you will practice more advanced tactics using an Piranha missile cruiser. You will need to find and destroy the ships of a scattered enemy convoy, and use your jump drive and your missiles to take 'em by surprise. Notice that your ship does not have any beam weapons. I will keep you updated about the positions of the next enemy targets on a public broadcast channel; you can look at it on your comms log if you missed one. Commander Saberhagen out.]])
    end
    if not instr2 and timer > 10.0 then
        instr2 = true
        player:addToShipLog("[Cmd. Saberhagen] Your science should have detected the enemy convoy by now. Use your jump-drive to approach.", "White")
    end
    if not instr3 and distance(player, pos1x, pos1y) < 8000 then
        instr3 = true
        player:addToShipLog("[Cmd. Saberhagen] Escort 1 detected movement in sector "..chi:getSectorName()..". This aint a tutorial, so you should already know how to operate probes.", "White")
    end
    if not instr3b and #enemyList <= 4 then
        instr3b = true
        player:addToShipLog("[Cmd. Saberhagen] Did you notice that Escort 1 detected movement in sector "..chi:getSectorName()..". If not, check your comms log more carefully.", "White")
    end
    if not instr4 and distance(player, pos2x, pos2y) < 5000 then
        instr4 = true
        player:addToShipLog("[Cmd. Saberhagen] The next enemies must be somewhere within "..tostring(rr*2/1000).."u from your current position. Maybe your science detects some life-signs.", "White")
    end
    if not instr5 and chapter1completed then
        instr5 = true
        player:addToShipLog("[Cmd. Saberhagen] Good work. Now return to the Maintainance Dock.", "White")
    end
    if not instr6 and chapter2started then
        instr6 = true
        local msg = "Welcome back. Our sensors show some enemy fighters approaching. You may choose an appropriate countermeassure. Remember, Escort 1 can be of great assistance against fighters, but it will not interfere without beeing orders to do so."
        if command:isValid() then
            command:sendCommsMessage(player, "This is Commander Saberhagen. "..msg.." Commander Saberhagen out.")
        else
            player:addToShipLog("[Cmd. Saberhagen] "..msg, "White")
        end
    end
    if not instr7 and chapter3started then
        instr7 = true
        local bonusString = "escaped."
        if not bonus:isValid() then
            bonusString = "destroyed."
        end
        globalMessage("Mission Complete. Your Time: "..tostring(math.floor(timer)).."s. Bonus target "..bonusString)
        local msg = "The official part of this training ends here. You have done quite well. But if you want to challenge a superior enemy, seek and destroy the mothership where these drones came from.", "White"
        if command:isValid() then
            command:sendCommsMessage(player, "This is Commander Saberhagen. "..msg.." Commander Saberhagen out.")
        else
            player:addToShipLog("[Cmd. Saberhagen] "..msg, "White")
        end
    end
    if not instr8 and boss ~= nil and distance(player, boss) < 10000 then
        instr8 = true
        globalMessage("Kobayashi-Maru mode activated")
    end
end


function finished(delta)
    finishedTimer = finishedTimer - delta
    if finishedTimer < 0 then
        victory("Human Navy")
    end
    if not finishedFlag then
        finishedFlag = true
        globalMessage("Mission Complete.")
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
        if not chapter1completed then
            chapter1completed = true
        elseif not chapter2started then
            if distance(player, station) < 5000 then
                spawnWave2()
            end
        elseif not chapter3started then
            spawnBoss()
        elseif boss ~= nil and not boss:isValid() then
            finished(delta)
        end
    end

    if bonus:isValid() and not bonusEscapes then
        if distance(player, bonus) < 10000.0 then
            bonusEscapes = true
            bonus:orderFlyTowardsBlind(radialPosition(bonus, 100000, irandom(0, 360)))
        end
    end

    script_hangar.update(delta)
    commsInstr()

end

