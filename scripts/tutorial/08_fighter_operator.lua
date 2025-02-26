-- Name: Fighter Operator
-- Description: [Station Tutorial]
--- -------------------
--- -Goes over controlling a fighter with an additional operators screen.
---
--- [Station Info]
--- -------------------


require("tutorial/07_pilot.lua")

function init()
    tutorial_list = {
		fighterTutorial,
		fighterPowerTutorial,
		fighterOperatorTutorial,
        endOfFighterTutorial
    }
    startTutorialFighter()
end


