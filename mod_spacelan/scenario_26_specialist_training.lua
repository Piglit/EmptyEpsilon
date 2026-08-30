-- Name: Specialist Training Course
-- Type: Training
-- Short Description: A training scenario for crew of specialised ships.
-- Objective: Destroy all enemy ships in the area.
-- Duration: 30 minutes
-- Difficulty: Easy
-- Description: Fight against different kinds of enemies, using the special powers of your ship.

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

local function place_artifact()
	if artifacts_placed < #getActivePlayerShips() and artifacts_placed < #terrain_modules_placed then
		local module = terrain_modules_placed[artifact_module_index]
		artifact_module_index = artifact_module_index -1
		artifacts_placed = artifacts_placed +1
		if module.terrain_type == "asteroids" then
			local art = module:insertArtifact(function(art, pl, collected)
				sendMessageToCampaignServer("artifact", toJSON{name = art.resource_name, description = art.resource_descr})
				sendMessageToCampaignServer("score", toJSON({artifacts = collected}))
			end)
			art:setScanningParameters(3, 1)	-- reduced difficulty
		elseif module.terrain_type == "planets" then
			local art = campaign:placeArtifact(0,0,_("artifact", "Orbital relict"), _("artifact", "A relict from previous battles in the orbit of a planet."))
			module:insertOrbitingObject(art)
		elseif module.terrain_type == "blackholes" then
			local art = module:insertArtifact(function(art, pl, collected)
				sendMessageToCampaignServer("artifact", toJSON{name = art.resource_name, description = art.resource_descr})
				sendMessageToCampaignServer("score", toJSON({artifacts = collected}))
			end)
			art:setScanningParameters(3, 1)	-- reduced difficulty
		elseif module.terrain_type == "nebulae" then
			local neb = module.nebulae[1]
			if neb ~= nil then
				local x,y = neb:getPosition()
				local art = campaign:placeArtifact(x,y,_("artifact", "Nebulizer"), _("artifact", "A relict found in a nebular cloud."))
			end
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
	local playershiptype = ship:getTypeName()
	if playershiptype == "Kestrel" then
		playershiptype = "Phobos M3P"
	elseif playershiptype == "Honeybadger" then
		playershiptype = "Nautilus"
	end

	spawn_enemies(playershiptype)
	add_reinforecements(playershiptype)
	place_artifact()
	commsInstr(ship)
end

-- init
function init()
	wh_artifacts:init()
	gravity_util.gravity_const = 2000000	-- 50 times as high!

	terrain_modules_placed = create_terrain()
	commandStation = SpaceStation():setTemplate("Large Station"):setPosition(20000,0):setFaction("Human Navy"):setCallSign("Command Station")
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
	first_instr = false
	artifacts_placed = 0
	artifact_module_index = 4

	campaign:initScore()
	onNewPlayerShip(onNewPlayerShipSpawned)

	campaign:allowReinforcements()
end

function commsInstr(player)
	if not first_instr then
		first_instr = true
		commandStation:sendCommsMessage(player, _("goal-incCall", [[This is Commander Saberhagen.

In this mission you will encounter different kinds of enemies within hostile terrain.
Learn to use your ships abilities and decide which enemies you want to attack first.
There is a Human Navy station in the area - you can resupply there.
After you defeated some enemies, you may request reinforcements there to help you against the harder enemies.

Commander Saberhagen out.]]))
	else
		for __, pl2 in ipairs(getActivePlayerShips()) do
			if pl2 ~= player then
				commandStation:sendCommsMessage(pl2, string.format(_("goal-incCall", [[Reinforcements have arrived!
Coordinate your actions with the crew of the %s.
Some enemies may be easier for them than for you.
Some other enemies may require that you attack them together.

New enemies just arrived here. There may be some conflict between enemy ships. Maybe you can use that to your advantage.

Commander Saberhagen out.]]), player:getCallSign()))
			else
				commandStation:sendCommsMessage(player, _("goal-incCall", [[This is Commander Saberhagen.
In this mission you will encounter different kinds of enemies within hostile terrain.
Coordinate with your allies. Some enemies may be easier to defeat when attacked together.
There is a Human Navy station in the area - you can resupply there.

Commander Saberhagen out.]]))
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
	wh_rota:update(delta)
	for __, ship in ipairs(getActivePlayerShips()) do
		gravity_util:updatePlayerShip(delta, ship)
	end
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

