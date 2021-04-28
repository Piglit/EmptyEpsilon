--This file contains player variations of human ships
--For better readability, the original templates are copied

require("shipSystems.lua") -- contains addSystems*

color_player = "White" --change it if you want another style



--[[Starfighter--]]

template = ShipTemplate():setName("MP52 Hornet"):setClass("Starfighter", "Interceptor"):setType("playership")
template:setModel("WespeFighter"..color_player)
template:setRadarTrace("radar_fighter.png")
template:setDescription([[The Hornet is a basic interceptor found in many corners of the galaxy. 
The MP52 Hornet is a significantly upgraded version of MU52 Hornet, with nearly twice the hull strength, nearly three times the shielding, better acceleration, impulse boosters, and a second laser cannon. Combat maneuver systems are included.]])
template:setImpulseSoundFile("sfx/engine_fighter.wav")

template:setHull(70)
template:setShields(60)
template:setSpeed(125, 32, 40)
template:setCombatManeuver(600, 0)
template:setBeam(0, 30,-5, 900.0, 4.0, 2.5)
template:setBeam(1, 30, 5, 900.0, 4.0, 2.5)
template:setEnergyStorage(400)
template:setRepairCrewCount(1)
template:setLongRangeRadarRange(5000)
template:setShortRangeRadarRange(2500)

template:setCanScan(false)
template:setCanHack(false)
template:setCanDock(true)
template:setCanCombatManeuver(false)
template:setCanLaunchProbe(false)
template:setCanSelfDestruct(false)

addSystemsWespe(template)

--[[Bomber--]]

template = ShipTemplate():setName("ZX-Lindworm"):setClass("Starfighter", "Bomber"):setType("playership")
template:setModel("LindwurmFighter"..color_player)
template:setRadarTrace("radar_fighter.png")
template:setDescription([[The WX-Lindworm, or "Worm" as it's often called, is a bomber-class starfighter. While one of the least-shielded starfighters in active duty, the Worm's two launchers can pack quite a punch. Its goal is to fly in, destroy its target, and fly out or be destroyed. The engine can be overloaded to cause a massive explotion - however this destroys the bomber, too.]])
template:setImpulseSoundFile("sfx/engine_fighter.wav")

template:setHull(75)
template:setShields(40)
template:setSpeed(70, 15, 25)
template:setTubes(3, 10.0)
template:setTubeSize(0, "small")
template:setTubeSize(1, "small")
template:setTubeSize(2, "small")
template:setWeaponStorage("HVLI", 12)
template:setWeaponStorage("Homing", 3)
template:setTubeDirection(1,-1):setWeaponTubeExclusiveFor(1, "HVLI")
template:setTubeDirection(2, 1):setWeaponTubeExclusiveFor(2, "HVLI")
--                  Arc, Dir, Range, CycleTime, Dmg
template:setBeam(0, 10, 180, 700, 6.0, 2)
--								  Arc, Dir, Rotate speed
template:setBeamWeaponTurret( 0, 270, 180, 4)
template:setCombatManeuver(250, 150)
template:setEnergyStorage(400)
template:setRepairCrewCount(1)
template:setLongRangeRadarRange(5000)
template:setShortRangeRadarRange(2500)

template:setCanScan(false)
template:setCanHack(false)
template:setCanDock(true)
template:setCanCombatManeuver(false)
template:setCanLaunchProbe(false)
template:setCanSelfDestruct(false)
addSystemsLindwurm(template)

--[[Scout--]]
template = ShipTemplate():setName("Adder MK7"):setClass("Starfighter", "Scout"):setType("playership")
template:setModel("AdlerLongRangeScout"..color_player)
template:setRadarTrace("radar_cruiser.png")
template:setDescription([[The Adder mark 7 is a superior scout with scanning and hacking capabilities.]])
template:setImpulseSoundFile("sfx/engine_fighter.wav")

template:setHull(100)
template:setShields(100)
template:setSpeed(100, 30, 30)
template:setBeam(0, 35, 0, 800, 5.0, 2.0)
template:setBeam(1, 70, -35, 600, 5.0, 2.0)
template:setBeam(2, 70, 35, 600, 5.0, 2.0)
template:setBeam(3, 35,180, 600, 6.0, 2.0)
template:setTubes(1, 10.0)
template:setTubeSize(0, "small")
template:setWeaponStorage("HVLI", 8)
template:setCombatManeuver(400, 250)
template:setEnergyStorage(400)
template:setWarpSpeed(750)
template:setRepairCrewCount(1)

template:setCanScan(true)
template:setCanHack(true)
template:setCanDock(true)
template:setCanCombatManeuver(false)
template:setCanLaunchProbe(true)
template:setCanSelfDestruct(false)
addSystemsAdler(template)

--[[ Player Light Cruiser--]]
template = ShipTemplate():setName("Phobos M3P"):setClass("Frigate", "Light Cruiser"):setType("playership")
template:setModel("MultiGunCorvette"..color_player)
template:setDescription([[The Phobos is the workhorse of the human navy. It's extremely easy to modify, which makes retro-fitting this ship a breeze. Its basic stats aren't impressive, but due to its modular nature, it's fairly easy to produce in large quantities.

This prototype variant of the Phobos M3 military light cruiser is outfitted like a battlecruiser. Not as strong as the atlantis, but has a mine-laying tube and two front firing missile tubes, making it an easier to use ship in some missions.]])
template:setRadarTrace("radar_cruiser.png")
template:setBeamWeapon(0, 90, -15, 1200, 8, 6)
template:setBeamWeapon(1, 90,  15, 1200, 8, 6)
template:setTubes(3, 10.0)
template:setTubeDirection(0, -1):weaponTubeDisallowMissle(0, "Mine")
template:setTubeDirection(1,  1):weaponTubeDisallowMissle(1, "Mine")
template:setTubeDirection(2,  180):setWeaponTubeExclusiveFor(2, "Mine")
template:setShields(100, 100)
template:setHull(200)
template:setSpeed(80, 10, 20)
template:setCombatManeuver(400, 250)
template:setWeaponStorage("HVLI", 20)
template:setWeaponStorage("Homing", 10)
template:setWeaponStorage("Nuke", 2)
template:setWeaponStorage("Mine", 4)
template:setWeaponStorage("EMP", 3)
template:setJumpDrive(true)
addSystemsMulitGun(template)

--[[ Player Laser Battlecruiser --]]
template = ShipTemplate():setName("Hathcock"):setClass("Frigate", "Battlecruiser"):setType("playership") 
template:setModel("LaserCorvette"..color_player)
template:setDescription("Long range narrow beam and some point defense beams, broadside missiles. Agile for a frigate")
template:setRadarTrace("radar_laser.png")
--						Arc, Dir, Range, CycleTime, Dmg
template:setBeamWeapon(0, 4,   0, 1400.0, 6.0, 4)
template:setBeamWeapon(1,20,   0, 1200.0, 6.0, 4)
template:setBeamWeapon(2,60,   0, 1000.0, 6.0, 4)
template:setBeamWeapon(3,90,   0,  800.0, 6.0, 4)
template:setHull(120)
template:setShields(70, 70)
template:setSpeed(50, 15, 16)
template:setTubes(2, 15.0)
template:setCombatManeuver(200, 150)
template:setWeaponStorage("Homing", 6)
template:setWeaponStorage("EMP", 2)
template:setWeaponStorage("Nuke", 1)
template:setTubeDirection(0, -90)
template:setTubeDirection(1,  90)
template:setWarpSpeed(500)

template:setRepairCrewCount(2)
addSystemsLaserAlt(template)

--[[Player Missile Cruiser--]]
template = ShipTemplate():setName("Piranha M5P"):setClass("Frigate", "Missile Cruiser"):setType("playership")
template:setModel("HeavyCorvette"..color_player)
template:setDescription([[The Piranha is a light artillery cruiser, designed to fire from broadside weapon tubes. It comes to use as a escort or defensive spacecraft, since it can quickly react to ambushes. However since it comes without beam weapons, it has proven to be useless against starfighters.

This combat-specialized Piranha M5P adds nukes, mine-laying tubes, combat maneuvering systems, and a jump drive.]])
template:setRadarTrace("radar_missile_cruiser_thin.png")
template:setTubes(8, 15.0)
template:setWeaponStorage("HVLI", 20)
template:setWeaponStorage("Homing", 12)
template:setWeaponStorage("Nuke", 6)
template:setWeaponStorage("Mine", 8)
template:setTubeDirection(0, -90)
template:setTubeDirection(1, -90):weaponTubeDisallowMissle(1, "Mine"):weaponTubeDisallowMissle(1, "Nuke"):weaponTubeDisallowMissle(1, "EMP")
template:setTubeDirection(2, -90):weaponTubeDisallowMissle(2, "Mine"):weaponTubeDisallowMissle(2, "Nuke"):weaponTubeDisallowMissle(2, "EMP")
template:setTubeDirection(3,  90)
template:setTubeDirection(4,  90):weaponTubeDisallowMissle(4, "Mine"):weaponTubeDisallowMissle(4, "Nuke"):weaponTubeDisallowMissle(4, "EMP")
template:setTubeDirection(5,  90):weaponTubeDisallowMissle(5, "Mine"):weaponTubeDisallowMissle(5, "Nuke"):weaponTubeDisallowMissle(5, "EMP")
template:setTubeDirection(6, 190):setWeaponTubeExclusiveFor(6, "Mine")
template:setTubeDirection(7, 170):setWeaponTubeExclusiveFor(7, "Mine")

template:setHull(120)
template:setShields(70, 70)
template:setSpeed(60, 10, 16)
template:setCombatManeuver(200, 150)
template:setJumpDrive(true)
template:setRepairCrewCount(2)
addSystemsHeavy(template)

--[[Player Transport--]]
template = ShipTemplate():setName("Flavia P.Falcon"):setClass("Frigate", "Light transport"):setType("playership")
template:setModel("LightCorvette"..color_player)
template:setRadarTrace("radar_tug.png")
template:setDescription([[Popular among traders and smugglers, the Flavia is a small cargo and passenger transport. It's cheaper than a freighter for small loads and short distances, and is often used to carry high-value cargo discreetly.

The Flavia Falcon is a Flavia transport modified for faster flight, and adds rear-mounted lasers to keep enemies off its back.

The Flavia P.Falcon has a nuclear-capable rear-facing weapon tube and a warp drive.]])
template:setBeam(0, 40, 170, 1200.0, 8.0, 6)
template:setBeam(1, 40, 190, 1200.0, 8.0, 6)

template:setHull(100)
template:setShields(70, 70)
template:setSpeed(60, 10, 20)
template:setWarpSpeed(500)
template:setCombatManeuver(250, 150)
template:setTubes(1, 20.0)
template:setTubeDirection(0, 180)
template:setWeaponStorage("HVLI", 5)
template:setWeaponStorage("Homing", 3)
template:setWeaponStorage("Mine", 1)
template:setWeaponStorage("Nuke", 1)
template:setRepairCrewCount(8)
addSystemsLight(template)

template = ShipTemplate():setName("Repulse"):setClass("Frigate", "Armored Transport"):setModel("LightCorvette"..color_player):setType("playership")
template:setRadarTrace("radar_tug.png")
template:setDescription("Jump/Turret version of Flavia Falcon")
template:setHull(120)
template:setShields(80, 80)
template:setSpeed(55, 9, 20)
--                 Arc, Dir, Range, CycleTime, Dmg
template:setBeam(0, 10, 90, 1200.0, 6.0, 5)
template:setBeam(1, 10,-90, 1200.0, 6.0, 5)
--								Arc, Dir, Rotate speed
template:setBeamWeaponTurret(0, 200,  90, 5)
template:setBeamWeaponTurret(1, 200, -90, 5)
template:setJumpDrive(true)
template:setCombatManeuver(250,150)
template:setTubes(2, 20.0)
template:setTubeDirection(0, 0)
template:setTubeDirection(1, 180)
template:setWeaponStorage("HVLI", 6)
template:setWeaponStorage("Homing", 4)

template:setRepairCrewCount(8)
addSystemsLight(template)

--[[Mine Layer--]]
template = ShipTemplate():setName("Nautilus"):setType("playership"):setClass("Frigate","Mine Layer"):setModel("MineLayerCorvette"..color_player)
template:setDescription("Small mine laying vessel with minimal armament, shields and hull")
template:setRadarTrace("radar_tug.png")
template:setSpeed(100, 10, 20)
template:setShields(60,60)
template:setHull(100)
--                  Arc, Dir, Range, CycleTime, Dmg
template:setBeam(0, 10,  35, 1000.0, 6.0, 6)
template:setBeam(1, 10, -35, 1000.0, 6.0, 6)
--								Arc, Dir, Rotate speed
template:setBeamWeaponTurret(0, 90,  35, 6)
template:setBeamWeaponTurret(1, 90, -35, 6)
template:setJumpDrive(true)
template:setEnergyStorage(800)
template:setCombatManeuver(250,150)
template:setTubes(3, 10.0)
template:setTubeDirection(0, 180)
template:setTubeDirection(1, 180)
template:setTubeDirection(2, 180)
template:setWeaponStorage("Mine", 12)

template:setRepairCrewCount(4)
addSystemsMineLayer(template)

--[[Corvette--]]
template = ShipTemplate():setName("Atlantis"):setClass("Corvette", "Destroyer"):setModel("AtlasHeavyDreadnought"..color_player):setType("playership")
template:setDescription([[The Atlantis X23 is the smallest model of destroyer, and its combination of frigate-like size and corvette-like power makes it an excellent escort ship when defending larger ships against multiple smaller enemies. Because the Atlantis X23 is fitted with a jump drive, it can also serve as an intersystem patrol craft.
This is a refitted Atlantis X23 for more general tasks. The large shield system has been replaced with an advanced combat maneuvering systems and improved impulse engines. Its missile loadout is also more diverse. Mistaking the modified Atlantis for an Atlantis X23 would be a deadly mistake.]])
template:setRadarTrace("radar_melon.png")
template:setJumpDrive(true)
template:setShields(200, 200)
template:setHull(250)
template:setSpeed(90, 8, 10)
template:setCombatManeuver(400, 250)
--                  Arc, Dir, Range, CycleTime, Dmg
template:setBeam(0,100, -20, 1500.0, 6.0, 8)
template:setBeam(1,100,  20, 1500.0, 6.0, 8)
template:setWeaponStorage("Homing", 12)
template:setWeaponStorage("Nuke", 4)
template:setWeaponStorage("Mine", 8)
template:setWeaponStorage("EMP", 6)
template:setWeaponStorage("HVLI", 20)
template:setTubes(5, 8.0) -- Amount of torpedo tubes, and loading time of the tubes.
template:weaponTubeDisallowMissle(0, "Mine"):weaponTubeDisallowMissle(1, "Mine")
template:weaponTubeDisallowMissle(2, "Mine"):weaponTubeDisallowMissle(3, "Mine")
template:setTubeDirection(0, -90)
template:setTubeDirection(1, -90)
template:setTubeDirection(2,  90)
template:setTubeDirection(3,  90)
template:setTubeDirection(4, 180):setWeaponTubeExclusiveFor(4, "Mine")
template:setDockClasses("Starfighter")
addSystemsAtlasAlt(template)

--[[Missile Corvette--]]
template = ShipTemplate():setName("Crucible"):setLocaleName(_("Crucible")):setClass(_("Corvette"),_("Popper")):setModel("AtlasMissileDreadnought"..color_player):setType("playership")
template:setDescription(_("A number of missile tubes range around this ship. Beams were deemed lower priority, though they are still present. Stronger defenses than a frigate, but not as strong as the Atlantis"))
template:setRadarTrace("radar_melon.png")
template:setHull(160)
template:setShields(160,160)
template:setSpeed(80,8,10)
template:setCombatManeuver(400, 250)
template:setJumpDrive(false)
template:setWarpSpeed(750)
--                  Arc, Dir,  Range, CycleTime, Dmg
template:setBeam(0, 70, -30, 1000.0, 6.0, 5)
template:setBeam(1, 70,  30, 1000.0, 6.0, 5)
template:setTubes(5, 8.0)
template:setWeaponStorage("HVLI", 24)
template:setWeaponStorage("Homing", 8)
template:setWeaponStorage("EMP", 6)
template:setWeaponStorage("Nuke", 4)
template:setWeaponStorage("Mine", 6)
template:setTubeDirection(0, 0)
template:setTubeSize(0, "large")
template:setTubeDirection(1, 0)
template:setTubeSize(1, "large")
template:setTubeDirection(2, -90)
template:setTubeDirection(3,  90)
template:setTubeDirection(4, 180)
template:setWeaponTubeExclusiveFor(0, "HVLI")
template:setWeaponTubeExclusiveFor(1, "HVLI")
template:weaponTubeDisallowMissle(2, "Mine")
template:weaponTubeDisallowMissle(3, "Mine")
template:setWeaponTubeExclusiveFor(4, "Mine")
template:setDockClasses("Starfighter")

template:setRepairCrewCount(4)
addSystemsAtlas(template)

--[[Beam Corvette--]]
template = ShipTemplate():setName("Maverick"):setLocaleName(_("Maverick")):setClass(_("Corvette"),_("Gunner")):setModel("AtlasLaserDreadnought"..color_player):setType("playership")
template:setDescription(_("A number of beams bristle from various points on this gunner. Missiles were deemed lower priority, though they are still present. Stronger defenses than a frigate, but not as strong as the Atlantis"))
template:setRadarTrace("radar_melon.png")
template:setHull(160)
template:setShields(160,160)
template:setSpeed(80,8,10)
template:setCombatManeuver(400, 250)
template:setJumpDrive(false)
template:setWarpSpeed(800)
--                 Arc, Dir,  Range, CycleTime, Dmg
template:setBeam(0, 10,   0, 2000.0, 6.0, 6)
template:setBeam(1, 90, -20, 1500.0, 6.0, 8)
template:setBeam(2, 90,  20, 1500.0, 6.0, 8)
template:setBeam(3, 40, -70, 1000.0, 4.0, 6)
template:setBeam(4, 40,  70, 1000.0, 4.0, 6)
template:setBeam(5, 10, 180,  800.0, 6.0, 4)
--								Arc, Dir, Rotate speed
template:setBeamWeaponTurret(5, 180, 180, .5)
template:setTubes(3, 8.0)
template:setWeaponStorage("HVLI", 10)
template:setWeaponStorage("Homing", 6)
template:setWeaponStorage("EMP", 4)
template:setWeaponStorage("Nuke", 2)
template:setWeaponStorage("Mine", 2)
template:setTubeDirection(0, -90)
template:setTubeDirection(1,  90)
template:setTubeDirection(2, 180)
template:weaponTubeDisallowMissle(0, "Mine")
template:weaponTubeDisallowMissle(1, "Mine")
template:setWeaponTubeExclusiveFor(2, "Mine")

template:setDockClasses("Starfighter")
template:setRepairCrewCount(4)
addSystemsAtlas(template)
 
--[[---------------------Carrier------------------------]]
template = ShipTemplate():setName("Benedict"):setClass("Corvette", "Freighter"):setModel("transport_4_2")
template:setType("playership")
template:setDescription([[The Jump Carrier is a specialized Freighter. It does not carry any cargo, as it's cargo bay is taken up by a specialized jump drive and the energy storage required to run this jump drive.
It is designed to carry other ships deep into space. So it has special docking parameters, allowing other ships to attach themselves to this ship.
Benedict is an improved version of the Jump Carrier]])
template:setRadarTrace("radar_transport.png")
template:setJumpDrive(true)
template:setDockClasses("Starfighter", "Frigate", "Corvette")
--template:setSharesEnergyWithDocked(true)
template:setShields(70, 70)
template:setHull(200)
template:setSpeed(60, 6, 8)
--                  Arc, Dir, Range, CycleTime, Dmg
template:setBeam(0, 10,   0, 1500.0, 6.0, 4)
template:setBeam(1, 10, 180, 1500.0, 6.0, 4)
--								 Arc, Dir, Rotate speed
template:setBeamWeaponTurret( 0, 90,   0, 6)
template:setBeamWeaponTurret( 1, 90, 180, 6)
template:setCombatManeuver(400, 250)
template:setJumpDriveRange(5000, 90000) 
template:setRestocksMissilesDocked(true)
template:setSharesEnergyWithDocked(true)
template:setRestocksScanProbes(true)
template:setRepairDocked(true)
addSystemsTransport(template)

template:setRepairCrewCount(6)
var2 = template:copy("Kiriya")
var2:setDescription("Kiriya is an improved warp drive version of the Jump Carrier")
var2:setJumpDrive(false)
var2:setWarpSpeed(750)


