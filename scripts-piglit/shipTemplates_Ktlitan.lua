----------------------Ktlitan ships
--
--Faction style (equipment):
--hull:    30-350
--shields: mostly 0, except destroyer (3*50) & queen (3*100)
--beam:    rng 600-1200, dmg 6, cycle 4.0, dps 1.5 (except destroyer: 10/6, dps 1.66)
--missiles: only special
--speed: impulse 70-150 very fast!  maneuver 5-35,  accel:  25 (exc. destr.)



template = ShipTemplate():setName("Ktlitan Fighter"):setModel("sci_fi_alien_ship_1"):setClass("Ktlitan", "Fighter")
template:setRadarTrace("radar_ktlitan_fighter.png")
template:setBeam(0, 60, 0, 1200.0, 4.0, 6)
template:setHull(70)
--Reputation Score: 7
template:setSpeed(140, 30, 25)
template:setDefaultAI('fighter')	-- set fighter AI, which dives at the enemy, and then flies off, doing attack runs instead of "hanging in your face".

template = ShipTemplate():setName("Ktlitan Breaker"):setModel("sci_fi_alien_ship_2"):setClass("Ktlitan", "Breaker")
template:setRadarTrace("radar_ktlitan_breaker.png")
template:setBeam(0, 40, 0, 800.0, 4.0, 6)
template:setBeam(1, 35,-15, 800.0, 4.0, 6)
template:setBeam(2, 35, 15, 800.0, 4.0, 6)
template:setTubes(1, 13.0) -- Amount of torpedo tubes, loading time
template:setTubeSize(0, "large")
template:setWeaponStorage("HVLI", 5) --Only give this ship HVLI's
template:setHull(120)
--Reputation Score: 12
template:setSpeed(100, 5, 25)

template = ShipTemplate():setName("Ktlitan Worker"):setModel("sci_fi_alien_ship_3"):setClass("Ktlitan", "Worker")
template:setRadarTrace("radar_ktlitan_worker.png")
template:setBeam(0, 40, -90, 600.0, 4.0, 6)
template:setBeam(1, 40, 90, 600.0, 4.0, 6)
template:setHull(50)
--Reputation Score: 5
template:setSpeed(100, 35, 25)

template = ShipTemplate():setName("Ktlitan Drone"):setModel("sci_fi_alien_ship_4"):setClass("Ktlitan", "Drone")
template:setRadarTrace("radar_ktlitan_drone.png")
template:setBeam(0, 40, 0, 600.0, 4.0, 6)
template:setHull(30)
--Reputation Score: 3
template:setSpeed(120, 10, 25)

template = ShipTemplate():setName("Ktlitan Feeder"):setModel("sci_fi_alien_ship_5"):setClass("Ktlitan", "Feeder")
template:setRadarTrace("radar_ktlitan_feeder.png")
template:setBeam(0, 20, 0, 800.0, 4.0, 6)
template:setBeam(1, 35,-15, 600.0, 4.0, 6)
template:setBeam(2, 35, 15, 600.0, 4.0, 6)
template:setBeam(3, 20,-25, 600.0, 4.0, 6)
template:setBeam(4, 20, 25, 600.0, 4.0, 6)
template:setHull(150)
--Reputation Score: 15
template:setSpeed(120, 8, 25)

template = ShipTemplate():setName("Ktlitan Scout"):setModel("sci_fi_alien_ship_6"):setClass("Ktlitan", "Scout")
template:setRadarTrace("radar_ktlitan_scout.png")
template:setBeam(0, 40, 0, 600.0, 4.0, 6)
template:setHull(100)
--Reputation Score: 10
template:setSpeed(150, 30, 25)

template = ShipTemplate():setName("Ktlitan Destroyer"):setModel("sci_fi_alien_ship_7"):setClass("Ktlitan", "Destroyer")
template:setRadarTrace("radar_ktlitan_destroyer.png")
template:setBeam(0, 90, -15, 1000.0, 6.0, 10)
template:setBeam(1, 90,  15, 1000.0, 6.0, 10)
template:setHull(300)
template:setShields(50, 50, 50)
--Reputation Score: 45
template:setTubes(3, 15.0) -- Amount of torpedo tubes
template:setSpeed(70, 5, 10)
template:setWeaponStorage("Homing", 25)
template:setDefaultAI('missilevolley')

template = ShipTemplate():setName("Ktlitan Queen"):setModel("sci_fi_alien_ship_8"):setClass("Ktlitan", "Queen")
template:setRadarTrace("radar_ktlitan_queen.png")
template:setHull(350)
template:setShields(100, 100, 100)
--Reputation Score: 65
template:setTubes(2, 15.0) -- Amount of torpedo tubes
template:setWeaponStorage("Nuke", 5)
template:setWeaponStorage("EMP", 5)
template:setWeaponStorage("Homing", 5)

