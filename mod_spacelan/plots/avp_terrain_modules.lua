--[[ Terrain modules
contains small modular terrain elements.

Elements:
* Asteroid field
* Nebulae
* Black hole
* Mine field
* Planet
* Wormhole
* Meta: bigger landscape, consisting of above elements

Parameters:
* x,y and/or direction, distance: center of the module - see check()
* rotation (arc) and/or direction
* radius (all colliding elements and gravity fields must be completely inside)
* terrain specific args

Methods/Attributes:
* check(): checks args for validity, calculates centre, if not given
* create(): creates terrain - must be defined in subclasses
* insertStation(station): sets position of station inside terrain
* insertObject(obj, dist, orientation): sets position of an object inside terrain, distance from 0.0-1.0 (centre to rim), orientation is direction as string
* place defending/transport ship ()
* place attacking ship ()
* animate(dt)
* callbacks


requires: utils.lua (vectorFromAngle)
--]]

require "utils.lua"

avp_terrain_modules = {
	modules = {},
	hidden_modules = {},
	zone_names = nil,
}

local TerrainModule = {}

function TerrainModule:new(obj)
	obj = obj or {} -- create empty if none given 
	setmetatable(obj, self)
	self.__index = self
	table.insert(avp_terrain_modules.modules, obj)
	--if obj.terrain_type ~= nil then
	--	log("new "..obj.terrain_type)
	--end
	if obj.terrain_type ~= nil then
		obj.terrain_type_localised = _(obj.terrain_type)
	end
	return obj
end

-- if direction and distance are given, x and y are determined from them
function TerrainModule:calculatePosition()
	if self.position_calculated then
		return self
	end
	if self.direction ~= nil and self.distance ~= nil then
		assert(type(self.direction) == "number")
		assert(type(self.distance) == "number")
		if self.x == nil and self.y == nil then
			self.x, self.y = vectorFromAngle(self.direction, self.distance)
		else
			assert(type(self.x) == "number")
			assert(type(self.y) == "number")
			self.x, self.y = radialPosition(self.x, self.y, self.distance, self.direction)
		end
		self.rotation = self.rotation or self.direction
	end
	self.position_calculated = true
	return self
end

function TerrainModule:placeZone()
	if self.zone ~= nil then
		return self
	end
	local points = {}
    for i=1,12 do
        local x,y = radialPosition(self.x, self.y, self.radius, i*360/12)
        table.insert(points, x)
        table.insert(points, y)
    end
    self.zone = Zone():setPoints(table.unpack(points))
	--set label
	self.zone_name = ""
	if self.radius > 5000 then
		-- not too small to read
		if #self.zone_names == 0 then
			self.zone_names = TerrainModule.zone_names
		end
		if #self.zone_names > 0 then
			-- pop one element
			self.zone_name = table.remove(self.zone_names)
		end
	end
	return self					   
end

function TerrainModule:labelZone()
	-- not every zone gets a label
	-- the label is set on discovery in create()
	if self.zone_name ~= "" then
		self.zone:setLabel(self.zone_name)
	end
	return self
end
-- checks the center, radius and rotation of a terrain module for validity
-- must be called before/by create
function TerrainModule:check()
	self:calculatePosition()
	assert(self.x ~= nil)
	assert(type(self.x) == "number")
	assert(self.y ~= nil)
	assert(type(self.y) == "number")
	assert(self.radius ~= nil)
	assert(type(self.radius) == "number")
	self.rotation = self.rotation or 0
	assert(type(self.rotation) == "number")
	self:placeZone()
	assert(self.terrain_type ~= nil)	
	assert(self.canInsertShip ~= nil)	
	assert(self.canInsertStation ~= nil)	
	assert(self.canInsertArtifact ~= nil)	
	assert(self.canInsertEnemies~= nil)	
	return self
end

function TerrainModule:createWhenVisible()
	-- calls create() as soon as the border is visible to players
	-- calls call registered callbacks
	-- probes can not find it, they are stopped on entering
	self:check()
	table.insert(avp_terrain_modules.hidden_modules, self)
end

function TerrainModule:registerOnCreationCallback(callback)
	if self.onCreationCallbacks == nil then
		self.onCreationCallbacks = {}
	end
	table.insert(self.onCreationCallbacks, callback)
end

function TerrainModule:canInsertArtifact()
	return false
end

function TerrainModule:canInsertStation()
	return self.radius > 5000
end

function TerrainModule:canInsertEnemies()
	return self.radius > 5000 and not self.skip_enemies
end

function TerrainModule:canInsertShip()
	return true
end

function TerrainModule:insertStation(station)
	-- default implementation
	-- places a station inside the module
	if self.stations == nil then
		self.stations = {}
	end
	table.insert(self.stations, station)
	if self.station_distance_rad ~= nil then
		self:insertObject(station, self.station_distance_rad)
	else
		self:insertObject(station, 0.75)
	end
	station.terrain_module = self
end

function TerrainModule:getStation()
	-- returns the first valid station
	if self.stations ~= nil then
		for _,station in ipairs(self.stations) do
			if station ~= nil and station:isValid() then
				return station
			end
		end
	end
	return nil
end

function TerrainModule:insertShip(ship, visitor)
	-- default implementation
	-- places a ship inside the module
	if self.ships == nil then
		self.ships = {}
	end
	table.insert(self.ships, ship)
	local orientation = "near"
	if visitor ~= nil and visitor:isValid() then
		-- in direction of the player that finds this TerrainModule 
		orientation = angleRotation(visitor, self.x, self.y)
	end
	if self.ship_distance_rad ~= nil then
		self:insertObject(ship, self.ship_distance_rad, orientation)
	else
		self:insertObject(ship, 0.99, orientation)
	end
end

function TerrainModule:insertObject(obj, dist, orientation)
	-- places an object inside the module
	assert(type(dist) == "number")
	local arc = random(1, 360)
	if orientation == "east" then
		arc = 0
	elseif orientation == "south" then
		arc = 90
	elseif orientation == "west" then
		arc = 180
	elseif orientation == "north" then
		arc = 270
	elseif orientation == "near" then
		if self.direction ~= nil then
			arc = self.direction
		else
			arc = self.rotation
		end
	elseif orientation == "far" then
		if self.direction ~= nil then
			arc = self.direction + 180
		else
			arc = self.rotation + 180
		end
	elseif type(orientation) == "number" then
		arc = orientation
		orientation = nil
	end
	if orientation ~= "nil" then
		arc = arc + random(-45, 45)
	end
	local x,y = radialPosition(self.x, self.y, self.radius*dist, arc)
	obj:setPosition(x,y)
end

function TerrainModule:getEnemySpawnPositions()
	-- returns an array of tuples with spawn positions for this module
	-- If more enemies are used, the positioning starts again at the first coordinate
	-- default implementation, to be overridden by subclasses
	return {{0,0}}
end

function TerrainModule:calculateSpawnPositionsOnRing(distance)
	local rot = self.rotation
	local positions = {}
	for i = 1, 50 do
		rot = rot + 360/i
		local x,y = radialPosition(self.x, self.y, distance, rot)
		table.insert(positions, {x,y})
	end
	return positions

end

function avp_terrain_modules:updatePlayerShip(delta, ship)
	-- if a hidden module comes into view, create it and call onCreation callbacks
	for idx, module in ipairs(self.hidden_modules) do
		if distance(ship, module.x, module.y) <= ship:getLongRangeRadarRange() + module.radius + 5000 then
			module:create()
			--if module.terrain_type ~= nil then
			--	log("created "..module.terrain_type)
			--end
			table.remove(self.hidden_modules, idx)
			if module.onCreationCallbacks ~= nil then
				for _,cb in ipairs(module.onCreationCallbacks) do
					cb(module, ship)
				end
			end
			return
		end
	end
end

function avp_terrain_modules:update(delta)
	-- if a probe would enter a hidden module, stop the probe
	for _, module in ipairs(self.hidden_modules) do
		for _,obj in ipairs(getObjectsInRadius(module.x, module.y, module.radius+5000)) do
			if obj.typeName == "ScanProbe" then
				local x,y = obj:getPosition()
				obj:setTarget(x,y)
			end
		end
	end
end

-- new 'subclasses'
TerrainModuleAsteroids = TerrainModule:new{terrain_type="asteroids"}
TerrainModuleNebulae = TerrainModule:new{terrain_type="nebulae"}
TerrainModuleMines = TerrainModule:new{terrain_type="mines"}
TerrainModulePlanets = TerrainModule:new{terrain_type="planets"}
TerrainModuleBlackHoles = TerrainModule:new{terrain_type="blackholes"}
TerrainModuleWormHoles = TerrainModule:new{terrain_type="wormholes", all_wormholes={}}
TerrainModuleMeta = TerrainModule:new{terrain_type="meta"}
TerrainModuleMetaSpiral = TerrainModuleMeta:new{}

-- locale:
_("asteroids")
_("nebulae")
_("mines")
_("planets")
_("blackholes")
_("wormholes")

function TerrainModuleMeta:placeZone()
	-- do not create a zone for the meta modules
	return self
end

TerrainModule.zone_names = arrayShuffle({
	"Strahlen des Ponies",
	"Eisernes Hufeisen",
	"Fliege des Hundes",
	"Kupferner Hängeleuchter",
	"Schnurrhaare des Dachses",
	"Helm des Königs",
	"Kern der Melone",
	"Führung des Tentakels",
	"Leere der Unerfahrenheit",
	"Verschüttung der Kartoffelsuppe",
	"Trostlosigkeit von Saliba",
	"Stern der Muhlaktika",
	"Geweih des Jägers",
	"Eisberg 2",
	"Großer Hauptbahnhof",
	"Das Eckige",
	"Ybb T'strl",
	"Traum von Jules Verne",
	"Friedhof der Offiziere",
	"Endhaltestelle",
	"Ihrer Majestät Missfallen",
	"Padmes Lebensfreude",
	"Sicherer Raum",
	"Ende der Vernunft",
})

TerrainModuleAsteroids.zone_names = arrayShuffle({
	"Der Haufen",
	"Beltalowda",
	"Glas voll Dreck",
})

TerrainModuleNebulae.zone_names = arrayShuffle({
	"Phileas Fogg",
	"Der siebte Schleier",
	"Blauer Rauch",
})

TerrainModuleMines.zone_names = arrayShuffle({
	"Begierde der Möve",
	"Testgelände 7",
})

TerrainModulePlanets.zone_names = arrayShuffle({
	"Kosmische Jonglage",
	"Bunte Kugel",
	"Heimatwelt 48",
})

TerrainModuleBlackHoles.zone_names = {	-- not shuffeled
	"Offenbarung der Zwillinge",
	"Loch Ness",
	"Immerwährende Dunkelheit",
	"Vermächtnis der Nacht",
}

TerrainModuleWormHoles.zone_names = arrayShuffle({
	"Einstein-Rosen-Brücke 3",
	"Reisebüro Delta",
})

function TerrainModuleAsteroids:create()
	-- places asteroids in a nice manner
	self:check()
	local rings_amount = math.max(1,math.floor(self.radius / 5000))
	local rings_distance = self.radius / (rings_amount + 1)
	local rotation = self.rotation
	for stripe = 1, rings_amount do
		local stripe_dist = stripe * rings_distance
		local layers = 3
		local width = rings_distance/layers
		rotation = rotation + random(0, 180)
		for layer = 1, layers do
			createRandomAlongArc(Asteroid, 20*stripe/layer, self.x, self.y, stripe_dist, rotation-90/layer, rotation+90/layer, width*layer/2)
		end
	end
	self.rings_amount = rings_amount
	self.station_distance_rad = (irandom(1,math.max(rings_amount-2, 1)) +0.5) * rings_distance / self.radius
	self:labelZone()
	return self
end

function TerrainModuleAsteroids:canInsertStation()
	-- between rings, preferably not between the outer two
	if self.rings_amount == nil then
		self.rings_amount = math.max(1,math.floor(self.radius / 5000))
	end
	return self.rings_amount >= 2
end

function TerrainModuleAsteroids:canInsertArtifact()
	return true
end

function TerrainModuleAsteroids:insertArtifact(callback)
	local artifact_name = _("High value asteroid")
	local artifact_info = _("This asteroid contains rare materials an should be captured.")
	local dist = self.radius / (self.rings_amount + 1)
	local x,y = radialPosition(self.x, self.y, dist, self.rotation+90)
	local art = wh_artifacts:placeDetailedArtifact(x,y, artifact_name, artifact_info, callback)
	if TEST == false then
		art:setRadarTraceColor(255, 200, 100)	-- camoflage
	end
	art:setCallSign("")
end

function TerrainModuleAsteroids:canInsertEnemies()
	if self.rings_amount == nil then
		self.rings_amount = math.max(1,math.floor(self.radius / 5000))
	end
	return self.rings_amount ~= 2 and not self.skip_enemies
end

function TerrainModuleAsteroids:getEnemySpawnPositions()
	-- if no station: enemies at the center
	if not self:canInsertStation() then
		return {{self.x,self.y}}
	end
	-- just inside outermost ring
	local dist = (self.rings_amount-0.5) * self.radius / (self.rings_amount + 1)
	return self:calculateSpawnPositionsOnRing(dist)
end

function TerrainModuleNebulae:create()
	-- places nebulae in an interesting way
	-- since nebulae do not collide, we can place them also in the outermost area.
	self:check()
	self.nebulae = {}
	if self.radius < 5000 then
		table.insert(self.nebulae, Nebula():setPosition(self.x,self.y))
		return self
	end
	local arc = self.rotation
	for dist = 5000, self.radius, 3000 do
		arc = arc + random(120,180)
		local x,y = radialPosition(self.x, self.y, dist, arc)
		table.insert(self.nebulae, Nebula():setPosition(x,y))
	end
	self.station_distance_rad = random(0.25, 0.75)
	self:labelZone()
	return self
end

function TerrainModuleNebulae:canInsertEnemies()
	return not self.skip_enemies
end

function TerrainModuleNebulae:getEnemySpawnPositions()
	local positions = {}
	for _, nebula in ipairs(self.nebulae) do
		local x,y = nebula:getPosition()
		table.insert(positions, {x,y})
	end
	return positions
end

function TerrainModuleMines:create()
	-- places Mines in a nice manner
	self:check()
	self.mines = {}
	local rotation = self.rotation
	local dist_between_rings = self.radius / 4
	local dist_between_mines_squared = 1500*1500
	for dist_from_origin = dist_between_rings, self.radius-dist_between_rings, dist_between_rings do
		rotation = rotation + random(120,240)
		local arc_dist = math.deg(math.acos(1-dist_between_mines_squared/(2*dist_from_origin*dist_from_origin)))
		for arc = rotation, rotation+random(60,270), arc_dist do
			local x,y = radialPosition(self.x, self.y, dist_from_origin, arc)
			table.insert(self.mines, Mine():setPosition(x,y))
		end
	end
	self.station_distance_rad = 0
	self:labelZone()
	return self
end

function TerrainModuleMines:canInsertStation()
	return self.radius >= 5000
end

function TerrainModuleMines:canInsertArtifact()
	return self.radius < 5000
end

function TerrainModuleMines:canInsertEnemies()
	return self.radius/4 >= 3000 and not self.skip_enemies
end

function TerrainModuleMines:insertArtifact()
	-- if no station is placed
	wh_artifacts:placeGenericArtifact(self.x,self.y)
end

function TerrainModuleMines:getEnemySpawnPositions()
	return self:calculateSpawnPositionsOnRing(self.radius*5/8)
end

function TerrainModulePlanets:createPlanet(isMoon)
	local planet = Planet()
	if isMoon then
		-- solid, not earth like
		planet:setPlanetSurfaceTexture(string.format("planets/planet-%d.png", irandom(2,5)))
	elseif  random(0,1) > 0.5 then
		-- gas
		planet:setPlanetSurfaceTexture(string.format("planets/gas-%d.png", irandom(1,3)))
	else
		-- solid
		planet:setPlanetSurfaceTexture(string.format("planets/planet-%d.png", irandom(1,5)))
		if random(0,1) > 0.5 then
			planet:setPlanetCloudTexture(string.format("planets/clouds-%d.png", irandom(1,3)))
		end
	end
	if random(0,1) > 0.5 then
		planet:setPlanetAtmosphereTexture("planets/atmosphere.png")
	end
	planet:setPlanetAtmosphereColor(random(0,1),random(0,1),random(0,1))
	planet:setAxialRotationTime(random(180, 2*360))
	return planet
end
function TerrainModulePlanets:create()
	-- places Planets in a nice manner
	self:check()
	self.moons = {}
	local moons = irandom(0, math.floor(self.radius/8000))
	local z = self.radius/(6*(moons+1)) * random(-1, 1)
	self.planet = self:createPlanet(false):setPosition(self.x, self.y):setPlanetRadius(self.radius/4):setDistanceFromMovementPlane(z)
	gravity_util.addGravitySource(self.planet, self.radius)
	for i = 1, moons do
		local moon_radius = self.radius/(3*(moons+1))
		local moon_dist_min = self.radius/4
		local moon_dist_max = self.radius*3/4 - moon_radius
		local moon_dist = i * moon_dist_max / moons
		local moon_arc = self.rotation+(i*360/moons)
		local x,y = radialPosition(self.x, self.y, moon_dist_min+moon_dist, moon_arc)
		moon_radius = random(moon_radius/2, moon_radius)
		local moon = self:createPlanet(true):setPosition(x,y):setPlanetRadius(moon_radius):setDistanceFromMovementPlane(z)
		local orbit_time = 360
		if moons == 2 then
			moon:setOrbit(self.planet, orbit_time)	-- 1 deg per s for both moons
		else
			orbit_time = random(i*360, 2*i*360)
			moon:setOrbit(self.planet, orbit_time)
		end
		moon.orbit_time = orbit_time
		moon.arc = moon_arc
		table.insert(self.moons, moon)
	end
	self:labelZone()
	return self
end
function TerrainModulePlanets:canInsertStation()
	return self.radius >= 4000
end
function TerrainModulePlanets:canInsertArtifact()
	return true
end
function TerrainModulePlanets:insertStation(station)
	TerrainModule.insertStation(self, station)
	self:insertOrbitingObject(station)
end
function TerrainModulePlanets:insertArtifact()
	local art = wh_artifacts:placeGenericArtifact(0,0)	-- TODO: more specific description
	self:insertOrbitingObject(art)
end
function TerrainModulePlanets:insertOrbitingObject(obj)
	if #self.moons > 0 then
		local linked_moon = self.moons[#self.moons]
		local dist
		-- r(planet) = r(zone)/4
		-- r(moon) = r(zone)/(3*(#moons+1))
		-- r := r(zone)
		if #self.moons <= 2 then
			-- r(planet) + centerOf( r(zone) - r(planet) - 2r(moon))
			dist = self.radius/4 + 0.5 * (3/4 * self.radius - 2*self.radius/(3 * (#self.moons+1)))
		elseif #self.moons % 2 == 1 then
			-- r(planet) + centerOf( r(zone) - r(planet) - r(moon))
			dist = self.radius/4 + 0.5 * (3/4 * self.radius - self.radius/(3 * (#self.moons+1)))
		else
			-- innermost_orbit + centerOf( innermost_orbit, outermost_orbit)
			-- orbit(i) = r(planet) + i/moons * ( r(zone) - r(planet) - r(moon))
			local orbit_dist = (3/4 * self.radius - self.radius/ (3 * (#self.moons+1)))
			-- self.radius/4 + orbit_dist/#self.moons + (orbit_dist - orbit_dist / #self.moons) /2
			dist = self.radius/4 + orbit_dist * (1/#self.moons + (1 - 1 / #self.moons) /2)
		end							   
		local x,y = radialPosition(self.x, self.y, dist, linked_moon.arc)
		obj:setPosition(x,y)
		wh_rota:add_object(obj, 360/linked_moon.orbit_time, self.x, self.y)
	else
		wh_rota:add_object(obj, 0.5, self.x, self.y)
	end
end

function TerrainModulePlanets:getEnemySpawnPositions()
	-- just inside outermost moon
	local dist = self.radius
	if #self.moons > 0 then
		local moon_radius = self.radius/(3*(#self.moons+1))
		dist = self.radius - 2*moon_radius - 1000
	end
	return self:calculateSpawnPositionsOnRing(dist)
end

function TerrainModuleBlackHoles:create()
	-- places BlackHoles in a nice manner
	self:check()
	self.holes = {}
	self.artifacts = {}
	local holes = 1
	if self.radius >= 10000 then
		holes = irandom(1, math.floor(self.radius/10000))
	end
	if holes > 1 then
		for i = 1, holes do
			local x,y = radialPosition(self.x, self.y, self.radius/3, self.rotation+(i*360/holes))
			local bh = BlackHole():setRadius(self.radius/4):setPosition(x, y)
			table.insert(self.holes, bh)
			wh_rota:add_object(bh, -0.5, self.x, self.y)
			gravity_util.addGravitySource(bh, self.radius*2/3)					
		end
	else
		local bh = BlackHole():setRadius(self.radius/2):setPosition(self.x, self.y)
		table.insert(self.holes, bh)
		gravity_util.addGravitySource(bh, self.radius)
	end
	self:labelZone()
	return self
end

function TerrainModuleBlackHoles:canInsertStation()
	return self.radius >= 5000
end

function TerrainModuleBlackHoles:canInsertArtifact()
	return true
end

function TerrainModuleBlackHoles:insertArtifact(callback)
	-- callback can be nil for no effect
	local x,y,speed
	local artifact_name = _("Black hole stabilizer")
	local artifact_info = _("This Arlenian device was used to prevent the wormhole from collapsing.")
	if #self.holes == 1 then
		x,y = radialPosition(self.x,self.y, 2*self.radius/5, self.rotation)
		speed = 2
		local art = wh_artifacts:placeDetailedArtifact(x,y, artifact_name, artifact_info, callback)
		wh_rota:add_object(art, speed, self.x, self.y)
		art.terrain_module = self
		art.hole = self.holes[1]
		table.insert(self.artifacts, art)
	else
		for idx,bh in ipairs(self.holes) do
			speed = bh.speed -- the artifact circles the bh once each bh year
			x,y = bh:getPosition()
			local rotation = self.rotation -- for 1 or 2 holes, so they are opposite
			-- for 3 holes:
			if #self.holes%2 == 1 then
				rotation = rotation + idx*180/#self.holes
			end
			x,y = radialPosition(x,y, self.radius/5, rotation)--+idx*360/#self.holes)
			local art = wh_artifacts:placeDetailedArtifact(x,y, artifact_name, artifact_info, callback)
			wh_rota:add_object(art, speed, bh)
			art.hole = bh 
			art.terrain_module = self
			table.insert(self.artifacts, art)
		end
	end
end

function TerrainModuleBlackHoles:getEnemySpawnPositions()
	-- on the outside of the radius, since station is at 0.75
	return self:calculateSpawnPositionsOnRing(self.radius)
end

function TerrainModuleWormHoles:create()
	-- places WormHole in a nice manner
	self:check()
	local mirror_x = self.parent_x or 0
	local mirror_y = self.parent_y or 0
	assert(type(mirror_x) == "number")
	assert(type(mirror_y) == "number")
	local amount = 1
	if self.radius >= 10000 then
		amount = irandom(1, math.floor(self.radius/10000))
	end
	self.wormholes = {}
	for i = 1, amount do
		local x,y = radialPosition(self.x, self.y, self.radius/3, self.rotation+(i*360/amount))
		-- calculate wormhole target position
		local direction = angleRotation(mirror_x, mirror_y, x, y) + i * (360/(amount+1))
		local dist = distance(mirror_x, mirror_y, x, y)
		local target_x, target_y = radialPosition(mirror_x, mirror_y, dist, direction)
		local wh = WormHole():setPosition(x, y):setTargetPosition(target_x, target_y)
		table.insert(self.wormholes, wh) 
		table.insert(self.all_wormholes, wh) -- TODO test if this works
	end
	self.station_distance_rad = 0
	self:labelZone()
	return self
end

function TerrainModuleWormHoles:canInsertStation()
	return self.radius >= 10000
end

function TerrainModuleWormHoles:getEnemySpawnPositions()
	-- from outside to near the holes
	local current = self.rotation
	local positions = {}
	local limit = 2*self.radius/3 - 3000
	for i = 1, 50 do
		current = current + 360/i
		local x,y = radialPosition(self.x, self.y, self.radius-i*limit/50, current)
		table.insert(positions, {x,y})
	end
	return positions
end

function TerrainModuleWormHoles:canInsertEnemies()
	return 2*self.radius/3 > 3000 and not self.skip_enemies
end

function TerrainModuleMetaSpiral:create()
	-- places terrain in a nice spiral 
	self:check()
	self.children = {}
	local start_angle = self.start_angle or 0
	local end_angle = self.end_angle or 3*360
	local amount = self.amount or 47
	local scale = self.radius / end_angle
	-- module classes get shuffled and then distributed to the positions
	-- some modules appear more than once here, to appear more often
	local modules = {
		TerrainModuleAsteroids,
		TerrainModuleAsteroids,
		TerrainModuleNebulae,
		TerrainModuleMines,
		TerrainModulePlanets,
		TerrainModuleWormHoles,
		TerrainModuleBlackHoles,
		TerrainModuleNebulae,
	}
	-- start with the last one in the center (hole), shuffle after
	local module_idx = #modules -2
	-- set up a spiral
	for phi = start_angle,end_angle-1,(end_angle-start_angle)/amount do
		local direction, dist = spiral_position(self.rotation, scale, phi)
		if module_idx > #modules then
			arrayShuffle(modules)
			module_idx = 1
		end
		local module = modules[module_idx]
		module_idx = module_idx +1
		module = module:new{direction=direction, distance=dist, x=self.x, y=self.y, parent_x=self.x, parent_y=self.y}
		module:calculatePosition()
		table.insert(self.children, module)
	end
	for idx = 2, #self.children do
		local this = self.children[idx]
		local prev = self.children[idx-1]
		this.radius = distance(this.x, this.y, prev.x, prev.y) / 2
	end
	self.children[1].radius = self.children[2].radius	-- the center is a bit off

	if self.onChildrenCheckCallbacks == nil then
		self.onChildrenCheckCallbacks = {}
	end
	if self.onChildrenCreationCallbacks == nil then
		self.onChildrenCreationCallbacks = {}
	end
	local counter = {}
	local encounter_counter = {}
	for _,module in ipairs(self.children) do
		if MetaTerrain ~= nil then
			MetaTerrain():setPosition(module.x,module.y):setRadius(module.radius)
		end
		module:check()
		for _,callback in ipairs(self.onChildrenCheckCallbacks) do
			callback(module)
		end
		if counter[module.terrain_type] == nil then
			counter[module.terrain_type] = 1
		else
			counter[module.terrain_type] = counter[module.terrain_type] +1
		end
		if encounter_counter[module.encounter] == nil then
			encounter_counter[module.encounter] = 1
		else
			encounter_counter[module.encounter] = encounter_counter[module.encounter] +1
		end
		if TEST then
			module:create()
			for _,callback in ipairs(self.onChildrenCreationCallbacks) do
				callback(module)
			end
		else
			for _,callback in ipairs(self.onChildrenCreationCallbacks) do
				module:registerOnCreationCallback(callback)
			end
			module:createWhenVisible()
		end
	end
	for i=2, #self.children-1 do
		local last = self.children[i-1]
		local recent = self.children[i]
		local nex = self.children[i+1]
		assert(last.gossip)
		assert(nex.gossip, nex.encounter)
		recent.collected_gossip = {last.gossip, nex.gossip}
	end
	for terrain_type, counter in pairs(counter) do
		log(string.format("created %i %s", counter, terrain_type))
	end
	local ecc = 1
	for encounter, counter in pairs(encounter_counter) do
		log(string.format("created %i %s", counter, encounter))
		ecc = ecc+1
	end
	log(string.format("created %i different encounters (should be 17)", ecc))
	return self
end

function TerrainModuleMeta:registerOnChildrenCreationCallback(callback)
	if self.children ~= nil then
		for _,module in pairs(self.children) do
			module:registerOnCreationCallback(callback)
		end
	end

	if self.onChildrenCreationCallbacks == nil then
		self.onChildrenCreationCallbacks = {}
	end
	table.insert(self.onChildrenCreationCallbacks, callback)
end

function TerrainModuleMeta:registerOnChildrenCheckCallback(callback)
	if self.children ~= nil then
		for _,module in pairs(self.children) do
			log("  XXX")
			module:registerOnCheckCallback(callback)
		end
	end

	if self.onChildrenCheckCallbacks == nil then
		self.onChildrenCheckCallbacks = {}
	end
	table.insert(self.onChildrenCheckCallbacks, callback)
end


function avp_terrain_modules:createAsteroids(args)
	return TerrainModuleAsteroids:new(args):create()
end

function avp_terrain_modules:createNebulae(args)
	return TerrainModuleNebulae(args):create()
end

function avp_terrain_modules:createMines(args)
	return TerrainModuleMines:new(args):create()
end

function avp_terrain_modules:createPlanets(args)
	return TerrainModulePlanets:new(args):create()
end

function avp_terrain_modules:createBlackHole(args)
	return TerrainModuleBlackHoles:new(args):create()
end

function avp_terrain_modules:createWormhole(args)
	return TerrainModuleWormHoles:new(args):create()
end

function avp_terrain_modules:createMetaSpiral(args)
	return TerrainModuleMetaSpiral:new(args):create()
end
