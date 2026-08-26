-- Name: Specialist Training Course
-- Type: Training
-- Short Description: A training scenario for crew of specialised ships.
-- Objective: Destroy all enemy ships in the area.
-- Duration: 30 minutes
-- Difficulty: Easy
-- Description: TODO 
--- 

require("utils.lua")    -- formatTime
require("luax.lua")     -- table.filter
require("plots/campaign.lua")
require("plots/wh_rota.lua")
require("plots/gravity_util.lua")
require("plots/avp_terrain_modules.lua")
require("script_formation.lua")	-- script_formation.spawnFormation
require("script_hangar.lua")	-- script_hangar:create
require("comms/lib_comms_nodes.lua")
require("comms/comms_vf_station.lua")
require("comms/comms_vf_weapons.lua")
require("comms/comms_vf_military.lua")

--- Ship creation functions

function createExuariFighterSquad(posx, posy, arc)
	local enemyList = script_formation.spawnFormation("Dagger", 2, posx, posy, "Exuari", "Beta-")
	enemyList[1]:orderDefendLocation(posx, posy)
	return enemyList
end

function createExuariBomberSquad(posx, posy, arc)
	local enemyList = script_formation.spawnFormation("Gunner", 2, posx, posy, "Exuari", "Gamma-")
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
	script_hangar:create(ship, "Drone", 2, insertDrone)
	return {ship}
end

function createKraylorDreadnoughtCarrier(posx, posy, arc)
	local ship = CpuShip():setFaction("Kraylor"):setTemplate("Painbringer"):setPosition(posx, posy):setRotation(arc):orderDefendLocation(posx, posy):setJumpDrive(false)
	script_hangar:create(ship, "Drone", 4, insertDrone)
	return {ship}
end

function createExuariSmallSniper(posx, posy, arc)
	return {CpuShip():setTemplate("Ranger"):setFaction("Exuari"):setPosition(posx, posy):orderDefendLocation(posx, posy):setRotation(arc)}
end

function insertDrone(mother, newShip, idx)
	table.insert(dronesList, newShip)
end

function createExuariShuttle()
    return CpuShip():setFaction("Exuari"):setTemplate("Racer"):setTypeName("Exuari shuttle"):setWarpDrive(false):setBeamWeapon(0, 0, 355, 0, 0.1, 0.1):setBeamWeapon(1, 0, 355, 0, 0.1, 0.1)
end

local enemySets = {
	["MP52 Hornet"] = {
		createExuariFighterSquad,
		createExuariBomberSquad,
		createExuariSmallSniper,
		createKraylorGunship,
		createKraylorDreadnought,
	},

	["ZX-Lindworm"] = {
		createExuariBomberSquad,
		createKraylorGunship,
		createKraylorBeamship,
		createExuariSmallSniper,
		createExuariFighterSquad,
	},

	["Ryu"] = {
		createExuariFighterSquad,
		createExuariBomberSquad,
		createKraylorGunship,
		createExuariSmallSniper,
		createKraylorDreadnought,
	},

	["Adder MK7"] = {
		createExuariFighterSquad,
		createExuariBomberSquad,
		createExuariSmallSniper,
		createKraylorGunship,
		createKraylorDreadnought,
	},

	["Phobos M3P"] = {
		createExuariFighterSquad,
		createExuariBomberSquad,
		createKraylorGunship,
		createKraylorDreadnought,
		createKraylorDreadnoughtCarrier,
	},

	["Hathcock"] = {
		createExuariFighterSquad,
		createExuariBomberSquad,
		createExuariSmallSniper,
		createKraylorDreadnought,
		createKraylorDreadnoughtCarrier,
	},

	["Piranha M5P"] = {
		createKraylorDreadnought,
		createKraylorDreadnoughtCarrier,
		createKraylorBeamship,
		createKraylorGunship,
		createExuariFighterSquad,
	},

	["Nautilus"] = {
		createKraylorDreadnought,
		createKraylorDreadnoughtCarrier,
		createKraylorGunship,
		createExuariBomberSquad,
		createExuariFighterSquad,
	},

	["Atlantis"] = {
		createExuariFighterSquad,
		createExuariBomberSquad,
		createKraylorGunship,
		createKraylorDreadnought,
		createKraylorDreadnoughtCarrier,
	},

	["Crucible"] = {
		createKraylorDreadnought,
		createKraylorDreadnoughtCarrier,
		createKraylorGunship,
		createExuariBomberSquad,
		createExuariFighterSquad,
	},

	["Maverick"] = {
		createExuariFighterSquad,
		createExuariBomberSquad,
		createKraylorGunship,
		createKraylorDreadnought,
		createKraylorDreadnoughtCarrier,
	},

	["Poseidon"] = {
		createExuariFighterSquad,
		createExuariBomberSquad,
		createKraylorGunship,
		createKraylorDreadnought,
		createKraylorDreadnoughtCarrier,
	},

	["Neptune"] = {
		createExuariFighterSquad,
		createExuariBomberSquad,
		createKraylorGunship,
		createKraylorDreadnought,
		createKraylorDreadnoughtCarrier,
	},

	["Benedict"] = {
		createExuariFighterSquad,
		createExuariBomberSquad,
		createKraylorGunship,
		createKraylorBeamship,
		createKraylorDreadnought,
	},

	["Kiriya"] = {
		createExuariFighterSquad,
		createExuariBomberSquad,
		createKraylorGunship,
		createKraylorBeamship,
		createKraylorDreadnought,
	},

	["Hammer"] = {
		createKraylorDreadnought,
		createKraylorDreadnoughtCarrier,
		createKraylorGunship,
		createExuariBomberSquad,
		createExuariFighterSquad,
	},

	["Anvil"] = {
		createExuariFighterSquad,
		createExuariBomberSquad,
		createKraylorGunship,
		createKraylorDreadnought,
		createKraylorDreadnoughtCarrier,
	},
}




-- terrain
local function create_terrain()
	-- terrain, semi random
	local modules = arrayShuffle({
		TerrainModuleAsteroids,
		TerrainModuleNebulae,
	})
	table.extend(modules, arrayShuffle({
		TerrainModulePlanets,
		TerrainModuleBlackHoles,
	}))

	local start_angle = 45
	local end_angle = start_angle + 360
	local amount = #modules
	for i=1, amount do
		local dir = start_angle + i*(end_angle-start_angle)/amount
		local rad = 10000
		local x,y = radialPosition(rad*2,0,rad*1.1,dir)
		modules[i] = modules[i]:new{direction=dir, radius=rad, x=x, y=y}:create()
	end
	return modules
end

local function place_artifact(modules)
	--unused
	local art_placed = false
	while not art_placed do
		local art_location = arraySelectRandom(modules)
		if art_location:canInsertArtifact() then
			art_placed = true
			art_name = string.format(_("Artifact extracted from %s"), art_location.terrain_type)
			--local art1 = art_location:insertArtifact()
			--local x,y = art1:getPosition()
			--art1:destroy()
			-- TODO pos!
			campaign:placeArtifact(x,y, art_name, _("Collecting this artifact fulfills the bonus objective of the specialist training mission."))
		end
	end
end

local function spawn_enemies(playershiptype)
	local set = enemySets[playershiptype]
	if set == nil then
		set = enemySets["Phobos M3P"]
	end
	local amount = #set
	local start_angle = 180-72/2
	local end_angle = start_angle + 360
	for i=1, amount do
		local dir = start_angle + i*(end_angle-start_angle)/amount
		local x,y = radialPosition(20000,0,25000,dir)
		local enemies = set[i]
		assert(enemies, i)
		enemies = enemies(x,y,dir)
		x,y = radialPosition(17000,0,15000,dir)
		enemies[1]:orderDefendLocation(x,y)
		table.insert(enemyGroups, enemies)
		table.extend(enemyList, enemies)
	end
end

local ship_reinforces_by = {
	["Adder MK7"] =		"Atlantis X23",
	["Phobos M3P"] =	"Elara P2",
	["Hathcock"] =		"Storm",
	["Piranha M5P"] =	"Nirvana R5A",
	["Nautilus"] =		"Elara P2",
	["Atlantis"] =		"Adder MK6",
	["Crucible"] =		"Nirvana R5A",
	["Maverick"] =		"Piranha M5",
}
local function add_reinforecements(playershiptype)
	local reinforcement = ship_reinforces_by[playershiptype]
	if reinforcement == nil then
		reinforcement = ship_reinforces_by["Phobos M3P"]
	end
	table.insert(commandStation.comms_data.reinforcement_info, {
		desc = reinforcement,
		template = reinforcement,
		cost = 20,
		selectable = true,
	})
end

function onNewPlayerShipSpawned(ship)
	ship:setRotation(0):commandTargetRotation(0)
	campaign:requestReputation()
	spawn_enemies(ship:getTypeName())
	add_reinforecements(ship:getTypeName())
end

-- init
function init()
	wh_artifacts:init()
	create_terrain()
	commandStation = SpaceStation():setTemplate("Large Station"):setPosition(20000,0):setFaction("Human Navy")
	comms_vf_station.entry:set_as_comms_function(commandStation)
	commandStation.comms_data = {
		friendlyness = 100,
		reinforcement_cost = {},
		reinforcement_threshold = {},
		reinforcement_info = {},
		service_available = {
			reinforcements = true,
			activatedefensefleet = false,
			supplydrop = true,
			jumpsupplydrop = false,
		},
	}

    enemyGroups = {}
    enemyList = {}
    finishedTimer = 5
    finishedFlag = false
--    instr1 = false
--    assist_timer = 60
--
--    bonusAvail = true
--    bonusCaptured = false 
--    bonus = createExuariShuttle():setCallSign("bonus"):setPosition(-2341, -17052):orderFlyTowardsBlind(-80000, -40000):setHeading(-60)
--	bonus:onDestruction(bonusDestroyed)

	campaign:initScore()
	onNewPlayerShip(onNewPlayerShipSpawned)

	campaign:allowReinforcements()
end

function commsInstr()
    if not instr1 and player:isValid() and getScenarioTime() > 8.0 then
        instr1 = true
        command:sendCommsMessage(player, _("goal-incCall", [[This is Commander Saberhagen.

In this training mission you will practice the basic controls of a Phobos light cruiser.
Since this is not a tutorial, you will be on your own to decide how to destroy all enemy targets in an Exuari training ground.
There will be not much resistance, so you can try different approaches and tactics savely.

Here's your chance to beat up some helpless opponents.
Commander Saberhagen out.]]))
    end
end

function needHelp(delta)
    if not player:isValid() then
        return
    end
    if player:areEnemiesInRange(20000) then
        assist_timer = 60
    else
        assist_timer = assist_timer - delta
        if assist_timer < 0 then
            assist_timer = 120
            local nearest_dist = 99999999
            local nearest_enemy = nil
            for _,enemy in ipairs(enemyList) do
                if enemy:isValid() then
                    local dist = distance(enemy, player)
                    if dist < nearest_dist then
                        nearest_dist = dist
                        nearest_enemy = enemy
                    end
                end
            end
            if nearest_enemy ~= nil then
                command:sendCommsMessage(player, _("goal-incCall", [[This is Commander Saberhagen.
According to our sensors there are still enemies in sector ]]) .. nearest_enemy:getSectorName())
            end
        end
    end
end

function finished(delta)
    finishedTimer = finishedTimer - delta
	local timer = getScenarioTime()
    if finishedTimer < 0 then
        victory("Human Navy")
    end
    if finishedFlag == false then
        finishedFlag = true
		campaign:victoryScore()
        local bonusString = _("msgMainscreen-bonusTarget", "escaped.")
        --[[if not bonus:isValid() then
            bonusString = _("msgMainscreen-bonusTarget", "destroyed.")
			if bonusCaptured then
				bonusString = bonusString .. _("msgMainscreen-bonusTarget"," Artifact captured.")
			else
				bonusString = bonusString .. _("msgMainscreen-bonusTarget"," Artifact was destroyed.")
			end
        end
		--]]
        globalMessage(string.format(_("msgMainscreen", [[Mission Complete.
Your Time: %s
Bonus target %s]]), formatTime(timer), bonusString))
    end
end

function bonusDestroyed(bonus, _)
	local x,y = bonus:getPosition()
	local art = campaign:placeArtifact(x,y, "Exuari Warp Drive", "This warp drive was fitted in an Exuari ship. The drive was powering up when the ship was destroyed, which would have escaped if it weren't destroyed in time. Exuari sometimes use warp drives to ambush their enemies or to escape quickly with valuable cargo.", function(art, pl, collected)
		bonusAvail = false
		bonusCaptured = collected
	end)
	art:setScanningParameters(2, 1)
end

function update(delta)
    local enemyCount = campaign:progressEnemyCount(enemyList, true) -- true: remove all invalid objects enemies from the list

    if enemyCount == 0 then
        if not bonusAvail then
            finished(delta)
        else
            if not bonus:isValid() then
                finished(delta)
            end
        end
    end

--    if bonus:isValid() then
--        local x, y = bonus:getPosition()
--        if x < -40000 then
--            bonus:setWarpDrive(true)
--        end
--        if x < -50000 then
--            bonusAvail = false
--        end
--    end
--
--    commsInstr()
--    needHelp(delta)
end

