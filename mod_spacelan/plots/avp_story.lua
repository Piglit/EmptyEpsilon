
avp_story = {}

function avp_story:init()
	self.stations_discovered = 0
end

function avp_story.onStationCreation(terrain_module)
	self = avp_story
	self.stations_discovered = self.stations_discovered + 1
	local station = avp_stations:createInTerrain(terrain_module)
end
