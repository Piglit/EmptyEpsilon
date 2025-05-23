-- Name: Tactical
-- Description: [Station Tutorial]
--- -------------------
--- -Goes over controlling movement of the ship.
--- -Goes over weapon controls
---
require("tutorial/00_all.lua")

function init()
    tutorial_list = {
        helmsTutorial,
		weaponsTutorial,
        endOfTutorial
    }
    startTutorial()
end
