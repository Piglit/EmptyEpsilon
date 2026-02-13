-- Name: Rescue training
-- Description: Simple attack and gather asset maneuver for a carrier or a TIE squad. 
-- Type: Larp

TEST = false
require("utils.lua")
require("plot_manager.lua")

function init()
	-- collection of scripts from different sources for the plot_manager
	plot_manager:init({
		"gravity_util",
		"map_ice_planet",
		"map_ambush",
		"rescue_capsule_util",
		"proximity_scan",
		"fighter_utils",
		{"training", ss_training},	-- from this file
	})
end

ss_training = {
	docked_number = 1,
}

--[[ Scenario plot:

Design Goal:
* First mission to learn the game
* learn basic mechanics that are commonly used in the following maneuvers

Queen of Watch (carrier):
* Scan ambush site (using probe)
* Goto ambush site
* Destroy enemy ship(s)
* Gather dropped asset
* Return to station

TIEs (fighters):
* Launch from Gozanti
* Attack droid
* Gather pilot
* Return to Gozanti
--]]

function ss_training:init()
	-- station with ties:
	local x,y = 20000, -5000
	local station = map_ice_planet.station_high
	-- TIEs
	local x,y = radialPosition(x, y, 5001, 30)
	for i=1,fighter_utils.number_of_rhos do
		local rho = fighter_utils:createRho(i)
		fighter_utils:placeFighterInCarrier(rho, station, i)	-- misleading: station is the carrier here!
		-- enemies for TIEs
		local obj = CpuShip():setTemplate("Viper Droid"):orderStandGround():setFaction("Target")
		setCirclePos(obj, x, y, i*360/fighter_utils.number_of_rhos, 400)
		rho:commandAddWaypoint(x,y)
		station:sendCommsMessage(rho, _([[Missionsziel:
Der verunglückte Pilot "Alpha-1" muss von der RHO-Staffel geborgen und zurück zur Station gebracht werden.
Eine Gruppe bewaffneter Droiden ist in der Nähe - sie sind bei Bedarf zu zerstören.]]))
	end
	-- target for ties
	local pod = rescue_capsule_util.spawnNewPilotPod(x,y):setCallSign("Alpha-1"):setRotation(180):commandTargetRotation(180)

	-- gozanti
	local x,y = -5000, 15000
	local carrier = PlayerSpaceship():setTemplate("Gozanti Mk Ic"):setCallSign("QoW"):setFaction("Imperial"):setCanBeDestroyed(false):setJumpDrive(true):setPosition(x, y)
	-- target
	local x,y = 22500, 20000-2500

	local obj = CpuShip():setTemplate(" HWK-290"):setPosition(x,y):orderDefendLocation(x,y):setFaction("Target")
	local pod = rescue_capsule_util.spawnNewPilotPod(x,y):setCallSign("Beta-1"):setRotation(180):commandTargetRotation(180)
	carrier:commandAddWaypoint(20000,20000)
	station:sendCommsMessage(carrier, _([[Missionsziel:
Der verunglückte Pilot "Beta-1" muss von der Queen of Watch gefunden, geborgen und zum Skystrike-Dock zurückgebracht werden.
Der letzte bekannte Aufenthaltsort des Jägers des Piloten wurde als Wegpunkt markiert.
Vorsicht: wir kennen nicht die Ursache seines Verschwindens. Genaue Aufklährung ist angeraten.]]))
end

