-- Name: Training: Specialized
-- Type: Basic
-- Description: Frigate Training Ground
---
--- Try some other ships out agains different enemies

require("utils.lua")
require "luax.lua"

require "script_formation.lua"
local spawn = script_formation.spawnFormation
require "script_hangar.lua"

--- Ship creation functions
function createHumanBeamShip(posx, posy, arc)
	return {CpuShip():setFaction("Human Navy"):setTemplate(" Hathcock"):setPosition(posx, posy):setRotation(arc):orderIdle():setCommsFunction(nil):setCommsScript("")}
end

function createHumanMissileShip(posx, posy, arc)
	return {CpuShip():setFaction("Human Navy"):setTemplate(" Piranha M5P"):setPosition(posx, posy):setRotation(arc):orderIdle():setCommsFunction(nil):setCommsScript("")}
end

function createHumanMineShip(posx, posy, arc)
	return {CpuShip():setFaction("Human Navy"):setTemplate(" Nautilus"):setPosition(posx, posy):setRotation(arc):orderIdle():setCommsFunction(nil):setCommsScript("")}
end

function createHumanScoutShip(posx, posy, arc)
	return {CpuShip():setFaction("Human Navy"):setTemplate(" Adder MK7"):setPosition(posx, posy):setRotation(arc):orderIdle():setCommsFunction(nil):setCommsScript("")}
end

function createExuariFighterSquad(posx, posy, arc)
	local enemyList = spawn("Dagger", 2, posx, posy, "Exuari", "Beta-")
	enemyList[1]:orderDefendLocation(posx, posy)
	return enemyList
end

function createExuariBomberSquad(posx, posy, arc)
	local enemyList = spawn("Gunner", 2, posx, posy, "Exuari", "Gamma-")
	enemyList[1]:orderDefendLocation(posx, posy)
	return enemyList
end

function createKraylorBeamship(posx, posy, arc)
	return {CpuShip():setFaction("Kraylor"):setTemplate("Spinebreaker"):setPosition(posx, posy):setRotation(arc):orderDefendLocation(posx, posy)}
end

function createKraylorGunship(posx, posy, arc)
	return {CpuShip():setFaction("Kraylor"):setTemplate("Rockbreaker"):setPosition(posx, posy):setRotation(arc):orderDefendLocation(posx, posy)}
end

function createKraylorDreadnought(posx, posy, arc)
	local ship = CpuShip():setFaction("Kraylor"):setTemplate("Deathbringer"):setPosition(posx, posy):setRotation(arc):orderDefendLocation(posx, posy)
    script_hangar.create(ship, "Drone", 2)
	return {ship}
end

function createKraylorDreadnoughtCarrier(posx, posy, arc)
	local ship = CpuShip():setFaction("Kraylor"):setTemplate("Painbringer"):setPosition(posx, posy):setRotation(arc):orderDefendLocation(posx, posy):setJumpDrive(false)
    script_hangar.create(ship, "Drone", 4)
	return {ship}
end

function createExuariSmallSniper(posx, posy, arc)
    return {CpuShip():setTemplate("Ranger"):setFaction("Exuari"):setPosition(posx, posy):orderDefendLocation(posx, posy):setRotation(arc)}
end

function createExuariNormalSniper(posx, posy, arc)
    return {CpuShip():setTemplate("Flash"):setFaction("Exuari"):setPosition(posx, posy):orderDefendLocation(posx, posy):setRotation(arc)}
end

-- init
function init()
	terrain_radius = 22000
	player_ship_radius = 4000
	enemies_inner_radius = 18000
	enemies_outer_radius = 32000

	enemyList = {}
	humanList = {}

	-- place terrain
	local r = terrain_radius
	x,y = radialPosition(0,0, r, 45)
	placeRandomAroundPoint(Asteroid, 100, 0, r*0.5, x, y)
	placeRandomAroundPoint(VisualAsteroid, 100, 0, r*0.5, x, y)
	x_0,y_0 = radialPosition(0,0, r*0.8, 45+90)
	x_1,y_1 = radialPosition(0,0, r*1.2, 45+90)
	createObjectsOnLine(x_0, y_0, x_1, y_1, 1000, Mine, 2)
	x,y = radialPosition(0,0, r, 45+180)
	placeRandomAroundPoint(Nebula, 4, 0, r*0.5, x, y)
	x,y = radialPosition(0,0, r, 45+270)
	BlackHole():setPosition(x, y)

	-- place ships
	local spawn_funcs = {
		{createHumanBeamShip, createExuariFighterSquad, createExuariBomberSquad},
		{createHumanMissileShip, createKraylorBeamship, createKraylorGunship},
		{createHumanMineShip, createKraylorDreadnought, createKraylorDreadnoughtCarrier},
		{createHumanScoutShip, createExuariSmallSniper, createExuariNormalSniper},
	}
	-- place enemies
	for i,funcs in ipairs(spawn_funcs) do
		local arc = i*360/#spawn_funcs
		x,y = radialPosition(0,0, player_ship_radius, arc)
		table.extend(humanList, funcs[1](x,y,arc))
		x,y = radialPosition(0,0, enemies_inner_radius, arc)
		table.extend(enemyList, funcs[2](x,y,arc-180))
		x,y = radialPosition(0,0, enemies_outer_radius, arc)
		table.extend(enemyList, funcs[3](x,y,arc-180))
	end
end

function update(delta)
end

