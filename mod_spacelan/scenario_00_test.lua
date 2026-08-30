-- Name: Comms test
-- Description: used to test comms scrpts
-- Type: Development

--- Scenario
-- @script scenario_10_empty

require("utils.lua")
require("plots/wh_rota.lua")
require("plots/vf_trade_network.lua")
require("plots/vf_upgrades.lua")
require("comms/comms_vf_ship.lua")
require("comms/comms_vf_station.lua")
require("comms/comms_vf_weapons.lua")
require("comms/comms_vf_military.lua")
require("comms/comms_vf_scenario_management.lua")
require("comms/comms_vf_scenario_arlenians.lua")
require("place_station_scenario_utility.lua")

function init()
	local enemy_faction = "Kraylor"

	PlayerSpaceship():setTemplate("Adder MK7"):setCallSign("A1"):setPosition(1000, 0):setFaction("Human Navy"):setReputationPoints(2000)--:setRadarTrace("probe.png")
    local hn = CpuShip():setTemplate("Adder MK5"):setPosition(0, 2000):setFaction("Human Navy"):orderIdle()
    local ind = CpuShip():setTemplate("Adder MK5"):setPosition(1000, 2000):setFaction("Independent"):orderIdle()
--    local enemy_unknown = CpuShip():setTemplate("Adder MK5"):setPosition(-1000, -2000):setFaction(enemy_faction):orderIdle()
--    local enemy_known = CpuShip():setTemplate("Adder MK5"):setPosition(1000, -2000):setFaction(enemy_faction):setScannedByFaction("Human Navy", true):orderIdle()
	local station1 = SpaceStation():setTemplate("Arlenian Shipyard"):setPosition(2500, 0):setFaction("Arlenians")
	local station2 = placeStation(-500,0, "Asimov", "Arlenians")
	local station3 = SpaceStation():setTemplate("Arlenian Motherstation"):setPosition(0, 1000):setFaction("Arlenians")
																		  
	comms_vf_ship.main:set_as_comms_function(hn)
	comms_vf_ship.main:set_as_comms_function(ind)
--	comms_vf_ship.main:set_as_comms_function(enemy_unknown)
--	comms_vf_ship.main:set_as_comms_function(enemy_known)
	comms_vf_station.entry:set_as_comms_function(station1)
	comms_vf_station.entry:set_as_comms_function(station2)
	comms_vf_station.entry:set_as_comms_function(station3)

	station2.comms_data.service_available = {
		activatedefensefleet = true,
		reinforcements = true,
	}
	--station2.comms_data.orig_faction = "Independent"
end

function update(delta)
	vf_trade_network:update(delta)
	for _, ship in ipairs(getActivePlayerShips()) do
		vf_upgrades:updatePlayerShip(delta, ship)
	end
end
