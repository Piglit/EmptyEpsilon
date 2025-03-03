-- Name: Droid Collection
-- Description: A squadron of TIE-Pilots collect some defunct droids from an asteroid belt to train their flight abilities.
-- Type: Skystrike

TEST = false
require("utils.lua")
require("plot_manager.lua")

require("map_mining_area.lua")	-- fa_area_mining
require("rescue_capsule_utility.lua")	-- rescue_capsule_util
require("proximity_scan.lua")
require("fighter_utils.lua")

require("flight_plan.lua")	-- used inside ss_training, not in plot_modules

function init()
	-- collection of scripts from different sources for the plot_manager
	local plot_modules = {
		fa_area_mining,
		rescue_capsule_util,
		proximity_scan,
		fighter_utils,
		ss_training,	-- from this file
	}

	-- set scenario specific variables
	fa_area_mining.scale = 1

	plot_manager:init(plot_modules)
end

ss_training = {}

function ss_training:resetCarrier()
	self.carrier:setPosition(0,15000):setRotation(90):commandTargetRotation(90)
end

function ss_training:showCarrierWaypoints()
	self.carrier:commandAddWaypoint(2500,22500)
	self.carrier:commandAddWaypoint(17500,22500)
	self.carrier:commandAddWaypoint(32500,15500)
end

function ss_training:hideCarrierWaypoints()
	self.carrier:commandRemoveWaypoint(0)
	self.carrier:commandRemoveWaypoint(0)
	self.carrier:commandRemoveWaypoint(0)
end

function ss_training:createFlightPlan()
	-- The flight plan (slideshow):
	slowGame()
	local carrier = self.carrier

	flight_plan:init()
	flight_plan.observer = carrier

	flight_plan:addToSequence(function()
		flight_plan.observer:addToShipLog("This will introduce you to your flight plan for today. Press Next to continue.", "cyan")
		self:resetCarrier()
		flight_plan:clearObjects()
		carrier:setShortRangeRadarRange(100000)
		self:hideCarrierWaypoints()
	end)
	flight_plan:addInstructions("Gozanti will carry a TIE Squadron to the asteroid belt around Mustafar for flight training.")
	flight_plan:addToSequence(function()
		flight_plan.observer:addToShipLog("The TIEs will identify and if necessary destroy broken mining droids inside the asteroid belt.", "cyan")
		table.insert(flight_plan.objects, CpuShip():setTemplate("Debris"):setPosition(12000,32000):setRotation(0):orderIdle():setCallSign("???"):setFaction("Environment"):setCanBeDestroyed(false))
		table.insert(flight_plan.objects, CpuShip():setTemplate("Debris"):setPosition(11000,32000):setRotation(0):orderIdle():setCallSign("Debris"):setFaction("Environment"):setScanned(true):setCanBeDestroyed(false))
		table.insert(flight_plan.objects, CpuShip():setTemplate("Viper Droid"):setPosition(13000,32000):setRotation(0):orderIdle():setCallSign("Droid"):setFaction("Target"):setScanned(true):setCanBeDestroyed(false))
	end)
	flight_plan:addInstructions("During transit to the belt, the fighter pilots will familiarise themselves with their controls.")
	flight_plan:addToSequence(function()
		flight_plan.observer:addToShipLog("Gozanti will drop two TIEs at each waypoint along the asteroid belt.", "cyan")
		self:showCarrierWaypoints()
	end)
	flight_plan:addInstructions({
		"The training course is more difficult at early waypoints. The TIE-Pilots are advised to group according to their skill and desired challenge.",
		"Each fighter pilot will report to flight control, whenever they are ready to drop from the carrier."})
	flight_plan:addToSequence(function()
		flight_plan.observer:addToShipLog("Flight control will give the order to launch for two TIEs at each waypoint. Those two TIEs form a flight group.", "cyan")
		self.carrier:setPosition(12000,20000)
		table.insert(flight_plan.objects, CpuShip():setTemplate("TIE-Interceptor"):setPosition(12000,22000):setRotation(90):orderIdle():setCallSign("RHO-1"):setFaction("Imperial"):setScanned(true))
		table.insert(flight_plan.objects, CpuShip():setTemplate("TIE-Interceptor"):setPosition(11800,21800):setRotation(90):orderIdle():setCallSign("RHO-2"):setFaction("Imperial"):setScanned(true))
		self:hideCarrierWaypoints()
	end)
	flight_plan:addInstructions({
		"In each flight group, one of the TIEs takes point, the other one acts as wingman.",
		"Point flies in front, drawing the aggression of potential enemies. Wing flies behind point, supporting point in any way possible.",
		"Wingmen have mid-range sensors installed, so the wingman is responsible for mid-range navigation.",
		"Each flight group will enter the asteroid belt and search for unusual debris from mining operations.",
		"To identify unknown objects in the belt, either the wingman can use its scanners, or any TIE can fly close to it.",
		"If any of the objects is an armed droid, destroy it.",
	})
	flight_plan:addToSequence(function()
		flight_plan.observer:addToShipLog("After they cleared your area, the TIEs will return to the rendezvous point and where Gozanti will collect them and bring them back to the ground station.", "cyan")
		flight_plan:clearObjects()
		self:showCarrierWaypoints()
	end)
	flight_plan:addInstructions("Should a TIE be destroyed, it is the task of the other TIEs to rescue the pilot.")
	flight_plan:setOnFinish(function()
		self:hideCarrierWaypoints()
		self:resetCarrier()
		carrier:setShortRangeRadarRange(5000)
		carrier:setLongRangeRadarRange(30000)
	end)
end

function ss_training:startScenario()
	flight_plan.finished()	-- also resets carrier
	self:showCarrierWaypoints()
	unslowGame()
	removeGMFunction("Start Scenario")
	fa_area_mining:createDebris()
end

function ss_training:init()
	self.carrier = fighter_utils:spawnCarrier()
	self.carrier:setCanScan(false)
	self:resetCarrier()
	self:createFlightPlan()
	addGMFunction("Start Scenario", function() ss_training:startScenario() end)
end

function ss_training:initTest()
	self:startScenario()
	PlayerSpaceship():setTemplate("TIE Interceptor"):setFaction("Imperial"):setCallSign("Rho"):setPosition(2500,25000)
	self.carrier:setWarpDrive(true)
end
