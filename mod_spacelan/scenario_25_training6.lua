-- Name: Training: Corvette
-- Type: Basic
-- Description: Corvette Training Ground
---

require("utils.lua")


--- Ship creation functions

-- init
function init()
    -- terrain
    gu = 10000
    placeRandomAroundPoint(Asteroid, 100, gu, 2*gu, 0, -2.5*gu)
    placeRandomAroundPoint(VisualAsteroid, 100, gu, 2*gu, 0, -2.5*gu)
    placeRandomAroundPoint(Nebula, 4, gu, gu, 0, 2*gu)
    createObjectsOnLine(2*gu, 0, 2*gu, gu, 1000, Mine, 2)
    BlackHole():setPosition(-1.5*gu, gu)

    -- enemies
    enemy_list = {
        "Dagger",
        "Blade",
        "Gunner",
        "Shooter",
        "Jagger",
        "Racer",
        "Dash",
        "Guard",
        "Sentinel",
        "Warden",
        "Buster",
        "Ranger",
        "Rockbreaker",
        "Spinebreaker",
        "Deathbringer",
        "Painbringer",
        "Doombringer"
    }
    for i,enemy in ipairs(enemy_list) do
        x,y = radialPosition(0,0, 3*gu, i*360/#enemy_list)
        CpuShip():setTemplate(enemy):setPosition(x,y):orderDefendLocation(x,y)
    end
end

function update(delta)
end

