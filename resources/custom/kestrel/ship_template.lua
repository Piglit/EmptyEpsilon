--[[

Kestrel for SpaceLAN

- less HP than Phobos, same shields
- faster than most basic ships and faster maneuverability
- can jump (because that's what you do in FTL!), but halved range
- increased short-range radar (because... falcon eyes :P)
- 2 overcharged beam weapons: ~x2 damage and improved range, BUT: tighter cone, x2 charge time, high heat generation, high energy consumption
- 3 tubes:
  - #0: Flak (HVLI) only, MEDIUM (normal damage)
  - #1: missiles only, SMALL (1/2 damage, but x2 speed)
  - #2: Mine layer, MEDIUM
- only 2 repair crew instead of standard 3
- low missile storage space


Upgrade ideas:
- additional weapon storage (see commented out lines)
- better shields (in FTL you start with only basic shields)
- better hull
- improved jump drive (later on?)
- longer beam range+damage
- short range radar? :P

]]--

template = ShipTemplate():setName("Kestrel"):setLocaleName(_("playerShip", "Kestrel")):setClass(_("class", "Frigate"), _("subclass", "Light Cruiser")):setModel("kestrel"):setType("playership")
template:setDescription(_([[The Kestrel is a fast Light Cruiser. Speed is the main attribute here, while hull and shields are rather low. Its armaments consist of small missiles, which are weaker but travel faster, normal HVLIs, and a pair of burst lasers, outputting high damage at the cost of vastly increased energy consumption, heat production and charge times.]]))
template:setRadarTrace("../custom/kestrel/radar_kestrel.png")

template:setHull(120) -- like specialist frigates, not like corvettes
template:setShields(70, 70) -- like specialist frigates, not like the tanky light cruiser
template:setSpeed(100, 15, 25)	-- more like scout, but not like a fighter
template:setCombatManeuver(400, 250) -- like nimble frigates
template:setJumpDrive(true)
template:setJumpDriveRange(5000, 60000)	-- for a FTL ship it should be higher than normal
template:setLongRangeRadarRange(35000)	-- instead raise long range -> more fun for scouting

--                  Arc, Dir, Range, CycleTime, Dmg
template:setBeam(0,60, -20, 1200.0, 16.0, 12)
template:setBeam(1,60,  20, 1200.0, 16.0, 12)
-- range: default, not like snipers or corvettes
-- dmg: double of light cruiser, not double of corvette
-- cycle time: double of light cruiser, not double of corvette

-- 13% system heat for each shot (normal is 2%)  - cool your beams!
template:setBeamWeaponHeatPerFire(0, 0.13)
template:setBeamWeaponHeatPerFire(1, 0.13)
-- firing beam weapons takes increased energy (normal is 3.0)
template:setBeamWeaponEnergyPerFire(0, 15.0)
template:setBeamWeaponEnergyPerFire(1, 15.0)

-- 3 tubes (links, rechts, hinten) und 10sec ladezeit
template:setTubes(3, 10.0)

-- kapazität für waffensysteme
template:setWeaponStorage("HVLI", 20) -- flak (medium!)
template:setWeaponStorage("Homing", 10) -- missile (small)
template:setWeaponStorage("Nuke", 2) -- super missile (small)
template:setWeaponStorage("EMP", 2) -- antishield missile (small)
template:setWeaponStorage("Mine", 6) -- minen, nur hinten (medium)	-- between light cruiser and mine layer

-- TODO: Für skripting?
--template:setTypeName("Light Cruiser")
--template:setWeaponStorageMax("HVLI", 30)
--template:setWeaponStorageMax("Homing", 20)
--template:setWeaponStorageMax("Nuke", 6)
--template:setWeaponStorageMax("EMP", 6)
--template:setWeaponStorageMax("Mine", 10)

-- links: small missiles 
template:setTubeDirection(0, 0)
template:weaponTubeDisallowMissle(0, "HVLI")
template:weaponTubeDisallowMissle(0, "Mine")
template:setTubeSize(0, "small")
template:setTubeLoadTime(0, 8)

-- rechts: flak (medium)
template:setTubeDirection(1, 0)
template:setWeaponTubeExclusiveFor(1, "HVLI")
template:setTubeSize(1, "medium")
template:setTubeLoadTime(1, 10)

-- hinten: medium mines
template:setTubeDirection(2, 180)
template:setWeaponTubeExclusiveFor(2, "Mine")
template:setTubeSize(2, "medium")
template:setTubeLoadTime(2, 20)


-- FTL... ääh.... räume halt
template:setRepairCrewCount(2) -- 3 crew -1 steuermann


template:addRoomSystem(8, 3, 1, 2, "Maneuver");
template:addRoom(7,3, 1, 2);

template:addRoomSystem(5, 2, 2, 2, "FrontShield");
template:addRoomSystem(5, 4, 2, 2, "RearShield");
template:addRoom(4, 1, 2, 1);
template:addRoom(4, 6, 2, 1);

template:addRoom(4, 2, 1, 2);
template:addRoomSystem(4, 4, 1, 2, "BeamWeapons");

template:addRoomSystem(2, 3, 2, 2, "MissileSystem");
template:addRoomSystem(1, 2, 2, 1, "Impulse");
template:addRoomSystem(1, 5, 2, 1, "JumpDrive");
template:addRoomSystem(0, 3, 2, 2, "Reactor");

-- helm
template:addDoor(8,4, false);
template:addDoor(7,3, false);
template:addDoor(7,4, false);

template:addDoor(5, 2, false);
template:addDoor(5, 2, true);
template:addDoor(5, 5, false);
template:addDoor(5, 6, true);

template:addDoor(4, 3, false);
template:addDoor(4, 4, false);

template:addDoor(1, 3, true);
template:addDoor(2, 3, true);
template:addDoor(1, 5, true);
template:addDoor(2, 5, true);
