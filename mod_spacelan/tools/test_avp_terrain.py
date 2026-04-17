import lupa
import pytest
import os
import random
import math
import matplotlib.pyplot as plt

lua = lupa.LuaRuntime()
BASEPATH = os.path.dirname(__file__) + "/../"
def lua_require(filename):
	"""loads and executes the code of the given lua file"""
	filename = BASEPATH + filename
	print("REQUIRE",filename)
	try: 
		with open(filename, "r") as file:
			code = file.read()
			lua.execute(code)
	except Exception as e:
		raise
		print(e)

def lua_random(*args):
	if len(args) == 0:
		return random.random()
	elif len(args) == 1:
		return random.randint(1, int(args[0]))
	elif len(args) == 2:
		return random.randint(int(args[0]), int(args[1]))

def lua_unpack(*args):
	# can not mock this, it just won't work
	return

def lua_atan2(*args):
	return math.atan2(*args)
	
lua.require("math")

lua.execute("params = {...} require = params[1] random=params[2] irandom=params[2] table.unpack=params[3] math.atan2=params[4]", lua_require, lua_random, lua_unpack, lua_atan2)
g = lua.globals()

@pytest.fixture(scope="session")
def avp_terrain_modules():
	lua_require("plots/avp_terrain_modules.lua")

class SpaceObjects:
	fig, ax = plt.subplots()

	def __init__(self, radius, color): 
		self.radius = radius
		self.color = color
		self.clear()

	def clear(self):
		self.positions_x = []
		self.positions_y = []
		self.target_positions_x = []
		self.target_positions_y = []
		self.radii = []

	def isValid(self):
		# TODO test false for test coverage
		return True

	def setPosition(self, x, y):
		self.positions_x.append(x)
		self.positions_y.append(y)
		return self

	def getPosition(self):
		return self.positions_x[-1], self.positions_y[-1]

	def setTargetPosition(self, x, y):
		# only for wormholes
		self.target_positions_x.append(x)
		self.target_positions_y.append(y)
		return self

	def setRadius(self, radius):
		self.radii.append(radius)
		return self

	def setPlanetRadius(self, radius):
		# only for planets
		return self.setRadius(radius)

	def setPlanetSurfaceTexture(self, tex):
		return self

	def setPlanetCloudTexture(self, tex):
		return self

	def setPlanetAtmosphereTexture(self, tex):
		return self

	def setPlanetAtmosphereColor(self, *args):
		return self

	def setAxialRotationTime(self, time):
		return self

	def setOrbit(self, obj, orbit):
		return self

	def setDistanceFromMovementPlane(self, dist):
		return self

	def setPoints(self, points):
		# only for zones
		return self

	def setLabel(self, label):
		# only for zones
		self.label = label
		return self

	def plot(self, r):
		ax = SpaceObjects.ax
		ax.set_aspect("equal")
		ax.set_xlim((-r, r))
		ax.set_ylim((-r, r))
		ax.add_patch(plt.Circle((0,0),r, color="r", fill=False))

		for i in range(len(self.positions_x)):
			if self.radii:
				assert self.positions_x[i] is not None
				assert self.positions_y[i] is not None
				assert self.radii[i] is not None

				ax.add_patch(plt.Circle((self.positions_x[i],self.positions_y[i]),self.radii[i], color=self.color, fill=True))
			else:
				ax.add_patch(plt.Circle((self.positions_x[i],self.positions_y[i]),self.radius, color=self.color, fill=True))
			if self.target_positions_x:
				plt.plot((self.positions_x[i],self.target_positions_x[i]),(self.positions_y[i],self.target_positions_y[i]), color="black")
				
		#plt.savefig("plot.png")



asteroids = SpaceObjects(120, "brown")
def lua_Asteroid():
	return asteroids

nebulae = SpaceObjects(5000, "blue")
def lua_Nebulae():
	return nebulae
	
mines = SpaceObjects(1000, "red")
def lua_Mines():
	return mines 

planets = SpaceObjects(None, "green")
def lua_Planets():
	return planets 

blackholes = SpaceObjects(5000, "black")
def lua_Blackholes():
	return blackholes 

wormholes = SpaceObjects(5000, "purple")
def lua_Wormholes():
	return wormholes 

spacestations = SpaceObjects(500, "grey")
def lua_SpaceStations():
	return spacestations

zones = SpaceObjects(None, "")
def lua_Zones():
	return zones

meta = SpaceObjects(None, "yellow")
def lua_Meta():
	return meta 

lua.execute("params = {...} Asteroid = params[1] Nebula = params[2] Mine = params[3] Planet = params[4] BlackHole = params[5] WormHole = params[6] MetaTerrain=params[7] SpaceStation=params[8] Zone=params[9]", lua_Asteroid, lua_Nebulae, lua_Mines, lua_Planets, lua_Blackholes, lua_Wormholes, lua_Meta, lua_SpaceStations, lua_Zones)

def test_asteroids(avp_terrain_modules):
	modules_at_start = len(g.avp_terrain_modules.modules)	# subclasses are also listed as modules
	r = 31000
	lua.execute(f"""m = TerrainModuleAsteroids:new{{x=0,y=0,radius={r}}}:create()""")
	assert len(g.avp_terrain_modules.modules) == modules_at_start + 1
	assert len(spacestations.positions_x) == 0
	assert(g.m.zone.label)
	lua.execute("""m:insertStation(SpaceStation())""")
	assert len(spacestations.positions_x) == 1
	lua.execute(f"""m = TerrainModuleAsteroids:new{{x=30000,y=30000,radius={r}}}:create()""")
	#asteroids.plot(2*r)
	asteroids.clear()
	#plt.savefig("plot.png")

def test_nebula(avp_terrain_modules):
	modules_at_start = len(g.avp_terrain_modules.modules)	# subclasses are also listed as modules
	r = 31000
	lua.execute(f"""m = TerrainModuleNebulae:new{{x=0,y=0,radius={r}}}:create()""")
	assert len(g.avp_terrain_modules.modules) == modules_at_start + 1
	#nebulae.plot(r)
	nebulae.clear()

def test_mines(avp_terrain_modules):
	modules_at_start = len(g.avp_terrain_modules.modules)	# subclasses are also listed as modules
	r = 16000
	lua.execute(f"""m = TerrainModuleMines:new{{x=0,y=0,radius={r}}}:create()""")
	assert len(g.avp_terrain_modules.modules) == modules_at_start + 1
	#mines.plot(r)
	mines.clear()

def test_planets(avp_terrain_modules):
	modules_at_start = len(g.avp_terrain_modules.modules)	# subclasses are also listed as modules
	r = 41000
	lua.execute(f"""m = TerrainModulePlanets:new{{x=0,y=0,radius={r}}}:create()""")
	assert len(g.avp_terrain_modules.modules) == modules_at_start + 1
	#planets.plot(r)
	planets.clear()

def test_blackholes(avp_terrain_modules):
	modules_at_start = len(g.avp_terrain_modules.modules)	# subclasses are also listed as modules
	r = 60000
	lua.execute(f"""m = TerrainModuleBlackHoles:new{{x=0,y=0,radius={r}}}:create()""")
	assert len(g.avp_terrain_modules.modules) == modules_at_start + 1
	#blackholes.plot(r)
	blackholes.clear()

def test_wormholes(avp_terrain_modules):
	modules_at_start = len(g.avp_terrain_modules.modules)	# subclasses are also listed as modules
	r = 41000
	lua.execute(f"""m = TerrainModuleWormHoles:new{{x=0,y=0,radius={r}}}:create()""")
	assert len(g.avp_terrain_modules.modules) == modules_at_start + 1
	#wormholes.plot(r)
	wormholes.clear()

def test_meta(avp_terrain_modules):
	modules_at_start = len(g.avp_terrain_modules.modules)	# subclasses are also listed as modules
	r = 200000
	lua.execute(f"""TEST = true m = TerrainModuleMetaSpiral:new{{x=0,y=0,radius={r},rotation=0}}:create()""")
	#lua.execute(f"""m = TerrainModuleMetaSpiral:new{{x=2*{r},y=0,radius={r},rotation=180+3*360/47}}:create()""")
	assert len(g.avp_terrain_modules.modules) > modules_at_start
	#meta.plot(r)
	#print(meta.positions_x)
	#print(meta.positions_y)
	#print(meta.radii)
	#wormholes.plot(r)
	#blackholes.plot(r)
	#planets.plot(r)
	#nebulae.plot(r)
	#mines.plot(r)
	#asteroids.plot(r)
	#plt.savefig("plot.png")
