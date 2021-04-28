-- Name: Surrounded
-- Short Description: A quick but hard battle scenario
-- Objective: Survive and destroy all enemy ships
-- Duration: 15 minutes
-- Difficulty: hard
-- Description: You were ambushed while refueling. Now you are surrounded by asteroids, enemies, and mines.
-- Type: Basic

--- Scenario
-- @script scenario_02_surrounded

require("plots/campaign.lua")

function setCirclePos(obj, angle, distance)
    obj:setPosition(math.sin(angle / 180 * math.pi) * distance, -math.cos(angle / 180 * math.pi) * distance)
end

local enemyList
local enemy_faction = "Criminals"

--- Initialize scenario.
function init()
    enemyList = {}
    roamingEnemies = {}
	playerSpawned = false
	player = nil

    -- a station near the center
    -- (Currently, it is not necessary to defend it.)
    station = SpaceStation():setCallSign("Resupply Dock"):setTemplate("Small Station"):setPosition(0, -500):setRotation(random(0, 360)):setFaction("Independent")

    -- several single Phobos
    for _ = 1, 5 do
        ship = CpuShip():setTemplate("Phobos T3"):orderIdle():setFaction(enemy_faction)
        table.insert(enemyList, ship)
        table.insert(roamingEnemies, ship)
        setCirclePos(ship, random(0, 360), random(7000, 10000))
    end

    -- several single Piranha
    for _ = 1, 2 do
        ship = CpuShip():setTemplate("Piranha F12"):orderIdle():setFaction(enemy_faction)
        table.insert(enemyList, ship)
        table.insert(roamingEnemies, ship)
        setCirclePos(ship, random(0, 360), random(7000, 10000))
    end

    -- Atlantis with wingmen
    do
        local a = random(0, 360)
        local d = 9000
        ship = CpuShip():setTemplate("Atlantis X23"):setRotation(a + 180):orderIdle():setFaction(enemy_faction)
        table.insert(enemyList, ship)
        table.insert(roamingEnemies, ship)
        setCirclePos(ship, a, d)

        do
            local wingman = CpuShip():setTemplate("MT52 Hornet"):setRotation(a + 180):setFaction(enemy_faction)
            table.insert(enemyList, wingman)
            setCirclePos(wingman, a - 5, d + 100)
            wingman:orderFlyFormation(ship, 500, 100)
        end
        do
            local wingman = CpuShip():setTemplate("MT52 Hornet"):setRotation(a + 180):setFaction(enemy_faction)
            table.insert(enemyList, wingman)
            setCirclePos(wingman, a + 5, d + 100)
            wingman:orderFlyFormation(ship, -500, 100)
        end
        do
            local wingman = CpuShip():setTemplate("MT52 Hornet"):setRotation(a + 180):setFaction(enemy_faction)
            table.insert(enemyList, wingman)
            setCirclePos(wingman, a + random(-5, 5), d - 500)
            wingman:orderFlyFormation(ship, 0, 600)
        end
    end

    -- random mines
    for _ = 1, 10 do
        setCirclePos(Mine(), random(0, 360), random(10000, 20000))
    end

    -- random asteroids
    for _ = 1, 300 do
        setCirclePos(Asteroid(), random(0, 360), random(10000, 20000))
    end

    -- random artifact
	local art = campaign:placeArtifact(0,10000, "Espionage Device", "This Exuari-made device transmitted a signal, whenever a ship entered this sector.")
	setCirclePos(art, random(0, 360), 20000)

	campaign:initScore()
    onNewPlayerShip(function(pl)
		player = pl
		campaign:requestReputation()
		for i_,enemy in ipairs(roamingEnemies) do
			enemy:orderRoaming()
		end
        if ship:isValid() then
			ship:sendCommsMessage(
				player, string.format(_("goal-incCall", [[%s, this is %s. Surrender your ship and cargo or we will see to your destruction!]]), player:getCallSign(), ship:getCallSign())
			)
        end
		playerSpawned = true
		allowNewPlayerShips(false)
    end)
end

--- Update scenario.
function update(delta)
	local enemy_count = campaign:progressEnemyCount(enemyList)
    if enemy_count == 0 then
		campaign:victoryScore()
        victory("Human Navy")
    end
	if playerSpawned and not player:isValid() then
		allowNewPlayerShips(false)
        victory(enemy_faction)
	end
end
