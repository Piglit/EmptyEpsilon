require("script_formation.lua")
require("script_hangar.lua")

function init_constants_xansta()
	-- called during or instead of setConstants()
	missile_types = {'Homing', 'Nuke', 'Mine', 'EMP', 'HVLI'}
	--Ship Template Name List
	--every faction must have at least one ship with value 5 or lower to prevent endless loops
	stl = {
		["Human Navy"]= {
			["MU52 Hornet"]= 5,
			["WX-Lindworm"]= 7,
			["Adder MK6"]= 8,
			["Phobos M3"]= 15, --15 as long ai can't use mines
			["Piranha M5"]= 17,
			["Nirvana R5A"]= 18,
			["Storm"]= 22,
		},
		["Mining Corporation"]= {
			["Yellow Hornet"]= 5,
			["Yellow Lindworm"]= 7,
			["Yellow Adder MK5"]= 8,
			["Yellow Adder MK4"]= 6,

			["Phobos T3"]= 16,	
			["Piranha F12"]= 15,
			["Nirvana R3"]= 17,
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
	stl["Interplanetary Union"] = stl["Mining Corporation"]
	stl["Arlenians"] = stl["Blue Star Cartell"]
	stln = {}
	stnl = {}
	stsl = {}
	ship_template = {}
	for faction, list in pairs(stl) do
			stln[faction] = {}
			for key, value in pairs(list) do
				table.insert(stln[faction], key)
				table.insert(stnl, key)
				table.insert(stsl, value)
				ship_template[key] = {strength = value}
			end
	end

	--Player Ship Beams
	psb = {}
	psb["MP52 Hornet"] = 2
	psb["MP56 Bumblebee"] = 2
	psb["MP58 Mole"] = 2
	psb["Adder MK7"] = 4
	psb["Phobos M3P"] = 2
	psb["Flavia P.Falcon"] = 2
	psb["Atlantis"] = 2
	psb["Poseidon"] = 2
	psb["Neptune"] = 0
	psb["Striker"] = 2
	psb["ZX-Lindworm"] = 1
	psb["Peluda"] = 0
	psb["Drac"] = 0
	psb["Cuelebre"] = 0
	psb["Bashe"] = 0
	psb["Ryu"] = 0
	psb["Zomok"] = 0
	psb["Citadel"] = 12
	psb["Repulse"] = 2
	psb["Benedict"] = 2
	psb["Kiriya"] = 2
	psb["Nautilus"] = 2
	psb["Hathcock"] = 4
	psb["Anvil"] = 4
	psb["Piranha M5P"] = 0
	psb["Hammer"] = 0
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
	vapor_goods = {"gold pressed latinum","unobtanium","eludium","impossibrium"}
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
	feature_cargoInventory = true
	feature_autoCoolant = true
	feature_crewFate = true
	--Damage to ship can kill repair crew members, deplete coolant and --disable ship functions--
	--ship functions may no be repairable, make sure, stations can heal it.
	feature_coolantNebulae = true
	healthCheckTimer = 5
	healthCheckTimerInterval = 5
end

function modify_player_ships(pobj)
	--called during setPlayers()
	--TODO in each setPlayers() function: replace pobj.nameAssigned with modsAssigned
	if not pobj.modsAssigned then
		pobj.modsAssigned = true
		local tempPlayerType = pobj:getTypeName()
		if tempPlayerType == "MP52 Hornet" or
			tempPlayerType == "MP56 Bumblebee" or
			tempPlayerType == "MP58 Mole" then
			if #playerShipNamesForMP52Hornet > 0 and not pobj.nameAssigned then
				pobj.nameAssigned = true
				--local ni = math.random(1,#playerShipNamesForMP52Hornet)
				--pobj:setCallSign(playerShipNamesForMP52Hornet[ni])
				--table.remove(playerShipNamesForMP52Hornet,ni)
			end
			pobj.shipScore = 7
			pobj.maxCargo = 3
			pobj:setAutoCoolant(true)
			pobj:commandSetAutoRepair(true)
			pobj.autoCoolant = true
--			pobj:setWarpDrive(true)
		elseif tempPlayerType == "ZX-Lindworm" or
			tempPlayerType == "Peluda" or
			tempPlayerType == "Drac" or
			tempPlayerType == "Cuelebre" or
			tempPlayerType == "Bashe" or
			tempPlayerType == "Ryu" or
			tempPlayerType == "Zomok" then
			if #playerShipNamesForLindworm > 0 and not pobj.nameAssigned then
				pobj.nameAssigned = true
				--ni = math.random(1,#playerShipNamesForLindworm)
				--pobj:setCallSign(playerShipNamesForLindworm[ni])
				--table.remove(playerShipNamesForLindworm,ni)
			end
			pobj.shipScore = 8
			pobj.maxCargo = 3
			pobj:setAutoCoolant(true)
			pobj:commandSetAutoRepair(true)
			pobj.autoCoolant = true
--			pobj:setWarpDrive(true)
		elseif tempPlayerType == "Adder MK7" then
			print("Adder")
			if #playerShipNamesForStriker > 0 and not pobj.nameAssigned then
				pobj.nameAssigned = true
				--ni = math.random(1,#playerShipNamesForStriker)
				--pobj:setCallSign(playerShipNamesForStriker[ni])
				--table.remove(playerShipNamesForStriker,ni)
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
				--ni = math.random(1,#playerShipNamesForPhobosM3P)
				--pobj:setCallSign(playerShipNamesForPhobosM3P[ni])
				--table.remove(playerShipNamesForPhobosM3P,ni)
			end
			pobj.shipScore = 19
			pobj.maxCargo = 10
--			pobj:setWarpDrive(true)
		elseif tempPlayerType == "Hathcock" or
			tempPlayerType == "Anvil" then
			if #playerShipNamesForHathcock > 0 and not pobj.nameAssigned then
				pobj.nameAssigned = true
				--ni = math.random(1,#playerShipNamesForHathcock)
				--pobj:setCallSign(playerShipNamesForHathcock[ni])
				--table.remove(playerShipNamesForHathcock,ni)
			end
			pobj.shipScore = 30
			pobj.maxCargo = 6
		elseif tempPlayerType == "Piranha M5P" or 
			tempPlayerType == "Hammer" then
			if #playerShipNamesForPiranha > 0 and not pobj.nameAssigned then
				pobj.nameAssigned = true
				--ni = math.random(1,#playerShipNamesForPiranha)
				--pobj:setCallSign(playerShipNamesForPiranha[ni])
				--table.remove(playerShipNamesForPiranha,ni)
			end
			pobj.shipScore = 16
			pobj.maxCargo = 8
		elseif tempPlayerType == "Flavia P.Falcon" then
			if #playerShipNamesForFlaviaPFalcon > 0 and not pobj.nameAssigned then
				pobj.nameAssigned = true
				--ni = math.random(1,#playerShipNamesForFlaviaPFalcon)
				--pobj:setCallSign(playerShipNamesForFlaviaPFalcon[ni])
				--table.remove(playerShipNamesForFlaviaPFalcon,ni)
			end
			pobj.shipScore = 13
			pobj.maxCargo = 15
		elseif tempPlayerType == "Repulse" then
			if #playerShipNamesForRepulse > 0 and not pobj.nameAssigned then
				pobj.nameAssigned = true
				--ni = math.random(1,#playerShipNamesForRepulse)
				--pobj:setCallSign(playerShipNamesForRepulse[ni])
				--table.remove(playerShipNamesForRepulse,ni)
			end
			pobj.shipScore = 14
			pobj.maxCargo = 12
		elseif tempPlayerType == "Nautilus" then
			if #playerShipNamesForNautilus > 0 and not pobj.nameAssigned then
				pobj.nameAssigned = true
				--ni = math.random(1,#playerShipNamesForNautilus)
				--pobj:setCallSign(playerShipNamesForNautilus[ni])
				--table.remove(playerShipNamesForNautilus,ni)
			end
			pobj.shipScore = 12
			pobj.maxCargo = 7
		elseif tempPlayerType == "Atlantis" then
			if #playerShipNamesForAtlantis > 0 and not pobj.nameAssigned then
				pobj.nameAssigned = true
				--ni = math.random(1,#playerShipNamesForAtlantis)
				--pobj:setCallSign(playerShipNamesForAtlantis[ni])
				--table.remove(playerShipNamesForAtlantis,ni)
			end
			pobj.carrier = true
			pobj.shipScore = 52
			pobj.maxCargo = 6
		elseif tempPlayerType == "Maverick" then
			if #playerShipNamesForMaverick > 0 and not pobj.nameAssigned then
				pobj.nameAssigned = true
				--ni = math.random(1,#playerShipNamesForMaverick)
				--pobj:setCallSign(playerShipNamesForMaverick[ni])
				--table.remove(playerShipNamesForMaverick,ni)
			end
			pobj.carrier = true
			pobj.shipScore = 52
			pobj.maxCargo = 6
		elseif tempPlayerType == "Crucible" then
			if #playerShipNamesForCrucible > 0 and not pobj.nameAssigned then
				pobj.nameAssigned = true
				--ni = math.random(1,#playerShipNamesForCrucible)
				--pobj:setCallSign(playerShipNamesForCrucible[ni])
				--table.remove(playerShipNamesForCrucible,ni)
			end
			pobj.carrier = true
			pobj.shipScore = 52
			pobj.maxCargo = 6
		elseif tempPlayerType == "Poseidon" then
			if #playerShipNamesForAtlantis > 0 and not pobj.nameAssigned then
				pobj.nameAssigned = true
				--ni = math.random(1,#playerShipNamesForAtlantis)
				--pobj:setCallSign(playerShipNamesForAtlantis[ni])
				--table.remove(playerShipNamesForAtlantis,ni)
			end
			pobj.carrier = true
			pobj.shipScore = 32
			pobj.maxCargo = 6
		elseif tempPlayerType == "Neptune" then
			if #playerShipNamesForAtlantis > 0 and not pobj.nameAssigned then
				pobj.nameAssigned = true
				--ni = math.random(1,#playerShipNamesForAtlantis)
				--pobj:setCallSign(playerShipNamesForAtlantis[ni])
				--table.remove(playerShipNamesForAtlantis,ni)
			end
			pobj.carrier = true
			pobj.shipScore = 16
			pobj.maxCargo = 6
		elseif tempPlayerType == "Benedict" then
			if #playerShipNamesForBenedict > 0 and not pobj.nameAssigned then
				pobj.nameAssigned = true
				--ni = math.random(1,#playerShipNamesForBenedict)
				--pobj:setCallSign(playerShipNamesForBenedict[ni])
				--table.remove(playerShipNamesForBenedict,ni)
			end
			pobj.carrier = true
			pobj.shipScore = 10
			pobj.maxCargo = 9
		elseif tempPlayerType == "Kiriya" then
			if #playerShipNamesForKiriya > 0 and not pobj.nameAssigned then
				pobj.nameAssigned = true
				--ni = math.random(1,#playerShipNamesForKiriya)
				--pobj:setCallSign(playerShipNamesForKiriya[ni])
				--table.remove(playerShipNamesForKiriya,ni)
			end
			pobj.carrier = true
			pobj.shipScore = 10
			pobj.maxCargo = 9
		elseif tempPlayerType == "Ender" or 
				tempPlayerType == "Converted Carrier" then
			if #playerShipNamesForEnder > 0 and not pobj.nameAssigned then
				pobj.nameAssigned = true
				--ni = math.random(1,#playerShipNamesForEnder)
				--pobj:setCallSign(playerShipNamesForEnder[ni])
				--table.remove(playerShipNamesForEnder,ni)
			end
			pobj.shipScore = 100
			pobj.maxCargo = 20
		elseif tempPlayerType == "SpySat" then 
			if #playerShipNamesForEnder > 0 and not pobj.nameAssigned then
				pobj.nameAssigned = true
				--ni = math.random(1,#playerShipNamesForEnder)
				--pobj:setCallSign(playerShipNamesForEnder[ni])
				--table.remove(playerShipNamesForEnder,ni)
			end
			pobj.shipScore = 1
			pobj.maxCargo = 1
		else
			if #playerShipNamesForLeftovers > 0 and not pobj.nameAssigned then
				pobj.nameAssigned = true
				--ni = math.random(1,#playerShipNamesForLeftovers)
				--pobj:setCallSign(playerShipNamesForLeftovers[ni])
				--table.remove(playerShipNamesForLeftovers,ni)
			end
			pobj.shipScore = 24
			pobj.maxCargo = 5
--			pobj:setWarpDrive(true)
		end
		pobj.initialCoolant = pobj:getMaxCoolant()
	end
end


function spawn_enemies_faction(xOrigin, yOrigin, enemyStrength, enemyFaction, shape)
	-- called in spawnEnemies()
	if shape == nil then
		shape = "square"
		if random(1,100) < 50 then
			shape = "hexagonal"
		end
	end

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

	local formationLeader = nil
	local formationSecond = nil
	local smallFormations = {}

	-- Reminder: stsl and stnl are ship template score and name list
	enemyStrength = math.max(enemyStrength, 5) 
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
		if shape == "square" and enemyPosition <= #fleetPosDelta1x then
			ship:setPosition(xOrigin+fleetPosDelta1x[enemyPosition]*sp,yOrigin+fleetPosDelta1y[enemyPosition]*sp)
		elseif shape == "hexagonal" and enemyPosition <= #fleetPosDelta2x then
			ship:setPosition(xOrigin+fleetPosDelta2x[enemyPosition]*sp,yOrigin+fleetPosDelta2y[enemyPosition]*sp)
		else
			ship:setPosition(xOrigin, yOrigin)
		end
		if enemyFaction == "Kraylor" then
			--kraylor formation
			formationLeader, formationSecond = script_formation.buildFormationIncremental(ship, enemyPosition, formationLeader, formationSecond)
			ship:setCommsScript(""):setCommsFunction(commsShip)
		elseif enemyFaction == "Exuari" then
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
			end
		else
			ship:setCommsScript(""):setCommsFunction(commsShip)
		end
		table.insert(enemyList, ship)
	end
	return enemyList, totalStrength
end

function enemyComms(comms_data)
	-- called instead enemyComms() of xanstas scenarios, as long it is deleted there.
	if comms_data.friendlyness > 50 or comms_source.special_intimidate_ships then
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

		if comms_source.special_intimidate_ships then
			local cost = special_buy_cost(comms_target, comms_source)
			addCommsReply(string.format(_("special-comms", "Surrender now! [Cost: %s Rep.]"), cost), function()
				local x,y = comms_target:getPosition()
				local playership_near = false
				local friends_near = false
				for _, obj in ipairs(getObjectsInRadius(x, y, 5000)) do
					if obj ~= nil and obj:isValid() and obj ~= comms_target then
						if obj.typeName == "PlayerSpaceship" then
							playership_near = true
						elseif obj.typeName == "CpuShip" then
							if comms_target:isFriendly(obj) then
								friends_near = true
							end
						end
					end
				end
				if not playership_near then
					setCommsMessage(_("needRep-comms", "We will not surrender to cowardly weaklings who do not have even the courage to face us directly."))
				elseif comms_target:getHull() >= comms_target:getHullMax() then
					setCommsMessage(_("needRep-comms", "Our ship is not even damaged and you want us to surrender? Come here and fight!"))
				elseif friends_near then
					setCommsMessage(_("needRep-comms", "We will not surrender as long as our friends are still close."))
				elseif not comms_source:takeReputationPoints(cost) then
					setCommsMessage(_("needRep-comms", "Insufficient reputation"))
				else
					comms_target:setFaction("Independent")
					comms_target:orderRoaming()
					setCommsMessage(_("special-comms", "Ship has surrendered."))
				end
			end)
		end
		return true
	end

	return false
end

--- some functions that are common to all xanstas scenarios but implemented differently-
-- TODO delete them in the scenario files and call xanstas_player_update from update()
-- also delete plot variables that contain those functions

function xanstas_player_update(delta)
	if feature_cargoInventory then
		assert(playerShipCargoInventory == nil)
		assert(cargoInventory == nil)
	end
	if feature_autoCoolant then
		assert(autoCoolant == nil)
	end
	if feature_crewFate then
		assert(healthCheck == nil)
		assert(resetPreviousSystemHealth == nil)
		assert(crewFate == nil)
	end
	if feature_coolantNebulae then
		assert(coolantNebulae == nil)
		assert(updateCoolantGivenPlayer == nil)
		assert(getCoolantGivenPlayer == nil)
		assert(coolant_nebula ~= nil)	--table, sometimes calles coolant_nebulae
		assert(coolant_loss ~= nil)
		assert(adverseEffect ~= nil)
		assert(coolant_gain ~= nil)
	end
	for pidx=1,32 do	-- or use MAX_PLAYERS constant?
		p = getPlayerShip(pidx)
		if p ~= nil and p:isValid() then
			if feature_cargoInventory then
				x_cargoInventory(p)
			end
			if feature_autoCoolant then
				x_autoCoolant(p)
			end
			if feature_crewFate then
				x_healthCheck(delta, p)
			end
			if feature_coolantNebulae then
				x_coolantNebulae(delta, p)
			end
		end
	end
end

--      Inventory button and functions for relay/operations 
function x_cargoInventory(p)
	local cargoHoldEmpty = true
	if p.goods ~= nil then
		for good, quantity in pairs(p.goods) do
			if quantity ~= nil and quantity > 0 then
				cargoHoldEmpty = false
				break
			end
		end
	end
	if not cargoHoldEmpty then
		if p:hasPlayerAtPosition("Relay") then
			if p.inventoryButton == nil then
				local tbi = "inventory" .. p:getCallSign()
				p:addCustomButton("Relay",tbi,"Inventory",function() x_playerShipCargoInventory(p) end)
				p.inventoryButton = true
			end
		end
		if p:hasPlayerAtPosition("Operations") then
			if p.inventoryButton == nil then
				local tbi = "inventoryOp" .. p:getCallSign()
				p:addCustomButton("Operations",tbi,"Inventory",function() x_playerShipCargoInventory(p) end)
				p.inventoryButton = true
			end
		end
	end
end
function x_playerShipCargoInventory(p)
	p:addToShipLog(string.format("%s Current cargo:",p:getCallSign()),"Yellow")
	local goodCount = 0
	if p.goods ~= nil then
		for good, goodQuantity in pairs(p.goods) do
			goodCount = goodCount + 1
			p:addToShipLog(string.format("     %s: %i",good,goodQuantity),"Yellow")
		end
	end
	if goodCount < 1 then
		p:addToShipLog("     Empty","Yellow")
	end
	p:addToShipLog(string.format("Available space: %i",p.cargo),"Yellow")
end

--      Enable and disable auto-cooling on a ship functions
function x_autoCoolant(p)
	if p.autoCoolant ~= nil then
		if p:hasPlayerAtPosition("Engineering") then
			if p.autoCoolButton == nil then
				local tbi = "enableAutoCool" .. p:getCallSign()
				p:addCustomButton("Engineering",tbi,"Auto cool",function() 
					string.format("")	--global context for serious proton
					p:commandSetAutoRepair(true)
					p:setAutoCoolant(true)
					p.autoCoolant = true
				end)
				tbi = "disableAutoCool" .. p:getCallSign()
				p:addCustomButton("Engineering",tbi,"Manual cool",function()
					string.format("")	--global context for serious proton
					p:commandSetAutoRepair(false)
					p:setAutoCoolant(false)
					p.autoCoolant = false
				end)
				p.autoCoolButton = true
			end
		end
		if p:hasPlayerAtPosition("Engineering+") then
			if p.autoCoolButton == nil then
				tbi = "enableAutoCoolPlus" .. p:getCallSign()
				p:addCustomButton("Engineering+",tbi,"Auto cool",function()
					string.format("")	--global context for serious proton
					p:commandSetAutoRepair(true)
					p:setAutoCoolant(true)
					p.autoCoolant = true
				end)
				tbi = "disableAutoCoolPlus" .. p:getCallSign()
				p:addCustomButton("Engineering+",tbi,"Manual cool",function()
					string.format("")	--global context for serious proton
					p:commandSetAutoRepair(false)
					p:setAutoCoolant(false)
					p.autoCoolant = false
				end)
				p.autoCoolButton = true
			end
		end
	end
end

--		Mortal repair crew functions. Includes coolant loss as option to losing repair crew
function x_healthCheck(delta, p)
	healthCheckTimer = healthCheckTimer - delta
	if healthCheckTimer < 0 then
		if feature_crewFate and p:getRepairCrewCount() > 0 then
			p.system_choice_list = {}
			local fatalityChance = 0
			local cShield = 0
			if p:getShieldCount() > 1 then
				cShield = (p:getSystemHealth("frontshield") + p:getSystemHealth("rearshield"))/2
				if p.prevShield - cShield > 0 then
					table.insert(p.system_choice_list,"frontShield")
					table.insert(p.system_choice_list,"rearshield")
				end
			else
				cShield = p:getSystemHealth("frontshield")
				if p.prevShield - cShield > 0 then
					table.insert(p.system_choice_list,"frontShield")
				end
			end
			fatalityChance = fatalityChance + (p.prevShield - cShield)
			p.prevShield = cShield
			if p.prevReactor - p:getSystemHealth("reactor") > 0 then
				table.insert(p.system_choice_list,"reactor")
			end
			fatalityChance = fatalityChance + (p.prevReactor - p:getSystemHealth("reactor"))
			p.prevReactor = p:getSystemHealth("reactor")
			if p.prevManeuver - p:getSystemHealth("maneuver") > 0 then
				table.insert(p.system_choice_list,"maneuver")
			end
			fatalityChance = fatalityChance + (p.prevManeuver - p:getSystemHealth("maneuver"))
			p.prevManeuver = p:getSystemHealth("maneuver")
			if p.prevImpulse - p:getSystemHealth("impulse") > 0 then
				table.insert(p.system_choice_list,"impulse")
			end
			fatalityChance = fatalityChance + (p.prevImpulse - p:getSystemHealth("impulse"))
			p.prevImpulse = p:getSystemHealth("impulse")
			if p:getBeamWeaponRange(0) > 0 then
				if p.healthyBeam == nil then
					p.healthyBeam = 1.0
					p.prevBeam = 1.0
				end
				if p.prevBeam - p:getSystemHealth("beamweapons") > 0 then
					table.insert(p.system_choice_list,"beamweapons")
				end
				fatalityChance = fatalityChance + (p.prevBeam - p:getSystemHealth("beamweapons"))
				p.prevBeam = p:getSystemHealth("beamweapons")
			end
			if p:getWeaponTubeCount() > 0 then
				if p.healthyMissile == nil then
					p.healthyMissile = 1.0
					p.prevMissile = 1.0
				end
				if p.prevMissile - p:getSystemHealth("missilesystem") > 0 then
					table.insert(p.system_choice_list,"missilesystem")
				end
				fatalityChance = fatalityChance + (p.prevMissile - p:getSystemHealth("missilesystem"))
				p.prevMissile = p:getSystemHealth("missilesystem")
			end
			if p:hasWarpDrive() then
				if p.healthyWarp == nil then
					p.healthyWarp = 1.0
					p.prevWarp = 1.0
				end
				if p.prevWarp - p:getSystemHealth("warp") > 0 then
					table.insert(p.system_choice_list,"warp")
				end
				fatalityChance = fatalityChance + (p.prevWarp - p:getSystemHealth("warp"))
				p.prevWarp = p:getSystemHealth("warp")
			end
			if p:hasJumpDrive() then
				if p.healthyJump == nil then
					p.healthyJump = 1.0
					p.prevJump = 1.0
				end
				if p.prevJump - p:getSystemHealth("jumpdrive") > 0 then
					table.insert(p.system_choice_list,"jumpdrive")
				end
				fatalityChance = fatalityChance + (p.prevJump - p:getSystemHealth("jumpdrive"))
				p.prevJump = p:getSystemHealth("jumpdrive")
			end
			if p:getRepairCrewCount() == 1 then
				fatalityChance = fatalityChance/2	-- increase chances of last repair crew standing
			end
			if fatalityChance > 0 then
				x_crewFate(p,fatalityChance)
			end
		else	--no repair crew left
			local diff = 1
			if difficulty ~= nil then
				diff = difficulty
			elseif scenario ~= nil and scenario.difficulty ~= nil then
				diff = scenario.difficulty
			end
			if feature_crewFate and random(1,100) <= (4 - diff) then
				p:setRepairCrewCount(1)
				if p:hasPlayerAtPosition("Engineering") then
					local repairCrewRecovery = "repairCrewRecovery"
					p:addCustomMessage("Engineering",repairCrewRecovery,"Medical team has revived one of your repair crew")
				end
				if p:hasPlayerAtPosition("Engineering+") then
					local repairCrewRecoveryPlus = "repairCrewRecoveryPlus"
					p:addCustomMessage("Engineering+",repairCrewRecoveryPlus,"Medical team has revived one of your repair crew")
				end
				x_resetPreviousSystemHealth(p)
			end
		end
		if p.initialCoolant ~= nil then
			local current_coolant = p:getMaxCoolant()
			if current_coolant < 20 then
				if random(1,100) <= 4 then
					local reclaimed_coolant = 0
					if p.reclaimable_coolant ~= nil and p.reclaimable_coolant > 0 then
						reclaimed_coolant = p.reclaimable_coolant*random(.1,.5)	--get back 10 to 50 percent of reclaimable coolant
						p:setMaxCoolant(math.min(20,current_coolant + reclaimed_coolant))
						p.reclaimable_coolant = p.reclaimable_coolant - reclaimed_coolant
					end
					local noticable_reclaimed_coolant = math.floor(reclaimed_coolant)
					if noticable_reclaimed_coolant > 0 then
						if p:hasPlayerAtPosition("Engineering") then
							p:addCustomMessage("Engineering","coolant_recovery","Automated systems have recovered some coolant")
						end
						if p:hasPlayerAtPosition("Engineering+") then
							p:addCustomMessage("Engineering+","coolant_recovery_plus","Automated systems have recovered some coolant")
						end
					end
					x_resetPreviousSystemHealth(p)
				end
			end
		end
		healthCheckTimer = delta + healthCheckTimerInterval
	end
end
function x_resetPreviousSystemHealth(p)
	if p:getShieldCount() > 1 then
		p.prevShield = (p:getSystemHealth("frontshield") + p:getSystemHealth("rearshield"))/2
	else
		p.prevShield = p:getSystemHealth("frontshield")
	end
	p.prevReactor = p:getSystemHealth("reactor")
	p.prevManeuver = p:getSystemHealth("maneuver")
	p.prevImpulse = p:getSystemHealth("impulse")
	if p:getBeamWeaponRange(0) > 0 then
		p.prevBeam = p:getSystemHealth("beamweapons")
	end
	if p:getWeaponTubeCount() > 0 then
		p.prevMissile = p:getSystemHealth("missilesystem")
	end
	if p:hasWarpDrive() then
		p.prevWarp = p:getSystemHealth("warp")
	end
	if p:hasJumpDrive() then
		p.prevJump = p:getSystemHealth("jumpdrive")
	end
end
function x_crewFate(p, fatalityChance)
	if math.random() < (fatalityChance) then
		if p.initialCoolant == nil then
			p:setRepairCrewCount(p:getRepairCrewCount() - 1)
			if p:hasPlayerAtPosition("Engineering") then
				local repairCrewFatality = "repairCrewFatality"
				p:addCustomMessage("Engineering",repairCrewFatality,"One of your repair crew has perished")
			end
			if p:hasPlayerAtPosition("Engineering+") then
				local repairCrewFatalityPlus = "repairCrewFatalityPlus"
				p:addCustomMessage("Engineering+",repairCrewFatalityPlus,"One of your repair crew has perished")
			end
		else
			local damaged_system = p.system_choice_list[math.random(1,#p.system_choice_list)]
			local damage = p:getSystemHealth(damaged_system)
			damage = (1 - damage)*.3
			p:setSystemHealthMax(damaged_system,p:getSystemHealthMax(damaged_system) - damage)
			local consequence = 0
			local upper_consequence = 2
			local consequence_list = {}
--			if p:getCanLaunchProbe() then
--				upper_consequence = upper_consequence + 1
--				table.insert(consequence_list,"probe")
--			end
--			if p:getCanHack() then
--				upper_consequence = upper_consequence + 1
--				table.insert(consequence_list,"hack")
--			end
--			if p:getCanScan() then
--				upper_consequence = upper_consequence + 1
--				table.insert(consequence_list,"scan")
--			end
--			if p:getCanCombatManeuver() then
--				upper_consequence = upper_consequence + 1
--				table.insert(consequence_list,"combat_maneuver")
--			end
--			if p:getCanSelfDestruct() then
--				upper_consequence = upper_consequence + 1
--				table.insert(consequence_list,"self_destruct")
--			end
			consequence = math.random(1,upper_consequence)
			if consequence == 1 then
				p:setRepairCrewCount(p:getRepairCrewCount() - 1)
				if p:hasPlayerAtPosition("Engineering") then
					local repairCrewFatality = "repairCrewFatality"
					p:addCustomMessage("Engineering",repairCrewFatality,"One of your repair crew has perished")
				end
				if p:hasPlayerAtPosition("Engineering+") then
					local repairCrewFatalityPlus = "repairCrewFatalityPlus"
					p:addCustomMessage("Engineering+",repairCrewFatalityPlus,"One of your repair crew has perished")
				end
			elseif consequence == 2 then
				local current_coolant = p:getMaxCoolant()
				local lost_coolant = 0
				if current_coolant >= 10 then
					lost_coolant = current_coolant*random(.25,.5)	--lose between 25 and 50 percent
				else
					lost_coolant = current_coolant*random(.15,.35)	--lose between 15 and 35 percent
				end
				p:setMaxCoolant(current_coolant - lost_coolant)
				if p.reclaimable_coolant == nil then
					p.reclaimable_coolant = 0
				end
				p.reclaimable_coolant = math.min(20,p.reclaimable_coolant + lost_coolant*random(.8,1))
				if p:hasPlayerAtPosition("Engineering") then
					local coolantLoss = "coolantLoss"
					p:addCustomMessage("Engineering",coolantLoss,"Damage has caused a loss of coolant")
				end
				if p:hasPlayerAtPosition("Engineering+") then
					local coolantLossPlus = "coolantLossPlus"
					p:addCustomMessage("Engineering+",coolantLossPlus,"Damage has caused a loss of coolant")
				end
			else
				local named_consequence = consequence_list[consequence-2]
				if named_consequence == "probe" then
					p:setCanLaunchProbe(false)
					if p:hasPlayerAtPosition("Engineering") then
						p:addCustomMessage("Engineering","probe_launch_damage_message","The probe launch system has been damaged")
					end
					if p:hasPlayerAtPosition("Engineering+") then
						p:addCustomMessage("Engineering+","probe_launch_damage_message_plus","The probe launch system has been damaged")
					end
				elseif named_consequence == "hack" then
					p:setCanHack(false)
					if p:hasPlayerAtPosition("Engineering") then
						p:addCustomMessage("Engineering","hack_damage_message","The hacking system has been damaged")
					end
					if p:hasPlayerAtPosition("Engineering+") then
						p:addCustomMessage("Engineering+","hack_damage_message_plus","The hacking system has been damaged")
					end
				elseif named_consequence == "scan" then
					p:setCanScan(false)
					if p:hasPlayerAtPosition("Engineering") then
						p:addCustomMessage("Engineering","scan_damage_message","The scanners have been damaged")
					end
					if p:hasPlayerAtPosition("Engineering+") then
						p:addCustomMessage("Engineering+","scan_damage_message_plus","The scanners have been damaged")
					end
				elseif named_consequence == "combat_maneuver" then
					p:setCanCombatManeuver(false)
					if p:hasPlayerAtPosition("Engineering") then
						p:addCustomMessage("Engineering","combat_maneuver_damage_message","Combat maneuver has been damaged")
					end
					if p:hasPlayerAtPosition("Engineering+") then
						p:addCustomMessage("Engineering+","combat_maneuver_damage_message_plus","Combat maneuver has been damaged")
					end
				elseif named_consequence == "self_destruct" then
					p:setCanSelfDestruct(false)
					if p:hasPlayerAtPosition("Engineering") then
						p:addCustomMessage("Engineering","self_destruct_damage_message","Self destruct system has been damaged")
					end
					if p:hasPlayerAtPosition("Engineering+") then
						p:addCustomMessage("Engineering+","self_destruct_damage_message_plus","Self destruct system has been damaged")
					end
				end
			end	--coolant loss branch
		end
	end
end

--		Gain or lose coolant from nebula functions
-- TODO check coolant_nebula is filled correctly
function x_coolantNebulae(delta, p)
	local inside_gain_coolant_nebula = false
	for i=1,#coolant_nebula do
		if distance(p,coolant_nebula[i]) < 5000 then
			if coolant_nebula[i].lose then
				p:setMaxCoolant(p:getMaxCoolant()*coolant_loss*delta)
			end
			if coolant_nebula[i].gain then
				inside_gain_coolant_nebula = true
			end
		end
	end
	if inside_gain_coolant_nebula then
		if p.get_coolant then
			if p.coolant_trigger then
				x_updateCoolantGivenPlayer(p, delta)
			end
		else
			if p:hasPlayerAtPosition("Engineering") then
				p.get_coolant_button = "get_coolant_button"
				p:addCustomButton("Engineering",p.get_coolant_button,"Get Coolant",function() x_getCoolantGivenPlayer(p) end)
				p.get_coolant = true
			end
			if p:hasPlayerAtPosition("Engineering+") then
				p.get_coolant_button_plus = "get_coolant_button_plus"
				p:addCustomButton("Engineering+",p.get_coolant_button_plus,"Get Coolant",function() x_getCoolantGivenPlayer(p) end)
				p.get_coolant = true
			end
		end
	else
		p.get_coolant = false
		p.coolant_trigger = false
		p.configure_coolant_timer = nil
		p.deploy_coolant_timer = nil
		if p:hasPlayerAtPosition("Engineering") then
			if p.get_coolant_button ~= nil then
				p:removeCustom(p.get_coolant_button)
				p.get_coolant_button = nil
			end
			if p.gather_coolant ~= nil then
				p:removeCustom(p.gather_coolant)
				p.gather_coolant = nil
			end
		end
		if p:hasPlayerAtPosition("Engineering+") then
			if p.get_coolant_button_plus ~= nil then
				p:removeCustom(p.get_coolant_button_plus)
				p.get_coolant_button_plus = nil
			end
			if p.gather_coolant_plus ~= nil then
				p:removeCustom(p.gather_coolant_plus)
				p.gather_coolant_plus = nil
			end
		end
	end
end
function x_updateCoolantGivenPlayer(p, delta)
	if p.configure_coolant_timer == nil then
		p.configure_coolant_timer = delta + 5
	end
	p.configure_coolant_timer = p.configure_coolant_timer - delta
	if p.configure_coolant_timer < 0 then
		if p.deploy_coolant_timer == nil then
			p.deploy_coolant_timer = delta + 5
		end
		p.deploy_coolant_timer = p.deploy_coolant_timer - delta
		if p.deploy_coolant_timer < 0 then
			gather_coolant_status = "Gathering Coolant"
			p:setMaxCoolant(p:getMaxCoolant() + coolant_gain*delta)
			if p:getMaxCoolant() > 50 and random(1,100) <= 13 then
				local engine_choice = math.random(1,3)
				if engine_choice == 1 then
					p:setSystemHealth("impulse",p:getSystemHealth("impulse")*adverseEffect*delta)
				elseif engine_choice == 2 then
					if p:hasWarpDrive() then
						p:setSystemHealth("warp",p:getSystemHealth("warp")*adverseEffect*delta)
					end
				else
					if p:hasJumpDrive() then
						p:setSystemHealth("jumpdrive",p:getSystemHealth("jumpdrive")*adverseEffect*delta)
					end
				end
			end
		else
			gather_coolant_status = string.format("Deploying Collectors %i",math.ceil(p.deploy_coolant_timer - delta))
		end
	else
		gather_coolant_status = string.format("Configuring Collectors %i",math.ceil(p.configure_coolant_timer - delta))
	end
	if p:hasPlayerAtPosition("Engineering") then
		p.gather_coolant = "gather_coolant"
		p:addCustomInfo("Engineering",p.gather_coolant,gather_coolant_status)
	end
	if p:hasPlayerAtPosition("Engineering+") then
		p.gather_coolant_plus = "gather_coolant_plus"
		p:addCustomInfo("Engineering",p.gather_coolant_plus,gather_coolant_status)
	end
end
function x_getCoolantGivenPlayer(p)
	if p:hasPlayerAtPosition("Engineering") then
		if p.get_coolant_button ~= nil then
			p:removeCustom(p.get_coolant_button)
			p.get_coolant_button = nil
		end
	end
	if p:hasPlayerAtPosition("Engineering+") then
		if p.get_coolant_button_plus ~= nil then
			p:removeCustom(p.get_coolant_button_plus)
			p.get_coolant_button_plus = nil
		end
	end
	p.coolant_trigger = true
end


-- comms functions. Remove the corresponding part from the functions in the script and call the functions defined here instead

function undockedGoods()
	if goods[comms_target] ~= nil then
		local goodsQuantityAvailable = 0
		local gi = 1
		repeat
			if goods[comms_target][gi][2] > 0 then
				goodsQuantityAvailable = goodsQuantityAvailable + goods[comms_target][gi][2]
			end
			gi = gi + 1
		until(gi > #goods[comms_target])
		if goodsQuantityAvailable > 0 then
			addCommsReply(_("trade-comms", "What goods do you have available for sale or trade?"), function()
				oMsg = string.format(_("trade-comms", "Station %s:\nGoods or components available: quantity, cost in reputation\n"),comms_target:getCallSign())
				gi = 1		-- initialize goods index
				repeat
					goodsType = goods[comms_target][gi][1]
					goodsQuantity = goods[comms_target][gi][2]
					goodsRep = goods[comms_target][gi][3]
					oMsg = oMsg .. string.format(_("trade-comms", "   %14s: %2i, %3i\n"),goodsType,goodsQuantity,goodsRep)
					gi = gi + 1
				until(gi > #goods[comms_target])
				setCommsMessage(oMsg)
				addCommsReply(_("Back"), commsStation)
			end)
		end
		addCommsReply(_("trade-comms", "Where can I find particular goods?"), function()
			gkMsg = _("trade-comms", "Friendly stations generally have food or medicine or both. Neutral stations often trade their goods for food, medicine or luxury.")
			if comms_target.goodsKnowledge == nil then
				gkMsg = gkMsg .. _("trade-comms", " Beyond that, I have no knowledge of specific stations.\n\nCheck back later, someone else may have better knowledge")
				setCommsMessage(gkMsg)
				addCommsReply(_("Back"), commsStation)
				fillStationBrains()
			else
				if #comms_target.goodsKnowledge == 0 then
					gkMsg = gkMsg .. _("trade-comms", " Beyond that, I have no knowledge of specific stations")
				else
					gkMsg = gkMsg .. _("trade-comms", "\n\nWhat goods are you interested in?\nI've heard about these:")
					for gk=1,#comms_target.goodsKnowledge do
						addCommsReply(comms_target.goodsKnowledgeType[gk],function()
							setCommsMessage(string.format(_("trade-comms", "Station %s in sector %s has %s%s"),comms_target.goodsKnowledge[gk],comms_target.goodsKnowledgeSector[gk],comms_target.goodsKnowledgeType[gk],comms_target.goodsKnowledgeTrade[gk]))
							addCommsReply(_("Back"), commsStation)
						end)
					end
				end
				setCommsMessage(gkMsg)
				addCommsReply(_("Back"), commsStation)
			end
		end)
	end
end

function dockedGoods()
	if goods[comms_target] ~= nil then
		addCommsReply(_("explainGoods-comms", "No tutorial covered goods or cargo. Explain"), function()
			setCommsMessage(_("explainGoods-comms", "Different types of cargo or goods may be obtained from stations, freighters or other sources. They go by one word descriptions such as dilithium, optic, warp, etc. Certain mission goals may require a particular type or types of cargo. Each player ship differs in cargo carrying capacity. Goods may be obtained by spending reputation points or by trading other types of cargo (typically food, medicine or luxury)"))
			addCommsReply(_("explainGoodsComponent-comms", "Explain the component goods"), explainComponents)
			addCommsReply(_("explainGoodsMineral-comms", "Explain the mineral goods"), explainMinerals)
			addCommsReply(_("explainGoodsTrade-comms", "Explain the trade goods"), explainTradeGoods)
			addCommsReply(_("explainGoodsVapor-comms", "Explain vapor goods"), function()
				setCommsMessage(_("explainGoodsVapor-comms", "On rare occasions, the system cannot determine an appropriate good. In that case one of these 'vapor' or fake goods will be listed:\n   gold pressed latinum, unobtanium, eludium, impossibrium\n\nIf you see one of these, that means that the good is not available. The need or desire for that good will go unmet or the mission will have to be satisfied in some other fashion."))
				addCommsReply(_("Back"), commsStation)
			end)
			addCommsReply(_("Back"), commsStation)
		end)
		addCommsReply(_("trade-comms", "Buy, sell, trade"), function()
			oMsg = string.format(_("trade-comms", "Station %s:\nGoods or components available: quantity, cost in reputation\n"),comms_target:getCallSign())
			local gi = 1		-- initialize goods index
			repeat
				local goodsType = goods[comms_target][gi][1]
				local goodsQuantity = goods[comms_target][gi][2]
				local goodsRep = goods[comms_target][gi][3]
				oMsg = oMsg .. string.format(_("trade-comms", "     %s: %i, %i\n"),goodsType,goodsQuantity,goodsRep)
				gi = gi + 1
			until(gi > #goods[comms_target])
			oMsg = oMsg .. _("trade-comms", "Current Cargo:\n")
			gi = 1
			local cargoHoldEmpty = true
			repeat
				local playerGoodsType = goods[player][gi][1]
				local playerGoodsQuantity = goods[player][gi][2]
				if playerGoodsQuantity > 0 then
					oMsg = oMsg .. string.format(_("trade-comms", "     %s: %i\n"),playerGoodsType,playerGoodsQuantity)
					cargoHoldEmpty = false
				end
				gi = gi + 1
			until(gi > #goods[player])
			if cargoHoldEmpty then
				oMsg = oMsg .. _("trade-comms", "     Empty\n")
			end
			local playerRep = math.floor(player:getReputationPoints())
			oMsg = oMsg .. string.format(_("trade-comms", "Available Space: %i, Available Reputation: %i\n"),player.cargo,playerRep)
			setCommsMessage(oMsg)
			-- Buttons for reputation purchases
			gi = 1
			repeat
				local goodsType = goods[comms_target][gi][1]
				local goodsQuantity = goods[comms_target][gi][2]
				local goodsRep = goods[comms_target][gi][3]
				addCommsReply(string.format(_("trade-comms", "Buy one %s for %i reputation"),goods[comms_target][gi][1],goods[comms_target][gi][3]), function()
					oMsg = string.format(_("trade-comms", "Type: %s, Quantity: %i, Rep: %i"),goodsType,goodsQuantity,goodsRep)
					if player.cargo < 1 then
						oMsg = oMsg .. _("trade-comms", "\nInsufficient cargo space for purchase")
					elseif goodsRep > playerRep then
						oMsg = oMsg .. _("needRep-comms", "\nInsufficient reputation for purchase")
					elseif goodsQuantity < 1 then
						oMsg = oMsg .. _("trade-comms", "\nInsufficient station inventory")
					else
						if not player:takeReputationPoints(goodsRep) then
							oMsg = oMsg .. _("needRep-comms", "\nInsufficient reputation for purchase")
						else
							player.cargo = player.cargo - 1
							decrementStationGoods(goodsType)
							incrementPlayerGoods(goodsType)
							oMsg = oMsg .. _("trade-comms", "\npurchased")
						end
					end
					setCommsMessage(oMsg)
					addCommsReply(_("Back"), commsStation)
				end)	--end buy goods from station for player reputation comms reply branch
				gi = gi + 1
			until(gi > #goods[comms_target])
			-- Buttons for food trades
			if tradeFood[comms_target] ~= nil then
				gi = 1
				local foodQuantity = 0
				repeat
					if goods[player][gi][1] == "food" then
						foodQuantity = goods[player][gi][2]
					end
					gi = gi + 1
				until(gi > #goods[player])
				if foodQuantity > 0 then
					gi = 1
					repeat
						local goodsType = goods[comms_target][gi][1]
						local goodsQuantity = goods[comms_target][gi][2]
						addCommsReply(string.format(_("trade-comms", "Trade food for %s"),goods[comms_target][gi][1]), function()
							oMsg = string.format(_("trade-comms", "Type: %s,  Quantity: %i"),goodsType,goodsQuantity)
							if goodsQuantity < 1 then
								oMsg = oMsg .. _("trade-comms", "\nInsufficient station inventory")
							else
								decrementStationGoods(goodsType)
								incrementPlayerGoods(goodsType)
								decrementPlayerGoods("food")
								oMsg = oMsg .. _("trade-comms", "\nTraded")
							end
							setCommsMessage(oMsg)
							addCommsReply(_("Back"), commsStation)
						end)	--end trade food on player ship for goods on station comms reply branch
						gi = gi + 1
					until(gi > #goods[comms_target])
				end	--end food available on player ship if branch
			end	--end food trade if branch
			-- Buttons for luxury trades
			if tradeLuxury[comms_target] ~= nil then
				gi = 1
				local luxuryQuantity = 0
				repeat
					if goods[player][gi][1] == "luxury" then
						luxuryQuantity = goods[player][gi][2]
					end
					gi = gi + 1
				until(gi > #goods[player])
				if luxuryQuantity > 0 then
					gi = 1
					repeat
						local goodsType = goods[comms_target][gi][1]
						local goodsQuantity = goods[comms_target][gi][2]
						addCommsReply(string.format(_("trade-comms", "Trade luxury for %s"),goods[comms_target][gi][1]), function()
							oMsg = string.format(_("trade-comms", "Type: %s,  Quantity: %i"),goodsType,goodsQuantity)
							if goodsQuantity < 1 then
								oMsg = oMsg .. _("trade-comms", "\nInsufficient station inventory")
							else
								decrementStationGoods(goodsType)
								incrementPlayerGoods(goodsType)
								decrementPlayerGoods("luxury")
								oMsg = oMsg .. _("trade-comms", "\nTraded")
							end
							setCommsMessage(oMsg)
							addCommsReply(_("Back"), commsStation)
						end)	--end trade luxury on player ship for goods on station comms reply branch
						gi = gi + 1
					until(gi > #goods[comms_target])
				end	--end luxury available on player ship if branch
			end	--end luxury trade if branch
			-- Buttons for medicine trades
			if tradeMedicine[comms_target] ~= nil then
				gi = 1
				local medicineQuantity = 0
				repeat
					if goods[player][gi][1] == "medicine" then
						medicineQuantity = goods[player][gi][2]
					end
					gi = gi + 1
				until(gi > #goods[player])
				if medicineQuantity > 0 then
					gi = 1
					repeat
						local goodsType = goods[comms_target][gi][1]
						local goodsQuantity = goods[comms_target][gi][2]
						addCommsReply(string.format(_("trade-comms", "Trade medicine for %s"),goods[comms_target][gi][1]), function()
							oMsg = string.format(_("trade-comms", "Type: %s,  Quantity: %i"),goodsType,goodsQuantity)
							if goodsQuantity < 1 then
								oMsg = oMsg .. _("trade-comms", "\nInsufficient station inventory")
							else
								decrementStationGoods(goodsType)
								incrementPlayerGoods(goodsType)
								decrementPlayerGoods("medicine")
								oMsg = oMsg .. _("trade-comms", "\nTraded")
							end
							setCommsMessage(oMsg)
							addCommsReply(_("Back"), commsStation)
						end)	--end trade medicine on player ship for goods on station comms reply branch
						gi = gi + 1
					until(gi > #goods[comms_target])
				end	--end medicine available on player ship if branch
			end	--end medicine trade if branch
			addCommsReply(_("Back"), commsStation)
		end)	--end of buy, sell trade comms reply branch
		gi = 1
		cargoHoldEmpty = true
		repeat
			playerGoodsType = goods[player][gi][1]
			playerGoodsQuantity = goods[player][gi][2]
			if playerGoodsQuantity > 0 then
				cargoHoldEmpty = false
			end
			gi = gi + 1
		until(gi > #goods[player])
		if not cargoHoldEmpty then
			addCommsReply(_("trade-comms", "Jettison cargo"), function()
				setCommsMessage(string.format(_("trade-comms", "Available space: %i\nWhat would you like to jettison?"),player.cargo))
				gi = 1
				repeat
					local goodsType = goods[player][gi][1]
					local goodsQuantity = goods[player][gi][2]
					if goodsQuantity > 0 then
						addCommsReply(goodsType, function()
							decrementPlayerGoods(goodsType)
							player.cargo = player.cargo + 1
							setCommsMessage(string.format("One %s jettisoned",goodsType))
							addCommsReply("Back", commsStation)
						end)
					end
					gi = gi + 1
				until(gi > #goods[player])
				addCommsReply("Back", commsStation)
			end)	--end of cargo present, allow jettison if and comms reply branch
		end	
	end	--end of goods present on comms target if branch
end
function special_buy_cost(target, player)
	cost = target:getHullMax()
	--[[
	-- stations:			IU (*4)	Inde(*8)	gain
	--	Small Station	150	 600	1200	600/h
	--	Medium Station	400	1600	3200
	--	Large Station	500	2000	4000
	--	Huge Station	800	3200	6400
	-- Phobos			 70	 120	 240
	--]]
	if target:isEnemy(player) then
		health = target:getHull() / target:getHullMax()
		cost = cost *4 *health
	elseif target:isFriendly(player) then
		cost = cost *1
	else	-- Neutral
		cost = cost *2
	end
	if target:getFaction() == "Interplanetary Union" then
		cost = cost *1
	elseif target:getFaction() == "Independent" then
		cost = cost *2
	elseif target:getFaction() == "Arlenians" then
		cost = cost *4
	elseif target:getFaction() == "Exuari" then	-- because stations are ships
		cost = cost *4
	else	-- other neutral and enemies
		cost = cost *2
	end
	if target.typeName == "SpaceStation" then
		cost = cost *2
	else -- SpaceShip
		cost = cost *1
	end
	return math.floor(cost)
end

