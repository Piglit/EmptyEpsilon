
avp_story = {}

function avp_story:init()
	self.stations_discovered = 0
end

function avp_story.onStationCreation(terrain_module)
	self = avp_story
	local station, enemy_faction

	if terrain_module:canInsertStation() then
		self.stations_discovered = self.stations_discovered + 1

		station = avp_stations:createInTerrain(terrain_module)
	end
	if station == nil then
		-- Ktlitans dwell in the center, where it is too inhospitable for stations
		enemy_faction = "Ktlitans"
	elseif self.stations_discovered <= 4 then
		-- the exploration story starts with ghosts
		enemy_faction = "Ghosts"
	elseif terrain_module.terrain_type == "nebulae" then
		-- Exuari populate the nebulae, for surprise attacks
		enemy_faction = "Exuari"
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
	   	enemies, enemy_faction = avp_enemies:spawn(positions, enemy_faction)
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
