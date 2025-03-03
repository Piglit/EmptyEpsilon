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
	self.carrier:setPosition(50000,0):setRotation(180):commandTargetRotation(180)
	self.station:setPosition(0,20000)
end

function ss_kidnapped:init()
	self.station = fighter_utils:spawnCarrierStation()
	self.carrier = fighter_utils:spawnCarrier()
	fighter_utils.carriers["Team Red"] = self.carrier
	fighter_utils.carriers["Team Blue"] = self.station
	self.carrier:setFaction("Team Red")
	CpuShip():setTemplate("GR-75"):setPosition(48000,-1000):setRotation(180):setFaction("Team Red"):orderFlyTowards(-48000, -1000):setScanStateByFaction("Team Red", "fullscan")
	self:resetCarriers()
	self.carrier:commandImpulse(0.5)
end


