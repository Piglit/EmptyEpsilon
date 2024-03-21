--Exuari ships

--[[

Description
-----------
This file describes a set of ships of a similar style that was designed with the background of the Exuari culture.

Appearance
----------
Small ships with wings and many thin parts are the primary design features for the Exuari fleet.
The models that were chosen for the ships provide those common features.
Custom radar traces were designed for most of the Exuari ships. The radar traces show wings on all Exuari ships, so it should be easy for players to distinguish between Exuari ships and ships of other factions. As wings are considered to be the primary feature of Exuari ships, so make sure they are shown on radar traces if you add new ones.
If you want to extend this list of ships, consider using variations of the "small_frigate" Models/Meshes or other models that show mentioned features, like "dark_fighter_6", "small_fighter_1", "space_cruiser_4".

Strategic use in scenarios
--------------------------
Considering the faction description and existing scenarios the following strategies have been developed for the Exuari fleet.
  * Assassins ("death teams"): One or few ships attack a chosen target. Warp Jammers or other technology may be used. When used in a scenario, the players goal can be to defend the target or themself. Ambushes are a common element.
  * Siege: A carrier ship with defending frigates is hidden somewhere near the sector. The carrier launches waves of all kinds of fighters and artillery. Upon first resistance, Warp-enabled strikers are started as reinforcements. The players goals can be to simply defend and survive or to find and destroy the hidden carrier ship.
 
Ship Properties
---------------
The following features were chosen for Exuari ships, to make them distinguishable from other factions:
  * Exuari focus on small specialised ships and fighters, rather than massive corvettes
  * Hull is stronger than shields, front shields are stronger than rear shields
  * Shields are weaker than the shields of most other factions
  * Beams are weaker than the beams of most other factions
  * Heavy use of missiles: mostly small HVLIs, few small homing. Some missiles of mass destruction.

Naming Convention
-----------------
The Exuari ship template names mostly are "bad boys" names (like "Buster"). Some are named after a weapon (like "Dagger") or by their function (like "Warden"). Each class of ships has it's own small naming convention, so the names of similar ships provide similar association. Further names could be "Butch", "Ace", "Wilder" or "Rebel", "Ransom", "Rowdy".

Ship Classes
------------
As Exuari ships are specialised, there are several classes of ships that provide specific purposes:
  * Fighters are quick agile ships that do not do a lot of damage, but usually come in larger groups. They are easy to take out, but should not be underestimated.
  * Striker are warp-drive equipped fighters build for quick strikes. Fast, agile, but do not do an extreme amount of damage. Low rear shields.
  * Frigates are non-warp capable ships, mostly used to defend bases or to build the rear line in an assault.
  * Artillery are non-warp capable ships, mostly used to delivers Nukes to their enemies.
  * Carriers are huge ships with many defensive features. It can be docked by smaller ships.

Overview
--------
Strikers:
  * Racer
  * Hunter
  * Strike
  * Dash

Fighters:
  * Dagger
  * Blade
  * Gunner
  * Shooter
  * Jagger

Defenders/Frigates:
  * Warden
  * Sentinel
  * Guard

Sniper/Artillery:
  * Flash
  * Ranger
  * Buster

Carriers:
  * Ryder
  * Fortress

--]]

--[[ Fighters --]]
-- Fighters are quick agile ships that do not do a lot of damage, but usually come in larger groups. They are easy to take out, but should not be underestimated.
template = ShipTemplate():setName("T-Wing"):setClass(_("class", "Starfighter"), _("subclass", "Interceptor"))
template:setModel("small_fighter_1")
template:setRadarTrace("twing.png")
template:setDescription(_("The R-60 T-wing interceptor was an interceptor originally designed to replace the A-wing. Unfortunately for the Rebellion, the end result turned out to be a poor replacement for the craft."))

--                  Arc, Dir, Range, CycleTime, Dmg
template:setBeam(0, 60, 0, 1000.0, 4.0, 4)
template:setHull(30)
template:setShields(30)
--Reputation Score: 6
template:setSpeed(120, 30, 25)
template:setDefaultAI('fighter')

variation = template:copy("X-Wing")
variation:setClass(_("ss", "Exuari"), _("subclass", "Starfighter - Interceptor"))
variation:setModel("dark_fighter_6")
variation:setRadarTrace("xwing.png")
variation:setDescription(("X-wing starfighters were a type of starfighter marked by their distinctive S-foils that resembled the High Galactic script's character 'X' in attack formation. They were heavily armed with four laser cannons on the S-foils and proton torpedo launchers in the fuselage. X-wings were designed for dogfighting and long missions."))
variation:setBeam(0, 60, 0, 1000.0, 4.0, 4)
variation:setBeam(1, 60, 0, 1000.0, 4.0, 4)
variation:setSpeed(130, 35, 30)

template = ShipTemplate():setName("BTL-B Y-Wing"):setClass(_("class", "Starfighter"), _("subclass", "Bomber"))
template:setModel("small_fighter_1")
template:setRadarTrace("ywing.png")
template:setDescription(_("The Y-wing starfighter/bomber, was a model of starfighter-bomber produced by Koensayr Manufacturing, the first of the BTL-series Y-wing line. A mainstay of the Republic Navy during the Clone Wars, BTL-Bs were adopted by clones and Jedi officers alike and were instrumental in the fight against the Confederacy of Independent Systems."))
template:setBeam(0, 60, 0, 1000.0, 4.0, 4)
template:setHull(40)
template:setShields(30)
--Reputation Score: 7
template:setSpeed(70, 20, 15)
template:setDefaultAI('fighter')
template:setTubes(1, 60.0)
template:setTubeSize(0, "small")
template:setWeaponStorage("HVLI", 1)

variation = template:copy("BTL-A4 Y-Wing")
variation:setTubeSize(0, "medium")
variation:setWeaponStorage("HVLI", 2)

variation = template:copy("BTL-S3 Y-Wing")
variation:setTubeSize(0, "large")

--[[ Strikers --]]
-- The Strikeship is a warp-drive equipped figher build for quick strikes, it's fast, it's agile, but does not do an extreme amount of damage, and lacks in rear shields.
template = ShipTemplate():setName("Racer"):setClass(_("class", "Exuari"), _("subclass", "Striker"))
template:setModel("small_frigate_1"):setRadarTrace("exuari_1.png")
template:setDescription(_("The Exuari alpha striker 'Racer' is a warp-drive equipped Figter build for quick strikes. This spacecraft runs on a small crew and is often used as scout, interceptor or to perform preemptive attacks. It's fast, it's agile, but the striker beams do not cause an extreme amount of damage. Like all strikers, it lacks in rear shields."))
--                  Arc, Dir, Range, CycleTime, Dmg
template:setBeam(0, 40,-5, 1000.0, 6.0, 6)
template:setBeam(1, 40, 5, 1000.0, 6.0, 6)
template:setHull(50)
template:setShields(50, 30)
--Reputation Score: 13
template:setSpeed(70, 12, 12)
template:setWarpSpeed(600)

variation = template:copy("Hunter")
variation:setDescription(_("The Exuari beta striker 'Hunter' is a warp-drive equipped reinforement fighter. This spacecraft runs on a small crew and is often sent into battle to aid other Exuari ships when they engage in combat. It has an extra pair of striker beams and improved front shields. It's fast, it's agile, and can clean up what is left of the enemies fleet after an initial strike."))
variation:setModel("small_frigate_4"):setRadarTrace("exuari_4.png")
variation:setBeam(2, 50,-15, 1000.0, 6.0, 6)
variation:setBeam(3, 50, 15, 1000.0, 6.0, 6)
variation:setShields(80, 30)
--Reputation Score: 16
variation:setWarpSpeed(400)

variation = template:copy("Strike")
variation:setDescription(_("The Exuari gamma striker 'Strike' is a warp-drive equipped tactical bomber build for quick strikes against strong shielded targets. This spacecraft runs on a small crew and is equipped with HVLIs and an EMP. It's fast, it's agile, and can do a great amount of damage in short time."))
variation:setModel("small_frigate_3"):setRadarTrace("exuari_3.png")
variation:setTubes(1, 10.0)
variation:setWeaponStorage("EMP", 1)
variation:setWeaponStorage("HVLI", 2)
variation:setWarpSpeed(300)

variation = template:copy("Dash")
variation:setDescription(_("The Exuari delta striker 'Dash' is a warp-drive equipped endurance bomber build for prolonged strikes. This spacecraft runs on a small crew and combines reinforced front shields with a good amount of HVLIs. It's fast, it's agile, and can take some damage."))
variation:setModel("small_frigate_5"):setRadarTrace("exuari_5.png")
variation:setTubes(1, 10.0)
variation:setWeaponStorage("HVLI", 4)
variation:setHull(70)
variation:setShields(80, 30)
--Reputation Score: 18
variation:setWarpSpeed(200)

--[[ Frigates--]]
--Frigates are non-warp capable ships, mostly used to defend bases or to build the rear line in an assault.
--TODO: replace models (transorts should not be used here)
template = ShipTemplate():setName("Guard"):setClass(_("class", "Exuari"), _("subclass", "Frigate"))
template:setModel("transport_1_1"):setRadarTrace("exuari_frigate_1.png")
template:setDescription(_([[The Exuari Guard is not impressive, trying to be a alround escort or defense vessel. It has powering problems, causing the reload cycle of beams and missiles to take longer than expected. The Guard is equipped with turret beams and a large stock of different missiles, including homing missiles and mines.]]))
template:setHull(70)
template:setShields(50, 40)
--Reputation Score: 16
template:setSpeed(55, 10, 10)
template:setBeamWeapon(0, 10, -15, 1200, 9, 6)
template:setBeamWeapon(1, 10,  15, 1200, 9, 6)
template:setBeamWeaponTurret(0, 180, -15, 5)
template:setBeamWeaponTurret(1, 180,  15, 5)
template:setTubes(3, 60.0)
template:setWeaponStorage("Mine", 6)
template:setWeaponStorage("HVLI", 20)
template:setWeaponStorage("Homing", 6)
template:setTubeDirection(0, -1):weaponTubeDisallowMissle(0, "Mine")
template:setTubeDirection(1,  1):weaponTubeDisallowMissle(1, "Mine")
template:setTubeDirection(2,  180):setWeaponTubeExclusiveFor(2, "Mine")

template = ShipTemplate():setName("Sentinel"):setClass(_("class", "Exuari"), _("subclass", "Frigate"))
template:setModel("transport_3_1"):setRadarTrace("exuari_frigate_2.png")
template:setDescription(_([[The Exuari Sentinel is an anti-fighter frigate. It has several rapid-firing, low-damage point-defense turret beams to quickly take out starfighters.]]))
template:setBeamWeapon(0, 20, -9, 1200, 3, 2)
template:setBeamWeapon(1, 20,  9, 1200, 3, 2)
template:setBeamWeapon(2, 20,  50, 1200, 3, 2)
template:setBeamWeapon(3, 20, -50, 1200, 3, 2)
template:setBeamWeaponTurret(0, 180, -9, 5)
template:setBeamWeaponTurret(1, 180,  9, 5)
template:setBeamWeaponTurret(2, 180,  50, 5)
template:setBeamWeaponTurret(3, 180, -50, 5)
template:setHull(70)
template:setShields(50, 40)
--Reputation Score: 16
template:setSpeed(70, 15, 10)

template = ShipTemplate():setName("Warden"):setClass(_("class", "Exuari"), _("subclass", "Frigate"))
template:setModel("transport_4_1"):setRadarTrace("exuari_frigate_3.png")
template:setDescription(_([[The Exuari Warden is a heavy artillery frigate, it fires bunches of missiles from forward facing tubes. Only a single point defense turret is present.]]))
template:setBeamWeapon(0, 20, 0, 1200, 3, 2)
template:setBeamWeaponTurret(0, 270, 0, 5)
template:setHull(50)
template:setShields(30, 30)
--Reputation Score: 11
template:setSpeed(40, 6, 8)
template:setTubes(5, 15.0)
template:setWeaponStorage("HVLI", 15)
template:setWeaponStorage("Homing", 15)
template:setTubeDirection(0,  0)
template:setTubeDirection(1, -1)
template:setTubeDirection(2,  1)
template:setTubeDirection(3, -2)
template:setTubeDirection(4,  2)

--[[ Artillery--]]
--Artillery are non-warp capable ships, mostly used to delivers Nukes to their enemies. They may be disguised as Transport ships (or are refurbished freighters). 
template = ShipTemplate():setName("Flash"):setClass(_("class", "Exuari"), _("subclass", "Artillery"))
template:setModel("small_frigate_2"):setRadarTrace("exuari_2.png")
template:setDescription(_([[The Exuari Flash is a special artillery sniper, built to deal a large amounts of damage quickly and from a distance before escaping. It's a basic freighter that carries nuclear weapons. Some say, this is what happens to freighters, when they fall into the hands of the Exuari.]]))
template:setHull(30)
template:setShields(30, 5, 5)
--Reputation Score: 7
template:setSpeed(50, 6, 20)
template:setTubes(3, 25.0)
template:weaponTubeDisallowMissle(1, "Nuke"):weaponTubeDisallowMissle(2, "Nuke")
template:setWeaponStorage("Homing", 6)
template:setWeaponStorage("Nuke", 2)

variation = template:copy("Ranger")
variation:setDescription(_([[The Exuari Ranger is a special sniper, built to deal large amounts of damage over a large area and from a distance before escaping. It's a basic frigate that carries nuclear weapons, even though it's also one of the smallest of all frigate-class ships.]]))
variation:setSpeed(55, 6, 20)
variation:setTubes(1, 15.0)
variation:setTubeSize(0, "small")
variation:setWeaponStorage("Homing", 0)
variation:setWeaponStorage("Nuke", 4)

variation = template:copy("Buster")
variation:setDescription(_([[The Exuari Buster is a special sniper, built to deal a large amount of damage quickly and from a distance before escaping. It's a basic frigate that carries nuclear weapons, even though it's also one of the smallest of all frigate-class ships.]]))
variation:setSpeed(50, 6, 20)
variation:setTubes(1, 15.0)
variation:setTubeSize(0, "large")
variation:setWeaponStorage("Nuke", 1)

--[[ Station/Transport--]]
-- The battle station is a huge ship with many defensive features. It can be docked by smaller ships.
-- small station
template = ShipTemplate():setName("Ryder"):setModel("Ender Battlecruiser"):setClass(_("class", "Exuari"), _("subclass", "Carrier"))
template:setRadarTrace("battleship.png")
template:setDescription(_("The Exuari 'Ryder' is a large carrier spacecraft with many defensive features. It can be docked by smaller ships to refuel or carry them. Unlike a station it is equipped with a slow impulse drive and capable of interstellar travel. It is used as a habitation for Exuari crews and has a hangar bay. A commom Exuari assault strategy is to keep a Ryder off the sensor range of the desired target, while fighters and artillery start from the carrier."))
--                  Arc, Dir, Range, CycleTime, Dmg
template:setBeam(0,  20, -90, 1200.0, 6.1, 4):setBeamWeaponTurret(0, 160, -90, 5)
template:setBeam(1,  20, -90, 1200.0, 6.0, 4):setBeamWeaponTurret(1, 160, -90, 5)
template:setBeam(2,  20,  90, 1200.0, 6.1, 4):setBeamWeaponTurret(2, 160,  90, 5)
template:setBeam(3,  20,  90, 1200.0, 6.0, 4):setBeamWeaponTurret(3, 160,  90, 5)
template:setBeam(4,  20, -90, 1200.0, 5.9, 4):setBeamWeaponTurret(4, 160, -90, 5)
template:setBeam(5,  20, -90, 1200.0, 6.2, 4):setBeamWeaponTurret(5, 160, -90, 5)
template:setBeam(6,  20,  90, 1200.0, 5.9, 4):setBeamWeaponTurret(6, 160,  90, 5)
template:setBeam(7,  20,  90, 1200.0, 6.2, 4):setBeamWeaponTurret(7, 160,  90, 5)
template:setBeam(8,  20, -90, 1200.0, 6.1, 4):setBeamWeaponTurret(8, 160, -90, 5)
template:setBeam(9,  20, -90, 1200.0, 6.0, 4):setBeamWeaponTurret(9, 160, -90, 5)
template:setBeam(10, 20,  90, 1200.0, 6.1, 4):setBeamWeaponTurret(10, 160,  90, 5)
template:setBeam(11, 20,  90, 1200.0, 6.0, 4):setBeamWeaponTurret(11, 160,  90, 5)
template:setHull(100)
template:setShields(250)
--Reputation Score: 35
template:setSpeed(20, 1.5, 3)
template:setDockClasses(_("class", "Exuari"), _("class", "Frigate"))
template:setSharesEnergyWithDocked(true)
template:setRepairDocked(true)
template:setRestocksMissilesDocked("cpuships")
template:setRestocksScanProbes(true)

-- medium station
variation = template:copy("Zeppelin")
variation:setDescription(_("The Exuari 'Zeppelin' is a large carrier spacecraft with many defensive features. It can be docked by smaller ships to refuel or carry them. Unlike a station it is equipped with a slow impulse drive and capable of interstellar travel. It is used as a habitation for Exuari crews and has a hangar bay. A commom Exuari assault strategy is to keep a Zeppelin off the sensor range of the desired target, while fighters and artillery start from the carrier."))
--                  Arc, Dir, Range, CycleTime, Dmg
variation:setBeam(0,  20, -90, 1800.0, 6.1, 4):setBeamWeaponTurret(0, 160, -90, 5)
variation:setBeam(1,  20, -90, 1800.0, 6.0, 4):setBeamWeaponTurret(1, 160, -90, 5)
variation:setBeam(2,  20,  90, 1800.0, 6.1, 4):setBeamWeaponTurret(2, 160,  90, 5)
variation:setBeam(3,  20,  90, 1800.0, 6.0, 4):setBeamWeaponTurret(3, 160,  90, 5)
variation:setBeam(4,  20, -90, 1800.0, 5.9, 4):setBeamWeaponTurret(4, 160, -90, 5)
variation:setBeam(5,  20, -90, 1800.0, 6.2, 4):setBeamWeaponTurret(5, 160, -90, 5)
variation:setBeam(6,  20,  90, 1800.0, 5.9, 4):setBeamWeaponTurret(6, 160,  90, 5)
variation:setBeam(7,  20,  90, 1800.0, 6.2, 4):setBeamWeaponTurret(7, 160,  90, 5)
variation:setBeam(8,  20, -90, 1800.0, 6.1, 4):setBeamWeaponTurret(8, 160, -90, 5)
variation:setBeam(9,  20, -90, 1800.0, 6.0, 4):setBeamWeaponTurret(9, 160, -90, 5)
variation:setBeam(10, 20,  90, 1800.0, 6.1, 4):setBeamWeaponTurret(10, 160,  90, 5)
variation:setBeam(11, 20,  90, 1800.0, 6.0, 4):setBeamWeaponTurret(11, 160,  90, 5)
variation:setShields(600)
variation:setHull(300)
--Reputation Score: 

-- large station
variation = template:copy("Craver")
variation:setDescription(_("The Exuari Craver is a huge carrier with many defensive features. It can be docked by smaller ships to refuel or carry them. Unlike a station it is equipped with a slow impulse drive. The shields of this base carrier are saied to be very strong."))
--                  Arc, Dir, Range, CycleTime, Dmg
variation:setBeam(0,  20, -90, 2200.0, 6.1, 4):setBeamWeaponTurret(0, 160, -90, 5)
variation:setBeam(1,  20, -90, 2200.0, 6.0, 4):setBeamWeaponTurret(1, 160, -90, 5)
variation:setBeam(2,  20,  90, 2200.0, 6.1, 4):setBeamWeaponTurret(2, 160,  90, 5)
variation:setBeam(3,  20,  90, 2200.0, 6.0, 4):setBeamWeaponTurret(3, 160,  90, 5)
variation:setBeam(4,  20, -90, 2200.0, 5.9, 4):setBeamWeaponTurret(4, 160, -90, 5)
variation:setBeam(5,  20, -90, 2200.0, 6.2, 4):setBeamWeaponTurret(5, 160, -90, 5)
variation:setBeam(6,  20,  90, 2200.0, 5.9, 4):setBeamWeaponTurret(6, 160,  90, 5)
variation:setBeam(7,  20,  90, 2200.0, 6.2, 4):setBeamWeaponTurret(7, 160,  90, 5)
variation:setBeam(8,  20, -90, 2200.0, 6.1, 4):setBeamWeaponTurret(8, 160, -90, 5)
variation:setBeam(9,  20, -90, 2200.0, 6.0, 4):setBeamWeaponTurret(9, 160, -90, 5)
variation:setBeam(10, 20,  90, 2200.0, 6.1, 4):setBeamWeaponTurret(10, 160,  90, 5)
variation:setBeam(11, 20,  90, 2200.0, 6.0, 4):setBeamWeaponTurret(11, 160,  90, 5)
variation:setShields(1500)
variation:setHull(400)
--Reputation Score: 

-- huge station
variation = template:copy("Ridge")
variation:setDescription(_("The Exuari Ridge is a huge carrier with many defensive features. It can be docked by smaller ships to refuel or carry them. Unlike a station it is equipped with a slow impulse drive. The shields of this base carrier are saied to be undestroyable."))
--                  Arc, Dir, Range, CycleTime, Dmg
variation:setBeam(0,  20, -90, 2400.0, 6.1, 4):setBeamWeaponTurret(0, 160, -90, 5)
variation:setBeam(1,  20, -90, 2400.0, 6.0, 4):setBeamWeaponTurret(1, 160, -90, 5)
variation:setBeam(2,  20,  90, 2400.0, 6.1, 4):setBeamWeaponTurret(2, 160,  90, 5)
variation:setBeam(3,  20,  90, 2400.0, 6.0, 4):setBeamWeaponTurret(3, 160,  90, 5)
variation:setBeam(4,  20, -90, 2400.0, 5.9, 4):setBeamWeaponTurret(4, 160, -90, 5)
variation:setBeam(5,  20, -90, 2400.0, 6.2, 4):setBeamWeaponTurret(5, 160, -90, 5)
variation:setBeam(6,  20,  90, 2400.0, 5.9, 4):setBeamWeaponTurret(6, 160,  90, 5)
variation:setBeam(7,  20,  90, 2400.0, 6.2, 4):setBeamWeaponTurret(7, 160,  90, 5)
variation:setBeam(8,  20, -90, 2400.0, 6.1, 4):setBeamWeaponTurret(8, 160, -90, 5)
variation:setBeam(9,  20, -90, 2400.0, 6.0, 4):setBeamWeaponTurret(9, 160, -90, 5)
variation:setBeam(10, 20,  90, 2400.0, 6.1, 4):setBeamWeaponTurret(10, 160,  90, 5)
variation:setBeam(11, 20,  90, 2400.0, 6.0, 4):setBeamWeaponTurret(11, 160,  90, 5)
variation:setShields(2500)
variation:setHull(800)
--Reputation Score:

--[[
Component details used for designing the ships above:
 Beams
  Exuari Fighter beam: rng 1000, cycle 4, dmg 4, dps 1
  Exuari Striker beam: rng 1000, cycle 6, dmg 6, dps 1
  Exuari Turret  beam: rng 1200, cycle 3/6/9, dmg 2/4/6, dps 0.66 
 Hull/shields
  Fighter 30, 30
  Bomber  40, 30
  Striker 50, 50/30 or 80/30/30/30
  Frigate 70, 50/40 (more variation)
 Engines
  Fighter 120-130, 30-35, 25-30
  Bomber  70, 20, 15
  Striker 70, 12, 12 +warp
  Frigate 40-70, 6-15, 8-20 
  Station 20, 1.5, 3
--]]

