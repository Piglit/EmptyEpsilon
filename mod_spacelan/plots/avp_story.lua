
avp_story = {}

function avp_story:init()
	self.stations_discovered = 0
	self.terrain_discovered = 0
	self.time_first_discoverey = 0
end

function avp_story.onStationCreation(terrain_module)
	self = avp_story
	self.terrain_discovered = self.terrain_discovered + 1
	if self.time_first_discoverey == nil then
		self.time_first_discoverey = getScenarioTime()
	end

	local station, enemy_faction

	if terrain_module:canInsertStation() then
		self.stations_discovered = self.stations_discovered + 1

		station = avp_stations:createInTerrain(terrain_module)
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

	if terrain_module:canInsertArtifact() then
		terrain_module:insertArtifact()
		if enemy_faction == nil and	random(0,1) > 0.25 then
			-- Criminals like artifacts
			enemy_faction = "Criminals"
		end	
	end

	if terrain_module:canInsertEnemies() then
		local positions = terrain_module:getEnemySpawnPositions()
		local enemies
	   	enemies, enemy_faction = avp_enemies:spawn(positions, enemy_faction, self:enemyStrength(terrain_module))
	end

	if station ~= nil and enemy_faction == "Kraylor" then
		-- Kraylor already own their stations
		station:setFaction("Kraylor")
	end
	if station ~= nil and enemy_faction == "Exuari" and terrain_module.terrain_type ~= "nebulae" then
		-- Exuari are attacking the station, so make it Arlenian, so Exuari can attack it
		-- But Exuati try to hide in nebulae, so do not switch station faction then.
		station:setFaction("Arlenians")
	end


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
