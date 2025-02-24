map_ambush = {
	center_x = 0,
	center_y = 0,
	scale = 1,
}

function map_ambush:init()
	createRandomAlongArc(Nebula, 5, self.center_x, self.center_y, 5000, 0, 40, 2500)
	createRandomAlongArc(Asteroid, 100, self.center_x, self.center_y, 5000, 60, 340, 1000)
end
