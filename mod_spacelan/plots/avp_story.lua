require "utils"

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
--]]


avp_story = {
	stations_discovered = 0,
	terrain_discovered = 0,
	time_first_discoverey = 0,
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
	-- the first entry of any entrypoint (...Reward) must always be applicable!
	-- every terrain type appears about 7 times. nebulae and asteroids up to 14 times
	self.randomEffects = {
		-- rewards
		asteroidsReward = {"hiddenArtifact", "arlenianStation", "asteroidsBoss"},
		nebulaeReward = {"nebulaEffect", "arlenianStation", "exuariAmbush", "nebulaeBoss"},	-- störfelder, artefakt im totesten winkel, verborgene feinde, bewegliche nebel
		minesReward = {"mineThrower", "arlenianStation", "kraylorFortress", "minesBoss"}, -- aushalten/ausweichen, um belohnung zu erlangen
		planetsReward = {"conflict", "arlenianStation", "planetsBoss"},
		blackholesReward = {"collapseArtifact", "blackholesBoss"},	-- hard challenge, so use it everywhere?
		wormholesReward = {"instableWormhole", "arlenianStation", "wormholesBoss"},

		-- boss is a subtype of reward; it may set the enemy faction
		asteroidsBoss = {"derelictStation", "pirateStation", "kraylorBase"},
		nebulaeBoss = {"exuariCarrier", "pirateStation", "ktlitanQueen"},
		minesBoss = {"derelictStation", "kraylorBase", "ghostStation"},
		planetsBoss = {"exuariCarrier", "ktlitanQueen", "ghostStation"},
		blackholesBoss = {"exuariCarrier", "kraylorBase", "ghostStation"},
		wormholesBoss = {"pirateStation", "kraylorBase", "ktlitanQueen"},

		-- two default factions; if a bossfight occures, others may be set
		asteroidsEnemies = {"Criminals", "Kraylor"},
		nebulaeEnemies = {"Ktlitans", "Ghosts"},
		minesEnemies = {"Kraylor", "Exuari"},
		planetsEnemies = {"Ktlitans", "Criminals"},
		blackholesEnemies = {"Ghosts", "Kraylor"},
		wormholesEnemies = {"Kraylor", "Exuari"},
	}

	self.effectIndex = {}
end

function avp_story:selectEffect(effectId)
	-- calls next effect, reroll sample when all are used once
	assert(self.randomEffects[effectId] ~= nil, "no effect category "..effectId)
	if self.effectIndex[effectId] == nil or self.effectIndex[effectId] >= #self.randomEffects[effectId] then
		self.randomEffects[effectId] = arrayShuffle(self.randomEffects[effectId])
		self.effectIndex[effectId] = 1
	else
		self.effectIndex[effectId] = self.effectIndex[effectId] + 1
	end
	local effect = self.randomEffects[effectId][self.effectIndex[effectId]]
	assert(self[effect] ~= nil, "no such effect "..effect)
	return effect
end

function test_selectEffect()
	for k,v in pairs(avp_story.randomEffects) do
		for i=1, 2*#v do
			avp_story:selectEffect(k)
		end
	end
end

function avp_story:selectTerrainReward(terrain_module)
	-- roll a reward, depending on terrain type
	local reward = terrain_module.terrain_type .. "Reward"
	local effect = self:selectEffect(reward)
	local abort_counter = #self.randomEffects[reward]
	while self[effect](self, terrain_module) == false do
		-- try again, if this effect returns false
		effect = self:selectEffect(reward)
		abort_counter = abort_counter -1
		if abort_counter < 0 then
			print("all effects are invalid for "..reward)
			return
		end
	end
end

function test_selectTerrainReward()
	for _,t in ipairs({"asteroids", "nebulae", "mines", "planets", "blackholes", "wormholes", "meta"}) do
		local tm = {
			terrain_type = t,
			canInsertStation = function() return false end,
			canInsertArtifact = function() return false end,
			registerOnCreationCallback = function(f) end
		}
		avp_story:selectTerrainReward(tm)
	end
end

-- specific effect functions
-- the terrain_module is not created, when this functions are called.
-- they may use the registerOnCreationCallback funtion of the terrain_module to apply the actual effects

function avp_story:arlenianStation(terrain_module)
	-- TODO select type of station depending on terrain type
	if not terrain_module:canInsertStation() then return false end
	terrain_module:registerOnCreationCallback(function(terrain_module, ship)
		local station = nil -- TODO; maybe call avp_stations
		terrain_module:insertStation(station)
	end)
	return true
end

function avp_story:destroyableContainingArtifact(terrain_module)
	-- TODO terrain type restricts boss types
	if not terrain_module:canInsertStation() then return false end
	self:selectEffect("destroyableContainingArtifact")
	return true
end

function avp_story:derelictStation(terrain_module)
	terrain_module:registerOnCreationCallback(function(terrain_module, ship)
		local station = nil -- TODO; maybe call avp_stations
		terrain_module:insertStation(station)
	end)
	return true
end

function avp_story:exuariCarrier(terrain_module)
	terrain_module:registerOnCreationCallback(function(terrain_module, ship)
		local station = nil -- TODO; maybe call avp_stations
		terrain_module:insertStation(station)
	end)
	return true
end

function avp_story:pirateStation(terrain_module)
	terrain_module:registerOnCreationCallback(function(terrain_module, ship)
		local station = nil -- TODO; maybe call avp_stations
		terrain_module:insertStation(station)
	end)
	return true
end

function avp_story:ktlitanQueen(terrain_module)
	terrain_module:registerOnCreationCallback(function(terrain_module, ship)
		local station = nil -- TODO; maybe call avp_stations
		terrain_module:insertStation(station)
	end)
	return true
end

function avp_story:kraylorBase(terrain_module)
	terrain_module:registerOnCreationCallback(function(terrain_module, ship)
		local station = nil -- TODO; maybe call avp_stations
		terrain_module:insertStation(station)
	end)
	return true
end

function avp_story:ghostStation(terrain_module)
	terrain_module:registerOnCreationCallback(function(terrain_module, ship)
		local station = nil -- TODO; maybe call avp_stations
		terrain_module:insertStation(station)
	end)
	return true
end

function avp_story:hiddenArtifact(terrain_module)
	if not terrain_module:canInsertArtifact() then return false end
	assert(terrain_module.terrain_type == "asteroids")
	terrain_module:registerOnCreationCallback(function(terrain_module, ship)
		terrain_module:insertArtifact()
	end)
	return true
end

function avp_story:collapseArtifact(terrain_module)
	if not terrain_module:canInsertArtifact() then return false end
	assert(terrain_module.terrain_type == "blackholes")
	terrain_module:registerOnCreationCallback(function(terrain_module, ship)
		terrain_module:insertArtifact(vf_blackhole.triggerCollapse)
	end)
	return true
end

function avp_story:nebulaEffect(terrain_module)
	assert(terrain_module.terrain_type == "nebulae")
	terrain_module:registerOnCreationCallback(function(terrain_module, ship)
		-- TODO
	end)
	return true
end

function avp_story:exuariAmbush(terrain_module)
	assert(terrain_module.terrain_type == "nebulae")
	terrain_module:registerOnCreationCallback(function(terrain_module, ship)
		-- TODO
	end)
	return true
end

function avp_story:mineThrower(terrain_module)
	assert(terrain_module.terrain_type == "mines")
	terrain_module:registerOnCreationCallback(function(terrain_module, ship)
		-- TODO
	end)
	return true
end

function avp_story:kraylorFortress(terrain_module)
	assert(terrain_module.terrain_type == "mines")
	terrain_module:registerOnCreationCallback(function(terrain_module, ship)
		-- TODO
	end)
	return true
end

function avp_story:conflict(terrain_module)
	assert(terrain_module.terrain_type == "planets")
	terrain_module:registerOnCreationCallback(function(terrain_module, ship)
		-- TODO
	end)
	return true
end

function avp_story:instableWormhole(terrain_module)
	assert(terrain_module.terrain_type == "wormholes")
	terrain_module:registerOnCreationCallback(function(terrain_module, ship)
		-- TODO
	end)
	return true
end

--[[
	-- effects per terrain type
	-- there sould be:
	-- * a combat encounter
	-- * something to explore / a call to action
	-- * a challenge
	-- * a reward
	-- effects may write additional facts or adjust the difficulty rating for enemies
	-- every terrain type appears about 7 times. nebulae and asteroids up to 14 times

	if terrain_module.terrain_type == "asteroids" then
		self.addPirateHideout, self.addConflict, self.addRelict, self.addAggressor, self.addQuestgiver, self.addTechBase
	elseif terrain_module.terrain_type == "nebulae" then
		self:addNebulaEffect(terrain_module)	-- Coolant +/-, some malfunction, etc...
	elseif terrain_module.terrain_type == "mines" then
	elseif terrain_module.terrain_type == "planets" then
	elseif terrain_module.terrain_type == "blackholes" then
		self:addCollapseArtifact(terrain_module)
	elseif terrain_module.terrain_type == "wormholes" then
	end
		"asteroids" = arrayShuffle({}),
		"nebulae" = arrayShuffle({self.addNebulaEffect, self.addRelict, self.addBoss, self.addAggressor, self.addQuestgiver, self.addTechBase}),
		"mines" = arrayShuffle({self.addMineThrower, self.addRelict, self.addAggressor, self.addQuestgiver, self.addTechBase}),
		"planets" = arrayShuffle({self.addConflict, self.addAggressor, self.addQuestgiver, self.addTechBase}),
		"blackholes" = {self.addAggressor, self.addQuestgiver, self.addTechBase},
		"wormholes" = arrayShuffle({self.addInstableWormholeEffect, self.addAggressor, self.addQuestgiver, self.addTechBase}),

end
--]]
--function avp_story:getMotivation()
--	self.motivations_index = self.motivations_index +1
--	if self.motivations_index > #self.motivations then
--		arrayShuffle(self.motivations)
--		self.motivations_index = 1
--	end
--	return = self.motivations[self.motivations_index]
--end

function avp_story.onTerrainCreation(terrain_module, player)
	-- so, we generated some terrain, what happens next?
	-- first, update world and player facts
	-- terrain specific facts are stored in terrain_module
	-- then select what effects apply (effects are functions), and call them
	-- effects may access the facts to determine if or how they apply

	self = avp_story

	-- global facts
	self.terrain_discovered = self.terrain_discovered + 1
	if self.time_first_discoverey == nil then
		self.time_first_discoverey = getScenarioTime()
	end

	-- player facts
	if player.terrain_discovered == nil then
		player.terrain_discovered = 1
	else
		player.terrain_discovered = player.terrain_discovered + 1
	end

	self:selectTerrainReward(terrain_module, player)


	--local motivation = self:getMotivation()

	local station, enemy_faction, artifact_callback

	if terrain_module:canInsertStation() then
		self.stations_discovered = self.stations_discovered + 1

		station = avp_stations:createInTerrain(terrain_module)
		-- TODO determine what station & call to action
	end
	if station == nil or terrain_module.terrain_type == "nebulae" then
		-- Ktlitans and Exuari:
		-- they dwell in the center, where it is too inhospitable for stations
		-- and populate the nebulae, for surprise attacks
		if irandom(1,2) == 1 then
			enemy_faction = "Ktlitans"
		else
			enemy_faction = "Exuari"
		end
	end

--	if terrain_module:canInsertArtifact() then
--		terrain_module:insertArtifact(artifact_callback)
--		if enemy_faction == nil and	random(0,1) > 0.25 then
--			-- Criminals like artifacts
--			enemy_faction = "Criminals"
--		end	
--	end

	local enemies = {}
	if terrain_module:canInsertEnemies() then
		local positions = terrain_module:getEnemySpawnPositions()
	   	enemies, enemy_faction = avp_enemies:spawn(positions, enemy_faction, self:enemyStrength(terrain_module))
	end

	if station ~= nil and enemy_faction == "Kraylor" then
		-- Kraylor already own their stations
		station:setFaction("Kraylor")
	end
	if station ~= nil and enemy_faction == "Exuari" and terrain_module.terrain_type ~= "nebulae" then
		-- Exuari are attacking the station, so make it Arlenian, so Exuari can attack it
		-- But Exuari try to hide in nebulae, so do not switch station faction then.
		station:setFaction("Arlenians")
	end


	--if terrain_module.terrain_type == "blackholes" then
	--	local questgivers = {
	--		station,
	--		--ship,
	--		enemies[1],	-- maybe more?
	--	}
	--	vf_cta:contactPlayer(player, questgivers, vf_blackhole.contact)
	--end
end

function avp_story:enemyStrength(terrain_module)
	local hours_of_game = (getScenarioTime() - self.time_first_discoverey) / 3600
	local radius_factor = math.sqrt(terrain_module.radius / 5000)
	local gm_adjustment = 0	--TODO
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
	-- difficulty: ~ 5-30
	local difficulty = 10 * (player_strength + hours_of_game + self.terrain_discovered + radius_factor + gm_adjustment)
	--print(string.format("Difficulty: %.1f\tPlayers: %.1f\tTime: %.1f\tDiscovery: %.1f\tRadius: %.1f", difficulty, player_strength, hours_of_game, self.terrain_discovered, radius_factor))
	return difficulty
end


-- module specific events

-- tests
if TEST ~= true then
	avp_story:init()
	test_selectEffect()
	test_selectTerrainReward()
end

