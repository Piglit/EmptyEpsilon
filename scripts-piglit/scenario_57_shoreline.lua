-- Name: Shoreline
-- Description: Waves of increasingly difficult enemies. At least one required mission and several optional missions randomly selected
---
--- Maximum of 8 player ships supported by scenario. More player ships may experience strange results
---
--- Version 2
-- Type: Re-playable Mission
-- Variation[Timed]: Normal difficulty with a 45 minute time limit
-- Variation[Very Easy]: Few or weak enemies
-- Variation[Very Easy Timed]: Few or weak enemies with a 45 minute time limit
-- Variation[Easy]: Fewer or less powerful enemies
-- Variation[Easy Timed]: Fewer or less powerful enemies with a 45 minute time limit
-- Variation[Hard]: More or more powerful enemies
-- Variation[Hard Timed]: More or more powerful enemies with a 45 minute time limit
-- Variation[Very Hard]: Many powerful enemies
-- Variation[Very Hard Timed]: Many powerful enemies with a 45 minute time limit

require("ee.lua")
require("utils.lua")
require("xansta_mods.lua")
require("script_hangar.lua")

--[[-----------------------------------------------------------------
      Dynamic map functions 
-----------------------------------------------------------------]]--
function moveBlackHole(delta)
	local mbhx, mbhy = grawp:getPosition()
	if mbhx < 67000 or mbhx > 90000 or mbhy < -21000 or mbhy > 40000 then
		if mbhx < 67000 then
			grawp.angle = random(0,180) + 270
		end
		if mbhx > 90000 then
			grawp.angle = random(90,270)
		end
		if mbhy < -21000 then
			grawp.angle = random(0,180)
		end
		if mbhy > 40000 then
			grawp.angle = random(180,360)
		end
		if grawp.angle == nil then print("grawp.angle is nil (1)") end
		local deltaBlackx, deltaBlacky = vectorFromAngle(grawp.angle, grawp.travel+20)
		grawp:setPosition(mbhx+deltaBlackx,mbhy+deltaBlacky)
		grawp.travel = random(1,5 + difficulty)
	else
		if grawp.angle == nil then print("grawp.angle is nil (2)") end
		deltaBlackx, deltaBlacky = vectorFromAngle(grawp.angle, grawp.travel)
		grawp:setPosition(mbhx+deltaBlackx,mbhy+deltaBlacky)
	end
end

function moveAsteroids(delta)
	local movingAsteroidCount = 0
	for aidx, aObj in ipairs(movingAsteroidList) do
		if aObj:isValid() then
			movingAsteroidCount = movingAsteroidCount + 1
			local mAstx, mAsty = aObj:getPosition()
			if mAstx < -150000 or mAstx > 150000 or mAsty < -150000 or mAsty > 150000 then
				aObj.angle = random(0,360)
				local curve = 0
				if random(1,100) < 50 then
					curve = math.random()*.08
				end
				if aObj.angle < 90 then
					aObj:setPosition(random(-150000,-100000),random(-150000,-100000))
					if aObj.angle < 45 then
						aObj.curve = curve
					else
						aObj.curve = -curve
					end
				elseif aObj.angle < 180 then
					aObj:setPosition(random(100000,150000),random(-150000,-100000))
					if aObj.angle < 135 then
						aObj.curve = curve
					else
						aObj.curve = -curve
					end
				elseif aObj.angle < 270 then
					aObj:setPosition(random(100000,150000),random(100000,150000))
					if aObj.angle < 225 then
						aObj.curve = curve
					else
						aObj.curve = -curve
					end
				else
					aObj:setPosition(random(-150000,-100000),random(100000,150000))
					if aObj.angle < 315 then
						aObj.curve = curve
					else
						aObj.curve = -curve
					end
				end
			else
				if aObj.angle == nil then print("aObj.angle is nil") end
				local deltaAstx, deltaAsty = vectorFromAngle(aObj.angle,aObj.travel)
				aObj:setPosition(mAstx+deltaAstx,mAsty+deltaAsty)
				aObj.angle = aObj.angle + aObj.curve
			end
		end
	end
	if movingAsteroidCount < 1 then
		setMovingAsteroids()
	end
end
--[[-----------------------------------------------------------------
      Initialization 
-----------------------------------------------------------------]]--
function init()
	init_constants_xansta()
	--Ship Template Name List
		transportList = {}
	transportSpawnDelay = 30
	diagnostic = false
	game_end_statistics_diagnostic = false
	update_loop_diagnostic = false
	optional_mission_loop_diagnostic = false
	goods = {}
	prefix_length = 0
	suffix_index = 0
	setVariations()
	setPlayers()
	setMovingAsteroids()
	setStations()
	plotT = transportPlot
	plotB = moveBlackHole
	persistentEnemies = {}
	waveDelayCount = 0
	waveInProgress = false
	waveProgressInterval = .25
	waveProgress = 0
	plotW = monitorWaves
	helpWarnDelay = 30
	vaiken_damage_timer_interval = 120
	vaiken_damage_timer = vaiken_damage_timer_interval
	plotH = helpWarn
	plotHangar = script_hangar.update
	plotCI = cargoInventory			--manage button on relay/operations to show cargo inventory
	plotCN = coolantNebulae
	primaryOrders = "Defend bases in the area (human navy and independent) from enemy attack."
	secondaryOrders = ""
	optionalOrders = ""
	undercutLocation = "station"
	requiredMissionCount = 0
	optionalMissionDelay = 60
	--Allow choice of required mission on GM screen rather than being selected at random
	addGMFunction("R.Undercut",undercutGM)
	addGMFunction("R.Stettor",stettorGM)
	addGMFunction("R.Horizon",horizonGM)
	addGMFunction("R.Sporisky",sporiskyGM)
	--Allow choice of optional mission on GM screen rather than being selected at random
	addGMFunction("O.Beam Range",beamRangeGM)
	addGMFunction("O.Impulse",impulseGM)
	addGMFunction("O.Spin",spinGM)
	addGMFunction("O.Shield",shieldGM)
	addGMFunction("O.Beam Damage",beamDamageGM)
end

function setVariations()
	if string.find(getScenarioVariation(),"Timed") then
		playWithTimeLimit = true
		gameTimeLimit = 45*60		
		waveDelayCountCheck = 15
	else
		gameTimeLimit = 0
		clueMessageDelay = 30*60
		playWithTimeLimit = false
		requiredMissionDelay = 20
		waveDelayCountCheck = 30
		clueMessageDelay = 30*60
	end
	if string.find(getScenarioVariation(),"Very Easy") then
		difficulty = .25
		coolant_loss = .999995
		coolant_gain = .015
		waveDelayCountCheck = waveDelayCountCheck + 9
		waveProgressInterval = .15
	elseif string.find(getScenarioVariation(),"Very Hard") then
		difficulty = 3
		coolant_loss = .999
		coolant_gain = .00001
		waveDelayCountCheck = waveDelayCountCheck - 9		
		waveProgressInterval = .75
	elseif string.find(getScenarioVariation(),"Easy") then
		difficulty = .5
		coolant_loss = .99999
		coolant_gain = .01
		waveDelayCountCheck = waveDelayCountCheck + 6
		waveProgressInterval = .2
	elseif string.find(getScenarioVariation(),"Hard") then
		difficulty = 2
		coolant_loss = .9999
		coolant_gain = .0001
		waveDelayCountCheck = waveDelayCountCheck - 6
		waveProgressInterval = .5
	else
		difficulty = 1		--default (normal)
		coolant_loss = .99995
		coolant_gain = .001
	end
end

function setPlayers()
	for p1idx=1, MAX_PLAYER_SHIPS do
		pobj = getPlayerShip(p1idx)
		if pobj ~= nil and pobj:isValid() then
			if goods[pobj] == nil then
				goods[pobj] = goodsList
			end
			if pobj.initialRep == nil then
				pobj:addReputationPoints(100-(difficulty*6))
				pobj.initialRep = true
			end
			modify_player_ships(pobj)
			if pobj.cargo == nil then
				pobj.cargo = pobj.maxCargo
			end
		end
	end
end
--required mission selection GM functions
function undercutGM()
	if undercutMission ~= "done" and undercutLocation ~= "free" then
		plotR = undercutOrderMessage
		chooseUndercutBase()
	end
	removeGMFunction("R.Undercut")
end
function stettorGM()
	if stettorMission ~= "done" then
		chooseSensorBase()
		chooseSensorParts()
		plotR = stettorOrderMessage
	end
	removeGMFunction("R.Stettor")
end
function horizonGM()
	if horizonMission ~= "done" then
		chooseHorizonParts()
		plotR = horizonOrderMessage
	end				
	removeGMFunction("R.Horizon")
end
function sporiskyGM()
	if sporiskyMission ~= "done" then
		chooseTraitorBase()
		plotR = traitorOrderMessage
	end
	removeGMFunction("R.Sporisky")
end
--optional mission selection GM functions
function beamRangeGM()
	if beamRangePlot ~= "done" then
		chooseBeamRangeParts()
		plotO = beamRangeMessage
	end
	removeGMFunction("O.Beam Range")
end
function impulseGM()
	if impulseSpeedPlot ~= "done" then
		impulseSpeedParts()
		plotO = impulseSpeedMessage
	end
	removeGMFunction("O.Impulse")
end
function spinGM()
	if spinPlot ~= "done" then
		chooseSpinBaseParts()
		plotO = spinMessage
	end
	removeGMFunction("O.Spin")
end
function shieldGM()
	if quantumArtPlot ~= "done" then
		plotO = quantumArtMessage
	end
	removeGMFunction("O.Shield")
end
function beamDamageGM()
	if beamDamagePlot ~= "done" then
		chooseBeamDamageParts()
		plotO = beamDamageMessage
	end
	removeGMFunction("O.Beam Damage")
end
--additional ad hoc ship definitions
function phobosR2(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Phobos T3"):orderRoaming()
	ship:setTypeName("Phobos R2")
	ship:setWeaponTubeCount(1)			--one tube (vs 2)
	ship:setWeaponTubeDirection(0,0)	
	ship:setImpulseMaxSpeed(55)			--slower impulse (vs 60)
	ship:setRotationMaxSpeed(15)		--faster maneuver (vs 10)
	return ship
end
function adderMk8(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Adder MK5"):orderRoaming()
	ship:setTypeName("Adder MK8")
	ship:setShieldsMax(50)					--stronger shields (vs 30)
	ship:setShields(50)
	ship:setBeamWeapon(0,30,0,900,5.0,2.3)	--narrower (30 vs 35) but longer (900 vs 800) and stronger (2.3 vs 2.0) beam
	ship:setRotationMaxSpeed(30)			--faster maneuver (vs 25)
	return ship
end
function adderMk7(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Adder MK6"):orderRoaming()
	ship:setTypeName("Adder MK7")
	ship:setShieldsMax(40)	--stronger shields (vs 30)
	ship:setShields(40)
	ship:setBeamWeapon(0,30,0,900,5.0,2.0)	--narrower (30 vs 35) but longer (900 vs 800) beam
	return ship
end
function adderMk3(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Adder MK4"):orderRoaming()
	ship:setTypeName("Adder MK3")
	ship:setHullMax(35)		--weaker hull (vs 40)
	ship:setHull(35)
	ship:setShieldsMax(15)	--weaker shield (vs 20)
	ship:setShields(15)
	ship:setRotationMaxSpeed(35)	--faster maneuver (vs 20)
	return ship
end
--station related functions
function setMovingAsteroids()
	movingAsteroidList = {}
	for aidx=1,30 do
		local xAst = random(-100000,100000)
		local yAst = random(-100000,100000)
		local outRange = true
		for p2idx=1, MAX_PLAYER_SHIPS do
			local p2obj = getPlayerShip(p2idx)
			if p2obj ~= nil and p2obj:isValid() then
				if p2obj == nil then print("p2obj is nil") end
				if xAst == nil then print("xAst is nil") end
				local x1, y1 = p2obj:getPosition()
				if distance(x1,y1,xAst,yAst) < 30000 then
					outRange = false
				end
			end
		end
		if outRange then
			local mAst = Asteroid():setPosition(xAst,yAst)
			mAst.angle = random(0,360)
			mAst.travel = random(40,220)
			if random(1,100) < 50 then
				mAst.curve = 0
			else
				mAst.curve = math.random()*.16 - .08
			end
			table.insert(movingAsteroidList,mAst)
		end
	end
	plotA = moveAsteroids
end
function randomMineral(exclude)
	local good = mineralGoods[math.random(1,#mineralGoods)]
	if exclude == nil then
		return good
	else
		repeat
			good = mineralGoods[math.random(1,#mineralGoods)]
		until(good ~= exclude)
		return good
	end
end
function randomComponent(exclude)
	local good = componentGoods[math.random(1,#componentGoods)]
	if exclude == nil then
		return good
	else
		repeat
			good = componentGoods[math.random(1,#componentGoods)]
		until(good ~= exclude)
		return good
	end
end
function szt()
--Randomly choose station size template
	if stationSize ~= nil then
		sizeTemplate = stationSize
		return sizeTemplate
	end
	stationSizeRandom = random(1,100)
	if stationSizeRandom < 8 then
		sizeTemplate = "Huge Station"		-- 8 percent huge
	elseif stationSizeRandom < 24 then
		sizeTemplate = "Large Station"		--16 percent large
	elseif stationSizeRandom < 50 then
		sizeTemplate = "Medium Station"		--26 percent medium
	else
		sizeTemplate = "Small Station"		--50 percent small
	end
	return sizeTemplate
end
--neutral and friendly stations
function placeVaiken()
	--Vaiken
	stationVaiken = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationVaiken:setPosition(psx,psy):setCallSign("Vaiken"):setDescription("Ship building and maintenance facility")
    stationVaiken.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",	HVLI = "neutral", 	Mine = "neutral",	Nuke = "friend", 	EMP = "friend"},
        weapon_available = 	{Homing = true,			HVLI = true,		Mine = true,		Nuke = true,		EMP = true},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 2.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	food =		{quantity = 10,	cost = 1},
        			medicine =	{quantity = 5,	cost = 5} },
        trade = {	food = false, medicine = false, luxury = false },
        public_relations = true,
        general_information = "Human Navy headquarters. Loss of this station would be devastating"
	}
	return stationVaiken
end
function placeZefram()
	--Zefram
	stationZefram = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationZefram:setPosition(psx,psy):setCallSign("Zefram"):setDescription("Warp engine components")
    stationZefram.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        weapon_cost = 		{Homing = 2,							HVLI = math.random(3),					Mine = math.random(4),					Nuke = math.random(10,15),				EMP = 10},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 2.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	warp =	{quantity = 5,	cost = 140} },
        trade = {	food = true, medicine = false, luxury = true },
        public_relations = true,
        general_information = "We specialize in the esoteric components necessary to make warp drives function properly",
    	history = "Zefram Cochrane constructed the first warp drive in human history. We named our station after him because of the specialized warp systems work we do"
	}
	if stationFaction == "Human Navy" then
		stationZefram.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
		if random(1,5) <= 1 then
			stationZefram.comms_data.goods.medicine = {quantity = 5, cost = 5}
		else
			stationZefram.comms_data.trade.medicine = random(1,100) < 27
		end
	else
		stationZefram.comms_data.trade.medicine = random(1,100) < 27
		stationZefram.comms_data.trade.food = random(1,100) < 16
	end
	return stationZefram
end
function placeMarconi()
	--Marconi 
	stationMarconi = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationMarconi:setPosition(psx,psy):setCallSign("Marconi"):setDescription("Energy Beam Components")
    stationMarconi.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = f_n[math.random(2)],			HVLI = "neutral", 						Mine = "neutral",						Nuke = f_n[math.random(2)], 			EMP = f_n[math.random(2)]},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 2.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	beam =	{quantity = 5,	cost = 80} },
        trade = {	food = true, medicine = false, luxury = true },
        public_relations = true,
        general_information = "We manufacture energy beam components",
    	history = "Station named after Guglielmo Marconi an Italian inventor from early 20th century Earth who, along with Nicolo Tesla, claimed to have invented a death ray or particle beam weapon"
	}
	if stationFaction == "Human Navy" then
		stationMarconi.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
		if random(1,5) <= 1 then
			stationMarconi.comms_data.goods.medicine = {quantity = 5, cost = 5}
		else
			stationMarconi.comms_data.trade.medicine = true
		end
	else
		stationMarconi.comms_data.trade.luxury = true
		stationMarconi.comms_data.trade.food = true
	end
	return stationMarconi
end
function placeMuddville()
	--Muddville 
	stationMudd = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationMudd:setPosition(psx,psy):setCallSign("Muddville"):setDescription("Trading station")
    stationMudd.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 2.5},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	luxury =	{quantity = 10,	cost = 60} },
        trade = {	food = false, medicine = false, luxury = false },
        public_relations = true,
        general_information = "Come to Muddvile for all your trade and commerce needs and desires",
    	history = "Upon retirement, Harry Mudd started this commercial venture using his leftover inventory and extensive connections obtained while he traveled the stars as a salesman"
	}
	if stationFaction == "Human Navy" then
		stationMudd.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
		if random(1,5) <= 1 then
			stationMudd.comms_data.goods.medicine = {quantity = 5, cost = 5}
		end
	end
	return stationMudd
end
function placeAlcaleica()
	--Alcaleica
	stationAlcaleica = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationAlcaleica:setPosition(psx,psy):setCallSign("Alcaleica"):setDescription("Optical Components")
    stationAlcaleica.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	optic = {quantity = 5,	cost = 66} },
        trade = {	food = false, medicine = false, luxury = false },
		buy =	{	[randomMineral()] = math.random(40,200)	},
        public_relations = true,
        general_information = "We make and supply optic components for various station and ship systems",
    	history = "This station continues the businesses from Earth based on the merging of several companies including Leica from Switzerland, the lens manufacturer and the Japanese advanced low carbon (ALCA) electronic and optic research and development company"
	}
	if stationFaction == "Human Navy" then
		stationAlcaleica.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
		if random(1,5) <= 1 then
			stationAlcaleica.comms_data.goods.medicine = {quantity = 5, cost = 5}
		else
			stationAlcaleica.comms_data.trade.medicine = true
		end
	else
		stationAlcaleica.comms_data.trade.medicine = true
		stationAlcaleica.comms_data.trade.food = true
	end
	return stationAlcaleica
end
function placeCalifornia()
	--California
	stationCalifornia = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationCalifornia:setPosition(psx,psy):setCallSign("California"):setDescription("Mining station")
    stationCalifornia.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 2.5},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	gold =		{quantity = 5,	cost = 90},
        			dilithium =	{quantity = 2,	cost = 25} },
        trade = {	food = false, medicine = false, luxury = false },
		buy =	{	[randomComponent()] = math.random(40,200)	}
	}
	if stationFaction == "Human Navy" then
		stationCalifornia.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
		if random(1,5) <= 1 then
			stationCalifornia.comms_data.goods.medicine = {quantity = 5, cost = 5}
		end
	end
	return stationCalifornia
end
function placeOutpost15()
	--Outpost 15
	stationOutpost15 = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationOutpost15:setPosition(psx,psy):setCallSign("Outpost-15"):setDescription("Mining and trade")
    stationOutpost15.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	luxury =	{quantity = 5,	cost = 70} },
        trade = {	food = true, medicine = false, luxury = false }
	}
	local outpost15Goods = random(1,100)
	if outpost15Goods < 20 then
		stationOutpost15.comms_data.goods.gold = {quantity = 5, cost = math.random(22,30)}
		stationOutpost15.comms_data.goods.cobalt = {quantity = 4, cost = math.random(45,55)}
	elseif outpost15Goods < 40 then
		stationOutpost15.comms_data.goods.gold = {quantity = 5, cost = math.random(22,30)}
	elseif outpost15Goods < 60 then
		stationOutpost15.comms_data.goods.cobalt = {quantity = 4, cost = math.random(45,55)}
	else
		stationOutpost15.comms_data.goods.platinum = {quantity = 4, cost = math.random(55,65)}
	end
	if stationFaction == "Human Navy" then
		stationOutpost15.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
		if random(1,5) <= 1 then
			stationOutpost15.comms_data.goods.medicine = {quantity = 5, cost = 5}
		else
			stationOutpost15.comms_data.trade.medicine = true		
		end
	else
		stationOutpost15.comms_data.trade.food = true
	end
	placeRandomAroundPoint(Asteroid,15,1,15000,psx,psy)
	return stationOutpost15
end
function placeOutpost21()
	--Outpost 21
	stationOutpost21 = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationOutpost21:setPosition(psx,psy):setCallSign("Outpost-21"):setDescription("Mining and gambling")
    stationOutpost21.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	luxury =	{quantity = 5,	cost = 70} },
        trade = {	food = false, medicine = false, luxury = true }
	}
	placeRandomAroundPoint(Asteroid,15,1,15000,psx,psy)
	local outpost21Goods = random(1,100)
	if outpost21Goods < 20 then
		stationOutpost21.comms_data.goods.gold = {quantity = 5, cost = math.random(22,30)}
		stationOutpost21.comms_data.goods.cobalt = {quantity = 4, cost = math.random(45,55)}
	elseif outpost21Goods < 40 then
		stationOutpost21.comms_data.goods.gold = {quantity = 5, cost = math.random(22,30)}
	elseif outpost21Goods < 60 then
		stationOutpost21.comms_data.goods.cobalt = {quantity = 4, cost = math.random(45,55)}
	else
		stationOutpost21.comms_data.goods.dilithium = {quantity = 4, cost = math.random(45,55)}
	end
	if stationFaction == "Human Navy" then
		stationOutpost21.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
		if random(1,5) <= 1 then
			stationOutpost21.comms_data.goods.medicine = {quantity = 5, cost = 5}
		else
			stationOutpost21.comms_data.trade.medicine = random(1,100) < 50
		end
	else
		stationOutpost21.comms_data.trade.food = true
		stationOutpost21.comms_data.trade.medicine = random(1,100) < 50
	end
	return stationOutpost21
end
function placeValero()
	--Valero
	stationValero = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationValero:setPosition(psx,psy):setCallSign("Valero"):setDescription("Resupply")
    stationValero.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 2.5},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	luxury =	{quantity = 5,	cost = 90} },
        trade = {	food = false, medicine = false, luxury = false }
	}
	return stationValero
end
function placeVactel()
	--Vactel
	stationVactel = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationVactel:setPosition(psx,psy):setCallSign("Vactel"):setDescription("Shielded Circuitry Fabrication")
    stationVactel.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	circuit =	{quantity = 5,	cost = 50} },
        trade = {	food = false, medicine = false, luxury = false },
        public_relations = true,
        general_information = "We specialize in circuitry shielded from external hacking suitable for ship systems",
    	history = "We started as an expansion from the lunar based chip manufacturer of Earth legacy Intel electronic chips"
	}
	if stationFaction == "Human Navy" then
		stationVactel.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
		if random(1,5) <= 1 then
			stationVactel.comms_data.goods.medicine = {quantity = 5, cost = 5}
		end
	end
	return stationVactel
end
function placeArcher()
	--Archer 
	stationArcher = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationArcher:setPosition(psx,psy):setCallSign("Archer"):setDescription("Shield and Armor Research")
    stationArcher.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	shield =	{quantity = 5,	cost = 90} },
        trade = {	food = false, medicine = false, luxury = true },
		buy =	{	[randomMineral()] = math.random(40,200)	},
        public_relations = true,
        general_information = "The finest shield and armor manufacturer in the quadrant",
    	history = "We named this station for the pioneering spirit of the 22nd century Starfleet explorer, Captain Jonathan Archer"
	}
	if stationFaction == "Human Navy" then
		stationArcher.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
		if random(1,5) <= 1 then
			stationArcher.comms_data.goods.medicine = {quantity = 5, cost = 5}
		else
			stationArcher.comms_data.trade.medicine = true
		end
	else
		stationArcher.comms_data.trade.medicine = true
	end
	return stationArcher
end
function placeDeer()
	--Deer
	stationDeer = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationDeer:setPosition(psx,psy):setCallSign("Deer"):setDescription("Repulsor and Tractor Beam Components")
    stationDeer.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	tractor =	{quantity = 5,	cost = 90},
        			repulsor =	{quantity = 5,	cost = 95} },
        trade = {	food = true, medicine = false, luxury = true },
		buy =	{	[randomMineral()] = math.random(40,200)	},
        public_relations = true,
        general_information = "We can meet all your pushing and pulling needs with specialized equipment custom made",
    	history = "The station name comes from a short story by the 20th century author Clifford D. Simak as well as from the 19th century developer John Deere who inspired a company that makes the Earth bound equivalents of our products"
	}
	if stationFaction == "Human Navy" then
		stationDeer.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
		stationDeer.comms_data.goods.food.cost = 1
		if random(1,5) <= 1 then
			stationDeer.comms_data.goods.medicine = {quantity = 5, cost = 5}
		else
			stationDeer.comms_data.trade.medicine = true
		end
	else
		stationDeer.comms_data.trade.medicine = true
		stationDeer.comms_data.trade.food = true
	end
	return stationDeer
end
function placeCavor()
	--Cavor 
	stationCavor = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationCavor:setPosition(psx,psy):setCallSign("Cavor"):setDescription("Advanced Material components")
    stationCavor.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	filament =	{quantity = 5,	cost = 42} },
        trade = {	food = false, medicine = false, luxury = false },
        public_relations = true,
        general_information = "We fabricate several different kinds of materials critical to various space industries like ship building, station construction and mineral extraction",
    	history = "We named our station after Dr. Cavor, the physicist that invented a barrier material for gravity waves - Cavorite"
	}
	if stationFaction == "Human Navy" then
		stationCavor.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
		if random(1,5) <= 1 then
			stationCavor.comms_data.goods.medicine = {quantity = 5, cost = 5}
			stationCavor.comms_data.trade.luxury = random(1,100) < 33
		else
			if random(1,100) < 50 then
				stationCavor.comms_data.trade.medicine = true
			else
				stationCavor.comms_data.trade.luxury = true
			end
		end
	else
		local whatTrade = random(1,100)
		if whatTrade < 33 then
			stationCavor.comms_data.trade.medicine = true
		elseif whatTrade > 66 then
			stationCavor.comms_data.trade.food = true
		else
			stationCavor.comms_data.trade.luxury = true
		end
	end
	return stationCavor
end
function placeEmory()
	--Emory
	stationEmory = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationEmory:setPosition(psx,psy):setCallSign("Emory"):setDescription("Transporter components")
    stationEmory.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        weapon_cost = 		{Homing = math.random(3),				HVLI = math.random(2),					Mine = math.random(2,4),				Nuke = math.random(12,18),				EMP = math.random(7,10)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	transporter =	{quantity = 5,	cost = 76} },
        trade = {	food = false, medicine = false, luxury = false }
	}
	if stationFaction == "Human Navy" then
		stationEmory.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
		if random(1,5) <= 1 then
			stationEmory.comms_data.goods.medicine = {quantity = 5, cost = 5}
		else
			stationEmory.comms_data.trade.medicine = random(1,100) < 34
		end
	else
		stationEmory.comms_data.trade.medicine = true
		stationEmory.comms_data.trade.food = random(1,100) < 13
	end
	stationEmory.comms_data.trade.luxury = random(1,100) < 43
	return stationEmory
end
function placeVeloquan()
	--Veloquan
	stationVeloquan = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationVeloquan:setPosition(psx,psy):setCallSign("Veloquan"):setDescription("Sensor components")
    stationVeloquan.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	sensor =	{quantity = 5,	cost = 68} },
        trade = {	food = false, medicine = false, luxury = false },
        public_relations = true,
        general_information = "We research and construct components for the most powerful and accurate sensors used aboard ships along with the software to make them easy to use",
    	history = "The Veloquan company has its roots in the manufacturing of LIDAR sensors in the early 21st century on Earth in the United States for autonomous ground-based vehicles. They expanded research and manufacturing operations to include various sensors for space vehicles. Veloquan was the result of numerous mergers and acquisitions of several companies including Velodyne and Quanergy"
	}
	if stationFaction == "Human Navy" then
		stationVeloquan.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
		if random(1,5) <= 1 then
			stationVeloquan.comms_data.goods.medicine = {quantity = 5, cost = 5}
		else
			stationVeloquan.comms_data.trade.medicine = true
		end
	else
		stationVeloquan.comms_data.trade.medicine = true
		stationVeloquan.comms_data.trade.food = true
	end
	return stationVeloquan
end
function placeBarclay()
	--Barclay
	stationBarclay = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationBarclay:setPosition(psx,psy):setCallSign("Barclay"):setDescription("Communication components")
    stationBarclay.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	communication =	{quantity = 5,	cost = 58} },
        trade = {	food = false, medicine = false, luxury = false },
		buy =	{	[randomMineral()] = math.random(40,200)	},
        public_relations = true,
        general_information = "We provide a range of communication equipment and software for use aboard ships",
    	history = "The station is named after Reginald Barclay who established the first transgalactic com link through the creative application of a quantum singularity. Station personnel often refer to the station as the Broccoli station"
	}
	if stationFaction == "Human Navy" then
		stationBarclay.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
		if random(1,5) <= 1 then
			stationBarclay.comms_data.goods.medicine = {quantity = 5, cost = 5}
		else
			stationBarclay.comms_data.trade.medicine = true
		end
	else
		stationBarclay.comms_data.trade.medicine = true
	end
	return stationBarclay
end
function placeLipkin()
	--Lipkin
	stationLipkin = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationLipkin:setPosition(psx,psy):setCallSign("Lipkin"):setDescription("Autodoc components")
    stationLipkin.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	autodoc =	{quantity = 5,	cost = 76} },
        trade = {	food = false, medicine = false, luxury = true },
        public_relations = true,
        general_information = "We build and repair and provide components and upgrades for automated facilities designed for ships where a doctor cannot be a crew member (commonly called autodocs)",
    	history = "The station is named after Dr. Lipkin who pioneered some of the research and application around robot assisted surgery in the area of partial nephrectomy for renal tumors in the early 21st century on Earth"
	}
	if stationFaction == "Human Navy" then
		stationLipkin.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
		if random(1,5) <= 1 then
			stationLipkin.comms_data.goods.medicine = {quantity = 5, cost = 5}
		end
	else
		stationLipkin.comms_data.trade.food = true
	end
	return stationLipkin
end
function placeRipley()
	--Ripley
	stationRipley = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationRipley:setPosition(psx,psy):setCallSign("Ripley"):setDescription("Load lifters and components")
    stationRipley.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	lifter =	{quantity = 5,	cost = 82} },
        trade = {	food = false, medicine = false, luxury = random(1,100) < 47 },
        public_relations = true,
        general_information = "We provide load lifters and components",
    	history = "The station is named after Ellen Ripley who made creative and effective use of one of our load lifters when defending her ship"
	}
	if stationFaction == "Human Navy" then
		stationRipley.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
		if random(1,5) <= 1 then
			stationRipley.comms_data.goods.medicine = {quantity = 5, cost = 5}
		else
			stationRipley.comms_data.trade.medicine = true
		end
	else
		stationRipley.comms_data.trade.food = random(1,100) < 17
		stationRipley.comms_data.trade.medicine = true
	end
	return stationRipley
end
function placeDeckard()
	--Deckard
	stationDeckard = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationDeckard:setPosition(psx,psy):setCallSign("Deckard"):setDescription("Android components")
    stationDeckard.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	android =	{quantity = 5,	cost = 73} },
        trade = {	food = false, medicine = false, luxury = true },
        public_relations = true,
        general_information = "Supplier of android components, programming and service",
    	history = "Named for Richard Deckard who inspired many of the sophisticated safety security algorithms now required for all androids"
	}
	if stationFaction == "Human Navy" then
		stationDeckard.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
		if random(1,5) <= 1 then
			stationDeckard.comms_data.goods.medicine = {quantity = 5, cost = 5}
			stationDeckard.comms_data.goods.medicine.cost = 5
		end
	else
		stationDeckard.comms_data.trade.food = true
	end
	return stationDeckard
end
function placeConnor()
	--Connor 
	stationConnor = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationConnor:setPosition(psx,psy):setCallSign("Connor"):setDescription("Automated weapons systems")
    stationConnor.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",						HVLI = "neutral", 						Mine = "neutral",						Nuke = "neutral", 						EMP = "neutral"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        weapon_cost = 		{Homing = math.random(3),				HVLI = math.random(2),					Mine = math.random(2,4),				Nuke = math.random(12,18),				EMP = math.random(7,10)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {},
        trade = {	food = false, medicine = false, luxury = false },
        public_relations = true,
        general_information = "We research and create automated weapons systems to improve ship combat capability"
	}
	local stationGoodChoice = math.random(1,3)
	if stationGoodChoice == 1 then
		stationConnor.comms_data.goods.shield = {quantity = 5, cost = math.random(85,94)}
	elseif stationGoodChoice == 2 then
		stationConnor.comms_data.goods.beam = {quantity = 5, cost = math.random(62,75)}
	else
		stationConnor.comms_data.goods.lifter = {quantity = 5, cost = math.random(55,89)}
	end
	return stationConnor
end
function placeAnderson()
	--Anderson 
	stationAnderson = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationAnderson:setPosition(psx,psy):setCallSign("Anderson"):setDescription("Battery and software engineering")
    stationAnderson.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	battery =	{quantity = 5,	cost = 66},
        			software =	{quantity = 5,	cost = 115} },
        trade = {	food = false, medicine = false, luxury = true },
        public_relations = true,
        general_information = "We provide high quality high capacity batteries and specialized software for all shipboard systems",
    	history = "The station is named after a fictional software engineer in a late 20th century movie depicting humanity unknowingly conquered by aliens and kept docile by software generated illusion"
	}
	if stationFaction == "Human Navy" then
		stationAnderson.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
		if random(1,5) <= 1 then
			stationAnderson.comms_data.goods.medicine = {quantity = 5, cost = 5}
		end
	end
	return stationAnderson
end
function placeFeynman()
	--Feynman 
	stationFeynman = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationFeynman:setPosition(psx,psy):setCallSign("Feynman"):setDescription("Nanotechnology research")
    stationFeynman.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	software =	{quantity = 5,	cost = 115},
        			nanites =	{quantity = 5,	cost = 79} },
        trade = {	food = false, medicine = false, luxury = true },
        public_relations = true,
        general_information = "We provide nanites and software for a variety of ship-board systems",
    	history = "This station's name recognizes one of the first scientific researchers into nanotechnology, physicist Richard Feynman"
	}
	if stationFaction == "Human Navy" then
		stationFeynman.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
		if random(1,5) <= 1 then
			stationFeynman.comms_data.goods.medicine = {quantity = 5, cost = 5}
		end
	else
		stationFeynman.comms_data.trade.medicine = true
		stationFeynman.comms_data.trade.food = random(1,100) < 26
	end
	return stationFeynman
end
function placeMayo()
	--Mayo
	stationMayo = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationMayo:setPosition(psx,psy):setCallSign("Mayo"):setDescription("Medical Research")
    stationMayo.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	autodoc =	{quantity = 5,	cost = 128},
        			food =		{quantity = 5,	cost = 1},
        			medicine = 	{quantity = 5,	cost = 5} },
        trade = {	food = false, medicine = false, luxury = false },
        public_relations = true,
        general_information = "We research exotic diseases and other human medical conditions",
    	history = "We continue the medical work started by William Worrall Mayo in the late 19th century on Earth"
	}
	return stationMayo
end
function placeNefatha()
	--Nefatha
	stationNefatha = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationNefatha:setPosition(psx,psy):setCallSign("Nefatha"):setDescription("Commerce and recreation")
    stationNefatha.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	luxury =	{quantity = 5,	cost = 70} },
        trade = {	food = false, medicine = false, luxury = false }
	}
	return stationNefatha
end
function placeScience4()
	--Science 4
	stationScience4 = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationScience4:setPosition(psx,psy):setCallSign("Science-4"):setDescription("Biotech research")
    stationScience4.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {},
        trade = {	food = false, medicine = false, luxury = false }
	}
	local stationGoodChoice = math.random(1,3)
	if stationGoodChoice == 1 then
		stationScience4.comms_data.goods.software = {quantity = 5, cost = math.random(85,94)}
	elseif stationGoodChoice == 2 then
		stationScience4.comms_data.goods.circuit = {quantity = 5, cost = math.random(62,75)}
	else
		stationScience4.comms_data.goods.battery = {quantity = 5, cost = math.random(55,89)}
	end
	return stationScience4
end
function placeSpeculation4()
	--Speculation 4
	stationSpeculation4 = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationSpeculation4:setPosition(psx,psy):setCallSign("Speculation 4"):setDescription("Trading post")
    stationSpeculation4.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	luxury =	{quantity = 5,	cost = 60} },
        trade = {	food = false, medicine = false, luxury = false }
	}
	if stationFaction == "Human Navy" then
		stationSpeculation4.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
		if random(1,5) <= 1 then
			stationSpeculation4.comms_data.goods.medicine = {quantity = 5, cost = 5}
		end
	end
	return stationSpeculation4
end
function placeTiberius()
	--Tiberius
	stationTiberius = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationTiberius:setPosition(psx,psy):setCallSign("Tiberius"):setDescription("Logistics coordination")
    stationTiberius.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	food =	{quantity = 5,	cost = 1} },
        trade = {	food = false, medicine = false, luxury = false },
        public_relations = true,
        general_information = "We support the stations and ships in the area with planning and communication services",
    	history = "We recognize the influence of Starfleet Captain James Tiberius Kirk in the 23rd century in our station name"
	}
	return stationTiberius
end
function placeResearch11()
	--Research-11
	stationResearch11 = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationResearch11:setPosition(psx,psy):setCallSign("Research-11"):setDescription("Stress Psychology Research")
    stationResearch11.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {},
        trade = {	food = false, medicine = false, luxury = false }
	}
	local stationGoodChoice = math.random(1,3)
	if stationGoodChoice == 1 then
		stationResearch11.comms_data.goods.warp = {quantity = 5, cost = math.random(85,120)}
	elseif stationGoodChoice == 2 then
		stationResearch11.comms_data.goods.repulsor = {quantity = 5, cost = math.random(62,75)}
	else
		stationResearch11.comms_data.goods.robotic = {quantity = 5, cost = math.random(75,89)}
	end
	return stationResearch11
end
function placeFreena()
	--Freena
	stationFreena = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationFreena:setPosition(psx,psy):setCallSign("Freena"):setDescription("Zero gravity sports and entertainment")
    stationFreena.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	luxury =	{quantity = 5,	cost = 70} },
        trade = {	food = false, medicine = false, luxury = false }
	}
	if stationFaction == "Human Navy" then
		stationFreena.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
		if random(1,5) <= 1 then
			stationFreena.comms_data.goods.medicine = {quantity = 5, cost = 5}
		else
			stationFreena.comms_data.trade.medicine = true
		end
	else
		stationFreena.comms_data.trade.medicine = true
	end
	return stationFreena
end
function placeOutpost33()
	--Outpost 33
	stationOutpost33 = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationOutpost33:setPosition(psx,psy):setCallSign("Outpost-33"):setDescription("Resupply")
    stationOutpost33.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	luxury =	{quantity = 5,	cost = 75} },
        trade = {	food = false, medicine = false, luxury = false }
	}
	return stationOutpost33
end
function placeLando()
	--Lando
	stationLando = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationLando:setPosition(psx,psy):setCallSign("Lando"):setDescription("Casino and Gambling")
    stationLando.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	shield =	{quantity = 5,	cost = 90} },
        trade = {	food = false, medicine = false, luxury = false }
	}
	local stationGoodChoice = math.random(1,3)
	if stationGoodChoice == 1 then
		stationLando.comms_data.goods.luxury = {quantity = 5, cost = math.random(68,81)}
	elseif stationGoodChoice == 2 then
		stationLando.comms_data.goods.gold = {quantity = 5, cost = math.random(61,77)}
	else
		stationLando.comms_data.goods.platinum = {quantity = 5, cost = math.random(65,79)}
	end
	return stationLando
end
function placeKomov()
	--Komov
	stationKomov = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationKomov:setPosition(psx,psy):setCallSign("Komov"):setDescription("Xenopsychology training")
    stationKomov.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	filament =	{quantity = 5,	cost = 46} },
        trade = {	food = false, medicine = false, luxury = false },
        public_relations = true,
        general_information = "We provide classes and simulation to help train diverse species in how to relate to each other",
    	history = "A continuation of the research initially conducted by Dr. Gennady Komov in the early 22nd century on Venus, supported by the application of these principles"
	}
	if stationFaction == "Human Navy" then
		stationKomov.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
		if random(1,5) <= 1 then
			stationKomov.comms_data.goods.medicine = {quantity = 5, cost = 5}
		else
			stationKomov.comms_data.trade.medicine = random(1,100) < 44
		end
	else
		stationKomov.comms_data.trade.medicine = random(1,100) < 44
		stationKomov.comms_data.trade.food = random(1,100) < 24
	end
	return stationKomov
end
function placeScience2()
	--Science 2
	stationScience2 = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationScience2:setPosition(psx,psy):setCallSign("Science-2"):setDescription("Research Lab and Observatory")
    stationScience2.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {},
        trade = {	food = false, medicine = false, luxury = false }
	}
	local stationGoodChoice = math.random(1,3)
	if stationGoodChoice == 1 then
		stationScience2.comms_data.goods.autodoc = {quantity = 5, cost = math.random(85,94)}
	elseif stationGoodChoice == 2 then
		stationScience2.comms_data.goods.android = {quantity = 5, cost = math.random(62,75)}
	else
		stationScience2.comms_data.goods.nanites = {quantity = 5, cost = math.random(55,89)}
	end
	return stationScience2
end
function placePrefect()
	--Prefect
	stationPrefect = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationPrefect:setPosition(psx,psy):setCallSign("Prefect"):setDescription("Textiles and fashion")
    stationPrefect.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	luxury =	{quantity = 5,	cost = 45} },
        trade = {	food = false, medicine = false, luxury = false }
	}
	local stationGoodChoice = math.random(1,3)
	if stationGoodChoice == 1 then
		stationPrefect.comms_data.goods.luxury = {quantity = 5, cost = math.random(69,75)}
	elseif stationGoodChoice == 2 then
		stationPrefect.comms_data.goods.cobalt = {quantity = 5, cost = math.random(55,67)}
	else
		stationPrefect.comms_data.goods.dilithium = {quantity = 5, cost = math.random(61,69)}
	end
	return stationPrefect
end
function placeOutpost7()
	--Outpost 7
	stationOutpost7 = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationOutpost7:setPosition(psx,psy):setCallSign("Outpost-7"):setDescription("Resupply")
    stationOutpost7.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	luxury =	{quantity = 5,	cost = 80} },
        trade = {	food = false, medicine = false, luxury = false }
	}
	return stationOutpost7
end
function placeOrgana()
	--Organa
	stationOrgana = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationOrgana:setPosition(psx,psy):setCallSign("Organa"):setDescription("Diplomatic training")
    stationOrgana.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	luxury =	{quantity = 5,	cost = 96} },
        trade = {	food = false, medicine = false, luxury = false },
        public_relations = true,
        general_information = "The premeire academy for leadership and diplomacy training in the region",
    	history = "Established by the royal family so critical during the political upheaval era"
	}
	return stationOrgana
end
function placeKrak()
	--Krak
	stationKrak = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationKrak:setPosition(psx,psy):setCallSign("Krak"):setDescription("Mining station")
    stationKrak.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	nickel =	{quantity = 5,	cost = 20} },
        trade = {	food = random(1,100) < 50, medicine = true, luxury = random(1,100) < 50 },
		buy =	{	[randomComponent()] = math.random(40,200)	}
	}
	local posAxisKrak = random(0,360)
	local posKrak = random(10000,60000)
	local negKrak = random(10000,60000)
	local spreadKrak = random(4000,7000)
	local negAxisKrak = posAxisKrak + 180
	local xPosAngleKrak, yPosAngleKrak = vectorFromAngle(posAxisKrak, posKrak)
	local posKrakEnd = random(30,70)
	createRandomAlongArc(Asteroid, 30+posKrakEnd, psx+xPosAngleKrak, psy+yPosAngleKrak, posKrak, negAxisKrak, negAxisKrak+posKrakEnd, spreadKrak)
	local xNegAngleKrak, yNegAngleKrak = vectorFromAngle(negAxisKrak, negKrak)
	local negKrakEnd = random(40,80)
	createRandomAlongArc(Asteroid, 30+negKrakEnd, psx+xNegAngleKrak, psy+yNegAngleKrak, negKrak, posAxisKrak, posAxisKrak+negKrakEnd, spreadKrak)
	local krakGoods = random(1,100)
	if krakGoods < 10 then
		stationKrak.comms_data.goods.platinum = {quantity = 5, cost = 70}
		stationKrak.comms_data.goods.tritanium = {quantity = 5, cost = 50}
		stationKrak.comms_data.goods.dilithium = {quantity = 5, cost = 52}
	elseif krakGoods < 20 then
		stationKrak.comms_data.goods.platinum = {quantity = 5, cost = 70}
		stationKrak.comms_data.goods.tritanium = {quantity = 5, cost = 50}
	elseif krakGoods < 30 then
		stationKrak.comms_data.goods.platinum = {quantity = 5, cost = 70}
		stationKrak.comms_data.goods.dilithium = {quantity = 5, cost = 52}
	elseif krakGoods < 40 then
		stationKrak.comms_data.goods.tritanium = {quantity = 5, cost = 50}
		stationKrak.comms_data.goods.dilithium = {quantity = 5, cost = 52}
	elseif krakGoods < 50 then
		stationKrak.comms_data.goods.dilithium = {quantity = 5, cost = 52}
	elseif krakGoods < 60 then
		stationKrak.comms_data.goods.platinum = {quantity = 5, cost = 70}
	elseif krakGoods < 70 then
		stationKrak.comms_data.goods.tritanium = {quantity = 5, cost = 50}
	elseif krakGoods < 80 then
		stationKrak.comms_data.goods.gold = {quantity = 5, cost = 50}
		stationKrak.comms_data.goods.tritanium = {quantity = 5, cost = 50}
	elseif krakGoods < 90 then
		stationKrak.comms_data.goods.gold = {quantity = 5, cost = 50}
		stationKrak.comms_data.goods.dilithium = {quantity = 5, cost = 52}
	else
		stationKrak.comms_data.goods.gold = {quantity = 5, cost = 50}
	end
	return stationKrak
end
function placeGrap()
	--Grap
	stationGrap = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationGrap:setPosition(psx,psy):setCallSign("Grap"):setDescription("Mining station")
    stationGrap.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	nickel =	{quantity = 5,	cost = 20} },
        trade = {	food = random(1,100) < 50, medicine = true, luxury = random(1,100) < 50 },
		buy =	{	[randomComponent()] = math.random(40,200)	}
	}
	local posAxisGrap = random(0,360)
	local posGrap = random(10000,60000)
	local negGrap = random(10000,60000)
	local spreadGrap = random(4000,7000)
	local negAxisGrap = posAxisGrap + 180
	local xPosAngleGrap, yPosAngleGrap = vectorFromAngle(posAxisGrap, posGrap)
	local posGrapEnd = random(30,70)
	createRandomAlongArc(Asteroid, 30+posGrapEnd, psx+xPosAngleGrap, psy+yPosAngleGrap, posGrap, negAxisGrap, negAxisGrap+posGrapEnd, spreadGrap)
	local xNegAngleGrap, yNegAngleGrap = vectorFromAngle(negAxisGrap, negGrap)
	local negGrapEnd = random(40,80)
	createRandomAlongArc(Asteroid, 30+negGrapEnd, psx+xNegAngleGrap, psy+yNegAngleGrap, negGrap, posAxisGrap, posAxisGrap+negGrapEnd, spreadGrap)
	local grapGoods = random(1,100)
	if grapGoods < 10 then
		stationGrap.comms_data.goods.platinum = {quantity = 5, cost = 70}
		stationGrap.comms_data.goods.tritanium = {quantity = 5, cost = 50}
		stationGrap.comms_data.goods.dilithium = {quantity = 5, cost = 52}
	elseif grapGoods < 20 then
		stationGrap.comms_data.goods.platinum = {quantity = 5, cost = 70}
		stationGrap.comms_data.goods.tritanium = {quantity = 5, cost = 50}
	elseif grapGoods < 30 then
		stationGrap.comms_data.goods.platinum = {quantity = 5, cost = 70}
		stationGrap.comms_data.goods.dilithium = {quantity = 5, cost = 52}
	elseif grapGoods < 40 then
		stationGrap.comms_data.goods.tritanium = {quantity = 5, cost = 50}
		stationGrap.comms_data.goods.dilithium = {quantity = 5, cost = 52}
	elseif grapGoods < 50 then
		stationGrap.comms_data.goods.dilithium = {quantity = 5, cost = 52}
	elseif grapGoods < 60 then
		stationGrap.comms_data.goods.platinum = {quantity = 5, cost = 70}
	elseif grapGoods < 70 then
		stationGrap.comms_data.goods.tritanium = {quantity = 5, cost = 50}
	elseif grapGoods < 80 then
		stationGrap.comms_data.goods.gold = {quantity = 5, cost = 50}
		stationGrap.comms_data.goods.tritanium = {quantity = 5, cost = 50}
	elseif grapGoods < 90 then
		stationGrap.comms_data.goods.gold = {quantity = 5, cost = 50}
		stationGrap.comms_data.goods.dilithium = {quantity = 5, cost = 52}
	else
		stationGrap.comms_data.goods.gold = {quantity = 5, cost = 50}
	end
	return stationGrap
end
function placeKruk()
	--Kruk
	stationKruk = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationKruk:setPosition(psx,psy):setCallSign("Kruk"):setDescription("Mining station")
    stationKruk.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	nickel =	{quantity = 5,	cost = math.random(25,35)} },
        trade = {	food = random(1,100) < 50, medicine = random(1,100) < 50, luxury = true },
		buy =	{	[randomComponent()] = math.random(40,200)	}
	}
	local posAxisKruk = random(0,360)
	local posKruk = random(10000,60000)
	local negKruk = random(10000,60000)
	local spreadKruk = random(4000,7000)
	local negAxisKruk = posAxisKruk + 180
	local xPosAngleKruk, yPosAngleKruk = vectorFromAngle(posAxisKruk, posKruk)
	local posKrukEnd = random(30,70)
	createRandomAlongArc(Asteroid, 30+posKrukEnd, psx+xPosAngleKruk, psy+yPosAngleKruk, posKruk, negAxisKruk, negAxisKruk+posKrukEnd, spreadKruk)
	local xNegAngleKruk, yNegAngleKruk = vectorFromAngle(negAxisKruk, negKruk)
	local negKrukEnd = random(40,80)
	createRandomAlongArc(Asteroid, 30+negKrukEnd, psx+xNegAngleKruk, psy+yNegAngleKruk, negKruk, posAxisKruk, posAxisKruk+negKrukEnd, spreadKruk)
	local krukGoods = random(1,100)
	if krukGoods < 10 then
		stationKruk.comms_data.goods.platinum = {quantity = 5, cost = math.random(65,75)}
		stationKruk.comms_data.goods.tritanium = {quantity = 5, cost = math.random(45,55)}
		stationKruk.comms_data.goods.dilithium = {quantity = 5, cost = math.random(45,55)}
	elseif krukGoods < 20 then
		stationKruk.comms_data.goods.platinum = {quantity = 5, cost = math.random(65,75)}
		stationKruk.comms_data.goods.tritanium = {quantity = 5, cost = math.random(45,55)}
	elseif krukGoods < 30 then
		stationKruk.comms_data.goods.platinum = {quantity = 5, cost = math.random(65,75)}
		stationKruk.comms_data.goods.dilithium = {quantity = 5, cost = math.random(45,55)}
	elseif krukGoods < 40 then
		stationKruk.comms_data.goods.tritanium = {quantity = 5, cost = math.random(45,55)}
		stationKruk.comms_data.goods.dilithium = {quantity = 5, cost = math.random(45,55)}
	elseif krukGoods < 50 then
		stationKruk.comms_data.goods.dilithium = {quantity = 5, cost = math.random(45,55)}
	elseif krukGoods < 60 then
		stationKruk.comms_data.goods.platinum = {quantity = 5, cost = math.random(65,75)}
	elseif krukGoods < 70 then
		stationKruk.comms_data.goods.tritanium = {quantity = 5, cost = math.random(45,55)}
	elseif krukGoods < 80 then
		stationKruk.comms_data.goods.gold = {quantity = 5, cost = math.random(45,55)}
		stationKruk.comms_data.goods.tritanium = {quantity = 5, cost = math.random(45,55)}
	elseif krukGoods < 90 then
		stationKruk.comms_data.goods.gold = {quantity = 5, cost = math.random(45,55)}
		stationKruk.comms_data.goods.dilithium = {quantity = 5, cost = math.random(45,55)}
	else
		stationKruk.comms_data.goods.gold = {quantity = 5, cost = math.random(45,55)}
	end
	return stationKruk
end
function placeGrup()
	--Grup
	stationGrup = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationGrup:setPosition(psx,psy):setCallSign("Grup"):setDescription("Mining station")
    stationGrup.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	nickel =	{quantity = 5,	cost = math.random(25,35)} },
        trade = {	food = random(1,100) < 50, medicine = random(1,100) < 50, luxury = true },
		buy =	{	[randomComponent()] = math.random(40,200)	}
	}
	local posAxisGrup = random(0,360)
	local posGrup = random(30000,60000)
	local negGrup = random(10000,30000)
	local spreadGrup = random(5000,8000)
	local negAxisGrup = posAxisGrup + 180
	local xPosAngleGrup, yPosAngleGrup = vectorFromAngle(posAxisGrup, posGrup)
	local posGrupEnd = random(30,70)
	createRandomAlongArc(Asteroid, 30+posGrupEnd, psx+xPosAngleGrup, psy+yPosAngleGrup, posGrup, negAxisGrup, negAxisGrup+posGrupEnd, spreadGrup)
	local xNegAngleGrup, yNegAngleGrup = vectorFromAngle(negAxisGrup, negGrup)
	local negGrupEnd = random(40,80)
	createRandomAlongArc(Asteroid, 30+negGrupEnd, psx+xNegAngleGrup, psy+yNegAngleGrup, negGrup, posAxisGrup, posAxisGrup+negGrupEnd, spreadGrup)
	local grupGoods = random(1,100)
	if grupGoods < 10 then
		stationGrup.comms_data.goods.platinum = {quantity = 5, cost = math.random(65,75)}
		stationGrup.comms_data.goods.tritanium = {quantity = 5, cost = math.random(45,55)}
		stationGrup.comms_data.goods.dilithium = {quantity = 5, cost = math.random(45,55)}
	elseif grupGoods < 20 then
		stationGrup.comms_data.goods.platinum = {quantity = 5, cost = math.random(65,75)}
		stationGrup.comms_data.goods.tritanium = {quantity = 5, cost = math.random(45,55)}
	elseif grupGoods < 30 then
		stationGrup.comms_data.goods.platinum = {quantity = 5, cost = math.random(65,75)}
		stationGrup.comms_data.goods.dilithium = {quantity = 5, cost = math.random(45,55)}
	elseif grupGoods < 40 then
		stationGrup.comms_data.goods.tritanium = {quantity = 5, cost = math.random(45,55)}
		stationGrup.comms_data.goods.dilithium = {quantity = 5, cost = math.random(45,55)}
	elseif grupGoods < 50 then
		stationGrup.comms_data.goods.dilithium = {quantity = 5, cost = math.random(45,55)}
	elseif grupGoods < 60 then
		stationGrup.comms_data.goods.platinum = {quantity = 5, cost = math.random(65,75)}
	elseif grupGoods < 70 then
		stationGrup.comms_data.goods.tritanium = {quantity = 5, cost = math.random(45,55)}
	elseif grupGoods < 80 then
		stationGrup.comms_data.goods.gold = {quantity = 5, cost = math.random(45,55)}
		stationGrup.comms_data.goods.tritanium = {quantity = 5, cost = math.random(45,55)}
	elseif grupGoods < 90 then
		stationGrup.comms_data.goods.gold = {quantity = 5, cost = math.random(45,55)}
		stationGrup.comms_data.goods.dilithium = {quantity = 5, cost = math.random(45,55)}
	else
		stationGrup.comms_data.goods.gold = {quantity = 5, cost = math.random(45,55)}
	end
	return stationGrup
end
function placeOutpost8()
	--Outpost 8
	stationOutpost8 = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationOutpost8:setPosition(psx,psy):setCallSign("Outpost-8")
    stationOutpost8.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {},
        trade = {	food = false, medicine = false, luxury = false }
	}
	local stationGoodChoice = math.random(1,3)
	if stationGoodChoice == 1 then
		stationOutpost8.comms_data.goods.impulse = {quantity = 5, cost = math.random(69,75)}
	elseif stationGoodChoice == 2 then
		stationOutpost8.comms_data.goods.tractor = {quantity = 5, cost = math.random(55,67)}
	else
		stationOutpost8.comms_data.goods.beam = {quantity = 5, cost = math.random(61,69)}
	end
	return stationOutpost8
end
function placeScience7()
	--Science 7
	stationScience7 = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationScience7:setPosition(psx,psy):setCallSign("Science-7"):setDescription("Observatory")
    stationScience7.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	food =	{quantity = 2,	cost = 1} },
        trade = {	food = false, medicine = false, luxury = false }
	}
	return stationScience7
end
function placeCyrus()
	--Cyrus
	stationCyrus = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationCyrus:setPosition(psx,psy):setCallSign("Cyrus"):setDescription("Impulse engine components")
    stationCyrus.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	impulse =	{quantity = 5,	cost = 124} },
        trade = {	food = false, medicine = false, luxury = random(1,100) < 78 },
        public_relations = true,
        general_information = "We supply high quality impulse engines and parts for use aboard ships",
    	history = "This station was named after the fictional engineer, Cyrus Smith created by 19th century author Jules Verne"
	}
	if stationFaction == "Human Navy" then
		stationCyrus.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
		if random(1,5) <= 1 then
			stationCyrus.comms_data.goods.medicine = {quantity = 5, cost = 5}
		else
			stationCyrus.comms_data.trade.medicine = random(1,100) < 34
		end
	else
		stationCyrus.comms_data.trade.medicine = random(1,100) < 34
		stationCyrus.comms_data.trade.food = random(1,100) < 13
	end
	return stationCyrus
end
function placeCalvin()
	--Calvin 
	stationCalvin = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationCalvin:setPosition(psx,psy):setCallSign("Calvin"):setDescription("Robotic research")
    stationCalvin.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	robotic =	{quantity = 5,	cost = 90} },
        trade = {	food = false, medicine = false, luxury = true },
		buy =	{	[randomComponent("robotic")] = math.random(40,200)	},
        public_relations = true,
        general_information = "We research and provide robotic systems and components",
    	history = "This station is named after Dr. Susan Calvin who pioneered robotic behavioral research and programming"
	}
	if stationFaction == "Human Navy" then
		stationCalvin.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
		if random(1,5) <= 1 then
			stationCalvin.comms_data.goods.medicine = {quantity = 5, cost = 5}
		end
	else
		stationCalvin.comms_data.trade.food = random(1,100) < 8
	end
	return stationCalvin
end
--enemy stations
function placeGandala()
	--Gandala
	stationGanalda = SpaceStation():setTemplate(szt()):setFaction(stationFaction)
	stationGanalda:setPosition(psx,psy):setCallSign("Ganalda")
	return stationGanalda
end
function placeEmpok()
	--Empok Nor
	stationEmpok = SpaceStation():setTemplate(szt()):setFaction(stationFaction)
	stationEmpok:setPosition(psx,psy):setCallSign("Empok Nor")
	return stationEmpok
end
function placeTic()
	--Ticonderoga
	stationTic = SpaceStation():setTemplate(szt()):setFaction(stationFaction)
	stationTic:setPosition(psx,psy):setCallSign("Ticonderoga")
	return stationTic
end

function setStations()
	local afd = 30	-- asteroid field density
	stationList = {}
	totalStations = 0
	friendlyStations = 0
	neutralStations = 0
	stationFaction = "Human Navy"
	stationSize = "Huge Station"
	psx = random(-10000,5000)
	psy = random(5000,9000)
	placeVaiken()
	table.insert(stationList,stationVaiken)
	friendlyStations = friendlyStations + 1
	stationSize = "Medium Station"
	psx = random(5000,8000)
	psy = random(-8000,9000)
	placeZefram()
	table.insert(stationList,stationZefram)
	friendlyStations = friendlyStations + 1
	local marconiAngle = random(0,360)
	stationFaction = "Independent"
	stationSize = "Small Station"
	psx, psy = vectorFromAngle(marconiAngle,random(12500,15000))
	placeMarconi()
	table.insert(stationList,stationMarconi)
	neutralStations = neutralStations + 1
	local muddAngle = marconiAngle + random(60,180)
	stationSize = "Medium Station"
	psx, psy = vectorFromAngle(muddAngle,random(12500,15000))
	placeMuddville()
	table.insert(stationList,stationMudd)
	neutralStations = neutralStations + 1
	local alcaleicaAngle = muddAngle + random(60,120)
	stationSize = "Small Station"
	psx, psy = vectorFromAngle(alcaleicaAngle,random(12500,15000))
	placeAlcaleica()
	table.insert(stationList,stationAlcaleica)
	neutralStations = neutralStations + 1
	stationFaction = "Human Navy"
	psx = random(-90000,-70000)
	psy = random(-15000,25000)
	placeCalifornia()
	table.insert(stationList,stationCalifornia)
	friendlyStations = friendlyStations + 1
	stationFaction = "Independent"
	psx = random(35000,50000)
	psy = random(52000,79000)
	placeOutpost15()
	table.insert(stationList,stationOutpost15)
	neutralStations = neutralStations + 1
	placeRandomAroundPoint(Asteroid,25,1,15000,60000,75000)
	psx = random(50000,75000)
	psy = random(52000,61250)
	placeOutpost21()
	table.insert(stationList,stationOutpost21)
	neutralStations = neutralStations + 1
	if stationOutpost15.comms_data.goods.gold == nil and stationOutpost21.comms_data.goods.gold == nil then
		if random(1,100) < 50 then
			stationOutpost21.comms_data.goods.gold = {quantity = 5, cost = math.random(22,30)}
		else
			stationOutpost15.comms_data.goods.gold = {quantity = 5, cost = math.random(22,30)}
		end
	end
	if stationOutpost15.comms_data.goods.cobalt == nil and stationOutpost21.comms_data.goods.cobalt == nil then
		if random(1,100) < 50 then
			stationOutpost21.comms_data.goods.cobalt = {quantity = 4, cost = math.random(45,55)}
		else
			stationOutpost15.comms_data.goods.cobalt = {quantity = 4, cost = math.random(45,55)}
		end
	end
	psx = random(-88000,-65000)
	psy = random(36250,40000)
	placeValero()
	table.insert(stationList,stationValero)
	neutralStations = neutralStations + 1
	local vactelAngle = random(0,360)
	psx, psy = vectorFromAngle(vactelAngle,random(50000,61250))
	placeVactel()
	table.insert(stationList,stationVactel)
	neutralStations = neutralStations + 1
	local archerAngle = vactelAngle + random(60,120)
	psx, psy = vectorFromAngle(archerAngle,random(50000,61250))
	placeArcher()
	table.insert(stationList,stationArcher)
	neutralStations = neutralStations + 1
	local deerAngle = archerAngle + random(60,120)
	psx, psy = vectorFromAngle(deerAngle,random(50000,61250))
	placeDeer()
	table.insert(stationList,stationDeer)
	neutralStations = neutralStations + 1
	local cavorAngle = deerAngle + random(60,90)
	psx, psy = vectorFromAngle(cavorAngle,random(50000,61250))
	placeCavor()
	table.insert(stationList,stationCavor)
	neutralStations = neutralStations + 1
	stationFaction = "Human Navy"
	psx = random(72000,85000)
	psy = random(-50000,-26000)
	placeEmory()
	table.insert(stationList,stationEmory)
	friendlyStations = friendlyStations + 1
	stationFaction = "Independent"
	psx = random(-25000,15000)
	psy = random(27000,40000)
	placeVeloquan()
	table.insert(stationList,stationVeloquan)
	neutralStations = neutralStations + 1
	psx = random(-20000,0)
	psy = random(-45000,-25000)
	placeBarclay()
	table.insert(stationList,stationBarclay)
	neutralStations = neutralStations + 1
	psx = random(20000,45000)
	psy = random(-25000,-15000)
	placeLipkin()
	table.insert(stationList,stationLipkin)
	neutralStations = neutralStations + 1
	psx = random(-75000,-30000)
	psy = random(55000,62150)
	placeRipley()
	table.insert(stationList,stationRipley)
	neutralStations = neutralStations + 1
	psx = random(-45000,-25000)
	psy = random(-25000,-14000)
	placeDeckard()
	table.insert(stationList,stationDeckard)
	neutralStations = neutralStations + 1
	psx = random(-10000,15000)
	psy = random(15000,27000)
	placeConnor()
	table.insert(stationList,stationConnor)
	neutralStations = neutralStations + 1
	psx = random(15000,20000)
	psy = random(-25000,48000)
	placeAnderson()
	table.insert(stationList,stationAnderson)
	neutralStations = neutralStations + 1
	stationFaction = "Human Navy"
	psx = random(-90000,-55000)
	psy = random(25000,36250)
	placeFeynman()
	table.insert(stationList,stationFeynman)
	friendlyStations = friendlyStations + 1
	stationSize = "Large Station"
	psx = random(-45000,-30000)
	psy = random(-14000,12500)
	placeMayo()
	table.insert(stationList,stationMayo)
	friendlyStations = friendlyStations + 1
	stationSize = "Medium Station"
	stationFaction = "Independent"
	psx = random(-10000,12500)
	psy = random(-96000,-80000)
	placeNefatha()
	table.insert(stationList,stationNefatha)
	neutralStations = neutralStations + 1
	psx = random(-60000,-40000)
	psy = random(47000,55000)
	placeScience4()
	table.insert(stationList,stationScience4)
	neutralStations = neutralStations + 1
	stationSize = "Small Station"
	psx = random(-26000,-15000)
	psy = random(-10000,27000)
	placeSpeculation4()
	table.insert(stationList,stationSpeculation4)
	neutralStations = neutralStations + 1
	stationSize = "Medium Station"
	stationFaction = "Human Navy"
	psx = random(-30000,-26000)
	psy = random(-14000,35000)
	placeTiberius()
	table.insert(stationList,stationTiberius)
	friendlyStations = friendlyStations + 1
	stationSize = "Small Station"
	stationFaction = "Independent"
	psx = random(-75000,-55000)
	psy = random(-50000,-25000)
	placeResearch11()
	table.insert(stationList,stationResearch11)
	neutralStations = neutralStations + 1
	psx = random(0,15000)
	psy = random(-37500,-15000)
	placeFreena()
	table.insert(stationList,stationFreena)
	neutralStations = neutralStations + 1
	psx = random(15000,65000)
	psy = random(-65000,-25000)
	placeOutpost33()
	table.insert(stationList,stationOutpost33)
	neutralStations = neutralStations + 1
	psx = random(-60000,-30000)
	psy = random(612500,70000)
	placeLando()
	table.insert(stationList,stationLando)
	neutralStations = neutralStations + 1
	psx = random(-55000,-30000)
	psy = random(70000,80000)
	placeKomov()
	table.insert(stationList,stationKomov)
	neutralStations = neutralStations + 1
	stationSize = "Medium Station"
	psx = random(20000,35000)
	psy = random(55000,70000)
	placeScience2()
	table.insert(stationList,stationScience2)
	neutralStations = neutralStations + 1
	stationSize = "Small Station"
	psx = random(-65000,-60000)
	psy = random(36250,55000)
	placePrefect()
	table.insert(stationList,stationPrefect)
	neutralStations = neutralStations + 1
	psx = random(35000,45000)
	psy = random(-15000,25000)
	placeOutpost7()
	table.insert(stationList,stationOutpost7)
	neutralStations = neutralStations + 1
	psx = random(55000,62000)
	psy = random(20000,45000)
	placeOrgana()
	table.insert(stationList,stationOrgana)
	neutralStations = neutralStations + 1
	psx = random(-60000,15000)
	psy = random(-65000,-61250)
	placeGrap()
	table.insert(stationList,stationGrap)
	neutralStations = neutralStations + 1
	psx = random(-65000,-61250)
	psy = random(-25000,25000)
	placeGrup()
	if stationGrap.comms_data.goods.nickel == nil and stationGrap.comms_data.goods.nickel == nil then
		if random(1,100) < 50 then
			stationGrap.comms_data.goods.nickel = {quantity = 5, cost = math.random(22,30)}
		else
			stationGrup.comms_data.goods.nickel = {quantity = 5, cost = math.random(22,30)}
		end
	end
	if stationGrap.comms_data.goods.tritanium == nil and stationGrap.comms_data.goods.tritanium == nil then
		if random(1,100) < 50 then
			stationGrap.comms_data.goods.tritanium = {quantity = 5, cost = math.random(45,60)}
		else
			stationGrup.comms_data.goods.tritanium = {quantity = 5, cost = math.random(45,60)}
		end
	end
	if stationGrap.comms_data.goods.dilithium == nil and stationGrap.comms_data.goods.dilithium == nil then
		if random(1,100) < 50 then
			stationGrap.comms_data.goods.dilithium = {quantity = 5, cost = math.random(45,60)}
		else
			stationGrup.comms_data.goods.dilithium = {quantity = 5, cost = math.random(45,60)}
		end
	end
	if stationGrap.comms_data.goods.platinum == nil and stationGrap.comms_data.goods.platinum == nil then
		if random(1,100) < 50 then
			stationGrap.comms_data.goods.platinum = {quantity = 5, cost = math.random(65,80)}
		else
			stationGrup.comms_data.goods.platinum = {quantity = 5, cost = math.random(65,80)}
		end
	end
	table.insert(stationList,stationGrup)
	neutralStations = neutralStations + 1
	psx = random(-65000,-40000)
	psy = random(-61250,-50000)
	placeOutpost8()
	table.insert(stationList,stationOutpost8)
	neutralStations = neutralStations + 1
	stationFaction = "Human Navy"
	psx = random(-25000,-20000)
	psy = random(-40000,-10000)
	placeScience7()
	table.insert(stationList,stationScience7)
	friendlyStations = friendlyStations + 1
	stationFaction = "Independent"
	psx = random(20000,35000)
	psy = random(-15000,40000)
	placeCyrus()
	table.insert(stationList,stationCyrus)
	neutralStations = neutralStations + 1
	stationSize = "Medium Station"
	psx = random(40000,86250)
	psy = random(45000,51000)
	placeCalvin()
	table.insert(stationList,stationCalvin)
	neutralStations = neutralStations + 1
	totalStations = neutralStations + friendlyStations
	originalStationList = stationList	--save for statistics
	art1 = Artifact():setModel("artifact4"):allowPickup(false):setScanningParameters(2,2):setRadarSignatureInfo(random(4,20),random(2,12), random(7,13))
	art2 = Artifact():setModel("artifact5"):allowPickup(false):setScanningParameters(2,3):setRadarSignatureInfo(random(2,12),random(7,13), random(4,20))
	art3 = Artifact():setModel("artifact6"):allowPickup(false):setScanningParameters(3,2):setRadarSignatureInfo(random(7,13),random(4,20), random(2,12))
	art1:setPosition(random(-50000,50000),random(-80000,-70000))
	art2:setPosition(random(-90000,-75000),random(-40000,-20000))
	art3:setPosition(random(50000,75000),random(625000,80000))
	local artChoice = math.random(6)
	if artChoice == 1 then
		art1:setDescriptions("Unusual object","Artifact with quantum biometric characteristics")
		art2:setDescriptions("Unusual object","Artifact with embedded chroniton particles")
		art3:setDescriptions("Unusual object","Artifact bridging two parallel universes")
		art1.quantum = true
		art2.chroniton = true
		art3.parallel = true
	elseif artChoice == 2 then
		art1:setDescriptions("Unusual object","Artifact with quantum biometric characteristics")
		art3:setDescriptions("Unusual object","Artifact with embedded chroniton particles")
		art2:setDescriptions("Unusual object","Artifact bridging two parallel universes")
		art1.quantum = true
		art3.chroniton = true
		art2.parallel = true
	elseif artChoice == 3 then
		art2:setDescriptions("Unusual object","Artifact with quantum biometric characteristics")
		art1:setDescriptions("Unusual object","Artifact with embedded chroniton particles")
		art3:setDescriptions("Unusual object","Artifact bridging two parallel universes")
		art2.quantum = true
		art1.chroniton = true
		art3.parallel = true
	elseif artChoice == 4 then
		art2:setDescriptions("Unusual object","Artifact with quantum biometric characteristics")
		art3:setDescriptions("Unusual object","Artifact with embedded chroniton particles")
		art1:setDescriptions("Unusual object","Artifact bridging two parallel universes")
		art2.quantum = true
		art3.chroniton = true
		art1.parallel = true
	elseif artChoice == 5 then
		art3:setDescriptions("Unusual object","Artifact with quantum biometric characteristics")
		art1:setDescriptions("Unusual object","Artifact with embedded chroniton particles")
		art2:setDescriptions("Unusual object","Artifact bridging two parallel universes")
		art3.quantum = true
		art1.chroniton = true
		art2.parallel = true
	else
		art3:setDescriptions("Unusual object","Artifact with quantum biometric characteristics")
		art2:setDescriptions("Unusual object","Artifact with embedded chroniton particles")
		art1:setDescriptions("Unusual object","Artifact bridging two parallel universes")
		art3.quantum = true
		art2.chroniton = true
		art1.parallel = true
	end
	ganaldaAngle = random(0,360)
	stationFaction = "Kraylor"
	local gDist = random(120000,150000)
	psx, psy = vectorFromAngle(ganaldaAngle,gDist)
	local nebula_list = {}
	table.insert(nebula_list,Nebula():setPosition(psx,psy))
	placeGandala()
	local empokAngle = ganaldaAngle + random(60,180)
	if empokAngle == nil then print("empokAngle is nil") end
	psx, psy = vectorFromAngle(empokAngle,random(120000,150000))
	stationFaction = "Exuari"
	stationSize = "Large Station"
	placeEmpok()
	ticAngle = empokAngle + random(60,120)
	stationFaction = "Kraylor"
	stationSize = "Medium Station"
	psx, psy = vectorFromAngle(ticAngle,random(120000,150000))
	placeTic()
	local temp_list = createRandomAlongArc(Nebula, 15, 100000, -100000, 140000, 100, 170, 25000)
	for i=1,#temp_list do
		table.insert(nebula_list,temp_list[i])
	end
	temp_list = createRandomAlongArc(Nebula, 5, 0, 0, gDist,ganaldaAngle-20, ganaldaAngle+20, 9000)
	for i=1,#temp_list do
		table.insert(nebula_list,temp_list[i])
	end
	local nebula_index = 0
	for i=1,#nebula_list do
		nebula_list[i].lose = false
		nebula_list[i].gain = false
	end
	coolant_nebula = {}
	local nebula_count = #nebula_list
	for i=1,math.random(math.floor(nebula_count/2)) do
		nebula_index = math.random(1,#nebula_list)
		table.insert(coolant_nebula,nebula_list[nebula_index])
		table.remove(nebula_list,nebula_index)
		if math.random(1,100) < 50 then
			coolant_nebula[#coolant_nebula].lose = true
		else
			coolant_nebula[#coolant_nebula].gain = true
		end
	end
	alderaan = Planet():setPosition(random(-27000,32000),random(65500,87500)):setPlanetRadius(3000):setDistanceFromMovementPlane(-2000):setCallSign("Alderaan")
	alderaan:setPlanetSurfaceTexture("planets/planet-1.png"):setPlanetCloudTexture("planets/clouds-1.png")
	alderaan:setPlanetAtmosphereTexture("planets/atmosphere.png"):setPlanetAtmosphereColor(0.2,0.2,1.0)
	alderaan:setAxialRotationTime(400.0):setDescription("Lush planet with only mild seasonal variations")
	grawp = BlackHole():setPosition(random(67000,90000),random(-21000,40000)):setCallSign("Grawp")
	grawp.angle = random(0,360)
	grawp.travel = random(1,5)
	-- determine which stations will trade food, luxury items and/or medicine for their goods
	tradeFood = {}
	tradeLuxury = {}
	tradeMedicine = {}
	tradeFood[stationGrap] = true
	if random(1,100) < 50 then tradeLuxury[stationGrap] = true end
	tradeMedicine[stationGrap] = true
	tradeFood[stationGrup] = true
	tradeLuxury[stationGrup] = true
	tradeMedicine[stationGrup] = true
	tradeFood[stationOutpost15] = true
	tradeFood[stationOutpost21] = true
	tradeLuxury[stationOutpost21] = true
	if random(1,100) < 50 then tradeMedicine[stationOutpost21] = true end
	tradeLuxury[stationCarradine] = true
	tradeMedicine[stationCarradine] = true
	tradeFood[stationZefram] = true
	tradeLuxury[stationZefram] = true
	tradeLuxury[stationArcher] = true
	tradeMedicine[stationArcher] = true
	tradeFood[stationDeer] = true
	tradeLuxury[stationDeer] = true
	tradeMedicine[stationDeer] = true
	tradeFood[stationMarconi] = true
	tradeLuxury[stationMarconi] = true
	tradeFood[stationAlcaleica] = true
	tradeMedicine[stationAlcaleica] = true
	tradeLuxury[stationCalvin] = true
	whatTrade = random(1,100)
	if whatTrade < 33 then
		tradeMedicine[stationCavor] = true
	elseif whatTrade > 66 then
		tradeFood[stationCavor] = true
	else
		tradeLuxury[stationCavor] = true
	end
	tradeFood[stationEmory] = true
	tradeLuxury[stationEmory] = true
	tradeMedicine[stationEmory] = true
	tradeFood[stationVeloquan] = true
	tradeMedicine[stationVeloquan] = true
	tradeMedicine[stationBarclay] = true
	tradeFood[stationLipkin] = true
	tradeLuxury[stationLipkin] = true
	tradeMedicine[stationLipkin] = true
	tradeFood[stationRipley] = true
	tradeLuxury[stationRipley] = true
	tradeFood[stationDeckard] = true
	tradeLuxury[stationDeckard] = true
	tradeLuxury[stationAnderson] = true
	tradeFood[stationFeynman] = true
end
--[[-----------------------------------------------------------------
      Transport ship generation and handling 
-----------------------------------------------------------------]]--
function randomStation()
	local stationCount = 0
	for sidx, obj in ipairs(stationList) do
		if obj:isValid() then
			stationCount = stationCount + 1
		else
			table.remove(stationList,sidx)
		end
	end
	local sidx = math.floor(random(1, #stationList + 0.99))
	return stationList[sidx]
end
function nearbyStation(object,pool_size)
	if object == nil then
		return
	end
	if pool_size == nil then
		pool_size = 1
	end
	local temp_list = {}
	local temp_station = nil
	for i=1,#stationList do
		temp_station = stationList[i]
		if temp_station ~= nil and temp_station:isValid() and object ~= temp_station then
			table.insert(temp_list,temp_station)
		end 
	end
	local nearest_distance = 999999
	for i=1,#temp_list do
		temp_station = temp_list[i]
		if temp_station ~= nil and temp_station:isValid() then
			nearest_station = temp_station
			nearest_station_index = i
			local x1, y1 = temp_station:getPosition()
			local x2, y2 = object:getPosition()
			nearest_distance = distance(x1,y1,x2,y2)
			break
		end
	end
	if nearest_station == nil then
		return
	else
		local station_pool = {}
		for i=1,pool_size do
			for j=1,#temp_list do
				temp_station = temp_list[j]
				if temp_station ~= nil and temp_station:isValid() then
					if temp_station == nil then print("temp_station is nil") end
					if object == nil then print("object is nil") end
					local x1, y1 = temp_station:getPosition()
					local x2, y2 = object:getPosition()
					local temp_distance = distance(x1,y1,x2,y2)
					if temp_distance < nearest_distance then
						nearest_station_index = j
						nearest_distance = temp_distance
					end
				end
			end
			if nearest_station_index ~= nil then
				table.insert(station_pool,temp_list[nearest_station_index])
				table.remove(temp_list,nearest_station_index)
			end
			nearest_station_index = nil
			nearest_distance = 999999
		end
		local selected_station = math.random(1,#station_pool)
		return station_pool[selected_station]
	end
end

function randomNearStation5(nobj)
	distanceStations = {}
	cs, rs1 = nearStations(nobj,stationList)
	table.insert(distanceStations,cs)
	cs, rs2 = nearStations(nobj,rs1)
	table.insert(distanceStations,cs)
	cs, rs3 = nearStations(nobj,rs2)
	table.insert(distanceStations,cs)
	cs, rs4 = nearStations(nobj,rs3)
	table.insert(distanceStations,cs)
	cs, rs5 = nearStations(nobj,rs4)
	table.insert(distanceStations,cs)
	return distanceStations[irandom(1,5)]
end

function transportPlot(delta)
	local name = ""
	local transportCount = 0
	if transportSpawnDelay > 0 then
		transportSpawnDelay = transportSpawnDelay - delta
	end
	if transportSpawnDelay < 0 then
		transportSpawnDelay = delta + random(5,15)
		transportCount = 0
		for tidx, obj in ipairs(transportList) do
			if obj ~= nil and obj:isValid() then
				if obj.target ~= nil and obj.target:isValid() then
					if obj:isDocked(obj.target) then
						if obj.undock_delay > 0 then
							obj.undock_delay = obj.undock_delay - 1
						else
							obj.target = nearbyStation(obj,5)
							obj.undock_delay = irandom(1,4)
							obj:orderDock(obj.target)
						end
					end
				else
					obj.target = nearbyStation(obj,8)
				end
				transportCount = transportCount + 1
			end
		end
		if transportCount < #transportList then
			local tempTransportList = {}
			for _, obj in ipairs(transportList) do
				if obj:isValid() then
					table.insert(tempTransportList,obj)
				end
			end
			transportList = tempTransportList
		end
		if #transportList < #stationList then
			local target = randomStation()
			local rnd = irandom(1,5)
			if rnd == 1 then
				name = "Personnel"
			elseif rnd == 2 then
				name = "Goods"
			elseif rnd == 3 then
				name = "Garbage"
			elseif rnd == 4 then
				name = "Equipment"
			else
				name = "Fuel"
			end
			if irandom(1,100) < 30 then
				name = name .. " Jump Freighter " .. irandom(3, 5)
			else
				name = name .. " Freighter " .. irandom(1, 5)
			end
			local obj = CpuShip():setTemplate(name):setFaction('Independent'):setCommsScript(""):setCommsFunction(commsShip)
			obj:setCallSign(generateCallSign())
			obj.target = target
			obj.undock_delay = irandom(1,4)
			obj:orderDock(obj.target)
			local x, y = obj.target:getPosition()
			local xd, yd = vectorFromAngle(random(0, 360), random(25000, 40000))
			obj:setPosition(x + xd, y + yd)
			table.insert(transportList, obj)
		end
	end
end
--[[-----------------------------------------------------------------
      Station communication 
-----------------------------------------------------------------]]--
function commsStation()
    if comms_target.comms_data == nil then
        comms_target.comms_data = {}
    end
    mergeTables(comms_target.comms_data, {
        friendlyness = random(0.0, 100.0),
        weapons = {
            Homing = "neutral",
            HVLI = "neutral",
            Mine = "neutral",
            Nuke = "friend",
            EMP = "friend"
        },
        weapon_cost = {
            Homing = 2,
            HVLI = 2,
            Mine = 2,
            Nuke = 15,
            EMP = 10
        },
        services = {
            supplydrop = "friend",
            reinforcements = "friend",
			fighters = "friend",
        },
        service_cost = {
            supplydrop = 100,
            reinforcements = 150,
			fighterInterceptor = math.random(125,175),
			fighterBomber = math.random(150,200),
			fighterScout = math.random(175,225)
        },
        reputation_cost_multipliers = {
            friend = 1.0,
            neutral = 2.5
        },
        max_weapon_refill_amount = {
            friend = 1.0,
            neutral = 0.5
        }
    })
    comms_data = comms_target.comms_data
	setPlayers()
    if comms_source:isEnemy(comms_target) then
        return false
    end
    if comms_target:areEnemiesInRange(5000) then
        setCommsMessage("We are under attack! No time for chatting!");
        return true
    end
    if not comms_source:isDocked(comms_target) then
        handleUndockedState()
    else
        handleDockedState()
    end
    return true
end

function handleDockedState()
	local ctd = comms_target.comms_data
	local oMsg = ""
    if comms_source:isFriendly(comms_target) then
		oMsg = "Good day, officer!\nWhat can we do for you today?\n"
    else
		oMsg = "Welcome to our lovely station.\n"
    end
    if comms_target:areEnemiesInRange(20000) then
		oMsg = oMsg .. "Forgive us if we seem a little distracted. We are carefully monitoring the enemies nearby."
	end
	setCommsMessage(oMsg)
	local missilePresence = 0
	for _, missile_type in ipairs(missile_types) do
		missilePresence = missilePresence + comms_source:getWeaponStorageMax(missile_type)
	end
	if missilePresence > 0 then
		if 	(ctd.weapon_available.Nuke   and comms_source:getWeaponStorageMax("Nuke") > 0)   or 
			(ctd.weapon_available.EMP    and comms_source:getWeaponStorageMax("EMP") > 0)    or 
			(ctd.weapon_available.Homing and comms_source:getWeaponStorageMax("Homing") > 0) or 
			(ctd.weapon_available.Mine   and comms_source:getWeaponStorageMax("Mine") > 0)   or 
			(ctd.weapon_available.HVLI   and comms_source:getWeaponStorageMax("HVLI") > 0)   then
			addCommsReply("I need ordnance restocked", function()
				setCommsMessage("What type of ordnance?")
				for _, missile_type in ipairs(missile_types) do
					if comms_source:getWeaponStorageMax(missile_type) > 0 then
						addCommsReply(missile_type .. " (" .. getWeaponCost(missile_type) .. "rep each)", function()
							handleWeaponRestock(missile_type)
						end)
					end
				end
			end)
		end
	end
	if comms_source:isFriendly(comms_target) then
		addCommsReply("What are my current orders?", function()
			local ordMsg = primaryOrders .. secondaryOrders .. optionalOrders
			if playWithTimeLimit then
				ordMsg = ordMsg .. string.format("\n   %i Minutes remain in game",math.floor(gameTimeLimit/60))
			end
			setCommsMessage(ordMsg)
			addCommsReply("Back", commsStation)
		end)
	end
	if isAllowedTo(comms_target.comms_data.services.fighters) and comms_source.carrier then
		addCommsReply("Visit shipyard", function()
			setCommsMessage("Here you can start fighters that can be taken by your pilots. You do have a fighter pilot waiting, do you?")
			addCommsReply(string.format("Purchase unmanned MP52 Hornet Interceptor for %i reputation", getServiceCost("fighterInterceptor")), function()
				if not comms_source:takeReputationPoints(getServiceCost("fighterInterceptor")) then
					setCommsMessage("Insufficient reputation")
				else
					local ship = PlayerSpaceship():setTemplate("MP52 Hornet"):setFactionId(comms_source:getFactionId())
					setPlayers()
					ship:setPosition(comms_target:getPosition())
					setCommsMessage("We have dispatched " .. ship:getCallSign() .. " to be manned by one of your pilots")
				end
				addCommsReply("Back", commsStation)
			end)
			addCommsReply(string.format("Purchase unmanned ZX-Lindworm Bomber for %i reputation", getServiceCost("fighterBomber")), function()
				if not comms_source:takeReputationPoints(getServiceCost("fighterBomber")) then
					setCommsMessage("Insufficient reputation")
				else
					local ship = PlayerSpaceship():setTemplate("ZX-Lindworm"):setFactionId(comms_source:getFactionId())
					setPlayers()
					ship:setPosition(comms_target:getPosition())
					setCommsMessage("We have dispatched " .. ship:getCallSign() .. " to be manned by one of your pilots")
				end
				addCommsReply("Back", commsStation)
			end)
			addCommsReply(string.format("Purchase unmanned Adder MK7 Scout for %i reputation", getServiceCost("fighterScout")), function()
				if not comms_source:takeReputationPoints(getServiceCost("fighterScout")) then
					setCommsMessage("Insufficient reputation")
				else
					local ship = PlayerSpaceship():setTemplate("Adder MK7"):setFactionId(comms_source:getFactionId())
					setPlayers()
					ship:setPosition(comms_target:getPosition())
					setCommsMessage("We have dispatched " .. ship:getCallSign() .. " to be manned by one of your pilots")
				end
				addCommsReply("Back", commsStation)
			end)
			addCommsReply("Back", commsStation)
		end)
	end
	if goods[comms_target] ~= nil then
		addCommsReply("Buy, sell, trade", function()
			oMsg = "Goods or components available here: quantity, cost in reputation\n"
			gi = 1		-- initialize goods index
			repeat
				goodsType = goods[comms_target][gi][1]
				goodsQuantity = goods[comms_target][gi][2]
				goodsRep = goods[comms_target][gi][3]
				oMsg = oMsg .. string.format("     %s: %i, %i\n",goodsType,goodsQuantity,goodsRep)
				gi = gi + 1
			until(gi > #goods[comms_target])
			oMsg = oMsg .. "Current Cargo:\n"
			gi = 1
			cargoHoldEmpty = true
			repeat
				playerGoodsType = goods[player][gi][1]
				playerGoodsQuantity = goods[player][gi][2]
				if playerGoodsQuantity > 0 then
					oMsg = oMsg .. string.format("     %s: %i\n",playerGoodsType,playerGoodsQuantity)
					cargoHoldEmpty = false
				end
				gi = gi + 1
			until(gi > #goods[player])
			if cargoHoldEmpty then
				oMsg = oMsg .. "     Empty\n"
			end
			playerRep = math.floor(player:getReputationPoints())
			oMsg = oMsg .. string.format("Available Space: %i, Available Reputation: %i\n",player.cargo,playerRep)
			setCommsMessage(oMsg)
			-- Buttons for reputation purchases
			gi = 1
			repeat
				local goodsType = goods[comms_target][gi][1]
				local goodsQuantity = goods[comms_target][gi][2]
				local goodsRep = goods[comms_target][gi][3]
				addCommsReply(string.format("Buy one %s for %i reputation",goods[comms_target][gi][1],goods[comms_target][gi][3]), function()
					oMsg = string.format("Type: %s, Quantity: %i, Rep: %i",goodsType,goodsQuantity,goodsRep)
					if player.cargo < 1 then
						oMsg = oMsg .. "\nInsufficient cargo space for purchase"
					elseif goodsRep > playerRep then
						oMsg = oMsg .. "\nInsufficient reputation for purchase"
					elseif goodsQuantity < 1 then
						oMsg = oMsg .. "\nInsufficient station inventory"
					else
						if not player:takeReputationPoints(goodsRep) then
							oMsg = oMsg .. "\nInsufficient reputation for purchase"
						else
							player.cargo = player.cargo - 1
							decrementStationGoods(goodsType)
							incrementPlayerGoods(goodsType)
							oMsg = oMsg .. "\npurchased"
						end
					end
					setCommsMessage(oMsg)
					addCommsReply("Back", commsStation)
				end)
				gi = gi + 1
			until(gi > #goods[comms_target])
			-- Buttons for food trades
			if tradeFood[comms_target] ~= nil then
				gi = 1
				foodQuantity = 0
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
						addCommsReply(string.format("Trade food for %s",goods[comms_target][gi][1]), function()
							oMsg = string.format("Type: %s,  Quantity: %i",goodsType,goodsQuantity)
							if goodsQuantity < 1 then
								oMsg = oMsg .. "\nInsufficient station inventory"
							else
								decrementStationGoods(goodsType)
								incrementPlayerGoods(goodsType)
								decrementPlayerGoods("food")
								oMsg = oMsg .. "\nTraded"
							end
							setCommsMessage(oMsg)
							addCommsReply("Back", commsStation)
						end)
						gi = gi + 1
					until(gi > #goods[comms_target])
				end
			end
			-- Buttons for luxury trades
			if tradeLuxury[comms_target] ~= nil then
				gi = 1
				luxuryQuantity = 0
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
						addCommsReply(string.format("Trade luxury for %s",goods[comms_target][gi][1]), function()
							oMsg = string.format("Type: %s,  Quantity: %i",goodsType,goodsQuantity)
							if goodsQuantity < 1 then
								oMsg = oMsg .. "\nInsufficient station inventory"
							else
								decrementStationGoods(goodsType)
								incrementPlayerGoods(goodsType)
								decrementPlayerGoods("luxury")
								oMsg = oMsg .. "\nTraded"
							end
							setCommsMessage(oMsg)
							addCommsReply("Back", commsStation)
						end)
						gi = gi + 1
					until(gi > #goods[comms_target])
				end
			end
			-- Buttons for medicine trades
			if tradeMedicine[comms_target] ~= nil then
				gi = 1
				medicineQuantity = 0
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
						addCommsReply(string.format("Trade medicine for %s",goods[comms_target][gi][1]), function()
							oMsg = string.format("Type: %s,  Quantity: %i",goodsType,goodsQuantity)
							if goodsQuantity < 1 then
								oMsg = oMsg .. "\nInsufficient station inventory"
							else
								decrementStationGoods(goodsType)
								incrementPlayerGoods(goodsType)
								decrementPlayerGoods("medicine")
								oMsg = oMsg .. "\nTraded"
							end
							setCommsMessage(oMsg)
							addCommsReply("Back", commsStation)
						end)
						gi = gi + 1
					until(gi > #goods[comms_target])
				end
			end
			addCommsReply("Back", commsStation)
		end)
	end
	if sensorBase ~= nil then
		if comms_target == sensorBase then
			gi = 1
			s1PartQuantity = 0
			s2PartQuantity = 0
			s3PartQuantity = 0
			repeat
				if goods[player][gi][1] == s1part then
					s1PartQuantity = goods[player][gi][2]
				end
				if goods[player][gi][1] == s2part then
					s2PartQuantity = goods[player][gi][2]
				end
				if goods[player][gi][1] == s3part then
					s3PartQuantity = goods[player][gi][2]
				end
				gi = gi + 1
			until(gi > #goods[player])
			if s1PartQuantity > 0 and s2PartQuantity > 0 and s3PartQuantity > 0 then
				addCommsReply(string.format("Provide %s, %s and %s for sensor upgrade",s1part,s2part,s3part), function()
					decrementPlayerGoods(s1part)
					decrementPlayerGoods(s2part)
					decrementPlayerGoods(s3part)
					player.cargo = player.cargo + 3
					if stettorTarget == nil then
						if stationGanalda:isValid() then
							stettorTarget = stationGanalda
						elseif stationTic:isValid() then
							stettorTarget = stationTic
						else
							stettorTarget = stationEmpok
						end
					end
					oMsg = string.format("Our upgraded sensors found an enemy base in sector %s",stettorTarget:getSectorName())
					player.stettor = "provided"
					setCommsMessage(oMsg)
					addCommsReply("Back", commsStation)
				end)
			end
		end
	end
	if plotR == horizonStationDeliver then
		if comms_target == stationEmory then
			if player.horizonComponents == nil then
				gi = 1
				hr1partQuantity = 0
				hr2partQuantity = 0
				repeat
					if goods[player][gi][1] == hr1part then
						hr1partQuantity = goods[player][gi][2]
					end
					if goods[player][gi][1] == hr2part then
						hr2partQuantity = goods[player][gi][2]
					end
					gi = gi + 1
				until(gi > #goods[player])
				if hr1partQuantity > 0 and hr2partQuantity > 0 then
					addCommsReply(string.format("Provide %s and %s for black hole research",hr1part,hr2part), function()
						decrementPlayerGoods(hr1part)
						decrementPlayerGoods(hr2part)
						player.cargo = player.cargo + 2
						bhsMsg = "With the materials you supplied, we installed special sensors on your ship. "
						bhsMsg = bhsMsg .. "We need you to get close to the black hole and run sensor sweeps. "
						bhsMsg = bhsMsg .. "Your science console will have the controls when your ship is in range."
						bhsMsg = bhsMsg .. "\nThe mobile black hole was last seen in sector " .. grawp:getSectorName()
						setCommsMessage(bhsMsg)
						player.horizonComponents = "provided"
					end)
				end
			end
		end
	end
	if plotO == beamRangeUpgrade then
		if comms_target == stationMarconi then
			if player.beamComponents == nil then
				gi = 1
				br1partQuantity = 0
				br2partQuantity = 0
				br3partQuantity = 0
				repeat
					if goods[player][gi][1] == br1part then
						br1partQuantity = goods[player][gi][2]
					end
					if goods[player][gi][1] == br2part then
						br2partQuantity = goods[player][gi][2]
					end
					if goods[player][gi][1] == br3part then
						br3partQuantity = goods[player][gi][2]
					end
					gi = gi + 1
				until(gi > #goods[player])
				if br1partQuantity > 0 and br2partQuantity > 0 and br3partQuantity > 0 then
					addCommsReply(string.format("Provide %s, %s and %s for beam research project",br1part,br2part,br3part), function()
						decrementPlayerGoods(br1part)
						decrementPlayerGoods(br2part)
						decrementPlayerGoods(br3part)
						player.cargo = player.cargo + 3
						setCommsMessage("With the goods you provided, we completed our advanced beam weapons prototype. We transmitted our research results to Vaiken. The next time you dock at Vaiken, you can have the range of your beam weapons upgraded.")
						player.beamComponents = "provided"
					end)
				end
			end
		end
	end
	if plotO == impulseSpeedUpgrade then
		if comms_target == stationCarradine then
			if player.impulseSpeedComponents == nil then
				--impulseSpeedUpgradeAvailable
				gi = 1
				is1partQuantity = 0
				is2partQuantity = 0
				repeat
					if goods[player][gi][1] == is1part then
						is1partQuantity = goods[player][gi][2]
					end
					if goods[player][gi][1] == is2part then
						is2partQuantity = goods[player][gi][2]
					end
					gi = gi + 1
				until(gi > #goods[player])
				if is1partQuantity > 0 and is2partQuantity > 0 then
					addCommsReply(string.format("Provide %s and %s for impulse engine research project",is1part,is2part), function()
						decrementPlayerGoods(is1part)
						decrementPlayerGoods(is2part)
						player.cargo = player.cargo + 2
						setCommsMessage("[Nikhil Morrison] With the goods you provided, I completed the impulse engine research. I transmitted the research results to Vaiken. The next time you dock at Vaiken, you can have the speed of your impulse engines improved.")
						player.impulseSpeedComponents = "provided"
					end)
				end
			end
		end
	end
	if plotO == spinUpgrade then
		if comms_target == spinBase then
			if player.spinComponents == nil then
				gi = 1
				sp1partQuantity = 0
				sp2partQuantity = 0
				sp3partQuantity = 0
				repeat
					if goods[player][gi][1] == sp1part then
						sp1partQuantity = goods[player][gi][2]
					end
					if goods[player][gi][1] == sp2part then
						sp2partQuantity = goods[player][gi][2]
					end
					if goods[player][gi][1] == sp3part then
						sp3partQuantity = goods[player][gi][2]
					end
					gi = gi + 1
				until(gi > #goods[player])
				if sp1partQuantity > 0 and sp2partQuantity > 0 and sp3partQuantity > 0 then
					addCommsReply(string.format("Provide %s, %s and %s for maneuver research project",sp1part,sp2part,sp3part), function()
						decrementPlayerGoods(sp1part)
						decrementPlayerGoods(sp2part)
						decrementPlayerGoods(sp3part)
						player.cargo = player.cargo + 3
						setCommsMessage("[Maneuver technician] With the goods you provided, we completed the maneuver research and transmitted the research results to Vaiken. The next time you dock at Vaiken, you can have your ship's maneuver speed improved.")
						player.spinComponents = "provided"
					end)
				end
			end
		end
	end
	if comms_target == stationVaiken then
		if beamRangeUpgradeAvailable then
			addCommsReply("Apply Marconi station beam range upgrade", function()
				if player.marconiBeamUpgrade then
					setCommsMessage("You already have the upgrade")
				else
					tempBeam = psb[player:getTypeName()]
					if tempBeam == nil then
						setCommsMessage("Your ship type does not support a beam weapon upgrade.")
					else
						for b=0,tempBeam-1 do
							newRange = player:getBeamWeaponRange(b) * 1.25
							tempCycle = player:getBeamWeaponCycleTime(b)
							tempDamage = player:getBeamWeaponDamage(b)
							tempArc = player:getBeamWeaponArc(b)
							tempDirection = player:getBeamWeaponDirection(b)
							player:setBeamWeapon(b,tempArc,tempDirection,newRange,tempCycle,tempDamage)
						end
						player.marconiBeamUpgrade = true
						setCommsMessage("Your beam range has been improved by 25 percent")
					end
				end
			end)
		end
		if impulseSpeedUpgradeAvailable then
			addCommsReply("Apply Nikhil Morrison impulse engine upgrade", function()
				if player.morrisonUpgrade then
					setCommsMessage("You already have the upgrade")
				else
					player:setImpulseMaxSpeed(player:getImpulseMaxSpeed()*1.25)
					player.morrisonUpgrade = true
					setCommsMessage("Your impulse engine speed has been improved by 25 percent")
				end
			end)
		end
		if spinUpgradeAvailable then
			addCommsReply("Apply maneuver upgrade", function()
				if player.spinUpgrade then
					setCommsMessage("You already have the upgrade")
				else
					player:setRotationMaxSpeed(player:getRotationMaxSpeed()*2)
					player.spinUpgrade = true
					setCommsMessage("Your spin speed has been doubled")
				end
			end)
		end
		if shieldUpgradeAvailable then
			addCommsReply("Apply Phillip Organa shield upgrade", function()
				if player.shieldUpgrade then
					setCommsMessage("You already have the upgrade")
				else
					frontShieldValue = player:getShieldMax(0)
					rearShieldValue = player:getShieldMax(1)
					player:setShieldsMax(frontShieldValue*1.25,rearShieldValue*1.25)
					player.shieldUpgrade = true
					setCommsMessage("Your shield capacity has been increased by 25 percent")
				end
			end)
		end
		if beamDamageUpgradeAvailable then
			addCommsReply("Apply Nefatha beam damage upgrade", function()
				if player.nefathaUpgrade then
					setCommsMessage("You already have the upgrade")
				else
					tempBeam = psb[player:getTypeName()]
					if tempBeam == nil then
						setCommsMessage("Your ship type does not support a beam weapon upgrade.")
					else
						for b=0,tempBeam-1 do
							tempRange = player:getBeamWeaponRange(b)
							tempCycle = player:getBeamWeaponCycleTime(b)
							newDamage = player:getBeamWeaponDamage(b) * 1.25
							tempArc = player:getBeamWeaponArc(b)
							tempDirection = player:getBeamWeaponDirection(b)
							player:setBeamWeapon(b,tempArc,tempDirection,tempRange,tempCycle,newDamage)
						end
						player.nefathaUpgrade = true
						setCommsMessage("Your beam weapons damage has improved by 25 percent")
					end
				end
			end)
		end
	end
--	if comms_target == stationEmory then
--		if diagnostic then
--			addCommsReply("Turn off test script diagnostic", function()
--				diagnostic = false
--				setCommsMessage("Diagnostic turned off")
--				addCommsReply("Back", commsStation)
--			end)
--		else
--			addCommsReply("Turn on test script diagnostic", function()
--				diagnostic = true
--				setCommsMessage("Diagnostic turned on")
--				addCommsReply("Back", commsStation)
--			end)
--		end
--	end
end

function getServiceCost(service)
    return math.ceil(comms_data.service_cost[service])
end

function isAllowedTo(state)
    if state == "friend" and comms_source:isFriendly(comms_target) then
        return true
    end
    if state == "neutral" and not comms_source:isEnemy(comms_target) then
        return true
    end
    return false
end

function handleWeaponRestock(weapon)
    if not comms_source:isDocked(comms_target) then 
		setCommsMessage("You need to stay docked for that action.")
		return
	end
    if not isAllowedTo(comms_data.weapons[weapon]) then
        if weapon == "Nuke" then setCommsMessage("We do not deal in weapons of mass destruction.")
        elseif weapon == "EMP" then setCommsMessage("We do not deal in weapons of mass disruption.")
        else setCommsMessage("We do not deal in those weapons.") end
        return
    end
    local points_per_item = getWeaponCost(weapon)
    local item_amount = math.floor(comms_source:getWeaponStorageMax(weapon) * comms_data.max_weapon_refill_amount[getFriendStatus()]) - comms_source:getWeaponStorage(weapon)
    if item_amount <= 0 then
        if weapon == "Nuke" then
            setCommsMessage("All nukes are charged and primed for destruction.");
        else
            setCommsMessage("Sorry, sir, but you are as fully stocked as I can allow.");
        end
        addCommsReply("Back", commsStation)
    else
		if comms_source:getReputationPoints() > points_per_item * item_amount then
			if comms_source:takeReputationPoints(points_per_item * item_amount) then
				comms_source:setWeaponStorage(weapon, comms_source:getWeaponStorage(weapon) + item_amount)
				if comms_source:getWeaponStorage(weapon) == comms_source:getWeaponStorageMax(weapon) then
					setCommsMessage("You are fully loaded and ready to explode things.")
				else
					setCommsMessage("We generously resupplied you with some weapon charges.\nPut them to good use.")
				end
			else
				setCommsMessage("Not enough reputation.")
				return
			end
		else
			if comms_source:getReputationPoints() > points_per_item then
				setCommsMessage("You can't afford as much as I'd like to give you")
				addCommsReply("Get just one", function()
					if comms_source:takeReputationPoints(points_per_item) then
						comms_source:setWeaponStorage(weapon, comms_source:getWeaponStorage(weapon) + 1)
						if comms_source:getWeaponStorage(weapon) == comms_source:getWeaponStorageMax(weapon) then
							setCommsMessage("You are fully loaded and ready to explode things.")
						else
							setCommsMessage("We generously resupplied you with one weapon charge.\nPut it to good use.")
						end
					else
						setCommsMessage("Not enough reputation.")
					end
					return
				end)
			else
				setCommsMessage("Not enough reputation.")
				return				
			end
		end
        addCommsReply("Back", commsStation)
    end
end

function getWeaponCost(weapon)
    return math.ceil(comms_data.weapon_cost[weapon] * comms_data.reputation_cost_multipliers[getFriendStatus()])
end

function handleUndockedState()
    --Handle communications when we are not docked with the station.
    local oMsg = ""
    if comms_source:isFriendly(comms_target) then
        oMsg = "Good day, officer.\nIf you need supplies, please dock with us first."
    else
        oMsg = "Greetings.\nIf you want to do business, please dock with us first."
    end
    if comms_target:areEnemiesInRange(20000) then
		oMsg = oMsg .. "\nBe aware that if enemies in the area get much closer, we will be too busy to conduct business with you."
	end
	setCommsMessage(oMsg)
 	addCommsReply("I need information", function()
 		local ctd = comms_target.comms_data
		setCommsMessage("What kind of information do you need?")
		addCommsReply("See any enemies in your area?", function()
			if comms_source:isFriendly(comms_target) then
				local enemiesInRange = 0
				for _, obj in ipairs(comms_target:getObjectsInRange(30000)) do
					if obj:isEnemy(comms_source) then
						enemiesInRange = enemiesInRange + 1
					end
				end
				if enemiesInRange > 0 then
					if enemiesInRange > 1 then
						setCommsMessage(string.format("Yes, we see %i enemies within 30U",enemiesInRange))
					else
						setCommsMessage("Yes, we see one enemy within 30U")						
					end
					comms_source:addReputationPoints(2.0)					
				else
					setCommsMessage("No enemies within 30U")
					comms_source:addReputationPoints(1.0)
				end
				addCommsReply("Back", commsStation)
			else
				setCommsMessage("Not really")
				comms_source:addReputationPoints(1.0)
				addCommsReply("Back", commsStation)
			end
		end)
		addCommsReply("Where can I find particular goods?", function()
			gkMsg = "Friendly stations generally have food or medicine or both. Neutral stations often trade their goods for food, medicine or luxury."
			if comms_target.goodsKnowledge == nil then
				gkMsg = gkMsg .. " Beyond that, I have no knowledge of specific stations.\n\nCheck back later, someone else may have better knowledge"
				setCommsMessage(gkMsg)
				addCommsReply("Back", commsStation)
				fillStationBrains()
			else
				if #comms_target.goodsKnowledge == 0 then
					gkMsg = gkMsg .. " Beyond that, I have no knowledge of specific stations"
				else
					gkMsg = gkMsg .. " I've heard about these goods:"
					for gk=1,#comms_target.goodsKnowledge do
						addCommsReply(comms_target.goodsKnowledgeType[gk],function()
							setCommsMessage(string.format("Station %s in sector %s has %s%s",comms_target.goodsKnowledge[gk],comms_target.goodsKnowledgeSector[gk],comms_target.goodsKnowledgeType[gk],comms_target.goodsKnowledgeTrade[gk]))
							addCommsReply("Back", commsStation)
						end)
					end
				end
				setCommsMessage(gkMsg)
				addCommsReply("Back", commsStation)
			end
		end)
	end)
	if player:isFriendly(comms_target) then
		addCommsReply("What are my current orders?", function()
			ordMsg = primaryOrders .. secondaryOrders .. optionalOrders
			if playWithTimeLimit then
				ordMsg = ordMsg .. string.format("\n   %i Minutes remain in game",math.floor(gameTimeLimit/60))
			end
			setCommsMessage(ordMsg)
			addCommsReply("Back", commsStation)
		end)
	end
	if diagnostic then
		addCommsReply("Diagnostic data", function()
			if playWithTimeLimit then
				dMsg = string.format("Game time remaining: %f",gameTimeLimit)
			else
				dMsg = string.format("Clue message time remaining: %f",clueMessageDelay)
			end
			for p12idx=1, MAX_PLAYER_SHIPS do
				p12 = getPlayerShip(p12idx)
				if p12 ~= nil and p12:isValid() then
					dMsg = dMsg .. string.format("\nPlayer %i: %s in sector %s",p12idx,p12:getCallSign(),p12:getSectorName())
				end
			end
			if plotR == nil then
				addCommsReply("Choose required mission", function()
					if stettorMission ~= "done" then
						if playWithTimeLimit then
							if gameTimeLimit > 1800 then
								addCommsReply("Stettor", function()
									chooseSensorBase()
									chooseSensorParts()
									plotR = stettorOrderMessage
								end)
							end
						else
							addCommsReply("Stettor", function()
								chooseSensorBase()
								chooseSensorParts()
								plotR = stettorOrderMessage
							end)						
						end
					end
					if undercutMission ~= "done" then
						if playWithTimeLimit then
							if gameTimeLimit > 2400 then
								addCommsReply("Undercut", function()
									mPart = 1
									plotR = undercutOrderMessage
									chooseUndercutBase()
								end)
							end
						else
							addCommsReply("Undercut", function()
								mPart = 1
								plotR = undercutOrderMessage
								chooseUndercutBase()
							end)						
						end
					end
					if horizonMission ~= "done" then
						if playWithTimeLimit then
							if gameTimeLimit > 2400 then
								addCommsReply("Horizon", function()
									chooseHorizonParts()
									plotR = horizonOrderMessage
								end)
							end
						else
							addCommsReply("Horizon", function()
								chooseHorizonParts()
								plotR = horizonOrderMessage
							end)						
						end
					end
					if sporiskyMission ~= "done" then
						if playWithTimeLimit then
							if gameTimeLimit > 1700 then
								addCommsReply("Sporisky", function()
									chooseTraitorBase()
									plotR = traitorOrderMessage
								end)
							end
						else
							addCommsReply("Sporisky", function()
								chooseTraitorBase()
								plotR = traitorOrderMessage
							end)						
						end
					end
					addCommsReply("Back", commsStation)
				end)
			elseif plotR == undercutStation then
				dMsg = dMsg .. "\nUndercut station: hide base: " .. hideBase:getCallSign()
				dMsg = dMsg .. "\nundercut location: " .. undercutLocation
			elseif plotR == undercutTransport then
				dMsg = dMsg .. "\nundercut location: " .. undercutLocation
				dMsg = dMsg .. "\nhide transport: " .. hideTransport:getCallSign() .. " in sector " .. hideTransport:getSectorName()
			elseif plotR == undercutEnemyBase then
				dMsg = dMsg .. "\nundercut enemy base: " .. undercutTarget:getCallSign() .. " in sector " .. undercutTarget:getSectorName()
			elseif plotR == horizonStationDeliver then
				dMsg = dMsg .. string.format("\nhorizon station deliver part1: %s, part2: %s",hr1part,hr2part)
				if player.horizonComponents == nil then
					dMsg = dMsg .. "\nplayer horizon components: nil"
				else
					dMsg = dMsg .. "\nplayer horizon components: " .. player.horizonComponents
				end
			end
			if plotO == nil then
				addCommsReply("Choose optional mission", function()
					if beamRangePlot ~= "done" then
						addCommsReply("beam range", function()
							chooseBeamRangeParts()
							plotO = beamRangeMessage				
						end)
					end
					if impulseSpeedPlot ~= "done" then
						addCommsReply("impulse speed", function()
							impulseSpeedParts()
							plotO = impulseSpeedMessage
						end)
					end
					if spinPlot ~= "done" then
						addCommsReply("spin speed", function()
							chooseSpinBaseParts()
							plotO = spinMessage						
						end)
					end
					if quantumArtPlot ~= "done" then
						addCommsReply("quantum artifact", function()
							plotO = quantumArtMessage
						end)
					end
					if beamDamagePlot ~= "done" then
						addCommsReply("beam damage", function()
							chooseBeamDamageParts()
							plotO = beamDamageMessage
						end)
					end
					addCommsReply("Back", commsStation)
				end)
			end
			setCommsMessage(dMsg)
			addCommsReply("Back", commsStation)
		end)
	end
	if isAllowedTo(comms_target.comms_data.services.supplydrop) then
        addCommsReply("Can you send a supply drop? ("..getServiceCost("supplydrop").."rep)", function()
            if player:getWaypointCount() < 1 then
                setCommsMessage("You need to set a waypoint before you can request backup.");
            else
                setCommsMessage("To which waypoint should we deliver your supplies?");
                for n=1,player:getWaypointCount() do
                    addCommsReply("WP" .. n, function()
                        if player:takeReputationPoints(getServiceCost("supplydrop")) then
                            local position_x, position_y = comms_target:getPosition()
                            local target_x, target_y = player:getWaypoint(n)
                            local script = Script()
                            script:setVariable("position_x", position_x):setVariable("position_y", position_y)
                            script:setVariable("target_x", target_x):setVariable("target_y", target_y)
                            script:setVariable("faction_id", comms_target:getFactionId()):run("supply_drop.lua")
                            setCommsMessage("We have dispatched a supply ship toward WP" .. n);
                        else
                            setCommsMessage("Not enough reputation!");
                        end
                        addCommsReply("Back", commsStation)
                    end)
                end
            end
            addCommsReply("Back", commsStation)
        end)
    end
    if isAllowedTo(comms_target.comms_data.services.reinforcements) then
        addCommsReply("Please send reinforcements! ("..getServiceCost("reinforcements").."rep)", function()
            if player:getWaypointCount() < 1 then
                setCommsMessage("You need to set a waypoint before you can request reinforcements.");
            else
                setCommsMessage("To which waypoint should we dispatch the reinforcements?");
                for n=1,player:getWaypointCount() do
                    addCommsReply("WP" .. n, function()
                        if player:takeReputationPoints(getServiceCost("reinforcements")) then
                            ship = CpuShip():setFactionId(comms_target:getFactionId()):setPosition(comms_target:getPosition()):setTemplate("Adder MK5"):setScanned(true):orderDefendLocation(player:getWaypoint(n))
                            setCommsMessage("We have dispatched " .. ship:getCallSign() .. " to assist at WP" .. n);
                        else
                            setCommsMessage("Not enough reputation!");
                        end
                        addCommsReply("Back", commsStation)
                    end)
                end
            end
            addCommsReply("Back", commsStation)
        end)
    end
end

function fillStationBrains()
	comms_target.goodsKnowledge = {}
	comms_target.goodsKnowledgeSector = {}
	comms_target.goodsKnowledgeType = {}
	comms_target.goodsKnowledgeTrade = {}
	knowledgeCount = 0
	knowledgeMax = 10
	for sti=1,#stationList do
		if stationList[sti] ~= nil and stationList[sti]:isValid() then
			for gi=1,#goods[stationList[sti]] do
				if math.random(1,10) == 1 then
					table.insert(comms_target.goodsKnowledge,stationList[sti]:getCallSign())
					table.insert(comms_target.goodsKnowledgeSector,stationList[sti]:getSectorName())
					table.insert(comms_target.goodsKnowledgeType,goods[stationList[sti]][gi][1])
					tradeString = ""
					stationTrades = false
					if tradeMedicine[stationList[sti]] ~= nil then
						tradeString = " and will trade it for medicine"
						stationTrades = true
					end
					if tradeFood[stationList[sti]] ~= nil then
						if stationTrades then
							tradeString = tradeString .. " or food"
						else
							tradeString = tradeString .. " and will trade it for food"
							stationTrades = true
						end
					end
					if tradeLuxury[stationList[sti]] ~= nil then
						if stationTrades then
							tradeString = tradeString .. " or luxury"
						else
							tradeString = tradeString .. " and will trade it for luxury"
						end
					end
					table.insert(comms_target.goodsKnowledgeTrade,tradeString)
					knowledgeCount = knowledgeCount + 1
					if knowledgeCount >= knowledgeMax then
						return
					end
				end
			end
		end
	end
end

function getFriendStatus()
    if comms_source:isFriendly(comms_target) then
        return "friend"
    else
        return "neutral"
    end
end
--[[-----------------------------------------------------------------
      Ship communication 
-----------------------------------------------------------------]]--
function commsShip()
	if comms_target.comms_data == nil then
		comms_target.comms_data = {friendlyness = random(0.0, 100.0)}
	end
	if goods[comms_target] == nil then
		goods[comms_target] = {goodsList[irandom(1,#goodsList)][1], 1, random(20,80)}
	end
	comms_data = comms_target.comms_data
	setPlayers()
	for p4idx=1, MAX_PLAYER_SHIPS do
		p4obj = getPlayerShip(p4idx)
		if p4obj ~= nil and p4obj:isValid() then
			if p4obj:isCommsOpening() then
				player = p4obj
			end
		end
	end	
	if player:isFriendly(comms_target) then
		return friendlyComms(comms_data)
	end
	if comms_source:isEnemy(comms_target) and comms_target:isFriendOrFoeIdentifiedBy(comms_source) then
		return enemyComms(comms_data)
	end
	return neutralComms(comms_data)
end

function friendlyComms(comms_data)
	if comms_data.friendlyness < 20 then
		setCommsMessage("What do you want?");
	else
		setCommsMessage("Sir, how can we assist?");
	end
	addCommsReply("Defend a waypoint", function()
		if comms_source:getWaypointCount() == 0 then
			setCommsMessage("No waypoints set. Please set a waypoint first.");
			addCommsReply("Back", commsShip)
		else
			setCommsMessage("Which waypoint should we defend?");
			for n=1,comms_source:getWaypointCount() do
				addCommsReply("Defend WP" .. n, function()
					comms_target:orderDefendLocation(comms_source:getWaypoint(n))
					setCommsMessage("We are heading to assist at WP" .. n ..".");
					addCommsReply("Back", commsShip)
				end)
			end
		end
	end)
	if comms_data.friendlyness > 0.2 then
		addCommsReply("Assist me", function()
			setCommsMessage("Heading toward you to assist.");
			comms_target:orderDefendTarget(comms_source)
			addCommsReply("Back", commsShip)
		end)
	end
	addCommsReply("Report status", function()
		local msg = "Hull: " .. math.floor(comms_target:getHull() / comms_target:getHullMax() * 100) .. "%\n"
		shields = comms_target:getShieldCount()
		if shields == 1 then
			msg = msg .. "Shield: " .. math.floor(comms_target:getShieldLevel(0) / comms_target:getShieldMax(0) * 100) .. "%\n"
		elseif shields == 2 then
			msg = msg .. "Front Shield: " .. math.floor(comms_target:getShieldLevel(0) / comms_target:getShieldMax(0) * 100) .. "%\n"
			msg = msg .. "Rear Shield: " .. math.floor(comms_target:getShieldLevel(1) / comms_target:getShieldMax(1) * 100) .. "%\n"
		else
			for n=0,shields-1 do
				msg = msg .. "Shield " .. n .. ": " .. math.floor(comms_target:getShieldLevel(n) / comms_target:getShieldMax(n) * 100) .. "%\n"
			end
		end

		missile_types = {'Homing', 'Nuke', 'Mine', 'EMP', 'HVLI'}
		for i, missile_type in ipairs(missile_types) do
			if comms_target:getWeaponStorageMax(missile_type) > 0 then
					msg = msg .. missile_type .. " Missiles: " .. math.floor(comms_target:getWeaponStorage(missile_type)) .. "/" .. math.floor(comms_target:getWeaponStorageMax(missile_type)) .. "\n"
			end
		end

		setCommsMessage(msg);
		addCommsReply("Back", commsShip)
	end)
	for _, obj in ipairs(comms_target:getObjectsInRange(5000)) do
		if obj.typeName == "SpaceStation" and not comms_target:isEnemy(obj) then
			addCommsReply("Dock at " .. obj:getCallSign(), function()
				setCommsMessage("Docking at " .. obj:getCallSign() .. ".");
				comms_target:orderDock(obj)
				addCommsReply("Back", commsShip)
			end)
		end
	end
	return true
end

function neutralComms(comms_data)
	local shipType = comms_target:getTypeName()
	if shipType:find("Freighter") ~= nil then
		if comms_data.friendlyness > 66 then
			setCommsMessage("Yes?")
			-- Offer destination information
			addCommsReply("Where are you headed?", function()
				setCommsMessage(comms_target.target:getCallSign())
				addCommsReply("Back", commsShip)
			end)
			-- Offer to trade goods if goods or equipment freighter
			if distance(player,comms_target) < 5000 then
				if shipType:find("Goods") ~= nil or shipType:find("Equipment") ~= nil then
					gi = 1
					luxuryQuantity = 0
					repeat
						if goods[player][gi][1] == "luxury" then
							luxuryQuantity = goods[player][gi][2]
						end
						gi = gi + 1
					until(gi > #goods[player])
					if luxuryQuantity > 0 then
--						oMsg = "Goods or components available from freighter: quantity, cost in reputation\n"
--						gi = 1		-- initialize goods index
--						repeat
--							goodsType = goods[comms_target][gi][1]
--							goodsQuantity = goods[comms_target][gi][2]
--							goodsRep = goods[comms_target][gi][3]
--							oMsg = oMsg .. string.format("     %s: %i, %i\n",goodsType,goodsQuantity,goodsRep)
--							gi = gi + 1
--						until(gi > #goods[comms_target])
--						oMsg = oMsg .. "Current Cargo:\n"
--						gi = 1
--						cargoHoldEmpty = true
--						repeat
--							playerGoodsType = goods[player][gi][1]
--							playerGoodsQuantity = goods[player][gi][2]
--							if playerGoodsQuantity > 0 then
--								oMsg = oMsg .. string.format("     %s: %i\n",playerGoodsType,playerGoodsQuantity)
--								cargoHoldEmpty = false
--							end
--							gi = gi + 1
--						until(gi > #goods[player])
--						if cargoHoldEmpty then
--							oMsg = oMsg .. "     Empty\n"
--						end
--						playerRep = math.floor(player:getReputationPoints())
--						oMsg = oMsg .. string.format("Available Space: %i, Available Reputation: %i\n",player.cargo,playerRep)
--						setCommsMessage(oMsg)
						gi = 1
						repeat
							local goodsType = goods[comms_target][gi][1]
							local goodsQuantity = goods[comms_target][gi][2]
							addCommsReply(string.format("Trade luxury for %s",goods[comms_target][gi][1]), function()
								if goodsQuantity < 1 then
									setCommsMessage("Insufficient inventory on freighter for trade")
								else
									decrementShipGoods(goodsType)
									incrementPlayerGoods(goodsType)
									decrementPlayerGoods("luxury")
									setCommsMessage("Traded")
								end
								addCommsReply("Back", commsShip)
							end)
							gi = gi + 1
						until(gi > #goods[comms_target])
					else
						setCommsMessage("Insufficient luxury to trade")
					end
					addCommsReply("Back", commsShip)
				else
					-- Offer to sell goods
--					oMsg = "Goods or components available here: quantity, cost in reputation\n"
--					gi = 1		-- initialize goods index
--					repeat
--						goodsType = goods[comms_target][gi][1]
--						goodsQuantity = goods[comms_target][gi][2]
--						goodsRep = goods[comms_target][gi][3]
--						oMsg = oMsg .. string.format("     %s: %i, %i\n",goodsType,goodsQuantity,goodsRep)
--						gi = gi + 1
--					until(gi > #goods[comms_target])
--					oMsg = oMsg .. "Current Cargo:\n"
--					gi = 1
--					cargoHoldEmpty = true
--					repeat
--						playerGoodsType = goods[player][gi][1]
--						playerGoodsQuantity = goods[player][gi][2]
--						if playerGoodsQuantity > 0 then
--							oMsg = oMsg .. string.format("     %s: %i\n",playerGoodsType,playerGoodsQuantity)
--							cargoHoldEmpty = false
--						end
--						gi = gi + 1
--					until(gi > #goods[player])
--					if cargoHoldEmpty then
--						oMsg = oMsg .. "     Empty\n"
--					end
--					playerRep = math.floor(player:getReputationPoints())
--					oMsg = oMsg .. string.format("Available Space: %i, Available Reputation: %i\n",player.cargo,playerRep)
--					setCommsMessage(oMsg)
					gi = 1
					repeat
						local goodsType = goods[comms_target][gi][1]
						local goodsQuantity = goods[comms_target][gi][2]
						local goodsRep = goods[comms_target][gi][3]
						addCommsReply(string.format("Buy one %s for %i reputation",goods[comms_target][gi][1],goods[comms_target][gi][3]), function()
							if player.cargo < 1 then
								setCommsMessage("Insufficient cargo space for purchase")
							elseif goodsQuantity < 1 then
								setCommsMessage("Insufficient inventory on freighter")
							else
								if not player:takeReputationPoints(goodsRep) then
									setCommsMessage("Insufficient reputation for purchase")
								else
									player.cargo = player.cargo - 1
									decrementShipGoods(goodsType)
									incrementPlayerGoods(goodsType)
									setCommsMessage("Purchased")
								end
							end
							addCommsReply("Back", commsShip)
						end)
						gi = gi + 1
					until(gi > #goods[comms_target])
				end
			end
		elseif comms_data.friendlyness > 33 then
			setCommsMessage("What do you want?")
			-- Offer to sell destination information
			local destRep = random(1,5)
			addCommsReply(string.format("Where are you headed? (cost: %f reputation)",destRep), function()
				if not comms_source:takeReputationPoints(destRep) then
					setCommsMessage("Insufficient reputation")
				else
					setCommsMessage(comms_target.target:getCallSign())
				end
				addCommsReply("Back", commsShip)
			end)
			-- Offer to sell goods if goods or equipment freighter
			if distance(player,comms_target) < 5000 then
				if shipType:find("Goods") ~= nil or shipType:find("Equipment") ~= nil then
--					oMsg = "Goods or components available here: quantity, cost in reputation\n"
--					gi = 1		-- initialize goods index
--					repeat
--						goodsType = goods[comms_target][gi][1]
--						goodsQuantity = goods[comms_target][gi][2]
--						goodsRep = goods[comms_target][gi][3]
--						oMsg = oMsg .. string.format("     %s: %i, %i\n",goodsType,goodsQuantity,goodsRep)
--						gi = gi + 1
--					until(gi > #goods[comms_target])
--					oMsg = oMsg .. "Current Cargo:\n"
--					gi = 1
--					cargoHoldEmpty = true
--					repeat
--						playerGoodsType = goods[player][gi][1]
--						playerGoodsQuantity = goods[player][gi][2]
--						if playerGoodsQuantity > 0 then
--							oMsg = oMsg .. string.format("     %s: %i\n",playerGoodsType,playerGoodsQuantity)
--							cargoHoldEmpty = false
--						end
--						gi = gi + 1
--					until(gi > #goods[player])
--					if cargoHoldEmpty then
--						oMsg = oMsg .. "     Empty\n"
--					end
--					playerRep = math.floor(player:getReputationPoints())
--					oMsg = oMsg .. string.format("Available Space: %i, Available Reputation: %i\n",player.cargo,playerRep)
--					setCommsMessage(oMsg)
					gi = 1
					repeat
						local goodsType = goods[comms_target][gi][1]
						local goodsQuantity = goods[comms_target][gi][2]
						local goodsRep = goods[comms_target][gi][3]
						addCommsReply(string.format("Buy one %s for %i reputation",goods[comms_target][gi][1],goods[comms_target][gi][3]), function()
							if player.cargo < 1 then
								setCommsMessage("Insufficient cargo space for purchase")
							elseif goodsQuantity < 1 then
								setCommsMessage("Insufficient inventory on freighter")
							else
								if not player:takeReputationPoints(goodsRep) then
									setCommsMessage("Insufficient reputation for purchase")
								else
									player.cargo = player.cargo - 1
									decrementShipGoods(goodsType)
									incrementPlayerGoods(goodsType)
									setCommsMessage("Purchased")
								end
							end
							addCommsReply("Back", commsShip)
						end)
						gi = gi + 1
					until(gi > #goods[comms_target])
				else
					-- Offer to sell goods double price
--					oMsg = "Goods or components available here: quantity, cost in reputation\n"
--					gi = 1		-- initialize goods index
--					repeat
--						goodsType = goods[comms_target][gi][1]
--						goodsQuantity = goods[comms_target][gi][2]
--						goodsRep = goods[comms_target][gi][3]*2
--						oMsg = oMsg .. string.format("     %s: %i, %i\n",goodsType,goodsQuantity,goodsRep)
--						gi = gi + 1
--					until(gi > #goods[comms_target])
--					oMsg = oMsg .. "Current Cargo:\n"
--					gi = 1
--					cargoHoldEmpty = true
--					repeat
--						playerGoodsType = goods[player][gi][1]
--						playerGoodsQuantity = goods[player][gi][2]
--						if playerGoodsQuantity > 0 then
--							oMsg = oMsg .. string.format("     %s: %i\n",playerGoodsType,playerGoodsQuantity)
--							cargoHoldEmpty = false
--						end
--						gi = gi + 1
--					until(gi > #goods[player])
--					if cargoHoldEmpty then
--						oMsg = oMsg .. "     Empty\n"
--					end
--					playerRep = math.floor(player:getReputationPoints())
--					oMsg = oMsg .. string.format("Available Space: %i, Available Reputation: %i\n",player.cargo,playerRep)
--					setCommsMessage(oMsg)
					gi = 1
					repeat
						local goodsType = goods[comms_target][gi][1]
						local goodsQuantity = goods[comms_target][gi][2]
						local goodsRep = goods[comms_target][gi][3]*2
						addCommsReply(string.format("Buy one %s for %i reputation",goods[comms_target][gi][1],goods[comms_target][gi][3]*2), function()
							if player.cargo < 1 then
								setCommsMessage("Insufficient cargo space for purchase")
							elseif goodsQuantity < 1 then
								setCommsMessage("Insufficient inventory on freighter")
							else
								if not player:takeReputationPoints(goodsRep) then
									setCommsMessage("Insufficient reputation for purchase")
								else
									player.cargo = player.cargo - 1
									decrementShipGoods(goodsType)
									incrementPlayerGoods(goodsType)
									setCommsMessage("Purchased")
								end
							end
							addCommsReply("Back", commsShip)
						end)
						gi = gi + 1
					until(gi > #goods[comms_target])
				end
			end
		else
			setCommsMessage("Why are you bothering me?")
			-- Offer to sell goods if goods or equipment freighter double price
			if distance(player,comms_target) < 5000 then
				if shipType:find("Goods") ~= nil or shipType:find("Equipment") ~= nil then
--					oMsg = "Goods or components available here: quantity, cost in reputation\n"
--					gi = 1		-- initialize goods index
--					repeat
--						goodsType = goods[comms_target][gi][1]
--						goodsQuantity = goods[comms_target][gi][2]
--						goodsRep = goods[comms_target][gi][3]*2
--						oMsg = oMsg .. string.format("     %s: %i, %i\n",goodsType,goodsQuantity,goodsRep)
--						gi = gi + 1
--					until(gi > #goods[comms_target])
--					oMsg = oMsg .. "Current Cargo:\n"
--					gi = 1
--					cargoHoldEmpty = true
--					repeat
--						playerGoodsType = goods[player][gi][1]
--						playerGoodsQuantity = goods[player][gi][2]
--						if playerGoodsQuantity > 0 then
--							oMsg = oMsg .. string.format("     %s: %i\n",playerGoodsType,playerGoodsQuantity)
--							cargoHoldEmpty = false
--						end
--						gi = gi + 1
--					until(gi > #goods[player])
--					if cargoHoldEmpty then
--						oMsg = oMsg .. "     Empty\n"
--					end
--					playerRep = math.floor(player:getReputationPoints())
--					oMsg = oMsg .. string.format("Available Space: %i, Available Reputation: %i\n",player.cargo,playerRep)
--					setCommsMessage(oMsg)
					gi = 1
					repeat
						local goodsType = goods[comms_target][gi][1]
						local goodsQuantity = goods[comms_target][gi][2]
						local goodsRep = goods[comms_target][gi][3]*2
						addCommsReply(string.format("Buy one %s for %i reputation",goods[comms_target][gi][1],goods[comms_target][gi][3]*2), function()
							if player.cargo < 1 then
								setCommsMessage("Insufficient cargo space for purchase")
							elseif goodsQuantity < 1 then
								setCommsMessage("Insufficient inventory on freighter")
							else
								if not player:takeReputationPoints(goodsRep) then
									setCommsMessage("Insufficient reputation for purchase")
								else
									player.cargo = player.cargo - 1
									decrementShipGoods(goodsType)
									incrementPlayerGoods(goodsType)
									setCommsMessage("Purchased")
								end
							end
							addCommsReply("Back", commsShip)
						end)
						gi = gi + 1
					until(gi > #goods[comms_target])
				end
			end
		end
		if undercutLocation == "transport" then
			if distance(player,comms_target) < 5000 then
				if comms_target == hideTransport then
					addCommsReply("I need to talk to Charles Undercut", function()
						setCommsMessage("[Charles Undercut] Haven't you destroyed my life enough?")
						addCommsReply("We need the information you obtained about enemies in this region", function()
							setCommsMessage("That will cost you something more than just pretty words. Got any luxury, gold or platinum goods?")
							gi = 1
							luxuryQuantity = 0
							goldQuantity = 0
							platinumQuantity = 0
							repeat
								if goods[player][gi][1] == "luxury" then
									luxuryQuantity = goods[player][gi][2]
								end
								if goods[player][gi][1] == "gold" then
									goldQuantity = goods[player][gi][2]
								end
								if goods[player][gi][1] == "platinum" then
									platinumQuantity = goods[player][gi][2]
								end
								gi = gi + 1
							until(gi > #goods[player])
							if luxuryQuantity > 0 then
								addCommsReply("Trade luxury for information", function()
									decrementPlayerGoods("luxury")
									player.cargo = player.cargo + 1
									if stationGanalda:isValid() then
										undercutTarget = stationGanalda
									elseif stationEmpok:isValid() then
										undercutTarget = stationEmpok
									else
										undercutTarget = stationTic
									end
									player:addToShipLog("enemy base identified in sector " .. undercutTarget:getSectorName(),"Magenta")
									setCommsMessage("I found an enemy base in sector " .. undercutTarget:getSectorName())
									undercutLocation = "free"
								end)
							end
							if goldQuantity > 0 then
								addCommsReply("Trade gold for information", function()
									decrementPlayerGoods("gold")
									player.cargo = player.cargo + 1
									if stationEmpok:isValid() then
										undercutTarget = stationEmpok
									elseif stationGanalda:isValid() then
										undercutTarget = stationGanalda
									else
										undercutTarget = stationTic
									end
									player:addToShipLog("enemy base identified in sector " .. undercutTarget:getSectorName(),"Magenta")
									setCommsMessage("I found an enemy base in sector " .. undercutTarget:getSectorName())
									undercutLocation = "free"
								end)
							end
							if platinumQuantity > 0 then
								addCommsReply("Trade platinum for information", function()
									decrementPlayerGoods("platinum")
									player.cargo = player.cargo + 1
									if stationTic:isValid() then
										undercutTarget = stationTic
									elseif stationGanalda:isValid() then
										undercutTarget = stationGanalda
									else
										undercutTarget = stationEmpok
									end
									player:addToShipLog("enemy base identified in sector " .. undercutTarget:getSectorName(),"Magenta")
									setCommsMessage("I found an enemy base in sector " .. undercutTarget:getSectorName())
									undercutLocation = "free"
								end)
							end
							addCommsReply("Back", commsShip)
						end)
					end)
				end
			end
		end
		if plotR == sporiskyTransport then
			if comms_target == runTransport then
				if comms_source == nil then print("comms_source 6 is nil") end
				if comms_target == nil then print("comms_target 6 is nil") end
				local x1, y1 = comms_source:getPosition()
				local x2, y2 = comms_target:getPosition()
				if distance(x1,y1,x2,y2) < 5000 then
					if sporiskyLocation ~= "aboard ship" then
						addCommsReply("We need you to hand over Annette Sporisky", function()
							local asMsg = "Why should we? Despite what you may have heard, she is not related to this freighter's owner. "
							asMsg = asMsg .. "However, she's obviously valuable. I'll hand her over for something I can trade, "
							asMsg = asMsg .. "one of the following types of goods: "
							if as1part == nil then
								local as1choice = math.floor(random(1,3))
								if as1choice == 1 then
									as1part = "dilithium"
								elseif as1choice == 2 then
									as1part = "platinum"
								else
									as1part = "gold"
								end
							end
							if as2part == nil then
								local as2choice = math.floor(random(1,3))
								if as2choice == 1 then
									as2part = "nanites"
								elseif as2choice == 2 then
									as2part = "impulse"
								else
									as2part = "communication"
								end
							end
							if as3part == nil then
								local as3choice = math.floor(random(1,3))
								if as3choice == 1 then
									as3part = "optic"
								elseif as3choice == 2 then
									as3part = "lifter"
								else
									as3part = "filament"
								end
							end
							asMsg = asMsg .. as1part .. ", " .. as2part .. " or " .. as3part
							setCommsMessage(asMsg)
							gi = 1
							as1partQuantity = 0
							as2partQuantity = 0
							as3partQuantity = 0
							repeat
								if goods[player][gi][1] == as1part then
									as1partQuantity = goods[player][gi][2]
								end
								if goods[player][gi][1] == as2part then
									as2partQuantity = goods[player][gi][2]
								end
								if goods[player][gi][1] == as3part then
									as3partQuantity = goods[player][gi][2]
								end
								gi = gi + 1
							until(gi > #goods[player])
							if as1partQuantity > 0 then
								addCommsReply("Trade " .. as1part .. " for Annette Sporisky", function()
									decrementPlayerGoods(as1part)
									player.cargo = player.cargo + 1
									player.traitorBought = true
									player:addToShipLog("Annette Sporisky aboard","Magenta")
									setCommsMessage("Traded")
									sporiskyTarget = stationGanalda
									sporiskyLocation = "aboard ship"
								end)
							end
							if as2partQuantity > 0 then
								addCommsReply("Trade " .. as2part .. " for Annette Sporisky", function()
									decrementPlayerGoods(as2part)
									player.cargo = player.cargo + 1
									player.traitorBought = true
									player:addToShipLog("Annette Sporisky aboard","Magenta")
									setCommsMessage("Traded")
									sporiskyTarget = stationEmpok
									sporiskyLocation = "aboard ship"
								end)
							end
							if as3partQuantity > 0 then
								addCommsReply("Trade " .. as3part .. " for Annette Sporisky", function()
									decrementPlayerGoods(as3part)
									player.cargo = player.cargo + 1
									player.traitorBought = true
									player:addToShipLog("Annette Sporisky aboard","Magenta")
									setCommsMessage("Traded")
									sporiskyTarget = stationTic
									sporiskyLocation = "aboard ship"
								end)
							end
							addCommsReply("Back", commsShip)
						end)
					end
				end
			end
		end
	else
		if comms_data.friendlyness > 50 then
			setCommsMessage("Sorry, we have no time to chat with you.\nWe are on an important mission.");
		else
			setCommsMessage("We have nothing for you.\nGood day.");
		end
	end
	return true
end
--[[-----------------------------------------------------------------
      Cargo management 
-----------------------------------------------------------------]]--
function incrementPlayerGoods(goodsType)
	local gi = 1
	repeat
		if goods[player][gi][1] == goodsType then
			goods[player][gi][2] = goods[player][gi][2] + 1
		end
		gi = gi + 1
	until(gi > #goods[player])
end

function decrementPlayerGoods(goodsType)
	local gi = 1
	repeat
		if goods[player][gi][1] == goodsType then
			goods[player][gi][2] = goods[player][gi][2] - 1
		end
		gi = gi + 1
	until(gi > #goods[player])
end

function decrementStationGoods(goodsType)
	local gi = 1
	repeat
		if goods[comms_target][gi][1] == goodsType then
			goods[comms_target][gi][2] = goods[comms_target][gi][2] - 1
		end
		gi = gi + 1
	until(gi > #goods[comms_target])
end

function decrementShipGoods(goodsType)
	local gi = 1
	repeat
		if goods[comms_target][gi][1] == goodsType then
			goods[comms_target][gi][2] = goods[comms_target][gi][2] - 1
		end
		gi = gi + 1
	until(gi > #goods[comms_target])
end
--[[-----------------------------------------------------------------
      Wave management 
-----------------------------------------------------------------]]--
function spawnEnemies(xOrigin, yOrigin, danger, enemyFaction)
	if enemyFaction == nil then
		enemyFaction = "Exuari"
	end
	if danger == nil then 
		danger = 1
	end
	enemyStrength = math.max(danger * difficulty * playerPower(),5)
	return spawn_enemies_faction(xOrigin, yOrigin, enemyStrength, enemyFaction)
end

function playerPower()
	playerShipScore = 0
	for p5idx=1, MAX_PLAYER_SHIPS do
		p5obj = getPlayerShip(p5idx)
		if p5obj ~= nil and p5obj:isValid() then
			if p5obj.shipScore == nil then
				playerShipScore = playerShipScore + 24
			else
				playerShipScore = playerShipScore + p5obj.shipScore
			end
		end
	end
	return playerShipScore
end

function launchWaves()
	waveSize = irandom(1,4)
	waveProgress = waveProgress + waveProgressInterval
	local wave1angle = 0
	local wave2angle = 0
	local wave3angle = 0
	local wave4angle = 0
	if random(1,100) < 50 then
		wave1angle = ganaldaAngle
	else
		wave1angle = ticAngle
	end
	if wave1angle == nil then
		wave1angle = random(0,360)
	end
	if wave1angle == nil then print("wave1angle is nil") end
	local wave_start_incursion_distance = 60000 - (difficulty * 5000)
	local wave1startx, wave1starty = vectorFromAngle(wave1angle,random(wave_start_incursion_distance+waveProgress*10000,wave_start_incursion_distance+20000+waveProgress*10000))
	wave1list = {}
	wave1list = spawnEnemies(wave1startx, wave1starty, random(.6,3))
	waveEnemyCount = 0
	local svx = 0
	local svy = 0
	if stationVaiken:isValid() then
		svx, svy = stationVaiken:getPosition()
	else
		svx = 0
		svy = 0
	end
	for _, enemy in ipairs(wave1list) do
		enemy:orderFlyTowards(svx, svy)
		waveEnemyCount = waveEnemyCount + 1
	end
	if waveSize > 1 then
		if waveSize == 4 then
			wave2angle = wave1angle + random(60,120)
		elseif waveSize == 3 then
			wave2angle = wave1angle + random(60,180)
		else
			wave2angle = wave1angle + random(90,270)
		end
		local wave2distance = random(wave_start_incursion_distance+waveProgress*10000,wave_start_incursion_distance+20000+waveProgress*10000)
		if wave2angle == nil then print("wave2angle is nil") end
		local wave2startx, wave2starty = vectorFromAngle(wave2angle,wave2distance)
		wave2list = {}
		wave2list = spawnEnemies(wave2startx, wave2starty, random(.5,2) + waveProgress, "Exuari")
		for _, enemy in ipairs(wave2list) do
			enemy:orderFlyTowards(svx, svy)
			waveEnemyCount = waveEnemyCount + 1
		end	
	end
	if waveSize > 2 then
		if waveSize == 4 then
			wave3angle = wave2angle + random(60,120)
		else
			wave3angle = wave2angle + random(60,180)
		end
		if wave3angle == nil then print("wave3angle is nil") end
		local wave3startx, wave3starty = vectorFromAngle(wave3angle,random(wave_start_incursion_distance+waveProgress*10000,wave_start_incursion_distance+20000+waveProgress*10000))
		wave3list = {}
		wave3list = spawnEnemies(wave3startx, wave3starty, random(.4,1.5) + waveProgress)
		for _, enemy in ipairs(wave3list) do
			enemy:orderFlyTowards(svx, svy)
			waveEnemyCount = waveEnemyCount + 1
		end	
	end
	if waveSize == 4 then
		wave4angle = wave3angle + random(60,120)
		if wave4angle == nil then print("wave4angle is nil") end
		local wave4startx, wave4starty = vectorFromAngle(wave4angle,random(wave_start_incursion_distance+waveProgress*10000,wave_start_incursion_distance+20000+waveProgress*10000))
		wave4list = {}
		wave4list = spawnEnemies(wave4startx, wave4starty, random(.3,1), "Exuari")
		for _, enemy in ipairs(wave3list) do
			enemy:orderFlyTowards(svx, svy)
			waveEnemyCount = waveEnemyCount + 1
		end	
	end
	local p = getPlayerShip(-1)
	p:addReputationPoints(math.floor(waveProgress*10/difficulty))
end

function monitorWaves(delta)
	if waveInProgress then
		waveCheckDelay = waveCheckDelay - delta
		if waveCheckDelay > 0 then
			return
		end
		local waveRemainingEnemies = 0
		for _, enemy in ipairs(wave1list) do
			if enemy ~= nil and enemy:isValid() then
				waveRemainingEnemies = waveRemainingEnemies + 1
			end
		end
		if waveSize > 1 then
			for _, enemy in ipairs(wave2list) do
				if enemy ~= nil and enemy:isValid() then
					waveRemainingEnemies = waveRemainingEnemies + 1
				end
			end
		end
		if waveSize > 2 then
			for _, enemy in ipairs(wave3list) do
				if enemy ~= nil and enemy:isValid() then
					waveRemainingEnemies = waveRemainingEnemies + 1
				end
			end
		end
		if waveSize == 4 then
			for _, enemy in ipairs(wave4list) do
				if enemy ~= nil and enemy:isValid() then
					waveRemainingEnemies = waveRemainingEnemies + 1
				end
			end
		end
		if waveRemainingEnemies/waveEnemyCount < .12 or waveDelayCount > waveDelayCountCheck then
			for _, enemy in ipairs(wave1list) do
				if enemy ~= nil and enemy:isValid() then
					table.insert(persistentEnemies,enemy)
				end
			end
			if waveSize > 1 then
				for _, enemy in ipairs(wave2list) do
					if enemy ~= nil and enemy:isValid() then
						table.insert(persistentEnemies,enemy)
					end
				end
			end
			if waveSize > 2 then
				for _, enemy in ipairs(wave3list) do
					if enemy ~= nil and enemy:isValid() then
						table.insert(persistentEnemies,enemy)
					end
				end
			end
			if waveSize == 4 then
				for _, enemy in ipairs(wave4list) do
					if enemy ~= nil and enemy:isValid() then
						table.insert(persistentEnemies,enemy)
					end
				end
			end
			for _, enemy in ipairs(persistentEnemies) do
				pecdist = 999999	--player to enemy closest distance
				if enemy:isValid() then
					for p6idx=1, MAX_PLAYER_SHIPS do
						p6obj = getPlayerShip(p6idx)
						if p6obj ~= nil and obj:isValid() then
							curdist = distance(p6obj,enemy)
							if curdist < pecdist then
								closest = p6obj
								pecdist = curdist
							end
						end
					end
					enemy:orderAttack(closest)
				end
			end
			waveInProgress = false
		end
		waveCheckDelay = delta + 20
		if playWithTimeLimit then
			waveDelayCount = waveDelayCount + 1
		end
	else	--wave not in progress, launch one
		for i=1,#stationList do
			local current_station = stationList[i]
			if current_station ~= nil and current_station:isValid() then
				current_station.warn_count = 0
			end
		end
		launchWaves()
		waveDelayCount = 0
		waveInProgress = true
		waveCheckDelay = delta + 20
	end
end

function helpWarn(delta)
	helpWarnDelay = helpWarnDelay - delta
	if helpWarnDelay > 0 then
		return
	end
	helpWarnDelay = delta + 30
	waveNear(wave1list)
	if waveSize > 1 then
		waveNear(wave2list)
	end
	if waveSize > 2 then
		waveNear(wave3list)
	end
	if waveSize == 4 then
		waveNear(wave4list)
	end
end

function waveNear(enemyWaveList)
	for _, enemy in pairs(enemyWaveList) do
		if enemy:isValid() then
			playerInRange = false -- no warning if a player in range
			for p7idx=1, MAX_PLAYER_SHIPS do
				p7 = getPlayerShip(p7idx)
				if p7 ~= nil and p7:isValid() and distance(p7,enemy) < 30000 then
					playerInRange = true
					break
				end
			end
			if not playerInRange then
				local distToEnemy = 999999
				local closestStation = nil
				for _, obj in ipairs(enemy:getObjectsInRange(30000)) do
					if obj ~= nil and obj:isValid() then
						if obj.typeName == "SpaceStation" then
							if obj:getFaction() == "Human Navy" or obj:getFaction() == "Independent" then
								if obj == nil then print("obj is nil") end
								if enemy == nil then print("enemy 3 is nil") end
								local x1, y1 = obj:getPosition()
								local x2, y2 = enemy:getPosition()
								local curDist = distance(x1,y1,x2,y2)
								if curDist < distToEnemy then
									distToEnemy = curDist
									closestStation = obj
								end
							end
						end
					end
				end
				warnFactor = (1 - distToEnemy/30000)*100
				if closestStation.comms_data ~= nil and closestStation.comms_data.friendlyness ~= nil then
					warnFactor = warnFactor + closestStation.comms_data.friendlyness
				end
--				if random(1,100) < warnFactor then
--					closestStation = nil
--				end
				if closestStation ~= nil then
					distToPlayer = 999999
					closestPlayer = nil
					for p8idx=1, MAX_PLAYER_SHIPS do
						p8 = getPlayerShip(p8idx)
						if p8 ~= nil and p8:isValid() then
							curDist = distance(p8,closestStation)
							if curDist < distToPlayer then
								distToPlayer = curDist
								closestPlayer = p8
							end
						end
					end
					if diagnostic then
						lMsg = string.format("%f ",warnFactor)
					else
						lMsg = ""
					end
					lMsg = lMsg .. "[" .. closestStation:getCallSign() .. ", Sector " .. closestStation:getSectorName() .. "] There are enemies nearby"
					closestPlayer:addToShipLog(lMsg, "Red")
					return
				end
			end
		end
	end
end

function showGameEndStatistics()
	destroyedStations = 0
	survivedStations = 0
	destroyedFriendlyStations = 0
	survivedFriendlyStations = 0
	destroyedNeutralStations = 0
	survivedNeutralStations = 0
	for _, station in pairs(originalStationList) do
		if station:isFriendly(getPlayerShip(-1)) then
			if station:isValid() then
				survivedStations = survivedStations + 1
				survivedFriendlyStations = survivedFriendlyStations + 1
			end
		else
			if station:isValid() then
				survivedStations = survivedStations + 1
				survivedNeutralStations = survivedNeutralStations + 1
			end
		end
	end
	destroyedStations = totalStations - survivedStations
	destroyedFriendlyStations = friendlyStations - survivedFriendlyStations
	destroyedNeutralStations = neutralStations - survivedNeutralStations
	gMsg = string.format("Stations: %i\t survived: %i\t destroyed: %i",totalStations,survivedStations,destroyedStations)
	gMsg = gMsg .. string.format("\nFriendly Stations: %i\t survived: %i\t destroyed: %i",friendlyStations,survivedFriendlyStations,destroyedFriendlyStations)
	gMsg = gMsg .. string.format("\nNeutral Stations: %i\t survived: %i\t destroyed: %i",neutralStations,survivedNeutralStations,destroyedNeutralStations)
	gMsg = gMsg .. string.format("\n\n\n\nRequired missions completed: %i",requiredMissionCount)
	rankVal = survivedFriendlyStations/friendlyStations*.7 + survivedNeutralStations/neutralStations*.3
	globalMessage(gMsg)
end
--[[-----------------------------------------------------------------
      Required plot choices
-----------------------------------------------------------------]]--
--		Required plot choice: Undercut leads to base destruction
function chooseUndercutBase()
	local hideChoice = math.random(1,4)
	if hideChoice == 1 then
		if stationOutpost21:isValid() then
			hideBase = stationOutpost21
		elseif stationOutpost33:isValid() then
			hideBase = stationOutpost33
		elseif stationLando:isValid() then
			hideBase = stationLando
		else
			hideBase = stationOutpost8
		end
	elseif hideChoice == 2 then
		if stationOutpost33:isValid() then
			hideBase = stationOutpost33
		elseif stationLando:isValid() then
			hideBase = stationLando
		elseif stationOutpost8:isValid() then
			hideBase = stationOutpost8
		else
			hideBase = stationOutpost21
		end
	elseif hideChoice == 3 then
		if stationLando:isValid() then
			hideBase = stationLando
		elseif stationOutpost8:isValid() then
			hideBase = stationOutpost8
		elseif stationOutpost21:isValid() then
			hideBase = stationOutpost21
		else
			hideBase = stationOutpost33
		end
	else
		if stationOutpost8:isValid() then
			hideBase = stationOutpost8
		elseif stationOutpost33:isValid() then
			hideBase = stationOutpost33
		elseif stationLando:isValid() then
			hideBase = stationLando
		else
			hideBase = stationOutpost21
		end
	end
	hideStationName = hideBase:getCallSign()
	hideStationSector = hideBase:getSectorName()
end

function undercutOrderMessage(delta)
	mMsg = string.format("[Vaiken] As a naval operative, Charles Undercut discovered information about enemies in this region. Unfortunately, he was fired for his poor performance as a maintenance technician by his commanding officer before he could file a report. We need his information. His last known location was station %s in sector %s. Go find him and get that information",hideBase:getCallSign(),hideBase:getSectorName()) 
	for p11idx=1, MAX_PLAYER_SHIPS do
		p11 = getPlayerShip(p11idx)
		if p11 ~= nil and p11:isValid() then
			p11:addToShipLog(mMsg,"Magenta")
		end
	end	
	secondaryOrders = "\nFind Charles Undercut last reported at station " .. hideStationName .. " in sector " .. hideStationSector .. " who has information on enemy activity"
	plotR = undercutStation
end

function undercutStation(delta)
	if hideBase:isValid() then
		for p9idx=1, MAX_PLAYER_SHIPS do
			p9 = getPlayerShip(p9idx)
			if p9 ~= nil and p9:isValid() then
				if p9:isDocked(hideBase) then
					if p9.undercut == nil then
						if hideTransport == nil then
							farthestTransport = transportList[1]
							for _, t in ipairs(transportList) do
								if t:isValid() then
									if distance(hideBase, t) > distance(hideBase, farthestTransport) then
										farthestTransport = t
									end
								end
							end
							hideTransport = farthestTransport
						end
						p9.undercut = hideTransport
						fMsg = "[" .. hideBase:getCallSign() .. "] We haven't seen Charles Undercut in a while. He took a job as a maintenance technician aboard " .. hideTransport:getCallSign()
						fMsg = fMsg .. ".\nLast we heard, that ship was working in the " .. hideTransport:getSectorName() .. " sector. He was desperate for a job."
						p9:addToShipLog(fMsg,"Magenta")
						plotR = undercutTransport
						undercutLocation = "transport"
						undercutHelp = 30
					end
				end
			end
		end
	else
		undercutMission = "done"
		plotR = nil
	end
end

function undercutTransport(delta)
	if hideTransport ~= nil and hideTransport:isValid() then
		if undercutLocation == "transport" then
			undercutHelp = undercutHelp - delta
			if undercutHelp < 0 then
				local helpHideTransport = false
				if hideTransport:getHull() < hideTransport:getHullMax() then
					helpHideTransport = true
				end
				shields = hideTransport:getShieldCount()
				for n=0,shields-1 do
					if hideTransport:getShieldLevel(n)/hideTransport:getShieldMax(n) < .5 then
						helpHideTransport = true
					end
				end
				if helpHideTransport then
					playerDistance = 999999
					for p10idx=1, MAX_PLAYER_SHIPS do
						p10 = getPlayerShip(p10idx)
						if p10 ~= nil and p10:isValid() then
							currentDistance = distance(p10,hideTransport)
							if currentDistance < playerDistance then
								closestPlayer = p10
								playerDistance = currentDistance
							end
						end
					end
					hMsg = "[" .. hideTransport:getCallSign() .. "] we need help. Our maintenance technician says you might be interested. "
					hMsg = hMsg .. "We are in sector " .. hideTransport:getSectorName() .. ". Hurry."
					closestPlayer:addToShipLog(hMsg,"Magenta")
				end
				undercutHelp = delta + 30
			end
		end
		if undercutLocation == "free" then
			secondaryOrders = "\nDestroy enemy base in sector " .. undercutTarget:getSectorName()
			plotR = undercutEnemyBase
		end
	else
		undercutMission = "done"
		plotR = nil
	end
end

function undercutEnemyBase(delta)
	if undercutBaseDefense == nil then
		local undercutTargetx, undercutTargetY = undercutTarget:getPosition()
		local undercutWaveDefenseList = {}
		undercutWaveDefenseList = spawnEnemies(undercutTargetx, undercutTargetY, 1, undercutTarget:getFaction())
		for _, enemy in ipairs(undercutWaveDefenseList) do
			enemy:orderDefendTarget(undercutTarget)
		end
		undercutBaseDefense = true
	end
	if not undercutTarget:isValid() then
		requiredMissionCount = requiredMissionCount + 1
		secondaryOrders = ""
		undercutMission = "done"
		for p30idx=1, MAX_PLAYER_SHIPS do
			p30 = getPlayerShip(p30idx)
			if p30 ~= nil and p30:isValid() and undercutRep == nil then
				p30:addReputationPoints(100-(difficulty*5))
				undercutRep = "awarded"
			end
		end
		plotR = nil
	end
end
--      Required plot choice: Stettor sensors find enemy base - destroy
function chooseSensorBase()
	if sensorBase == nil then
		local sensorChoice = math.floor(random(1,4))
		if sensorChoice == 1 then
			sensorBase = stationVactel
		elseif sensorChoice == 2 then
			sensorBase = stationArcher
		elseif sensorChoice == 3 then
			sensorBase = stationDeer
		else
			sensorBase = stationCavor
		end
	end
	sensorBaseName = sensorBase:getCallSign()
	sensorBaseSector = sensorBase:getSectorName()
end

function chooseSensorParts()
	if s1part == nil then
		local si1Choice = math.floor(random(1,3))
		if si1Choice == 1 then
			s1part = "dilithium"
		elseif si1Choice == 2 then
			s1part = "cobalt"
		else
			s1part = "tritanium"
		end
	end
	if s2part == nil then
		local si2Choice = math.floor(random(1,3))
		if si2Choice == 1 then
			s2part = "software"
		elseif si2Choice == 2 then
			s2part = "optic"
		else
			s2part = "robotic"
		end
	end
	s3part = "sensor"
end

function stettorOrderMessage(delta)
	local snsMsg = "[Vaiken] Jing Stettor's research on advanced sensor technology produced a breakthrough. To facilitate rapid deployment, we need you to gather the following:\n"
	snsMsg = snsMsg .. s1part .. "\n"
	snsMsg = snsMsg .. s2part .. "\n"
	snsMsg = snsMsg .. s3part .. "\n"
	if difficulty > 1 then
		snsMsg = snsMsg .. "and take these items to station " .. sensorBaseName 
		secondaryOrders = string.format("\nGather the following:\n%s\n%s\n%s\nand take to station %s",s1part,s2part,s3part,sensorBaseName)
	else
		snsMsg = snsMsg .. "and take these items to station " .. sensorBaseName .. " in sector " .. sensorBaseSector
		secondaryOrders = string.format("\nGather the following:\n%s\n%s\n%s\nand take to station %s in sector %s",s1part,s2part,s3part,sensorBaseName,sensorBaseSector)
	end
	if sensorMessage == nil then
		for p13idx=1, MAX_PLAYER_SHIPS do
			p13 = getPlayerShip(p13idx)
			if p13 ~= nil and p13:isValid() then
				p13:addToShipLog(snsMsg,"Magenta")
			end
		end	
		sensorMessage = "done"
	end
	plotR = stettorStation
end

function stettorStation(delta)
	if sensorBase:isValid() then
		for p14idx=1, MAX_PLAYER_SHIPS do
			p14 = getPlayerShip(p14idx)
			if p14 ~= nil and p14:isValid() then
				if p14:isDocked(sensorBase) then
					if p14.stettor == "provided" then
						secondaryOrders = "\nDestroy enemy base in sector " .. stettorTarget:getSectorName()
						plotR = stettorEnemyBase
					end
				end
			end
		end
	else
		stettorMission = "done"
		plotR = nil
		removeGMFunction("R.Stettor")
	end
end

function stettorEnemyBase(delta)
	if not stettorTarget:isValid() then
		requiredMissionCount = requiredMissionCount + 1
		secondaryOrders = ""
		stettorMission = "done"
		for p31idx=1, MAX_PLAYER_SHIPS do
			p31 = getPlayerShip(p31idx)
			if p31 ~= nil and p31:isValid() and stettorRep == nil then
				p31:addReputationPoints(80-(difficulty*5))
				stettorRep = "awarded"
			end
		end
		plotR = nil
		removeGMFunction("R.Stettor")
	end
end
--      Required plot choice: Traitor bought identifies enemy base
function chooseTraitorBase()
	if traitorBase == nil then
		local traiterBaseChoice = math.floor(random(1,3))
		if traiterBaseChoice == 1 then
			traitorBase = stationMarconi
		elseif traiterBaseChoice == 2 then
			traitorBase = stationMudd
		else
			traitorBase = stationAlcaleica
		end
	end
	traitorBaseName = traitorBase:getCallSign()
	traitorBaseSector = traitorBase:getSectorName()
end

function traitorOrderMessage(delta)
	local tMsg = "[Vaiken] Intelligence observed a spy for the enemy at station " .. traitorBaseName
	if difficulty <= 1 then
		tMsg = tMsg .. " in sector " .. traitorBaseSector
	end
	tMsg = tMsg .. ". Go find out what you can about this spy."
	if difficulty <= 1 then
		secondaryOrders = string.format("\nInvestigate spy reported at station %s in sector %s",traitorBaseName,traitorBaseSector)
	else
		secondaryOrders = string.format("\nInvestigate spy reported at station %s",traitorBaseName)
	end
	if traitorMessage == nil then
		for p14idx=1, MAX_PLAYER_SHIPS do
			p14 = getPlayerShip(p14idx)
			if p14 ~= nil and p14:isValid() then
				p14:addToShipLog(tMsg,"Magenta")
			end
		end	
		traitorMessage = "done"
	end
	plotR = traitorStation
end

function traitorStation(delta)
	if traitorBase:isValid() then
		for p15idx=1, MAX_PLAYER_SHIPS do
			p15 = getPlayerShip(p15idx)
			if p15 ~= nil and p15:isValid() then
				if p15:isDocked(traitorBase) then
					if p15.traitor == nil then
						if runTransport == nil then
							local farthestTransport = nil
							for _, ft in ipairs(transportList) do
								if ft ~= nil and ft:isValid() then
									farthestTransport = ft
									break
								end
							end
							for _, t in ipairs(transportList) do
								if t ~= nil and t:isValid() then
									if traitorBase == nil then print("traitorBase is nil") end
									if t == nil then print("t 2 is nil") end
									if farthestTransport == nil then print("farthestTransport 3 is nil") end
									local x1, y1 = traitorBase:getPosition()
									local x2, y2 = t:getPosition()
									local x3, y3 = farthestTransport:getPosition()
									if distance(x1,y1,x2,y2) > distance(x1,y1,x3,y3) then
										farthestTransport = t
									end
								end
							end
							runTransport = farthestTransport
						end
						p15.traitor = runTransport
						local trMsg = "[" .. traitorBaseName .. "] The girl you're looking for is Annette Sporisky. She boarded a freighter owned by her family: " .. runTransport:getCallSign()
						trMsg = trMsg .. ".\nLast we heard, that ship was working in the " .. runTransport:getSectorName() .. " sector."
						p15:addToShipLog(trMsg,"Magenta")
						plotR = sporiskyTransport
						if difficulty > 1 then
							runTransport:setImpulseMaxSpeed(runTransport:getImpulseMaxSpeed()*2)
						end
						secondaryOrders = string.format("\nGet the spy Annette Sporisky from transport %s and bring her to Vaiken station for questioning",runTransport:getCallSign())
					end
				end
			end
		end
	else
		sporiskyMission = "done"
		plotR = nil
		removeGMFunction("R.Sporisky")
	end
end

function sporiskyTransport(delta)
	if runTransport:isValid() then
		for p16idx=1, MAX_PLAYER_SHIPS do
			p16 = getPlayerShip(p16idx)
			if p16 ~= nil and p16:isValid() then
				if p16.traitorBought == true then
					plotR = sporiskyQuestioned
				end
			end
		end
	else
		sporiskyMission = "done"
		plotR = nil
	end
end

function sporiskyQuestioned(delta)
	if stationVaiken:isValid() then
		for p17idx=1, MAX_PLAYER_SHIPS do
			p17 = getPlayerShip(p17idx)
			if p17 ~= nil and p17:isValid() then
				if p17:isDocked(stationVaiken) then
					if p17.traitorBought then
						p17:addToShipLog("Annette Sporisky transferred to Vaiken station","Magenta")
						if sporiskyTarget:isValid() then
							p17:addToShipLog("Spy identified enemy base in sector " .. sporiskyTarget:getSectorName(),"Magenta") 
							secondaryOrders = string.format("\nDestroy enemy base in sector %s",sporiskyTarget:getSectorName())
						else
							if stationGanalda:isValid() then
								sporiskyTarget = stationGanalda
							elseif stationEmpok:isValid() then
								sporiskyTarget = stationEmpok
							elseif stationTic:isValid() then
								sporiskyTarget = stationTic
							end
							if sporiskyTarget:isValid() then
								p17:addToShipLog("Spy identified enemy base in sector " .. sporiskyTarget:getSectorName(),"Magenta") 
								secondaryOrders = string.format("\nDestroy enemy base in sector %s",sporiskyTarget:getSectorName())
							else
								p17:addToShipLog("The enemy base identified has already been destroyed","Magenta")
							end
						end
						plotR = sporiskyEnemyBase
					end
				end
			end
		end
	else
		sporiskyMission = "done"
		plotR = nil
		removeGMFunction("R.Sporisky")
	end
end

function sporiskyEnemyBase(delta)
	if not sporiskyTarget:isValid() then
		requiredMissionCount = requiredMissionCount + 1
		plotR = nil
		removeGMFunction("R.Sporisky")
		secondaryOrders = ""
		sporiskyMission = "done"
		for p32idx=1, MAX_PLAYER_SHIPS do
			p32 = getPlayerShip(p32idx)
			if p32 ~= nil and p32:isValid() and sporiskyRep == nil then
				p32:addReputationPoints(80-(difficulty*5))
				sporiskyRep = "awarded"
			end
		end
		plotR = nil
	end
end
--      Required plot choice: black hole horizon research
function chooseHorizonParts()
	if hr1part == nil then
		local hr1Choice = math.random(3)
		if hr1Choice == 1 then
			hr1part = "communication"
		elseif hr1Choice == 2 then
			hr1part = "lifter"
		else
			hr1part = "repulsor"
		end
	end
	hr2part = "sensor"
end

function horizonOrderMessage(delta)
	if stationEmory:isValid() then
		local hMsg = string.format("[Emory] After years or research, we are near a breakthrough on our mobile black hole research. We need some assistance for the next phase. Please bring us some %s and %s type goods.",hr1part,hr2part)
		secondaryOrders = string.format("\nBring %s and %s to station Emory",hr1part,hr2part)
		if horizonMessage == nil then
			for p25idx=1, MAX_PLAYER_SHIPS do
				p25 = getPlayerShip(p25idx)
				if p25 ~= nil and p25:isValid() then
					p25:addToShipLog(hMsg,"Magenta")
				end
			end	
			horizonMessage = "done"
		end
		horizonScanRange = 5000 - (difficulty * 200)
		plotR = horizonStationDeliver
	else
		horizonMission = "done"
		plotR = nil
		removeGMFunction("R.Horizon")
	end
end

function horizonStationDeliver(delta)
	if stationEmory:isValid() then
		for p26idx=1, MAX_PLAYER_SHIPS do
			p26 = getPlayerShip(p26idx)
			if p26 ~= nil and p26:isValid() then
				if p26:isDocked(stationEmory) then
					if p26.horizonComponents == "provided" then
						secondaryOrders = "Gather sensor data from black hole by close approach"
						horizonScienceMessageStartTimer = 20
						phScan = p26
						elapsedScanTime = 0
						plotR = horizonScienceMessage					
					end
				end
			end
		end	
	else
		horizonMission = "done"
		plotR = nil
		removeGMFunction("R.Horizon")
	end
end

function horizonScienceMessage(delta)
	horizonScienceMessageStartTimer = horizonScienceMessageStartTimer - delta
	if horizonScienceMessageStartTimer < 0 then
		if phScan.horizonConsoleMessage ~= "sent" then
			horizonConsoleMessage = "grawp scan instructions"
			if phScan:hasPlayerAtPosition("Science") then
				phScan:addCustomMessage("Science",horizonConsoleMessage,"When the ship gets close enough, a button to initiate black hole scan will become available. Click it to start scanning the black hole. The ship must remain within scanning distance for a full 30 seconds to complete the scan.")
				phScan.horizonConsoleMessage = "sent"
			end
			if phScan:hasPlayerAtPosition("Operations") then
				phScan:addCustomMessage("Operations",horizonConsoleMessage,"When the ship gets close enough, a button to initiate black hole scan will become available. Click it to start scanning the black hole. The ship must remain within scanning distance for a full 30 seconds to complete the scan.")
				phScan.horizonConsoleMessage = "sent"
			end
		end
	end
	local grawp_status = nil
	if phScan == nil then print("phScan is nil") end
	if grawp == nil then print("grawp is nil") end
	local x1, y1 = phScan:getPosition()
	local x2, y2 = grawp:getPosition()
	if distance(x1,y1,x2,y2) < horizonScanRange then
		grawp_status = "Grawp in range"
		if scanGrawpButton then
			if scanGrawp then
				if elapsedScanTime == 0 then
					elapsedScanTime = delta
					elapsedScanTimeHalf = delta + 15
					elapsedScanTimeGoal = delta + 30
				else
					elapsedScanTime = elapsedScanTime + delta
				end
				if elapsedScanTime > elapsedScanTimeHalf then
					if phScan.halfScanMessage ~= "sent" then
						phScan:addToShipLog("[Scan technician] Black hole scan 50 percent complete","Blue")
						phScan.halfScanMessage = "sent"
					end
				end
				if elapsedScanTime > elapsedScanTimeGoal then
					phScan:addToShipLog("[Scan technician] Black hole scan complete","Blue")
					if horizonScienceScanButton == "scan button" then
						phScan:removeCustom(horizonScienceScanButton)
						horizonScienceScanButton = nil
					end
					if horizonScienceScanButtonOperations == "scan button operations" then
						phScan:removeCustom(horizonScienceScanButtonOperations)
						horizonScienceScanButtonOperations = nil
					end
					if grawp_status_helm == "grawp_status_helm" then
						phScan:removeCustom(grawp_status_helm)
						grawp_status_helm = nil
					end
					if grawp_status_tactical == "grawp_status_tactical" then
						phScan:removeCustom(grawp_status_tactical)
						grawp_status_tactical = nil
					end
					if grawp_status_science == "grawp_status_science" then
						phScan:removeCustom(grawp_status_science)
						grawp_status_science = nil
					end
					if grawp_status_operations == "grawp_status_operations" then
						phScan:removeCustom(grawp_status_operations)
						grawp_status_operations = nil
					end
					requiredMissionCount = requiredMissionCount + 1
					secondaryOrders = ""
					horizonMission = "done"
					for p33idx=1,MAX_PLAYER_SHIPS do
						local p33 = getPlayerShip(p33idx)
						if p33 ~= nil and p33:isValid() and horizonRep == nil then
							p33:addReputationPoints(70-(difficulty*5))
							horizonRep = "awarded"
						end
					end
					plotR = nil
					removeGMFunction("R.Horizon")
				end
				grawp_status = string.format("Grawp in range: %i",math.ceil(elapsedScanTimeGoal - elapsedScanTime))
			end
		else
			if phScan:hasPlayerAtPosition("Science") then
				horizonScienceScanButton = "scan button"
				phScan:addCustomButton("Science",horizonScienceScanButton,"Scan black hole",scanBlackHole)
				scanGrawpButton = true
			end
			if phScan:hasPlayerAtPosition("Operations") then
				horizonScienceScanButtonOperations = "scan button operations"
				phScan:addCustomButton("Operations",horizonScienceScanButtonOperations,"Scan black hole",scanBlackHole)
				scanGrawpButton = true
			end
		end
	else
		grawp_status = "Grawp out of range"
		if scanGrawpButton then
			if horizonScienceScanButton == "scan button" then
				phScan:removeCustom(horizonScienceScanButton)
				horizonScienceScanButton = nil
			end
			if horizonScienceScanButtonOperations == "scan button operations" then
				phScan:removeCustom(horizonScienceScanButtonOperations)
				horizonScienceScanButtonOperations = nil
			end
			phScan:addToShipLog("[Scan technician] Black hole scan aborted before completion","Blue")
			phScan.halfScanMessage = "reset"
			elapsedScanTime = 0
			scanGrawp = false
			scanGrawpButton = false
		end
	end
	if plotR ~= nil then
		if phScan:hasPlayerAtPosition("Helms") then
			grawp_status_helm = "grawp_status_helm"
			phScan:addCustomInfo("Helms",grawp_status_helm,grawp_status)
		end
		if phScan:hasPlayerAtPosition("Tactical") then
			grawp_status_tactical = "grawp_status_tactical"
			phScan:addCustomInfo("Tactical",grawp_status_tactical,grawp_status)
		end
		if phScan:hasPlayerAtPosition("Science") then
			grawp_status_science = "grawp_status_science"
			phScan:addCustomInfo("Science",grawp_status_science,grawp_status)
		end
		if phScan:hasPlayerAtPosition("Operations") then
			grawp_status_operations = "grawp_status_operations"
			phScan:addCustomInfo("Operations",grawp_status_operations,grawp_status)
		end
	end
end

function scanBlackHole()
	scanGrawp = true
	phScan:addToShipLog("[Scan technician] Black hole scan started","Blue")
end
--[[-----------------------------------------------------------------
      Optional plot choices
-----------------------------------------------------------------]]--
--      Optional plot choice: Beam range upgrade
function chooseBeamRangeParts()
	if br1part == nil then
		local br1partChoice = math.floor(random(1,3))
		if br1partChoice == 1 then
			br1part = "gold"
		elseif br1partChoice == 2 then
			br1part = "nickel"
		else
			br1part = "cobalt"
		end
	end
	if br2part == nil then
		local br2partChoice = math.floor(random(1,3))
		if br2partChoice == 1 then
			br2part = "lifter"
		elseif br2partChoice == 2 then
			br2part = "filament"
		else
			br2part = "optic"
		end
	end
	if br3part == nil then
		local br3partChoice = math.floor(random(1,3))
		if br3partChoice == 1 then
			br3part = "robotic"
		elseif br3partChoice == 2 then
			br3part = "nanites"
		else
			br3part = "battery"
		end
	end
end

function beamRangeMessage(delta)
	optionalOrders = string.format("\nOptional: Gather and bring goods to station Marconi: %s, %s, %s",br1part,br2part,br3part)
	obrMsg = string.format("[Station Marconi] Please bring us some components and materials for a project we are working on: %s, %s, %s",br1part,br2part,br3part)
	for p18idx=1, MAX_PLAYER_SHIPS do
		p18 = getPlayerShip(p18idx)
		if p18 ~= nil and p18:isValid() then
			p18:addToShipLog(obrMsg,"Magenta")
		end
	end	
	plotO = beamRangeUpgrade
end

function beamRangeUpgrade(delta)
	if stationMarconi:isValid() then
		for p19idx=1, MAX_PLAYER_SHIPS do
			p19 = getPlayerShip(p19idx)
			if p19 ~= nil and p19:isValid() then
				if p19:isDocked(stationMarconi) then
					if p19.beamComponents == "provided" then
						beamRangeUpgradeAvailable = true
						optionalMissionDelay = delta + random(30,90)
						beamRangePlot = "done"
						optionalOrders = ""
						for p34idx=1, MAX_PLAYER_SHIPS do
							p34 = getPlayerShip(p34idx)
							if p34 ~= nil and p34:isValid() and beamRangeRep == nil then
								p34:addReputationPoints(50-(difficulty*5))
								beamRangeRep = "awarded"
							end
						end
						plotO = nil
						removeGMFunction("O.Beam Range")
					end
				end
			end
		end
	else
		beamRangePlot = "done"
		plotO = nil
	end
end
--      Optional plot choice: Beam damage upgrade
function chooseBeamDamageParts()
	if bd1part == nil then
		local bd1partChoice = math.floor(random(1,3))
		if bd1partChoice == 1 then
			bd1part = "platinum"
		elseif bd1partChoice == 2 then
			bd1part = "tritanium"
		else
			bd1part = "dilithium"
		end
	end
	if bd2part == nil then
		local bd2partChoice = math.floor(random(1,3))
		if bd2partChoice == 1 then
			bd2part = "sensor"
		elseif bd2partChoice == 2 then
			bd2part = "software"
		else
			bd2part = "android"
		end
	end
	if bd3part == nil then
		local bd3partChoice = math.floor(random(1,3))
		if bd3partChoice == 1 then
			bd3part = "circuit"
		elseif bd3partChoice == 2 then
			bd3part = "repulsor"
		else
			bd3part = "transporter"
		end
	end
end

function beamDamageMessage(delta)
	optionalOrders = string.format("\nOptional: Gather and bring goods to station Nefatha: %s, %s, %s",bd1part,bd2part,bd3part)
	obdMsg = string.format("[Station Nefatha] Please bring us some components and materials for a weapons project we are working on: %s, %s, %s",bd1part,bd2part,bd3part)
	for p20idx=1, MAX_PLAYER_SHIPS do
		p20 = getPlayerShip(p20idx)
		if p20 ~= nil and p20:isValid() then
			p20:addToShipLog(obdMsg,"Magenta")
		end
	end	
	plotO = beamDamageUpgrade
end

function beamDamageUpgrade(delta)
	if stationNefatha:isValid() then
		for p21idx=1, MAX_PLAYER_SHIPS do
			p21 = getPlayerShip(p21idx)
			if p21 ~= nil and p21:isValid() then
				if p21:isDocked(stationNefatha) then
					if p21.beamDamageComponents == "provided" then
						beamDamageUpgradeAvailable = true
						optionalMissionDelay = delta + random(30,90)
						beamDamagePlot = "done"
						optionalOrders = ""
						for p35idx=1, MAX_PLAYER_SHIPS do
							p35 = getPlayerShip(p35idx)
							if p35 ~= nil and p35:isValid() and beamDamageRep == nil then
								p35:addReputationPoints(50-(difficulty*5))
								beamDamageRep = "awarded"
							end
						end
						plotO = nil
						removeGMFunction("O.Beam Damage")
					end
				end
			end
		end
	else
		beamDamagePlot = "done"
		plotO = nil
		removeGMFunction("O.Beam Damage")
	end
end
--      Optional plot choice: Spin upgrade - maneuver
function chooseSpinBaseParts()
	if sp1part == nil then
		local sp1partChoice = math.random(3)
		if sp1partChoice == 1 then
			sp1part = "platinum"
		elseif sp1partChoice == 2 then
			sp1part = "dilithium"
		else
			sp1part = "gold"
		end
	end
	if sp2part == nil then
		local sp2partChoice = math.random(3)
		if sp2partChoice == 1 then
			sp2part = "tractor"
		elseif sp2partChoice == 2 then
			sp2part = "transporter"
		else
			sp2part = "impulse"
		end
	end
	if sp3part == nil then
		local sp3partChoice = math.random(3)
		if sp3partChoice == 1 then
			sp3part = "battery"
		elseif sp3partChoice == 2 then
			sp3part = "android"
		else
			sp3part = "robotic"
		end
	end
	if spinBase == nil then
		local spinBaseChoice = math.random(3)
		if spinBaseChoice == 1 then
			if stationCalifornia:isValid() then
				spinBase = stationCalifornia
			elseif stationScience2:isValid() then
				spinBase = stationScience2
			else
				spinBase = stationOutpost33
			end
		elseif spinBaseChoice == 2 then
			if stationScience2:isValid() then
				spinBase = stationScience2
			elseif stationOutpost33:isValid() then
				spinBase = stationOutpost33
			else
				spinBase = stationCalifornia
			end
		else
			if stationOutpost33:isValid() then
				spinBase = stationOutpost33
			elseif stationCalifornia:isValid() then
				spinBase = stationCalifornia
			else
				spinBase = stationScience2
			end
		end
	end
end

function spinMessage(delta)
	optionalOrders = string.format("\nOptional: Bring %s, %s and %s to station %s in sector %s",sp1part,sp2part,sp3part,spinBase:getCallSign(),spinBase:getSectorName())
	spMsg = string.format("[Station %s, sector %s] Please bring us some goods to help us with a project: %s, %s, %s",spinBase:getCallSign(),spinBase:getSectorName(),sp1part,sp2part,sp3part)
	for p28idx=1, MAX_PLAYER_SHIPS do
		p28 = getPlayerShip(p28idx)
		if p28 ~= nil and p28:isValid() then
			p28:addToShipLog(spMsg,"Magenta")
		end
	end
	plotO = spinUpgrade
end

function spinUpgrade(delta)
	if spinBase:isValid() then
		for p29idx=1, MAX_PLAYER_SHIPS do
			p29 = getPlayerShip(p29idx)
			if p29 ~= nil and p29:isValid() then
				if p29:isDocked(spinBase) then
					if p29.spinComponents == "provided" then
						spinUpgradeAvailable = true
						optionalMissionDelay = delta + random(30,90)
						spinPlot = "done"
						optionalOrders = ""
						for p36idx=1, MAX_PLAYER_SHIPS do
							p36 = getPlayerShip(p36idx)
							if p36 ~= nil and p36:isValid() and spinRep == nil then
								p36:addReputationPoints(50-(difficulty*5))
								spinRep = "awarded"
							end
						end
						plotO = nil
						removeGMFunction("O.Spin")
					end
				end
			end
		end
	else
		spinPlot = "done"
		plotO = nil
		removeGMFunction("O.Spin")
	end
end
--      Optional plot choice: Impulse speed upgrade
function impulseSpeedParts()
	if is1part == nil then
		local is1partChoice = math.floor(random(1,3))
		if is1partChoice == 1 then
			is1part = "nickel"
		elseif is1partChoice == 2 then
			is1part = "tritanium"
		else
			is1part = "cobalt"
		end
	end
	if is2part == nil then
		local is2partChoice = math.floor(random(1,3))
		if is2partChoice == 1 then
			is2part = "software"
		elseif is2partChoice == 2 then
			is2part = "robotic"
		else
			is2part = "android"
		end
	end
	if morrisonBase == nil then
		local morrisonBaseChoice = math.floor(random(1,3))
		if morrisonBaseChoice == 1 then
			morrisonBase = stationResearch11
		elseif morrisonBaseChoice == 2 then
			morrisonBase = stationScience4
		else
			morrisonBase = stationScience2
		end
	end
	morrisonBaseName = morrisonBase:getCallSign()
	morrisonBaseSector = morrisonBase:getSectorName()
end

function impulseSpeedMessage(delta)
	optionalOrders = string.format("\nOptional: Get Nikhil Morrison from station %s in sector %s",morrisonBaseName,morrisonBaseSector)
	oisMsg = string.format("[Station %s] Research scientist Nikhil Morrison is close to a breakthrough on his project, but needs some assistance. Dock with us if you wish to help.",morrisonBaseName)
	for p22idx=1, MAX_PLAYER_SHIPS do
		p22 = getPlayerShip(p22idx)
		if p22 ~= nil and p22:isValid() then
			p22:addToShipLog(oisMsg,"Magenta")
		end
	end	
	plotO = impulseSpeedPartMessage
end

function impulseSpeedPartMessage(delta)
	if morrisonBase:isValid() then
		for p23idx=1, MAX_PLAYER_SHIPS do
			p23 = getPlayerShip(p23idx)
			if p23 ~= nil and p23:isValid() then
				if p23:isDocked(morrisonBase) then
					if p23.morrison ~= "aboard" then
						p23.morrison = "aboard"
						p23:addToShipLog("Nikhil Morrison is aboard","Magenta")
						p23:addToShipLog(string.format("He requests that you get %s and %s type goods and take him to station Cyrus",is1part,is2part),"Magenta")
						if difficulty <= 1 then
							p23:addToShipLog("He says his project relates to increasing ship impulse speeds","Magenta")
						end
						optionalOrders = string.format("\nOptional: Get %s and %s and transport Nikhil Morrison to station Cyrus",is1part,is2part)
						plotO = impulseSpeedUpgrade
					end
				end
			end
		end
	else
		impulseSpeedPlot = "done"
		plotO = nil
		removeGMFunction("O.Impulse")
	end
end

function impulseSpeedUpgrade(delta)
	if stationCarradine:isValid() then
		for p24idx=1, MAX_PLAYER_SHIPS do
			p24 = getPlayerShip(p24idx)
			if p24 ~= nil and p24:isValid() then
				if p24:isDocked(stationCyrus) then
					if p24.impulseSpeedComponents == "provided" then
						impulseSpeedUpgradeAvailable = true
						optionalMissionDelay = delta + random(30,90)
						impulseSpeedPlot = "done"
						optionalOrders = ""
						for p37idx=1, MAX_PLAYER_SHIPS do
							p37 = getPlayerShip(p37idx)
							if p37 ~= nil and p37:isValid() and impulseSpeedRep == nil then
								p37:addReputationPoints(50-(difficulty*5))
								impulseSpeedRep = "awarded"
							end
						end
						plotO = nil
						removeGMFunction("O.Impulse")
					end
				end
			end
		end
	else
		impulseSpeedPlot = "done"
		plotO = nil
		removeGMFunction("O.Impulse")
	end
end
--      Optional plot choice: Get quantum biometric artifact
function quantumArtMessage(delta)
	if stationOrgana:isValid() then
		optionalOrders = string.format("\nOptional: Retrieve artifact with quantum biometric characteristics and bring to station Organa in sector %s",stationOrgana:getSectorName())
		qaMsg = string.format("[Station Organa, sector %s] Research scientist Phillip Solo of the royal research academy finished the theoretical research portion of his dissertation. He needs an artifact with quantum biometric characteristics to apply his research. Please retrieve an artifact with quantum biometric characteristics and bring it to Organa station",stationOrgana:getSectorName())
		for p40idx=1, MAX_PLAYER_SHIPS do
			p40 = getPlayerShip(p40idx)
			if p40 ~= nil and p40:isValid() then
				p40:addToShipLog(qaMsg,"Magenta")
			end
		end	
		if art1.quantum then
			artQ = art1
		elseif art2.quantum then
			artQ = art2
		else
			artQ = art3
		end
		if difficulty <= 1 then
			quantumArtHintDelay = 60
		else
			quantumArtHintDelay = 120
		end
		plotO = quantumRetrieveArt
	else	-- station Organa destroyed
		plotO = nil
		quantumArtPlot = "done"
		removeGMFunction("O.Shield")
	end
end

function quantumRetrieveArt(delta)
	if artQ ~= nil and artQ:isValid() then
		if artQ:isScannedByFaction("Human Navy") then
			artQ:allowPickup(true)
		end
		quantumArtHintDelay = quantumArtHintDelay - delta
		cptad = 999999	-- closest player to artifact distance
		for p41idx=1, MAX_PLAYER_SHIPS do
			p41 = getPlayerShip(p41idx)
			if p41 ~= nil and p41:isValid() then
				clpd = distance(artQ,p41)	-- current loop player distance
				if clpd < cptad then
					cptad = clpd
					closestPlayer = p41
				end
			end
		end
		if quantumArtHintDelay < 0 then
			if quantumArtHint == nil  and closestPlayer ~= nil then
				closestPlayer:addToShipLog(string.format("[Station Organa] We just received a report that an artifact with quantum biometric characteristics may have been observed in sector %s",artQ:getSectorName()),"Magenta")
				if difficulty <= 1 then
					closestPlayer:addToShipLog("Solo's research may have application for ship shield systems","Magenta")
				end
				quantumArtHint = "delivered"
			end
		end
		for p42idx=1, MAX_PLAYER_SHIPS do
			p42 = getPlayerShip(p42idx)
			if p42 ~= nil and p42:isValid() then
				if p42 == closestPlayer then
					p42.artQ = true
				else
					p42.artQ = false
				end
			end
		end
	else
		plotO = quantumDeliverArt
	end
end

function quantumDeliverArt(delta)
	if stationOrgana:isValid() then
		for p44idx=1, MAX_PLAYER_SHIPS do
			p44 = getPlayerShip(p44idx)
			if p44.artQ then
				if p44.artQaboardMessage == nil then
					p44:addToShipLog("Artifact is aboard","Magenta")
					p44.artQaboardMessage = "sent"
				end
				if p44:isDocked(stationOrgana) then
					p44:addToShipLog("[Phillip Organa] Thanks for the artifact. I completed my research. Next time you dock with Vaiken, you can improve your shield effectiveness.","Magenta")
					shieldUpgradeAvailable = true
					p44:addReputationPoints(50-(difficulty*5))
					quantumArtPlot = "done"
					plotO = nil
					removeGMFunction("O.Shield")
				end
			end
		end
	else
		quantumArtPlot = "done"
		plotO = nil
		removeGMFunction("O.Shield")
	end
end
function vaikenStatus(delta)
	if stationVaiken:isValid() then
		local shields_damaged = false
		local shield_index = 0
		local shield_level_total = 0
		local shield_max_total = 0
		local shield_level = 0
		local shield_max = 0
		local shield_report = "Shields:"
		local critical_shield = ""
		repeat
			shield_level = stationVaiken:getShieldLevel(shield_index)
			shield_max = stationVaiken:getShieldMax(shield_index)
			if shield_level < shield_max then
				shields_damaged = true
			end
			shield_level_total = shield_level_total + shield_level
			shield_max_total = shield_max_total + shield_max
			shield_report = shield_report .. string.format(" %i:%i/%i",shield_index,math.floor(shield_level),math.floor(shield_max))
			if shield_level/shield_max < .2 then
				critical_shield = critical_shield .. string.format("Shield %i is critical ",shield_index)
			end
			shield_index = shield_index + 1
		until(shield_index >= stationVaiken:getShieldCount())
		if shields_damaged then
			vaiken_damage_timer = vaiken_damage_timer - delta
			if vaiken_damage_timer < 0 then
				if shield_level_total/shield_max_total < .85 then
					local hull_max = stationVaiken:getHullMax()
					local hull_level = stationVaiken:getHull()
					local hull_damage = hull_level/hull_max
					for pidx=1,8 do
						local p = getPlayerShip(pidx)
						if p ~= nil and p:isValid() then
							p:addToShipLog("[Vaiken] Station has been damaged. " .. shield_report,"Magenta")
							if critical_shield ~= "" then
								p:addToShipLog("[Vaiken] " .. critical_shield,"Red")
								if hull_damage < .4 then
									p:addToShipLog(string.format("[Vaiken] Hull damage: %i out of %i",math.floor(hull_level),math.floor(hull_max)),"Red")
								elseif hull_damage < .8 then
									p:addToShipLog(string.format("[Vaiken] Hull damage: %i out of %i",math.floor(hull_level),math.floor(hull_max)),"Magenta")
								end
							end
						end
					end
					if critical_shield ~= "" then
						vaiken_damage_timer_interval = 60
						if hull_damage < .4 then
							vaiken_damage_timer_interval = 30
						end
					else
						vaiken_damage_timer_interval = 120
					end
				else
					for pidx=1,8 do
						local p = getPlayerShip(pidx)
						if p ~= nil and p:isValid() then
							p:addToShipLog("[Vaiken] Station has been damaged","Magenta")
						end
					end
					vaiken_damage_timer_interval = 120
				end
				vaiken_damage_timer = delta + vaiken_damage_timer_interval
			end
		end
	else
		showGameEndStatistics()
		victory("Kraylor")
	end
end

function update(delta)
	if delta == 0 then
		--game paused
		setPlayers()
		return
	end
	if playWithTimeLimit then
		gameTimeLimit = gameTimeLimit - delta
		if gameTimeLimit < 0 then
			showGameEndStatistics()
			if requiredMissionCount > 0 and plotR == nil then
				victory("Human Navy")
			else
				victory("Exuari")
			end
		end
		-- select required mission
		if plotR == nil then
			-- timed missions
			local requiredMissionChoice = math.random(4)
			if requiredMissionChoice == 1 then
				if undercutMission ~= "done" and undercutLocation ~= "free" and gameTimeLimit < 2670 and gameTimeLimit > 2400 then
					mPart = 1
					plotR = undercutOrderMessage
					chooseUndercutBase()
				end
				removeGMFunction("R.Undercut")
			elseif requiredMissionChoice == 2 then
				if stettorMission ~= "done" and gameTimeLimit < 2670 and gameTimeLimit > 1800 then
					chooseSensorBase()
					chooseSensorParts()
					plotR = stettorOrderMessage
				end
				removeGMFunction("R.Stettor")
			elseif requiredMissionChoice == 3 then
				if horizonMission ~= "done" and gameTimeLimit < 2670 and gameTimeLimit > 1200 then
					chooseHorizonParts()
					plotR = horizonOrderMessage
				end
				removeGMFunction("R.Horizon")
			else
				if sporiskyMission ~= "done" and gameTimeLimit < 2670 and gameTimeLimit > 1700 then
					chooseTraitorBase()
					plotR = traitorOrderMessage
				end
			end
		end
	else
		clueMessageDelay = clueMessageDelay - delta
		if clueMessageDelay < 0 then
			if clueMessage ~= "delivered" then
				local clMsg = "Intelligence has analyzed all the enemy activity in this area and has determined that there must be three enemy bases. Find these bases and destroy them."
				local enemyBaseCount = 0
				if stationEmpok:isValid() then
					enemyBaseCount = enemyBaseCount + 1
				end
				if stationTic:isValid() then
					enemyBaseCount = enemyBaseCount + 1
				end
				if stationGanalda:isValid() then
					enemyBaseCount = enemyBaseCount + 1
				end
				if enemyBaseCount == 1 then
					clMsg = clMsg .. " You have already destroyed two of them."
				elseif enemyBaseCount == 2 then
					clMsg = clMsg .. " You have already destroyed one of them."
				end
				primaryOrders = "Defend bases in the area (human navy and independent) from enemy attack and destroy three enemy bases."
				for p43idx=1, MAX_PLAYER_SHIPS do
					p43 = getPlayerShip(p43idx)
					if p43 ~= nil and p43:isValid() then
						p43:addToShipLog(clMsg,"Magenta")
					end
				end
				clueMessage = "delivered"
			end
		end
		if plotR == nil then
			requiredMissionDelay = requiredMissionDelay - delta
			if requiredMissionCount > 0 and not stationEmpok:isValid() and not stationTic:isValid() and not stationGanalda:isValid() then
				showGameEndStatistics()
				victory("Human Navy")
			end
			if requiredMissionDelay < 0 then
				requiredMissionChoice = math.random(4)
				if requiredMissionChoice == 1 then
					if undercutMission ~= "done" and undercutLocation ~= "free" then
						plotR = undercutOrderMessage
						chooseUndercutBase()
					end
					removeGMFunction("R.Undercut")
				elseif requiredMissionChoice == 2 then
					if stettorMission ~= "done" then
						chooseSensorBase()
						chooseSensorParts()
						plotR = stettorOrderMessage
					end
					removeGMFunction("R.Stettor")
				elseif requiredMissionChoice == 3 then
					if horizonMission ~= "done" then
						chooseHorizonParts()
						plotR = horizonOrderMessage
					end
					removeGMFunction("R.Horizon")
				else
					if sporiskyMission ~= "done" then
						chooseTraitorBase()
						plotR = traitorOrderMessage
					end
					removeGMFunction("R.Sporisky")
				end
				requiredMissionDelay = delta + random(10,30)
			end
		end
	end
	-- select optional mission
	if plotO == nil then
		optionalMissionDelay = optionalMissionDelay - delta
		if optionalMissionDelay < 0 then
			local optionalMissionChoice = math.random(5)
			if optionalMissionChoice == 1 then
				if beamRangePlot ~= "done" then
					chooseBeamRangeParts()
					plotO = beamRangeMessage
				end
				removeGMFunction("O.Beam Range")
			elseif optionalMissionChoice == 2 then
				if impulseSpeedPlot ~= "done" then
					impulseSpeedParts()
					plotO = impulseSpeedMessage
				end
				removeGMFunction("O.Impulse")
			elseif optionalMissionChoice == 3 then
				if spinPlot ~= "done" then
					chooseSpinBaseParts()
					plotO = spinMessage
				end
				removeGMFunction("O.Spin")
			elseif optionalMissionChoice == 4 then
				if quantumArtPlot ~= "done" then
					plotO = quantumArtMessage
				end
				removeGMFunction("O.Shield")
			else
				if beamDamagePlot ~= "done" then
					chooseBeamDamageParts()
					plotO = beamDamageMessage
				end
				removeGMFunction("O.Beam Damage")
			end
			optionalMissionDelay = delta + random(20,40)
		end
	end
	if plotR ~= nil then
		plotR(delta)		--required mission
	end
	if plotO ~= nil then
		plotO(delta)		--optional mission
	end
	if plotA ~= nil then
		plotA(delta)		--asteroids
	end
	if plotB ~= nil then
		plotB(delta)		--black hole
	end
	if plotT ~= nil then
		plotT(delta)		--transports
	end
	if plotW ~= nil then
		plotW(delta)	--waves
	end
	if plotHangar ~= nil then
		plotHangar(delta)	--script_hangar
	end
	if plotH ~= nil then
		plotH(delta)	--help warning
	end
end
