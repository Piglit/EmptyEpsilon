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

--[[Fighter tutorial--]]
function startTutorialFighter()
    --player = PlayerSpaceship():setFaction("Imperial"):setTemplate("TIE-Interceptor")
    tutorial:setPlayerShip(player)
    resetPlayerShip()
    tutorial:switchViewToScreen(9)
    tutorial:showMessage(_([[Welcome to the TIE-Fighter tutorial.
Note that this tutorial is designed to give you a quick overview of the basic functions of your TIE, but does not cover every single aspect.

Press next (]]) .. tutorial:showHotkey("TUTORIAL_NEXT") .. _([[) to continue.
To abort the tutorial at any time press ]]) .. tutorial:showHotkey("ESCAPE") .. ".", true)
    tutorial:onNext(function()
        tutorial_list_index = 1
        startSequence(tutorial_list[tutorial_list_index])
    end)
end

endOfFighterTutorial = createSequence()
addToSequence(endOfFighterTutorial, function() tutorial:switchViewToScreen(9) end)
addToSequence(endOfFighterTutorial, function() tutorial:setMessageToTopPosition() end)
addToSequence(endOfFighterTutorial, _([[This concludes the tutorial. While we have covered the basics, there are more advanced features that you might discover.

After you press next, your controls will be transferred to your actual ship. Contact flight control and let them know you are on standby.]]))

fighterTutorial = createSequence()

addToSequence(fighterTutorial, function() resetPlayerShip() end)
addToSequence(fighterTutorial, function() tutorial:switchViewToScreen(9) end)
addToSequence(fighterTutorial, function() tutorial:setMessageToTopPosition() end)
addToSequence(fighterTutorial, _([[This is your cockpit whith its controls and display panels.
The short-range radar on the right side allows you to quickly identify nearby objects.]]))

--radar
addToSequence(fighterTutorial, _([[Your ship is depicted at the radar's center. This radar can detect objects up to 5u from your ship.]]))
addToSequence(fighterTutorial, function() prev_object = Asteroid():setPosition(2500, 0):setSize(243) end)
addToSequence(fighterTutorial, _([[This is an asteroid. Flying into an asteroid will damage your ship, so avoid hitting them.]]))
addToSequence(fighterTutorial, function() prev_object:destroy() end)
addToSequence(fighterTutorial, function() prev_object = Mine():setPosition(2500, 0) end)
addToSequence(fighterTutorial, _([[The white dot is a mine. When you move near a mine, it explodes with a powerful 1u-radius blast. Striking a mine will surely destroy your ship.]]))
addToSequence(fighterTutorial, function() prev_object:destroy() end)
addToSequence(fighterTutorial, function() prev_object = SpaceStation():setTemplate("Medium Station"):setFaction("Imperial"):setPosition(2500, 0) end)
addToSequence(fighterTutorial, function() prev_object2 = SpaceStation():setTemplate("Large Station"):setFaction("Independent"):setPosition(2500, 2500) end)
addToSequence(fighterTutorial, function() prev_object3 = SpaceStation():setTemplate("Huge Station"):setFaction("Rebel Alliance"):setPosition(2500, -2500) end)
addToSequence(fighterTutorial, _([[These are stations. Stations can be several different sizes and belong to different factions. Their color on the radar indicates whether the station is friendly (green), neutral (light blue), or hostile (red).]]))
addToSequence(fighterTutorial, function() prev_object:destroy() end)
addToSequence(fighterTutorial, function() prev_object2:destroy() end)
addToSequence(fighterTutorial, function() prev_object3:destroy() end)
addToSequence(fighterTutorial, function() prev_object = Nebula():setPosition(4000, 0) end)
addToSequence(fighterTutorial, _([[The rainbow-colored cloud is a nebula. Nebulae block long-range sensors, preventing larger ships from detecting what's inside of them at distances of more than 5u. Sensors also cannot detect objects behind nebulae.]]))
addToSequence(fighterTutorial, function() prev_object:destroy() end)
addToSequence(fighterTutorial, function() prev_object = CpuShip():setFaction("Imperial"):setTemplate("Phobos T3"):setPosition(1500, -750):orderIdle():setScanned(true):setRotation(0) end)
addToSequence(fighterTutorial, function() prev_object2 = CpuShip():setFaction("Independent"):setTemplate("Phobos T3"):setPosition(1500, 750):orderIdle():setScanned(true):setRotation(0) end)
addToSequence(fighterTutorial, function() prev_object3 = CpuShip():setFaction("Rebel Alliance"):setTemplate("Phobos T3"):setPosition(1500, -2500):orderIdle():setScanned(true):setRotation(0) end)
addToSequence(fighterTutorial, function() prev_object4 = CpuShip():setFaction("Rebel Alliance"):setTemplate("Phobos T3"):setPosition(1500, 2500):orderIdle():setScanned(false):setRotation(0) end)
addToSequence(fighterTutorial, _([[Finally, these are ships. Their attitude toward you is reflected by the same colors on your radar as stations. In addition to green, blue, and red, ships of unknown attitude appear as gray objects on the radar.

On your radar you can also see the range of their weapons (the red arcs) and the status of their shields (the blue circles)]]))
addToSequence(fighterTutorial, function() prev_object:destroy() end)
addToSequence(fighterTutorial, function() prev_object2:destroy() end)
addToSequence(fighterTutorial, function() prev_object3:destroy() end)
addToSequence(fighterTutorial, function() prev_object4:destroy() end)

--helms
addToSequence(fighterTutorial, function()
    tutorial:setMessageToTopPosition()
    resetPlayerShip()
    player:setJumpDrive(false)
    player:setWarpDrive(false)
    player:setCanCombatManeuver(false)
    player:setImpulseMaxSpeed(0);
    player:setRotationMaxSpeed(0);
end)
addToSequence(fighterTutorial, _([[Let's look at the more active instruments in your cockpit.]]))
addToSequence(fighterTutorial, function() player:setImpulseMaxSpeed(90) end)
addToSequence(fighterTutorial, _([[As fighter pilot, you command your ship's movement in space.
Your primary controls are your impulse engines and maneuvering thrusters.

Raise your impulse level to 100% to fly forward right now. (]]) .. tutorial:showHotkey("HELMS_IMPULSE_INCREASE") .. ")", function() return distance(player, 0, 0) > 1000 end)
addToSequence(fighterTutorial, function() player:setImpulseMaxSpeed(0):commandImpulse(0):setRotationMaxSpeed(10) end)
addToSequence(fighterTutorial, _([[Good. You now know how to move forward.

I've disabled your impulse engine for now. Next, let's rotate your ship.
Try rotating to heading 200 right now. (]]) .. tutorial:showHotkey("HELMS_TURN_RIGHT") .. ")", function() return math.abs(player:getHeading() - 200) < 1.0 end)
addToSequence(fighterTutorial, function() player:setImpulseMaxSpeed(90) end)
addToSequence(fighterTutorial, function() prev_object = SpaceStation():setTemplate("Medium Station"):setFaction("Human Navy"):setPosition(0, -1500) end)
addToSequence(fighterTutorial, _([[Excellent!

Next up: docking. To dock, maneuver within 1u of a station and press the "Request Dock" button (]]) .. tutorial:showHotkey("HELMS_DOCK_ACTION") .. _([[), from which point docking is fully automated.
Maneuver to the nearby station and request permission to dock.]]), function() return player:isDocked(prev_object) end)
addToSequence(fighterTutorial, _([[Now that you are docked, your movement is locked. There is nothing else you can do but undock, so do that now. (]]) .. tutorial:showHotkey("HELMS_DOCK_ACTION") .. ")", function() return not player:isDocked(prev_object) end)
addToSequence(fighterTutorial, function() prev_object:destroy() end)
addToSequence(fighterTutorial, _([[Ok, there are just a few more things that you need to know.
As fighter pilot, you are responsible for firing with laser weapons on your target.]]))

--weapons
addToSequence(fighterTutorial, function()
    resetPlayerShip()
    player:setJumpDrive(false)
    player:setWarpDrive(false)
    player:setImpulseMaxSpeed(0)
    player:setRotationMaxSpeed(0)
    player:setWeaponStorageMax("laser_green", 99)
    player:setWeaponStorage("laser_green", 99)
    player:setWeaponTubeCount(2)
	player:commandLoadTube(0,"laser_green")
	player:commandLoadTube(1,"laser_green")
    prev_object = CpuShip():setFaction("Rebel Alliance"):setTemplate("Flavia"):setPosition(1500, 0):setRotation(0):orderIdle():setScanned(true)
    prev_object:setHull(1):setShieldsMax(1) -- Make it die in 1 shot.
end)
addToSequence(fighterTutorial, _([[Now fire your lasers at the enemy ship! (]]) .. tutorial:showHotkey("WEAPONS_FIRE_TUBE1") .. ")", function() return not prev_object:isValid() end)

addToSequence(fighterTutorial, function() prev_object = CpuShip():setFaction("Rebel Alliance"):setTemplate("X-Wing"):setPosition(3000, -1500):setRotation(0):orderIdle():setScanned(true):setHullMax(30):setHull(30):setShieldsMax(1)end)
addToSequence(fighterTutorial, function() player:setImpulseMaxSpeed(90) end)
addToSequence(fighterTutorial, function() player:setRotationMaxSpeed(10) end)
addToSequence(fighterTutorial, _([[Your most fundamental task is to get your enemy in the range of your ship's weapons. Attack that fighter you can see on your radar with your laser weapons.

If you are having trouble to see the target on your screen, select it on your radar (]]) ..tutorial:showHotkey("WEAPONS_TARGET_NEXT") .. _([[).
Notice that your laser weapons have a range of 2u.]]), function() return prev_object:getHull() ~= prev_object:getHullMax() end)

addToSequence(fighterTutorial, _([[You can hold the fire-button down for rapid fire.

Take a look on your radar while firing, when the target is hit, the blue circle around it flickers red.

Now destroy that target!]]), function() return not prev_object:isValid() end)
addToSequence(fighterTutorial, _([[Aggression is not always the solution, but boy, it is fun!

Now we will take a look at the engineering console. To switch to the engineering console press ]]) .. tutorial:showHotkey("STATION_NEXT"))

--engineer
fighterPowerTutorial = createSequence()
addToSequence(fighterPowerTutorial, function()
    tutorial:switchViewToScreen(2)
    tutorial:setMessageToTopPosition()
    resetPlayerShip()
	player:setRepairCrewCount(0)
end)
addToSequence(fighterPowerTutorial, _([[Welcome to engineering.
Engineering is split into two parts. The top part shows your ship's interior, including damage control teams stationed throughout.
The bottom part controls power and coolant levels of your ship's systems.]]))

addToSequence(fighterPowerTutorial, _([[First, we will explain your control over your ship's systems.
Each row on the bottom area of the screen represents one of your ship's system, and each system has a damage level, heat level, power level, and coolant level.]]))

addToSequence(fighterPowerTutorial, _([[You can cycle through the systems with ]]) .. tutorial:showHotkey("ENGINEERING_SELECT_SYSTEM_NEXT") .. _([[ and ]]) .. tutorial:showHotkey("ENGINEERING_SELECT_SYSTEM_PREV") .. _([[. This will show you additional details of that systems performance.

Select maneuvering now.]]))

addToSequence(fighterPowerTutorial, _([[You can manage each system's power level independently. Adding power to a system makes it perform more effectively, but also generates more heat, and thus requires coolant to prevent it from overheating and damaging the system.

Maximize the power to the maneuvering system. (]]) .. tutorial:showHotkey("ENGINEERING_POWER_INCREASE") .. ")", function() return player:getSystemPower("maneuver") > 2.5 end)
addToSequence(fighterPowerTutorial, _([[The added power increases the amount of heat in the system.
To prevent damage, your ship is automatically putting coolant in your maneuvering system.
Overpower the system until it overheats.]]), function() return player:getSystemHealth("maneuver") < 0.5 end)
addToSequence(fighterPowerTutorial, function() player:setSystemPower("maneuver", 0.0) end)
addToSequence(fighterPowerTutorial, function() player:commandSetSystemPowerRequest("maneuver", 0.0) end)
addToSequence(fighterPowerTutorial, _([[Note that as the system overheats, it takes damage. Because the system is damaged, it functions less effectively.

Systems can also take damage when your ship is hit.]]))

--addToSequence(fighterPowerTutorial, _([[In this top area, you see your damage control droid in your ship.]]))
addToSequence(fighterPowerTutorial, _([[The maneuvering system is damaged, as indicated by the color of this room's outline.]]))

--Your droid will automatically repair damaged ship systems. Repairs will take a while.]]), function() player:commandSetSystemPowerRequest("maneuver", 0.0) return player:getSystemHealth("maneuver") > 0.9 end)

addToSequence(fighterPowerTutorial, function() player:setSystemHeat("beamweapons", 0.8) end)
addToSequence(fighterPowerTutorial, function() player:setSystemHeat("impulse", 0.8) end)
addToSequence(fighterPowerTutorial, _([[I've also overheated the weapons and impulse systems. As before, the system's coolant level is increased to mitigate the effect. Note that the maneuvering system's coolant level is automatically reduced to allow for coolant in the impulse and beam weapons system.

This is because you have a limited amount of coolant available to distribute this across your ship's systems.]]), function() return player:getSystemHeat("impulse") < 0.05 end)

addToSequence(fighterPowerTutorial, _([[Good. Now you know your most important tasks. Next, we'll go over each system's function in detail.
Remember, each system performs better with more power, but performs less well when damaged. It is your job to keep vital systems running as well as you can.]]))
addToSequence(fighterPowerTutorial, _([[Reactor:

The reactor generates energy. Adding power to the reactor increases your energy generation rate.]]))
addToSequence(fighterPowerTutorial, _([[Beam Weapons:

Adding power to the beam weapons system increases their rate of fire, which causes them to do more damage.
Note that every beam you fire adds additional heat to the system.]]))
addToSequence(fighterPowerTutorial, _([[Maneuvering:

Increasing power to the maneuvering system allows the ship to turn faster.]]))
addToSequence(fighterPowerTutorial, _([[Impulse Engines:

Adding power to the impulse engines increases your flight speed.]]))

addToSequence(fighterPowerTutorial, _([[This concludes the overview of the engineering station. Be sure to keep your ship running in top condition!]]))

-- operations
fighterOperatorTutorial = createSequence()
addToSequence(fighterOperatorTutorial, function()
    tutorial:switchViewToScreen(7)
    tutorial:setMessageToBottomPosition()
    resetPlayerShip()
end)
addToSequence(fighterOperatorTutorial, function() player:setLongRangeRadarRange(15000) end)
addToSequence(fighterOperatorTutorial, _([[Welcome, operations officer.
To switch from your cockpit to the operation console later press ]]) .. tutorial:showHotkey("STATION_NEXT") .._([[.

You are the eyes of the squadron. Your job is to supply the other pilotes with information. From this station, you can detect and scan objects at a range of up to 15u.]]))
addToSequence(fighterOperatorTutorial, function() prev_object = SpaceStation():setTemplate("Medium Station"):setFaction("Imperial"):setPosition(3000, -5000) end)
addToSequence(fighterOperatorTutorial, function() prev_object2 = CpuShip():setFaction("Imperial"):setTemplate("Phobos T3"):setPosition(5000, -7000):orderIdle():setScanned(true) end)
addToSequence(fighterOperatorTutorial, _([[On this radar, you can select objects to get information about them.
I've added a friendly ship and a station for you to examine. Select them (]]) .. tutorial:showHotkey("SCIENCE_SELECT_NEXT_SCANNABLE") .. _([[) and notice how much information you can observe.
Heading and distance are of particular importance, as without these, the pilotes will be flying in the dark.]]))
addToSequence(fighterOperatorTutorial, function() prev_object:destroy() end)
addToSequence(fighterOperatorTutorial, function() prev_object = CpuShip():setFaction("Rebel Alliance"):setTemplate("Phobos T3"):setPosition(3000, -5000):orderIdle() end)
addToSequence(fighterOperatorTutorial, _([[I've replaced the friendly station with an unknown ship. Once you select it (]]) .. tutorial:showHotkey("SCIENCE_SELECT_NEXT_SCANNABLE") .. _([[), notice that you know nothing about this ship.
To learn about it, you must scan it. Scanning requires you to match your scanner's frequency bands to your target's. (]]) .. tutorial:showHotkey("SCIENCE_SCAN_PARAM_INCREASE_1") .. _([[)
Scan this ship now. (]]) .. tutorial:showHotkey("SCIENCE_SCAN_OBJECT") .. ")", function() return prev_object:isScannedBy(player) end)
addToSequence(fighterOperatorTutorial, _([[Good. Notice that you now know this ship is unfriendly. It might have been a friendly or neutral ship as well, but until you scanned it, you do not know.]]))
addToSequence(fighterOperatorTutorial, _([[Note that you have less information about this ship than the friendly ship. You must perform a deep scan of this ship to acquire more information.
A deep scan takes more effort and requires you to align 2 different frequency bands simultaneously. (]]) .. tutorial:showHotkey("SCIENCE_SCAN_PARAM_INCREASE_1") .. _([[ and ]]) .. tutorial:showHotkey("SCIENCE_SCAN_PARAM_INCREASE_2") .. _([[)
Deep scan the enemy now. (]]) .. tutorial:showHotkey("SCIENCE_SCAN_OBJECT") .. ")", function() return prev_object:isFullyScannedBy(player) end)
addToSequence(fighterOperatorTutorial, _([[Excellent. Notice that this took more time and concentration than the simple scan, so be careful to perform deep scans only when necessary or you could run out of time. You can also abort a running scan if it takes too long (]]) .. tutorial:showHotkey("SCIENCE_SCAN_ABORT") .. ")")
addToSequence(fighterOperatorTutorial, function() prev_object:destroy() end)
addToSequence(fighterOperatorTutorial, function() prev_object2:destroy() end)
addToSequence(fighterOperatorTutorial, function() tutorial:setMessageToTopPosition() end)
addToSequence(fighterOperatorTutorial, _([[Next to the long-range radar, the science station can also access the science database.

In this database, you can look up details on things like ship types, weapons, and other objects.]]))
addToSequence(fighterOperatorTutorial, _([[Remember, your job is to supply information. Knowing the location and status of other ships is vital to your squadron.

Without your information, the pilotes are mostly blind.]]))


