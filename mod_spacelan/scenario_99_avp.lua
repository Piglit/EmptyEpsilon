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
		"wh_stations",	--TODO adjust
	})
end

function update(delta)
	plot_manager:update(delta)
	script_hangar.update(delta)
end


