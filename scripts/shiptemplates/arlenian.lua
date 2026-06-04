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
Usually the peaceful Arlenians appear not as enemies of the players, but as important NPCs or questgivers. They might provide support against hostile factions or need help to defend themselfs from them. Discovering their stations might become important. In combat, the players should do the heavy lifting, but specialised Arlenian forces can come to help.

Ship Properties
---------------
The following features were chosen for Arlenian ships, to make them distinguishable from other factions. They are primarily designed to support players or to need rescue from players, but not to directly fight against players.
  * Arlenians tend to use specialised ships for different purposes, some of them come completely unarmed.
  * Hull is weaker than shields, also weaker than most other factions.
  * Shields are strong, but with only one shield segment. (Enemy ai can not leverage weak shield segments.)
  * Beams have narrow arcs - good as fire support but easy to outmaneuver. Arlenians only use front facing beams.
  * Missiles: some heavy HVLIs against enemy stations or capital ships, few homing. No missiles of mass destruction. Maybe EMPs.
  * Impulse is slower than enemy factions. Usually no warp or jump drives.

Naming Convention
-----------------
Humans named the Arlenian ship types after birds from earth. Other factions would probably call them by other words.

Ship Classes
------------
* Fighters:
	* Arlenian Needle: long narrow beam arc
	* Arlenian Drill: very short beam, must almost touch enemy
* Freighters:
	* Corvettes, transport, ... mostly unarmed ships.
* Frigates:
	* destroyers and cruisers - specialisef
* Carriers...


--]]


--[[
TODO
Component details used for designing the ships above:
 Beams
  Arlenian narrow beam: rng 1000+, cycle 4, dmg 4, dps 1
  Arlenian drill beam: rng 500-, cycle 6, dmg 6, dps 1.33
  Arlenian heavy beam: rng 1200+, cycle 3/6/9, dmg 2/4/6, dps 2
 Hull/shields	golden elements outside generate shields - ships without wont get shields
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


-- Fighters / small transport craft

template = ShipTemplate():setName(_("Widow"))
-- widow: from cape widow, also called yellow bishop - a black bird with some gold
template:setClass("Arlenian", "Fighter")
template:setDescription(_("The Widow is a small and fragile craft, that is usually unarmed and used as one-person shuttle or to transport small items between ships. Unmanned Widows may be deployed by capital ships to distract enemy fighters for a short time."))
template:setModel("esga_bomber"):setRadarTrace("esga_bomber.png")
-- the model is also used for kraylor drones.
template:setHull(14)	-- defenseless against capital ships
-- no shields
template:setSpeed(90, 15, 30)
-- no weapons
-- template:setBeam(0, 270, 0, 500.0, 4.0, 1.5):setBeamTexture(0, "texture/beam_arlenian.png")
template:setDefaultAI('fighter')
var = template:copy(template:getName().."P"):setType("playership")

-- armed variant with a single homing
var = template:copy("Matron")
var:setDescription(_("The Matron is a small and fragile craft, but in contrast to the widow, it is not completely unarmed: the Matron carries a single small anti-fighter homing missile."))
var:setWeaponStorage("Homing", 1)
var:setTubes(1, 12.0)
var:setTubeSize(0, "small")
var = var:copy(var:getName().."P"):setType("playership")


template = ShipTemplate():setName("Goldfinch")
-- goldfinch: from colors: red black white gold
template:setClass("Arlenian", "Fighter")
template:setDescription(_("The Goldfinch is the standard Arlenian starfighter. Small, somewhat fragile without shields, but still charming in small groups."))	-- translation note: a flock of goldfinches is called a charm.
template:setModel("esga_fighter"):setRadarTrace("esga_fighter.png")
template:setHull(20)
-- no shields
template:setSpeed(90, 15, 30)
template:setDefaultAI('fighter')
--                  Arc, Dir, Range, CycleTime, Dmg
template:setBeam(0, 20, 0, 600.0, 4.0, 3):setBeamTexture(0, "texture/beam_arlenian.png")
var = template:copy(template:getName().."P"):setType("playership")

template = ShipTemplate():setName("Gentoo")
-- gentoo penguins have a red beak
template:setClass("Arlenian", "Fighter")
template:setDescription(_("The Gentoo is a drop-pod with a powered front-drill. The engine only provides forward power, so this vehicle is less maneuverable than other fighters and can only move forwards. It is used to breach the hull of immobile targets."))
template:setModel("esga_droppod"):setRadarTrace("esga_droppod.png")
template:setHull(14)	-- defenseless ageinst armed capital ships
-- no shields
template:setSpeed(90, 10, 15, 1 ,5)	-- less maneuverable than other fighters, can only move forward
template:setBeam(0, 30, 0, 100.0, 1.0, 1.1):setBeamTexture(0, "texture/beam_arlenian.png")
var = template:copy(template:getName().."P"):setType("playership")
-- do not use currently; could also be an exuari craft

template = ShipTemplate():setName("Hoatzin")
-- hoatzin: bird with claws on its wings
template:setClass("Arlenian", "Fighter")
template:setDescription(_("The Hoatzin is a small shielded Arlenian craft that is used to collect samples in hazardous environments, like fragile asteroid tunnels. Although the beams are more a tool than a weapon, they can still break parts from the hull of enemy ships and disable their systems, provided that the Hoatzin gets the enemy in its claws."))
template:setModel("esga_construction_drone"):setRadarTrace("esga_construction_drone.png")
template:setHull(20)
template:setShields(30)
template:setSpeed(90, 14, 20)
template:setBeam(0, 60, 0, 250.0, 1.0, 1.1):setBeamTexture(0, "texture/beam_arlenian.png")
var = template:copy(template:getName().."P"):setType("playership")


-- Unarmed transports; ment to be protected by players


template = ShipTemplate():setName("Macaw")
-- spix, coulon, illiger: names of macaws that are named after naturalists or ornithologists.
template:setClass("Arlenian", "Frigate")
template:setDescription(_("The Macaw class ships, with their Spix, Coulon and Illinger subclasses are unarmed Arlenian vessels, build for - what humans would call it - civilian purposes. They are seemingly defenseless and their moderate speed makes them a good target for raiders. However their shield generators are usually strong enough to protect them from ambushes until reinforcements arrive."))
template:setModel("esga_corvette_A"):setRadarTrace("esga_corvette_A.png")
template:setHull(75)
template:setShields(175)
template:setSpeed(55, 10, 10) -- slower than enemies attackers, faster than human defenders
var = template:copy(template:getName().."P"):setType("playership")

var = template:copy("Spix")
var:setModel("esga_corvette_B"):setRadarTrace("esga_corvette_B.png")
var:setShields(200)
var:setSpeed(56, 9, 10)
var = var:copy(var:getName().."P"):setType("playership")

template = ShipTemplate():setName("Pidgeon")
-- pidgeon: big white belly
template:setModel("esga_colony_vessel"):setRadarTrace("esga_colony_vessel.png")
template:setHull(100)
template:setShields(150)
template:setSpeed(28, 5, 2)

var = template:copy(template:getName().."P"):setType("playership")

-- combat-ready ships
-- destroyers: faster than heavy ships
-- amount of rings *100 = shields

template = ShipTemplate():setName("Woodpecker")
-- woodpecker
template:setModel("esga_destroyer_A"):setRadarTrace("esga_destroyer_A.png")
template:setHull(100)
template:setShields(2*100)
template:setSpeed(42, 9, 7)
--                  Arc, Dir, Range, CycleTime, Dmg
template:setBeam(0, 30, 0, 1500, 7.0, 10):setBeamTexture(0, "texture/beam_arlenian.png")
template:setBeam(1, 30, 0, 1500, 7.1, 10):setBeamTexture(1, "texture/beam_arlenian.png")
-- beam collides with hull when arc < 7°
template:setBeam(2, 20, -7.5-10, 1500, 7.2, 10):setBeamTexture(2, "texture/beam_arlenian.png")
template:setBeam(3, 20,  17.5, 1500, 7.3, 10):setBeamTexture(3, "texture/beam_arlenian.png")
var = template:copy(template:getName().."P"):setType("playership")

template = ShipTemplate():setName("Swallow")
-- swallow (the bird, not the verb)
template:setModel("esga_destroyer_B"):setRadarTrace("esga_destroyer_B.png")
template:setHull(120)
template:setShields(3*100)
template:setSpeed(42, 8, 6)
template:setBeam(0, 30, 0, 1400, 5.0, 7):setBeamTexture(0, "texture/beam_arlenian.png")
template:setBeam(1, 30, 0, 1400, 5.1, 7):setBeamTexture(1, "texture/beam_arlenian.png")
template:setBeam(2, 30, 0, 1400, 5.2, 7):setBeamTexture(2, "texture/beam_arlenian.png")
template:setBeam(3, 30, 0, 1400, 5.3, 7):setBeamTexture(3, "texture/beam_arlenian.png")
-- beam collides with hull when arc < 12°
template:setBeam(4, 20, -12.5-10, 1500, 7.0, 10):setBeamTexture(4, "texture/beam_arlenian.png")
template:setBeam(5, 20,  22.5, 1500, 7.1, 10):setBeamTexture(5, "texture/beam_arlenian.png")
var = template:copy(template:getName().."P"):setType("playership")

template = ShipTemplate():setName("Linnet")
-- linnet
template:setModel("esga_destroyer_C"):setRadarTrace("esga_destroyer_C.png")
template:setHull(100)
template:setShields(4*100)
template:setSpeed(42, 9, 8)
template:setBeam(0, 30, -14, 1500, 7.0, 10):setBeamTexture(0, "texture/beam_arlenian.png")
template:setBeam(1, 30,  14, 1500, 7.1, 10):setBeamTexture(1, "texture/beam_arlenian.png")
var = template:copy(template:getName().."P"):setType("playership")

-- cruisers: slower than heavy ships
-- rings * 75 = shields

template = ShipTemplate():setName("Pheasant")
-- pheasant
template:setModel("esga_cruiser_A"):setRadarTrace("esga_cruiser_A.png")
template:setHull(150)
template:setShields(7*75)
template:setSpeed(27, 5, 2.7)
template:setBeam(0, 40, 0, 1400, 5.0, 7):setBeamTexture(0, "texture/beam_arlenian.png")
template:setBeam(1, 40, 0, 1400, 5.1, 7):setBeamTexture(1, "texture/beam_arlenian.png")
template:setBeam(2, 40, 0, 1400, 5.2, 7):setBeamTexture(2, "texture/beam_arlenian.png")
template:setBeam(3, 40, 0, 1400, 5.3, 7):setBeamTexture(3, "texture/beam_arlenian.png")
template:setDockClasses("Shuttle", "Starfighter", "Freighter", "Cruiser")	-- all player ship may dock on each other
var = template:copy(template:getName().."P"):setType("playership")

template = ShipTemplate():setName("Grebe")
-- grebe
template:setModel("esga_cruiser_B"):setRadarTrace("esga_cruiser_B.png")
template:setHull(150)
template:setShields(6*75)
template:setSpeed(27, 4, 3)	-- different configuration of drive rings
template:setBeam(0, 40, 0, 1400, 5.0, 7):setBeamTexture(0, "texture/beam_arlenian.png")
template:setBeam(1, 40, 0, 1400, 5.1, 7):setBeamTexture(1, "texture/beam_arlenian.png")
template:setWeaponStorage("HVLI", 12)
template:setTubes(1, 12.0)
template:setTubeSize(0, "medium")
var = template:copy(template:getName().."P"):setType("playership")

template = ShipTemplate():setName("Pochard")
-- pochard
template:setModel("esga_cruiser_C"):setRadarTrace("esga_cruiser_C.png")
template:setHull(150)
template:setShields(6*75)
template:setSpeed(27, 5, 2.7)
template:setBeam(0, 40, 0, 1400, 5.0, 7):setBeamTexture(0, "texture/beam_arlenian.png")
template:setBeam(1, 40, 0, 1400, 5.1, 7):setBeamTexture(1, "texture/beam_arlenian.png")
template:setWeaponStorage("HVLI", 12)
template:setWeaponStorage("Homing", 12)
template:setTubes(3, 12.0)
template:setWeaponTubeExclusiveFor(0, "HVLI"):setTubeSize(0, "medium")
template:setWeaponTubeExclusiveFor(1, "Homing"):setTubeSize(1, "medium"):setTubeDirection(1,-45)
template:setWeaponTubeExclusiveFor(2, "Homing"):setTubeSize(2, "medium"):setTubeDirection(2,45)
var = template:copy(template:getName().."P"):setType("playership")

template = ShipTemplate():setName("Crane")
-- crane	
template:setModel("esga_cruiser_D"):setRadarTrace("esga_cruiser_D.png")
template:setHull(150)
template:setShields(5*75)
template:setSpeed(27, 5, 2.7)
template:setBeam(0, 40, -5, 1500, 7.0, 10):setBeamTexture(0, "texture/beam_arlenian.png")
template:setBeam(1, 40,  5, 1500, 7.1, 10):setBeamTexture(1, "texture/beam_arlenian.png")
var = template:copy(template:getName().."P"):setType("playership")

-- special ships

template = ShipTemplate():setName("Towhee")
-- eastern towhee: red accent on while belly and black hat
template:setModel("esga_science_ship"):setRadarTrace("esga_science_ship.png")
template:setHull(85)
template:setShields(175)
template:setSpeed(50, 8, 5)
template:setBeam(0, 30, 0, 400, 4.0, 6):setBeamTexture(0, "texture/beam_arlenian.png")
template:setBeam(1, 30, 0, 400, 4.1, 6):setBeamTexture(1, "texture/beam_arlenian.png")
template:setBeam(2, 30, 0, 400, 4.2, 6):setBeamTexture(2, "texture/beam_arlenian.png")
template:setBeam(3, 30, 0, 400, 4.3, 6):setBeamTexture(3, "texture/beam_arlenian.png")
template:setBeam(4, 30, 0, 400, 4.4, 6):setBeamTexture(4, "texture/beam_arlenian.png")
template:setBeam(5, 30, 0, 400, 4.5, 6):setBeamTexture(5, "texture/beam_arlenian.png")
var = template:copy(template:getName().."P"):setType("playership")

template = ShipTemplate():setName("Pelican")
-- pelican: for the big mouth	
template:setHull(85)
template:setShields(200)
template:setSpeed(50, 8, 5)
template:setModel("esga_construction_ship"):setRadarTrace("esga_construction_ship.png")
template:setBeam(0, 25, 0, 1000, 5.0, 6):setBeamTexture(0, "texture/beam_arlenian.png")
template:setBeam(1, 25, 0, 1000, 5.1, 6):setBeamTexture(1, "texture/beam_arlenian.png")
template:setBeam(2, 25, 0, 1000, 5.2, 6):setBeamTexture(2, "texture/beam_arlenian.png")
template:setBeam(3, 25, 0, 1000, 5.3, 6):setBeamTexture(3, "texture/beam_arlenian.png")
var = template:copy(template:getName().."P"):setType("playership")

template = ShipTemplate():setName("Grosbeak")
-- grosbeak: after the red breased grosbeak
template:setModel("esga_transport"):setRadarTrace("esga_transport.png")
template:setHull(75)
template:setShields(175)
template:setSpeed(53, 8.5, 5.3) -- slower than enemies attackers, faster than human defenders
-- beam collides with hull when arc < 15°
template:setBeam(0, 30, 0, 1200, 5.0, 6):setBeamTexture(0, "texture/beam_arlenian.png")
template:setBeam(1, 30, 0, 1200, 5.1, 6):setBeamTexture(1, "texture/beam_arlenian.png")
template:setBeam(2, 30, 0, 1200, 5.2, 6):setBeamTexture(2, "texture/beam_arlenian.png")
template:setBeam(3, 30, 0, 1200, 5.3, 6):setBeamTexture(3, "texture/beam_arlenian.png")
var = template:copy(template:getName().."P"):setType("playership")

template = ShipTemplate():setName("Kite")
-- kite: after the red kite
template:setModel("esga_juggernaut_carrier"):setRadarTrace("esga_juggernaut_carrier.png")
template:setHull(300)
template:setShields(500)
template:setSpeed(35, 4, 2)
template:setBeam(0, 60, 0, 1500, 7.0, 10):setBeamTexture(0, "texture/beam_arlenian.png")
template:setBeam(1, 60, 0, 1500, 7.1, 10):setBeamTexture(1, "texture/beam_arlenian.png")
template:setBeam(2, 60, 0, 1500, 7.0, 10):setBeamTexture(2, "texture/beam_arlenian.png")
template:setBeam(3, 60, 0, 1500, 7.1, 10):setBeamTexture(3, "texture/beam_arlenian.png")
var = template:copy(template:getName().."P"):setType("playership")

template = ShipTemplate():setName("Heron")
-- heron: after the long neck
template:setModel("esga_titan_artillery"):setRadarTrace("esga_titan_artillery.png")
template:setHull(200)
template:setShields(400)
template:setSpeed(3, 1, 0.1)
template:setWeaponStorage("HVLI", 25)
template:setTubes(1, 24.0)
template:setTubeSize(0, "large")
var = template:copy(template:getName().."P"):setType("playership")

---- stations		 
--template = ShipTemplate():setName("Arlenian Station 0"):setType("station")
--template:setModel("esga_station_citadel"):setRadarTrace("esga_station_citadel.png")
--template:setHull(500)
--template:setShields(1000)
--
--template = ShipTemplate():setName("Arlenian Station 1"):setType("station")
--template:setModel("esga_station_habitat"):setRadarTrace("esga_station_habitat.png")
--template:setHull(500)
--template:setShields(1000)
--
--template = ShipTemplate():setName("Arlenian Station 2"):setType("station")
--template:setModel("esga_station_starbase"):setRadarTrace("esga_station_starbase.png")
--template:setHull(300)
--template:setShields(600)
--
--template = ShipTemplate():setName("Arlenian Station 3"):setType("station")
--template:setModel("esga_station_assemblyyard"):setRadarTrace("esga_station_assemblyyard.png")
--template:setHull(150)
--template:setShields(300)
---- has beams
--
--template = ShipTemplate():setName("Arlenian Station 4"):setType("station")
--template:setModel("esga_station_habitation"):setRadarTrace("esga_station_habitation.png")
--template:setHull(200)
---- no shields
--
--template = ShipTemplate():setName("Arlenian Station 5"):setType("station")
--template:setModel("esga_station_hangar"):setRadarTrace("esga_station_hangar.png")
--template:setHull(150)
--template:setShields(300)
--
--template = ShipTemplate():setName("Arlenian Station 6"):setType("station")
--template:setModel("esga_station_mining"):setRadarTrace("esga_station_mining.png")
--template:setHull(200)
---- no shields
---- has beams
--
--template = ShipTemplate():setName("Arlenian Station 7"):setType("station")
--template:setModel("esga_station_science"):setRadarTrace("esga_station_science.png")
--template:setHull(150)
--template:setShields(300)
---- has beams

