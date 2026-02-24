require("shipSystems.lua") -- contains addSystems*

color_player = "White" --change it if you want another style

function createTemplate(crew_size, shield_segments, turret_level)
	template = ShipTemplate()
	template:setType("playership")
	local model_names = {
		"WespeFighter",			--1 Fighter
		"AdlerLongRangeScout",	--2 Heavy Fighter
		"LaserScout",			--3 Heavy Fighter
		"LightCorvette",		--4 Light Transport
		"MultiGunCorvette",		--5	Light Transport
		"HeavyFrigate"			--6 Medium Freighter
	}
	template:setModel(model_names[crew_size]..color_player)
	local system_functions = {
		addSystemsWespe,	--1 Fighter
		addSystemsAdler,	--2 Heavy Fighter
		addSystemsLaser,	--3 Heavy Fighter
		addSystemsLight,	--4 Light Transport
		addSystemsMultiGun,	--5	Light Transport
		addSystemsHeavy,	--6 Medium Freighter
	}
	system_functions[crew_size](template)

	-- scale up with crew_size
	template:setHull(40*crew_size)
	template:setEnergyStorage(400 + 100*crew_size)
	template:setLongRangeRadarRange(math.max(10000, 5000*crew_size))	-- min 20u for asteroid show/hide
	template:setRepairCrewCount(crew_size)

	-- scale down speed with crew_size
	--                speed, 			turn, 			accel, 			rev-speed, rev-accel
	template:setSpeed(110-10*crew_size, 22-2*crew_size, 45-5*crew_size)

	-- shields depend on shield_segments
	assert(shield_segments <= 2 and shield_segments >= 0)
	if shield_segments == 1 then
		template:setShields(math.floor(30*crew_size))
	elseif shield_segments == 2 then
		template:setShields(20*crew_size, 20*crew_size)
	end

	-- beams default to two beams in front; all cause 1 dps

	assert(turret_level <= 3 and turret_level >= 0)
	if turret_level > 0 then
		--           		Arc,  Dir,	Range, 				CycleTime,	Dmg
		template:setBeam(0, 10,   0,	800+100*crew_size, 	crew_size, 	crew_size)
		template:setBeam(1, 10,   0,	800+100*crew_size, 	crew_size, 	crew_size)
		--							    Arc, 			Dir, Rotate speed
		template:setBeamWeaponTurret(0, 120*turret_level, 0, 6-turret_level)
		template:setBeamWeaponTurret(1, 120*turret_level, 0, 6-turret_level)
	else
		local beam_arc = 15*crew_size
		local beam_dir = 5*crew_size
		local beam_range = 800+100*crew_size
		if crew_size <= 3 then
			beam_arc = 30
			beam_dir = 5
		end
		--           		Arc,  		Dir,		Range,			CycleTime,	Dmg
		template:setBeam(0, beam_arc,   -beam_dir,	beam_range, 	crew_size, 	crew_size)
		template:setBeam(1, beam_arc,    beam_dir,	beam_range, 	crew_size, 	crew_size)
	end

	if crew_size <= 2 then
		-- fighter functionality
		template:setImpulseSoundFile("sfx/engine_fighter.wav")
		template:setDefaultAI('fighter')
		-- if tactical and engi are used, GM must disable auto*
		template:setAutoCoolant(true)
		template:setAutoRepair(true)
		template:setAutoMissileReload(true)
		template:setCanHack(false)
		template:setCanCombatManeuver(false)
		template:setCanLaunchProbe(false)
	end

	template:setCanSelfDestruct(false)
	template:setInternalDockClasses("Escape Pod")
	template:setDockClasses("Shuttle")
	return template
end

function addRockets(variation, auto)
	variation:setTubes(1, 10.0)
	variation:setWeaponStorage("Homing", 6)
	variation:setAutoMissileReload(auto)
end

--[[ Fighters (1 person crew) --]]
-- Fighters are quick agile ships that do not do a lot of damage, but usually come in larger groups. They are easy to take out, but should not be underestimated.
local template = createTemplate(1, 2, 0)

var = template:copy("U-Wing")
var:setClass("Starfighter", "Support")
var:setDescription(_("The UT-60D U-wing starfighter/support craft, also known as the UT-60D, U-wing, or UT-60D U-wing Troop Transport, was a transport/gunship model manufactured by Incom Corporation and used by the Alliance to Restore the Republic during the Galactic Civil War. Used to drop troops into battle, and provide cover fire for them, U-wings were pivotal in transport and protection of the Rebel Alliance's ground forces during the Battle of Scarif."))
var:setRadarTrace("uwing.png")
var:setRepairCrewCount(0)
var:copy(" "..var:getName()):setType("ship") -- CpuShip variant

var = template:copy("X-Wing")
var:setClass("Starfighter", "Interceptor")
var:setDescription(_("X-wing starfighters were a type of starfighter marked by their distinctive S-foils that resembled the High Galactic script's character 'X' in attack formation. They were heavily armed with four laser cannons on the S-foils and proton torpedo launchers in the fuselage. X-wings were designed for dogfighting and long missions."))
var:setRadarTrace("xwing.png")
addRockets(var, true)
var:setRepairCrewCount(1)
var:copy(" "..var:getName()):setType("ship") -- CpuShip variant

var = template:copy("Peregrine yacht")
var:setClass("Starfighter", "Yacht")
var:setDescription(_("The Peregrine-class star yacht was a model of luxurious star yacht used during the Clone Wars."))
var:setRadarTrace("pyacht.png")
var:setRepairCrewCount(0)
var:copy(" "..var:getName()):setType("ship") -- CpuShip variant

var = template:copy("ARC-170")
var:setClass("Starfighter", "Heavy Assault Fighter")
var:setDescription(_("The Aggressive ReConnaissance-170 starfighter, also known simply as the ARC-170 starfighter, was a heavy-duty model of starfighter used by the Galactic Republic during the Clone Wars and was considered the latest in fighter technology. Jointly manufactured by Incom Corporation and Subpro, it continued to see usage into the reign of the Galactic Empire, but was eventually phased out by the newer TIE fighter series, though some found their way into the hands of the Alliance to Restore the Republic."))
var:setRadarTrace("arc170.png")
var:setRepairCrewCount(0)
addRockets(var, true)
var:copy(" "..var:getName()):setType("ship") -- CpuShip variant

var = template:copy("StarViper")
var:setClass("Starfighter", "Heavy Attack Fighter")
var:setDescription(_("The StarViper-class attack platform was a model of heavy attack starfighter manufactured by a subdivision of MandalMotors called Mandal Hypernautics. The fighter was lightly armored, but compensated for this with heavy weaponry and fast speed. Its high price meant that it was primarily found in use by larger crime syndicates like Black Sun and the Zann Consortium."))
var:setRadarTrace("starviper.png")
var:setShields(45)
var:setRepairCrewCount(0)
addRockets(var, true)
var:copy(" "..var:getName()):setType("ship") -- CpuShip variant

--[[Heavy Fighter (2/3 person crew)--]]
-- If 2 player: tactical & ops OR tactical & Engi+
-- must enable auto coolant/repair if no Engi is present
template = createTemplate(2, 2, 0)

var = template:copy("Sheathipede")
var:setClass("Shuttle", "Transport")
var:setDescription(_("The Sheathipede-class transport shuttle, also known as the Sheathipede-class shuttle and as the Neimoidian escort shuttle, was a short-range transport used by the Trade Federation and the Confederacy of Independent Systems. A larger version of the shuttle also existed."))
var:setRadarTrace("sheathipede.png")
var:setRepairCrewCount(0)
var:copy(" "..var:getName()):setType("ship") -- CpuShip variant


var = template:copy("TIE-Reaper")
var:setClass("Starfighter", "Transport")
var:setDescription(_("The TIE/rp Reaper attack lander, also known simply as the TIE Reaper, was a troop carrier variant of Sienar Fleet Systems's TIE fighter series used by the Galactic Empire. The TIE Reaper differed from the standard craft of the TIE line as it was primarily a troop dropship; it was designed for ferrying troops amidst the heat of battle"))
var:setRadarTrace("tierp.png")
var:setRepairCrewCount(0)
var:copy(" "..var:getName()):setType("ship") -- CpuShip variant

var = template:copy("UT-60D")
var:setClass("Starfighter", "Support")
var:setDescription(_("The UT-60D U-wing starfighter/support craft, also known as the UT-60D, U-wing, or UT-60D U-wing Troop Transport, was a transport/gunship model manufactured by Incom Corporation and used by the Alliance to Restore the Republic during the Galactic Civil War. Used to drop troops into battle, and provide cover fire for them, U-wings were pivotal in transport and protection of the Rebel Alliance's ground forces during the Battle of Scarif."))
var:setRadarTrace("uwing.png")
var:copy(" "..var:getName()):setType("ship") -- CpuShip variant

var = template:copy("Kuat D7")
var:setClass("Starfighter", "Patrol")
var:setDescription(_("The D7-Mantis Patrol Craft was a rare, top-of-the-line starship during the Cold War. It was meant to meet the demands of larger capital ships."))
var:setRadarTrace("d5.png")
var:setRepairCrewCount(0)
addRockets(var, true)
var:setWeaponStorage("Mine", 4)
var:setTubes(2, 10.0)
var:setWeaponTubeExclusiveFor(1, "Mine")
var:setTubeDirection(1, 180):setWeaponTubeExclusiveFor(1, "Mine")
var:setWeaponTubeExclusiveFor(0, "Homing")
var:copy(" "..var:getName()):setType("ship") -- CpuShip variant

var = template:copy("Kom'rk")
var:setClass("Starfighter", "Transport")
var:setDescription(_("The Kom'rk-class fighter/transport, also known as Kom'rk Class fighter transport or the Gauntlet starfighter, was a type of starfighter and troop transport used by the Mandalorian splinter faction known as Death Watch during the Clone Wars. The fighters were utilized as part of a move by Death Watch leader Pre Vizsla to end Satine Kryze's pacifist rule of Mandalore and restore the Mandalorians to their former warrior past. These ships were later used by Maul's Shadow Collective army during battles on Zanbar, Ord Mantell, and Vizsla Keep 09."))
var:setRadarTrace("komrk.png")
addRockets(var, true)
var:setRepairCrewCount(0)
var:copy(" "..var:getName()):setType("ship") -- CpuShip variant


var = template:copy("KvK-P0001")
var:setClass("Starfighter", "Attack Fighter")
var:setDescription(_("Custom designed U-Wing, rebuilt as strong fighter. Reduced weight, strong chasing, very fast impulse drive."))
var:setRadarTrace("kvk.png")
var:setCanScan(false)
var:setRepairCrewCount(1)
var:setTubes(3, 10.0)
var:setWeaponStorage("Homing", 8)
var:setWeaponStorage("HVLI", 8)
var:setWeaponStorage("Mine", 4)
var:setWeaponTubeExclusiveFor(1, "HVLI"):setTubeSize(1,"small")
var:setWeaponTubeExclusiveFor(2, "Homing")
var:setTubeDirection(2, 180):setWeaponTubeExclusiveFor(2, "Mine")
var:copy(" "..var:getName()):setType("ship") -- CpuShip variant

var = template:copy("A-24")
var:setClass("Shuttle", "Scout")
var:setDescription(_("Designed by Incom Corporation at its peak for stealth and speed, the A-24 was a long and narrow craft, with a distinctive flat and triangular aft that housed the ship's engines, weapons, and distinctive stabilizers. Amidships, the A-24 sported a pair of canards that supported the ship's powerful sensor and communications arrays, while the forward command deck, while cramped, sported a cockpit that was offset by panoramic sheets of thick photosensitive transparisteel."))
var:setRadarTrace("a24.png")
var:setRepairCrewCount(1)
var:copy(" "..var:getName()):setType("ship") -- CpuShip variant

var = template:copy("HWK-290")
var:setClass("Freighter", "Light transport")
var:setDescription(_("The HWK-290 was a light freighter manufactured by the Corellian Engineering Corporation in an effort to break into a new market for fast, small cargo ships. The production lasted from the decades leading up to the Battle of Naboo until being discontinued during the Clone Wars."))
var:setRadarTrace("hwk290.png")
var:setRepairCrewCount(0)
var:setShields(45)
addRockets(var, true)
var:setWeaponStorage("Homing", 0)
var:setWeaponStorage("Mine", 4)
var:setWeaponTubeExclusiveFor(0, "Mine"):setTubeDirection(0, 180)
var:copy(" "..var:getName()):setType("ship") -- CpuShip variant


--[[Player Transport, 4-person turreted, single shielded, mostly classes that start with 'Y'--]]

template = createTemplate(4, 1, 3)
template:setClass("Freighter", "Light transport")
template:setCombatManeuver(250, 150)
template:setDockClasses("Starfighter", "Shuttle")

var = template:copy("Y2K")
var:setRadarTrace("y2k.png")
var:setDescription(_([[Y2K Peregerine Class Light Freighter. Designed and put into production a few years after the end of the Clone Wars and the formation of the Galactic Empire, Corellian Engineering Corporation sought to create a smaller-scale version of their venerable YT-series of freighters, which were beginning to show their age. Applying lessons learned over the decades, the design team for the Y2K-series strove to design a courier-vessel, opting to skimp on the frills and focus on functionality.]]))
var:setRepairCrewCount(0)
var:setExternalDockClasses("Starfighter","Freighter","Shuttle", "Cruiser")
var:copy(" "..var:getName()):setType("ship") -- CpuShip variant

var = template:copy("YT-1300")
var:setRadarTrace("yt1300.png")
var:setDescription(_([[The YT-1300 light freighter, also known as the YT-1300 Corellian freighter, was a type of light freighter manufactured by the Corellian Engineering Corporation that saw operation in the galaxy during the final days of the Galactic Republic and the reign of the Galactic Empire. By the year 0 BBY, it was considered an outdated model.]]))
var:setRepairCrewCount(0)
var:setTubes(1, 10.0)
var:setTubeDirection(0, 180)
var:setWeaponStorage("HVLI", 1)
var:setExternalDockClasses("Starfighter","Freighter","Shuttle", "Cruiser")
var:copy(" "..var:getName()):setType("ship") -- CpuShip variant

var = template:copy("YT-2000")
var:setRadarTrace("yt2000.png")
var:setDescription(_([[The YT-2000 transport was designed to be a direct improvement over the YT-1300, but it only saw a limited production run. Its basic design was similar to the YT-1930 with its centrally-placed cockpit and symmetrical design, while the rest of the ship returned to the saucer-like design of the YT-1300.]]))
var:setRepairCrewCount(0)
var:setBeam(2, 30, 0, 1200, 6.0, 6)
var:setExternalDockClasses("Starfighter","Freighter","Shuttle", "Cruiser")
var:copy(" "..var:getName()):setType("ship") -- CpuShip variant

var = template:copy("YT-2400")
var:setRadarTrace("yt2400b.png")
var:setDescription(_([[The YT-2400 light freighter, also known as the YT-2400 transport, was a class of YT-series light freighter. During the Imperial Era, this model of freighter was used by both the Galactic Empire and the Alliance to Restore the Republic. The YT-2400 also saw use under cargo haulers and pirates.]]))
var:setRepairCrewCount(1)
addRockets(var, false)
var:setExternalDockClasses("Starfighter","Freighter","Shuttle", "Cruiser")
var:copy(" "..var:getName()):setType("ship") -- CpuShip variant

var = template:copy("YV-330")
var:setRadarTrace("yv330.png")
var:setDescription(_([[The YV-330 light freighter was a YV series light freighter produced by the Corellian Engineering Corporation. It was 26 meters long, and its standard armament was a twin laser cannon turret mounted beneath the cockpit. YV-330 freighters were often used by smugglers, and modified with heavier weaponry.]]))
var:setRepairCrewCount(0)
var:setSpeed(55, 8, 12)
var:setShields(100, 50)
addRockets(var, false)
var:setExternalDockClasses("Starfighter","Freighter","Shuttle", "Cruiser")
var:copy(" "..var:getName()):setType("ship") -- CpuShip variant

var = template:copy("VCX-100")
var:setRadarTrace("vcx100.png")
var:setDescription(_([[The VCX-100 light freighter was one of the Corellian Engineering Corporation's freighter designs.]]))
var:setRepairCrewCount(0)
var:setExternalDockClasses("Starfighter","Freighter","Shuttle", "Cruiser")
var:copy(" "..var:getName()):setType("ship") -- CpuShip variant

var = template:copy("G9")
var:setRadarTrace("g9.png")
var:setDescription(_([[The G9 Rigger-class light freighter was a model of freighter manufactured by the Corellian Engineering Corporation and used during the Clone Wars. Its only weapons were small blaster cannons attached to the wings and top of the freighter.]]))
var:setRepairCrewCount(0)
var:setBeam(0, 10, -90, 1200.0, 6.0, 6)
var:setBeam(1, 0, 0, 0, 6.0, 6)
var:setBeamWeaponTurret(0, 300, -90, 5)
var:setExternalDockClasses("Starfighter","Freighter","Shuttle", "Cruiser")
var:copy(" "..var:getName()):setType("ship") -- CpuShip variant

--[[Player Transport, 4-person without turret, two shields ]]

template = createTemplate(4, 2, 0)
template:setClass("Freighter", "Light transport")
template:setCombatManeuver(250, 150)
template:setDockClasses("Starfighter", "Shuttle")

var = template:copy("Gozanti")
var:setModel("MultiGunCorvette"..color_player)
var:setDescription(_([[The Imperial Gozanti-class cruiser, also referred to as the Imperial Gozanti-class TIE carrier and known generally as the Imperial freighter, was a variant of the standard Gozanti-class cruiser used by the Galactic Empire and later by sympathizers of the First Order.]]))
var:setRadarTrace("gozanti.png")
var:setRepairCrewCount(2)
var:setRepairDocked(true)
var:setSharesEnergyWithDocked(false)
var:setRestocksMissilesDocked("all")
var:setExternalDockClasses("Starfighter","Freighter","Shuttle", "Cruiser")
var:copy(" "..var:getName()):setType("ship") -- CpuShip variant


var = var:copy("Gozanti C-ROC")
--                 Arc, Dir, Range, CycleTime, Dmg
var:setBeam(0, 10, 0, 800.0, 6.0, 6)
var:setBeam(1, 30, 0, 1200.0, 8.0, 12)
--								Arc, Dir, Rotate speed
var:setBeamWeaponTurret(0, 360, 0, 5)
var:setBeamWeaponTurret(1, 0, 0, 5)
addRockets(var, false)
var:setRepairCrewCount(2)
var:setExternalDockClasses("Starfighter","Freighter","Shuttle", "Cruiser")
var:copy(" "..var:getName()):setType("ship") -- CpuShip variant


--[[Player Transport, 5 person crew, more specialiced, no default turret--]]

template = createTemplate(5, 2, 0)
template:setClass("Freighter", "Light transport")
template:setCombatManeuver(250, 150)
template:setDockClasses("Starfighter", "Shuttle")

var = template:copy("Allanar N3")
var:setRadarTrace("n3.png")
var:setDescription(_([[The Allanar N3 light freighter was a model of light freighter that saw use during the era of the Galactic Empire. The ship, which typically required a crew of 4 to 7, boasted a hyperdrive system, three sublight engines, and multiple forward facing laser cannons.]]))
var:setRepairCrewCount(0)
addRockets(var, false)
var:setExternalDockClasses("Starfighter","Freighter","Shuttle", "Cruiser")
var:copy(" "..var:getName()):setType("ship") -- CpuShip variant

var = template:copy("Lambda T-4a")
var:setRadarTrace("lambda.png")
template:setClass("Shuttle", "Light transport")
var:setDescription(_([[The Lambda-class T-4a shuttle, also known as the Imperial Shuttle, was a standard light utility craft in common with the Imperial military as a transport for troops and high-ranking individuals.]]))
var:setRepairCrewCount(0)
var:setBeam(0, 30, 0, 1200.0, 6.0, 6)
var:setBeam(1, 10, 0, 1200.0, 6.0, 6)
var:setBeamWeaponTurret(1, 120, 0, 5)
var:setExternalDockClasses("Starfighter","Freighter","Shuttle", "Cruiser")
var:copy(" "..var:getName()):setType("ship") -- CpuShip variant

-- GM: Instruction:
-- they can extract a rear-blaster:
-- Set range of beam 3 to 800

var = template:copy("YV-929")
var:setRadarTrace("yv929.png")
var:setDescription(_([[The YV-929 armed freighter was a 22-meter-long light freighter produced by Corellian Engineering Corporation. It used the same forward cockpit structure as the much larger YV-100 light freighter. 
Unlike most CEC freighters, which came off the assembly lines with minimal weaponry, the YV-929 was designed from the start to be heavily armed for defense against pirate and Rebel raids, and also featured very strong shields.]]))
var:setRepairCrewCount(0)
var:setBeam(0, 50, 0, 1200.0, 6.0, 6)
var:setBeam(1, 50, 0, 900.0, 4.0, 4)
var:setTubes(2, 15.0)
var:setTubeDirection(1, 180)
var:setWeaponStorage("Homing", 20)
var:setAutoMissileReload(false)
--	            speed, turn, accel, rev-speed, rev-accel
var:setSpeed(55, 8, 12)
var:setCanCombatManeuver(false)
var:setExternalDockClasses("Starfighter","Freighter","Shuttle", "Cruiser")
var:copy(" "..var:getName()):setType("ship") -- CpuShip variant

var = template:copy("Gozanti Mk Ic")
var:setRadarTrace("gozanti.png")
var:setModel("MultiGunCorvette"..color_player)
var:setDescription(_([[The Imperial Gozanti-class cruiser, also referred to as the Imperial Gozanti-class TIE carrier and known generally as the Imperial freighter, was a variant of the standard Gozanti-class cruiser used by the Galactic Empire and later by sympathizers of the First Order.]]))
var:setJumpDrive(true)
var:setRepairCrewCount(2)
var:setRepairDocked(true)
var:setSharesEnergyWithDocked(false)
var:setRestocksMissilesDocked("all")
var:setExternalDockClasses("Starfighter", "Freighter", "Shuttle", "Cruiser")


var = template:copy("CX-9")
var:setDescription(_("A modular cargo shuttle from the Loronar shipyards, originally designed for automated cargo runs in mining colonies. After the Empire shut down the production, many of these CX models were salvaged or sold to pirates."))
var:setRadarTrace("cx8.png")
var:setRepairCrewCount(0)
var:setSpeed(55, 7, 12)
var:setExternalDockClasses("Starfighter","Freighter","Shuttle", "Cruiser")
var:copy(" "..var:getName()):setType("ship") -- CpuShip variant


--[[Heavy Freighter]]
template = ShipTemplate()
template:setClass("Freighter", "Medium Transport")
template:setModel("transport_4_2")
template:setType("playership")
template:setHull(200)
--	            speed, turn, accel, rev-speed, rev-accel
template:setSpeed(50, 5, 7)
template:setCanCombatManeuver(false)
template:setDockClasses("Starfighter")
template:setDockClasses("Light transport")
addSystemsTransport(template)

var = template:copy("GR-75")
var:setDescription(_([[The GR-75 medium transport, sometimes referred to as the Gallofree transport, was a transport designed and constructed by Gallofree Yards, Inc.. They were lightly armed with a clamshell-like hull to protect the cargo pods it carried. They could not reach anymore than 650 kilometers per hour.]]))
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
var:setExternalDockClasses("Starfighter","Freighter","Shuttle", "Cruiser")
var:copy(" "..var:getName()):setType("ship") -- CpuShip variant

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
var:setExternalDockClasses("Starfighter","Freighter","Shuttle", "Cruiser")
var:copy(" "..var:getName()):setType("ship") -- CpuShip variant

--[[ Test default templates
template = createTemplate(1, 2, 0)
template:setName("Default Fighter")
template:setRadarTrace("xwing.png")

template = createTemplate(2, 2, 0)
template:setName("Default Heavy Fighter")
template:setRadarTrace("uwing.png")

template = createTemplate(2, 2, 3)
template:setName("Default Turret Fighter")
template:setRadarTrace("ywing.png")

template = createTemplate(3, 1, 0)
template:setName("Default light transport")
template:setRadarTrace("a24.png")

template = createTemplate(4, 2, 0)
template:setName("Default transport")
template:setRadarTrace("yt2400b.png")

template = createTemplate(4, 2, 2)
template:setName("Default turret transport")
template:setRadarTrace("yt2400b.png")

template = createTemplate(5, 2, 0)
template:setName("Default medium transport")
template:setRadarTrace("yt2000.png")

template = createTemplate(6, 2, 0)
template:setName("Default heavy transport")
template:setRadarTrace("action4.png")

template = createTemplate(6, 2, 1)
template:setName("Default turret heavy transport")
template:setRadarTrace("action4.png")
--]]
