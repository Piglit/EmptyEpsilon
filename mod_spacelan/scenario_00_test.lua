-- Name: Comms test
-- Description: used to test comms scrpts
-- Type: Development

--- Scenario
-- @script scenario_10_empty

require("utils.lua")
require("comms/comms_vf_ship.lua")
require("comms/comms_vf_weapons.lua")	-- HACK for testability
require("comms/comms_vf_station.lua")
require("place_station_scenario_utility.lua")

function init()

	PlayerSpaceship():setTemplate("Phobos M3P"):setCallSign("A1"):setPosition(1000, 0):setFaction("Human Navy"):setReputationPoints(200)
    local other = CpuShip():setTemplate("Adder MK5"):setPosition(0, 2000):setFaction("Human Navy")
	local station1 = SpaceStation():setTemplate("Medium Station"):setPosition(2500, 0):setFaction("Independent")
	local station2 = placeStation(-500,0, "Asimov", "Human Navy")
																		  
	comms_vf_ship.main:set_as_comms_function(other)
	comms_vf_station.entry:set_as_comms_function(station1)
	comms_vf_station.entry:set_as_comms_function(station2)

	station2.comms_data.service_available = {
		activatedefensefleet = true,
		reinforcements = true,
	}
end
