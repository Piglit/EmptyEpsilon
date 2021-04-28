--Ships from Kraylor shipyards.
--
--Faction style (equipment):
--moderate hull, even on heavyer ships (Kraylors can survive hull breaches more easily than other species)
--strong shields, more shield segments (counts as pysical strength of the ship)
--heavyer beams
--moderate speed, no warp, heavyer ships may have jump
--homing missiles as standarg equipment. Heavyer ships have also HVLIs.
--focus on capital ships, no fighters, few specialiced ships
--big bulky ships
--naming mentions physical strength and the destructive capabilities of the ship
--Models: battleship_destroyer_*
--
--Tech details:
-- Beams
--  Kraylor standard beam:     Range: 1000-1500 CycleTime: 6.0 Dmg: 8  (dps: 1.33)
--  Kraylor heavy beam:        Range: 1500-2000 CycleTime: 8.0 Dmg: 11 (dps: 1.375) (only doombringer)
--  Kraylor turbo beam:        Range: 3000-4000 CycleTime: 3.0 Dmg: 10 (dps: 3.33)  (stations only)
-- Hull/shields
--  100, 100/80/80
--  70,  100/150
--  70,  5*300
--  100, 4*200
--  200, 450/2*350/2*150
--  150, 6*120
--  => hull: 70-200, shields: 2-6 * 80-300
-- Engines
--  Gunships  60, 5-15, 10-25
--  Destroyer 30-35, 1.5-6, 5-10 jump

--[[Fighter--]]
template = ShipTemplate():setName("Drone"):setClass("Starfighter", "Interceptor")
template:setModel("small_fighter_1") --TODO own model!
template:setRadarTrace("radar_kraylor_fighter.png")
template:setDescription([[The Kraylor Drone is an automated interceptor vehicle. Often some gunships or destroyers carry drones with them to distract their enemies while attacking. Novice crews often fall for it and waste expensive missiles firing at drones, but due to theirs small size, drones can easily dodge some missiles. The drones beams consist of old and lightweight technology, nothing compared with the usual Kraylor beams. As long as your shields are up, its almost save to igonre drones.]])
template:setHull(16)
template:setShields(15)
--Reputation Score: 3.1
template:setSpeed(100, 25, 20)
template:setDefaultAI('fighter')
--                  Arc, Dir, Range, CycleTime, Dmg
template:setBeam(0, 270, 0, 500.0, 4.0, 1.5)

--[[----------------------Gunships------------------------]]
-- Gunships are the weakest capital ships the Kraylor shipyards offer.
-- Equipment: Kraylor standard beams (short range), impulse speed: 60
rockbreaker_description = [[The Rockbreaker gunship is a spacecraft popular among Kraylor raiders. Since the Kraylor military got rid of those ships after the Ganymede slaughter, they are very cheap on the Kraylor second hand shipyards. These ships are not well equiped, but easily to repair.

The Rockbreaker is equiped with a central homing missile tube to do initial damage and then take out the enemy with 2 front firing beams. It's designed to quickly destroy single enemies weaker than itself. The shields of most human frigates will only last few seconds under the fire of a fully equipped Rockbreaker.
]]

--Balancing: 1 Rockbreaker ~= 1.5 Human Frigates.
--strong against Nirvanas and Phobos (R. takes out one or two), weak against Piranhas and Storms (R. takes out zero or one)

template = ShipTemplate():setName("Rockbreaker"):setModel("battleship_destroyer_5_upgraded"):setClass("Kraylor","Gunship")
template:setRadarTrace("radar_kraylor_gunship.png")
template:setDescription(rockbreaker_description)
--                  Arc, Dir, Range, CycleTime, Dmg
template:setBeam(0, 50, 0, 1000.0, 6.0, 8)
template:setBeam(1, 50, 0, 1000.0, 6.0, 8)
template:setTubes(1, 16.0) -- Amount of torpedo tubes
template:setHull(100)
template:setShields(100, 80, 80)
--Reputation Score: 36
template:setSpeed(60, 5, 10)
template:setWeaponStorage("Homing", 4)
--threat level: 2*1.3=2.6(dps)+1*4(tube)+(100+80+80)/60=4.3(shields)+100/100=1(hull) = 2.6+4+4.3+1=11.9
--Key features: homing and beams. Variants should modify those.

variation = template:copy("Rockbreaker Merchant")
variation:setDescription(rockbreaker_description .. " The civil version of the Rockbreaker is designed to remove small space debris or fighters with it's wide beam angles.")
variation:setBeam(0, 60,-5, 1000.0, 6.0, 8)
variation:setBeam(1, 60, 5, 1000.0, 6.0, 8)
--threat level: 12.4

variation = template:copy("Rockbreaker Murderer")
variation:setDescription(rockbreaker_description .. " This version of the Rockbreaker was mostly used by assassins and black ops and comes with a much greater beam range than the standard vessel. In close combat between two Rockbreaker variants the Murderer usualy has the first strike.")
variation:setBeam(0, 50, 0, 1500.0, 6.0, 8)
variation:setBeam(1, 50, 0, 1500.0, 6.0, 8)
--threat level: 12.9

variation = template:copy("Rockbreaker Mercenary")
variation:setDescription(rockbreaker_description .. " The upgraded mercenary version of the Rockbreaker is able to fire its missiles much faster. This allows the ship to destroy enemies sooner, taking fewer damage in combat.")
variation:setTubes(1, 10.0) -- Amount of torpedo tubes
--threat level: 13.9

variation = template:copy("Rockbreaker Marauder")
variation:setDescription(rockbreaker_description .. " This old experimental version of the Rockbreaker has a lager missile storage for a longer attack run. This may come to use in guerilla strikes.")
variation:setWeaponStorage("Homing", 8)
--threat level: 14.9

variation = template:copy("Rockbreaker Military")
variation:setDescription(rockbreaker_description .. " The newer military version of the Rockbreaker is equiped with a double-action homing missile tube that fires two missiles in very short time before reloading.")
variation:setTubes(2, 16.0) -- Amount of torpedo tubes
--threat level: 15.9


template = ShipTemplate():setName("Spinebreaker"):setModel("battleship_destroyer_2_upgraded"):setClass("Kraylor","Gunship")
template:setRadarTrace("radar_kraylor_gunship_reargun.png")
template:setDescription("The Spinebreaker blockade runner is a reasonably fast, high shield spacecraft designed to break through defense lines. Its light hull plating and the lack of missiles make this vessel high maneuverable and fast accelerating, but pysically weaker in the eyes of the Kraylor society. Often the crew of this craft consists of cowards, criminals or otherwise politically unpleasent individuals. The additional beams and the higher powered front shields are one step up from the Bonebreaker towards Destroyer class ships.")
--                  Arc, Dir, Range, CycleTime, Dmg
template:setBeam(0, 60, 0, 1000.0, 6.0, 8)
template:setBeam(1, 60, 0, 1000.0, 6.0, 8)
template:setBeam(4, 60, -5, 1000.0, 6.0, 8)
template:setBeam(5, 60, 5, 1000.0, 6.0, 8)
template:setHull(60)
template:setShields(150, 100)
--Reputation Score: 31
template:setSpeed(60, 10, 20)



--[[----------------------Destroyers----------------------]]
-- Destroyers slow but are heavy armed and strong shielded ships.
-- Equipment: Kraylor standard or heavy beams (long range), impulse speed: 30, optional: jump drive

template = ShipTemplate():setName("Deathbringer"):setModel("battleship_destroyer_1_upgraded"):setClass("Kraylor","Destroyer")
template:setRadarTrace("radar_kraylor_gunship_adv.png")
template:setDescription([[The Deathbringer destroyer is one of the oldest designs the Kraylor engineers remember, and no new ones were built over the last decades. But there are still many Deathbringers around and they are still seen in the Kraylor navy. The age may be the reason for the slow engines and the lack of missile tubes.

In the Kraylor society the Deathbringer is seen as flying fortress, since it packs a huge amount of beam weapons in the front. Everybody knows that taking it head-on is suicide. But the corrosive hull plating, the small blind spots and its really slow maneuvering may give nimble pilots a chance to cause serious damage.]])
--                  Arc, Dir, Range, CycleTime, Dmg
template:setBeam(0, 90, -25, 1500.0, 6.0, 8)
template:setBeam(1, 90,  25, 1500.0, 6.0, 8)
template:setBeam(2,100, -60, 1000.0, 6.0, 8)
template:setBeam(3,100,  60, 1000.0, 6.0, 8)
template:setBeam(4, 30,   0, 2000.0, 6.0, 8)
template:setBeam(5,100, 180, 1200.0, 6.0, 8)
template:setHull(70)
template:setShields(300, 300, 300, 300, 300)
--Reputation Score: 157
template:setSpeed(30, 1.5, 5)
--threat level: 6*1.3=7.8(dps)+(300)/20=15(shields)+0.7(hull) = 7.8+15+0.7=23.5
--Key features: Beams configuration. Variants should change arc, dir, range.

template = ShipTemplate():setName("Painbringer"):setClass("Kraylor", "Destroyer"):setModel("battleship_destroyer_4_upgraded")
template:setDescription([[The Painbringer a small destroyer, and its combination of frigate-like beam weapons and corvette-like shields and a huge torpedo storage make it an excellent strike ship. Because the Painbringer is fitted with a jump drive, it can also serve as an intersystem surprise strike craft.]])
template:setRadarTrace("radar_kraylor_destroyer_sides.png")
template:setHull(100)
template:setShields(200, 200, 200, 200)
--Reputation Score: 90
template:setSpeed(30, 3.5, 5)
template:setJumpDrive(true)
--                  Arc, Dir, Range, CycleTime, Dmg
template:setBeam(0,100, 0, 1500.0, 6.0, 8)
template:setBeam(1,100, 0, 1500.0, 6.0, 8)
template:setTubes(2, 10.0)
template:setWeaponStorage("HVLI", 20)
template:setWeaponStorage("Homing", 4)

--threat level: 3*1.3=3.9(dps)+~8(tube)+(200)/20=10(shields)+1(hull) = 3.9+8+10+1=24.9
--Key features: side attack capability

template = ShipTemplate():setName("Doombringer"):setClass("Kraylor", "Destroyer"):setModel("battleship_destroyer_3_upgraded")
template:setDescription([[The Doombringer lives its name as a phenomenal frontal assault ship. This spacecraft just left the prototype state and is seen in the Kraylor fleet more and more often. It features the newest military equipment available: The Kraylor heavy beams, stronger shields, reinforced hull plating and improved engines. It is the only known Kraylor spacecraft that is equiped with EMP projectiles. Its jump drive balances out its low speed and when it is positioned in the right place at the right time, even the strongest shields can't withstand a Doombringers assault for long. The best chance to destroy a Doombringer may be an attack from behind.]])
template:setRadarTrace("radar_kraylor_destroyer_frontal.png")
template:setHull(200)
template:setShields(450, 350, 150, 150, 350)
--Reputation Score: 165
template:setSpeed(35, 6, 10)
template:setJumpDrive(true)
--                  Arc, Dir, Range, CycleTime, Dmg
template:setBeam(0, 60, -10, 2000.0, 8.0, 11)
template:setBeam(1, 60,  10, 2000.0, 8.0, 11)
template:setBeam(2, 60, -20, 1500.0, 8.0, 11)
template:setBeam(3, 60,  20, 1500.0, 8.0, 11)
template:setTubes(2, 10.0)
template:setWeaponStorage("HVLI", 20)
template:setWeaponStorage("Homing", 4)
template:setWeaponStorage("EMP", 2)
template:weaponTubeDisallowMissle(1, "EMP")
--threat level: 4*1.4=5.6(dps)+8(tube)+(362.5)/20=18.125(shields)+2(hull) = 5.6+8+18.125+2=32.7
--Key features: frontal attack capability

--[[-----------------------Support/Station---------------]]
-- The weapons-platform is a stationary platform with beam-weapons. It's extremely slow to turn, but it's beam weapons do a huge amount of damage.
template = ShipTemplate():setName("Battlestation"):setClass("Kraylor", "Station"):setModel("space_station_4")
template:setDescription([[This stationary defense platform operates like a station, with docking and resupply functions, but is armed with powerful Kraylor rapid devastor beam weapons and can slowly rotate. Larger systems often use these platforms to resupply patrol ships.]])
template:setRadarTrace("radartrace_smallstation.png")
template:setHull(150)
template:setShields(120, 120, 120, 120, 120, 120)
--Reputation Score: 87
template:setSpeed(0, 0.5, 0)
template:setDockClasses("Starfighter", "Frigate", "Gunship", "Destroyer", "Striker")
--                  Arc, Dir, Range, CycleTime, Dmg
template:setBeam(0, 30,   0, 4000.0, 3.0, 10)
template:setBeam(1, 30,  60, 4000.0, 3.0, 10)
template:setBeam(2, 30, 120, 4000.0, 3.0, 10)
template:setBeam(3, 30, 180, 4000.0, 3.0, 10)
template:setBeam(4, 30, 240, 4000.0, 3.0, 10)
template:setBeam(5, 30, 300, 4000.0, 3.0, 10)
template:setRestocksMissilesDocked(true)
template:setSharesEnergyWithDocked(true)
template:setRepairDocked(true)
template:setRestocksScanProbes(true)
--threat level: 6*3.3=20(dps)+(120)/20=6(shields)+1.7(hull) = 20+6+1.7=27.7
--Key features: stationary. Maybe add a Homing tube as variant.

template = ShipTemplate():setName("Goddess of Destruction"):setClass("Kraylor", "Station"):setModel("space_station_2")
template:setRadarTrace("radartrace_largestation.png")
template:setDescription([[The Goddess of Destruction is a "ship" so large and unique that it's almost a class of its own.

The ship is often nicknamed the "all-mother", a name that aptly describes the many roles this ship can fulfill. It's both a supply station and an extremely heavily armored and shielded weapon station capable of annihilating small fleets on its own.

The Goddess' core contains the largest jump drive ever created. About 150 support crew are needed to operate the jump drive alone, and it takes 5 days of continuous operation to power it.

Due to the enormous cost of this station, only the richest star systems are able to build and maintain ships like the Goddess of Destruction. 

This machine's primary tactic is to jump into an unsuspecting enemy system and destroy everything before they know what hit them. It's effective and destructive, but extremely expensive.]])
template:setJumpDrive(true)
template:setTubes(16, 3.0)
template:setWeaponStorage("Homing", 1000)
for n=0,15 do
    template:setBeamWeapon(n, 90,  n * 22.5, 3200, 3, 10)
    template:setTubeDirection(n, n * 22.5)
    template:setTubeSize(n, "large")
end
template:setHull(2000)
template:setShields(1200, 1200, 1200, 1200, 1200, 1200)
--Reputation Score: 920
template:setSpeed(0, 1, 0)
template:setDockClasses("Starfighter", "Frigate", "Gunship", "Destroyer", "Striker")
template:setRestocksMissilesDocked(true)
template:setSharesEnergyWithDocked(true)
template:setRepairDocked(true)
template:setRestocksScanProbes(true)
--threat level: 15*3.3=49.5(dps)+32(tubes)+(1200)/20=60(shields)+20(hull) = 49.5+32+60+20=161.5!

