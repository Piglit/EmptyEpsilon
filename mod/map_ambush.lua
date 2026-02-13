map_ambush = {
	center_x = 20000,
	center_y = -5000,
	scale = 1,
}

function map_ambush:init()
--	createRandomAlongArc(Nebula, 5, self.center_x, self.center_y, 15000, 20, 140, 2500)
	local radius = 20000
	local arc = 20 --self.rotation
	for dist = 5000, radius, 3000 do
		arc = arc + 140--random(120,180)
		local x,y = radialPosition(self.center_x, self.center_y+radius, dist, arc)
		Nebula():setPosition(x,y)
	end
--	createRandomAlongArc(Asteroid, 100, self.center_x, self.center_y, 20000, 200, 340, 1000)

	local radius = 10000
	local rings_amount = 2 --math.max(1,math.floor(radius / 5000))
	local rings_distance = radius / (rings_amount + 1)
	local rotation = -60 -- self.rotation
	for stripe = 1, rings_amount do
		local stripe_dist = stripe * rings_distance
		local layers = 3
		local width = rings_distance/layers
		rotation = rotation + 60--random(0, 180)
		for layer = 1, layers do
			createRandomAlongArc(Asteroid, 10*stripe/layer, self.center_x, self.center_y, stripe_dist, rotation-90/layer, rotation+90/layer, width*layer/2)
		end
	end
end
