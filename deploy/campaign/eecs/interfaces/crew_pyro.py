import Pyro4
from models import crew

@Pyro4.expose
class Crews:
	def __init__(self):
		self.crew_servers = {}

	def ping(self):
		return True

	def get(self, instance):
		return crew.crews[instance].__dict__

	def list(self):
		ret = {}
		for instance, obj in crew.crews.items():
			ret[instance] = obj.__dict__
		return ret

	# setter
	def setCrewName(self, instance, name):
		crew.crews[instance].setCrewName(name)
	def setStatus(self, instance, status):
		crew.crews[instance].setStatus(status)
	def setScenarios(self, instance, scenarios):
		crew.crews[instance].setScenarios(scenarios)
	def unlockScenario(self, instance, s, settings=None):
		crew.crews[instance].unlockScenario(s, settings=settings)
	def lockScenario(self, instance, s):
		crew.crews[instance].lockScenario(s)
	def setShips(self, instance, ships):
		crew.crews[instance].setShips(ships)
	def unlockShip(self, instance, shipName):
		crew.crews[instance].unlockShip(shipName)
	def lockShip(self, instance, shipName):
		crew.crews[instance].lockShip(shipName)
	def setBriefing(self, instance, text):
		crew.crews[instance].setBriefing(text)


		
