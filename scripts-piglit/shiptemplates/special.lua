--[[ Technician Cruiser from Player Light Cruiser--]]
--template = ShipTemplate():setName("Technician Cruiser"):setClass("Frigate", "Light Cruiser"):setType("playership")
--template:setModel("MultiGunCorvetteBlue")
--template:setDescription([[This is a modified Phobos Cruiser which is the workhorse of the human navy. Its basic stats aren't impressive, and it has less power then the normal Cruisers used hy the human navy. But it can be retro-fitted and made war-ready in a breeze. However the Beam Weapons are optimised for close range repair or salvage operations and about twice as powerful as the unmodified Phobos' variation.
--]])
--template:setRadarTrace("cruiser.png")
--template:setBeamWeapon(0, 90, -15, 1000, 6, 10)
--template:setBeamWeapon(1, 90,  15, 1000, 6, 10)
--template:setTubes(1, 10.0)
--template:setTubeDirection(0, 0)
--template:weaponTubeDisallowMissle(0, "Mine")
--template:setShields(100, 100)
--template:setHull(200)
--template:setSpeed(80, 10, 20)
--template:setCombatManeuver(400, 250)
--template:setWeaponStorage("HVLI", 20)
--template:setWeaponStorage("Homing", 10)
--template:setWeaponStorage("Nuke", 0)
--template:setWeaponStorage("Mine", 0)
--template:setWeaponStorage("EMP", 3)
--template:setJumpDrive(true)
--
--template:addRoomSystem(1, 0, 2, 1, "Maneuver");
--template:addRoomSystem(1, 1, 2, 1, "BeamWeapons");
--template:addRoom(2, 2, 2, 1);
--template:addRoomSystem(0, 3, 1, 2, "RearShield");
--template:addRoomSystem(1, 3, 2, 2, "Reactor");
--template:addRoomSystem(3, 3, 2, 2, "Warp");
--template:addRoomSystem(5, 3, 1, 2, "JumpDrive");
--template:addRoom(6, 3, 2, 1);
--template:addRoom(6, 4, 2, 1);
--template:addRoomSystem(8, 3, 1, 2, "FrontShield");
--template:addRoom(2, 5, 2, 1);
--template:addRoomSystem(1, 6, 2, 1, "MissileSystem");
--template:addRoomSystem(1, 7, 2, 1, "Impulse");
--
--template:addDoor(1, 1, true);
--template:addDoor(2, 2, true);
--template:addDoor(3, 3, true);
--template:addDoor(1, 3, false);
--template:addDoor(3, 4, false);
--template:addDoor(3, 5, true);
--template:addDoor(2, 6, true);
--template:addDoor(1, 7, true);
--template:addDoor(5, 3, false);
--template:addDoor(6, 3, false);
--template:addDoor(6, 4, false);
--template:addDoor(8, 3, false);
--template:addDoor(8, 4, false);


--[[Corvette Melonidas--]]
--template = ShipTemplate():setName("Melonidas"):setClass("Corvette", "Destroyer"):setModel("AtlasDreadnoughtGreen"):setType("playership")
--template:setDescription([[The Melonidas is the smallest model of destroyer, and its combination of frigate-like size and corvette-like power makes it an excellent escort ship when defending larger ships against multiple smaller enemies. Because the Melonidas is fitted with a jump drive, it can also serve as an intersystem patrol craft.]])
--template:setRadarTrace("melon.png")
--template:setJumpDrive(true)
--template:setShields(200, 200)
--template:setHull(250)
--template:setSpeed(90, 10, 20)
--template:setCombatManeuver(400, 250)
--template:setDockClasses("Starfighter")
----                  Arc, Dir, Range, CycleTime, Dmg
--template:setBeam(0,80, -80, 1500.0, 6.0, 8)
--template:setBeam(1,80,  80, 1500.0, 6.0, 8)
--template:setBeam(2,80, -100, 1500.0, 6.0, 8)
--template:setBeam(3,80,  100, 1500.0, 6.0, 8)
--template:setWeaponStorage("Homing", 12)
--template:setWeaponStorage("Nuke", 4)
--template:setWeaponStorage("Mine", 8)
--template:setWeaponStorage("EMP", 6)
--template:setWeaponStorage("HVLI", 20)
--template:setTubes(4, 8.0) -- Amount of torpedo tubes, and loading time of the tubes.
--template:weaponTubeDisallowMissle(0, "Mine")
--template:weaponTubeDisallowMissle(1, "Mine")
--template:weaponTubeDisallowMissle(2, "Mine")
--template:weaponTubeDisallowMissle(3, "Mine")
--
--template:setTubeDirection(0, 0)
--template:setTubeDirection(1, 0):weaponTubeDisallowMissle(1, "Nuke"):weaponTubeDisallowMissle(1, "EMP")
--template:setTubeDirection(2, 0):weaponTubeDisallowMissle(2, "Nuke"):weaponTubeDisallowMissle(2, "EMP")
--template:setTubeDirection(3, 180):setWeaponTubeExclusiveFor(3, "Mine")
--
--template:addRoomSystem(1, 0, 3, 1, "Maneuver");
--template:addRoom(0, 1, 2, 1);
--template:addRoom(2, 1, 1, 1);
--template:addRoom(3, 1, 2, 1);
--template:addRoom(2, 2, 2, 1);
--template:addRoomSystem(6, 2, 2, 1, "MissileSystem");
--template:addRoomSystem(1, 3, 1, 2, "RearShield");
--template:addRoomSystem(2, 3, 2, 2, "Reactor");
--template:addRoomSystem(4, 3, 2, 2, "JumpDrive");
--template:addRoomSystem(6, 3, 2, 2, "Warp");
--template:addRoomSystem(8, 3, 1, 2, "FrontShield");
--template:addRoom(2, 5, 2, 1);
--template:addRoomSystem(6, 5, 2, 1, "BeamWeapons");
--template:addRoom(0, 6, 2, 1);
--template:addRoom(2, 6, 1, 1);
--template:addRoom(3, 6, 2, 1);
--template:addRoomSystem(1, 7, 3, 1, "Impulse");
--
--template:addDoor(2, 1, true);
--template:addDoor(2, 1, false);
--template:addDoor(3, 1, false);
--template:addDoor(2, 2, true); 
--template:addDoor(3, 3, true);
--template:addDoor(3, 5, true);
--template:addDoor(2, 6, true);
--template:addDoor(2, 6, false);
--template:addDoor(3, 6, false);
--template:addDoor(2, 7, true); 
--template:addDoor(2, 3, false);
--template:addDoor(4, 4, false);
--template:addDoor(6, 3, false);
--template:addDoor(8, 4, false);
--template:addDoor(7, 3, true);
--template:addDoor(7, 5, true);


--[[ Hack-Sat --]]
--[[template = ShipTemplate():setName("XB-4"):setClass("Satellite", "Relay"):setType("playership")
template:setModel("SensorBuoyMKII")
template:setRadarTrace("radartrace_smallstation.png")
template:setShields(20)
template:setHull(20)
template:setSpeed(0, 0, 0)
template:setCanDock(false)
template:setCanCombatManeuver(false)

-- Could be improved:
--	(H)oriz, (V)ert	   HC,VC,HS,VS, system    (C)oordinate (S)ize
template:addRoomSystem( 0, 1, 1, 2, "Impulse")
template:addRoomSystem( 1, 0, 2, 1, "RearShield")
template:addRoomSystem( 1, 1, 2, 2, "JumpDrive")
template:addRoomSystem( 1, 3, 2, 1, "FrontShield")
template:addRoomSystem( 3, 0, 2, 1, "Beamweapons")
template:addRoomSystem( 3, 1, 3, 1, "Warp")
template:addRoomSystem( 3, 2, 3, 1, "Reactor")
template:addRoomSystem( 3, 3, 2, 1, "MissileSystem")
template:addRoomSystem( 6, 1, 1, 2, "Maneuver")

-- (H)oriz, (V)ert H, V, true = horizontal
template:addDoor( 1, 1, false)
template:addDoor( 2, 1, true)
template:addDoor( 1, 3, true)
template:addDoor( 3, 2, false)
template:addDoor( 4, 3, true)
template:addDoor( 6, 1, false)
template:addDoor( 4, 2, true)
template:addDoor( 4, 1, true)
--]]

