require("utils.lua")

--[[
Design:
* Multiple high level quests (goals) to give the differnt players a purpose
* Exploring reveals means to persue that Quests, alsong with obstacles
* Many obstacles should require working together

High-Level-Goals
* eliminate Kraylor in the east
* remove Exuari threat that circles the area
* diplomacy with Ktiltans
* diplomacy with Criminals
* something with Ghosts
* help Arlenians
* ? with Independent / Human Navy

In this file, the main goal is Exploration and giving the players challanges during that step.
In the stations script, Expansion (taking stations and their services) and Exploitation (upgrading and trading station services) should be handled.
--]]


avp_story = {
	terrain_discovered = 0,
	time_first_discoverey = 0,
	gm_difficulty_adjustment = 0,
--	motivations = arrayShuffle({
--		"Reputation",	-- high value station
--		"Artifact",		-- visible, capturable, via maneuver or heavy combat
--		"Diplomacy",	-- Comms with enemy faction, maybe combat
--		"Skill",		-- difficult to achieve artifacs, near black hole, mines. Or docking on rotating planet station
--		"Capture",		-- high value station
--		"Information",
--		"Heroism",		-- heavy enemies, as communicated
--		"Customisation",	-- promise upgrades?
--	}),
---- other approach:
--	({
--		"Rescue Huge Station",
--		"Capture Huge Station",
--		"Support Huge Station",
--		"Enemy Artifact",
--		"Skill Artifact",
--		"Heavy Enemies",
--	})
--	motivations_index = 0,
}

--[[ GOSSIP: (relevant information for players)
* sometimes there are high valuable asteroids in asteroid fields
* when an asteroid fields containes a station, usually there are no more high-value asteroids anymore
* there are about 4 arlenian asteroid mining station in the wider area
* arlenian mining stations are the source of some wealth. find them and redirect their carriers to your stations for profit.
* there is an ancient mining station in ...; destroying it could yield something valuable
* there is an exuari carrier hiding in an asteroid field near ...
* there is a pirate hideout in the asteroid field in ...
* a Ktlitan hive is in the asteroid field in ...
--]]
function avp_story:init()
	-- the first entry of any entrypoint (...Encounter) must always be applicable!
	-- every terrain type appears about 7 times. nebulae and asteroids up to 14 times
	self.randomEffects = {
		-- rewards
		asteroidsEncounter ={"hiddenArtifact", "arlenianStation", "boss"},
		nebulaeEncounter = 	{"nebulaEffect", "arlenianStation", "exuariAmbush", "boss"},	-- störfelder, artefakt im totesten winkel, verborgene feinde, bewegliche nebel
		minesEncounter = 	{"mineThrower", "arlenianStation", "kraylorMotherbase", "boss"}, -- aushalten/ausweichen, um belohnung zu erlangen
		planetsEncounter = 	{"conflict", "arlenianStation", "boss"},
		blackholesEncounter={"collapseArtifact", "boss"},	-- hard challenge, so use it everywhere?
		wormholesEncounter ={"instableWormhole", "arlenianStation", "boss"},

		-- boss is a subtype of effect; it may set the enemy faction
		asteroidsBoss = {"kraylorBase", "ktlitanQueen", "pirateStation"},
		nebulaeBoss = 	{"exuariCarrier", "ghostStation", "ktlitanQueen"},
		minesBoss = 	{"derelictStation", "ghostStation", "kraylorBase"},
		planetsBoss = 	{"derelictStation", "ghostStation", "pirateStation"},
		blackholesBoss ={"exuariCarrier", "kraylorBase", "pirateStation"},
		wormholesBoss = {"exuariCarrier", "kraylorBase", "ktlitanQueen"},

		nebulaEffect = 	{"nebulaCoolantGain", "nebulaCoolantDrain"},
		mineThrower = 	{"mineThrowerSeek", "mineThrowerDance"},

		-- emenies: two default factions; if a bossfight occures, others may be set
		asteroidsEnemies = 	{"Criminals", "Kraylor"},
		nebulaeEnemies = 	{"Ktlitans", "Ghosts"},
		minesEnemies = 		{"Kraylor", "Exuari"},
		planetsEnemies = 	{"Ktlitans", "Criminals"},
		blackholesEnemies = {"Ghosts", "Kraylor"},
		wormholesEnemies = 	{"Kraylor", "Exuari"},
	}
	self.arlenianStationsCounter = 0
	self.arlenianStationsCounterByTerrain = {
		asteroids = 0,
		nebulae = 0,
		mines = 0,
		planets = 0,
		wormholes = 0,
	}

	self.effectIndex = {}
end

function avp_story:selectEncounter(encounterId)
	-- calls next encounter, reroll sample when all are used once
	assert(self.randomEffects[encounterId] ~= nil, "no encounter category "..encounterId)
	if self.effectIndex[encounterId] == nil or self.effectIndex[encounterId] >= #self.randomEffects[encounterId] then
		self.randomEffects[encounterId] = arrayShuffle(self.randomEffects[encounterId])
		self.effectIndex[encounterId] = 1
	else
		self.effectIndex[encounterId] = self.effectIndex[encounterId] + 1
	end
	local encounter = self.randomEffects[encounterId][self.effectIndex[encounterId]]

	return encounter
end

function test_selectEncounter()
	for k,v in pairs(avp_story.randomEffects) do
		for i=1, 2*#v do
			avp_story:selectEncounter(k)
			avp_story:selectEncounter(k)
			avp_story:selectEncounter(k)
			avp_story:selectEncounter(k)
			avp_story:selectEncounter(k)
		end
	end
end

function avp_story:selectTerrainEncounter(terrain_module)
	-- roll a encounter_type, depending on terrain type
	local encounter_type = terrain_module.terrain_type .. "Encounter"
	local encounter = self:selectEncounter(encounter_type)
	assert(self[encounter] ~= nil, "no such encounter "..encounter)
	local abort_counter = #self.randomEffects[encounter_type]
	log(string.format("select encounter %s for %s %s", encounter, terrain_module.terrain_type, terrain_module.zone_name))
	terrain_module.encounter = encounter	-- store the name
	while self[encounter](self, terrain_module) == false do
		-- try again, if this encounter returns false
		encounter = self:selectEncounter(encounter_type)
		assert(self[encounter] ~= nil, "no such encounter "..encounter)
		terrain_module.encounter = encounter	-- store the name
		log("FAILED! select new encounter "..encounter)
		abort_counter = abort_counter -1
		if abort_counter < 0 then
			print("all encounters are invalid for "..encounter_type)
			return nil
		end
	end
	return encounter 
end

function test_selectTerrainEncounter()
	for _,t in ipairs({"asteroids", "nebulae", "mines", "planets", "blackholes", "wormholes"}) do
		local tm = {
			terrain_type = t,
			canInsertStation = function() return false end,
			canInsertArtifact = function() return false end,
			canInsertEnemies = function() return false end,
			registerOnCreationCallback = function(f) end
		}
		avp_story:selectTerrainEncounter(tm)
		avp_story:selectTerrainEncounter(tm)
		avp_story:selectTerrainEncounter(tm)
		avp_story:selectTerrainEncounter(tm)
		avp_story:selectTerrainEncounter(tm)
	end
end

-- called when the terrain object is created at the beginning of the scenario
-- but before actual terrain:create() is called
function avp_story.onTerrainCheck(terrain_module)
	if not avp_story:selectTerrainEncounter(terrain_module) then
		print("select encounter failed for "..terrain_module.terrain_type)
	end
end

-- specific effect functions
-- the terrain_module is not created, when this functions are called.
-- they use the registerOnCreationCallback funtion of the terrain_module to apply the actual effects
-- the effect may also set gossip or similar effects, that are taken into account before the actual terrain is created

function avp_story:arlenianStation(terrain_module)
	-- about a total of 15 arlenian stations can be found
	if not terrain_module:canInsertStation() then return false end

	terrain_module:registerOnCreationCallback(function(terrain_module, ship)

		local found = avp_story.arlenianStationsCounter
		avp_story.arlenianStationsCounter = found +1
		local terrain_type = terrain_module.terrain_type
		local template = "Arlenian Starbase"	-- default: first one and later
		if found == 4 or found == 8 then
			-- a total of two can be found
			if terrain_type == "planets" then
				avp_story.arlenianStationsCounter = found -- skip, no motherstation on a planet
			else
				template = "Arlenian Motherstation"
				avp_story.found_motherstation = true
			end
		elseif found >= 1 then
			-- first one is starbase
			found = avp_story.arlenianStationsCounterByTerrain[terrain_type]
			avp_story.arlenianStationsCounterByTerrain[terrain_type] = found +1
			if found == 4 then
				-- in late game, citadels can be found.
				template = "Arlenian Citadel"
			elseif found ~= 2 then
				-- the third one of each kind is skipped and replaced by a starbase
				if terrain_type == "asteroids" then
					template = "Arlenian Mining Station"
				elseif terrain_type == "nebulae" then
					template = "Arlenian Science Station"
				elseif terrain_type == "mines" then
					template = "Arlenian Shipyard"
				elseif terrain_type == "planets" then
					template = "Arlenian Habitat"
				elseif terrain_type == "wormholes" then
					template = "Arlenian Hangar"
				-- no arl stations near blackholes
				end
			end
		end
		log(string.format("%s discovered %s %s with %s (%s, %i)", ship:getCallSign(), terrain_module.terrain_type, terrain_module.zone_name, terrain_module.encounter, template, found))
		local station = avp_stations:createArlenianStation(template, terrain_module)
		local x,y = station:getPosition()
		local strength = avp_story:enemyStrength(terrain_module)
		local fleet = avp_enemies.modules["Arlenians"]:spawnEnemiesAtPositions({
			{x+100,y+100},{x-100,y-100},{x+100,y-100},{x-100,y+100}
		}, strength/2)
		for __, ship in ipairs(fleet) do
			ship:orderDefendTarget(station)
		end
		if terrain_module:canInsertEnemies() then
			vf_comms_call_to_action:call_to_action(station, math.max(terrain_module.radius, 30000), terrain_module.encounter)
		end
	end)
	terrain_module.enemy_faction = tableSelectRandom({"Kraylor", "Exuari"})
	terrain_module.gossip = string.format("From time to time we see ships of the Arlenians near their station in the %s not very far from here.", terrain_module.terrain_type)
	return true
end

function avp_story:derelictStation(terrain_module)
	terrain_module:registerOnCreationCallback(function(terrain_module, ship)
		log(string.format("%s discovered %s %s with %s", ship:getCallSign(), terrain_module.terrain_type, terrain_module.zone_name, terrain_module.encounter))
		local station = avp_stations:createEnemyStation({"Small Station", "Medium Station", "Medium Station"}, {"History", "RandomHumanNeutral", "Random"}, terrain_module)
		station:setFaction("Empty")
		local x,y = station:getPosition()
		local art = wh_artifacts:placeGenericArtifact(x,y)
		if station.speed ~= nil and station.center ~= nil then
			wh_rota:add_object(art, station.speed, station.center)
		end
		station:setCommsFunction(nil):setCommsScript("")
	end)
	terrain_module.gossip = string.format("Last time we looked, there was a derelict space station near some %s not very far from here.", terrain_module.terrain_type)
	return true
end

function avp_story:pirateStation(terrain_module)
	terrain_module:registerOnCreationCallback(function(terrain_module, ship)
		log(string.format("%s discovered %s %s with %s", ship:getCallSign(), terrain_module.terrain_type, terrain_module.zone_name, terrain_module.encounter))
		local station = avp_stations:createEnemyStation({"Large Station", "Medium Station", "Medium Station"}, {"Pop Sci Fi", "RandomGenericSinister", "Random"}, terrain_module)
		station:setFaction("Criminals")
		EnemyModuleCriminals:addBossHangar(station, {"capitals", "capitals", "fighters", "fighters"})
		local x,y = station:getPosition()
		local art = wh_artifacts:placeGenericArtifact(x,y)
		if station.speed ~= nil and station.center ~= nil then
			wh_rota:add_object(art, station.speed, station.center)
		end
		vf_comms_call_to_action:call_to_action(station, math.max(terrain_module.radius, 30000), terrain_module.encounter)
	end)
	terrain_module.enemy_faction = "Criminals"
	terrain_module.gossip = string.format("Nearby is a filthy area with %s where pirates make a living. It would be nice if someone brought justice to them", terrain_module.terrain_type)
	return true
end

function avp_story:ghostStation(terrain_module)
	terrain_module:registerOnCreationCallback(function(terrain_module, ship)
		log(string.format("%s discovered %s %s with %s", ship:getCallSign(), terrain_module.terrain_type, terrain_module.zone_name, terrain_module.encounter))
		local station = avp_stations:createEnemyStation({"Large Station", "Medium Station", "Small Station"}, {"Science", "RandomGenericSinister", "Random"}, terrain_module)
		station:setFaction("Ghosts")
		EnemyModuleGhosts:addBossHangar(station, {"capitals", "capitals", "fighters", "fighters"})
		local x,y = station:getPosition()
		local art = wh_artifacts:placeGenericArtifact(x,y)
		station.comms_data.service_available["surrender"] = false
		if station.speed ~= nil and station.center ~= nil then
			wh_rota:add_object(art, station.speed, station.center)
		end
		vf_comms_call_to_action:call_to_action(station, math.max(terrain_module.radius, 30000), terrain_module.encounter)
	end)
	terrain_module.enemy_faction = "Ghosts"
	terrain_module.gossip = string.format("We are not far from an area with %s - don't go there, unless you want to have some rouge AI taking over your ship.", terrain_module.terrain_type)
	return true
end

function avp_story:exuariCarrier(terrain_module)
	terrain_module:registerOnCreationCallback(function(terrain_module, ship)
		log(string.format("%s discovered %s %s with %s", ship:getCallSign(), terrain_module.terrain_type, terrain_module.zone_name, terrain_module.encounter))
		local carrier = EnemyModuleExuari:spawnBoss()
		avp_stations:insertStation(carrier, terrain_module)
		local x,y = carrier:getPosition()
		local art = wh_artifacts:placeGenericArtifact(x,y)
		carrier.comms_data.service_available["surrender"] = false
		vf_comms_call_to_action:call_to_action(carrier, math.max(terrain_module.radius, 30000), terrain_module.encounter)
	end)
	terrain_module.enemy_faction = "Exuari"
	terrain_module.gossip = string.format("There were sightings of an Exuari carrier ship near the %s nearby.", terrain_module.terrain_type)
	return true
end


function avp_story:ktlitanQueen(terrain_module)
	terrain_module:registerOnCreationCallback(function(terrain_module, ship)
		log(string.format("%s discovered %s %s with %s", ship:getCallSign(), terrain_module.terrain_type, terrain_module.zone_name, terrain_module.encounter))
		local carrier = EnemyModuleKtlitans:spawnBoss()
		avp_stations:insertStation(carrier, terrain_module)
		local x,y = carrier:getPosition()
		local art = wh_artifacts:placeGenericArtifact(x,y)
		carrier.comms_data.service_available["surrender"] = false
		vf_comms_call_to_action:call_to_action(carrier, math.max(terrain_module.radius, 30000), terrain_module.encounter)
	end)
	terrain_module.enemy_faction = "Ktlitans"
	terrain_module.gossip = string.format("There is a reservoir full of Ktlitans in the neighbourhood. You can almost see the %s of that area from here.", terrain_module.terrain_type)
	return true
end

function avp_story:kraylorBase(terrain_module)
	terrain_module:registerOnCreationCallback(function(terrain_module, ship)
		log(string.format("%s discovered %s %s with %s", ship:getCallSign(), terrain_module.terrain_type, terrain_module.zone_name, terrain_module.encounter))
		local art = wh_artifacts:placeGenericArtifact(0,0)
		terrain_module:insertStation(art)
		local x,y = art:getPosition()
		local last_base = nil
		for idx, base in ipairs(EnemyModuleKraylor:spawnBossBases()) do
			avp_stations:insertStation(base, terrain_module)
			local x1,y1 = radialPosition(x, y, 1000, idx*90)
			base:setPosition(x1,y1)
			last_base = base
		end
		vf_comms_call_to_action:call_to_action(last_base, math.max(terrain_module.radius, 30000), terrain_module.encounter)
	end)
	terrain_module.enemy_faction = "Kraylor"
	terrain_module.gossip = string.format("The Krailor are near! They will move from their %s to us soon.", terrain_module.terrain_type)
	return true
end

function avp_story:hiddenArtifact(terrain_module)
	if not terrain_module:canInsertArtifact() then return false end
	assert(terrain_module.terrain_type == "asteroids")
	terrain_module:registerOnCreationCallback(function(terrain_module, ship)
		log(string.format("%s discovered %s %s with %s", ship:getCallSign(), terrain_module.terrain_type, terrain_module.zone_name, terrain_module.encounter))
		terrain_module:insertArtifact()
		if terrain_module:canInsertStation() then
			local station = avp_stations:createIndependentStation(terrain_module)
			if station ~= nil then
				terrain_module.cta = vf_comms_call_to_action:call_to_action(station, 20000, terrain_module.encounter)
			end
		end
	end)
	terrain_module.enemy_faction = "Criminals"
	terrain_module.gossip = string.format("A small flotilla of independent miners recently came through here. They moved to the %s not far from here. They believe they might strike rich mining asteroids. I guess without the Human Navy, some troublemakers could benefit from them in one way or the other.", terrain_module.terrain_type)
	return true
end

function avp_story:collapseArtifact(terrain_module)
	if not terrain_module:canInsertArtifact() then return false end
	assert(terrain_module.terrain_type == "blackholes")
	terrain_module:registerOnCreationCallback(function(terrain_module, ship)
		log(string.format("%s discovered %s %s with %s", ship:getCallSign(), terrain_module.terrain_type, terrain_module.zone_name, terrain_module.encounter))
		terrain_module:insertArtifact(vf_blackhole.triggerCollapse)
		if terrain_module:canInsertStation() then
			local station = avp_stations:createIndependentStation(terrain_module)
			if station ~= nil then
				terrain_module.cta = vf_comms_call_to_action:call_to_action(station, 20000, terrain_module.encounter)
			end
		end
	end)
	terrain_module.gossip = string.format("They say, some black holes have orbiting stabiliser artifacts from an ancient civilisation that keep them from collapsing. If you ever see a black hole collapse, flee from that area fast and as far as possible!")
	return true
end

function avp_story:nebulaEffect(terrain_module)
	local encounter = self:selectEncounter("nebulaEffect")
	terrain_module.encounter = encounter	-- store the name
	log(string.format("(%s)", terrain_module.encounter))
	return self[encounter](self, terrain_module)
end

function avp_story:nebulaCoolantGain(terrain_module)
	assert(terrain_module.terrain_type == "nebulae")
	terrain_module:registerOnCreationCallback(function(terrain_module, ship)
		log(string.format("%s discovered %s %s with %s", ship:getCallSign(), terrain_module.terrain_type, terrain_module.zone_name, terrain_module.encounter))
		for _,nebula in ipairs(terrain_module.nebulae) do
			vf_nebulae:addNebulaEffect(nebula, random(1/60, 1/20))
		end
		if terrain_module:canInsertStation() then
			local station = avp_stations:createIndependentStation(terrain_module)
			if station ~= nil then
				terrain_module.cta = vf_comms_call_to_action:call_to_action(station, 20000, terrain_module.encounter)
			end
		end
	end)
	terrain_module.gossip = string.format("Did you know, you can harvest certain kinds of nebulae to use their gases as coolant fluid?")
	return true
end
function avp_story:nebulaCoolantDrain(terrain_module)
	assert(terrain_module.terrain_type == "nebulae")
	terrain_module:registerOnCreationCallback(function(terrain_module, ship)
		log(string.format("%s discovered %s %s with %s", ship:getCallSign(), terrain_module.terrain_type, terrain_module.zone_name, terrain_module.encounter))
		for _,nebula in ipairs(terrain_module.nebulae) do
			vf_nebulae:addNebulaEffect(nebula, -random(1/120, 1/60))
		end
		if terrain_module:canInsertStation() then
			local station = avp_stations:createIndependentStation(terrain_module)
			if station ~= nil then
				terrain_module.cta = vf_comms_call_to_action:call_to_action(station, 20000, terrain_module.encounter)
			end
		end
	end)
	terrain_module.gossip = string.format("Some nebulae consist of particles that are not stopped by your shields or hull, but can react with your coolant fluid, making your pumps clog.")
	return true
end

function avp_story:exuariAmbush(terrain_module)
	assert(terrain_module.terrain_type == "nebulae")
	assert(terrain_module.canInsertEnemies ~= nil)
	if not terrain_module:canInsertEnemies() then return false end
	terrain_module:registerOnCreationCallback(function(terrain_module, ship)
		log(string.format("%s discovered %s %s with %s", ship:getCallSign(), terrain_module.terrain_type, terrain_module.zone_name, terrain_module.encounter))
		local positions = terrain_module:getEnemySpawnPositions()
		table.insert(positions, 1, table.pack(vf_ambush:findBestAmbushPosition(ship)))
		table.insert(positions, 3, table.pack(vf_ambush:findBestAmbushPosition(ship)))
		local enemies = avp_enemies:spawn(positions, "Exuari", avp_story:enemyStrength(terrain_module))
		for _, enemy in ipairs(enemies) do
			enemy:orderAttack(ship)
		end
		if #enemies > 0 then
			vf_comms_call_to_action:call_to_action(enemies[1], math.max(terrain_module.radius, 30000), terrain_module.encounter)
		end
	end)
	terrain_module.enemy_faction = "Exuari"
	terrain_module.skip_enemies = true
	terrain_module.gossip = string.format("The Exuari sometimes appear near here out of nowhere, kill someone, and are away again.")
	--terrain_module.canInsertEnemies = function(_)
	--	return false
	--end
	return true
end

function avp_story:mineThrowerSeek(terrain_module)
	assert(terrain_module.terrain_type == "mines")
	terrain_module.enemy_faction = "Ghosts"
	terrain_module:registerOnCreationCallback(function(terrain_module, ship)
		log(string.format("%s discovered %s %s with %s", ship:getCallSign(), terrain_module.terrain_type, terrain_module.zone_name, terrain_module.encounter))
		local station = avp_stations:createEnemyStation({"Medium Station"}, {"Spec Sci Fi", "RandomHumanNeutral", "Random"}, terrain_module)
		station:setFaction(terrain_module.enemy_faction)
		for idx,mine in ipairs(terrain_module.mines) do
			vf_mine_dance:addSeekingMine(mine)
		end
		vf_comms_call_to_action:call_to_action(station, math.max(terrain_module.radius, 30000), terrain_module.encounter)
	end)
	terrain_module.gossip = string.format("Recently we intercepted a software-update for target seeking mines on a subspace frequency.")
	return true
end

function avp_story:mineThrowerDance(terrain_module)
	assert(terrain_module.terrain_type == "mines")
	terrain_module.enemy_faction = "Criminals"
	terrain_module:registerOnCreationCallback(function(terrain_module, ship)
		log(string.format("%s discovered %s %s with %s", ship:getCallSign(), terrain_module.terrain_type, terrain_module.zone_name, terrain_module.encounter))
		local station = avp_stations:createEnemyStation({"Medium Station"}, {"Spec Sci Fi", "RandomHumanNeutral", "Random"}, terrain_module)
		station:setFaction(terrain_module.enemy_faction)
		for idx,mine in ipairs(terrain_module.mines) do
			vf_mine_dance:addDancingMine(station, mine, terrain_module.radius, idx%2==1)
		end
		vf_comms_call_to_action:call_to_action(station, math.max(terrain_module.radius, 30000), terrain_module.encounter)
	end)
	terrain_module.getEnemySpawnPositions = function(self)
		return self:calculateSpawnPositionsOnRing(self.radius)
	end
	terrain_module.gossip = string.format("A mad scientist sometimes visits us. They must have a laboratory somewhere near.")
	return true
end

function avp_story:mineThrower(terrain_module)
	local encounter = self:selectEncounter("mineThrower")
	terrain_module.encounter = encounter	-- store the name
	log(string.format("(%s)", terrain_module.encounter))
	return self[encounter](self, terrain_module)
end

function avp_story:kraylorMotherbase(terrain_module)
	assert(terrain_module.terrain_type == "mines")
	terrain_module:registerOnCreationCallback(function(terrain_module, ship)
		log(string.format("%s discovered %s %s with %s", ship:getCallSign(), terrain_module.terrain_type, terrain_module.zone_name, terrain_module.encounter))
		local carrier = EnemyModuleKraylor:spawnBossMothership()
		avp_stations:insertStation(carrier, terrain_module)
		local x,y = carrier:getPosition()
		for idx, base in ipairs(EnemyModuleKraylor:spawnBossBases()) do
			local x1,y1 = radialPosition(x, y, 3000, idx*90)
			base:setPosition(x1,y1)
			x1,y1 = radialPosition(x, y, 1000, idx*90)
			wh_artifacts:placeGenericArtifact(x1,y1)
		end
		vf_comms_call_to_action:call_to_action(carrier, math.max(terrain_module.radius, 30000), terrain_module.encounter)
	end)
	terrain_module.enemy_faction = "Kraylor"
	terrain_module.gossip = string.format("From time to time Kraylor supply vessels travel through here to the %s nearby. There must be something there...", terrain_module.terrain_type)
	return true
end

function avp_story:conflict(terrain_module)
	assert(terrain_module.terrain_type == "planets")
	assert(terrain_module.canInsertEnemies ~= nil)
	if not terrain_module:canInsertEnemies() then return false end
	terrain_module:registerOnCreationCallback(function(terrain_module, ship)
		log(string.format("%s discovered %s %s with %s", ship:getCallSign(), terrain_module.terrain_type, terrain_module.zone_name, terrain_module.encounter))
		local positions = terrain_module:getEnemySpawnPositions()
		local strength = avp_story:enemyStrength(terrain_module)
		local closest_contact = nil
		local closest_contact_dist = 9999999
		local farest_contact = nil
		local farest_contact_dist = 0
		for idx, faction in ipairs(arrayShuffle({"Kraylor", "Exuari", "Ktlitans", "Ghosts", "Criminals"})) do
			local fleet = avp_enemies.modules[faction]:spawnEnemiesAtPositions({positions[idx]}, strength/4)
			if #fleet >= 1 then
				local dist = distance(ship, fleet[1])
				if dist < closest_contact_dist then
					closest_contact = fleet[1]
					closest_contact_dist = dist
				end
				if dist > farest_contact_dist then
					farest_contact = fleet[1]
					farest_contact_dist = dist
				end
			end
		end
		if closest_contact ~= nil then
			vf_comms_call_to_action:call_to_action(closest_contact, 20000, terrain_module.encounter .. closest_contact:getFaction())
		end
		if farest_contact ~= nil then
			vf_comms_call_to_action:call_to_action(farest_contact, 20000, terrain_module.encounter .. farest_contact:getFaction())
		end
	end)
	terrain_module.skip_enemies = true
	terrain_module.gossip = string.format("There is an ongoing conflict between different faction near the %s next to our area.", terrain_module.terrain_type)
	return true
end

function avp_story:instableWormhole(terrain_module)
	assert(terrain_module.terrain_type == "wormholes")
	terrain_module:registerOnCreationCallback(function(terrain_module, ship)
		log(string.format("%s discovered %s %s with %s", ship:getCallSign(), terrain_module.terrain_type, terrain_module.zone_name, terrain_module.encounter))
		for _,wh in ipairs(terrain_module.wormholes) do
			wh:onTeleportation(vf_wormhole_instable.onTeleportation)
		end
		if terrain_module:canInsertStation() then
			local station = avp_stations:createIndependentStation(terrain_module)
			if station ~= nil then
				terrain_module.cta = vf_comms_call_to_action:call_to_action(station, 20000, terrain_module.encounter)
			end
		end
	end)
	terrain_module.gossip = string.format("From time to time we get reading from objects that travel through the wormholes nearby. Our reading show, that a wormhole is slowly collapsing, making travel more risky with every jump.")
	return true
end

function avp_story:boss(terrain_module)
	local encounter = self:selectEncounter(terrain_module.terrain_type .. "Boss")
	terrain_module.encounter = encounter	-- store the name
	log(string.format("(%s)", terrain_module.encounter))
	return self[encounter](self, terrain_module)
end

function avp_story.onTerrainCreation(terrain_module, player)
	--if true then
	--	return true
	--end
	-- so, we generated some terrain, what happens next?
	-- first, update world and player facts
	-- terrain specific facts are stored in terrain_module
	-- then select what effects apply (effects are functions), and call them
	-- effects may access the facts to determine if or how they apply
	self = avp_story

	-- global facts
	self.terrain_discovered = self.terrain_discovered + 1
	if self.time_first_discoverey == 0 then
		self.time_first_discoverey = getScenarioTime()
	end

	-- player facts
	if player.terrain_discovered == nil then
		player.terrain_discovered = 1
	else
		player.terrain_discovered = player.terrain_discovered + 1
	end


	--local motivation = self:getMotivation()



	if terrain_module.stations == nil and terrain_module:canInsertStation() then
		avp_stations:createIndependentStation(terrain_module)
	end
	if terrain_module.enemy_faction == nil then
		terrain_module.enemy_faction = self:selectEncounter(terrain_module.terrain_type .. "Enemies")
	end
	local enemies = {}
	if terrain_module:canInsertEnemies() then
		local positions = terrain_module:getEnemySpawnPositions()
		enemies, terrain_module.enemy_faction = avp_enemies:spawn(positions, terrain_module.enemy_faction, avp_story:enemyStrength(terrain_module))
	end

	local station = terrain_module:getStation()
	if station ~= nil and station.typeName == "SpaceStation" and station:getFaction() == "Independent" then
		if terrain_module.enemy_faction == "Kraylor" then
			-- Kraylor already own their stations, overwrites call to action message, if stored
			station.comms_data.orig_faction = station:getFaction()
			station:setFaction("Kraylor")
			if terrain_module.cta ~= nil and terrain_module.cta.source == station then
				terrain_module.cta.message = vf_comms_call_to_action:selectMessage("kraylorOccupiedStation")
			end
			log("Kraylor occupied")
		else
			if vf_bescheid ~= nil then
				vf_bescheid:sag_bescheid("independent_station_found", {
					callsign=station:getCallSign(),
					sector=station:getSectorName(),
				})
			end
		end
	end
end

function avp_story:enemyStrength(terrain_module)
	local hours_of_game = (getScenarioTime() - self.time_first_discoverey) / 3600
	local radius_factor = math.sqrt(terrain_module.radius / 5000)
	local gm_adjustment = self.gm_difficulty_adjustment
	local player_strength = 0
	for _,ship in ipairs(getActivePlayerShips()) do
		local hull = ship:getHullMax()
		if hull >= 500 then
			-- stations have about 1000 hull, they should count as one ship
			player_strength = player_strength + hull / 1000
		elseif hull >= 100 then
			-- capital ships have between 100 and 250 hull
			player_strength = player_strength + hull / 100
		else
			-- fighters have < 100 hull, they count only half
			player_strength = player_strength + hull / 200
		end
	end
	-- player_strength: ~2-12
	-- hours: ~1-5
	-- discovery_score: ~1-35
	-- radius_factor: ~1-6
	-- difficulty: ~ 5-30 * 10
	local difficulty = 10 * math.max(1,(player_strength + hours_of_game + self.terrain_discovered + radius_factor + gm_adjustment))
	--log(string.format("Difficulty: %.1f\tPlayers: %.1f\tTime: %.1f\tDiscovery: %.1f\tRadius: %.1f", difficulty, player_strength, hours_of_game, self.terrain_discovered, radius_factor))
	return difficulty
end

function avp_story:gm_menu()
    addGMFunction(_("buttonGM", "Lower Enemy Strength"), function()
		avp_story.gm_difficulty_adjustment = avp_story.gm_difficulty_adjustment -1
		log("Difficulty adjustment:", avp_story.gm_difficulty_adjustment)
	end)
    addGMFunction(_("buttonGM", "Raise Enemy Strength"), function 
		avp_story.gm_difficulty_adjustment = avp_story.gm_difficulty_adjustment +1
		log("Difficulty adjustment:", avp_story.gm_difficulty_adjustment)
	end)
end

function avp_story:spawn_threat(station, player)
	-- send enemies whenever the players gained some ground
	-- triggered by upgrades or station favor
	local terrain_module = station.terrain_module
	local faction = station:getFaction()
	if terrain_module == nil then
		log("spawn_threat: station has no terrain module")
		terrain_module = {
			radius = 5000
		}
	end
	local enemy_faction
	if faction == "Arlenians" then
		enemy_faction = arraySelectRandom({"Kraylor", "Exuari"})
	elseif faction == "Independent" then
		enemy_faction = arraySelectRandom({"Kraylor", "Criminals"})
	else
		enemy_faction = arraySelectRandom({"Kraylor", "Exuari", "Criminals"})
		-- ghosts and hive do not attack
	end
	local strength = avp_story:enemyStrength(terrain_module) / 4	-- small
	local x,y = vf_ambush:findBestAmbushPosition(player)
	local enemies, enemy_faction = avp_enemies:spawn({{x,y}}, enemy_faction, strength)
	for __,leader in ipairs(enemies) do
		if station:isEnemy(leader) then
			leader:orderAttack(station)
		else
			leader:orderAttack(player)
		end
	end
end

-- module specific events

-- tests
if TEST ~= true then
	avp_story:init()
	log("### begin test ##################################################")
	test_selectEncounter()
	test_selectTerrainEncounter()
	log("### end test ####################################################")
end

