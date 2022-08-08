-- Name: Training: Close Combat
-- Type: Mission
-- Description: Combat Training Course
---
--- Objective: Defend your mothership against enemy fighters and destroy the enemy carrier.
---
--- Description:
--- In this training you will face different armed oppenents that you must destroy one by one. The difficulty will start low and will increase slowly with every destroyed enemy.
---
--- Your ship is a Hathcock Battle Cruiser - a warp-driven cruiser with great beam power and few missiles.
---
--- This is a short mission for inexperienced players who prefer close combat.
-- Variation[Hard]: All enemies (and more of the stonger ones) are present at the beginning of the scenario.

-- secondary design goal: Test and example for script_formation (Hard variation)


require "utils.lua"
require "script_formation.lua"

--- Ship creation functions
function createExuariFighterSquad(amount, posx, posy)
    local enemyList = script_formation.spawnFormation("Dagger", amount, posx, posy, "Exuari", "Alpha-")
    return enemyList
end

function createExuariInterceptorSquad(amount, posx, posy)
    local enemyList = script_formation.spawnFormation("Blade", amount, posx, posy, "Exuari", "Beta-")
    return enemyList
end

function createExuariBomberSquad(amount, posx, posy)
    local enemyList = script_formation.spawnFormation("Gunner", amount, posx, posy, "Exuari", "Gamma-")
    return enemyList
end

function createExuariStrikerSquad(amount, posx, posy)
    local enemyList = script_formation.spawnFormation("Strike", amount, posx, posy, "Exuari", "Delta-")
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
	return PlayerSpaceship():setTemplate("Hathcock"):setFaction("Human Navy")
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
 
    -- terrain
    createRandomAlongArc(Asteroid, 100, 2*gu, -1*gu, gu, 60, 220, 200)
    createRandomAlongArc(VisualAsteroid, 100, 2*gu, -1*gu, gu, 400, 270, 400)
    placeRandomAroundPoint(Nebula, 4, gu, 2*gu, 3.5*gu, 1.5*gu)
    placeRandomAroundPoint(Nebula, 4, gu, 3*gu, 6*gu, -2.5*gu)
    createRandomAlongArc(Asteroid, 80, 7*gu, 2*gu, 1.5*gu, 180, 270, 400)
    createRandomAlongArc(VisualAsteroid, 100, 7*gu, 2*gu, 1.5*gu, 180, 270, 1000)
    createObjectsOnLine(8*gu, -gu, 8*gu, gu, 1000, Mine, 2)

    -- scenario script details
    enemyWaveIndex = 1
    enemyList = {}
    nextWaveDreadPos = 0
    plot = "waves" 

    instr1 = false
    timer = 0
    finishedTimer = 5
    finishedFlag = false

    -- start action
    spwanNextWave()
    instructions()
end

function spwanNextWave()

    local amount
    if getScenarioVariation() == "Hard" then
        amount = enemyWaveIndex
    else
        amount = enemyWaveIndex % 4 + 1
    end

    if enemyWaveIndex == 1 then
        enemyList = createExuariFighterSquad(amount, 2*gu, -1*gu)
        enemyList[1]:orderRoaming()
    elseif enemyWaveIndex == 2 then
        enemyList = createExuariInterceptorSquad(amount, 3.5*gu, 1.5*gu)
        enemyList[1]:orderAttack(player)
    elseif enemyWaveIndex == 3 then
        enemyList = createExuariBomberSquad(amount, 6*gu, -2.5*gu)
        enemyList[1]:orderAttack(dread)
    elseif enemyWaveIndex == 4 then
        enemyList = createExuariStrikerSquad(amount, 7*gu, 2*gu)
        enemyList[1]:orderAttack(dread)
        if getScenarioVariation() == "Hard" then
            enemyList[2]:orderAttack(player)
        end
    elseif enemyWaveIndex == 5 then
        -- only boss may be left
        enemyList = {boss, guard}
        if dread:isValid() then
            dread:setWeaponStorage("HVLI", 20)  -- restore full fire power, in case some was fired upon fighters
        end
    elseif enemyWaveIndex >= 6 then
        if #enemyList == 0 then
            return false
        else
            return true
        end
    end

    enemyWaveIndex = enemyWaveIndex + 1
    nextWaveDreadPos = nextWaveDreadPos + 2*gu
    dread:orderAttack(boss)
    return true
end

function instructions()
    if dread:isValid() and not instr1 then
        if getScenarioVariation() == "Hard" then
            instr1 = true
            dread:sendCommsMessage(player, [[This is Commander Saberhagen onboard the Liberator.

Your goal is to keep yourself and the Liberator alive until the enemy carrier and it's guards are destroyed. You chose the hard mode, so prepare for some resistance.

Commander Saberhagen out.]])
        elseif enemyWaveIndex == 2 then
            dread:sendCommsMessage(player, [[This is Commander Saberhagen onboard the Liberator.

In this combat training you will practise your abilities with a Hathcock battlecruiser.
The Hathcock is a ship for those who seek close combat. Rely on her beams and the high turn rate.

The Liberator is pursuing an Exuari carrier ship in this sector.
Your goal is to keep yourself and the Liberator alive until the carrier and it's guards are destroyed.

We will face several small groups of enemies that will target you or the Liberator.
Each group will be more difficult then the previous one.

If you need any kind of help or strategic hints, feel free to contact us.

Commander Saberhagen out.]])
        elseif enemyWaveIndex == 3 and dread:isValid() then
            dread:sendCommsMessage(player, [[This is Commander Saberhagen.

You can dock at the Liberator if you need to restore your energy or if you need repairs.

If you run into more trouble than you can handle, feel free to contact us for help.

Commander Saberhagen out.
]])

        elseif enemyWaveIndex == 4 then
            dread:sendCommsMessage(player, [[This is Commander Saberhagen.

Remember to use all of your capabilities to your advantage: warp drive, hacking, shield and beam frequencies, the database, energy management etc.

If you need more information on how to use those systems, contact us.

Commander Saberhagen out.
]])
        elseif enemyWaveIndex == 5 then
            dread:sendCommsMessage(player, [[This is Commander Saberhagen.

We need you to find a way for the Liberator to get across that mine-field ahead.

Commander Saberhagen out.
]])
        elseif enemyWaveIndex == 6 then
            instr1 = true
            dread:sendCommsMessage(player, [[This is Commander Saberhagen.

The final battle lies ahead of us. Try to distract the enemy guard frigate while the Liberator attacks the carrier.

Commander Saberhagen out.
]])

        end

    end
end


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

    continue = false
    if dread:isValid() then
        dreadPosx, dreadPosy = dread:getPosition()
        if dreadPosx > nextWaveDreadPos then
            continue = true
        end
    end
    if #enemyList == 0 then
        continue = true
    end
    if getScenarioVariation() == "Hard" then
        continue = true
    end

    if continue then
        if not spwanNextWave() then
            finished(delta)
        else
            instructions()
        end
    end
end

function mainMenu()
	if comms_target.comms_data == nil then
		comms_target.comms_data = {friendlyness = random(0.0, 100.0)}
	end
	-- comms_data is used globally
	comms_data = comms_target.comms_data
	
	if player:isFriendly(comms_target) then
		return commsCommand(comms_data)
	end
	return false
end

function commsCommand(comms_data)
	setCommsMessage("This is Commander Saberhagen onboard the Liberator, how can we assist?")
	addCommsReply("Go to a waypoint", function()
		if player:getWaypointCount() == 0 then
			setCommsMessage("No waypoints set. Please set a waypoint first.")
			addCommsReply("Back", mainMenu)
		else
			setCommsMessage("Which waypoint should we approach?")
			for n=1,player:getWaypointCount() do
				addCommsReply("Defend WP" .. n, function()
					comms_target:orderDefendLocation(player:getWaypoint(n))
					setCommsMessage("We are heading towards WP" .. n ..".")
					addCommsReply("Back", mainMenu)
				end)
			end
		end
	end)
	addCommsReply("Defend us", function()
		setCommsMessage("Heading toward you to assist.")
		comms_target:orderDefendTarget(player)
		addCommsReply("Back", mainMenu)
	end)
	if boss:isValid() then
		addCommsReply("Resume your previous mission", function()
			setCommsMessage("Setting course to attack the enemy carrier.")
			comms_target:orderAttack(boss)
			addCommsReply("Back", mainMenu)
		end)
	end
	addCommsReply("Report status", function()
		local msg = "Hull: " .. math.floor(comms_target:getHull() / comms_target:getHullMax() * 100) .. "%\n"
		local shields = comms_target:getShieldCount()
		if shields == 1 then
			msg = msg .. "Shield: " .. math.floor(comms_target:getShieldLevel(0) / comms_target:getShieldMax(0) * 100) .. "%\n"
		elseif shields == 2 then
			msg = msg .. "Front Shield: " .. math.floor(comms_target:getShieldLevel(0) / comms_target:getShieldMax(0) * 100) .. "%\n"
			msg = msg .. "Rear Shield: " .. math.floor(comms_target:getShieldLevel(1) / comms_target:getShieldMax(1) * 100) .. "%\n"
		else
			for n=0,shields-1 do
				msg = msg .. "Shield " .. n .. ": " .. math.floor(comms_target:getShieldLevel(n) / comms_target:getShieldMax(n) * 100) .. "%\n"
			end
		end

		setCommsMessage(msg)
		addCommsReply("Back", mainMenu)
	end)

	addCommsReply("We need tactical advice", function()
		setCommsMessage("How can I help?")
		return commsHelp()
	end)
	return true
end

function commsHelp()

	if enemyWaveIndex == 5 then
		addCommsReply("How do we deal with that minefield", function()
			setCommsMessage("There are several ways to get the Liberator around that minefield.\nYou can set a waypoint and order us to fly to that waypoint.\nYou can order us to defend you, so the Liberator will follow you instead of flying into the mines.\n\nMaybe there is a way to clear that mineflield. Your shields will be too weak to absorb the damage of more than one mine at once, so you have to think of something else. Be brave, be bold and be very fast!")
		end)
	end
	if enemyWaveIndex >= 6 then
		addCommsReply("How do we deal with those bigger enemies?", function()
			setCommsMessage("Your science officer should be able to tell you something after looking up the enemy ship types in the database.\n\nThe enemy uses missiles, but their supply is limited. It may be a good idea to distract them while they waste their missiles and attack afterwards.\n\nThe Liberator has great firepower, let us use it against the enemies.\n\nWhen science has scanned the enemies twice, their beam ranges will be shown. You can attack from an angle, where they have no defense.\n\nIf you have missiles left, use them from afar before engaging with beam weapons.")
		end)
	end
	addCommsReply("What is our goal?", function()
		setCommsMessage("Your goal is to keep yourself and the Liberator alive until the enemy carrier and it's guards are destroyed.\nTo achieve that, you must destroy all attacking enemy fighters.")
	end)
	local rng = player:getShortRangeRadarRange()
	if not player:areEnemiesInRange(rng) then
		addCommsReply("Where do we find enemies?", function()
			rng = player:getLongRangeRadarRange()
			if player:areEnemiesInRange(rng) then
				setCommsMessage("Your science officer can scan unknown (white) ships. That will reveal weather they are enemies or not. If they are hostile, they will turn red on your radar after scaning.\n\nScience should tell Helm where detected enemies are, so you can engage them.\nYou can always see previous comms messages in your comms log when you click on the line at the bottom of your relay screen.")
			else
				local course = ""
				if comms_target:getOrderTarget() == boss then
					course = "If you can not find any enemy, return to the Libarator."
				else
					course = "We are setting course towards the enemy carrier. Follow the Liberator if you can not find any enemies."
					comms_target:orderAttack(boss)
				end
				if distance(player, comms_target) > rng then
					course = course .. "\nIf Science lost track of the Liberator, you as relay officer should still see us on your map."
				end
				if player:areEnemiesInRange(2*rng) then
					setCommsMessage("If there are no enemies in radar range, your science officer can look at the colored scanner lines surrounding the radar. The green line shows bio-signatures. That may reveal the position of enemies outside your radar range.\n\n"..course)
				else
					setCommsMessage(course)
				end
			end
		end)
	else
		-- enemies are in short range
		addCommsReply("The enemies keep evading, what can we do?", function()
			setCommsMessage("The enemy fighters have great maneuverability and a fast impulse drive.\nEnemies that quick will most likely evade even homing missiles, so you should prefer beam weapons.\nYour engineer can boost your own impulse drive or maneuver; use it to keep the enemy inside your beam range.\nYour helm can also brevely use combat maneuver to get an evading enemy back into your range. You can also use a short burst with your warp drive, to get to the enemy.\n\nAnother approach is to disable the enemies drive. Relay can do this via hacking; also weapons can target the enemies drive system with the beams. Be aware that beams will only really damage an enemy when they target the hull.\n\nYour science officer can monitor the enemies hull, shields and system health to keep you updated about the damage done.\n\nYou might also be able to use the enemies evasion pattern against them.")
		end)
		addCommsReply("The enemies take a long time to be destroyed, what can we do?", function()
			setCommsMessage("Your science officer should monitor the enemies current hull and shield levels. If science scanned the enemy twice, their shield frequencies are shown. Weapons can set the beam frequency to the enemies lowest shield frequency.\nYour weapons officer should make sure, that your beams target the enemies hull, not any other system; otherwise each hit will only cause one point of hull damage.\nAlso the enemy must be selected by the weapons officer, otherwise the beams will not fire.\nYour engineer can boost your beam weapons for a higher fire rate and better damage output.\n\nIf you are unclear how much damage your weapons deal, keep an eye on the main screen and watch your beams fire while ordering your science officer to report remaining shields and hull of the enemy after every hit.\n\nWhen you do it right, your beams should cut through the enemy like a knife through butter.")
		end)
	end
	addCommsReply("We need some general advice how to deal with enemies.", function()
		setCommsMessage("Your science officer can select a scanned enemy and look them up in the database. The description should reveal some tactical advice for that enemy.\nWhen Science scans an enemy twice, the enemies beam range, beam frequencies and shield frequencies are shown.\nWhen you are inside an enemies beam range, your weapon officer should have activated the shields. But switch them off when you are no longer in combat; Shields eat up a lot of energy.")
	end)
	if player:getEnergy() < 500 then
		addCommsReply("We are low on energy, what can we do?", function()
			setCommsMessage("You can dock with the Liberator to restore your energy.\nYour Engineer should always keep an eye on your energy consumption. The biggest energy drain are usualy the shields and the warp drive. Use your shields only when in combat and deactivate them when you are not in danger.\nYour engineer can also boost the reactor power to gain more energy. Lower the power of systems you do not use.\nIf you are comletely out of energy, your engineer can set all systems except the reactor to zero power to regain energy.")
		end)
	end
	-- if you have something to contribute, that might be interesting for a beginner crew, feel free to add your own tactical advice here.
	addCommsReply("Back", mainMenu)
	return commsHelp()
end
