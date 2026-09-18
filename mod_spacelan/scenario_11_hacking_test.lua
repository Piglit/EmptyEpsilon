-- Name: Hacking test
-- Description: A ship to hack, so that you can test minigames quickly.
-- Type: Development

--- Scenario
-- @script scenario_11_hacking_test

require("utils.lua")
require("comms/comms_vf_ship.lua")


function init()
	PlayerSpaceship():setFaction("Human Navy"):setTemplate("Adder MK7"):setPosition(-7889, 5778)
	CpuShip():setFaction("Kraylor"):setTemplate(" Adder MK7"):setCallSign("HackMe"):setPosition(-5444, 5889):orderIdle()
		:setImpulseMaxSpeed(0.0)
		:setImpulseMaxReverseSpeed(0.0)
		:setRotationMaxSpeed(0.0)
		:setRotationMaxSpeed(0.0)
		:setWarpDrive(false)
		:setWarpSpeed(0.00)
		:setWeaponTubeCount(0)
		:setWeaponStorage("HVLI", 0)
		:setScanned(true)
end

function update(delta)
end

-- Set callback function
onNewPlayerShip(
    function(ship)
        -- Decide what you do with new ships:
        print(ship, ship.typeName, ship:getTypeName(), ship:getCallSign())
        -- ship:destroy()
    end
)
