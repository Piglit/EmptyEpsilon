-- Name: Kidnapped
-- Description: The Gozanti carrier is held hostage, you need to liberate it.
-- Type: Skystrike

TEST = true
require("utils.lua")
require("plot_manager.lua")

require("map_ambush.lua")
require("rescue_capsule_utility.lua")	-- rescue_capsule_util
require("proximity_scan.lua")
require("fighter_utils.lua")
--require("flight_plan.lua")

function init()
	-- collection of scripts from different sources for the plot_manager
	local plot_modules = {
		map_ambush,
		rescue_capsule_util,
		proximity_scan,
		fighter_utils,
		ss_kidnapped,	-- from this file
	}

	-- set scenario specific variables
	fighter_utils.default_faction = "Team Blue"
	fighter_utils.enemy_faction = "Team Red"

	plot_manager:init(plot_modules)
end

ss_kidnapped = {}

function ss_kidnapped:resetCarriers()
	self.carrier:setPosition(0,60000):setRotation(180):commandTargetRotation(180)
	self.freighter:setPosition(10000,60000):setRotation(180):commandTargetRotation(180)
end

function ss_kidnapped:init()
	self.carrier = fighter_utils:spawnCarrier():setFaction("Team Red")
	self.freighter = fighter_utils:spawnFreighter()
	self:resetCarriers()
end


