-- Name: Wormhole Expedition
-- Type: Development
-- Proxy: 192.168.2.3

require "plots/wh_artifacts.lua"
require "plots/wh_exuari.lua"
require "plots/wh_fleetcommand.lua"
require "plots/wh_kraylor.lua"
require "plots/wh_locusts.lua"
require "plots/wh_players.lua"
require "plots/wh_stations.lua"
require "plots/wh_story.lua"
require "plots/wh_terrain.lua"
require "plots/wh_turns.lua"
require "plots/wh_util_rota.lua"
require "plots/wh_wormhole.lua"

--require "sandbox_error.lua"
require "xansta_mods.lua"
require "script_hangar.lua"

require("serpent.lua")
function table.dump(...)
	print(serpent.block(...))
end

TEST = false

function init()
	difficulty = 1	-- global var from xanstas stuff
	init_constants_xansta()
	plots = {
		wh_rota,
		wh_wormhole,
		wh_players,
		wh_artifacts,
		wh_stations,
		wh_terrain,
		wh_fleetcommand,
		wh_turns,
		wh_locusts,
		wh_exuari,
		wh_kraylor,
		wh_story,
	}
	onNewPlayerShip(function(ship)
		for i,plot in ipairs(plots) do
			if plot.onNewPlayerShip ~= nil then
				plot:onNewPlayerShip(ship)
			end
		end
	end)

	for i,plot in ipairs(plots) do
		assert(plot.init ~= nil, "plot "..i.." must have init()")
		plot:init()
		if TEST and plot.initTest ~= nil then
			plot:initTest()
		end
	end
end

function update(delta)
	for i,plot in ipairs(plots) do
		if plot.update ~= nil then
			plot:update(delta)
		end
		if TEST and plot.updateTest ~= nil then
			plot:updateTest()
		end
	end
	script_hangar.update(delta)
end


