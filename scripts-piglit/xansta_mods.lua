require("script_formation.lua")
require("script_hangar.lua")

function init_constants_xansta()
	-- called during or instead of setConstants()
	missile_types = {'Homing', 'Nuke', 'Mine', 'EMP', 'HVLI'}
	--Ship Template Name List
	stl = {
		["Human Navy"]= {
			["MU52 Hornet"]= 5,
			["WX-Lindworm"]= 7,
			["Adder MK6"]= 8,
			["Phobos M3"]= 15, --15 as long ai can't use mines
			["Piranha M5"]= 17,
			["Nirvana R5M"]= 18,
			["Storm"]= 22,
		},
		["Mining Corporation"]= {
			["Yellow Hornet"]= 5,
			["Yellow Lindworm"]= 7,
			["Yellow Adder MK5"]= 8,
			["Yellow Adder MK4"]= 6,

			["Phobos Y2"]= 16,	
			["Piranha F12"]= 15,
			["Nirvana R5A"]= 17,
		},
		["Blue Star Cartell"]= {
			["Blue Hornet"]= 5,
			["Blue Lindworm"]= 7,
			["Blue Adder MK5"]= 7,
			["Blue Adder MK4"]= 6,

			["Phobos Vanguard"]= 16, 
			["Phobos Rear-Guard"]= 15, -- 15 as long ai can't use mines
			["Piranha Vanguard"]= 17,
			["Piranha Rear-Guard"]= 15, -- 15 as long ai can't use mines
			["Nirvana Vanguard"]= 17,
			["Nirvana Rear-Guard"]= 17,
		},
		["Criminals"]= {
			["Red Hornet"]= 5,
			["Red Lindworm"]= 7,
			["Red Adder MK5"]= 7,
			["Red Adder MK4"]= 6,

			["Phobos Firehawk"]= 16,
			["Piranha F12.M"]= 17,
			["Nirvana Thunder Child"]= 18,
			["Lightning Storm"]= 22,
		},
		["Ghosts"]= {
			["Advanced Hornet"]= 5,
			["Advanced Lindworm"]= 7,
			["Advanced Adder MK5"]= 7,
			["Advanced Adder MK4"]= 6,

			["Phobos G4"]= 17,
			["Piranha G4"]= 16,
			["Nirvana 0x81"]= 19,
			["Solar Storm"]= 22,
		},
		["Kraylor"]= {
			["Drone"]= 5,
			["Rockbreaker"]= 22,
			["Rockbreaker Merchant"]= 25,
			["Rockbreaker Murderer"]= 26,
			["Rockbreaker Mercenary"]= 28,
			["Rockbreaker Marauder"]= 30,
			["Rockbreaker Military"]= 32,
			["Spinebreaker"]= 24,
			["Deathbringer"]= 47,
			["Painbringer"]= 50,
			["Doombringer"]= 65,
		},
		["Exuari"]= {
			["Dagger"]= 5,
			["Blade"]= 6,
			["Gunner"]= 7,
			["Shooter"]= 8,
			["Jagger"]= 9,
			["Racer"]= 15,
			["Hunter"]= 18,
			["Strike"]= 20,
			["Dash"]= 22,
			["Guard"]= 26,
			["Sentinel"]= 26,
			["Warden"]= 21,
			["Flash"]= 17,
			["Ranger"]= 17,
			["Buster"]= 17,
			["Ryder"]= 65,
			["Fortress"]= 260,
		},
		["Ktlitans"]= {
			["Ktlitan Drone"]= 5,	
			["Ktlitan Worker"]= 15,	
			["Ktlitan Fighter"]= 22,	
			["Ktlitan Scout"]= 30,	
			["Ktlitan Breaker"]= 45,	
			["Ktlitan Feeder"]= 60,	
			["Ktlitan Destroyer"]= 75,
			["Ktlitan Queen"]= 100,	
		},
		["other"]= {
			["MT52 Hornet"]= 5,
			["WX-Lindworm"]= 7,
			["Adder MK5"]= 7,
			["Adder MK4"]= 6,
			["Phobos T3"]= 15,
			["Piranha F8"]= 15,
			["Nirvana R5"]= 19,
		}
	}
	stln = {}
	stnl = {}
	stsl = {}
	for faction, list in pairs(stl) do
			stln[faction] = {}
			for key, value in pairs(list) do
				table.insert(stln[faction], key)
				table.insert(stnl, key)
				table.insert(stsl, value)
			end
	end

	--Player Ship Beams
	psb = {}
	psb["MP52 Hornet"] = 2
	psb["Adder MK7"] = 4
	psb["Phobos M3P"] = 2
	psb["Flavia P.Falcon"] = 2
	psb["Atlantis"] = 2
	psb["Striker"] = 2
	psb["ZX-Lindworm"] = 1
	psb["Citadel"] = 12
	psb["Repulse"] = 2
	psb["Benedict"] = 2
	psb["Kiriya"] = 2
	psb["Nautilus"] = 2
	psb["Hathcock"] = 4
	psb["Piranha M5P"] = 0
	psb["Crucible"] = 2
	psb["Maverick"] = 6
	-- square grid deployment
	fleetPosDelta1x = {0,1,0,-1, 0,1,-1, 1,-1,2,0,-2, 0,2,-2, 2,-2,2, 2,-2,-2,1,-1, 1,-1}
	fleetPosDelta1y = {0,0,1, 0,-1,1,-1,-1, 1,0,2, 0,-2,2,-2,-2, 2,1,-1, 1,-1,2, 2,-2,-2}
	-- rough hexagonal deployment
	fleetPosDelta2x = {0,2,-2,1,-1, 1, 1,4,-4,0, 0,2,-2,-2, 2,3,-3, 3,-3,6,-6,1,-1, 1,-1,3,-3, 3,-3,4,-4, 4,-4,5,-5, 5,-5}
	fleetPosDelta2y = {0,0, 0,1, 1,-1,-1,0, 0,2,-2,2,-2, 2,-2,1,-1,-1, 1,0, 0,3, 3,-3,-3,3,-3,-3, 3,2,-2,-2, 2,1,-1,-1, 1}
	--list of goods available to buy, sell or trade 
	goodsList = {	{"food",0},
					{"medicine",0},
					{"nickel",0},
					{"platinum",0},
					{"gold",0},
					{"dilithium",0},
					{"tritanium",0},
					{"luxury",0},
					{"cobalt",0},
					{"impulse",0},
					{"warp",0},
					{"shield",0},
					{"tractor",0},
					{"repulsor",0},
					{"beam",0},
					{"optic",0},
					{"robotic",0},
					{"filament",0},
					{"transporter",0},
					{"sensor",0},
					{"communication",0},
					{"autodoc",0},
					{"lifter",0},
					{"android",0},
					{"nanites",0},
					{"software",0},
					{"circuit",0},
					{"battery",0}	}
	commonGoods = {"food","medicine","nickel","platinum","gold","dilithium","tritanium","luxury","cobalt","impulse","warp","shield","tractor","repulsor","beam","optic","robotic","filament","transporter","sensor","communication","autodoc","lifter","android","nanites","software","circuit","battery"}
	componentGoods = {"impulse","warp","shield","tractor","repulsor","beam","optic","robotic","filament","transporter","sensor","communication","autodoc","lifter","android","nanites","software","circuit","battery"}
	mineralGoods = {"nickel","platinum","gold","dilithium","tritanium","cobalt"}
	playerShipNamesForMP52Hornet = {"Dragonfly","Scarab","Mantis","Yellow Jacket","Jimminy","Flik","Thorny","Buzz"}
	playerShipNamesForPiranha = {"Razor","Biter","Ripper","Voracious","Carnivorous","Characid","Vulture","Predator"}
	playerShipNamesForFlaviaPFalcon = {"Ladyhawke","Hunter","Seeker","Gyrefalcon","Kestrel","Magpie","Bandit","Buccaneer"}
	playerShipNamesForPhobosM3P = {"Blinder","Shadow","Distortion","Diemos","Ganymede","Castillo","Thebe","Retrograde"}
	playerShipNamesForAtlantis = {"Excaliber","Thrasher","Punisher","Vorpal","Protang","Drummond","Parchim","Coronado"}
	playerShipNamesForCruiser = {"Excelsior","Velociraptor","Thunder","Kona","Encounter","Perth","Aspern","Panther"}
	playerShipNamesForMissileCruiser = {"Projectus","Hurlmeister","Flinger","Ovod","Amatola","Nakhimov","Antigone"}
	playerShipNamesForFighter = {"Buzzer","Flitter","Zippiticus","Hopper","Molt","Stinger","Stripe"}
	playerShipNamesForBenedict = {"Elizabeth","Ford","Vikramaditya","Liaoning","Avenger","Naruebet","Washington","Lincoln","Garibaldi","Eisenhower"}
	playerShipNamesForKiriya = {"Cavour","Reagan","Gaulle","Paulo","Truman","Stennis","Kuznetsov","Roosevelt","Vinson","Old Salt"}
	playerShipNamesForStriker = {"Sparrow","Sizzle","Squawk","Crow","Phoenix","Snowbird","Hawk"}
	playerShipNamesForLindworm = {"Seagull","Catapult","Blowhard","Flapper","Nixie","Pixie","Tinkerbell"}
	playerShipNamesForRepulse = {"Fiddler","Brinks","Loomis","Mowag","Patria","Pandur","Terrex","Komatsu","Eitan"}
	playerShipNamesForEnder = {"Mongo","Godzilla","Leviathan","Kraken","Jupiter","Saturn"}
	playerShipNamesForNautilus = {"October", "Abdiel", "Manxman", "Newcon", "Nusret", "Pluton", "Amiral", "Amur", "Heinkel", "Dornier"}
	playerShipNamesForHathcock = {"Hayha", "Waldron", "Plunkett", "Mawhinney", "Furlong", "Zaytsev", "Pavlichenko", "Pegahmagabow", "Fett", "Hawkeye", "Hanzo"}
	playerShipNamesForAtlantisII = {"Spyder", "Shelob", "Tarantula", "Aragog", "Charlotte"}
	playerShipNamesForProtoAtlantis = {"Narsil", "Blade", "Decapitator", "Trisect", "Sabre"}
	playerShipNamesForMaverick = {"Angel", "Thunderbird", "Roaster", "Magnifier", "Hedge"}
	playerShipNamesForCrucible = {"Sling", "Stark", "Torrid", "Kicker", "Flummox"}
	playerShipNamesForSurkov = {"Sting", "Sneak", "Bingo", "Thrill", "Vivisect"}
	playerShipNamesForStricken = {"Blazon", "Streaker", "Pinto", "Spear", "Javelin"}
	playerShipNamesForAtlantisII = {"Spyder", "Shelob", "Tarantula", "Aragog", "Charlotte"}
	playerShipNamesForRedhook = {"Headhunter", "Thud", "Troll", "Scalper", "Shark"}
	playerShipNamesForLeftovers = {"Foregone","Righteous","Masher"}
	characterNames = {"Frank Brown",
				  "Joyce Miller",
				  "Harry Jones",
				  "Emma Davis",
				  "Zhang Wei Chen",
				  "Yu Yan Li",
				  "Li Wei Wang",
				  "Li Na Zhao",
				  "Sai Laghari",
				  "Anaya Khatri",
				  "Vihaan Reddy",
				  "Trisha Varma",
				  "Henry Gunawan",
				  "Putri Febrian",
				  "Stanley Hartono",
				  "Citra Mulyadi",
				  "Bashir Pitafi",
				  "Hania Kohli",
				  "Gohar Lehri",
				  "Sohelia Lau",
				  "Gabriel Santos",
				  "Ana Melo",
				  "Lucas Barbosa",
				  "Juliana Rocha",
				  "Habib Oni",
				  "Chinara Adebayo",
				  "Tanimu Ali",
				  "Naija Bello",
				  "Shamim Khan",
				  "Barsha Tripura",
				  "Sumon Das",
				  "Farah Munsi",
				  "Denis Popov",
				  "Pasha Sokolov",
				  "Burian Ivanov",
				  "Radka Vasiliev",
				  "Jose Hernandez",
				  "Victoria Garcia",
				  "Miguel Lopez",
				  "Renata Rodriguez"}
	hitZonePermutations = {
		{"warp","beamweapons","reactor"},
		{"jumpdrive","beamweapons","reactor"},
		{"impulse","beamweapons","reactor"},
		{"warp","missilesystem","reactor"},
		{"jumpdrive","missilesystem","reactor"},
		{"impulse","missilesystem","reactor"},
		{"warp","beamweapons","maneuver"},
		{"jumpdrive","beamweapons","maneuver"},
		{"impulse","beamweapons","maneuver"},
		{"warp","missilesystem","maneuver"},
		{"jumpdrive","missilesystem","maneuver"},
		{"impulse","missilesystem","maneuver"},
		{"warp","beamweapons","frontshield"},
		{"jumpdrive","beamweapons","frontshield"},
		{"impulse","beamweapons","frontshield"},
		{"warp","missilesystem","frontshield"},
		{"jumpdrive","missilesystem","frontshield"},
		{"impulse","missilesystem","frontshield"},
		{"warp","beamweapons","rearshield"},
		{"jumpdrive","beamweapons","rearshield"},
		{"impulse","beamweapons","rearshield"},
		{"warp","missilesystem","rearshield"},
		{"jumpdrive","missilesystem","rearshield"},
		{"impulse","missilesystem","rearshield"},
		{"warp","reactor","maneuver"},
		{"jumpdrive","reactor","maneuver"},
		{"impulse","reactor","maneuver"},
		{"warp","reactor","frontshield"},
		{"jumpdrive","reactor","frontshield"},
		{"impulse","reactor","frontshield"},
		{"warp","reactor","rearshield"},
		{"jumpdrive","reactor","rearshield"},
		{"impulse","reactor","rearshield"},
		{"warp","maneuver","frontshield"},
		{"jumpdrive","maneuver","frontshield"},
		{"impulse","maneuver","frontshield"},
		{"warp","maneuver","rearshield"},
		{"jumpdrive","maneuver","rearshield"},
		{"impulse","maneuver","rearshield"},
		{"beamweapons","beamweapons","maneuver"},
		{"missilesystem","beamweapons","maneuver"},
		{"beamweapons","beamweapons","frontshield"},
		{"missilesystem","beamweapons","frontshield"},
		{"beamweapons","beamweapons","rearshield"},
		{"missilesystem","beamweapons","rearshield"},
		{"beamweapons","maneuver","frontshield"},
		{"missilesystem","maneuver","frontshield"},
		{"beamweapons","maneuver","rearshield"},
		{"missilesystem","maneuver","rearshield"},
		{"reactor","maneuver","frontshield"},
		{"reactor","maneuver","rearshield"}
	}

end

function modify_player_ships(pobj)
	--called during setPlayers()
	--TODO in each setPlayers() function: replace pobj.nameAssigned with modsAssigned
	if not pobj.modsAssigned then
		pobj.modsAssigned = true
		local tempPlayerType = pobj:getTypeName()
		if tempPlayerType == "MP52 Hornet" then
			if #playerShipNamesForMP52Hornet > 0 and not pobj.nameAssigned then
				pobj.nameAssigned = true
				local ni = math.random(1,#playerShipNamesForMP52Hornet)
				pobj:setCallSign(playerShipNamesForMP52Hornet[ni])
				table.remove(playerShipNamesForMP52Hornet,ni)
			end
			pobj.shipScore = 7
			pobj.maxCargo = 3
			pobj:setAutoCoolant(true)
			pobj:commandSetAutoRepair(true)
			pobj.autoCoolant = true
--			pobj:setWarpDrive(true)
		elseif tempPlayerType == "ZX-Lindworm" then
			if #playerShipNamesForLindworm > 0 and not pobj.nameAssigned then
				pobj.nameAssigned = true
				ni = math.random(1,#playerShipNamesForLindworm)
				pobj:setCallSign(playerShipNamesForLindworm[ni])
				table.remove(playerShipNamesForLindworm,ni)
			end
			pobj.shipScore = 8
			pobj.maxCargo = 3
			pobj:setAutoCoolant(true)
			pobj:commandSetAutoRepair(true)
			pobj.autoCoolant = true
--			pobj:setWarpDrive(true)
		elseif tempPlayerType == "Adder MK7" then
			if #playerShipNamesForStriker > 0 and not pobj.nameAssigned then
				pobj.nameAssigned = true
				ni = math.random(1,#playerShipNamesForStriker)
				pobj:setCallSign(playerShipNamesForStriker[ni])
				table.remove(playerShipNamesForStriker,ni)
			end
			pobj.shipScore = 8
			pobj.maxCargo = 4
			pobj:setAutoCoolant(true)
			pobj:commandSetAutoRepair(true)
			pobj.autoCoolant = true
--			pobj:setJumpDrive(true)
--			pobj:setJumpDriveRange(3000,40000)
		elseif tempPlayerType == "Phobos M3P" then
			if #playerShipNamesForPhobosM3P > 0 and not pobj.nameAssigned then
				pobj.nameAssigned = true
				ni = math.random(1,#playerShipNamesForPhobosM3P)
				pobj:setCallSign(playerShipNamesForPhobosM3P[ni])
				table.remove(playerShipNamesForPhobosM3P,ni)
			end
			pobj.shipScore = 19
			pobj.maxCargo = 10
--			pobj:setWarpDrive(true)
		elseif tempPlayerType == "Hathcock" then
			if #playerShipNamesForHathcock > 0 and not pobj.nameAssigned then
				pobj.nameAssigned = true
				ni = math.random(1,#playerShipNamesForHathcock)
				pobj:setCallSign(playerShipNamesForHathcock[ni])
				table.remove(playerShipNamesForHathcock,ni)
			end
			pobj.shipScore = 30
			pobj.maxCargo = 6
		elseif tempPlayerType == "Piranha M5P" then
			if #playerShipNamesForPiranha > 0 and not pobj.nameAssigned then
				pobj.nameAssigned = true
				ni = math.random(1,#playerShipNamesForPiranha)
				pobj:setCallSign(playerShipNamesForPiranha[ni])
				table.remove(playerShipNamesForPiranha,ni)
			end
			pobj.shipScore = 16
			pobj.maxCargo = 8
		elseif tempPlayerType == "Flavia P.Falcon" then
			if #playerShipNamesForFlaviaPFalcon > 0 and not pobj.nameAssigned then
				pobj.nameAssigned = true
				ni = math.random(1,#playerShipNamesForFlaviaPFalcon)
				pobj:setCallSign(playerShipNamesForFlaviaPFalcon[ni])
				table.remove(playerShipNamesForFlaviaPFalcon,ni)
			end
			pobj.shipScore = 13
			pobj.maxCargo = 15
		elseif tempPlayerType == "Repulse" then
			if #playerShipNamesForRepulse > 0 and not pobj.nameAssigned then
				pobj.nameAssigned = true
				ni = math.random(1,#playerShipNamesForRepulse)
				pobj:setCallSign(playerShipNamesForRepulse[ni])
				table.remove(playerShipNamesForRepulse,ni)
			end
			pobj.shipScore = 14
			pobj.maxCargo = 12
		elseif tempPlayerType == "Nautilus" then
			if #playerShipNamesForNautilus > 0 and not pobj.nameAssigned then
				pobj.nameAssigned = true
				ni = math.random(1,#playerShipNamesForNautilus)
				pobj:setCallSign(playerShipNamesForNautilus[ni])
				table.remove(playerShipNamesForNautilus,ni)
			end
			pobj.shipScore = 12
			pobj.maxCargo = 7
		elseif tempPlayerType == "Atlantis" then
			if #playerShipNamesForAtlantis > 0 and not pobj.nameAssigned then
				pobj.nameAssigned = true
				ni = math.random(1,#playerShipNamesForAtlantis)
				pobj:setCallSign(playerShipNamesForAtlantis[ni])
				table.remove(playerShipNamesForAtlantis,ni)
			end
			pobj.carrier = true
			pobj.shipScore = 52
			pobj.maxCargo = 6
		elseif tempPlayerType == "Maverick" then
			if #playerShipNamesForMaverick > 0 and not pobj.nameAssigned then
				pobj.nameAssigned = true
				ni = math.random(1,#playerShipNamesForMaverick)
				pobj:setCallSign(playerShipNamesForMaverick[ni])
				table.remove(playerShipNamesForMaverick,ni)
			end
			pobj.carrier = true
			pobj.shipScore = 52
			pobj.maxCargo = 6
		elseif tempPlayerType == "Crucible" then
			if #playerShipNamesForCrucible > 0 and not pobj.nameAssigned then
				pobj.nameAssigned = true
				ni = math.random(1,#playerShipNamesForCrucible)
				pobj:setCallSign(playerShipNamesForCrucible[ni])
				table.remove(playerShipNamesForCrucible,ni)
			end
			pobj.carrier = true
			pobj.shipScore = 52
			pobj.maxCargo = 6
		elseif tempPlayerType == "Benedict" then
			if #playerShipNamesForBenedict > 0 and not pobj.nameAssigned then
				pobj.nameAssigned = true
				ni = math.random(1,#playerShipNamesForBenedict)
				pobj:setCallSign(playerShipNamesForBenedict[ni])
				table.remove(playerShipNamesForBenedict,ni)
			end
			pobj.carrier = true
			pobj.shipScore = 10
			pobj.maxCargo = 9
		elseif tempPlayerType == "Kiriya" then
			if #playerShipNamesForKiriya > 0 and not pobj.nameAssigned then
				pobj.nameAssigned = true
				ni = math.random(1,#playerShipNamesForKiriya)
				pobj:setCallSign(playerShipNamesForKiriya[ni])
				table.remove(playerShipNamesForKiriya,ni)
			end
			pobj.carrier = true
			pobj.shipScore = 10
			pobj.maxCargo = 9
		elseif tempPlayerType == "Ender" then
			if #playerShipNamesForEnder > 0 and not pobj.nameAssigned then
				pobj.nameAssigned = true
				ni = math.random(1,#playerShipNamesForEnder)
				pobj:setCallSign(playerShipNamesForEnder[ni])
				table.remove(playerShipNamesForEnder,ni)
			end
			pobj.shipScore = 100
			pobj.maxCargo = 20
		else
			if #playerShipNamesForLeftovers > 0 and not pobj.nameAssigned then
				pobj.nameAssigned = true
				ni = math.random(1,#playerShipNamesForLeftovers)
				pobj:setCallSign(playerShipNamesForLeftovers[ni])
				table.remove(playerShipNamesForLeftovers,ni)
			end
			pobj.shipScore = 24
			pobj.maxCargo = 5
--			pobj:setWarpDrive(true)
		end
	end
end


function spawn_enemies_faction(xOrigin, yOrigin, enemyStrength, enemyFaction)
	-- called in spawnEnemies()

	local enemyFactionScoreList = stl[enemyFaction]
	local enemyFactionNameList = stln[enemyFaction]
	if stl[enemyFaction] == nil then
		enemyFactionScoreList = stl["other"]
		enemyFactionNameList = stln["other"]
	end

	local totalStrength = 0
	local enemyNameList = {}
	local enemyList = {}

	local enemyPosition = 0
	local sp = irandom(300,500)			--random spacing of spawned group
	local deployConfig = random(1,100)	--randomly choose between squarish formation and hexagonish formation

	local formationLeader = nil
	local formationSecond = nil
	local smallFormations = {}

	-- Reminder: stsl and stnl are ship template score and name list
	while enemyStrength > 0 do
		local shipTemplateType = enemyFactionNameList[ irandom(1,#enemyFactionNameList) ]
		while enemyFactionScoreList[shipTemplateType] > enemyStrength * 1.1 + 5 do
			shipTemplateType = enemyFactionNameList[ irandom(1,#enemyFactionNameList) ]
		end		
		enemyStrength = enemyStrength - enemyFactionScoreList[shipTemplateType]
		table.insert(enemyNameList, shipTemplateType)
		if enemyFactionScoreList[shipTemplateType] ~= nil then
			totalStrength = totalStrength + enemyFactionScoreList[shipTemplateType]
		end
	end

	-- here other formation or spawn logic is possible. E.g. Hangar code
	for index,shipTemplateType in ipairs(enemyNameList) do
		local ship = CpuShip():setFaction(enemyFaction):setScannedByFaction(enemyFaction, true):setTemplate(shipTemplateType):orderRoaming()
		enemyPosition = enemyPosition + 1
		if deployConfig < 50 and enemyPosition <= #fleetPosDelta1x then
			ship:setPosition(xOrigin+fleetPosDelta1x[enemyPosition]*sp,yOrigin+fleetPosDelta1y[enemyPosition]*sp)
		elseif enemyPosition <= #fleetPosDelta2x then
			ship:setPosition(xOrigin+fleetPosDelta2x[enemyPosition]*sp,yOrigin+fleetPosDelta2y[enemyPosition]*sp)
		else
			ship:setPosition(xOrigin, yOrigin)
		end
		if enemyFaction == "Kraylor" then
			--kraylor formation
			formationLeader, formationSecond = script_formation.buildFormationIncremental(ship, enemyPosition, formationLeader, formationSecond)
		end
		if enemyFaction == "Exuari" then
			ship:setCommsScript("comms_exuari.lua")
			--TODO check if multiple onDamage/onDestruction are possible. If true, raise frenzy in combat, otherwise slowly lower
			--Update: no, it is not possible.
			if smallFormations[shipTemplateType] == nil then
				smallFormations[shipTemplateType] = {ship, nil, 1}
			else
				local pack = smallFormations[shipTemplateType]
				local leader = pack[1]
				local second = pack[2]
				local fidx = pack[3]
				fidx = fidx + 1
				leader, second = script_formation.buildFormationIncremental(ship, fidx, leader, second)
				smallFormations[shipTemplateType] = {leader, second, fidx}
			end
			if shipTemplateType == "Ryder" then
				local fighterTemplate = enemyFactionNameList[ irandom(1,5) ]
				script_hangar.create(ship, fighterTemplate, 3)
			elseif shipTemplateType == "Fortress" then
				local fighterTemplate = enemyFactionNameList[ irandom(1,5) ]
				script_hangar.create(ship, fighterTemplate, 3)
				fighterTemplate = enemyFactionNameList[ irandom(1,5) ]
				script_hangar.append(ship, fighterTemplate, 3)
			end
		else
			ship:setCommsScript(""):setCommsFunction(commsShip)
		end
		table.insert(enemyList, ship)
	end
	return enemyList, totalStrength
end

function enemyComms(comms_data)
	-- called intead enemyComms() of xanstas scenarios, as long it is deleted there.
	if comms_data.friendlyness > 50 then
		local faction = comms_target:getFaction()
		local taunt_option = "We will see to your destruction!"
		local taunt_success_reply = "Your bloodline will end here!"
		local taunt_failed_reply = "Your feeble threats are meaningless."
		if faction == "Kraylor" then
			setCommsMessage("Ktzzzsss.\nYou will DIEEee weaklingsss!");
			local kraylorTauntChoice = math.random(1,3)
			if kraylorTauntChoice == 1 then
				taunt_option = "We will destroy you"
				taunt_success_reply = "We think not. It is you who will experience destruction!"
			elseif kraylorTauntChoice == 2 then
				taunt_option = "You have no honor"
				taunt_success_reply = "Your insult has brought our wrath upon you. Prepare to die."
				taunt_failed_reply = "Your comments about honor have no meaning to us"
			else
				taunt_option = "We pity your pathetic race"
				taunt_success_reply = "Pathetic? You will regret your disparagement!"
				taunt_failed_reply = "We don't care what you think of us"
			end
		elseif faction == "Arlenians" then
			setCommsMessage("We wish you no harm, but will harm you if we must.\nEnd of transmission.");
		elseif faction == "Exuari" then
			setCommsMessage("Stay out of our way, or your death will amuse us extremely!");
		elseif faction == "Ghosts" then
			setCommsMessage("One zero one.\nNo binary communication detected.\nSwitching to universal speech.\nGenerating appropriate response for target from human language archives.\n:Do not cross us:\nCommunication halted.");
			taunt_option = "EXECUTE: SELFDESTRUCT"
			taunt_success_reply = "Rogue command received. Targeting source."
			taunt_failed_reply = "External command ignored."
		elseif faction == "Ktlitans" then
			setCommsMessage("The hive suffers no threats. Opposition to any of us is opposition to us all.\nStand down or prepare to donate your corpses toward our nutrition.");
			taunt_option = "<Transmit 'The Itsy-Bitsy Spider' on all wavelengths>"
			taunt_success_reply = "We do not need permission to pluck apart such an insignificant threat."
			taunt_failed_reply = "The hive has greater priorities than exterminating pests."
		else
			setCommsMessage("Mind your own business!");
		end
		comms_data.friendlyness = comms_data.friendlyness - random(0, 10)
		addCommsReply(taunt_option, function()
			if random(0, 100) < 30 then
				comms_target:orderAttack(comms_source)
				setCommsMessage(taunt_success_reply);
			else
				setCommsMessage(taunt_failed_reply);
			end
		end)
		return true
	end
	return false
end

