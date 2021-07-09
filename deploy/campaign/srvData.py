"""load and store server specific data"""
import os
import json
import pyrohelper
import Pyro4

@Pyro4.expose
class GameServerData:
	db = "serverDB.json"

	def __init__(self):
		self.servers = {}
		if os.path.exists(GameServerData.db):
			self.loadData()

	def ping(self):
		return True

	def getOrCreateServer(self, serverName):
		if serverName not in self.servers:
			self.servers[serverName] = {
				"scenarios": ["20_training1"],
				"scenarioVariations": {},
				"ships": ["Phobos M3P"]
			}
		return self.servers[serverName]
	
	def getScenarios(self, serverName):
		srv = self.getOrCreateServer(serverName)
		return srv["scenarios"]

	def getScenarioVariations(self, scenarioName, serverName):
		srv = self.getOrCreateServer(serverName)
		if scenarioName not in srv["scenarios"]:
			raise RuntimeError("try to get Variations but scenario is not unlocked: "+scenarioName)
		if scenarioName in srv["scenarioVariations"]:
			return srv["scenarioVariations"][scenarioName]
		else:
			return [None]

	def getShips(self, serverName):
		srv = self.getOrCreateServer(serverName)
		return srv["ships"]

	def storeData(self):
		db = GameServerData.db
		with open(db, "w") as file:
			json.dump(self.servers, file, indent=2)
	
	def loadData(self):
		db = GameServerData.db
		assert os.path.exists(db)
		with open(db, "r") as file:
			self.servers = json.load(file)

	def clearData(self):
		self.servers = {}

	def unlockScenario(self, scenarioName, serverName, variation=None):
		srv = self.getOrCreateServer(serverName)
		if variation:
			if isinstance(variation, list):
				for var in variation:
					self.unlockScenario(scenarioName, serverName, var)
				return
			assert isinstance(variation, str) or isinstance(variation, None)
			if scenarioName not in srv["scenarioVariations"]:
				if scenarioName in srv["scenarios"]:
					# scenario was already unlocked without variation
					srv["scenarioVariations"][scenarioName] = [None]
				else:
					srv["scenarioVariations"][scenarioName] = []
			if variation not in srv["scenarioVariations"][scenarioName]:
				srv["scenarioVariations"][scenarioName].append(variation)
			if "*" in srv["scenarioVariations"][scenarioName]:
				srv["scenarioVariations"][scenarioName] = ["*"]
		if scenarioName not in srv["scenarios"]:
			srv["scenarios"].append(scenarioName)
		self.storeData()

	def unlockScenarios(self, scenarios, serverName):
		assert isinstance(scenarios, list)
		for scenario in scenarios:
			if isinstance(scenario, str):
				self.unlockScenario(scenario, serverName)
			elif isinstance(scenario, tuple):
				self.unlockScenario(scenario[0], serverName, variation=scenario[1])
			else:
				raise TypeError(scenario + " is not of type str ot tuple")

	def unlockShip(self, shipName, serverName):
		srv = self.getOrCreateServer(serverName)
		if shipName not in srv["ships"]:
			srv["ships"].append(shipName)
		self.storeData()

	def unlockShips(self, shipNames, serverName):
		assert isinstance(shipNames, list)
		for sn in shipNames:
			self.unlockShip(sn, serverName)

servers = GameServerData()
pyrohelper.host_named_server(servers, "campaign_state")
