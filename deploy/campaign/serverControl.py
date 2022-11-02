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
				"scenarioSettings": {},
				"ships": ["Phobos M3P"],
				"status": "idle",
				"additionalCode": ""
			}
		return self.servers[serverName]
	
	def getScenarios(self, serverName):
		srv = self.getOrCreateServer(serverName)
		return srv["scenarios"]

	def getScenarioSettings(self, scenarioName, serverName):
		"""when a setting is undefined, it is fully available to the players.
			to enable all possible settings, set {} as setting or just leave undefined.
			each setting contains possible values. If empty [] or undefined,
			everything is available.
			When only one setting is avail, use ["value"].
			If the default entry is not available, the first entry will become default
		"""
		srv = self.getOrCreateServer(serverName)
		if scenarioName not in srv["scenarios"]:
			raise RuntimeError("try to get Settings but scenario is not unlocked: "+scenarioName)
		if scenarioName in srv["scenarioSettings"]:
			return srv["scenarioSettings"][scenarioName]
		else:
			return {} 

	def getShips(self, serverName):
		srv = self.getOrCreateServer(serverName)
		return srv["ships"]

	def setShips(self, ships, serverName):
		assert isinstance(ships, list)
		for s in ships:
			assert isinstance(s, str)
		srv = self.getOrCreateServer(serverName)
		srv["ships"] = ships

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

	def unlockScenario(self, scenarioName, serverName, settings=None):
		srv = self.getOrCreateServer(serverName)
		if settings:
			assert isinstance(settings, dict)
			if scenarioName not in srv["scenarioSettings"]:
				srv["scenarioSettings"][scenarioName] = {}
			for setting, options in settings.items():
				assert isinstance(options, list)
				if setting not in srv["scenarioSettings"][scenarioName]:
					srv["scenarioSettings"][scenarioName][setting] = []
				srv["scenarioSettings"][scenarioName][setting] = list(set(srv["scenarioSettings"][scenarioName][setting] + options))	# unique
						
		if scenarioName not in srv["scenarios"]:
			srv["scenarios"].append(scenarioName)
		self.storeData()

	def unlockScenarios(self, scenarios, serverName):
		assert isinstance(scenarios, list)
		for scenario in scenarios:
			if isinstance(scenario, str):
				self.unlockScenario(scenario, serverName)
			elif isinstance(scenario, tuple):
				settings = scenario[1]
				self.unlockScenario(scenario[0], serverName, settings=settings)
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
	
	def getStatus(self, serverName):
		srv = self.getOrCreateServer(serverName)
		return srv["status"]

	def getStatusAll(self):
		entries = {}
		for serverName in self.servers:
			status = self.servers[serverName].get("status")
			entries[serverName] = status
		return entries

	def setStatus(self, statusMessage, serverName):
		srv = self.getOrCreateServer(serverName)
		srv["status"] = statusMessage
		self.storeData()
	
	def getShipAdditionalCode(self, serverName):
		if serverName in self.servers:
			# no entry in servers for fighters
			srv = self.getOrCreateServer(serverName)
			return srv.get("additionalCode", "")
		else:
			return ""

	def setShipAdditionalCode(self, code, serverName):
		srv = self.getOrCreateServer(serverName)
		code = code.replace("\t", "")
		srv["additionalCode"] = code 
		self.storeData()

servers = GameServerData()
pyrohelper.host_named_server(servers, "campaign_state")
