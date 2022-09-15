-- Name: Battle: Waves
-- Description: Waves of increasingly difficult enemies attack friendly stations. There is no victory. How many waves can you destroy?
---
--- Spawn the player ships you want. The strength of enemy ships is independent of the number and type of player ships.
-- Type: Basic
-- Setting[Enemies]: Configures the amount of enemies spawned in the scenario.
-- Enemies[Easy]: Decreases the number of ships in each wave. Good for new players, but takes longer for the players to be overwhelmed.
-- Enemies[Normal|Default]: Normal amount of enemies. Recommended for a normal crew.
-- Enemies[Hard]: Difficulty starts at wave 5 and increases by 1.5 after the players defeat each wave. Players are overwhelmed more quickly, leading to shorter games.
-- Setting[Enemy Faction]: Configures the faction of enemies spawned in the scenario. Different factions attack with different types of ships.
-- Enemy Faction[Ghosts|Default]: Ghosts attack with ships similar to the ships used by the Human Navy
-- Enemy Faction[Exuari]: Exuari Death Squads will attack. Expect specialised ships and fighters.
-- Enemy Faction[Kraylor]: Kraylor forces will attack. Expect heavy ships.
-- Enemy Faction[Ktlitans]: Ktlitans will attack. Expect ships of the swarm.

--- Scenario
-- @script scenario_03_waves

require("utils.lua")
-- For this scenario, utils.lua provides:
--   vectorFromAngle(angle, length)
--      Returns a relative vector (x, y coordinates)
--   setCirclePos(obj, x, y, angle, distance)
--      Returns the object with its position set to the resulting coordinates.

function randomStationTemplate()
    local rnd = random(0, 100)
    if rnd < 10 then
        return "Huge Station"
    end
    if rnd < 20 then
        return "Large Station"
    end
    if rnd < 50 then
        return "Medium Station"
    end
    return "Small Station"
end

function init()
    -- global variables:
    waveNumber = 0
    spawnWaveDelay = nil
    enemyList = {}
    friendlyList = {}

    --PlayerSpaceship():setFaction("Human Navy"):setTemplate("Atlantis")

    -- Give the mission to the (first) player ship
    local text = _("goal-shipLog", [[At least one friendly base must survive.

Destroy all enemy ships. After a short delay, the next wave will appear. And so on ...

How many waves can you destroy?]])
    --getPlayerShip(-1):addToShipLog(text, "white")

    -- Random friendly stations
    for _ = 1, 2 do
        local station = SpaceStation():setTemplate(randomStationTemplate()):setFaction("Human Navy"):setPosition(random(-5000, 5000), random(-5000, 5000))
        table.insert(friendlyList, station)
    end

    -- Random neutral stations
    for _ = 1, 6 do
        local station = SpaceStation():setTemplate(randomStationTemplate()):setFaction("Independent")
        setCirclePos(station, 0, 0, random(0, 360), random(15000, 30000))
    end
    friendlyList[1]:addReputationPoints(150.0)

    -- Random nebulae
    local x, y = vectorFromAngle(random(0, 360), 15000)
    for n = 1, 5 do
        local xx, yy = vectorFromAngle(random(0, 360), random(2500, 10000))
        Nebula():setPosition(x + xx, y + yy)
    end

    -- Random asteroids
    local a, a2, d
    local dx1, dy1
    local dx2, dy2
    for cnt = 1, random(2, 7) do
        a = random(0, 360)
        a2 = random(0, 360)
        d = random(3000, 15000 + cnt * 5000)
        x, y = vectorFromAngle(a, d)
        for acnt = 1, 25 do
            dx1, dy1 = vectorFromAngle(a2, random(-1000, 1000))
            dx2, dy2 = vectorFromAngle(a2 + 90, random(-10000, 10000))
            Asteroid():setPosition(x + dx1 + dx2, y + dy1 + dy2)
        end
        for acnt = 1, 50 do
            dx1, dy1 = vectorFromAngle(a2, random(-1500, 1500))
            dx2, dy2 = vectorFromAngle(a2 + 90, random(-10000, 10000))
            VisualAsteroid():setPosition(x + dx1 + dx2, y + dy1 + dy2)
        end
    end

    -- First enemy wave
    spawnWave()

    -- Random transports
    Script():run("util_random_transports.lua")
end

function randomSpawnPointInfo(distance)
    local x, y
    local rx, ry
    if random(0, 100) < 50 then
        if random(0, 100) < 50 then
            x = -distance
        else
            x = distance
        end
        rx = 2500
        y = 0
        ry = 5000 + 1000 * waveNumber
    else
        x = 0
        rx = 5000 + 1000 * waveNumber
        if random(0, 100) < 50 then
            y = -distance
        else
            y = distance
        end
        ry = 2500
    end
    return x, y, rx, ry
end


function createEnemyGroup(difficulty)
    if getScenarioSetting("Enemy Faction") == "Ghosts" then
		return createEnemyGroupGhosts(difficulty)
    elseif getScenarioSetting("Enemy Faction") == "Exuari" then
		return createEnemyGroupExuari(difficulty)
    elseif getScenarioSetting("Enemy Faction") == "Kraylor" then
		return createEnemyGroupKraylor(difficulty)
    elseif getScenarioSetting("Enemy Faction") == "Ktlitans" then
		return createEnemyGroupKtlitans(difficulty)
	end
end

function createEnemyGroupGhosts(difficulty)
    local faction = "Ghosts"
    -- all human ships are possible.
    -- groups are sorted by color (faction)
    local enemyList = {}
    local totalScore = 0
    local costs = {
        ["MU52 Hornet"]= 5,
        ["WX-Lindworm"]= 7,
        ["Adder MK6"]= 8,
        ["Phobos M3"]= 15,
        ["Piranha M5"]= 20,
        ["Nirvana R5A"]= 21,
        ["Storm"]= 22,
        ["Yellow Hornet"]= 5,
        ["Yellow Lindworm"]= 7,
        ["Yellow Adder MK5"]= 7,
        ["Yellow Adder MK4"]= 6,
        ["Phobos T3"]= 16,    
        ["Piranha F12"]= 15,
        ["Nirvana R3"]= 20,
        ["Blue Hornet"]= 5,
        ["Blue Lindworm"]= 7,
        ["Blue Adder MK5"]= 7,
        ["Blue Adder MK4"]= 6,
        ["Phobos Vanguard"]= 16, 
        ["Phobos Rear-Guard"]= 15,
        ["Piranha Vanguard"]= 17,
        ["Piranha Rear-Guard"]= 15,
        ["Nirvana Vanguard"]= 20,
        ["Nirvana Rear-Guard"]= 20,
        ["Red Hornet"]= 5,
        ["Red Lindworm"]= 7,
        ["Red Adder MK5"]= 7,
        ["Red Adder MK4"]= 6,
        ["Phobos Firehawk"]= 16,
        ["Piranha F12.M"]= 17,
        ["Nirvana Thunder Child"]= 21,
        ["Lightning Storm"]= 22,
        ["Advanced Hornet"]= 5,
        ["Advanced Lindworm"]= 7,
        ["Advanced Adder MK5"]= 7,
        ["Advanced Adder MK4"]= 6,
        ["Phobos G4"]= 17,
        ["Piranha G4"]= 16,
        ["Nirvana 0x81"]= 22,
        ["Solar Storm"]= 22,
        ["MT52 Hornet"]= 5,
        ["WX-Lindworm"]= 7,
        ["Adder MK5"]= 7,
        ["Adder MK4"]= 6,
        ["Phobos T3"]= 15,
        ["Piranha F8"]= 15,
        ["Nirvana R5"]= 19,
    }
    local groups = {
        {"MU52 Hornet", "WX-Lindworm", "Adder MK6", "Phobos M3", "Piranha M5", "Nirvana R5M", "Storm"},
        {"Yellow Hornet", "Yellow Lindworm", "Yellow Adder MK5", "Yellow Adder MK4", "Phobos Y2", "Piranha F12", "Nirvana R5A"},
        {"Blue Hornet", "Blue Lindworm", "Blue Adder MK5", "Blue Adder MK4", "Phobos Vanguard", "Phobos Rear-Guard", "Piranha Vanguard", "Piranha Rear-Guard", "Nirvana Vanguard", "Nirvana Rear-Guard"},
        {"Red Hornet", "Red Lindworm", "Red Adder MK5", "Red Adder MK4", "Phobos Firehawk", "Piranha F12.M", "Nirvana Thunder Child", "Lightning Storm"},
        {"Advanced Hornet", "Advanced Lindworm", "Advanced Adder MK5", "Advanced Adder MK4", "Phobos G4", "Piranha G4", "Nirvana 0x81", "Solar Storm"},
        {"MT52 Hornet", "WX-Lindworm", "Adder MK5", "Adder MK4", "Phobos T3", "Piranha F8", "Nirvana R5"}
    }

    local groupIdx = math.random(#groups)
    while totalScore < difficulty do
        local tmpl = groups[groupIdx][math.random(#(groups[groupIdx]))]
        local cost = costs[tmpl]
        if cost == nil then
            cost = 5
        end
        if cost < difficulty - totalScore + 5 then
            local ship = CpuShip():setFaction(faction):setTemplate(tmpl)
            totalScore = totalScore + cost
            table.insert(enemyList, ship)
        end
    end

    return enemyList
end

function createEnemyGroupExuari(difficulty)
    -- Exuari attack groups consist of different ship types
    -- different types have different speeds (sorted by groups)
    local faction = "Exuari"
    local enemyList = {}
    local totalScore = 0
    -- TODO match cost/difficulty with other waves scenarios
    local costs = {
        ["Dagger"]= 4,
        ["Blade"]= 5,
        ["Gunner"]= 4,
        ["Shooter"]= 5,
        ["Jagger"]= 5,
        ["Racer"]= 25,
        ["Hunter"]= 30,
        ["Strike"]= 25,
        ["Dash"]= 30,
        ["Guard"]= 20,
        ["Sentinel"]= 15,
        ["Warden"]= 20,
        ["Flash"]= 25,
        ["Ranger"]= 30,
        ["Buster"]= 25,
        ["Ryder"]= 50,
        ["Fortress"]= 100,
    }
    local groups = {
        {"Dagger", "Blade", "Gunner", "Shooter", "Jagger"},
        {"Racer", "Hunter", "Strike", "Dash"},
        {"Guard", "Sentinel", "Warden"},
        {"Flash", "Ranger", "Buster"},
        {"Ryder", "Fortress"}
    }

    local groupIdx = 0
    while totalScore < difficulty do
        groupIdx = (groupIdx % #groups) + 1
        local tmpl = groups[groupIdx][math.random(#(groups[groupIdx]))]
        local cost = costs[tmpl]
        if cost == nil then
            cost = 5
        end
        if cost < difficulty - totalScore + 5 then
            local ship = CpuShip():setFaction(faction):setTemplate(tmpl)
            totalScore = totalScore + cost
            table.insert(enemyList, ship)
        end
    end

    return enemyList
end

function createEnemyGroupKraylor(difficulty)
    local faction = "Kraylor"
    local enemyList = {}
    local totalScore = 0
    local costs = {
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
        ["Battlestation"]= 70,
        ["Goddess of Destruction"]= 170,
    }
    local destroyers = {"Deathbringer", "Painbringer", "Doombringer"}
    local gunships = {"Rockbreaker", "Rockbreaker Merchant", "Rockbreaker Murderer", "Rockbreaker Mercenary", "Rockbreaker Marauder", "Rockbreaker Military", "Spinebreaker"}
    local dest = math.random(math.floor(difficulty/6), math.floor(difficulty/3)) -- max d/3 points in destroyers

	local tmpl
	local cost
    while totalScore < difficulty do
        local ship = CpuShip():setFaction(faction)
        if (difficulty - totalScore) > 20 then
            if dest > 25 then
                tmpl = destroyers[math.random(#destroyers)]
                cost = costs[tmpl]
                if cost == nil then
                    cost = 50
                end
                ship:setTemplate(tmpl)
                totalScore = totalScore + cost
                dest = dest - cost
            else
                tmpl = gunships[math.random(#gunships)]
                cost = costs[tmpl]
                if cost == nil then
                    cost = 25
                end
                ship:setTemplate(tmpl)
                totalScore = totalScore + cost 
            end
            dest = dest - cost
            script_hangar.create(ship, "Drone", 3, function (_, fighter, _)
                table.insert(enemyList, fighter)
            end)
        else
            ship:setTemplate("Drone")
            totalScore = totalScore + 5 
        end
        table.insert(enemyList, ship)
    end

    return enemyList
end

function createEnemyGroupKtlitans(difficulty)
    -- Ktlitan attack groups consist of different ship types
    -- different types have different speeds (sorted by groups)
    local faction = "Ktlitans"
    local enemyList = {}
    local totalScore = 0
    local costs = {
        ["Ktlitan Drone"]= 3,
        ["Ktlitan Worker"]= 5,
        ["Ktlitan Fighter"]= 7,
        ["Ktlitan Breaker"]= 12,
        ["Ktlitan Scout"]= 10,
        ["Ktlitan Feeder"]= 15,
        ["Ktlitan Destroyer"]= 45,
        ["Ktlitan Queen"]= 64,
    }
	local hierarchy = {
        "Ktlitan Queen",
        "Ktlitan Destroyer",
        "Ktlitan Feeder",
        "Ktlitan Scout",
        "Ktlitan Breaker",
        "Ktlitan Fighter",
        "Ktlitan Worker",
        "Ktlitan Drone",
	}
    
    local hierarchyIdx = 0
	local maxAmount = 0
    while totalScore < difficulty do
		hierarchyIdx = hierarchyIdx +1
		maxAmount = maxAmount + 1
		if hierarchyIdx > #hierarchy then
			hierarchyIdx = 2
			maxAmount = 2
		end
        local tmpl = hierarchy[hierarchyIdx]
        local cost = costs[tmpl]
        if cost == nil then
            cost = 5
        end
		local actualMax = math.random(1,maxAmount)
		for i=1,actualMax do
			if cost < difficulty - totalScore + 5 then
				local ship = CpuShip():setFaction(faction):setTemplate(tmpl)
				totalScore = totalScore + cost
				table.insert(enemyList, ship)
			end
		end
    end
    return enemyList
end



function spawnWave()
    waveNumber = waveNumber + 1
    getPlayerShip(-1):addToShipLog(string.format(_("shipLog", "Wave %d"), waveNumber), "red")
    friendlyList[1]:addReputationPoints(150 + waveNumber * 15)

    enemyList = {}

    -- Calculate score of wave
    local totalScoreRequirement  -- actually: remainingScoreRequirement
    if getScenarioSetting("Enemies") == "Hard" then
        totalScoreRequirement = math.pow(waveNumber * 1.5 + 4, 1.3) * 10
    elseif getScenarioSetting("Enemies") == "Easy" then
        totalScoreRequirement = math.pow(waveNumber * 0.8, 1.3) * 9
    else
        totalScoreRequirement = math.pow(waveNumber, 1.3) * 10
    end

    local newEnemies = createEnemyGroup(totalScoreRequirement)

    local spawnDistance = 20000
    local spawnPointLeader = nil
    local spawn_x, spawn_y, spawn_range_x, spawn_range_y = randomSpawnPointInfo(spawnDistance)
    for _, ship in ipairs(newEnemies) do
        ship:setPosition(random(-spawn_range_x, spawn_range_x) + spawn_x, random(-spawn_range_y, spawn_range_y) + spawn_y);
        ship:orderRoaming()
        table.insert(enemyList, ship);
    end

    globalMessage(string.format(_("msgMainscreen", "Wave %d"), waveNumber))
end

function update(delta)
    -- Show countdown, spawn wave
    if spawnWaveDelay ~= nil then
        spawnWaveDelay = spawnWaveDelay - delta
        if spawnWaveDelay < 5 then
            globalMessage(math.ceil(spawnWaveDelay))
        end
        if spawnWaveDelay < 0 then
            spawnWave()
            spawnWaveDelay = nil
        end
        return
    end

    -- Count enemies and friends
    local enemy_count = 0
    local friendly_count = 0
    for _, enemy in ipairs(enemyList) do
        if enemy:isValid() then
            enemy_count = enemy_count + 1
        end
    end
    for _, friendly in ipairs(friendlyList) do
        if friendly:isValid() then
            friendly_count = friendly_count + 1
        end
    end
    -- Continue ...
    if enemy_count == 0 then
        spawnWaveDelay = 15.0
        globalMessage(_("msgMainscreen", "Wave cleared!"))
        getPlayerShip(-1):addToShipLog(string.format(_("shipLog", "Wave %d cleared."), waveNumber), "green")
    end
    -- ... or lose
    if friendly_count == 0 then
        victory("Ghosts") -- Victory for the Ghosts (= defeat for the players)
    end
end
