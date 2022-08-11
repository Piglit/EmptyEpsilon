----------------------Ktlitan ships
--Faction style (equipment):
--hull:    30-350
--shields: always 0  (original destroyer & queen had shields, those were removed for consistency)
--beam:    rng 600-1200, dmg 6, cycle 4.0, dps 1.5 (except destroyer: 10/6, dps 1.66)
--missiles: only special
--speed: impulse 70-150 very fast!  maneuver 5-35,  accel:  25 (exc. destr.)

-- roles from bee-hive:
-- Queen: lays eggs - unfertile for drones, send alive-signal to all bees in that hive - keeps others sterile as long as queen is alive
-- Drones: male, fertilise eggs, no stingers, no long range travel. Will be left behind when resources are low
-- Worker: largest population, can only produces eggs->drones when no queen is avail. Following are worker jobs:
-- Cleaner: clean cells for new eggs
-- Undertaker: remove dead ones
-- Nurse: care for larvae, distributes nutrition, repairs?
-- Builder: Builds cells, needs much food
-- Temperatur Controller: Bring cooling Water, act as Fans or cuddle for warmth
-- Guard: Checks against intruders, defends Hive
-- Forager: Searches for Food in 5 km radius


descr = [[Ktlitan Drones are the smallest ships of the Ktlitan hive-fleets. They mostly carry crew or smaller cargo between other ships, but will also attack ships crossing their paths.

New Drones are deployed by Ktlitan Queens, but are also often left behind when the fleet departs. The reason for this is currently unknown. Speculations are that Drones are cheaper to build than to maintain inside the fleet.

Single Ktlitan Drones do not pose a thread against any shielded ship, but add to the firepower of a bigger fleet.
]]
-- Usage: Queens spawn Drones (Hangar-endless-5u-60s) with orders set to defend (near) location. Other ships should follow the Queen. That way the Fleet may leave a trail of Drones whenever they encountered resistance.
template = ShipTemplate():setName("Ktlitan Drone"):setLocaleName(_("ship", "Ktlitan Drone")):setModel("sci_fi_alien_ship_4")
template:setDescription(_(descr))
template:setRadarTrace("ktlitan_drone.png")
template:setBeam(0, 40, 0, 600.0, 4.0, 6)
template:setHull(30)
--Reputation Score: 3
template:setSpeed(120, 10, 25)
template:setDefaultAI("fighter")

variation = template:copy("Lite Drone"):setLocaleName(_("ship", "Lite Drone"))
variation:setHull(20)
variation:setSpeed(130, 20, 25)
variation:setBeam(0, 40, 0, 600, 4.0, 4)
variation:setDescription(_(descr .. "The lite drone has a weaker hull, and a weaker beam, but a faster turn and impulse speed than the normal Ktlitan Drone"))

variation = template:copy("Heavy Drone"):setLocaleName(_("ship", "Heavy Drone"))
variation:setHull(40)
variation:setSpeed(110, 10, 25)
variation:setBeam(0, 40, 0, 600, 4.0, 8)
variation:setDescription(_(descr .. "The heavy drone has a stronger hull and a stronger beam than the normal Ktlitan Drone, but it also moves slower"))

--Design question: do we want shielded drones?
--variation = template:copy("Jacket Drone"):setLocaleName(_("ship", "Jacket Drone"))
--variation:setShields(20)
--variation:setSpeed(110, 10, 25)
--variation:setBeam(0, 40, 0, 600, 4.0, 4)
--variation:setDescription(_(descr .. "The Jacket Drone is a Ktlitan Drone with a shield. It's also slightly slower and has a slightly weaker beam due to the energy requirements of the added shield"))

variation = template:copy("Gnat"):setLocaleName(_("ship", "Gnat"))
variation:setHull(15)
variation:setSpeed(140, 25, 25)
variation:setBeam(0, 40, 0, 600, 4.0, 3)
variation:setDescription(_(descr .. "The Gnat is a nimbler version of the Ktlitan Drone. It's got half the hull, but it moves and turns faster"))


descr = [[The Ktlitan Worker is the most common ship in a Ktlitan hive-fleet. These ships play a secondary role in combat, but forefill specific tasks within the fleet.
]]
-- Usage: defend (any) other ships. Produced by Queens (Hangar-endless-15u-90s)
template = ShipTemplate():setName("Ktlitan Worker"):setLocaleName(_("ship", "Ktlitan Worker")):setModel("sci_fi_alien_ship_3")
template:setDescription(_(descr))
template:setRadarTrace("ktlitan_worker.png")
template:setBeam(0, 40, -90, 600.0, 4.0, 6)
template:setBeam(1, 40, 90, 600.0, 4.0, 6)
template:setHull(50)
--Reputation Score: 5
template:setSpeed(100, 35, 25)
template:setDefaultAI("fighter")


-- Worker -> Cleaner or Undertaker
-- Cleaner -> Nurse
-- Undertaker -> Builder
variation = template:copy("Cleaner"):setLocaleName(_("ship", "Cleaner"))
variation:setBeam(0, 40, -30, 600, 4.0, 6)
variation:setDescription(_(descr .. "Maintains fleet space"))

variation = template:copy("Undertaker"):setLocaleName(_("ship", "Undertaker"))
variation:setBeam(1, 40, 30, 600, 4.0, 6)
variation:setDescription(_(descr .. "Collects destroyed ships"))

variation = template:copy("Nurse"):setLocaleName(_("ship", "Nurse"))
variation:setBeam(0, 40, -30, 600, 4.0, 6)
-- Dockable
variation:setDescription(_(descr .. "Repairs ships"))

variation = template:copy("Builder"):setLocaleName(_("ship", "Builder"))
variation:setBeam(1, 40, 30, 600, 4.0, 6)
-- Can spwan bigger ships (Hangar-single-use-7u)
variation:setDescription(_(descr .. "Creates ships"))


descr = ""
-- Usage: set to Roaming
template = ShipTemplate():setName("Ktlitan Scout"):setLocaleName(_("ship", "Ktlitan Scout")):setModel("sci_fi_alien_ship_6")
template:setDescription(_(descr))
template:setRadarTrace("ktlitan_scout.png")
template:setBeam(0, 40, 0, 600.0, 4.0, 6)
template:setHull(100)
--Reputation Score: 10
template:setSpeed(150, 30, 25)




descr = ""
template = ShipTemplate():setName("Ktlitan Fighter"):setLocaleName(_("ship", "Ktlitan Fighter")):setModel("sci_fi_alien_ship_1")
template:setDescription(_(descr))
template:setRadarTrace("ktlitan_fighter.png")
template:setBeam(0, 60, 0, 1200.0, 4.0, 6)
template:setHull(70)
--Reputation Score: 7
template:setSpeed(140, 30, 25)
template:setDefaultAI('fighter')	-- set fighter AI, which dives at the enemy, and then flies off, doing attack runs instead of "hanging in your face".

variation = template:copy("K2 Fighter"):setLocaleName(_("ship", "K2 Fighter"))
variation:setBeam(0, 60, 0, 1200.0, 2.5, 6)
variation:setHull(65)
variation:setDescription(_(descr .. "It's got beams that cycle faster, but the hull is a bit weaker."))

variation = template:copy("K3 Fighter"):setLocaleName(_("ship", "K3 Fighter"))
variation:setBeam(0, 60, 0, 1200.0, 2.5, 9)
variation:setHull(60)
variation:setDescription(_(descr .. "It's got beams that are stronger and cycle faster, but the hull is weaker."))

descr = ""
template = ShipTemplate():setName("Ktlitan Feeder"):setLocaleName(_("ship", "Ktlitan Feeder")):setModel("sci_fi_alien_ship_5")
template:setDescription(_(descr))
template:setRadarTrace("ktlitan_feeder.png")
template:setBeam(0, 20, 0, 800.0, 4.0, 6)
template:setBeam(1, 35,-15, 600.0, 4.0, 6)
template:setBeam(2, 35, 15, 600.0, 4.0, 6)
template:setBeam(3, 20,-25, 600.0, 4.0, 6)
template:setBeam(4, 20, 25, 600.0, 4.0, 6)
template:setHull(150)
--Reputation Score: 15
template:setSpeed(120, 8, 25)

descr = ""
template = ShipTemplate():setName("Ktlitan Breaker"):setLocaleName(_("ship", "Ktlitan Breaker")):setModel("sci_fi_alien_ship_2")
template:setDescription(_(descr))
template:setRadarTrace("ktlitan_breaker.png")
template:setBeam(0, 40, 0, 800.0, 4.0, 6)
template:setBeam(1, 35,-15, 800.0, 4.0, 6)
template:setBeam(2, 35, 15, 800.0, 4.0, 6)
template:setTubes(1, 13.0) -- Amount of torpedo tubes, loading time
--template:setTubeSize(0, "large") -- addes by Pithlit 
template:setWeaponStorage("HVLI", 5) --Only give this ship HVLI's
template:setHull(120)
--Reputation Score: 12
template:setSpeed(100, 5, 25)

variation = template:copy("K2 Breaker"):setLocaleName(_("ship", "K2 Breaker"))
variation:setHull(200)
variation:setTubes(3, 13.0) -- Amount of torpedo tubes, loading time
variation:setTubeSize(0, "large"):setWeaponTubeExclusiveFor(0, "HVLI")
variation:setTubeDirection(1, -30)
variation:setTubeDirection(2,  30)
variation:setWeaponStorage("HVLI", 8)
variation:setWeaponStorage("Homing", 16)
variation:setDescription(_(descr .. "he K2 Breaker is a Ktlitan Breaker with beefed up hull, and two bracketing tubes, enlarged center tube and more missiles to shoot. Should be good for a couple of enemy ships"))

descr = ""
template = ShipTemplate():setName("Ktlitan Destroyer"):setLocaleName(_("ship", "Ktlitan Destroyer")):setModel("sci_fi_alien_ship_7")
template:setRadarTrace("ktlitan_destroyer.png")
template:setBeam(0, 90, -15, 1000.0, 6.0, 10)
template:setBeam(1, 90,  15, 1000.0, 6.0, 10)
template:setHull(450)
--template:setShields(50, 50, 50)
-- shields were removed for stronger hull
--Reputation Score: 45
template:setTubes(3, 15.0) -- Amount of torpedo tubes
template:setSpeed(70, 5, 10)
template:setWeaponStorage("Homing", 25)
template:setDefaultAI('missilevolley')

descr = ""
template = ShipTemplate():setName("Ktlitan Queen"):setModel("sci_fi_alien_ship_8"):setClass("Ktlitan", "Queen")
template:setDescription(_(descr))
template:setRadarTrace("ktlitan_queen.png")
template:setHull(650)
--template:setShields(100, 100, 100)
-- shields were removed for stronger hull
--Reputation Score: 65
template:setTubes(2, 15.0) -- Amount of torpedo tubes
template:setWeaponStorage("Nuke", 5)
template:setWeaponStorage("EMP", 5)
template:setWeaponStorage("Homing", 5)
template:setSpeed(500, 10, 20)	-- default values

variation = template:copy("Diva"):setLocaleName(_("ship", "Diva"))
variation:setSpeed(35, 8, 5)
variation:setTubeDirection(1, 180)
variation:setDescription(_(descr .. "The Diva is a mobile version of the Ktlitan Queen with one tube pointed to the rear"))

variation = template:copy("Tsarina"):setLocaleName(_("ship", "Tsarina"))
variation:setBeamWeapon(0, 90, -15, 1000.0, 6.0, 10)
variation:setBeamWeapon(1, 90, -45, 1000.0, 6.0, 10)
variation:setBeamWeapon(3, 90, 15, 1000.0, 6.0, 10)
variation:setBeamWeapon(4, 90, 45, 1000.0, 6.0, 10)
variation:setTubeSize(0, "small")
variation:setTubeSize(1, "small")
variation:setWeaponStorage("Nuke", 0)
variation:setWeaponStorage("EMP", 0)
variation:setWeaponStorage("Homing", 0)
variation:setWeaponStorage("HVLI", 100)
variation:setHull(600)
variation:setShields(100, 100, 100)
variation:setDefaultAI("fighter")
variation:setDescription(_(descr .. "Undiscovered type of Ktlitan warship", "Ktlitan Tsarina is a subtype of Ktlitan Queen. It's twice as agile and durable.  " .. "It focuses on using beams and dumbfire weapons. "))
variation:setSpeed(500, 20, 20)


