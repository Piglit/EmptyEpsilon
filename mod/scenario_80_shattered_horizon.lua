-- Name: Shattered Horizon
-- Type: Larp

TEST = true
require("utils.lua")
require("ee.lua")   -- SYSTEMS
require("plot_manager.lua")

require("map_shattered.lua")
require("gravity_util.lua")
require("player_ships_util.lua")
require("perma_damage_util.lua")
require("plot_shattered.lua")

function init()
	-- collection of scripts from different sources for the plot_manager
	local plot_modules = {
		map_shattered,
		GRAVITY,
		player_ships_util,
		perma_damage_util,
		plot_shattered_droid,
		plot_shattered_network,
		plot_shattered_gozanti,
	}

	plot_manager:init(plot_modules)

	-- set scenario specific variables
	GRAVITY.addGravitySource(map_shattered.planet, 80000)
	GRAVITY.addException(map_shattered.flight_control)
	GRAVITY.addException(map_shattered.ground)
	player_ships_util.ground_station = map_shattered.ground
	plot_shattered_droid.gm_dummy = map_shattered.gm_dummy
	plot_shattered_droid.flight_control = map_shattered.flight_control
	plot_shattered_network.gm_dummy = map_shattered.gm_dummy
	plot_shattered_network.flight_control = map_shattered.flight_control
	plot_shattered_network.ground = map_shattered.ground

	plot_manager.gm_main_menu()

	if TEST then
		player_ships_util:spawn_player_ship("Drexl", "Lambda T-4a", "Treuton Otro and Endira Vask's Lambda Shuttle", "Transport1"):setPosition(0, -50000)
	end
end


--[[ Plots:
* SH-Mission for every player group
* longer plot-line for flight control:
    * auto: sat debris in lower orbit -> send players to capture some that are on the way
        * players need instructions on how to capture
    * GM-Triggered: Unusual readings: single milit Droid
        * capture to research
    * GM-Triggered: ...
--]]

function _init()
    Script():run("util_proximity_scan.lua")


    -- handle new player ships
    onNewPlayerShip(init_player)

    -- set initial mission state
    mission_state = preflight
end


------------------------ end of initialisation -----





