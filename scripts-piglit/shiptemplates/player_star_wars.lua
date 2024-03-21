require("shipSystems.lua") -- contains addSystems*

color_player = "White" --change it if you want another style




--[[ Fighters --]]
-- Fighters are quick agile ships that do not do a lot of damage, but usually come in larger groups. They are easy to take out, but should not be underestimated.
template = ShipTemplate()
template:setModel("WespeScout"..color_player)
template:setType("playership")
template:setImpulseSoundFile("sfx/engine_fighter.wav")
template:setSpeed(100, 20, 40, 25, 20)
template:setEnergyStorage(500)
template:setLongRangeRadarRange(10000)
template:setShortRangeRadarRange(5000)
template:setCanScan(false)
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

var = template:copy("U-Wing")
var:setClass(_("class", "Starfighter"), _("subclass", "Support"))
var:setDescription(_("The UT-60D U-wing starfighter/support craft, also known as the UT-60D, U-wing, or UT-60D U-wing Troop Transport, was a transport/gunship model manufactured by Incom Corporation and used by the Alliance to Restore the Republic during the Galactic Civil War. Used to drop troops into battle, and provide cover fire for them, U-wings were pivotal in transport and protection of the Rebel Alliance's ground forces during the Battle of Scarif."))
var:setRadarTrace("uwing.png")
--                 Arc, Dir, Range, CycleTime, Dmg
var:setBeam(0, 30,-5, 900.0, 4.0, 4)
var:setBeam(1, 30, 5, 900.0, 4.0, 4)
var:setShields(34, 34)
var:setRepairCrewCount(0)
--	speed, turn, accel, rev-speed, rev-accel
varNcp = var:copy(" U-Wing")
varNcp:setType("ship")

var = template:copy("X-Wing")
var:setClass(_("class", "Starfighter"), _("subclass", "Support"))
var:setDescription(_(""))
var:setRadarTrace("xwing.png")
--                 Arc, Dir, Range, CycleTime, Dmg
var:setBeam(0, 30,-5, 900.0, 4.0, 4)
var:setBeam(1, 30, 5, 900.0, 4.0, 4)
var:setShields(34, 34)
var:setRepairCrewCount(1)
--	speed, turn, accel, rev-speed, rev-accel


var = template:copy("StarViper")
var:setClass(_("class", "Starfighter"), _("subclass", "Heavy Attack Fighter"))
var:setDescription(_("The StarViper-class attack platform was a model of heavy attack starfighter manufactured by a subdivision of MandalMotors called Mandal Hypernautics. The fighter was lightly armored, but compensated for this with heavy weaponry and fast speed. Its high price meant that it was primarily found in use by larger crime syndicates like Black Sun and the Zann Consortium."))
var:setRadarTrace("starviper.png")
var:setShields(45)
var:setBeam(0, 30,-5, 900.0, 4.0, 4)
var:setBeam(1, 30, 5, 900.0, 4.0, 4)
var:setRepairCrewCount(0)
var:setTubes(3, 10.0)
var:setWeaponStorage("Homing", 8)
varNcp = var:copy(" StarViper")
varNcp:setType("ship")

var = template:copy("KvK-P0001")
var:setClass(_("class", "Starfighter"), _("subclass", "Attack Fighter"))
var:setDescription(_("Custom designed U-Wing, rebuilt as strong fighter. Reduced weight, strong chasing, very fast impulse drive."))
var:setRadarTrace("kvk.png")
var:setShields(34,34)
var:setBeam(0, 30,-5, 900.0, 4.0, 4)
var:setBeam(1, 30, 5, 900.0, 6.0, 6)
var:setRepairCrewCount(1)
var:setTubes(3, 10.0)
var:setWeaponStorage("Homing", 8)
var:setWeaponStorage("HVLI", 8)
var:setWeaponStorage("Mine", 4)
var:setWeaponTubeExclusiveFor(1, "HVLI"):setTubeSize(1,"small")
var:setWeaponTubeExclusiveFor(2, "Homing")
var:setTubeDirection(2, 180):setWeaponTubeExclusiveFor(2, "Mine")
-- Can be played as three person crew - but then it should not use the fighter template.
-- Reenable Scan, disable auto*, comms range
varNcp = var:copy(" KvK-P0001")
varNcp:setType("ship")

var = template:copy("A-24")
var:setClass(_("class", "Starfighter"), _("subclass", "Scout"))
var:setDescription(_("Designed by Incom Corporation at its peak for stealth and speed, the A-24 was a long and narrow craft, with a distinctive flat and triangular aft that housed the ship's engines, weapons, and distinctive stabilizers. Amidships, the A-24 sported a pair of canards that supported the ship's powerful sensor and communications arrays, while the forward command deck, while cramped, sported a cockpit that was offset by panoramic sheets of thick photosensitive transparisteel."))
var:setRadarTrace("a24.png")
var:setShields(45)
var:setBeam(0, 30,-5, 900.0, 4.0, 4)
var:setBeam(1, 30, 5, 900.0, 4.0, 4)
var:setBeam(2, 15, 0, 1000.0, 6.0, 6)
var:setRepairCrewCount(1)
var:setLongRangeRadarRange(30000)
var:setCanScan(true)
-- Can be played as three person crew - but then it should not use the fighter template.
-- Reenable Scan, disable auto*, comms range
varNcp = var:copy(" A-24")
varNcp:setType("ship")



--[[Player Transport--]]
template = ShipTemplate()
template:setClass(_("class", "Freighter"), _("subclass", "Light transport"))
template:setType("playership")
template:setModel("LightCorvette"..color_player)
template:setHull(100)
template:setShields(70)
--	            speed, turn, accel, rev-speed, rev-accel
template:setSpeed(60, 10, 20)
template:setCombatManeuver(250, 150)
template:setAutoMissileReload(true)
addSystemsLight(template)

var = template:copy("YT-2000")
var:setRadarTrace("yt2000.png")
var:setDescription([[The YT-2000 transport was designed to be a direct improvement over the YT-1300, but it only saw a limited production run. Its basic design was similar to the YT-1930 with its centrally-placed cockpit and symmetrical design, while the rest of the ship returned to the saucer-like design of the YT-1300.]])
var:setRepairCrewCount(0)
var:setShields(90)
--                 Arc, Dir, Range, CycleTime, Dmg
var:setBeam(0, 10, 0, 1200.0, 6.0, 6)
var:setBeam(1, 10, 0, 1200.0, 6.0, 6)
--								Arc, Dir, Rotate speed
var:setBeamWeaponTurret(0, 360, 0, 5)
var:setBeamWeaponTurret(1, 360, 0, 5)
var:setBeam(2, 30, 0, 1200, 6.0, 6)
varNcp = var:copy(" YT-2000")
varNcp:setType("ship")

var = template:copy("Y2K")
var:setRadarTrace("yt2k.png")
var:setDescription([[Y2K Peregerine Class Light Freighter. Designed and put into production a few years after the end of the Clone Wars and the formation of the Galactic Empire, Corellian Engineering Corporation sought to create a smaller-scale version of their venerable YT-series of freighters, which were beginning to show their age. Applying lessons learned over the decades, the design team for the Y2K-series strove to design a courier-vessel, opting to skimp on the frills and focus on functionality.]])
var:setRepairCrewCount(0)
--                 Arc, Dir, Range, CycleTime, Dmg
var:setBeam(0, 10, 0, 1200.0, 6.0, 6)
var:setBeam(1, 10, 0, 1200.0, 6.0, 6)
--								Arc, Dir, Rotate speed
var:setBeamWeaponTurret(0, 360, 0, 5)
var:setBeamWeaponTurret(1, 360, 0, 5)
varNcp = var:copy(" Y2K")
varNcp:setType("ship")

var = template:copy("YT-2400")
var:setRadarTrace("yt2400b.png")
var:setDescription([[The YT-2400 light freighter, also known as the YT-2400 transport, was a class of YT-series light freighter. During the Imperial Era, this model of freighter was used by both the Galactic Empire and the Alliance to Restore the Republic. The YT-2400 also saw use under cargo haulers and pirates.]])
--                 Arc, Dir, Range, CycleTime, Dmg
var:setBeam(0, 10, 0, 1200.0, 6.0, 6)
var:setBeam(1, 10, 0, 1200.0, 6.0, 6)
--								Arc, Dir, Rotate speed
var:setBeamWeaponTurret(0, 360, 0, 5)
var:setBeamWeaponTurret(1, 360, 0, 5)
var:setTubes(1, 10.0)
--var:setTubeSize(0, "small")
var:setWeaponStorage("Homing", 8)
var:setRepairCrewCount(1)
varNcp = var:copy(" YT-2400")
varNcp:setType("ship")

var = template:copy("Lambda T-4a")
var:setRadarTrace("lambda.png")
var:setDescription([[The Lambda-class T-4a shuttle, also known as the Imperial Shuttle, was a standard light utility craft in common with the Imperial military as a transport for troops and high-ranking individuals.]])
var:setRepairCrewCount(0)
var:setBeam(0, 30, 0, 1200.0, 6.0, 6)
var:setBeam(1, 10, 0, 1200.0, 6.0, 6)
var:setBeamWeaponTurret(1, 120, 0, 5)
var:setSpeed(60, 12, 20)
var:setShields(50, 50)
varNcp = var:copy(" Lambda T-4a")
varNcp:setType("ship")

-- GM: Instruction:
-- they can extract a rear-blaster:
-- Set range of beam 3 to 800

var = template:copy("YV-330")
var:setRadarTrace("yv929.png")
var:setDescription([[The YV-330 light freighter was a YV series light freighter produced by the Corellian Engineering Corporation. It was 26 meters long, and its standard armament was a twin laser cannon turret mounted beneath the cockpit. YV-330 freighters were often used by smugglers, and modified with heavier weaponry.]])
var:setRepairCrewCount(0)
var:setBeam(0, 50, 0, 1200.0, 6.0, 6)
var:setSpeed(55, 8, 12)
varNcp = var:copy(" YV-330")
varNcp:setType("ship")

var = template:copy("YV-929")
var:setRadarTrace("yv929.png")
var:setDescription([[The YV-929 armed freighter was a 22-meter-long light freighter produced by Corellian Engineering Corporation. It used the same forward cockpit structure as the much larger YV-100 light freighter. 
Unlike most CEC freighters, which came off the assembly lines with minimal weaponry, the YV-929 was designed from the start to be heavily armed for defense against pirate and Rebel raids, and also featured very strong shields.]])
var:setRepairCrewCount(0)
var:setBeam(0, 50, 0, 1200.0, 6.0, 6)
var:setBeam(1, 50, 0, 900.0, 4.0, 4)
var:setTubes(2, 15.0)
var:setTubeDirection(2, 180)
var:setWeaponStorage("Homing", 20)
var:setAutoMissileReload(false)
--	            speed, turn, accel, rev-speed, rev-accel
var:setSpeed(55, 8, 12)
var:setCanCombatManeuver(false)
varNcp = var:copy(" YV-929")
varNcp:setType("ship")


var = template:copy("G9")
var:setRadarTrace("g9.png")
var:setDescription([[The G9 Rigger-class light freighter was a model of freighter manufactured by the Corellian Engineering Corporation and used during the Clone Wars. Its only weapons were small blaster cannons attached to the wings and top of the freighter.]])
var:setRepairCrewCount(0)
var:setBeam(0, 10, -90, 1200.0, 6.0, 6)
var:setBeamWeaponTurret(0, 300, -90, 5)
var:setSpeed(60, 12, 20)
var:setShields(50)
varNcp = var:copy(" G9")
varNcp:setType("ship")

var = template:copy("UT-60D")
var:setDescription(_("The UT-60D U-wing starfighter/support craft, also known as the UT-60D, U-wing, or UT-60D U-wing Troop Transport, was a transport/gunship model manufactured by Incom Corporation and used by the Alliance to Restore the Republic during the Galactic Civil War. Used to drop troops into battle, and provide cover fire for them, U-wings were pivotal in transport and protection of the Rebel Alliance's ground forces during the Battle of Scarif."))
var:setRadarTrace("uwing.png")
--           Arc, Dir, Range, CycleTime, Dmg
var:setBeam(0, 30,-5, 900.0, 4.0, 4)
var:setBeam(1, 30, 5, 900.0, 4.0, 4)
var:setShields(34, 34)
varNcp = var:copy(" UT-60D")
varNcp:setType("ship")

var = template:copy("Kuat D7")
var:setClass(_("class", "Starfighter"), _("subclass", "Patrol"))
var:setDescription(_("The D7-Mantis Patrol Craft was a rare, top-of-the-line starship during the Cold War. It was meant to meet the demands of larger capital ships."))
var:setRadarTrace("d5.png")
--                 Arc, Dir, Range, CycleTime, Dmg
var:setBeam(0, 30,-5, 1200.0, 4.0, 4)
var:setBeam(1, 30, 5, 1200.0, 4.0, 4)
var:setShields(34, 34)
var:setRepairCrewCount(0)
--	speed, turn, accel, rev-speed, rev-accel
varNcp = var:copy(" Kuat D7")
varNcp:setType("ship")


--[[ Player Light Cruiser--]]
template = ShipTemplate():setName("Gozanti"):setLocaleName(_("playerShip", "Gozanti")):setClass(_("class", "Cruiser"), _("subclass", "Freighter")):setType("playership")
template:setModel("MultiGunCorvette"..color_player)
template:setDescription([[The Imperial Gozanti-class cruiser, also referred to as the Imperial Gozanti-class TIE carrier and known generally as the Imperial freighter, was a variant of the standard Gozanti-class cruiser used by the Galactic Empire and later by sympathizers of the First Order.]])
template:setRadarTrace("gozanti.png")
--                 Arc, Dir, Range, CycleTime, Dmg
template:setBeam(0, 10, 0, 800.0, 6.0, 6)
template:setBeam(1, 30, 0, 1200.0, 8.0, 12)
--								Arc, Dir, Rotate speed
template:setBeamWeaponTurret(0, 360, 0, 5)
template:setTubes(0, 10.0)
template:setShields(100, 100)
template:setHull(200)
--	            speed, turn, accel, rev-speed, rev-accel
template:setSpeed(80, 10, 20)
template:setCombatManeuver(400, 250)
template:setRepairCrewCount(4)
template:setDockClasses(_("class", "Starfighter"))
template:setRepairDocked(true)
template:setSharesEnergyWithDocked(false)
template:setRestocksMissilesDocked("all")
addSystemsMulitGun(template)
varNcp = template:copy(" Gozanti")
varNcp:setType("ship")

--[[Heavy Freighter]]
template = ShipTemplate()
template:setClass(_("class", "Freighter"), _("subclass", "Medium Transport"))
template:setModel("transport_4_2")
template:setType("playership")
template:setHull(200)
--	            speed, turn, accel, rev-speed, rev-accel
template:setSpeed(50, 5, 7)
template:setCanCombatManeuver(false)
addSystemsTransport(template)

var = template:copy("GR-75")
var:setDescription([[The GR-75 medium transport, sometimes referred to as the Gallofree transport, was a transport designed and constructed by Gallofree Yards, Inc.. They were lightly armed with a clamshell-like hull to protect the cargo pods it carried. They could not reach anymore than 650 kilometers per hour.]])
var:setRadarTrace("gr75.png")
var:setShields(70, 70, 70, 70)
--                  Arc, Dir, Range, CycleTime, Dmg
var:setBeam(0, 10,   0, 1500.0, 6.0, 6)
var:setBeam(1, 10, 180, 1500.0, 6.0, 6)
var:setBeam(2, 10,   0, 1500.0, 6.0, 6)
var:setBeam(3, 10, 180, 1500.0, 6.0, 6)
--                               Arc, Dir, Rotate speed
var:setBeamWeaponTurret( 0, 120,   0, 6)
var:setBeamWeaponTurret( 1, 120, 180, 6)
var:setBeamWeaponTurret( 2, 120,   0, 6)
var:setBeamWeaponTurret( 3, 120, 180, 6)
var:setRepairCrewCount(5)
varNcp = var:copy(" GR-75")
varNcp:setType("ship")

var = template:copy("Action IV")
var:setDescription(_("The Action IV transport was a Corellian Engineering Corporation medium bulk freighter of the Action series. Even though each ship was sold without any weaponry or defensive shields built in, plenty of after-market systems could be added to the Action IV."))
var:setRadarTrace("action4.png")
var:setShields(70, 70)
--           Arc, Dir, Range, CycleTime, Dmg
var:setBeam(0, 60, 0,   1500.0, 6.0, 6)
var:setBeam(1, 60, 180, 1500.0, 6.0, 6)
var:setWeaponStorage("Homing", 12)
var:setTubes(1, 10.0)
var:setRepairCrewCount(2)
varNcp = var:copy(" Action IV")
varNcp:setType("ship")

