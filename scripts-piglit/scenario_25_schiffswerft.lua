-- Name: Schiffswerft
-- Type: Mission
-- Description: In der Schiffswerft kann das verwendete Schiff gewechselt oder angepasst werden.
--- Dockt an der Station und kontaktiert sie, um euer Schiff anzupassen.
-- Variation[small crew]: Schiffe für eine kleine Crew (2-4 Spieler) stehen zur Verfügung.
-- Variation[large crew]: Schiffe für eine große Crew (6-10 Spieler) stehen zur Verfügung.


require "utils.lua"
require "script_formation.lua"
require "script_hangar.lua"

--- Ship creation functions
function createKraylorGunship()
    ship = CpuShip():setFaction("Kraylor"):setTemplate("Rockbreaker")   -- todo randomize
    script_hangar.create(enemy_station, "Drone", 2)
    script_hangar.config(enemy_station, "onLaunch", addToEnemiesList)
    table.insert(enemyList, ship)
    return ship
end

function createPlayerShip()
    return PlayerSpaceship():setTemplate("Phobos"):setFaction("Human Navy")
end

function addToEnemiesList(_, ship, _)
    table.insert(enemyList, ship)
end

function deleteEnemies()
    for _,enemy in ipairs(enemyList) do
        enemy:delete()  --todo is this even a function?
    end
end

function createTerrain(x,y,gu)
    -- todo tweak
    createRandomAlongArc(Asteroid, 100, 2*gu, -1*gu, gu, 60, 220, 200)
    createRandomAlongArc(VisualAsteroid, 100, 2*gu, -1*gu, gu, 400, 270, 400)
    placeRandomAroundPoint(Nebula, 4, gu, 2*gu, 3.5*gu, 1.5*gu)
    placeRandomAroundPoint(Nebula, 4, gu, 3*gu, 6*gu, -2.5*gu)
    createRandomAlongArc(Asteroid, 80, 7*gu, 2*gu, 1.5*gu, 180, 270, 400)
    createRandomAlongArc(VisualAsteroid, 100, 7*gu, 2*gu, 1.5*gu, 180, 270, 1000)
    createObjectsOnLine(8*gu, -gu, 8*gu, gu, 1000, Mine, 2)
    -- add black hole
end

function deleteTerrain(x,y,gu)
    -- todo remove around point
end


function init()
    allowNewPlayerShips(false)
    enemyList = {}
    last_coords = {0,0}

    player = createPlayerShip()
    player:setCallSign("Rookie 1"):setHeading(90):addReputationPoints(140.0)

    station = SpaceStation():setTemplate('Huge Station'):setCallSign("Shipyard"):setRotation(random(0, 360)):setFaction("Human Navy"):setPosition(1200, 0)
  
end

function spwanCombatSim()
    local x,y = 0,0 --todo random point with radius
    createTerrain(x,y,5000)
    createKraylorGunship():setPosition(x,y)
    last_coords = {x,y}
end

function deleteCombatSim()
    local x,y = last_coords[1], last_coords[2]
    deleteTerrain(x,y,5000)
    deleteEnemies()
    last_coords = {0,0}
end

function update(delta)
    script_hangar.update(delta)
end

