map_ice_planet = {
	center_x = -100000,
	center_y = 0,
	scale = 1,
	planet = nil,	-- created in init
	station_high = nil,	-- created in init
}

function map_ice_planet:init()
	self.planet_radius = 32300*self.scale
    self.planet = Planet():setPosition(self.center_x, self.center_y):setPlanetRadius(self.planet_radius):setPlanetSurfaceTexture("planets/ice5.jpg"):setPlanetAtmosphereColor(0.0,0.4,0.4):setPlanetAtmosphereTexture("planets/atmosphere.png"):setDistanceFromMovementPlane(-20000)
	--:setPlanetCloudTexture("planets/clouds-1.png")
	--self.planet:setDescriptions(_("Ilum"),_("The ice planet Ilum")):setCallSign(_("Ilum")):setFaction("Environment")
	self.planet:setDescriptions(_("Gall"),_("The planet Gall")):setCallSign(_("Gall")):setFaction("Environment"):setAxialRotationTime(480)

	-- Nebulae
	for i=1,3 do
		for a=1,360,8+2*i do
			setCirclePos(Nebula(),self.center_x, self.center_y, random(a,a+2), self.planet_radius -5000 + random(i*5000, i*10000))
		end
	end

	-- needs gravity_util
	gravity_util.gravity_const = gravity_util.gravity_const * 0.75
	gravity_util.addGravitySource(map_ice_planet.planet, 99000)

	local x,y = self.center_x + 120000, self.center_y - 5000
	self.station_high = SpaceStation():setTemplate("Small Station"):setCallSign("EAHOD"):setDescription("Erebus Array High Orbit Dock"):setFaction("Imperial"):setCanBeDestroyed(false):setPosition(x, y):setRotation(180)
	x,y = self.center_x + 50000, self.center_y - 15000
	self.station_medium = SpaceStation():setTemplate("Small Station"):setCallSign("EAMOD"):setDescription("Erebus Array Mid Orbit Dock"):setFaction("Imperial"):setCanBeDestroyed(false):setPosition(x, y):setRotation(150)
	x,y = self.center_x + 0, self.center_y - self.planet_radius + 4000
	self.station_low = SpaceStation():setTemplate("Medium Station"):setCallSign("EALOD"):setDescription("Erebus Array Low Orbit Dock"):setFaction("Imperial"):setCanBeDestroyed(false):setPosition(x, y):setRotation(-90)
end
