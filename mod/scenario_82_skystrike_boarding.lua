-- Name: Boarding Action
-- Description: A TIE-squadron supports the boarding of a freighter.
-- Type: Skystrike

TEST = false
require("utils.lua")
require("plot_manager.lua")

require("map_gas_giant.lua")
require("rescue_capsule_utility.lua")	-- rescue_capsule_util
require("proximity_scan.lua")
require("fighter_utils.lua")
--require("flight_plan.lua")

function init()
	-- collection of scripts from different sources for the plot_manager
	local plot_modules = {
		map_gas_giant,
		rescue_capsule_util,
		proximity_scan,
		fighter_utils,
		ss_boarding,	-- from this file
	}

	-- set scenario specific variables
	fighter_utils.default_faction = "Team Blue"

	plot_manager:init(plot_modules)
end

ss_boarding = {}

function ss_boarding:resetCarriers()
	self.carrier:setPosition(0,80000):setRotation(-90):commandTargetRotation(-90)
	self.freighter:setPosition(-11000,60000):setRotation(180):commandTargetRotation(180)

end

function ss_boarding:init()
	SpaceStation():setTemplate("Medium Station"):setCallSign("Skystrike Academy"):setFaction("Imperial"):setPosition(-10000,60000)
	self.carrier = fighter_utils:spawnCarrier()
	self.freighter = fighter_utils:spawnFreighter()
	self:resetCarriers()
	self.probe_countdown = 0
end

function ss_boarding:initTest()
	changeLaserColorToRed(CpuShip():setTemplate("TIE-Fighter"):setFaction("Team Red"):setPosition(1000,60000):orderRoaming())
	changeLaserColorToRed(CpuShip():setTemplate("TIE-Interceptor"):setFaction("Team Red"):setPosition(0,61000):orderRoaming())
	changeLaserColorToRed(CpuShip():setTemplate("TIE-Bomber"):setFaction("Team Red"):setPosition(500,60500):orderRoaming())

	CpuShip():setTemplate("TIE-Fighter"):setFaction("Team Blue"):setPosition(-1000,60000):orderRoaming()
	CpuShip():setTemplate("TIE-Interceptor"):setFaction("Team Blue"):setPosition(0,59000):orderRoaming()
	CpuShip():setTemplate("TIE-Bomber"):setFaction("Team Blue"):setPosition(-500,59500):orderRoaming()
end

function changeLaserColorToRed(ship)
	ship:setWeaponTubeExclusiveFor(0, "laser_red")
	ship:setWeaponTubeExclusiveFor(1, "laser_red")
	ship:setWeaponStorageMax("laser_green", 0)
	ship:setWeaponStorageMax("laser_red", 99)
	ship:setWeaponStorage("laser_green", 0)
	ship:setWeaponStorage("laser_red", 99)
end

function ss_boarding:update(delta)
	-- restore probes over time
	if self.carrier ~= nil and self.carrier:isValid() and self.carrier:getScanProbeCount() < self.carrier:getMaxScanProbeCount() then
		self.probe_countdown = self.probe_countdown - delta
		if self.probe_countdown < 0 then
			self.carrier:setScanProbeCount(self.carrier:getScanProbeCount()+1)
			self.probe_countdown = 60
		end
	else
		self.probe_countdown = 60
	end
end

