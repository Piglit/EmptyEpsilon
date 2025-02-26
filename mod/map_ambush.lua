map_ambush = {
	center_x = 0,
	center_y = 0,
	scale = 1,
}

function map_ambush:init()
	createRandomAlongArc(Nebula, 5, self.center_x, self.center_y, 15000, 20, 140, 2500)
	createRandomAlongArc(Asteroid, 100, self.center_x, self.center_y, 20000, 200, 340, 1000)
end
