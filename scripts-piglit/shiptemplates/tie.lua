require("shipSystems.lua") -- contains addSystems*

color_player = "White" --change it if you want another style

template = ShipTemplate():setName("TIE-Fighter"):setClass(_("class", "Starfighter"), _("subclass", "Fighter"))
template:setModel("WespeFighter"..color_player)
template:setDescription([[It's a TIE Fighter]])
template:setRadarTrace("tie_fighter.png")
template:setImpulseSoundFile("sfx/engine_fighter.wav")
template:setHull(36)	-- asteroid makes 35 dmg
template:setShields()
--				spped, turn, accel, rev-speed, rev-accel
template:setSpeed(100, 28, 40, 25, 20)
template:setCombatManeuver(600, 0)
--                 Arc, Dir, Range, CycleTime, Dmg
template:setBeam(0, 30,-5, 900.0, 4.0, 2.5)
template:setBeam(1, 30, 5, 900.0, 4.0, 2.5)
template:setTubes(0, 10.0)
template:setTubeSize(0, "small")
template:setEnergyStorage(400)
template:setRepairCrewCount(1)
template:setLongRangeRadarRange(10000)
template:setShortRangeRadarRange(5000)
template:setCanScan(true)
template:setCanHack(false)
template:setCanDock(true)
template:setCanCombatManeuver(false)
template:setCanLaunchProbe(false)
template:setCanSelfDestruct(false)
template:setAutoCoolant(true)
template:setAutoMissileReload(true)
template:setAutoRepair(true)
template:setDefaultAI('fighter')
addSystemsWespe(template)

var = template:copy("TIE Fighter")
var:setType("playership")

var = template:copy("TIE-Interceptor")
var:setClass(_("class", "Starfighter"), _("subclass", "Interceptor"))
var:setDescription([[It's a TIE Interceptor]])
var:setRadarTrace("tie_interceptor.png")
var:setHull(69)	-- two asteroids also kill TI
var:setBeam(0, 30,-5, 900.0, 3.0, 3.0)
var:setBeam(1, 30, 5, 900.0, 3.0, 3.0)

var2 = var:copy("TIE Interceptor")
var2:setType("playership")

template = ShipTemplate():setName("TIE-Bomber"):setClass(_("class", "Starfighter"), _("subclass", "Bomber"))
template:setDescription([[It's a TIE Bomber]])
template:setModel("LindwurmFighter"..color_player)
template:setRadarTrace("tie_bomber.png")
template:setImpulseSoundFile("sfx/engine_fighter.wav")
template:setHull(100)
template:setShields()
template:setSpeed(70, 15, 25, 40, 15)
template:setTubes(1, 10.0)
template:setTubeSize(0, "small")
template:setWeaponStorage("Homing", 8)	-- other loadout by GM
--                  Arc, Dir, Range, CycleTime, Dmg
template:setBeam(0, 30,-5, 900.0, 3.0, 2.5)
template:setBeam(1, 30, 5, 900.0, 3.0, 2.5)
template:setCombatManeuver(250, 150)
template:setEnergyStorage(400)
template:setRepairCrewCount(1)
template:setLongRangeRadarRange(10000)
template:setShortRangeRadarRange(5000)
template:setCanScan(true)
template:setCanHack(false)
template:setCanDock(true)
template:setCanCombatManeuver(false)
template:setCanLaunchProbe(false)
template:setCanSelfDestruct(true)
template:setAutoCoolant(true)
template:setAutoMissileReload(true)
template:setAutoRepair(true)
template:setDefaultAI('fighter')
addSystemsLindwurm(template)

var = template:copy("TIE Bomber")
var:setType("playership")

var2 = var:copy("TIE Bomber (assault)")
var2:setTubes(1,7)
var2:setWeaponStorage("Homing", 0)
var2:setWeaponStorage("HVLI", 8)

var3 = var:copy("TIE Bomber (mine)")
var3:setTubes(1,20)
var3:setWeaponStorage("Homing", 0)
var3:setWeaponStorage("Mine", 1)
var3:setTubeDirection(0,180)

var4 = var:copy("TIE Bomber (assassin)")
var4:setTubes(1,20)
var4:setWeaponStorage("Homing", 0)
var4:setWeaponStorage("Mine", 1)

var5 = var:copy("TIE Bomber (sniper)")
var5:setTubes(1,20)
var5:setWeaponStorage("Homing", 0)
var5:setWeaponStorage("Nuke", 1)

var6 = var:copy("TIE Bomber (twin missile)")
var6:setModel("AdlerLongRangeFighter"..color_player)
var6:setTubes(2,7)
var6:setTubeSize(0, "small")
var6:setTubeSize(1, "small")
var6:setWeaponStorage("Homing", 8)

var7 = var6:copy("TIE Bomber (specialist)")
var7:setTubes(2,10)
var7:setWeaponStorage("HVLI", 1)
var7:setWeaponStorage("Homing", 0)
var7:setWeaponStorage("EMP", 1)
var7:setAutoMissileReload(false)


