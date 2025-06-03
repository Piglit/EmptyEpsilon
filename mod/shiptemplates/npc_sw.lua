-- Once were Exuari ships, modified to be used as rebel and capital ships here
-- Only CPU Ships are found here. Names start with a space, to match the naming convention:
-- SW-Player-Ships start with a letter and may end with spaces.
-- SW-CPU-Ships start with a space.

--[[ Fighters --]]
template = ShipTemplate():setName(" T-Wing R-60"):setClass("Starfighter", "Interceptor")
template:setModel("small_fighter_1")
template:setRadarTrace("twing.png")
template:setDescription(_("The R-60 T-wing interceptor was an interceptor originally designed to replace the A-wing. Unfortunately for the Rebellion, the end result turned out to be a poor replacement for the craft."))

--                  Arc, Dir, Range, CycleTime, Dmg
--template:setBeam(0, 60, 0, 1000.0, 4.0, 4)
template:setTubes(1, 1.0)
template:setTubeSystem(0, "beamweapons")
template:setTubeSystem(1, "beamweapons")
template:setWeaponTubeExclusiveFor(0, "laser_red")
template:setWeaponTubeExclusiveFor(1, "laser_red")
template:setWeaponStorage("laser_red", 99)

template:setHull(15)
template:setShields(15)
--Reputation Score: 6
template:setSpeed(120, 30, 25)
template:setDefaultAI('fighter')

variation = template:copy(" X-Wing")
variation:setClass("Starfighter", "Interceptor")
variation:setModel("dark_fighter_6")
variation:setRadarTrace("xwing.png")
variation:setDescription(("X-wing starfighters were a type of starfighter marked by their distinctive S-foils that resembled the High Galactic script's character 'X' in attack formation. They were heavily armed with four laser cannons on the S-foils and proton torpedo launchers in the fuselage. X-wings were designed for dogfighting and long missions."))
--variation:setBeam(0, 60, 0, 1000.0, 4.0, 4)
--variation:setBeam(1, 60, 0, 1000.0, 4.0, 4)
variation:setTubes(2, 1.0)
variation:setSpeed(130, 35, 30)

template = ShipTemplate():setName(" Y-Wing BTL-B"):setClass("Starfighter", "Bomber")
template:setModel("small_fighter_1")
template:setRadarTrace("ywing.png")
template:setDescription(_("The Y-wing starfighter/bomber, was a model of starfighter-bomber produced by Koensayr Manufacturing, the first of the BTL-series Y-wing line. A mainstay of the Republic Navy during the Clone Wars, BTL-Bs were adopted by clones and Jedi officers alike and were instrumental in the fight against the Confederacy of Independent Systems."))
--template:setBeam(0, 60, 0, 1000.0, 4.0, 4)
template:setTubes(2, 1.0)
template:setTubeLoadTime(1,60)		 
template:setTubeSystem(0, "beamweapons")
template:setWeaponTubeExclusiveFor(0, "laser_red")
template:setWeaponStorage("laser_red", 99)
template:setHull(40)
template:setShields(30)
--Reputation Score: 7
template:setSpeed(70, 20, 15)
template:setDefaultAI('fighter')
--template:setTubes(1, 60.0)
template:setTubeSize(1, "small")
template:setWeaponStorage("HVLI", 1)
template:setWeaponTubeExclusiveFor(1, "HVLI")

variation = template:copy(" Y-Wing BTL-A4")
variation:setTubeSize(1, "medium")
variation:setWeaponStorage("HVLI", 2)

variation = template:copy(" Y-Wing BTL-S3")
variation:setTubeSize(1, "large")


--[[ Capital Ships --]]
template = ShipTemplate():setName(" CR90"):setClass("Capital Ship", "Corvette")
template:setModel("cr90"):setRadarTrace("corellian_corvette.png")
template:setDescription(_([[The CR90 Corvette, colloquially known as the Corellian corvette or blockade runner, was manufactured by the Corellian Engineering Corporation. While the CR90 would see initial use within the late Galactic Republic and Imperial Senate, many vessels would be appropriated by the early rebellion and Rebel Alliance against the First Galactic Empire, despite not being designed as a combat-oriented vessel. They were later used by the navies of the New Republic.]]))
template:setHull(700)
template:setShields(500, 400)
--Reputation Score: 16
template:setSpeed(40, 8, 10)
template:setBeamWeapon(0, 10, -60, 1200, 9, 20)
template:setBeamWeapon(1, 10,  60, 1200, 9, 20)
template:setBeamWeaponTurret(0, 180, -15, 2)
template:setBeamWeaponTurret(1, 180,  15, 2)
template:setDockClasses("Shuttle", "Starfighter", "Freighter", "Cruiser")	-- all player ship may dock on each other

template = ShipTemplate():setName(" Nebulon-B"):setClass("Capital Ship", "Frigate")
template:setModel("nebulon_b"):setRadarTrace("nebulon-b.png")
template:setDescription(_([[The EF76 Nebulon-B escort frigate is a class of frigate manufactured by Kuat Drive Yards. Despite being intended for Imperial Navy service, it gained more fame as a Rebel Cruiser used by the Alliance to Restore the Republic and its successor, the New Republic, throughout the Galactic Civil War.]]))
template:setBeamWeapon(0, 20, -9, 1200, 3, 4)
template:setBeamWeapon(1, 20,  9, 1200, 3, 4)
template:setBeamWeapon(2, 20,  50, 1200, 3, 4)
template:setBeamWeapon(3, 20, -50, 1200, 3, 4)
template:setBeamWeaponTurret(0, 180, -9, 3)
template:setBeamWeaponTurret(1, 180,  9, 3)
template:setBeamWeaponTurret(2, 180,  50, 3)
template:setBeamWeaponTurret(3, 180, -50, 3)
template:setHull(1400)
template:setShields(500, 400)
template:setSpeed(40, 6, 2)
template:setDockClasses("Shuttle", "Starfighter", "Freighter", "Cruiser")	-- all player ship may dock on each other

--template = ShipTemplate():setName("Warden"):setClass("Exuari", "Frigate")
--template:setModel("transport_4_1"):setRadarTrace("exuari_frigate_3.png")
--template:setDescription(_([[The Exuari Warden is a heavy artillery frigate, it fires bunches of missiles from forward facing tubes. Only a single point defense turret is present.]]))
--template:setBeamWeapon(0, 20, 0, 1200, 3, 2)
--template:setBeamWeaponTurret(0, 270, 0, 5)
--template:setHull(50)
--template:setShields(30, 30)
----Reputation Score: 11
--template:setSpeed(40, 6, 8)
--template:setTubes(5, 15.0)
--template:setWeaponStorage("HVLI", 15)
--template:setWeaponStorage("Homing", 15)
--template:setTubeDirection(0,  0)
--template:setTubeDirection(1, -1)
--template:setTubeDirection(2,  1)
--template:setTubeDirection(3, -2)
--template:setTubeDirection(4,  2)


template = ShipTemplate():setName(" MC80"):setModel("calamari"):setClass("Capital Ship", "Carrier")
template:setRadarTrace("mc80.png")
template:setDescription(_([[MC80 Star Cruisers, otherwise generally referred to as Mon Calamari Star Cruisers were capital ships used by the Rebel Alliance during the Galactic Civil War. There are pods attached all around the ship, containing turbolasers, sensor arrays and viewing ports, the latter fulfilling the ships' original intended role as an exploration and observation vessel. Each cruiser was of a unique design. Despite their smooth lines, these vessels are heavily armed with dozens of turbolasers, and shield generators.]]))
--                  Arc, Dir, Range, CycleTime, Dmg
template:setBeam(0,  20, -10, 2400.0, 6.1, 4):setBeamWeaponTurret(0, 160, -10, 5)
template:setBeam(1,  20, -50, 2400.0, 6.0, 4):setBeamWeaponTurret(1, 160, -50, 5)
template:setBeam(2,  20,  10, 2400.0, 6.1, 4):setBeamWeaponTurret(2, 160,  10, 5)
template:setBeam(3,  20,  50, 2400.0, 6.0, 4):setBeamWeaponTurret(3, 160,  50, 5)
template:setBeam(4,  20, -60, 2400.0, 5.9, 4):setBeamWeaponTurret(4, 160, -60, 5)
template:setBeam(5,  20, -90, 2400.0, 6.2, 4):setBeamWeaponTurret(5, 160, -90, 5)
template:setBeam(6,  20,  60, 2400.0, 5.9, 4):setBeamWeaponTurret(6, 160,  60, 5)
template:setBeam(7,  20,  90, 2400.0, 6.2, 4):setBeamWeaponTurret(7, 160,  90, 5)
template:setBeam(8,  20, -120, 2400.0, 6.1, 4):setBeamWeaponTurret(8, 160, -120, 5)
template:setBeam(9,  20, -140, 2400.0, 6.0, 4):setBeamWeaponTurret(9, 160, -140, 5)
template:setBeam(10, 20,  120, 2400.0, 6.1, 4):setBeamWeaponTurret(10, 160,  120, 5)
template:setBeam(11, 20,  140, 2400.0, 6.0, 4):setBeamWeaponTurret(11, 160,  140, 5)
template:setHull(10000)
template:setShields(2500, 2500, 2500, 2500, 2500, 2500)
template:setSpeed(20, 1.5, 3)
template:setDockClasses("Exuari")
template:setSharesEnergyWithDocked(true)
template:setRepairDocked(true)
template:setRestocksMissilesDocked("all")
template:setRestocksScanProbes(true)
template:setDockClasses("Shuttle", "Starfighter", "Freighter", "Cruiser")	-- all player ship may dock on each other

template = ShipTemplate():setName(" Star Destroyer"):setClass("Capital Ship", "Carrier"):setModel("star_destroyer")
template:setDescription(_([[A Star Destroyer is a dagger-shaped type of capital ship. Notable examples of Star Destroyers include the Imperial-class Star Destroyer and its predecessor, the Venator-class Star Destroyer.]]))
template:setRadarTrace("star_destroyer.png")
template:setShields(5000, 5000)
template:setHull(8000)
template:setSpeed(20, 1, 2)
template:setDockClasses("Starfighter")
--                  Arc, Dir, Range, CycleTime, Dmg
template:setBeam(0,  40, -10, 2400.0, 6.1, 6)
template:setBeam(1,  40, -30, 2400.0, 6.0, 6)
template:setBeam(2,  40,  10, 2400.0, 6.1, 6)
template:setBeam(3,  40,  30, 2400.0, 6.0, 6)
template:setBeam(4,  40, -50, 2400.0, 5.9, 6)
template:setBeam(5,  40, -70, 2400.0, 6.2, 6)
template:setBeam(6,  40,  50, 2400.0, 5.9, 6)
template:setBeam(7,  40,  70, 2400.0, 6.2, 6)
template:setBeam(8,  40, -90, 2400.0, 6.1, 6)
template:setBeam(9,  40, -120, 2400.0, 6.0, 6)
template:setBeam(10, 40,  90, 2400.0, 6.1, 6)
template:setBeam(11, 40,  120, 2400.0, 6.0, 6)

template:setWeaponStorage("Homing", 12)
template:setWeaponStorage("Nuke", 4)
template:setWeaponStorage("Mine", 8)
template:setWeaponStorage("EMP", 6)
template:setWeaponStorage("HVLI", 20)
template:setTubes(4, 8.0) -- Amount of torpedo tubes, and loading time of the tubes.
template:weaponTubeDisallowMissle(0, "Mine")
template:weaponTubeDisallowMissle(1, "Mine")
template:weaponTubeDisallowMissle(2, "Mine")
template:weaponTubeDisallowMissle(3, "Mine")

template:setTubeDirection(0, 0)
template:setTubeDirection(1, 0):weaponTubeDisallowMissle(1, "Nuke"):weaponTubeDisallowMissle(1, "EMP")
template:setTubeDirection(2, 0):weaponTubeDisallowMissle(2, "Nuke"):weaponTubeDisallowMissle(2, "EMP")
template:setTubeDirection(3, 180):setWeaponTubeExclusiveFor(3, "Mine")
template:setDockClasses("Shuttle", "Starfighter", "Freighter", "Cruiser")	-- all player ship may dock on each other


