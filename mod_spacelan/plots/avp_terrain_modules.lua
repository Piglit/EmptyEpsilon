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
--require "plots/wh_rota.lua"

avp_terrain_modules = {
	modules = {},
	hidden_modules = {},
	zone_names = nil,
}

local TerrainModule = {}
local MAX_ASTEROID_SIZE = 130	-- source asteroid size :110-130

function TerrainModule:new(obj)
	obj = obj or {} -- create empty if none given 
	setmetatable(obj, self)
	self.__index = self
	table.insert(avp_terrain_modules.modules, obj)
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
	return self					   
end

function TerrainModule:labelZone()
	-- not every zone gets a label
	-- the label is set on discovery in create()
--	if avp_terrain_modules.zone_names == nil then
--		avp_terrain_modules.zone_names = arrayShuffle({
--			"Strahlen des Ponies",
--			"Fliege des Hundes",
--			"Kupferner Hängeleuchter",
--			"Schnurrhaare des Dachses",
--			"Helm der Königs",
--			"Führung des Tentakels",
--			"Leere der Unerfahrenheit",
--		})
--	end
--	if #avp_terrain_modules.zone_names > 0 then
--		local label = table.remove(avp_terrain_modules.zone_names)
--		self.zone:setLabel(label)
--		self.zone_label = label
--	end
	if self.radius < 5000 then
		-- too small to read
		return self
	end
	if #self.zone_names == 0 then
		self.zone_names = TerrainModule.zone_names
	end
	if #self.zone_names > 0 then
		-- pop one element
		self.zone:setLabel(table.remove(self.zone_names))
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

function TerrainModule:insertStation(station)
	-- default implementation
	-- places a station inside the module
	if self.stations == nil then
		self.stations = {}
	end
	table.insert(self.stations, station)
	self:insertObject(station, 0.75)
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
	end
	if orientation ~= "nil" then
		arc = arc + random(-45, 45)
	end
	local x,y = radialPosition(self.x, self.y, self.radius*dist, arc)
	obj:setPosition(x,y)
end

function avp_terrain_modules:updatePlayerShip(delta, ship)
	-- if a hidden module comes into view, create it and call onCreation callbacks
	for idx, module in ipairs(self.hidden_modules) do
		if distance(ship, module.x, module.y) <= ship:getLongRangeRadarRange() + module.radius + 5000 then
			module:create()

			table.remove(self.hidden_modules, idx)
			if module.onCreationCallbacks ~= nil then
				for _,cb in ipairs(module.onCreationCallbacks) do
					cb(module)
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
TerrainModuleWormHoles = TerrainModule:new{terrain_type="wormholes"}
TerrainModuleMeta = TerrainModule:new{terrain_type="meta"}
TerrainModuleMetaSpiral = TerrainModuleMeta:new{}

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
	"Helm der Königs",
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
	"Padmes Verwüstung",
	"Sicherer Raum",
})

TerrainModuleBlackHoles.zone_names = arrayShuffle({
	"Offenbarung der Zwillinge",
})

TerrainModuleNebulae.zone_names = arrayShuffle({
	"Phileas Fogg",
})

function TerrainModuleAsteroids:create()
	-- places asteroids in a nice manner
	self:check()
	local outermost_position = self.radius - MAX_ASTEROID_SIZE
	local rings_amount = math.max(1,math.floor(outermost_position / 5000))
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
	self:labelZone()
	return self
end

function TerrainModuleNebulae:create()
	-- places nebulae in an interesting way
	self:check()
	-- since nebulae do not collide, we can place them also in the outermost area.
	if self.radius < 5000 then
		Nebula():setPosition(self.x,self.y)
		return self
	end
	local arc = self.rotation
	for dist = 5000, self.radius, 3000 do
		arc = arc + random(120,180)
		local x,y = radialPosition(self.x, self.y, dist, arc)
		Nebula():setPosition(x,y)
	end
	if self.radius > 15000 then
		self:labelZone()
	end
	return self
end

function TerrainModuleMines:create()
	-- places Mines in a nice manner
	self:check()
	local rotation = self.rotation
	local dict_between_rings = self.radius / 4
	local dist_between_mines_squared = 1500*1500
	for dist_from_origin = dict_between_rings, self.radius-dict_between_rings, dict_between_rings do
		rotation = rotation + random(120,240)
		local arc_dist = math.deg(math.acos(1-dist_between_mines_squared/(2*dist_from_origin*dist_from_origin)))
		for arc = rotation, rotation+random(60,270), arc_dist do
			local x,y = radialPosition(self.x, self.y, dist_from_origin, arc)
			Mine():setPosition(x,y)
		end
	end
	return self
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
	local moons = irandom(0, math.floor(self.radius/8000))
	local z = self.radius/(6*(moons+1))-- * random(-1, 1)
	self.planet = self:createPlanet(false):setPosition(self.x, self.y):setPlanetRadius(self.radius/4):setDistanceFromMovementPlane(z)
	gravity_util.addGravitySource(self.planet, self.radius)
	for i = 1, moons do
		local moon_radius = self.radius/(3*(moons+1))
		local moon_dist_min = self.radius/4
		local moon_dist_max = self.radius*3/4 - moon_radius
		local moon_dist = i * moon_dist_max / moons
		local x,y = radialPosition(self.x, self.y, moon_dist_min+moon_dist, self.rotation+(i*360/moons))
		moon_radius = random(moon_radius/2, moon_radius)
		local moon = self:createPlanet(true):setPosition(x,y):setPlanetRadius(moon_radius):setDistanceFromMovementPlane(z)
		if moons == 2 then
			moon:setOrbit(self.planet, 360)	-- 1 deg per s for both moons
		else
			moon:setOrbit(self.planet, random(i*360, 2*i*360))
		end
	end
	self:labelZone()
	return self
end

function TerrainModuleBlackHoles:create()
	-- places BlackHoles in a nice manner
	self:check()
	local holes = 1
	if self.radius >= 10000 then
		holes = irandom(1, math.floor(self.radius/10000))
	end
	if holes > 1 then
		self:labelZone()
		for i = 1, holes do
			local x,y = radialPosition(self.x, self.y, self.radius/3, self.rotation+(i*360/holes))
			local bh = BlackHole():setRadius(self.radius/4):setPosition(x, y)
			wh_rota:add_object(bh, -0.5, self.x, self.y)
			gravity_util.addGravitySource(bh, self.radius*2/3)					
		end
	else
		local bh = BlackHole():setRadius(self.radius/2):setPosition(self.x, self.y)
		gravity_util.addGravitySource(bh, self.radius)
	end
	return self
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
	for i = 1, amount do
		local x,y = radialPosition(self.x, self.y, self.radius/3, self.rotation+(i*360/amount))
		-- calculate wormhole target position
		local direction = angleRotation(mirror_x, mirror_y, x, y) + i * (360/(amount+1))
		local dist = distance(mirror_x, mirror_y, x, y)
		local target_x, target_y = radialPosition(mirror_x, mirror_y, dist, direction)
		WormHole():setPosition(x, y):setTargetPosition(target_x, target_y)
	end
	return self
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
		TerrainModuleNebulae,
		TerrainModuleMines,
		TerrainModulePlanets,
		TerrainModuleBlackHoles,
		TerrainModuleWormHoles,
	}
	-- start with the last one in the center (hole), shuffle after
	local module_idx = #modules
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
	for _,module in ipairs(self.children) do
		if MetaTerrain ~= nil then
			MetaTerrain():setPosition(module.x,module.y):setRadius(module.radius)
		end
		module:check()

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
