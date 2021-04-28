-- Name: Basic Waves
-- Description: Waves of increasingly difficult enemies. Prevent the destruction of your stations.
-- Type: Basic
-- Variation[Hard]: Difficulty starts at wave 5 and increases by 1.5 after the players defeat each wave. (Players are more quickly overwhelmed, leading to shorter games.)
-- Variation[Easy]: Makes each wave easier by decreasing the number of ships in each wave. (Takes longer for the players to be overwhelmed; good for new players.)

require("utils.lua")
-- For this scenario, utils.lua provides:
--   vectorFromAngle(angle, length)
--      Returns a relative vector (x, y coordinates)
--   setCirclePos(obj, x, y, angle, distance)
--      Returns the object with its position set to the resulting coordinates.

function randomStationTemplate()
    if random(0, 100) < 10 then
        return 'Huge Station'
    end
    if random(0, 100) < 20 then
        return 'Large Station'
    end
    if random(0, 100) < 50 then
        return 'Medium Station'
    end
    return 'Small Station'
end

function init()
    waveNumber = 0
    spawnWaveDelay = nil
    enemyList = {}
    friendlyList = {}

    --PlayerSpaceship():setFaction("Human Navy"):setTemplate("Atlantis")

    for n = 1, 2 do
        table.insert(friendlyList, SpaceStation():setTemplate(randomStationTemplate()):setFaction("Human Navy"):setPosition(random(-5000, 5000), random(-5000, 5000)))
    end
    friendlyList[1]:addReputationPoints(150.0)

    local x, y = vectorFromAngle(random(0, 360), 15000)
    for n = 1, 5 do
        local xx, yy = vectorFromAngle(random(0, 360), random(2500, 10000))
        Nebula():setPosition(x + xx, y + yy)
    end

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

    spawnWave()

    for n = 1, 6 do
        setCirclePos(SpaceStation():setTemplate(randomStationTemplate()):setFaction("Independent"), 0, 0, random(0, 360), random(15000, 30000))
    end
    Script():run("util_random_transports.lua")
end

function randomSpawnPointInfo(distance)
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
        ["Nirvana R5M"]= 21,
        ["Storm"]= 22,
        ["Yellow Hornet"]= 5,
        ["Yellow Lindworm"]= 7,
        ["Yellow Adder MK5"]= 7,
        ["Yellow Adder MK4"]= 6,
        ["Phobos Y2"]= 16,    
        ["Piranha F12"]= 15,
        ["Nirvana R5A"]= 20,
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

function spawnWave()
    waveNumber = waveNumber + 1
    friendlyList[1]:addReputationPoints(150 + waveNumber * 15)


    if getScenarioVariation() == "Hard" then
        totalScoreRequirement = math.pow(waveNumber * 1.5 + 4, 1.3) * 10;
    elseif getScenarioVariation() == "Easy" then
        totalScoreRequirement = math.pow(waveNumber * 0.8, 1.3) * 9;
    else
        totalScoreRequirement = math.pow(waveNumber, 1.3) * 10;
    end

    local newEnemies = createEnemyGroup(totalScoreRequirement)

    spawnDistance = 20000
    spawnPointLeader = nil
    spawn_x, spawn_y, spawn_range_x, spawn_range_y = randomSpawnPointInfo(spawnDistance)
    for _, ship in ipairs(newEnemies) do
        ship:setPosition(random(-spawn_range_x, spawn_range_x) + spawn_x, random(-spawn_range_y, spawn_range_y) + spawn_y);
        ship:orderRoaming()
        table.insert(enemyList, ship);
    end

    globalMessage("Wave " .. waveNumber);
end

function update(delta)
    if spawnWaveDelay ~= nil then
        spawnWaveDelay = spawnWaveDelay - delta
        if spawnWaveDelay < 5 then
            globalMessage(math.ceil(spawnWaveDelay));
        end
        if spawnWaveDelay < 0 then
            spawnWave();
            spawnWaveDelay = nil;
        end
        return
    end
    enemy_count = 0
    friendly_count = 0
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
    if enemy_count == 0 then
        spawnWaveDelay = 15.0;
        globalMessage("Wave cleared!");
    end
    if friendly_count == 0 then
        victory("Ghosts");
    end
end
