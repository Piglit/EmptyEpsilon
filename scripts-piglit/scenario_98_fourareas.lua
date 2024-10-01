-- Name: Four Areas
-- Type: Development
-- Proxy: 192.168.2.3

require "plots/fa_areas.lua"


require "utils.lua"
--require "sandbox_error.lua"
--require "xansta_mods.lua"
--require "script_hangar.lua"

--require("serpent.lua")
--function table.dump(...)
--	print(serpent.block(...))
--end

TEST = false

function init()
--	difficulty = 1	-- global var from xanstas stuff
--	init_constants_xansta()
	plots = {
		fa_areas
--		wh_rota,
--		wh_wormhole,
--		wh_players,
--		wh_artifacts,
--		wh_stations,
--		wh_terrain,
--		wh_fleetcommand,
--		wh_turns,
--		wh_locusts,
--		wh_exuari,
--		wh_kraylor,
--		wh_story,
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
	--script_hangar.update(delta)
end


