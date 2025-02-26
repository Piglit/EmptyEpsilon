-- Name: Fighter Pilot
-- Description: [Station Tutorial]
--- -------------------
--- -Goes over controlling a fighter.
--- -Covers maneuvering and combat
---
--- [Station Info]
--- -------------------


require("tutorial/00_all.lua")

function init()
    tutorial_list = {
        fighterTutorial,
        fighterPowerTutorial,
        endOfFighterTutorial
    }
    startTutorialFighter()
end

