"""This represents a crew's campaign progress"""

import core
import models.scenario
from models.scenario import Scenario

class Crew:
	def __init__(self, instance_name, crew_name, template):
		self.instance_name = instance_name
		self.crew_name = crew_name if crew_name else "" 
		self.status = "unknown"
		self.scenarios = []
		self.setScenarios(template["scenarios"].copy())
		self.scenario_settings = {}
		self.ships = template["ships"].copy()
		self.setBriefing(template["briefing"])
		self.scores = {}
		self.code = ""
	
	def setCrewName(self, name):
		self.crew_name = name

	def getStatus(self) -> str:
		return self.status

	def setStatus(self, status):
		self.status = status

	def getScenarios(self) -> list[Scenario]:
		return self.scenarios

	def setScenarios(self, scenarios):
		assert isinstance(scenarios, list)
		for s in scenarios:
			if isinstance(s, str):
				s = models.scenario.getScenario(s)
			assert isinstance(s, Scenario)
			self.scenarios.append(s)

	def unlockScenario(self, s, settings=None):
		if isinstance(s, str):
			s = models.scenario.getScenario(s)
		assert isinstance(s, Scenario)
		if settings:
			assert isinstance(settings, dict)
			if scenarioName not in self.scenario_settings:
				self.scenario_settings[s.filename] = {}
			for setting, options in settings.items():
				assert isinstance(options, list)
				if setting not in self.scenario_settings[s.filename]:
					self.scenario_settings[s.filename][setting] = []
				self.scenario_settings[s.filename][setting] = list(set(self.scenario_settings[s.filename][setting] + options))	# unique
						
		if s not in self.scenarios:
			self.scenarios.append(s)

	def lockScenario(self, s):
		if isinstance(s, str):
			s = models.scenario.getScenario(s)
		assert isinstance(s, Scenario)
		if s in self.scenarios:
			self.scenarios.remove(s)
		if s.filename in self.scenario_settings:
			del self.scenario_settings[s.filename]

	def unlockScenarios(self, scenarios):
		assert isinstance(scenarios, list)
		for s in scenarios:
			if isinstance(s, str) or isinstance(s, Scenario):
				self.unlockScenario(s)
			elif isinstance(s, tuple):
				settings = s[1]
				self.unlockScenario(s[0], settings=settings)
			else:
				raise TypeError(s+ " is not of type str ot tuple or Scenario")

	def getScenarioSettings(self, scenario_name):
		return self.scenario_settings.get(scenario_name)

	def getShips(self):
		return self.ships

	def hasShip(self, ship):
		return ship in self.ships

	def setShips(self, ships):
		assert isinstance(ships, list)
		for s in ships:
			assert isinstance(s, str)
		self.ships = ships

	def unlockShip(self, shipName):
		if shipName not in self.ships:
			self.ships.append(shipName)

	def lockShip(self, shipName):
		if shipName in self.ships:
			self.ships.remove(shipName)

	def unlockShips(self, shipNames):
		assert isinstance(shipNames, list)
		for sn in shipNames:
			self.unlockShip(sn)

	def getBriefing(self):
		return {key: text.format(crew_name=self.crew_name) for key, text in self.briefing.items()}

	def setBriefing(self, text):
		if not text:
			self.briefing = {}
		elif isinstance(text, str):
			self.briefing = {"Instructions": text}
		elif isinstance(text, dict):
			self.briefing = text
		else:
			raise TypeError(f"text has wrong type: {type(text)}")

	def getScenarioScore(self, s):
		if isinstance(s, str):
			s = models.scenario.getScenario(s)
		assert isinstance(s, Scenario)
		return self.scores.get(s.filename, {})

	def getRecentScore(self):
		return None

	def updateScore(self, s, newScore: dict):
		"""sets the score for the scenario s to the best values so far."""
		if isinstance(s, str):
			s = models.scenario.getScenario(s)
		assert isinstance(s, Scenario)
		score = self.scores.get(s.filename, {})
		for key, new in newScore:
			if not isinstance(new, int) and not isinstance(new, bool):
				continue
			val = score.get(key)
			if val:
				if key in ["time"]:
					val = min(new, val)
				else:	# progress, bonus
					val = max(new, val)
			score[key] = val
		self.scores[s.filename] = score
		#s.updateScore(score)	# update fleet highscore

	def __str__(self):
		return self.crew_name

crews = {}
template = {
		"scenarios": [],
		"ships": [],
		"briefing": ""
}

def setCrewTemplate(scenarios, ships, briefing):
	"""applies scenarios, ships and briefing to each new created crew"""
	template["scenarios"] = scenarios
	template["ships"] = ships 
	template["briefing"] = briefing 

def setCrewStatus(crew, status, **kwargs):
	crew.setStatus(status)

def getCrew(instance_name):
	return crews.get(instance_name)

def getOrCreateCrew(instance_name, crew_name):
	if instance_name not in crews:
		crews[instance_name] = Crew(instance_name, crew_name, template)
	elif crew_name:
		crews[instance_name].setCrewName(crew_name)
	return crews[instance_name]

def removeCrew(instance_name):
	if instance_name in crews:
		del crews[instance_name]


core.subscribe("activity", setCrewStatus)
