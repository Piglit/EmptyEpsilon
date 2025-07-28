-- Name: Auf verlorenem Posten
-- Type: Development
-- Proxy: 192.168.2.3

require "plots/plot_manager.lua"

--require "sandbox_error.lua"
require "xansta_mods.lua"
require "script_hangar.lua"

require("serpent.lua")
function table.dump(...)
	print(serpent.block(...))
end

TEST = true

function init()
	difficulty = 1	-- global var from xanstas stuff
	init_constants_xansta()

	plot_manager:init({
		"wh_fleetcommand",
		"wh_players",
		"wh_artifacts",
		"wh_rota",
		"gravity_util",
		"avp_terrain_modules",
		"avp_stations",
		"avp_enemies",
		"avp_story",
	})
	gravity_util.gravity_const = 2000000	-- 50 times as high!
	local terrain = TerrainModuleMetaSpiral:new{x=100000, y=120000, radius=200000, amount=47}
	terrain:registerOnChildrenCreationCallback(avp_story.onStationCreation)
	terrain:create()
--	local terrain_2 = avp_terrain_modules:createMetaSpiral{x=500000, y=120000, radius=200000, rotation=180+3*360/amount, amount=amount}	-- should be gm activated. for late game
end

function update(delta)
	plot_manager:update(delta)
	script_hangar.update(delta)
end


