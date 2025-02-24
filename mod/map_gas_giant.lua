map_gas_giant = {
	center_x = 0,
	center_y = 0,
	scale = 1,
}

function map_gas_giant:init()
	self.planet_radius = 52300*self.scale
    self.planet = Planet():setPosition(self.center_x, self.center_y):setPlanetRadius(self.planet_radius):setPlanetSurfaceTexture("planets/gas-6.png"):setPlanetAtmosphereColor(0.5,0.5,0.5):setPlanetAtmosphereTexture("planets/atmosphere.png"):setDistanceFromMovementPlane(-20000):setAxialRotationTime(240)
	--:setPlanetCloudTexture("planets/clouds-1.png")
	self.planet:setDescriptions(_("Montross"),_("The gas planet Montross")):setCallSign(_("Montross")):setFaction("Environment")

	-- Nebulae
	for i=1,3 do
		for a=1,360,8+2*i do
			setCirclePos(Nebula(),self.center_x, self.center_y, random(a,a+2), self.planet_radius -2500 + random(i*5000, i*10000))
		end
	end
end
