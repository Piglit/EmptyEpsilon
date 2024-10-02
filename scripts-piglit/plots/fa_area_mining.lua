fa_area_mining = {}

function fa_area_mining:init(center_x, center_y)
	self.center_x = center_x
	self.center_y = center_y

	local scale = 1

	-- The main Planet
	self.planet_radius = 12300*scale
    self.planet = Planet():setPosition(center_x, center_y):setPlanetRadius(self.planet_radius):setPlanetSurfaceTexture("planets/planet-4-hd.png"):setPlanetCloudTexture("planets/clouds-2-hd.png"):setPlanetAtmosphereTexture("planets/atmosphere.png"):setPlanetAtmosphereColor(0.0,0.5,0.5)
	--:setDescriptions(_("Endor"),_("Forest Moon of Endor")):setCallSign(_("Endor")):setFaction("Environment")

	-- Moons
	self.moon_1 = Planet():setPlanetRadius(2200*scale)
	setCirclePos(self.moon_1, center_x, center_y, 10, self.planet_radius*3)
	self.moon_2 = Planet():setPlanetRadius(2200*scale)
	setCirclePos(self.moon_2, center_x, center_y, 190, self.planet_radius*3)
	self.moon_3 = Planet():setPlanetRadius(3500*scale)
	setCirclePos(self.moon_3, center_x, center_y, -80, self.planet_radius*3.5)
	self.moon_4 = Planet():setPlanetRadius(2900*scale)
	setCirclePos(self.moon_4, center_x, center_y, 220, self.planet_radius*5)

	-- Asteroids
	local asteroid_offset = -2500*scale
	local asteroids_1, r, phi = spiral(center_x+asteroid_offset, center_y, scale*300, 2000, -40, -360-45, 0, false)
	local x,y = vectorFromAngle(phi, r*2)
	local asteroids_2, _, _ = spiral(center_x+x+asteroid_offset, center_y+y, scale*300, 1000, -30, -360-45, 180, false)
	BlackHole():setPosition(center_x+x,center_y+y+asteroid_offset)
	return self
end

function spiral(x, y, scale, amount, start_angle, end_angle, rotation, hyperbol)
	local formula = function(a,phi) return a*phi end
	if hyperbol then
		formula = function(a,phi) return a/phi end
	end
	local r, _phi
	local objs = {}
	for phi = start_angle,end_angle,(end_angle-start_angle)/amount do
		r = formula(scale, phi)
		local obj = Asteroid():setSize(150*random(0.5,1.5)*random(0.5,1.5))
		setCirclePos(obj, x, y, phi+rotation, r*random(0.9,1.1)*random(0.9,1.1))
		table.insert(objs, obj)
		_phi = phi+rotation
	end
	return objs, r, _phi
end

function factorial(n)
	if (n == 0) then
		return 1
	else
		return n * factorial(n-1)
	end
end

function clothoide()
	-- uses A = 1 and taylor
	-- L: length
	L = 10000
	PI = 2.5--3--.1415
	amount = 200
	for t = -PI/2,PI/2,PI/amount do
		x=0
		y=0
		for i = 0,32 do
			x = x + ( (-1)^i * t^(4*i+1) ) / ( factorial(2*i) * (4*i+1) )
			y = y + ( (-1)^i * t^(4*i+3) ) / ( factorial(2*i+1) * (4*i+3) )
		end
--		x = L * (1 - T^2 / (factorial(2)*5) + T^4 / (factorial(4)*9) - T^6 / (factorial(6)*13))
--		y = L * (T/3 - T^3 / (factorial(3)*7) + T^5 / (factorial(5)*11) - T^7 / (factorial(7)*15))
		Asteroid():setPosition(x*L*random(0.8,1.2),y*L*random(0.8,1.2))
	end
end
