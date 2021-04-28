-- Name: The Mining Outpost
-- Description: A mining outpost near the Kraylor border sent an emercency call. Defend the outpost against the Kraylor attack!
--- 
--- You will be piloting a Hathcock battle cruiser.
---
--- This is a short mission designed for one ship, but it can be played with any number of player ships.
--- 
-- Type: Basic

-- This mission uses hangar and fighter formation code.

require("utils.lua")
require("script_hangar.lua")

function createMiningFrigate()
    local frigates = {
        "Phobos Y2",
        "Piranha F12",
        "Nirvana R5A",
    }
    local idx = math.random(#frigates)
    return CpuShip():setTemplate(frigates[idx]):setFaction("Mining Corporation")
end

function createMiningFreighter()
    local freighters = {}
    for cnt = 1, 5 do
        table.insert(freighters, "Personnel Freighter "..cnt)
        table.insert(freighters, "Goods Freighter "..cnt)
        table.insert(freighters, "Garbage Freighter "..cnt)
        table.insert(freighters, "Equipment Freighter "..cnt)
        table.insert(freighters, "Fuel Freighter "..cnt)
    end
    local idx = math.random(#freighters)
    return CpuShip():setTemplate(freighters[idx]):setFaction("Mining Corporation")
end

function createKraylorGunship()
    local gunships = {
        "Rockbreaker",
        "Rockbreaker Merchant",
        "Rockbreaker Murderer",
        "Rockbreaker Mercenary",
        "Rockbreaker Marauder",
        "Rockbreaker Military",
        "Spinebreaker",
        "Spinebreaker",
        "Spinebreaker",
    }
    local idx = math.random(#gunships)
    return CpuShip():setFaction("Kraylor"):setTemplate(gunships[idx])
end

function createKraylorDestroyer(level)
    local destroyers = {
        "Deathbringer",
        "Painbringer",
        "Doombringer",
    }
    if level == nil then
        level = math.random(#destroyers)
    end
    return CpuShip():setFaction("Kraylor"):setTemplate(destroyers[level])
end

function init()

    player = PlayerSpaceship():setFaction("Human Navy"):setTemplate("Hathcock")
    station = SpaceStation():setTemplate("Small Station"):setPosition(0, -500):setRotation(random(0, 360)):setFaction("Mining Corporation"):setCallSign("Mining Outpost")
    enemies = {}
    friends = {}
    for n = 1, 2 do
        ship = createMiningFrigate():orderDefendTarget(station):setScanned(true)
        setCirclePos(ship, 0, 0, random(0, 360), random(2000, 5000))
        table.insert(friends, ship)
    end
    for n = 1, 2 do
        ship = createMiningFreighter():orderDock(station):setScanned(true)
        setCirclePos(ship, 0, 0, random(0, 360), random(10000, 20000))
        table.insert(friends, ship)
    end

    for n = 1, 5 do
        ship = createKraylorGunship():orderRoaming()
        setCirclePos(ship, 0, 0, random(0, 360), random(20000, 30000))
        table.insert(enemies, ship)
        script_hangar.create(ship, "Drone", 1)
    end

    a = random(0, 360)
    d = 9500
    ship_with_hangar = createKraylorDestroyer():setRotation(a + 180):orderRoaming()
    setCirclePos(ship_with_hangar, 0, 0, a, d)
    table.insert(enemies, ship_with_hangar)
    script_hangar.create(ship_with_hangar, "Drone", 3)

    for n = 1, 10 do
        setCirclePos(Mine(), 0, 0, random(0, 360), random(10000, 25000))
    end

    for n = 1, 500 do
        setCirclePos(Asteroid(), 0, 0, random(0, 360), random(10000, 30000))
    end
    for n = 1, 50 do
        setCirclePos(Asteroid(), 0, 0, random(0, 360), random(2000, 10000))
    end
end


function update(dt)
    --launch fighters from mothership
    script_hangar.update(dt)

    --victory condition
    enemy_count = 0
    friendly_count = 0

    -- Count all surviving enemies.
    for _, enemy in ipairs(enemies) do
        if enemy:isValid() then
            enemy_count = enemy_count + 1
        end
    end

    for _, friendly in ipairs(friends) do
        if friendly:isValid() then
            friendly_count = friendly_count + 1
        end
    end

    if enemy_count == 0 then
        victory("Human Navy");
    end

    -- If all allies are destroyed, the Humans (players) lose.
    if not station:isValid() then
        victory("Kraylor");
    else
        -- As the battle continues, award reputation based on
        -- the players' progress and number of surviving allies.
        for _, friendly in ipairs(friends) do
            if friendly:isValid() then
                some_player = getPlayerShip(-1)
                if some_player ~= nil and some_player:isValid() then
                    some_player:addReputationPoints(dt * friendly_count * 0.01)
                end
            end
        end
    end
end
