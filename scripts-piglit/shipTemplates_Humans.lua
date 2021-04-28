--this file contains human npc ships. Playerships are found in shipTemplates_Player.
--Every ship hull comes in several colors:

-- White: owned and outfited by Human Navy. Players default color (adjustable in shipTemplates_Player)
-- Yellow: Workers (stationary or unordered)
-- Blue: Travellers (convoys and escorts)
-- Red: criminals (enemy)
-- Green: Ghosts (enemy)
-- Grey: old default ships. (friendly)

color_default= "Grey"  --default/old equipment
-- Human light beam:  arc 90, rng 1200, cycle 8, dmg 6 = 0.75 dps  (used on light cruiser and transport)
-- Human fast beam:                           3,   1-2 = 0.67 dps  (used on beam cruiser)

color_milit  = "White" --get default military equipment. Like to travel in offensive echelon formation.
color_ghosts = "Green" --get improved equipment. Use Kraylor weapons. 
color_pirate = "Red"   --get improved equipment. Use Exuari weapons. 
color_civil1 = "Yellow"--get civil equipment. Yellows work in unordered formations. Ships are placed in the center of a group ready for protection to all sides.
color_civil2 = "Blue"  --get civil equipment. Blues like to travel in column formation. Ships are designed for vanguard or rear-guard duties.


--tactic formation notes
-- Unordered:
-- . .
-- .   . 
--  .  
--    .
--
-- Column (protective):
-- .	Vanguard
-- .	Transport
-- .	Transport
-- .	Rear-Guard
--
-- Echelon (offensive):
-- .
--  .
--   .
--    .
--
--Fighter Formations:
-- Vic:
--  .
-- . .
--
-- Four-Finger:
--   .	Flight Leader (off)
--  . . Flight Wingman (def), Element Leader (off)
--     .Element Wingman (def)
--
-- Rotte:
--  .	Leader
-- .  	Wingman
--


--AdlerLongRangeScout
--radius: 30, beams: 3, tubes: 1
--Adder(Scout, fighter)
--
--AtlasHeavyFighter/AtlasDestroyer
--radius: 80/160, beams: 2, tubes: 3/5
--Atlantis(Destroyer)
--
--LindwurmFighter
--radius: 30, beams: 0, tubes: 3
--Lindwurm(Bomber, fighter)
--
--WespeScout
--radius: 30, beams: 2, tubes: 0
--Hornet(Interceptor, fighter)
--
--MissileCorvette
--radius: 80, beams: 0 , tubes: 0
--Storm(heavy attil, nonplayer)
--
--LaserCorvette
--radius: 80, beams: 0, tubes: 0
--Nirvana/Hathcock(Beam cruiser/sniper, frontal)
--
--LightCorvette
--radius: 80, beams: 0, tubes: 0
--Flavia (Transport, rear fire), Repulse(rear fire)
--
--MineLayerCorvette
--radius: 80, beams: 0, tubes: 0
--Nautilus (player only)
--
--HeavyCorvette
--radius: 80, beams: 0, tubes: 0
--Piranha(Missile, no beam)
--
--MultiGunCorvette
--radius: 80, beams: 0, tubes: 0
--Phobos(light Cruiser)
--



--9 ships, 10 models; just rematch!


--LC light cruiser, allrounder
--MC missile cruiser broadside, no beam, defense against surprise attacks/surrounded - combine with BS
--BC beam cruiser anti fighter, defense against fighters/close combat - combine with MC
--TRN transport, maybe armed
--JCR jump carrier
--CRV corvette, destroyer - offensive allround 
--HMC heavy missile cruiser frontal assault, +beam, offensive
--stalker? nuker? enemies!

--[[Fighter--]]
model_hornet = "WespeFighter"
descr_hornet = [[The MT52 Hornet is a basic interceptor found in many corners of the galaxy. It's easy to find spare parts for MT52s, not only because they are produced in large numbers, but also because they suffer high losses in combat.]]
template = ShipTemplate():setName("MT52 Hornet"):setClass("Starfighter", "Interceptor")
template:setModel(model_hornet..color_default)
template:setRadarTrace("radar_fighter.png")
template:setDescription(descr_hornet)
template:setHull(30)
template:setShields(20)
--Reputation Score: 5.0
template:setSpeed(120, 30, 25)
template:setDefaultAI('fighter')
--                  Arc, Dir, Range, CycleTime, Dmg
template:setBeam(0, 30, 0, 700.0, 4.0, 2)
template:setBeam(1, 30, 0, 700.0, 4.0, 2)

variation = template:copy("MU52 Hornet")
variation:setModel(model_hornet..color_milit)
variation:setDescription([[The MU52 Hornet is a new, upgraded version of the MT52. All of its systems are slightly improved over the MT52 model.]])
variation:setHull(35)
variation:setShields(22)
--Reputation Score: 5.7
variation:setSpeed(125, 32, 25)
variation:setBeam(0, 30, 0, 900.0, 4.0, 2.5)
variation:setBeam(1, 30, 0, 900.0, 4.0, 2.5)

for _,color in ipairs({"Green", "Red", "Yellow", "Blue"}) do
	if color == "Green" then
		variation = template:copy("Advanced Hornet")
	else
		variation = template:copy(color .. " Hornet")
	end
	variation:setModel(model_hornet..color)
end


--[[Bomber--]]
model_lindworm = "LindwurmFighter"
descr_lindworm = [[The WX-Lindworm, or "Worm" as it's often called, is a bomber-class starfighter. While one of the least-shielded starfighters in active duty, the Worm's two launchers can pack quite a punch. Its goal is to fly in, destroy its target, and fly out or be destroyed.]]
template = ShipTemplate():setName("WX-Lindworm"):setClass("Starfighter", "Bomber")
template:setModel(model_lindworm..color_default)
template:setRadarTrace("radar_fighter.png")
template:setDescription(descr_lindworm)
template:setHull(50)
template:setShields(20)
--Reputation Score: 7
template:setSpeed(50, 15, 25)
template:setTubes(3, 15.0)
template:setTubeSize(0, "small")
template:setTubeSize(1, "small")
template:setTubeSize(2, "small")
template:setWeaponStorage("HVLI", 6)
template:setWeaponStorage("Homing", 1)
template:setTubeDirection(1,-1):setWeaponTubeExclusiveFor(1, "HVLI")
template:setTubeDirection(2, 1):setWeaponTubeExclusiveFor(2, "HVLI")


for _,color in ipairs({"Green", "Red", "Yellow", "Blue"}) do
	if color == "Green" then
		variation = template:copy("Advanced Lindworm")
	else
		variation = template:copy(color .. " Lindworm")
	end
	variation:setModel(model_lindworm..color)
end

--[[Scout--]]
model_adder = "AdlerLongRangeScout"
descr_adder = [[The Adder line's fifth iteration proved to be a great success among pirates and law officers alike. It is cheap, fast, and easy to maintain, and it packs a decent punch.]]

template = ShipTemplate():setName("Adder MK5"):setClass("Starfighter", "Gunship")
template:setModel(model_adder..color_default)
template:setRadarTrace("radar_fighter.png")
template:setDescription(descr_adder)
template:setHull(50)
template:setShields(30)
--Reputation Score: 8
template:setSpeed(80, 28, 25)
template:setBeam(0, 35, 0, 800, 5.0, 2.0)
template:setBeam(1, 70, -35, 600, 5.0, 2.0)
template:setBeam(2, 70, 35, 600, 5.0, 2.0)
template:setTubes(1, 15.0)
template:setTubeSize(0, "small")
template:setWeaponStorage("HVLI", 4)

for _,color in ipairs({"Green", "Red", "Yellow", "Blue"}) do
	if color == "Green" then
		variation = template:copy("Advanced Adder MK5")
	else
		variation = template:copy(color .. " Adder MK5")
	end
	variation:setModel(model_adder..color)
end

variation = template:copy("Adder MK4")
variation:setModel(model_adder..color_default)
variation:setDescription([[The mark 4 Adder is a rare sight these days due to the success its successor, the mark 5 Adder, which often replaces this model. Its similar hull, however, means careless buyers are sometimes conned into buying mark 4 models disguised as the mark 5.]])
variation:setHull(40)
variation:setShields(20)
--Reputation Score: 6
variation:setSpeed(60, 20, 20)
variation:setTubes(1, 20.0)
variation:setTubeSize(0, "small")
variation:setWeaponStorage("HVLI", 2)

for _,color in ipairs({"Green", "Red", "Yellow", "Blue"}) do
	if color == "Green" then
		variation = template:copy("Advanced Adder MK4")
	else
		variation = template:copy(color .. " Adder MK4")
	end
	variation:setModel(model_adder..color)
end

variation = template:copy("Adder MK6")
variation:setModel(model_adder..color_milit)
variation:setDescription([[The mark 6 Adder is a small upgrade compared to the highly successful mark 5 model. Since people still prefer the more familiar and reliable mark 5, the mark 6 has not seen the same level of success.]])
variation:setBeam(3, 35,180, 600, 6.0, 2.0)
variation:setWeaponStorage("HVLI", 8)



--[[Light Cruiser--]]
model_phobos = "MultiGunCorvette"
descr_phobos = [[The Phobos is the workhorse of the human navy. It's extremely easy to modify, which makes retro-fitting this ship a breeze. Its basic stats aren't impressive, but due to its modular nature, it's fairly easy to produce in large quantities.

As a light cruiser the Phobos is a allrounder: front beams and missiles, moderate shields, reasonable speed.

]]
--as is, old
template = ShipTemplate():setName("Phobos T3"):setClass("Frigate", "Light Cruiser"):setModel(model_phobos..color_milit)
template:setDescription(descr_phobos)
template:setRadarTrace("radar_cruiser.png")
template:setHull(70)
template:setShields(50, 40)
--Reputation Score: 16
template:setSpeed(60, 10, 10)
template:setBeamWeapon(0, 90, -15, 1200, 8, 6)
template:setBeamWeapon(1, 90,  15, 1200, 8, 6)
template:setTubes(2, 60.0)
template:setWeaponStorage("HVLI", 20)
template:setWeaponStorage("Homing", 6)
template:setTubeDirection(0, -1)
template:setTubeDirection(1,  1)

--yellow
variation = template:copy("Phobos Y2")
variation:setModel(model_phobos..color_civil1)
variation:setDescription(descr_phobos..[[This civil version of the Phobos is outfited for use in asteroid belts. Higher maneuverability is combined with reinfored hull against impact.]])
variation:setHull(90)
--Reputation Score: 18
variation:setSpeed(60, 15, 10)

--blue front
variation = template:copy("Phobos Vanguard")
variation:setModel(model_phobos..color_civil2)
variation:setDescription(descr_phobos..[[The Phobos Vanguard is designed to travel on the top position of convoys in column formation. The shields are reconfigured for frontal defense.]])
variation:setShields(70, 30)
--Reputation Score: 17
variation:setSpeed(65, 10, 10)

--blue rear 
variation = template:copy("Phobos Rear-Guard")
variation:setModel(model_phobos..color_civil2)
variation:setDescription(descr_phobos..[[The Phobos Rear-Guard is designed to travel on the last position of convoys in column formation. It adds a rear mounted missile tube, but the extra storage required slows this ship down slightly.]])
variation:setTubes(3, 60.0)
variation:setTubeDirection(2,  180)
variation:setSpeed(55, 10, 10)

--as is, military; has mines, but AI can not use them right now
variation = template:copy("Phobos M3")
variation:setModel(model_phobos..color_default)
variation:setDescription(descr_phobos..[[The Phobos M3 is a military variant of the Phobos. It adds a mine-laying tube, but the extra storage required for the mines slows this ship down slightly.]])
variation:setTubes(3, 60.0)
variation:setTubeDirection(2,  180):setWeaponTubeExclusiveFor(2, "Mine")
variation:setWeaponStorage("Mine", 6)
variation:setSpeed(55, 10, 10)

--pirate
variation = template:copy("Phobos Firehawk")
variation:setModel(model_phobos..color_pirate)
variation:setDescription(descr_phobos..[[This variant of the Phobos is outfited with Exuari Striker Guns which are declared illegal by the human authority.]])
variation:setBeamWeapon(0, 40, -15, 1000, 6, 6)
variation:setBeamWeapon(1, 40,  15, 1000, 6, 6)

--ghost
variation = template:copy("Phobos G4")
variation:setModel(model_phobos..color_ghosts)
variation:setDescription(descr_phobos..[[This variant was outfitted with Krayor particle beams. Since this kind of equipment uses a lot of space and energy, some vital parts of the ship had to be removed. It is not known how this craft manages to remain functional.]])
variation:setBeamWeapon(0, 60, -15, 1500, 6, 8)
variation:setBeamWeapon(1, 60,  15, 1500, 6, 8)


--[[Missile Cruiser--]]
model_piranha = "HeavyCorvette" 
descr_piranha = [[The Piranha broadside missile cruiser is a light artillery frigate. It is often used as escort or countermeassure against ambushes. It's homing missiles can take out single starfighters quickly, and capital ships fear the full broadside HVLI attacks. It was designed to replace the old Piranha missile cruiser. However, the biggest flaw of the Piranha is still present: the lack of beam weapons.

]]
--as is, yellow
template = ShipTemplate():setName("Piranha F12"):setClass("Frigate", "Missile Cruiser")
template:setModel(model_piranha..color_civil1)
template:setDescription(descr_piranha..[[This is the top-seller outfit for civil use. Like the old Piranha, the Piranha F12 fires exclusively from broadside weapons. Is is merely used as defense for unarmed industrial vessels against pirate raiders.]])
template:setRadarTrace("radar_missile_cruiser_thin.png")
template:setHull(70)
template:setShields(30, 30)
--Reputation Score: 13
template:setSpeed(40, 6, 8)
template:setTubes(6, 15.0)
template:setWeaponStorage("HVLI", 20)
template:setWeaponStorage("Homing", 6)
template:setTubeDirection(0, -90)
template:setTubeDirection(1, -90):setWeaponTubeExclusiveFor(1, "HVLI")
template:setTubeDirection(2, -90):setWeaponTubeExclusiveFor(2, "HVLI")
template:setTubeDirection(3,  90)
template:setTubeDirection(4,  90):setWeaponTubeExclusiveFor(4, "HVLI")
template:setTubeDirection(5,  90):setWeaponTubeExclusiveFor(5, "HVLI")
template:setDefaultAI('missilevolley')

--as is, old
variation = template:copy("Piranha F8")
variation:setModel(model_piranha..color_default)
variation:setDescription(descr_piranha..[[The first version of the Piranha was released into mass production before the secondary missile tubes were designed. It is not popular due to its meager firepower and unfinished tube configuration. The result was a huge financial failure.]])
variation:setTubes(2, 12.0)
variation:setWeaponStorage("HVLI", 10)
variation:setWeaponStorage("Homing", 5)
variation:setTubeDirection(0, -90)
variation:setTubeDirection(1,  90)

--blue front
variation = variation:copy("Piranha Vanguard")
variation:setModel(model_piranha..color_civil2)
variation:setDescription(descr_piranha..[[After the Piranha F8 turned out to be a flop on the market and the Piranha F12 were already available, the Blue Star Trading Cartell acquired the remaining Piranha F8 models while they were cheap.
The Piranha Vanguard and Piranha Rear-Guard were created by turning the missile tubes direction of the Piranha F8.

The Piranha Vanguard is often found as formation leader of echelon (diagonal left to right) formations. Convoys with a Piranha Vanguard often come with a Nirvana Rear-Guard.]])
variation:setTubeDirection(0, 0)
variation:setTubeDirection(1, 0)
variation:setDefaultAI('default')

--blue back 
variation = variation:copy("Piranha Rear-Guard")
variation:setModel(model_piranha..color_civil2)
variation:setDescription(descr_piranha..[[After the Piranha F8 turned out to be a flop on the market and the Piranha F12 were already available, the Blue Star Trading Cartell acquired the remaining Piranha F8 models while they were cheap.
The Piranha Vanguard and Piranha Rear-Guard were created by turning the missile tubes direction of the Piranha F8.

The Piranha Rear-Guard is often found on the last position of echelon or column formations. Convoys with a Piranha Rear-Guard often come with a Nirvana Vanguard.]])
variation:setTubeDirection(0, 180)
variation:setTubeDirection(1, 180)
variation:setDefaultAI('missilevolley')

--as is
variation = template:copy("Piranha F12.M")
variation:setModel(model_piranha..color_pirate)
variation:setDescription(descr_piranha .. [[This modified Piranha F12 is in all respects the same vessel except for special weapon tube modifications that allow it to fire nukes in addition to its normal loadout. However, these changes reduce its overall missile storage capacity and render the ship illegal.]])
variation:setWeaponStorage("HVLI", 10)
variation:setWeaponStorage("Homing", 4)
variation:setWeaponStorage("Nuke", 2)

--ghosts
variation = template:copy("Piranha G4")
variation:setModel(model_piranha..color_ghosts)
variation:setDescription(descr_piranha .. [[This modified Piranha F12 is in all respects the same vessel except for special weapon tube modifications that allow it to fire nukes in addition to its normal loadout. However, these changes render the ship illegal.]])
variation:setWeaponStorage("Nuke", 1)

--milit
variation = template:copy("Piranha M5")
variation:setModel(model_piranha..color_milit)
variation:setDescription(descr_piranha..[[This combat-specialized Piranha M5 adds nukes and the secondary tubes can also launch homing missiles.]])
variation:setWeaponStorage("Homing", 12)
variation:setWeaponStorage("Nuke", 6)
variation:weaponTubeAllowMissle(1, "Homing"):weaponTubeAllowMissle(2, "Homing")
variation:weaponTubeAllowMissle(4, "Homing"):weaponTubeAllowMissle(5, "Homing")


--[[Beam Cruiser--]]
model_nirvana = "LaserCorvette"
descr_nirvana = [[The Nirvana is an anti-fighter cruiser. It has several rapid-firing, low-damage point-defense weapons to quickly take out starfighters. It is often used as a escort or defensive spacecraft.

]]
--Balancing Info: To take out shield+hull=40 starfighters, a range of 1200 is too low.

--as is, old
template = ShipTemplate():setName("Nirvana R5"):setClass("Frigate", "Beam Cruiser")
template:setModel(model_nirvana..color_default)
template:setRadarTrace("radar_laser.png")
template:setDescription(descr_nirvana)
template:setBeamWeapon(0, 90, -15, 1400, 3, 2)
template:setBeamWeapon(1, 90,  15, 1400, 3, 2)
template:setBeamWeapon(2, 90,  50, 1400, 3, 2)
template:setBeamWeapon(3, 90, -50, 1400, 3, 2)
template:setHull(70)
template:setShields(50, 40)
--Reputation Score: 16
template:setSpeed(70, 12, 10)

--as is, yellow
variation = template:copy("Nirvana R5A")
variation:setModel(model_nirvana..color_civil1)
variation:setDescription(descr_nirvana..[[This is an improved version of the Nirvana R5 with faster turning speed and firing rates. It is often found protecting small groups of industrial vessels from raiders.]])
variation:setBeamWeapon(0, 90, -15, 1400, 2.9, 2)
variation:setBeamWeapon(1, 90,  15, 1400, 2.9, 2)
variation:setBeamWeapon(2, 90,  50, 1400, 2.9, 2)
variation:setBeamWeapon(3, 90, -50, 1400, 2.9, 2)
variation:setSpeed(70, 15, 10)

--blue front
variation = template:copy("Nirvana Vanguard")
variation:setModel(model_nirvana..color_civil2)
variation:setDescription(descr_nirvana..[[The Nirvana Vanguard is designed to travel on the top position of convoys in echelon formation. The shields are reconfigured for frontal defense. Convoys with a Nirvana Vanguard often come with a Piranha Rear-Guard.]])
variation:setShields(70, 30)
--Reputation Score: 17

--blue back 
variation = template:copy("Nirvana Rear-Guard")
variation:setModel(model_nirvana..color_civil2)
variation:setDescription(descr_nirvana..[[The Nirvana Rear-Guard is designed to travel on the last position of convoys in column formation. It features a rear mounted beam. Convoys with a Nirvana Rear-Guard often come with a Piranha Vanguard.]])
variation:setBeamWeapon(4, 90, 180, 1400, 3, 2)

--pirate
variation = template:copy("Nirvana Thunder Child")
variation:setModel(model_nirvana..color_pirate)
variation:setDescription(descr_nirvana..[[In this outfit the original beam weapons were replaced by Exuari Fighter Guns, which are prohibited on human ships by the human authority.]])
variation:setBeamWeapon(0, 60, -15, 1200, 4, 4)
variation:setBeamWeapon(1, 60,  15, 1200, 4, 4)
variation:setBeamWeapon(2, 60,  50, 1200, 4, 4)
variation:setBeamWeapon(3, 60, -50, 1200, 4, 4)

--ghost
variation = template:copy("Nirvana 0x81")
variation:setModel(model_nirvana..color_ghosts)
variation:setDescription(descr_nirvana..[[In this outfit the original beam weapons were replaced by powerful Krayor paricle beams. The consumption of space and energy is immense and it is unlikely this spacecraft is actually capable of hosting any crew at all.]])
variation:setBeamWeapon(0, 60, -15, 1500, 6, 8)
variation:setBeamWeapon(1, 60,  15, 1500, 6, 8)
variation:setBeamWeapon(2, 60,  50, 1500, 6, 8)
variation:setBeamWeapon(3, 60, -50, 1500, 6, 8)

--milit
variation = template:copy("Nirvana R5M")
variation:setModel(model_nirvana..color_milit)
variation:setDescription(descr_nirvana..[[This is an improved version of the Nirvana R5 with faster turning speed and firing rates. It is equipped with military fast beam weapons, doing double damage compared to civil versions.]])
variation:setBeamWeapon(0, 90, -15, 1400, 2.9, 2.5)
variation:setBeamWeapon(1, 90,  15, 1400, 2.9, 2.5)
variation:setBeamWeapon(2, 90,  50, 1400, 2.9, 2.5)
variation:setBeamWeapon(3, 90, -50, 1400, 2.9, 2.5)
variation:setSpeed(70, 15, 10)


--[[Transport--]]
model_flavia = "LightCorvette" 
descr_flavia = [[Popular among traders and smugglers, the Flavia is a small cargo and passenger transport. It's cheaper than a freighter for small loads and short distances, and is often used to carry high-value cargo discreetly.]]
--as is, old
template = ShipTemplate():setName("Flavia"):setClass("Frigate", "Light transport")
template:setModel(model_flavia..color_default)
template:setDescription(descr_flavia)
template:setRadarTrace("radar_tug.png")
template:setHull(50)
template:setShields(50, 50)
--Reputation Score: 15
template:setSpeed(30, 8, 10)

--blue
variation = template:copy("Flavia Express")
variation:setModel(model_flavia..color_civil2)
variation:setDescription(descr_flavia..[[The Flavia Express is a Flavia transport modified for faster flight. It is most often found in the in the middle of a column formation, guarded by cruisers. Such a convoy can afford losing the escore in battle, since the Flavia Express is able to outrun most common cruisers.]])
variation:setSpeed(60, 8, 10) --blue speeds: (40 MC, 55 LC-R, 60 TRN, 65 LC-V, 70 BC)

--as is, yellow
variation = template:copy("Flavia Falcon")
variation:setModel(model_flavia..color_civil1)
variation:setDescription(descr_flavia..[[The Flavia Falcon is a Flavia transport modified for faster flight, and adds rear-mounted lasers to keep enemies off its back. It is often seen in small groups as industrial vehicle, capable of escaping quickly from attackers.]])
variation:setSpeed(50, 8, 10)
variation:setBeam(0, 40, 170, 1200.0, 8.0, 6)
variation:setBeam(1, 40, 190, 1200.0, 8.0, 6)

--military
variation = template:copy("Flavia AT")
variation:setModel(model_flavia..color_milit)
variation:setDescription(descr_flavia..[[The Flavia Armed Transport is used by the human navy to transport small combat ready troops. It is most often found in the in the middle of a echelon formation, guarded by cruisers. Often it is used to bring enter-commandos in position or to carry prisoners.]])
variation:setBeam(0, 40,  10, 1200.0, 8.0, 6)
variation:setBeam(0, 40, -10, 1200.0, 8.0, 6)

--pirate
variation = template:copy("Flavia Medusa")
variation:setModel(model_flavia..color_pirate)
variation:setDescription(descr_flavia..[[The Flavia Medusa is a Flavia transport mostly used by pirates. It is capable of carring EMP missiles and enter commandos.]])
variation:setTubes(1, 30.0)
variation:setWeaponStorage("EMP", 2)

--ghost
variation = template:copy("Flavia Sniper")
variation:setModel(model_flavia..color_ghosts)
variation:setDescription(descr_flavia..[[The Flavia Sniper is a Flavia transport with a heavy turret on top. The technology used for this weapon is unknown.]])
variation:setBeam(0,  20, 0, 2400.0, 6.0, 8):setBeamWeaponTurret(0, 360, 0, 3)


--------------------------------------------------------------------------------
--no civil use (yet)


--[[Assault Missile Cruiser--]]
--as is, milit
model_strom = "MissileCorvette"
descr_storm = [[A heavy artillery cruiser, the Storm fires bunches of missiles from forward facing tubes. This spacecraft is designed for pure offensive actions, hence the use of the Storm is only allowed to the Human Navy. A big weakness of the Storm is it's slow turning rate.]] 
template = ShipTemplate():setName("Storm"):setClass("Frigate", "Heavy Artillery Cruiser")
template:setModel(model_strom..color_milit)
template:setRadarTrace("radar_cruiser.png")
template:setDescription(descr_storm)
template:setBeamWeapon(0, 60, 0, 1200, 3, 2)
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
template:setDefaultAI('missilevolley')

--pirate
variation = template:copy("Lightning Storm")
variation:setModel(model_strom..color_pirate)
variation:setDescription(descr_storm..[[ The Lightning Storm is a modified version using non-standard beam weapons.]])
variation:setBeam(0,  40, 0, 1000.0, 6.0, 6)

--ghost
variation = template:copy("Solar Storm")
variation:setModel(model_strom..color_ghosts)
variation:setDescription(descr_storm..[[ The Solar Storm is a modified version using non-standard beam weapons.]])
variation:setBeam(0,  60, 0, 1500.0, 6.0, 8)


--[[Corvette--]]
--as is, military

model_atlantis = "AtlasHeavyCorvette"
descr_atlantis = [[The Atlantis X23 is the smallest model of destroyer, and its combination of frigate-like size and corvette-like power makes it an excellent escort ship when defending larger ships against multiple smaller enemies. Because the Atlantis X23 is fitted with a jump drive, it can also serve as an intersystem patrol craft.]]
template = ShipTemplate():setName("Atlantis X23"):setClass("Corvette", "Destroyer")
template:setModel(model_atlantis..color_milit)
template:setDescription(descr_atlantis)
template:setRadarTrace("radar_dread.png")
template:setHull(100)
template:setShields(200, 200, 200, 200)
--Reputation Score: 90
template:setSpeed(30, 3.5, 5)
template:setJumpDrive(true)
--                  Arc, Dir, Range, CycleTime, Dmg
template:setBeam(0,100, -20, 1500.0, 6.0, 8)
template:setBeam(1,100,  20, 1500.0, 6.0, 8)
template:setBeam(2,100, 180, 1500.0, 6.0, 8)
template:setTubes(4, 10.0)
template:setWeaponStorage("HVLI", 20)
template:setWeaponStorage("Homing", 4)
template:setTubeDirection(0, -90)
template:setTubeDirection(1, -90)
template:setTubeDirection(2,  90)
template:setTubeDirection(3,  90)

--TODO
template = ShipTemplate():setName("Starhammer II"):setClass("Corvette", "Destroyer"):setModel("battleship_destroyer_4_upgraded")
template:setDescription([[Contrary to its predecessor, the Starhammer II lives up to its name. By resolving the original Starhammer's power and heat management issues, the updated model makes for a phenomenal frontal assault ship. Its low speed makes it difficult to position, but when in the right place at the right time, even the strongest shields can't withstand a Starhammer's assault for long.]])
template:setRadarTrace("radar_dread.png")
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


--[[---------------------Carrier------------------------]]
template = ShipTemplate():setName("Jump Carrier"):setClass("Corvette", "Freighter"):setModel("transport_4_2")
template:setDescription([[The Jump Carrier is a specialized Freighter. It does not carry any cargo, as it's cargo bay is taken up by a specialized jump drive and the energy storage required to run this jump drive.
It is designed to carry other ships deep into space. So it has special docking parameters, allowing other ships to attach themselves to this ship.]])
template:setHull(100)
template:setShields(50, 50)
--Reputation Score: 20
template:setSpeed(50, 6, 10)
template:setRadarTrace("radar_transport.png")
template:setJumpDrive(true)
template:setJumpDriveRange(5000, 100 * 50000) --The jump carrier can jump a 100x longer distance then normal jump drives.
template:setDockClasses("Starfighter", "Frigate", "Corvette")
template:setRestocksMissilesDocked(true)
template:setSharesEnergyWithDocked(true)
template:setRepairDocked(true)
template:setRestocksScanProbes(true)

--[[-----------------------Support-----------------------]]

-- The weapons-platform is a stationary platform with beam-weapons. It's extremely slow to turn, but it's beam weapons do a huge amount of damage.
-- Smaller ships can dock to this platform to re-supply.
template = ShipTemplate():setName("Defense platform"):setClass("Corvette", "Support"):setModel("space_station_4")
template:setDescription([[This stationary defense platform operates like a station, with docking and resupply functions, but is armed with powerful beam weapons and can slowly rotate. Larger systems often use these platforms to resupply patrol ships.]])
template:setRadarTrace("radartrace_smallstation.png")
template:setHull(150)
template:setShields(120, 120, 120, 120, 120, 120)
--Reputation Score: 87
template:setSpeed(0, 0.5, 0)
template:setDockClasses("Starfighter", "Frigate")
--                  Arc, Dir, Range, CycleTime, Dmg
template:setBeam(0, 30,   0, 4000.0, 1.5, 20)
template:setBeam(1, 30,  60, 4000.0, 1.5, 20)
template:setBeam(2, 30, 120, 4000.0, 1.5, 20)
template:setBeam(3, 30, 180, 4000.0, 1.5, 20)
template:setBeam(4, 30, 240, 4000.0, 1.5, 20)
template:setBeam(5, 30, 300, 4000.0, 1.5, 20)

template:setRestocksMissilesDocked(true)
template:setSharesEnergyWithDocked(true)
template:setRepairDocked(true)
template:setRestocksScanProbes(true)




