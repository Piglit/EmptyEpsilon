-- Name: Battlefield
-- Description: The Humans are fighting off their enemies who are on all out war on a neutral station. (This scenario is mostly for performance testing)
-- Type: Basic
-- Variation[Large]: Larger battle, normally it's about 30 vs 30 ships. This increases this to 100 vs 100 ships.
-- Variation[Huge]: Huge battle, normally it's about 30 vs 30 ships. This increases this to 500 vs 500 ships.

require("utils.lua")
-- For this scenario, utils.lua provides:
--   setCirclePos(obj, x, y, angle, distance)
--     Place an object relative to a vector. Returns the object with its position set to the resulting coordinates.

enemy_faction = "Criminals"

function init()
    player = PlayerSpaceship():setFaction("Human Navy"):setTemplate("Atlantis"):setRotation(0)
	setCirclePos(player, 0, 0, 0, 2000)
    player = PlayerSpaceship():setFaction("Human Navy"):setTemplate("Crucible"):setRotation(120)
	setCirclePos(player, 0, 0, 120, 2000)
    player = PlayerSpaceship():setFaction("Human Navy"):setTemplate("Maverick"):setRotation(240)
	setCirclePos(player, 0, 0, 240, 2000)
    player = PlayerSpaceship():setFaction("Human Navy"):setTemplate("MP52 Hornet"):setRotation(0)
	setCirclePos(player, 0, 0, 20, 1000)
    player = PlayerSpaceship():setFaction("Human Navy"):setTemplate("MP52 Hornet"):setRotation(120)
	setCirclePos(player, 0, 0, 60, 1000)
    player = PlayerSpaceship():setFaction("Human Navy"):setTemplate("MP52 Hornet"):setRotation(240)
	setCirclePos(player, 0, 0, 100, 1000)
    player = PlayerSpaceship():setFaction("Human Navy"):setTemplate("ZX-Lindworm"):setRotation(0)
	setCirclePos(player, 0, 0, 140, 1000)
    player = PlayerSpaceship():setFaction("Human Navy"):setTemplate("ZX-Lindworm"):setRotation(120)
	setCirclePos(player, 0, 0, 180, 1000)
    player = PlayerSpaceship():setFaction("Human Navy"):setTemplate("ZX-Lindworm"):setRotation(240)
	setCirclePos(player, 0, 0, 220, 1000)
    player = PlayerSpaceship():setFaction("Human Navy"):setTemplate("Adder MK7"):setRotation(0)
	setCirclePos(player, 0, 0, 260, 1000)
    player = PlayerSpaceship():setFaction("Human Navy"):setTemplate("Adder MK7"):setRotation(120)
	setCirclePos(player, 0, 0, 300, 1000)
    player = PlayerSpaceship():setFaction("Human Navy"):setTemplate("Adder MK7"):setRotation(240)
	setCirclePos(player, 0, 0, 340, 1000)
	player:addReputationPoints(2000) -- use them to fool around with player fighters

	enemies = {}
    neutral_station = SpaceStation():setTemplate("Large Station"):setPosition(0, -15000):setRotation(random(0, 360)):setFaction("Independent")
    neutral_station.comms_data = {supplydrop = "neutral", weapons = {Mine = "friend" } } -- Setup the neutral station to supply supplydrops to anyone, but mines only to friendlies (which rules out the player)
    friendly_station = SpaceStation():setTemplate("Large Station"):setPosition(-10000, -25000):setRotation(random(0, 360)):setFaction("Human Navy")
    --Put some mines around the friendly station.
    for n = 1, 30 do
        setCirclePos(Mine(), -10000, -25000, n * 10, 5000)
    end
    --Put some neutral tugs around the neutral station, just as cannon fodder.
    for n = 1, 5 do
        setCirclePos(CpuShip():setTemplate("Flavia"):setFaction("Independent"):setScanned(true), 0, -15000, random(0, 360), random(1000, 5000))
    end

    if getScenarioVariation() == "Large" then
        battle_scale = 3.3;
        location_scale = 1.5;
    elseif getScenarioVariation() == "Huge" then
        battle_scale = 16.6;
        location_scale = 3;
    else
        battle_scale = 1;
        location_scale = 1;
    end
    
    for n = 1, 20*battle_scale do
        CpuShip():setTemplate("MT52 Hornet"):setPosition(random(-10000 * location_scale, 10000 * location_scale), random(0, 3000)):setRotation(90):setFaction("Human Navy"):orderRoaming():setScanned(true)
    end
    for n = 1, 10*battle_scale do
        CpuShip():setTemplate("Phobos T3"):setPosition(random(-10000 * location_scale, 10000 * location_scale), random(0, 2000)):setRotation(90):setFaction("Human Navy"):orderRoaming():setScanned(true)
    end

    for n = 1, 20*battle_scale do
        ship = CpuShip():setTemplate("MT52 Hornet"):setPosition(random(-13000 * location_scale, 13000 * location_scale), random(5000, 8000)):setRotation(-90):setFaction(enemy_faction):orderRoaming():setScanned(true)
        table.insert(enemies, ship)
    end
    for n = 1, 10*battle_scale do
        ship = CpuShip():setTemplate("Phobos T3"):setPosition(random(-13000 * location_scale, 13000 * location_scale), random(5000, 8000)):setRotation(-90):setFaction(enemy_faction):orderRoaming()
        table.insert(enemies, ship)
    end
    for n = 1, 3*battle_scale do
        ship = CpuShip():setTemplate("Piranha F12"):setPosition(random(-13000 * location_scale, 13000 * location_scale), 5000):setRotation(-90):setFaction(enemy_faction):orderRoaming()
        table.insert(enemies, ship)
    end
    for n = 1, 1*battle_scale do
        ship = CpuShip():setTemplate("Atlantis X23"):setPosition(random(-3000 * location_scale, 3000 * location_scale), 7000):setRotation(-90):setFaction(enemy_faction):orderRoaming()
        table.insert(enemies, ship)
    end
end

function update(delta)

    -- Count all surviving enemies.
    for _, enemy in ipairs(enemies) do
        if enemy:isValid() then
            enemy_count = enemy_count + 1
        end
    end

    if enemy_count == 0 then
        victory("Human Navy");
    end
end
