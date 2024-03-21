--This file contains player variations of human ships
--For better readability, the original templates are copied

require("shipSystems.lua") -- contains addSystems*

color_player = "White" --change it if you want another style



----[[Starfighter--]]
---- what is fun: always having to maneuver to keep behind the enemy.
--template = ShipTemplate():setName("MP52 Hornet"):setClass(_("class", "Starfighter"), _("subclass", "Interceptor")):setType("playership")
--template:setModel("WespeFighter"..color_player)
--template:setRadarTrace("tie_fighter.png")
--template:setDescription([[The MP52 Hornet interceptor is a fast but fragile starfighter of the Human Navy. Conveived for high-speed surgical strikes, distraction maneuvers and escor fighter duty.]])
--template:setImpulseSoundFile("sfx/engine_fighter.wav")
--
--template:setHull(70)
--template:setShields(60)
----				spped, turn, accel, rev-speed, rev-accel
--template:setSpeed(125, 32, 40, 125, 20)
--template:setCombatManeuver(600, 0)
--template:setBeam(0, 30,-5, 900.0, 4.0, 2.5)
--template:setBeam(1, 30, 5, 900.0, 4.0, 2.5)
--template:setEnergyStorage(400)
--template:setRepairCrewCount(1)
--template:setLongRangeRadarRange(10000)
--template:setShortRangeRadarRange(5000)
--
--template:setCanScan(false)
--template:setCanHack(false)
--template:setCanDock(true)
--template:setCanCombatManeuver(false)
--template:setCanLaunchProbe(false)
--template:setCanSelfDestruct(false)
--
--template:setAutoCoolant(true)
--template:setAutoMissileReload(true)
--template:setAutoRepair(true)
--
--addSystemsWespe(template)
--
--var = template:copy("MP58 Mole")	-- Drill, slower maneuver, but faster beams
---- what is fun: difficult to outmaneuver enemies if they have high turn rate
--var:setClass(_("class", "Starfighter"), _("subclass", "Laser Drill"))
--var:setDescription([[The Mole mobile drill was long used to mine small asteroids. Outfitted with a state of the art starfighter impulse engine the MP58 Mole is capable of digging holes into enemy ships.]])
--var:setModel("WespeFighterBlue")
--var:setBeam(0, 30,-5, 900.0, 3.0, 2.5)
--var:setBeam(1, 30, 5, 900.0, 3.0, 2.5)
--var:setSpeed(80, 16, 20, 70, 10)
--
---- what is fun: same as starfighter but wider beam range makes it a bit more easy
--var = template:copy("MP56 Bumblebee")	-- Wider beam range
--var:setDescription([[The MP58 Bumblebee interceptor is the upgraded version of the MP52 Hornet interceptor. Fast but fragile starfighter, conveived for high-speed surgical strikes, distraction maneuvers and escor fighter duty.]])
--var:setClass(_("class", "Starfighter"), _("subclass", "Advanced Interceptor"))
--var:setModel("WespeFighterRed")
--var:setBeam(0, 45,-5, 700.0, 4.0, 2.5)
--var:setBeam(1, 45, 5, 700.0, 4.0, 2.5)
--
--
----[[Bomber--]]
---- Dragon Names:
---- Peluda: shoots quills from back - hvli
---- Ryu: grants wishes, three claws - Rockets
---- Drac: poison breath - Mine rear
---- Cuelebre: poison breath, eat cattle, Mine Fwd
---- Zomok: bad weather - emp
---- Bashe: eaths elefants - nuke
--
---- legacy; try not to use:
--template = ShipTemplate():setName("ZX-Lindworm"):setClass(_("class", "Starfighter"), _("subclass", "Bomber")):setType("playership")
--template:setModel("LindwurmFighter"..color_player)
--template:setRadarTrace("tie_bomber.png")
--template:setDescription([[The WX-Lindworm, or "Worm" as it's often called, is a bomber-class starfighter. While one of the least-shielded starfighters in active duty, the Worm's two launchers can pack quite a punch. Its goal is to fly in, destroy its target, and fly out or be destroyed. The engine can be overloaded to cause a massive explotion - however this destroys the bomber, too.]])
--template:setImpulseSoundFile("sfx/engine_fighter.wav")
--
--template:setHull(75)
--template:setShields()
--template:setSpeed(70, 15, 25, 40, 15)
--template:setTubes(3, 10.0)
--template:setTubeSize(0, "small")
--template:setTubeSize(1, "small")
--template:setTubeSize(2, "small")
--template:setWeaponStorage("HVLI", 12)
--template:setWeaponStorage("Homing", 3)
--template:setTubeDirection(1,-1):setWeaponTubeExclusiveFor(1, "HVLI")
--template:setTubeDirection(2, 1):setWeaponTubeExclusiveFor(2, "HVLI")
----                  Arc, Dir, Range, CycleTime, Dmg
--template:setBeam(0, 10, 180, 700, 6.0, 2)
----								  Arc, Dir, Rotate speed
--template:setBeamWeaponTurret( 0, 270, 180, 4)
--template:setCombatManeuver(250, 150)
--template:setEnergyStorage(400)
--template:setRepairCrewCount(1)
--template:setLongRangeRadarRange(10000)
--template:setShortRangeRadarRange(5000)
--
--template:setCanScan(true)
--template:setCanHack(false)
--template:setCanDock(true)
--template:setCanCombatManeuver(false)
--template:setCanLaunchProbe(false)
--template:setCanSelfDestruct(true)
--
--template:setAutoCoolant(true)
--template:setAutoMissileReload(true)
--template:setAutoRepair(true)
--
--addSystemsLindwurm(template)
--
----what is fun: destroying bigger enemies. Player should always consider weather keeping up the attack or escaping is adequate. Reverse drive should be slower than enemies forward drive. But forward faster.
----Challenge: you have to sustain firing, but are too slow to escape using reverse
--var = template:copy("Peluda")	-- HVLI
--var:setClass(_("class", "Starfighter"), _("subclass", "Bomber"))
--var:setModel("LindwurmFighterGreen")
--var:setDescription([[The Peluda assault Bomber is a basic starfighter of the Human Navy; being ideally suited for attacking slow or stationary targets.]])
--var:setTubes(1,7)
--var:setWeaponStorage("Homing", 0)
--var:setWeaponStorage("HVLI", 6)
--var:setBeam(0,0,0,0,0,0)
--var:setBeamWeaponTurret(0,0,0,0)
--
--var = template:copy("Drac")	-- Mine Rear
----what is fun: short range but huge AOE
----more challenging than front mines, since reverse is slow
--var:setClass(_("class", "Starfighter"), _("subclass", "Delivery"))
--var:setModel("LindwurmFighterYellow")
--var:setDescription([[The Dray tactical mine delivery fighter is an advanced starfighter of the Human Navy, designed for surgical strikes.]])
--var:setTubes(1,20)
--var:setWeaponStorage("HVLI", 0)
--var:setWeaponStorage("Homing", 0)
--var:setWeaponStorage("Mine", 1)
--var:setTubeDirection(0,180)
--var:setBeam(0,0,0,0,0,0)
--var:setBeamWeaponTurret(0,0,0,0)
--
--var = template:copy("Cuelebre")	-- Mine Front
----what is fun: frontal mines are awesome. short range but huge AOE -> fun to place
--var:setClass(_("class", "Starfighter"), _("subclass", "Delivery"))
--var:setModel("LindwurmFighterBlue")
--var:setDescription([[The Cuelebre tactical mine delivery fighter is an advanced starfighter of the Human Navy, designed for surgical strikes.]])
--var:setTubes(1,20)
--var:setWeaponStorage("HVLI", 0)
--var:setWeaponStorage("Homing", 0)
--var:setWeaponStorage("Mine", 1)
--var:setBeam(0,0,0,0,0,0)
--var:setBeamWeaponTurret(0,0,0,0)
--
--var = template:copy("Bashe")	-- Nuke
----what is fun: the firepower of nukes from a fighter.
----not really a challenge, it is just delivery and some dodging
--var:setClass(_("class", "Starfighter"), _("subclass", "Delivery"))
--var:setModel("LindwurmFighterRed")
--var:setDescription([[The Bashe tactical nuke delivery fighter is an advanced starfighter of the Human Navy, designed for surgical strikes.]])
--var:setTubes(1,20)	-- take quite long, so combat may evolve
--var:setWeaponStorage("HVLI", 0)
--var:setWeaponStorage("Homing", 0)
--var:setWeaponStorage("Nuke", 1)
--var:setBeam(0,0,0,0,0,0)
--var:setBeamWeaponTurret(0,0,0,0)
--
----[[Still Bombers, but with Scout hull--]]
--template = ShipTemplate():setName("Ryu"):setClass(_("class", "Starfighter"), _("subclass", "Rocket Fighter")):setType("playership")
----what is fun: double torpedo insta-destroys enemy fighters!
--template:setModel("AdlerLongRangeFighterRed")
--template:setRadarTrace("tie_bomber.png")
--template:setImpulseSoundFile("sfx/engine_fighter.wav")
--template:setDescription([[The Ryu Rocket Fighter is a basic starfighter of the Human Navy; Designed for escort and anti-fighter missions.]])
--template:setTubes(2,7)
--template:setTubeSize(0, "small")
--template:setTubeSize(1, "small")
--template:setWeaponStorage("Homing", 4)
--template:setHull(75)
--template:setShields(40)
--template:setSpeed(70, 15, 25, 40, 15)
--
--template:setCombatManeuver(250, 150)
--template:setEnergyStorage(400)
--template:setRepairCrewCount(1)
--template:setLongRangeRadarRange(10000)
--template:setShortRangeRadarRange(5000)
--
--template:setCanScan(false)
--template:setCanHack(false)
--template:setCanDock(true)
--template:setCanCombatManeuver(false)
--template:setCanLaunchProbe(false)
--template:setCanSelfDestruct(false)
--
--template:setAutoCoolant(true)
--template:setAutoMissileReload(true)
--template:setAutoRepair(true)
--
--addSystemsAdler(template)
--
--
---- switch to model with two primary tubes
---- switch to model with two primary tubes
----what is fun: 
----Can not destroy enemies, since it has only emps
--var = template:copy("Zomok")	-- EMP
--var:setModel("AdlerLongRangeFighterBlue")
--var:setClass(_("class", "Starfighter"), _("subclass", "Delivery"))
--var:setDescription([[The Zomok tactical EMP delivery fighter is an advanced starfighter of the Human Navy, designed for surgical strikes.]])
--var:setTubes(2,10)	-- may hide two rockets in tubes while docking. So we can change loadout!
--var:setWeaponStorage("HVLI", 1)
--var:setWeaponStorage("Homing", 0)
--var:setWeaponStorage("EMP", 1)
--var:setAutoMissileReload(false)
--

--[[Scout--]]
template = ShipTemplate():setName("Adder MK7"):setClass(_("class", "Starfighter"), _("subclass", "Scout")):setType("playership")
--what is fun: its balanced. has a bit of every weapon. and fast enough reverse. Han host specialist
template:setModel("AdlerLongRangeScout"..color_player)
template:setRadarTrace("cruiser.png")
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
template:setJumpDriveRange(5000,50000)
template:setJumpDrive(false)
template:setRepairCrewCount(1)

template:setCanScan(true)
template:setCanHack(true)
template:setCanDock(true)
template:setCanCombatManeuver(false)
template:setCanLaunchProbe(true)
template:setCanSelfDestruct(false)
addSystemsAdler(template)

--[[ Player Light Cruiser--]]
template = ShipTemplate():setName("Phobos M3P"):setLocaleName(_("playerShip", "Phobos M3P")):setClass(_("class", "Frigate"), _("subclass", "Light Cruiser")):setType("playership")
template:setModel("MultiGunCorvette"..color_player)
template:setDescription([[The Phobos is the workhorse of the human navy. It's extremely easy to modify, which makes retro-fitting this ship a breeze. Its basic stats aren't impressive, but due to its modular nature, it's fairly easy to produce in large quantities.

This prototype variant of the Phobos M3 military light cruiser is outfitted like a battlecruiser. Not as strong as the atlantis, but has a mine-laying tube and two front firing missile tubes, making it an easier to use ship in some missions.]])
template:setRadarTrace("cruiser.png")
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
template:setWarpSpeed(750)
template:setWarpDrive(false)
template:setDockClasses(_("class", "Satellite"))
addSystemsMulitGun(template)

--[[ Player Laser Battlecruiser --]]
template = ShipTemplate():setName("Hathcock"):setLocaleName(_("playerShip", "Hathcock")):setClass(_("class", "Frigate"), _("subclass", "Torpedoboat Destroyer")):setType("playership") 
template:setModel("LaserCorvette"..color_player)
template:setDescription("The Hathcock Torpedoboat Destroyer is a light escort vessel for larger Battleships. It is fast enough to outmaneuver missiles and armed with a quick-firing beam array.")
template:setRadarTrace("laser.png")
--						Arc, Dir, Range, CycleTime, Dmg
template:setBeamWeapon(0, 4,   0, 1400.0, 6.0, 4)
template:setBeamWeapon(1,20,   0, 1200.0, 6.0, 4)
template:setBeamWeapon(2,60,   0, 1000.0, 6.0, 4)
template:setBeamWeapon(3,90,   0,  800.0, 6.0, 4)
template:setHull(120)
template:setShields(100, 70)
template:setSpeed(60, 15, 20)
template:setTubes(2, 8.0)
template:setCombatManeuver(400, 250)
template:setWeaponStorage("Homing", 16)
template:setTubeDirection(0, -90)
template:setTubeDirection(1,  90)
template:setTubeSize(0, "small")
template:setTubeSize(1, "small")
template:setWarpSpeed(750)
template:setJumpDriveRange(5000,50000)
template:setJumpDrive(false)
template:setWarpDrive(true)

template:setRepairCrewCount(2)
template:setDockClasses(_("class", "Satellite"))
addSystemsLaserAlt(template)

var = template:copy("Anvil")
var:setModel("LaserCorvetteBlue")
var:setSharesEnergyWithDocked(true)
var:setClass(_("class", "Prototype"), _("subclass", "Torpedoboat Destroyer"))
var:setDockClasses(_("class", "Prototype"))

--var = template:copy("Gozanti")
--var:setLocaleName(_("playerShip", "Gozantl")):setClass(_("class", "Cruiser"), _("subclass", "Light Cruiser"))
--var:setModel("LaserBehemoth"..color_player)
--var:setRadarTrace("star_destroyer.png")
--var:setDescription("An Imperial Carrier")
----					Arc, Dir, Range, CycleTime, Dmg
--var:setBeamWeapon(0,10,   0, 2000.0, 8.0, 6)
--var:setBeamWeapon(1,10, -45, 2000.0, 8.0, 6)
--var:setBeamWeapon(2,10,  45, 2000.0, 8.0, 6)
--var:setBeamWeapon(3,10, -90, 2000.0, 8.0, 6)
--var:setBeamWeapon(4,10,  90, 2000.0, 8.0, 6)
----							Arc, Dir, Rotate speed
--var:setBeamWeaponTurret(0, 200,  0, 5)
--var:setBeamWeaponTurret(1, 180, -45, 5)
--var:setBeamWeaponTurret(2, 180,  45, 5)
--var:setBeamWeaponTurret(3, 120, -90, 5)
--var:setBeamWeaponTurret(4, 120,  90, 5)
--var:setHull(400)
--var:setShields(400, 400)
--var:setSpeed(30, 3, 8)
--var:setTubes(2, 16.0)
--var:setCombatManeuver(200, 150)
--var:setWeaponStorage("Homing", 16)
--var:setWeaponStorage("EMP", 8)
--var:setWeaponStorage("Mine", 4)
--var:setWeaponStorage("Nuke", 4)
--var:setWeaponStorage("HVLI", 16)
--var:setTubeSize(0, "medium")
--var:setTubeSize(1, "medium")
--var:setJumpDrive(true)
--var:setWarpDrive(false)
--var:setExternalDockClasses(_("class", "Satellite"))
--var:setInternalDockClasses(_("class", "Starfighter"))
--var:setEnergyStorage(5000)
--var:setRestocksMissilesDocked("all")
--var:setSharesEnergyWithDocked(true)
--var:setRestocksScanProbes(true)
--var:setRepairDocked(true)



--[[Player Missile Cruiser--]]
template = ShipTemplate():setName("Piranha M5P"):setClass(_("class", "Frigate"), _("subclass", "Missile Cruiser")):setType("playership")
template:setModel("HeavyCorvette"..color_player)
template:setDescription([[The Piranha is a light artillery cruiser, designed to fire from broadside weapon tubes. It comes to use as a escort or defensive spacecraft, since it can quickly react to ambushes. However since it comes without beam weapons, it has proven to be useless against starfighters.

This combat-specialized Piranha M5P adds nukes, mine-laying tubes, combat maneuvering systems, and a jump drive.]])
template:setRadarTrace("missile_cruiser_thin.png")
template:setTubes(6, 10.0)
template:setWeaponStorage("HVLI", 20)
template:setWeaponStorage("Homing", 12)
template:setWeaponStorage("Nuke", 6)
template:setWeaponStorage("EMP", 8)
template:setTubeDirection(0, -90)
template:setTubeDirection(1, -90)
template:setTubeDirection(2, -90)
template:setTubeDirection(3,  90)
template:setTubeDirection(4,  90)
template:setTubeDirection(5,  90)

template:setHull(120)
template:setShields(70, 70)
template:setSpeed(60, 10, 16)
template:setCombatManeuver(200, 150)
template:setJumpDrive(true)
template:setWarpSpeed(750)
template:setWarpDrive(false)
template:setRepairCrewCount(2)
template:setDockClasses(_("class", "Satellite"))
addSystemsHeavy(template)

var = template:copy("Hammer")
var:setModel("HeavyCorvetteBlue")
var:setSharesEnergyWithDocked(true)
var:setClass(_("class", "Prototype"), _("subclass", "Missile Cruiser"))
var:setDockClasses(_("class", "Prototype"))

--[[Player Transport--]]
template = ShipTemplate():setName("Flavia P.Falcon"):setClass(_("class", "Frigate"), _("subclass", "Light transport")):setType("playership")
template:setModel("LightCorvette"..color_player)
template:setRadarTrace("endor_ftr.png")
template:setDescription([[Popular among traders and smugglers, the Flavia is a small cargo and passenger transport. It's cheaper than a freighter for small loads and short distances, and is often used to carry high-value cargo discreetly.

The Flavia Falcon is a Flavia transport modified for faster flight, and adds rear-mounted lasers to keep enemies off its back.

The Flavia P.Falcon has a nuclear-capable rear-facing weapon tube and a warp drive.]])
template:setBeam(0, 40, 170, 1200.0, 8.0, 6)
template:setBeam(1, 40, 190, 1200.0, 8.0, 6)

template:setHull(100)
template:setShields(70, 70)
template:setSpeed(60, 10, 20)
template:setWarpSpeed(500)
template:setJumpDriveRange(3000,30000)
template:setJumpDrive(false)
template:setCombatManeuver(250, 150)
template:setTubes(1, 20.0)
template:setTubeDirection(0, 180)
template:setWeaponStorage("HVLI", 5)
template:setWeaponStorage("Homing", 3)
template:setWeaponStorage("Mine", 1)
template:setWeaponStorage("Nuke", 1)
template:setRepairCrewCount(8)
template:setDockClasses(_("class", "Satellite"))
addSystemsLight(template)

template = ShipTemplate():setName("Repulse"):setClass(_("class", "Frigate"), _("subclass", "Armored Transport")):setModel("LightCorvette"..color_player):setType("playership")
template:setRadarTrace("tug.png")
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
template:setWarpSpeed(750)
template:setWarpDrive(false)
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
template:setRadarTrace("tug.png")
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
template:setWarpSpeed(750)
template:setWarpDrive(false)
template:setEnergyStorage(800)
template:setCombatManeuver(250,150)
template:setTubes(3, 10.0)
template:setTubeDirection(0, 180)
template:setTubeDirection(1, 180)
template:setTubeDirection(2, 180)
template:setWeaponStorage("Mine", 12)

template:setRepairCrewCount(4)
template:setDockClasses(_("class", "Satellite"))
addSystemsMineLayer(template)

--[[Corvette--]]
template = ShipTemplate():setName("Atlantis"):setClass(_("class", "Corvette"), _("subclass", "Destroyer")):setModel("AtlasHeavyDreadnought"..color_player):setType("playership")
template:setDescription([[The Atlantis X23 is the smallest model of destroyer, and its combination of frigate-like size and corvette-like power makes it an excellent escort ship when defending larger ships against multiple smaller enemies. Because the Atlantis X23 is fitted with a jump drive, it can also serve as an intersystem patrol craft.
This is a refitted Atlantis X23 for more general tasks. The large shield system has been replaced with an advanced combat maneuvering systems and improved impulse engines. Its missile loadout is also more diverse. Mistaking the modified Atlantis for an Atlantis X23 would be a deadly mistake.]])
template:setRadarTrace("melon.png")
template:setJumpDrive(true)
template:setWarpSpeed(750)
template:setWarpDrive(false)
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
template:setDockClasses(_("class", "Starfighter"))
addSystemsAtlasAlt(template)

--[[Missile Corvette--]]
template = ShipTemplate():setName("Crucible"):setLocaleName(_("Crucible")):setClass(_("Corvette"),_("Popper")):setModel("AtlasMissileDreadnought"..color_player):setType("playership")
template:setDescription(_("A number of missile tubes range around this ship. Beams were deemed lower priority, though they are still present. Stronger defenses than a frigate, but not as strong as the Atlantis"))
template:setRadarTrace("melon.png")
template:setHull(160)
template:setShields(160,160)
template:setSpeed(80,8,10)
template:setCombatManeuver(400, 250)
template:setWarpSpeed(750)
template:setJumpDriveRange(5000,50000)
template:setJumpDrive(false)
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
template:setDockClasses(_("class", "Starfighter"))

template:setRepairCrewCount(4)
addSystemsAtlas(template)

--[[Beam Corvette--]]
template = ShipTemplate():setName("Maverick"):setLocaleName(_("Maverick")):setClass(_("Corvette"),_("Gunner")):setModel("AtlasLaserDreadnought"..color_player):setType("playership")
template:setDescription(_("A number of beams bristle from various points on this gunner. Missiles were deemed lower priority, though they are still present. Stronger defenses than a frigate, but not as strong as the Atlantis"))
template:setRadarTrace("corellian_corvette.png")
template:setHull(160)
template:setShields(160,160)
template:setSpeed(80,8,10)
template:setCombatManeuver(400, 250)
template:setWarpSpeed(800)
template:setJumpDriveRange(5000,50000)
template:setJumpDrive(false)
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

template:setDockClasses(_("class", "Starfighter"))
template:setRepairCrewCount(4)
addSystemsAtlas(template)

--[[Carrier Corvette--]]
template = ShipTemplate():setName("Poseidon"):setClass(_("class", "Corvette"), _("subclass", "Combat Carrier")):setModel("AtlasCarrierDreadnought"..color_player):setType("playership")
template:setDescription([[The Poseidon armed combat carrier combines the durability of a corvette class ship with the ability to launch fighters and bombers. It has weapons to defend itself and the fighters, however there are no heavy weapons in the arsenal.]])
template:setRadarTrace("melon.png")
template:setJumpDrive(true)
template:setWarpSpeed(750)
template:setWarpDrive(false)
template:setShields(200, 200)
template:setHull(250)
template:setSpeed(90, 8, 10)
template:setCombatManeuver(400, 250)
--                  Arc, Dir, Range, CycleTime, Dmg
template:setBeam(0,100, -20, 1500.0, 6.0, 8)
template:setBeam(1,100,  20, 1500.0, 6.0, 8)
template:setWeaponStorage("Homing", 12)
template:setWeaponStorage("Nuke", 0)
template:setWeaponStorage("Mine", 4)
template:setWeaponStorage("EMP", 4)
template:setWeaponStorage("HVLI", 10)
template:setTubes(3, 8.0) -- Amount of torpedo tubes, and loading time of the tubes.
template:weaponTubeDisallowMissle(0, "Mine")
template:weaponTubeDisallowMissle(1, "Mine")
template:setTubeDirection(0, -90)
template:setTubeDirection(1,  90)
template:setTubeDirection(2, 180):setWeaponTubeExclusiveFor(2, "Mine")
template:setInternalDockClasses(_("subclass", "Interceptor"), _("subclass", "Bomber"), _("subclass", "Rocket Fighter"), _("subclass", "Scout"), _("subclass", "Fighter"))	-- do not allow heavy bombers
template:setSpawnShips("MP52 Hornet", "Peluda", "Ryu")

template:setRestocksMissilesDocked("all")
template:setSharesEnergyWithDocked(true)
template:setRestocksScanProbes(true)
template:setRepairDocked(true)
addSystemsAtlasAlt(template)

--[[Heavy Carrier Corvette--]]
template = ShipTemplate():setName("Neptune"):setClass(_("class", "Corvette"), _("subclass", "Heavy Carrier")):setType("playership")
template:setModel("HeavyDreadnoughtGrey")
template:setDescription([[The Neptune heavy carrier is unarmed by itself, but has the capability to produce all types of missiles for the fighters it carries. It houses upgraded interceptors and heavy bombers, capable of carrying emps, mines and nukes into the enemy lines.]])
template:setRadarTrace("missile_cruiser.png")
template:setJumpDrive(true)
template:setWarpSpeed(750)
template:setWarpDrive(false)
template:setShields(200, 200)
template:setHull(250)
template:setSpeed(90, 8, 10)
template:setCombatManeuver(400, 250)
template:setInternalDockClasses(_("class", "Starfighter"))
template:setSpawnShips("MP56 Bumblebee", "MP58 Mole", "Peluda", "Ryu", "Drac", "Cuelebre", "Zomok", "Bashe", "Adder MK7")

template:setRestocksMissilesDocked("all")
template:setSharesEnergyWithDocked(true)
template:setRestocksScanProbes(true)
template:setRepairDocked(true)
addSystemsHeavy(template)

--[[---------------------Carrier------------------------]]
template = ShipTemplate():setName("Benedict"):setClass(_("class", "Corvette"), _("subclass", "Freighter")):setModel("transport_4_2")
template:setType("playership")
template:setDescription([[The Jump Carrier is a specialized Freighter. It does not carry any cargo, as it's cargo bay is taken up by a specialized jump drive and a huge ammunition factory to supply docked ships.
It is designed to carry other ships deep into space. So it has special docking parameters, allowing other ships to attach themselves to this ship.
Benedict is an improved version of the Jump Carrier]])
template:setRadarTrace("transport.png")
template:setJumpDrive(true)
template:setWarpSpeed(750)
template:setWarpDrive(false)
template:setExternalDockClasses(_("class", "Frigate"), _("class", "Corvette"))
template:setInternalDockClasses(_("class", "Starfighter"))
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
template:setRestocksMissilesDocked("all")
template:setSharesEnergyWithDocked(true)
template:setRestocksScanProbes(true)
template:setRepairDocked(true)
template:setSpawnShips("MP52 Hornet", "Peluda", "Ryu")
template:setRepairCrewCount(6)
addSystemsTransport(template)

var2 = template:copy("Kiriya")
var2:setDescription([[The Warp Carrier is a specialized Freighter. It does not carry any cargo, as it's cargo bay is taken up by a specialized warp drive and a huge ammunition factory to supply docked ships.
It is designed to carry other ships deep into space. So it has special docking parameters, allowing other ships to attach themselves to this ship.
Kiriya is an improved warp drive version of the Jump Carrier]])
var2:setJumpDrive(false)
var2:setWarpDrive(true)
var2:setWarpSpeed(750)


