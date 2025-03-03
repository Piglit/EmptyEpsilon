fa_area_mining = {
	center_x = 0,
	center_y = 0,
	scale = 1,
	droids_inactive = {},
}

function fa_area_mining:init()
	-- those variables can and should be modified before init is called.
	local center_x = self.center_x
	local center_y = self.center_y
	local scale = self.scale

	-- The main Planet
	self.planet_radius = 12300*scale
    self.planet = Planet():setPosition(center_x, center_y):setPlanetRadius(self.planet_radius):setPlanetSurfaceTexture("planets/planet-lava.png"):setPlanetAtmosphereColor(0.5,0.1,0.1):setPlanetAtmosphereTexture("planets/black.png"):setRotation(180):setAxialRotationTime(1800)
	--:setPlanetCloudTexture("planets/clouds-1.png")
	self.planet:setDescriptions(_("Mustafar"),_("The volcanic planet Mustafar")):setCallSign(_("Mustafar")):setFaction("Environment")

	-- Moons
	--[[
	self.moon_1 = Planet():setPlanetRadius(2200*scale)
	setCirclePos(self.moon_1, center_x, center_y, 10, self.planet_radius*3)
	self.moon_2 = Planet():setPlanetRadius(2200*scale)
	setCirclePos(self.moon_2, center_x, center_y, 190, self.planet_radius*3)
	self.moon_3 = Planet():setPlanetRadius(3500*scale)
	setCirclePos(self.moon_3, center_x, center_y, -80, self.planet_radius*3.5)
	self.moon_4 = Planet():setPlanetRadius(2900*scale)
	setCirclePos(self.moon_4, center_x, center_y, 220, self.planet_radius*5)
	--]]

	-- Asteroids
	local asteroid_offset = -2500*scale
	local start = -10
	local step = -30
	for i=1,6 do
		self:create_asteroid_spiral(center_x+asteroid_offset, center_y, scale*300, 50+150/i, start+i*step, start+(i+1)*step, 0)
	end
--	local asteroids_1, r, phi = create_asteroid_spiral(center_x+asteroid_offset, center_y, scale*300, 1000, -40, -180, 0)
--	local x,y = vectorFromAngle(phi, r*2)
--	local asteroids_2, _, _ = create_asteroid_spiral(center_x+asteroid_offset, center_y, scale*300, 200, -180, -270, 0)
--	local asteroids_1, r, phi = create_asteroid_spiral(center_x+asteroid_offset, center_y, scale*300, 2000, -40, -360-45, 0)
--	local x,y = vectorFromAngle(phi, r*2)
--	local asteroids_2, _, _ = create_asteroid_spiral(center_x+x+asteroid_offset, center_y+y, scale*300, 1000, -30, -360-45, 180)
--	BlackHole():setPosition(center_x+x,center_y+y+asteroid_offset)
	return self
end

function fa_area_mining:createDebris()
	local center_x = self.center_x
	local center_y = self.center_y
	local scale = self.scale
	local offset = -2500*scale
	local start = -10
	local step = -30
	for i=2,5 do
		self:create_debris_spiral(center_x+offset, center_y, scale*300, 8, start+i*step, start+(i+1)*step, 0)
		self:create_droid_spiral(center_x+offset, center_y, scale*300, 2, start+i*step, start+(i+1)*step, 0)
	end
end

function spiral_position(rotation, scale, phi)
	-- returns angle and distance. Can be used in setCirclePos(obj, x, y, angle, distance)
	return phi+rotation, scale*phi 
end

function fa_area_mining:create_asteroid_spiral(x, y, scale, amount, start_angle, end_angle, rotation)
	local r, angle
	local objs = {}
	for phi = start_angle,end_angle,(end_angle-start_angle)/amount do
		angle, r = spiral_position(rotation, scale, phi)
		local obj = Asteroid():setSize(150*random(0.5,1.5)*random(0.5,1.5))
		setCirclePos(obj, x, y, angle, r*random(0.9,1.1)*random(0.9,1.1))
		table.insert(objs, obj)
	end
	return objs, r, angle
end

function fa_area_mining:create_debris_spiral(x, y, scale, amount, start_angle, end_angle, rotation)
	for phi = start_angle,end_angle+1,(end_angle-start_angle)/amount do
		local angle, r = spiral_position(rotation, scale, phi)
		local obj = CpuShip():setTemplate("Debris"):orderIdle():setFaction("Environment")
		setCirclePos(obj, x, y, angle, r*random(1.0,1.1))
	end
end
function fa_area_mining:create_droid_spiral(x, y, scale, amount, start_angle, end_angle, rotation)
	local objs = {}
	for phi = start_angle,end_angle+1,(end_angle-start_angle)/amount do
		local angle, r = spiral_position(rotation, scale, phi)
		local obj = CpuShip():setTemplate("Viper Droid"):orderIdle():setFaction("Target")
		table.insert(self.droids_inactive, obj)
		setCirclePos(obj, x, y, angle, r*random(1.05,1.1))
	end
	return objs
end

function fa_area_mining:activateDroids(player)
	for idx, droid in ipairs(self.droids_inactive) do
		if droid:isValid() and distance(droid, player) < 1500 then
			droid:orderStandGround()
			table.remove(self.droids_inactive, idx)
			return
		end
	end
end

function fa_area_mining:updatePlayerShip(delta, player)
	self:activateDroids(player)
end
