-- Name: Battle: Ktlitan Waves
-- Description: Waves of increasingly difficult enemies. Prevent the destruction of your stations.
-- Type: Basic
-- Variation[Hard]: Difficulty starts at wave 5 and increases by 1.5 after the players defeat each wave. Players are overwhelmed more quickly, leading to shorter games.
-- Variation[Easy]: Decreases the number of ships in each wave. Good for new players, but takes longer for the players to be overwhelmed.

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
    friendlyList[1]:addReputationPoints(150 + waveNumber * 15)


    -- Calculate score of wave
    local totalScoreRequirement  -- actually: remainingScoreRequirement
    if getScenarioVariation() == "Hard" then
        totalScoreRequirement = math.pow(waveNumber * 1.5 + 4, 1.3) * 10
    elseif getScenarioVariation() == "Easy" then
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

    globalMessage(string.format(_("Wave %d"), waveNumber))
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
        globalMessage(_("Wave cleared!"))
    end
    -- ... or lose
    if friendly_count == 0 then
        victory("Ktlitans")
    end
end
