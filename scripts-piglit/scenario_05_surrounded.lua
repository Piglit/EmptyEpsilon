-- Name: Surrounded
-- Description: You are surrounded by astroids, enemies and mines.
-- Type: Basic

function setCirclePos(obj, angle, distance)
    obj:setPosition(math.sin(angle / 180 * math.pi) * distance, -math.cos(angle / 180 * math.pi) * distance)
end

enemy_faction = "Criminals"

function init()
    player = PlayerSpaceship():setFaction("Human Navy"):setTemplate("Piranha M5P")
    SpaceStation():setTemplate("Small Station"):setPosition(0, -500):setRotation(random(0, 360)):setFaction("Independent")
    enemies = {}
    
    for n = 1, 5 do
        ship = CpuShip():setTemplate("Phobos T3"):orderRoaming():setFaction(enemy_faction)
        setCirclePos(ship, random(0, 360), random(7000, 10000))
        table.insert(enemies, ship)
    end
    for n = 1, 2 do
        ship = CpuShip():setTemplate("Piranha F12"):orderRoaming():setFaction(enemy_faction)
        setCirclePos(ship, random(0, 360), random(7000, 10000))
        table.insert(enemies, ship)
    end
    
    a = random(0, 360)
    d = 9000
    ship = CpuShip():setTemplate("Atlantis X23"):setRotation(a + 180):orderRoaming():setFaction(enemy_faction)
    setCirclePos(ship, a, d)
	table.insert(enemies, ship)

    wingman = CpuShip():setTemplate("MT52 Hornet"):setRotation(a + 180):setFaction(enemy_faction)
    setCirclePos(wingman, a - 5, d + 100)
    wingman:orderFlyFormation(ship, 500, 100)
	table.insert(enemies, wingman)

    wingman = CpuShip():setTemplate("MT52 Hornet"):setRotation(a + 180):setFaction(enemy_faction)
    setCirclePos(wingman, a + 5, d + 100)
    wingman:orderFlyFormation(ship, -500, 100)
	table.insert(enemies, wingman)

    wingman = CpuShip():setTemplate("MT52 Hornet"):setRotation(a + 180):setFaction(enemy_faction)
    setCirclePos(wingman, a + random(-5, 5), d - 500)
    wingman:orderFlyFormation(ship, 0, 600)
	table.insert(enemies, wingman)
    
    for n = 1, 10 do
        setCirclePos(Mine(), random(0, 360), random(10000, 20000))
    end
    
    for n = 1, 300 do
        setCirclePos(Asteroid(), random(0, 360), random(10000, 20000))
    end
end

function update(delta)

    --victory condition
    enemy_count = 0
    -- Count all surviving enemies.
    for _, enemy in ipairs(enemies) do
        if enemy:isValid() then
            enemy_count = enemy_count + 1
        end
    end

    if enemy_count == 0 then
        victory("Human Navy")
    end
end
