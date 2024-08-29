-- Name: Basic Training Course
-- Type: Training
-- Short Description: A short training scenario for inexperienced crews.
-- Objective: Destroy all enemy ships in the area.
-- Duration: 15 minutes
-- Difficulty: Very easy
-- Description: Coordinate the actions of your crew to destoy an undefended Exuari training ground.
--- 
--- Your ship is a Phobos light cruiser - the most common vessel in the navy.


require("utils.lua")    -- formatTime
require("luax.lua")     -- table.filter
require("plots/campaign.lua")

--- Ship creation functions
function createExuariWeakInterceptor()
    return CpuShip():setFaction("Exuari"):setTemplate("Dagger"):setBeamWeapon(0, 0, 0, 0, 0.1, 0.1)
end

function createExuariWeakBomber()
    return CpuShip():setFaction("Exuari"):setTemplate("Gunner"):setWeaponTubeCount(0):setWeaponStorageMax("HVLI", 0):setWeaponStorage("HVLI", 0):setBeamWeapon(0, 0, 0, 0, 0.1, 0.1)
end

function createExuariInterceptor()
    return CpuShip():setFaction("Exuari"):setTemplate("Dagger")
end

function createExuariBomber()
    return CpuShip():setFaction("Exuari"):setTemplate("Gunner"):setBeamWeapon(0, 0, 0, 0, 0.1, 0.1)
end

function createExuariTransport()
    return CpuShip():setFaction("Exuari"):setTemplate("Personnel Freighter 1"):setTypeName("Exuari transport")
end

function createExuariFreighter()
    return CpuShip():setFaction("Exuari"):setTemplate("Goods Freighter 5"):setTypeName("Exuari freighter")
end

function createExuariShuttle()
    return CpuShip():setFaction("Exuari"):setTemplate("Racer"):setTypeName("Exuari shuttle"):setWarpDrive(false):setBeamWeapon(0, 0, 355, 0, 0.1, 0.1):setBeamWeapon(1, 0, 355, 0, 0.1, 0.1)
end


-- init
function init()
    enemyList = {}
    finishedTimer = 5
    finishedFlag = false
    instr1 = false
    assist_timer = 60

    bonusAvail = true
    bonusCaptured = false 
    bonus = createExuariShuttle():setCallSign("bonus"):setPosition(-2341, -17052):orderFlyTowardsBlind(-80000, -40000):setHeading(-60)
	bonus:onDestruction(bonusDestroyed)

    table.insert(enemyList, createExuariWeakInterceptor():setCallSign("Fgt1"):setPosition(2341, -5191):setHeading(60))
    table.insert(enemyList, createExuariWeakInterceptor():setCallSign("Fgt2"):setPosition(2933, -6555):setHeading(60))
    table.insert(enemyList, createExuariWeakBomber():setCallSign("B2"):setPosition(-8866, -9002):orderDefendLocation(-9798, -9869):setHeading(60))
    table.insert(enemyList, createExuariWeakBomber():setCallSign("B1"):setPosition(-12407, -9067):orderDefendLocation(-11433, -9887):setHeading(60))
    table.insert(enemyList, createExuariInterceptor():setCallSign("A1"):setPosition(-24113, -12830):orderDefendLocation(-25570, -13055):setHeading(60))
    table.insert(enemyList, createExuariInterceptor():setCallSign("A2"):setPosition(-26813, -12025):orderDefendLocation(-26425, -13447):setHeading(60))
    table.insert(enemyList, createExuariBomber():setCallSign("BR2"):setPosition(-39545, -16424):orderStandGround():setHeading(60))
    table.insert(enemyList, createExuariBomber():setCallSign("BR1"):setPosition(-41365, -15584):orderStandGround():setHeading(60))
    table.insert(enemyList, createExuariTransport():setCallSign("Omega1"):setPosition(-34120, -6629):setHeading(60))
    table.insert(enemyList, createExuariTransport():setCallSign("Omega2"):setPosition(-31698, -4868):setHeading(60))
    table.insert(enemyList, createExuariTransport():setCallSign("Omega3"):setPosition(-29270, -2853):setHeading(60))
    table.insert(enemyList, createExuariFreighter():setCallSign("FTR1"):setPosition(2787, -1822):orderFlyTowards(-42873, -13865):setHeading(-60))

    enemyCountStart = #enemyList
    player = PlayerSpaceship():setTemplate("Phobos M3P"):setPosition(18, -48):setJumpDrive(false):setLongRangeRadarRange(20000)
    command = CpuShip():setFaction("Human Navy"):setTemplate("Phobos M3"):setCallSign("Command"):setPosition(-100000, -100000):orderIdle()
	
	campaign:requestReputation()
	campaign:initScore()
end

function commsInstr()
    if not instr1 and player:isValid() and getScenarioTime() > 8.0 then
        instr1 = true
        command:sendCommsMessage(player, _("goal-incCall", [[This is Commander Saberhagen.

In this training mission you will practice the basic controls of a Phobos light cruiser.
Since this is not a tutorial, you will be on your own to decide how to destroy all enemy targets in an Exuari training ground.
There will be not much resistance, so you can try different approaches and tactics savely.

Here's your chance to beat up some helpless opponents.
Commander Saberhagen out.]]))
    end
end

function needHelp(delta)
    if not player:isValid() then
        return
    end
    if player:areEnemiesInRange(20000) then
        assist_timer = 60
    else
        assist_timer = assist_timer - delta
        if assist_timer < 0 then
            assist_timer = 120
            local nearest_dist = 99999999
            local nearest_enemy = nil
            for _,enemy in ipairs(enemyList) do
                if enemy:isValid() then
                    local dist = distance(enemy, player)
                    if dist < nearest_dist then
                        nearest_dist = dist
                        nearest_enemy = enemy
                    end
                end
            end
            if nearest_enemy ~= nil then
                command:sendCommsMessage(player, _("goal-incCall", [[This is Commander Saberhagen.
According to our sensors there are still enemies in sector ]]) .. nearest_enemy:getSectorName())
            end
        end
    end
end

function finished(delta)
    finishedTimer = finishedTimer - delta
	local timer = getScenarioTime()
    if finishedTimer < 0 then
        victory("Human Navy")
    end
    if finishedFlag == false then
        finishedFlag = true
		campaign:victoryScore()
        local bonusString = _("msgMainscreen-bonusTarget", "escaped.")
        if not bonus:isValid() then
            bonusString = _("msgMainscreen-bonusTarget", "destroyed.")
			if bonusCaptured then
				bonusString = bonusString .. _("msgMainscreen-bonusTarget"," Artifact captured.")
			else
				bonusString = bonusString .. _("msgMainscreen-bonusTarget"," Artifact was destroyed.")
			end
        end
        globalMessage(string.format(_("msgMainscreen", [[Mission Complete.
Your Time: %s
Bonus target %s]]), formatTime(timer), bonusString))
    end
end

function bonusDestroyed(bonus, _)
	local x,y = bonus:getPosition()
	local art = campaign:placeArtifact(x,y, "Exuari Warp Drive", "This warp drive was fitted in an Exuari ship. The drive was powering up when the ship was destroyed, which would have escaped if it weren't destroyed in time. Exuari sometimes use warp drives to ambush their enemies or to escape quickly with valuable cargo.", function(art, pl, collected)
		bonusAvail = false
		bonusCaptured = collected
	end)
	art:setScanningParameters(2, 1)
end

function update(delta)
    local enemyCount = campaign:progressEnemyCount(enemyList, true) -- true: remove all invalid objects enemies from the list

    if enemyCount == 0 then
        if not bonusAvail then
            finished(delta)
        else
            if not bonus:isValid() then
                finished(delta)
            end
        end
    end

    if bonus:isValid() then
        local x, y = bonus:getPosition()
        if x < -40000 then
            bonus:setWarpDrive(true)
        end
        if x < -50000 then
            bonusAvail = false
        end
    end

    commsInstr()
    needHelp(delta)
end

