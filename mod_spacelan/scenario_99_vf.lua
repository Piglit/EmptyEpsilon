-- Name: Verhärtete Fronten
-- Type: Development
-- Proxy: 192.168.2.3

require "plots/plot_manager.lua"

--require "sandbox_error.lua"
require "xansta_mods.lua"
--require("script_hangar.lua")
require("utils.lua")
require("utils_customElements.lua")

require("serpent.lua")
function table.dump(...)
	print(serpent.block(...))
end

TEST = false

function init()
	difficulty = 1	-- global var from xanstas stuff
	init_constants_xansta()

	plot_manager:init({
		"campaign",
		"wh_players",
		"wh_fleetcommand",
		"wh_artifacts",
		"script_hangar",
		"wh_rota",
		"gravity_util",
		"avp_mining",
		"avp_terrain_modules",
		"avp_stations",
		"avp_enemies",
		"vf_blackhole",
		"vf_nebulae",
		"vf_mine_dance",
		"vf_comms_call_to_action",
		"vf_wormhole_instable",
		"avp_story",
	})
	gravity_util.gravity_const = 2000000	-- 50 times as high!
	local terrain = TerrainModuleMetaSpiral:new{x=100000, y=120000, radius=200000, amount=47}
	terrain:registerOnChildrenCheckCallback(avp_story.onTerrainCheck)
	terrain:registerOnChildrenCreationCallback(avp_story.onTerrainCreation)
	terrain:create()
	addGMFunction("Create Kraylor Fortress", create_kraylor_fortress)
	addGMFunction("Create Exuari Boss", create_exuari_boss)
	addGMFunction("Create Ktlitan Boss", create_ktlitan_boss)
	addGMFunction("Create Terrain 2", create_terrain_2)

end

function create_terrain_2()
	local amount = 47
	local terrain = TerrainModuleMetaSpiral:new{x=500000, y=120000, radius=200000, rotation=180+3*360/amount, amount=amount}
	terrain:registerOnChildrenCreationCallback(avp_story.onStationCreation)
	terrain:create()
	removeGMFunction("Create Terrain 2")
end

function create_exuari_boss()
	onGMClick(function(x,y)
		EnemyModuleExuari:spawnEnemiesAtPositions({{x, y}}, 1000)
		onGMClick(nil)
		sendMessageToCampaignServer("fernschreiber", "Human Navy Tiefraum-Abhördienst an die Flotte:\nWir fangen eine starke Warpsignatur aus Sektor ".. getSectorName(x,y) .."auf.\nDort ist gerade etwas großes angekommen!")
	end)
end

function create_ktlitan_boss()
	onGMClick(function(x,y)
		EnemyModuleKtlitans:spawnEnemiesAtPositions({{x, y}}, 500)
		onGMClick(nil)
		sendMessageToCampaignServer("fernschreiber", "Human Navy Tiefraum-Abhördienst an die Flotte:\nWir empfangen eine große Menge Biosignaturen aus Sektor ".. getSectorName(x,y) ..".\nWir vermuten dort eine große Anzahl an Schiffen!")
	end)
end

function createKraylorDestroyer()
    local destroyers = {
        "Deathbringer",
        "Painbringer",
        "Doombringer",
        "Battlestation",
    }
    return CpuShip():setFaction("Kraylor"):setTemplate(destroyers[math.random(#destroyers)])
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
    return CpuShip():setFaction("Kraylor"):setTemplate(gunships[math.random(#gunships)])
end

function create_kraylor_fortress()
	local x_0,y_0 = 20000,100000
    local kraylor_defense_line = {
        WarpJammer():setFaction("Kraylor"):setRange(18000):setPosition(x_0 +264940, y_0 + 7657),
        WarpJammer():setFaction("Kraylor"):setRange(18000):setPosition(x_0 +289620, y_0 + 9915),
        WarpJammer():setFaction("Kraylor"):setRange(18000):setPosition(x_0 +287037, y_0 + 1822),
        WarpJammer():setFaction("Kraylor"):setRange(18000):setPosition(x_0 +285401, y_0 -6615),
        WarpJammer():setFaction("Kraylor"):setRange(18000):setPosition(x_0 +283593, y_0 -18324),
        WarpJammer():setFaction("Kraylor"):setRange(18000):setPosition(x_0 +276878, y_0 -24522),
        WarpJammer():setFaction("Kraylor"):setRange(18000):setPosition(x_0 +268613, y_0 -28138),
        WarpJammer():setFaction("Kraylor"):setRange(18000):setPosition(x_0 +256302, y_0 -23403),
        WarpJammer():setFaction("Kraylor"):setRange(18000):setPosition(x_0 +254149, y_0 -11608),
        WarpJammer():setFaction("Kraylor"):setRange(18000):setPosition(x_0 +260262, y_0 + 46849),
        WarpJammer():setFaction("Kraylor"):setRange(18000):setPosition(x_0 +254924, y_0 + 35571),
        WarpJammer():setFaction("Kraylor"):setRange(18000):setPosition(x_0 +254063, y_0 + 22312),
        WarpJammer():setFaction("Kraylor"):setRange(18000):setPosition(x_0 +255239, y_0 + 10842),
        WarpJammer():setFaction("Kraylor"):setRange(18000):setPosition(x_0 +272745, y_0 + 65015),
        WarpJammer():setFaction("Kraylor"):setRange(18000):setPosition(x_0 +263189, y_0 + 60452),
        WarpJammer():setFaction("Kraylor"):setRange(18000):setPosition(x_0 +280494, y_0 + 56664),
        WarpJammer():setFaction("Kraylor"):setRange(18000):setPosition(x_0 +284454, y_0 + 48829),
        WarpJammer():setFaction("Kraylor"):setRange(18000):setPosition(x_0 +287381, y_0 + 22915),
        WarpJammer():setFaction("Kraylor"):setRange(18000):setPosition(x_0 +287554, y_0 + 36690),
        WarpJammer():setFaction("Kraylor"):setRange(18000):setPosition(x_0 +259093, y_0 -34202),
        WarpJammer():setFaction("Kraylor"):setRange(18000):setPosition(x_0 +294816, y_0 + 29547),
        WarpJammer():setFaction("Kraylor"):setRange(18000):setPosition(x_0 +255958, y_0 + 54372)
    }

    for idx, warp_jammer in ipairs(kraylor_defense_line) do
        local x, y = warp_jammer:getPosition()
        local ship = createKraylorDestroyer():setPosition(x + random(-1000, 1000), y + random(-1000, 1000)):orderDefendLocation(x, y)
		script_hangar:create(ship, "Drone", 4)
        for n = 1, 3 do
            local ship2 = createKraylorGunship():setPosition(x + random(-1000, 1000), y + random(-1000, 1000)):orderDefendTarget(ship)
        end
    end

    SpaceStation():setTemplate("Huge Station"):setFaction("Kraylor"):setPosition(x_0 +291152, y_0 + 32099)
    SpaceStation():setTemplate("Huge Station"):setFaction("Kraylor"):setPosition(x_0 +297462, y_0 -4252)
    SpaceStation():setTemplate("Huge Station"):setFaction("Kraylor"):setPosition(x_0 +262071, y_0 -27984)

    -- Setup the Kraylor forward line.
    local kraylor_forward_line = {
        SpaceStation():setTemplate("Small Station"):setFaction("Kraylor"):setPosition(x_0 +197898, y_0 -7278),
        SpaceStation():setTemplate("Large Station"):setFaction("Kraylor"):setPosition(x_0 +233328, y_0 -13839),
        SpaceStation():setTemplate("Large Station"):setFaction("Kraylor"):setPosition(x_0 +240151, y_0 + 29333),
        SpaceStation():setTemplate("Small Station"):setFaction("Kraylor"):setPosition(x_0 +200260, y_0 + 36681)
    }

    for idx, station in ipairs(kraylor_forward_line) do
        local x, y = station:getPosition()
        local ship = createKraylorDestroyer():setPosition(x + random(-1000, 1000), y + random(-1000, 1000)):orderDefendLocation(x, y)
		script_hangar:create(ship, "Drone", 2)

        for n = 1, 3 do
            local ship2 = createKraylorGunship():setPosition(x + random(-1000, 1000), y + random(-1000, 1000)):orderDefendTarget(ship)
        end
    end

	sendMessageToCampaignServer("fernschreiber", "Human Navy Tiefraum-Abhördienst an die Flotte:\nWir empfangen starke Warp-Störsignale aus Sektor ".. getSectorName(x_0 +297462, y_0 -4252) ..".\nWir vermuten dort eine Kraylor-Befestigungsanlage!")
	removeGMFunction("Create Kraylor Fortress")
end
