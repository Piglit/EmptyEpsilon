
avp_story = {}

function avp_story:init()
	self.stations_discovered = 0
end

function avp_story.onStationCreation(terrain_module)
	self = avp_story
	if terrain_module:canInsertStation() then
		self.stations_discovered = self.stations_discovered + 1
		local station = avp_stations:createInTerrain(terrain_module)
	end
	if terrain_module:canInsertArtifact() then
		terrain_module:insertArtifact()
	end

	if terrain_module:canInsertEnemies() then
		local positions = terrain_module:getEnemySpawnPositions()
		avp_enemies:spawn(positions)
	end
end
