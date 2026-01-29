-- Arlenian ships

--[[

Description
-----------
This file defines some ships of a similar optical style with the background of the Arlenian culture.

Appearance
----------
The models from EsgaShipSet.pack are used here. Golden ornamental decorations and a curvy design are common, as well as rings around the engines. The color of their illumination is also used for the engine emissions and their beam texture. Custom radar traces were designed for them.

Strategic use in scenarios
--------------------------
Usually the peaceful Arlenians appear not as enemies of the players, but as important NPCs or questgivers. They might provide support against hostile factions or need help against attacking enemies. Discovering their stations might become important. In combat, the players should do the heavy lifting, but specialised Arlenian forces can come to help. Some Arlenian stations can be deployed as mobile structures.

Ship Properties
---------------
The following features were chosen for Arlenian ships, to make them distinguishable from other factions. They are primarily designed to support players or to need rescue from players, but not to directly fight against players. They have relatively very few ship designed primarily for combat.
  * Arlenians tend to use specialized ships for different purposes; some are completely unarmed.
  * Shielded ships tend to have strong shields but comparatively weak hulls, with hull strength generally below that of comparable ships from other factions.
  * Beams generally have narrow, forward-facing arcs, making them effective for fire support but relatively easy to outmaneuver.
  * Missile armament is limited to HVLIs and Homings. Small Homing missiles may be used for anti-fighter defense, while heavier missile armament is primarily intended against larger ships and stations. They have no weapons of mass destruction.
  * Arlenian ships generally have lower impulse performance than comparable ships of other factions and usually lack warp or jump drives. Some mobile stations may be exceptions.
  * Some Arlenian stations can be deployed as mobile vessels, allowing industrial, scientific, and logistical infrastructure to be relocated when necessary.

Naming Convention
-----------------
Humans named the Arlenian ship types after birds from earth. Other factions would probably call them by other words.

Ship Classes
------------
* Fighters: Widow, Matron, Goldfinch, Gentoo, Hoatzin
* Transports (mostly unarmed): Macaw, Spix, Pigeon, Grosbeak (armed)
* Escort: Woodpecker, Swallow, Linnet
* Cruisers: Pheasant, Grebe, Pochard, Crane
* Specialist: Towhee, Pelican, Kite, Heron
* Mobile station modules

Additional lore for Scenarios
---
Arlenians are an energy based lifeform, so their ships and research are focused on energy more than matter.
Arlenians are huge compared to humans, usually an Arlenian ship houses one Arlenian lifeform, who is captain as well as power source for that ship. The crew of the ships usually consists of different other species, humans being one of them. The ships interior is adjusted for the needs of the crew, except for the huge housing of the Arlenian itself. Communication with other ships is achieved by translators inside the crew, who interpret the will of the Arlenian captain and try to behave according to it.
--]]





-- Fighters / small transport craft

template = ShipTemplate():setName(_("Widow"))
-- widow: from cape widow, also called yellow bishop - a black bird with some gold
template:setClass("Arlenian", "Fighter")
template:setDescription(_("The Widow is a small and fragile craft, that is usually unarmed and used as one-person shuttle or to transport small items between ships. Unmanned Widows may be deployed by capital ships to distract enemy fighters for a short time."))
template:setModel("esga_bomber"):setRadarTrace("esga_bomber.png")
-- the model is also used for kraylor drones.
template:setHull(14)	-- defenseless against capital ships
-- no shields
-- engine config: 0 rings 
template:setSpeed(90, 15, 30)
-- no weapons
-- template:setBeam(0, 270, 0, 500.0, 4.0, 1.5):setBeamTexture(0, "texture/beam_arlenian.png")
template:setDefaultAI('fighter')
--var = template:copy(template:getName().."P"):setType("playership")

-- armed variant with a single homing
var = template:copy("Matron")
var:setDescription(_("The Matron is a small and fragile craft, but in contrast to the widow, it is not completely unarmed: the Matron carries a single small anti-fighter homing missile."))
var:setWeaponStorage("Homing", 1)
var:setTubes(1, 12.0)
var:setTubeSize(0, "small")
--var = var:copy(var:getName().."P"):setType("playership")


template = ShipTemplate():setName("Goldfinch")
-- goldfinch: from colors: red black white gold
template:setClass("Arlenian", "Fighter")
template:setDescription(_("The Goldfinch is the standard Arlenian starfighter. Small, somewhat fragile without shields, but still charming in small groups."))	-- TRANSLATERS : a flock of goldfinches is called a charm.
template:setModel("esga_fighter"):setRadarTrace("esga_fighter.png")
template:setHull(20)
-- no shields
-- engine config: 0 rings 
template:setSpeed(90, 15, 30)
template:setDefaultAI('fighter')
-- long range variation of the light tool beam
template:setBeam(0, 20, 0, 500.0, 3.0, 2.5):setBeamTexture(0, "texture/beam_arlenian.png")
--var = template:copy(template:getName().."P"):setType("playership")

template = ShipTemplate():setName("Gentoo")
-- gentoo penguins have a red beak
template:setClass("Arlenian", "Fighter")
template:setDescription(_("The Gentoo is a drop-pod with a powered front-drill. The engine only provides forward power, so this vehicle is less maneuverable than other fighters and can only move forwards. It is used to breach the hull of immobile targets."))
template:setModel("esga_droppod"):setRadarTrace("esga_droppod.png")
template:setHull(14)	-- defenseless against armed capital ships
-- no shields
-- engine config: 0 rings 
template:setSpeed(90, 10, 15, 1 ,5)	-- less maneuverable than other fighters, can only move forward
-- short range rapid fire variation of the light tool beam
template:setBeam(0, 30, 0, 100.0, 3.0, 2.5):setBeamTexture(0, "texture/beam_arlenian.png")
--var = template:copy(template:getName().."P"):setType("playership")
-- do not use currently; could also be an exuari craft

template = ShipTemplate():setName("Hoatzin")
-- hoatzin: bird with claws on its wings
template:setClass("Arlenian", "Fighter")
template:setDescription(_("The Hoatzin is a small shielded Arlenian craft that is used to collect samples in hazardous environments, like fragile asteroid tunnels. Although the beams are more a tool than a weapon, they can still break parts from the hull of enemy ships and disable their systems, provided that the Hoatzin gets the enemy in its claws."))
template:setModel("esga_construction_drone"):setRadarTrace("esga_construction_drone.png")
template:setHull(20)
template:setShields(30)
-- engine config: central: 1 ring 
template:setSpeed(90, 14, 20)
-- wide range variation of the light tool beam
template:setBeam(0, 60, 0, 300.0, 3.0, 2.5):setBeamTexture(0, "texture/beam_arlenian.png")
--var = template:copy(template:getName().."P"):setType("playership")


-- Unarmed transports; meant to be protected by players


template = ShipTemplate():setName("Macaw")
-- names of macaws that are named after naturalists or ornithologists, like spix.
template:setClass("Arlenian", "Transport")
template:setDescription(_("The Macaw class ships are unarmed Arlenian vessels, built for - what humans would call it - civilian purposes. They are seemingly defenseless and their moderate speed makes them a good target for raiders. However their shield generators are usually strong enough to protect them from ambushes until reinforcements arrive."))
template:setModel("esga_corvette_A"):setRadarTrace("esga_corvette_A.png")
template:setHull(75)
template:setShields(175)
-- engine config: central: 1 ring
template:setSpeed(55, 10, 10) -- slower than enemies attackers, faster than human defenders
--var = template:copy(template:getName().."P"):setType("playership")

var = template:copy("Spix")
var:setDescription(_("The Spix is a civilian transport of the Macaw class. It is unarmed and relies on its strong shields and moderate speed to survive until help arrives."))
var:setModel("esga_corvette_B"):setRadarTrace("esga_corvette_B.png")
var:setShields(200)
-- engine config: central: 1 ring
var:setSpeed(55, 10, 10)
--var = var:copy(var:getName().."P"):setType("playership")

-- heavy transport

template = ShipTemplate():setName("Pigeon")
-- pigeon: big white belly
template:setClass("Arlenian", "Transport")
template:setDescription(_("The Pigeon is a large Arlenian transport used for carrying passengers and bulky cargo. Its low speed makes it vulnerable to raiders, but its strong shields allow it to withstand attacks while waiting for assistance."))
template:setModel("esga_colony_vessel"):setRadarTrace("esga_colony_vessel.png")
template:setHull(150)
template:setShields(150)
-- engine config: central: 1 ring
template:setSpeed(28, 5, 2)
--var = template:copy(template:getName().."P"):setType("playership")

-- armed transport

template = ShipTemplate():setName("Grosbeak")
-- grosbeak: after the red breasted grosbeak
template:setClass("Arlenian", "Transport")
template:setDescription(_("The Grosbeak is a large Arlenian transport intended for carrying valuable cargo and equipment between stations and ships. It has a modest defensive armament and strong shields, allowing it to survive encounters with raiders while waiting for an escort."))
template:setModel("esga_transport"):setRadarTrace("esga_transport.png")
template:setHull(100)
template:setShields(175)
-- engine config: central: 1 ring
template:setSpeed(45, 8, 5) -- slower than enemies attackers, faster than human defenders
-- beam collides with hull when arc < 15°
template:setBeam(0, 30, 0, 1400, 5.0, 7):setBeamTexture(0, "texture/beam_arlenian.png")
template:setBeam(1, 30, 0, 1400, 5.1, 7):setBeamTexture(1, "texture/beam_arlenian.png")
template:setBeam(2, 30, 0, 1400, 5.2, 7):setBeamTexture(2, "texture/beam_arlenian.png")
template:setBeam(3, 30, 0, 1400, 5.3, 7):setBeamTexture(3, "texture/beam_arlenian.png")
--var = template:copy(template:getName().."P"):setType("playership")

-- combat-ready escort ships
-- faster than heavy ships or transport
-- amount of rings *100 = shields

template = ShipTemplate():setName("Woodpecker")
-- woodpecker
template:setClass("Arlenian", "Escort")
template:setDescription(_("The Woodpecker is a fast Arlenian escort ship designed to protect transports and other vulnerable vessels. Its multiple forward beams provide concentrated fire support, but their narrow arcs make the Woodpecker dependent on good positioning."))
template:setModel("esga_destroyer_A"):setRadarTrace("esga_destroyer_A.png")
template:setHull(100)
template:setShields(2*100)
-- engine config: central: 2 rings
template:setSpeed(42, 9, 8)
--                  Arc, Dir, Range, CycleTime, Dmg
template:setBeam(0, 30, 0, 1500, 7.0, 11):setBeamTexture(0, "texture/beam_arlenian.png")
template:setBeam(1, 30, 0, 1500, 7.1, 11):setBeamTexture(1, "texture/beam_arlenian.png")
-- beam collides with hull when arc < 7°
template:setBeam(2, 20, -7.5-10, 1500, 7.2, 11):setBeamTexture(2, "texture/beam_arlenian.png")
template:setBeam(3, 20,  17.5, 1500, 7.3, 11):setBeamTexture(3, "texture/beam_arlenian.png")
--var = template:copy(template:getName().."P"):setType("playership")

template = ShipTemplate():setName("Linnet")
-- linnet
template:setClass("Arlenian", "Escort")
template:setDescription(_("The Linnet is a heavily shielded escort designed to protect Arlenian vessels from attacks from the front. Its widely separated forward beams allow it to cover a broader area while still concentrating its fire on approaching enemies."))
template:setModel("esga_destroyer_C"):setRadarTrace("esga_destroyer_C.png")
template:setHull(100)
template:setShields(4*100)
-- engine config: central: 2 rings
template:setSpeed(42, 9, 8)
template:setBeam(0, 30, -14, 1500, 7.0, 11):setBeamTexture(0, "texture/beam_arlenian.png")
template:setBeam(1, 30,  14, 1500, 7.1, 11):setBeamTexture(1, "texture/beam_arlenian.png")
--var = template:copy(template:getName().."P"):setType("playership")

template = ShipTemplate():setName("Swallow")
-- swallow (the bird, not the verb)
template:setClass("Arlenian", "Escort")
template:setDescription(_("The Swallow is a versatile Arlenian escort ship with strong shields and several forward beams. It can accompany civilian vessels into dangerous areas and provide sustained fire support against hostile ships."))
template:setModel("esga_destroyer_B"):setRadarTrace("esga_destroyer_B.png")
template:setHull(120)
template:setShields(3*100)
-- engine config: central: 2 rings, but a bit heavier
template:setSpeed(40, 8, 6)
template:setBeam(0, 30, 0, 1400, 5.0, 7):setBeamTexture(0, "texture/beam_arlenian.png")
template:setBeam(1, 30, 0, 1400, 5.1, 7):setBeamTexture(1, "texture/beam_arlenian.png")
template:setBeam(2, 30, 0, 1400, 5.2, 7):setBeamTexture(2, "texture/beam_arlenian.png")
template:setBeam(3, 30, 0, 1400, 5.3, 7):setBeamTexture(3, "texture/beam_arlenian.png")
-- beam collides with hull when arc < 12°
template:setBeam(4, 20, -12.5-10, 1500, 7.0, 11):setBeamTexture(4, "texture/beam_arlenian.png")
template:setBeam(5, 20,  22.5, 1500, 7.1, 11):setBeamTexture(5, "texture/beam_arlenian.png")
--var = template:copy(template:getName().."P"):setType("playership")

-- cruisers: slower than heavy ships
-- rings * 75 = shields

template = ShipTemplate():setName("Pheasant")
template:setClass("Arlenian", "Cruiser")
template:setDescription(_("The Pheasant is a medium-sized Arlenian cruiser that provides fire support for civilian vessels and smaller escorts. Its broad forward beams can deliver sustained damage, while its strong shields allow it to remain near the front of an engagement."))
template:setModel("esga_cruiser_A"):setRadarTrace("esga_cruiser_A.png")
template:setHull(150)
template:setShields(7*75)
-- engine config: central: 2 rings, side: 1 ring
template:setSpeed(27, 5, 2.7)
template:setBeam(0, 40, 0, 1400, 5.0, 7):setBeamTexture(0, "texture/beam_arlenian.png")
template:setBeam(1, 40, 0, 1400, 5.1, 7):setBeamTexture(1, "texture/beam_arlenian.png")
template:setBeam(2, 40, 0, 1400, 5.2, 7):setBeamTexture(2, "texture/beam_arlenian.png")
template:setBeam(3, 40, 0, 1400, 5.3, 7):setBeamTexture(3, "texture/beam_arlenian.png")
--var = template:copy(template:getName().."P"):setType("playership")

template = ShipTemplate():setName("Pochard")
template:setClass("Arlenian", "Cruiser")
template:setDescription(_("The Pochard is a versatile Arlenian missile cruiser. It carries both heavy volley launchers and homing missiles, allowing it to engage a variety of targets while its forward beams provide additional fire support."))
template:setModel("esga_cruiser_C"):setRadarTrace("esga_cruiser_C.png")
template:setHull(150)
template:setShields(6*75)
-- engine config: central: 2 rings; side: 1 ring
template:setSpeed(27, 5, 2.7)
template:setBeam(0, 40, 0, 1400, 5.0, 7):setBeamTexture(0, "texture/beam_arlenian.png")
template:setBeam(1, 40, 0, 1400, 5.1, 7):setBeamTexture(1, "texture/beam_arlenian.png")
template:setWeaponStorage("HVLI", 12)
template:setWeaponStorage("Homing", 12)
template:setTubes(3, 12.0)
template:setWeaponTubeExclusiveFor(0, "HVLI"):setTubeSize(0, "medium")
template:setWeaponTubeExclusiveFor(1, "Homing"):setTubeSize(1, "medium"):setTubeDirection(1,-45)
template:setWeaponTubeExclusiveFor(2, "Homing"):setTubeSize(2, "medium"):setTubeDirection(2,45)
--var = template:copy(template:getName().."P"):setType("playership")

template = ShipTemplate():setName("Crane")
template:setDescription(_("The Crane is a specialized Arlenian cruiser built around powerful forward beams. It has fewer weapons than some other cruisers, but its concentrated fire makes it effective at supporting other ships against approaching enemies."))
template:setClass("Arlenian", "Cruiser")
template:setModel("esga_cruiser_D"):setRadarTrace("esga_cruiser_D.png")
template:setHull(150)
template:setShields(5*75)
-- engine config: central: 2 rings; side: 1 ring
template:setSpeed(27, 5, 2.7)
template:setBeam(0, 40, -5, 1500, 7.0, 11):setBeamTexture(0, "texture/beam_arlenian.png")
template:setBeam(1, 40,  5, 1500, 7.1, 11):setBeamTexture(1, "texture/beam_arlenian.png")
--var = template:copy(template:getName().."P"):setType("playership")

template = ShipTemplate():setName("Grebe")
template:setClass("Arlenian", "Cruiser")
template:setDescription(_("The Grebe is an Arlenian cruiser equipped with heavy volley launchers for attacking larger or more durable targets. It combines moderate speed and strong shields with limited missile firepower, making it useful against raider installments and enemy capital ships."))
template:setModel("esga_cruiser_B"):setRadarTrace("esga_cruiser_B.png")
template:setHull(150)
template:setShields(6*75)
-- engine config: central: 3 rings 
template:setSpeed(27, 4, 3)	-- different configuration of drive rings - faster accel, slower turn
template:setBeam(0, 40, 0, 1400, 5.0, 7):setBeamTexture(0, "texture/beam_arlenian.png")
template:setBeam(1, 40, 0, 1400, 5.1, 7):setBeamTexture(1, "texture/beam_arlenian.png")
template:setWeaponStorage("HVLI", 12)
template:setTubes(1, 12.0)
template:setTubeSize(0, "medium")
--var = template:copy(template:getName().."P"):setType("playership")

-- Specialists

template = ShipTemplate():setName("Towhee")
-- eastern towhee: red accent on white belly and black hat
template:setClass("Arlenian", "Specialist")
template:setDescription(_("The Towhee is an Arlenian science vessel equipped with a large array of short-range beams. Although built primarily for scientific work, these beams can be used for defense when the ship is operating in dangerous territory."))
template:setModel("esga_science_ship"):setRadarTrace("esga_science_ship.png")
template:setHull(85)
template:setShields(175)
-- engine config: central: 1 ring
template:setSpeed(50, 8, 5)
template:setBeam(0, 30, 0, 500, 3.0, 3.5):setBeamTexture(0, "texture/beam_arlenian.png")
template:setBeam(1, 30, 0, 500, 3.1, 3.5):setBeamTexture(1, "texture/beam_arlenian.png")
template:setBeam(2, 30, 0, 500, 3.2, 3.5):setBeamTexture(2, "texture/beam_arlenian.png")
template:setBeam(3, 30, 0, 500, 3.3, 3.5):setBeamTexture(3, "texture/beam_arlenian.png")
template:setBeam(4, 30, 0, 500, 3.4, 3.5):setBeamTexture(4, "texture/beam_arlenian.png")
template:setBeam(5, 30, 0, 500, 3.5, 3.5):setBeamTexture(5, "texture/beam_arlenian.png")
--var = template:copy(template:getName().."P"):setType("playership")

template = ShipTemplate():setName("Pelican")
-- pelican: for the big mouth	
template:setClass("Arlenian", "Specialist")
template:setDescription(_("The Pelican is an Arlenian construction vessel used to build, repair, and modify structures in space. Its broad front section and multiple beams are primarily intended for industrial work, but they can also provide protection against nearby threats."))
template:setHull(85)
template:setShields(200)
-- engine config: central: 1 ring
template:setSpeed(50, 8, 5)
template:setModel("esga_construction_ship"):setRadarTrace("esga_construction_ship.png")
template:setBeam(0, 25, 0, 500, 3.0, 3.5):setBeamTexture(0, "texture/beam_arlenian.png")
template:setBeam(1, 25, 0, 500, 3.1, 3.5):setBeamTexture(1, "texture/beam_arlenian.png")
template:setBeam(2, 25, 0, 500, 3.2, 3.5):setBeamTexture(2, "texture/beam_arlenian.png")
template:setBeam(3, 25, 0, 500, 3.3, 3.5):setBeamTexture(3, "texture/beam_arlenian.png")
--var = template:copy(template:getName().."P"):setType("playership")


template = ShipTemplate():setName("Kite")
-- kite: after the red kite
template:setClass("Arlenian", "Specialist")
template:setDescription(_("The Kite is a large Arlenian carrier designed to deploy and support smaller craft. Its strong shields and multiple forward beams allow it to protect its complement while remaining behind the main line of combat."))
template:setModel("esga_juggernaut_carrier"):setRadarTrace("esga_juggernaut_carrier.png")
template:setHull(300)
template:setShields(500)
-- engine config: central: 3 * 2 rings; side 1 ring
template:setSpeed(35, 4, 2)
-- wide beams as an exception to the arlenian style
template:setBeam(0, 60, 0, 1500, 7.0, 11):setBeamTexture(0, "texture/beam_arlenian.png")
template:setBeam(1, 60, 0, 1500, 7.1, 11):setBeamTexture(1, "texture/beam_arlenian.png")
template:setBeam(2, 60, 0, 1500, 7.0, 11):setBeamTexture(2, "texture/beam_arlenian.png")
template:setBeam(3, 60, 0, 1500, 7.1, 11):setBeamTexture(3, "texture/beam_arlenian.png")
--var = template:copy(template:getName().."P"):setType("playership")

template = ShipTemplate():setName("Heron")
-- heron: after the long neck
template:setClass("Arlenian", "Specialist")
template:setDescription(_("The Heron is a heavily built Arlenian artillery vessel designed to attack large and distant targets. It carries a substantial supply of heavy volley launchers, but its extremely low speed makes it dependent on other ships for protection and positioning."))
template:setModel("esga_titan_artillery"):setRadarTrace("esga_titan_artillery.png")
template:setHull(200)
template:setShields(400)
-- engine config: central: 3 rings; side 1 ring
template:setSpeed(3, 1, 0.1)
template:setWeaponStorage("HVLI", 25)
template:setTubes(1, 24.0)
template:setTubeSize(0, "large")
--var = template:copy(template:getName().."P"):setType("playership")

-- stations		 
template = ShipTemplate():setName("Arlenian Citadel"):setType("station")
template:setModel("esga_station_citadel"):setRadarTrace("esga_station_citadel.png")
template:setHull(500)
template:setShields(1000)

template = ShipTemplate():setName("Arlenian Motherstation"):setType("station")
template:setModel("esga_station_habitat"):setRadarTrace("esga_station_habitat.png")
template:setHull(500)
template:setShields(1000)

template = ShipTemplate():setName("Arlenian Starbase"):setType("station")
template:setModel("esga_station_starbase"):setRadarTrace("esga_station_starbase.png")
template:setHull(300)
template:setShields(600)

template = ShipTemplate():setName("Arlenian Shipyard"):setType("station")
template:setModel("esga_station_assemblyyard"):setRadarTrace("esga_station_assemblyyard.png")
template:setHull(150)
template:setShields(300)
var = template:copy(template:getName().." - mobile"):setType("cpuship")
var:setClass("Arlenian", "Station")
var:setSpeed(50, 8, 5) -- test, maybe add warp?
-- has beams
var:setBeam(0, 30, 0, 500, 3.0, 3.5):setBeamTexture(0, "texture/beam_arlenian.png")
var:setBeam(1, 30, 0, 500, 3.1, 3.5):setBeamTexture(1, "texture/beam_arlenian.png")
var:setBeam(2, 30, 0, 500, 3.2, 3.5):setBeamTexture(2, "texture/beam_arlenian.png")

template = ShipTemplate():setName("Arlenian Habitat"):setType("station")
template:setModel("esga_station_habitation"):setRadarTrace("esga_station_habitation.png")
template:setHull(200)
-- no shields
var = template:copy(template:getName().." - mobile"):setType("cpuship")
var:setClass("Arlenian", "Station")
var:setSpeed(50, 8, 5) -- test, maybe add warp?

template = ShipTemplate():setName("Arlenian Hangar"):setType("station")
template:setModel("esga_station_hangar"):setRadarTrace("esga_station_hangar.png")
template:setHull(150)
template:setShields(300)
var = template:copy(template:getName().." - mobile"):setType("cpuship")
var:setClass("Arlenian", "Station")
var:setSpeed(50, 8, 5) -- test, maybe add warp?

template = ShipTemplate():setName("Arlenian Mining Station"):setType("station")
template:setModel("esga_station_mining"):setRadarTrace("esga_station_mining.png")
template:setHull(200)
-- no shields
var = template:copy(template:getName().." - mobile"):setType("cpuship")
var:setClass("Arlenian", "Station")
var:setSpeed(50, 8, 5) -- test, maybe add warp?
-- has beams
var:setBeam(0, 30, 0, 500, 3.0, 3.5):setBeamTexture(0, "texture/beam_arlenian.png")
var:setBeam(1, 30, 0, 500, 3.1, 3.5):setBeamTexture(1, "texture/beam_arlenian.png")

template = ShipTemplate():setName("Arlenian Science Station"):setType("station")
template:setModel("esga_station_science"):setRadarTrace("esga_station_science.png")
template:setHull(150)
template:setShields(300)
var = template:copy(template:getName().." - mobile"):setType("cpuship")
var:setClass("Arlenian", "Station")
var:setSpeed(50, 8, 5) -- test, maybe add warp?
-- has beams
var:setBeam(0, 30, 0, 500, 3.0, 3.5):setBeamTexture(0, "texture/beam_arlenian.png")
var:setBeam(1, 30, 0, 500, 3.1, 3.5):setBeamTexture(1, "texture/beam_arlenian.png")


--[[
Equipment Overview
------------------
The following values are commonly used for Arlenian ships.
They serve as reference values when designing new ships;
specialized vessels may deviate from these values to fit their role.

Hull:
* Fighters:
	14: Widow, Matron, Gentoo
	20: Goldfinch, Hoatzin
* Transports / light Specialists / light Escort:
	75: Macaw, Spix, Grosbeak
	85: Towhee, Pelican
	100: Pigeon, Woodpecker, Linnet
	120: Swallow
* Cruisers / heavy Specialists / heavy Escort:
	150: Pheasant, Grebe, Pochard, Crane
	200: Heron
	300: Kite

Shields:
* Fighters:
	0:   Widow, Matron, Goldfinch, Gentoo
	30:  Hoatzin
* Transports / light Specialists / light Escort:
	150: Pigeon, Pheasant
	175: Macaw, Towhee, Grosbeak
	200: Spix, Woodpecker, Pelican
	300: Swallow
* Cruisers / heavy Specialists / heavy Escort:
	375: Crane
	400: Linnet, Heron
	450: Grebe, Pochard
	500: Kite

Beams:
Which one of the two standard beams is used, depends on what the model shows.

-- Arlenian Light Beam (the default - mostly cruiser)
-- Arc: ~30°
-- Direction: 0°
-- Range: 1400
-- Cycle: 5+ s
-- Damage: 7
-- DPS: 1.40
-- used by (amount): Pheasant(4), Grebe(2), Pochard(2), Swallow(4+), Grosbeak(4)

-- Arlenian Heavy Beam (mostly escort)
-- Arc: ~30°
-- Direction: 0°
-- Range: 1500
-- Cycle: 7 s
-- Damage: 11
-- DPS: 1.57
-- used by (amount): Woodpecker(4), Linnet(2), Swallow(2+), Crane(2), Kite(4)

-- Arlenian Tool Beam (specialists, stations)
-- Arc:       30°
-- Direction: 0°
-- Range:     500
-- Cycle:     3 s
-- Damage:    3.5
-- DPS:       1.17
-- used by (amount): Towhee, Pelican 

-- Arlenian Light Tool Beam (fighters)
-- Arc:       30°
-- Direction: 0°
-- Range:     300
-- Cycle:     3 s
-- Damage:    2.5
-- DPS:       0.83
-- used by (amount): Goldfinch, Gentoo, Hoatzin

Note: Some ships have multiple beams with slightly different cycle times or directions. The values above describe the common beam configurations rather than every individual beam slot.

Arlenian Drives are sorted mostly by class.
As a rule of thumb, the number of drive rings in relation to the ships size is relevant.

--]]
