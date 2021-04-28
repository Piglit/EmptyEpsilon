--[[ Wormhole Expedition Terrain
-- Creates a black hole surrounded by nebulae
-- The nebulae slowly orbit the black hole
-- other POIs are created, sometimes containing artifacts
-- Depends on: artifacts, rota
--]]

wh_terrain = {}

require "utils.lua"
require "plots/wh_util_rota.lua"

function wh_terrain:init()
	local center_x, center_y = 100000,0

	-- create rotating system center
	self.blackhole = BlackHole():setPosition(center_x, center_y)

	-- create POIs
	local common_scattered_objects = 0
	local common_obj_type_sizes = {
		{typ = "WarpJammer",	siz = 5000},
		{typ = "mineblob",		siz = 4000},
		{typ = "asteroidblob",	siz = 3500},
		{typ = "Mine",			siz = 2000},
		{typ = "Asteroid",		siz = 1000},
	}
	repeat
		local dist = random(6000,50000)
		-- avoid wormhole path
		if dist < 25000 or dist > 35000 then
			if dist > 35000 then
				dist = dist + random(0,50000) + random(0,50000)
			end
			local ox, oy = vectorFromAngle(random(0,360), dist)
			ox = ox + center_x
			oy = oy + center_y
			local obj_list = getObjectsInRadius(ox, oy, 5000)
			local closest_distance = 5000
			local closest_obj = nil
			for i,obj in ipairs(obj_list) do
				local obj_dist = distance(obj,ox,oy)
				if obj_dist < closest_distance then
					closest_distance = obj_dist
					closest_obj = obj
				end
			end
			local type_list = {}
			for i,type_size in ipairs(common_obj_type_sizes) do
				if type_size.siz < closest_distance then
					table.insert(type_list,type_size.typ)
				end
			end
			if #type_list > 0 then
				local insert_type = type_list[math.random(1,#type_list)]
				if insert_type == "WarpJammer" then
					closest_distance = math.min(closest_distance * .95,20000)
					WarpJammer():setPosition(ox,oy):setRange(closest_distance)
				elseif insert_type == "mineblob" then
					closest_distance = math.min(closest_distance,15000)
					self:placeMinefieldBlob(ox,oy,closest_distance*.37)
				elseif insert_type == "asteroidblob" then
					closest_distance = math.min(closest_distance,15000)
					self:placeAsteroidBlob(ox,oy,closest_distance*.37)
				elseif insert_type == "Mine" then
					Mine():setPosition(ox,oy)
				elseif insert_type == "Asteroid" then
					Asteroid():setPosition(ox,oy):setSize(random(20,950))
				end
			end
			common_scattered_objects = common_scattered_objects + 1
		end
	until(common_scattered_objects > 100)

	-- rotating Nebulae
	self.nebulae = placeRandomAroundPoint(Nebula,50,10000,100000,center_x,center_y)
	for _,o in ipairs(self.nebulae) do
		wh_rota:add_object(o, random(400, 2000), self.blackhole)
		o.speed = o.speed / o.distance
	end

	print("Terrain: "..wh_artifacts.artifacts_total.." Artifacts placed")
	getScriptStorage().wh_terrain = self
end

function wh_terrain:placeAsteroidBlob(x,y,field_radius)
	local asteroid_list = {}
	-- central point is an artefact
	local a = wh_artifacts:placeGenericArtifact(x,y)
	a.getSize = function(self)	-- face asteroid for getSize() call later
		return random(10,400) + random(10,400)
	end
	table.insert(asteroid_list,a)
	local visual_angle = random(0,360)
	local vx, vy = vectorFromAngle(visual_angle,random(0,field_radius))
	local va = VisualAsteroid():setPosition(x + vx, y + vy)
	va:setSize(random(10,300) + random(5,300))
	visual_angle = visual_angle + random(120,240)
	vx, vy = vectorFromAngle(visual_angle,random(0,field_radius))
	va = VisualAsteroid():setPosition(x + vx, y + vy)
	va:setSize(random(10,300) + random(5,300))
	local reached_the_edge = false
	repeat
		local overlay = false
		local nax = nil
		local nay = nil
		local size = nil
		repeat
			overlay = false
			local base_asteroid_index = math.random(1,#asteroid_list)
			local base_asteroid = asteroid_list[base_asteroid_index]
			local bax, bay = base_asteroid:getPosition()
			local angle = random(0,360)
			size = random(10,400) + random(10,400)
			local asteroid_space = (base_asteroid:getSize() + size)*random(1.05,1.25)
			nax, nay = vectorFromAngle(angle,asteroid_space)
			nax = nax + bax
			nay = nay + bay
			for i,asteroid in ipairs(asteroid_list) do
				if i ~= base_asteroid_index then
					local cax, cay = asteroid:getPosition()
					local asteroid_distance = distance(cax,cay,nax,nay)
					if asteroid_distance < asteroid_space then
						overlay = true
						break
					end
				end
			end
		until(not overlay)
		a = Asteroid():setPosition(nax,nay)
		a:setSize(size)
		table.insert(asteroid_list,a)
		visual_angle = random(0,360)
		vx, vy = vectorFromAngle(visual_angle,random(0,field_radius))
		va = VisualAsteroid():setPosition(nax + vx,nay + vy)
		va:setSize(random(10,300) + random(5,300))
		visual_angle = visual_angle + random(120,240)
		vx, vy = vectorFromAngle(visual_angle,random(0,field_radius))
		va = VisualAsteroid():setPosition(nax + vx, nay + vy)
		va:setSize(random(10,300) + random(5,300))
		if distance(x,y,nax,nay) > field_radius then
			reached_the_edge = true
		end
	until(reached_the_edge)
	return asteroid_list
end
function wh_terrain:placeMinefieldBlob(x,y,mine_blob_radius)
	local mine_list = {}
	-- central point is an artefact
	table.insert(mine_list,wh_artifacts:placeGenericArtifact(x,y))
	local reached_the_edge = false
	local mine_space = 1400
	repeat
		local overlay = false
		local nmx = nil
		local nmy = nil
		repeat
			overlay = false
			local base_mine_index = math.random(1,#mine_list)
			local base_mine = mine_list[base_mine_index]
			local bmx, bmy = base_mine:getPosition()
			local angle = random(0,360)
			nmx, nmy = vectorFromAngle(angle,mine_space)
			nmx = nmx + bmx
			nmy = nmy + bmy
			for i, mine in ipairs(mine_list) do
				if i ~= base_mine_index then
					local cmx, cmy = mine:getPosition()
					local mine_distance = distance(cmx, cmy, nmx, nmy)
					if mine_distance < mine_space then
						overlay = true
						break
					end
				end
			end
		until(not overlay)
		table.insert(mine_list,Mine():setPosition(nmx,nmy))
		if distance(x, y, nmx, nmy) > mine_blob_radius then
			reached_the_edge = true
		end
	until(reached_the_edge)
	return mine_list
end

-- nebulae movement is in wh_rota
