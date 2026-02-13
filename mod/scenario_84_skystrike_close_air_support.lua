-- Name: Close Air Support
-- Description: The Skystrike Academy practices Close Air Support
-- Type: Larp

TEST = false
require("utils.lua")
require("plot_manager.lua")


function init()
	plot_manager:init({
		"gravity_util",
		"map_ice_planet",
		"map_ambush",
		"rescue_capsule_util",
		"proximity_scan",
		"fighter_utils",
		{"cas", cas},
	})
end

cas = {}	-- local module for plot manager

--[[ Close Air Support Design
What is always there:
* Attack Team (Players): 4 TIEs + 1 Carrier
* CPU Target: FTR / Shuttle / Station
* Goal: Destroy specific systems of the target
* Friendly Boarding Team (TB? TR)
What can be there:
* Enemy Support
* Enemy Decoy (similar targets)
* Enemy Reinforcements
* Friendly Support (+Resupplies?)
Mechanics: Respawn
* Gozanti can spawn new TIEs for captured pilots
* (other Gozanti jumps from Hyperspace, carrying more TIEs)
* FTR with more TIEs?
--]]

function cas:init()
	local x,y = 40000, 0
	local carrier = PlayerSpaceship():setTemplate("Gozanti Mk Ic"):setCallSign("QoW"):setFaction("Imperial"):setCanBeDestroyed(false):setJumpDrive(true):setPosition(x, y):setRotation(180):commandTargetRotation(180)
	local station = map_ice_planet.station_high
	-- TIEs
	for i=1,fighter_utils.number_of_rhos do
		local rho = fighter_utils:createRho(i)
		fighter_utils:placeFighterInCarrier(rho, carrier, i)
	end
end


