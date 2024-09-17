"""This represents a crew's campaign progress
Crews are identified by their instance name.
Objects of the crew class are stored in a file on change or read from file on first access.

"""

import core
import models.scenario
from interfaces import storage
from models.scenario import Scenario
from outbound import luaExecutor
from utils import lua

import os
from datetime import timedelta
from pprint import pprint
import json

import logging
import coloredlogs

log = logging.getLogger(__name__)

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
		self.artifacts = {}
		self.code = ""

	def setCrewName(self, name):
		self.crew_name = name
		self.storeCrew()

	def getStatus(self) -> str:
		return self.status

	def setStatus(self, status):
		self.status = status
		self.storeCrew()

	def getScenarios(self) -> list[str]:
		return self.scenarios

	def setScenarios(self, scenarios):
		assert isinstance(scenarios, list)
		self.scenarios.clear()
		for s in scenarios:
			if isinstance(s, str):
				s = models.scenario.getScenario(s)
			assert isinstance(s, Scenario)
			self.scenarios.append(s.filename)
		self.storeCrew()

	def unlockScenario(self, s, settings=None):
		if isinstance(s, str):
			s = models.scenario.getScenario(s)
		assert isinstance(s, Scenario)
		if settings:
			assert isinstance(settings, dict)
			if s.filename not in self.scenario_settings:
				self.scenario_settings[s.filename] = {}
			for setting, options in settings.items():
				assert isinstance(options, list)
				if setting not in self.scenario_settings[s.filename]:
					self.scenario_settings[s.filename][setting] = []
				self.scenario_settings[s.filename][setting] = list(set(self.scenario_settings[s.filename][setting] + options))	# unique
						
		if s.filename not in self.scenarios:
			self.scenarios.append(s.filename)
		self.storeCrew()

	def lockScenario(self, s):
		if isinstance(s, str):
			s = models.scenario.getScenario(s)
		assert isinstance(s, Scenario)
		if s.filename in self.scenarios:
			self.scenarios.remove(s.filename)
		if s.filename in self.scenario_settings:
			del self.scenario_settings[s.filename]
		self.storeCrew()

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
		self.storeCrew()

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
		self.storeCrew()

	def unlockShip(self, shipName):
		if shipName not in self.ships:
			self.ships.append(shipName)

	def lockShip(self, shipName):
		if shipName in self.ships:
			self.ships.remove(shipName)
		self.storeCrew()

	def unlockShips(self, shipNames):
		assert isinstance(shipNames, list)
		for sn in shipNames:
			self.unlockShip(sn)

	def getBriefing(self):
		return self.briefing.format(crew_name=self.crew_name, ships=", ".join(self.ships))

	def getBriefingRaw(self):
		return self.briefing

	def setBriefing(self, text):
		assert isinstance(text, str)
		self.briefing = text
		self.storeCrew()

	def getScoreRaw(self, key):
		return self.scores.get(key, {})

	def getScenarioScore(self, s):
		if isinstance(s, str):
			s = models.scenario.getScenario(s)
		assert isinstance(s, Scenario)
		return self.getScoreRaw(s.filename)

	def getRecentScore(self):
		current = self.scores.get("current")
		if not current:
			return dict()
		ret = {
			"current_scenario_name": "",
			"artifacts": json.dumps(self.artifacts),
		}
		scenario = current["scenario"]
		ss = self.scores[scenario]
		hi = Crew.getFleetHighscore(scenario)
		ret["current_scenario_name"] = current["scenario_name"]
		if "time" in current:
			ret["current_time"] = str(timedelta(seconds=-current["time"]))
			ret["best_time"] = str(timedelta(seconds=-ss["time"]))
			ret["fleet_time"] = str(timedelta(seconds=-hi["time"][0]))
			ret["fleet_time_name"] = "" if len(hi["time"][1]) != 1 else " (" + str(list(hi["time"][1])[0]) + ")"
		if "progress" in current:
			ret["current_progress"] = str(int(current["progress"]))+"%"
			ret["best_progress"] = str(int(ss["progress"]))+"%"
			ret["fleet_progress"] = str(int(hi["progress"][0]))+"%"
			ret["fleet_progress_name"] = "" if len(hi["progress"][1]) != 1 else " (" + str(list(hi["progress"][1])[0]) + ")"
		if "artifacts" in current:
			ret["current_artifacts"] = str(int(current["artifacts"]))
			ret["best_artifacts"] = str(int(ss["artifacts"]))
			ret["fleet_artifacts"] = str(int(hi["artifacts"][0]))
			ret["fleet_artifacts_name"] = "" if len(hi["artifacts"][1]) != 1 else " (" + str(list(hi["artifacts"][1])[0]) + ")"
		if "difficulty" in current:
			ret["current_difficulty"] = str(int(current["difficulty"]))
		if "reputation" in current:
			ret["reputation"] = str(int(ss["reputation"]))
		return ret

	def getFleetHighscore(scenario):
		best = {
			"time": (-60*60*60, set()),
			"progress": (0, set()),
			"artifacts": (0, set()),
		}
		for n,crew in crews.items():
			score = crew.getScenarioScore(scenario)
			for key in best:
				if key in score and score[key] is not None:
					if score[key] > best[key][0]:
						best[key] = (score[key], {crew.crew_name})
					elif score[key] == best[key][0]:
						best[key] = (score[key], best[key][1] | {crew.crew_name})
		return best

	def updateScore(self, s, newScore: dict):
		"""sets the score for the scenario s to the best values so far."""
		if isinstance(s, str):
			s = models.scenario.getScenario(s)
		assert isinstance(s, Scenario)
		assert isinstance(newScore, dict)
		if "time" in newScore:
			newScore["time"] = -newScore["time"]	# sort by max value
		score = self.scores.get(s.filename, {})
		currentScore = self.scores.get("current", {})
		currentScore["scenario"] = s.filename
		currentScore["scenario_name"] = s.name
		for key, new in newScore.items():
			if not isinstance(new, int) and not isinstance(new, bool) and not isinstance(new, float):
				continue
			new = int(new)
			# update current score
			currentScore[key] = new
			# update max score
			val = score.get(key)
			if val is not None:
				new = max(new, val)
			score[key] = new 
		self.scores[s.filename] = score
		self.scores["current"] = currentScore
		self.storeCrew()

	def clearCurrentScore(self):
		self.scores["current"] = {}	# clear current score on scenario start

	def getTotalReputationBonus(self, apply_reductions):
		amount = 0
		for k,ss in self.scores.items():
			if k == "current":
				continue
			if k == "delivered" and not apply_reductions:
				continue
			if "reputation" in ss:
				amount += int(ss["reputation"])
		return amount

	def addArtifact(self, artifact_name, artifact_description):
		self.artifacts[artifact_name] = artifact_description

	def hasArtifact(self, artifact_name):
		return artifact_name in self.artifacts

	def rmArtifact(self, artifact_name):
		del self.artifacts[artifact_name]

	def sendArtifacts(self, server=None):
		"""send artifacts to server, granting them to the current ship"""
		if not server:
			_server = self.instance_name
		else:
			_server = server
		amount = len(self.artifacts)
		if amount <= 0:
			return
		log.info(f"{self.crew_name} requested artifacts to {_server}")
		script_artifacts = ""
		for name,descr in self.artifacts.items():
			name = lua.sanitize_lua_string(name)
			descr = lua.sanitize_lua_string(descr)
			script_artifacts += f"""
			_OBJECT_:setResourceAmount("{name}", 1)
			_OBJECT_:setResourceDescription("{name}", "{descr}")
			_OBJECT_:setResourceCategory("{name}", "Campaign Artifacts")"""
		script = f"""
			local id=getPlayerShipIndex("{self.crew_name}")-- this is a security issue
	        _OBJECT_=getPlayerShip(id)
			_OBJECT_:addToShipLog("You carry {amount} artifact{"s" if amount > 1 else ""} from previous missions to deliver to the fleet command station.", "green")"""
		script += script_artifacts
		luaExecutor.exec(script, _server+":8080", 0, Crew._artifactCallback, [self])

	def _artifactCallback(self, success):
		if success:
			self.artifacts.clear()

	def sendReputation(self, server=None, reduce=False):
		"""send reputation bonus to server, granting it the current ship"""
		if not server:
			_server = self.instance_name
		else:
			_server = server
		amount = self.getTotalReputationBonus(reduce)
		log.info(f"{self.crew_name} requested {amount} reputation bonus to {_server}")
		if amount <= 0:
			return
		script = f"""
			local id=getPlayerShipIndex("{self.crew_name}")-- this is a security issue
	        _OBJECT_=getPlayerShip(id)
			_OBJECT_:addReputationPoints({amount})
			_OBJECT_:addToShipLog("Reputation: +{amount} from previous missions", "green")
		"""
		luaExecutor.exec(script, _server + ":8080", 1, Crew._repCallback, [self, reduce])

	def _repCallback(self, reduce, success):
		if success and reduce:
			amount = self.getTotalReputationBonus(True)
			if "delivered" not in self.scores:
				self.scores["delivered"] = {"reputation": 0}
			self.scores["delivered"]["reputation"] -= amount
			log.info(f"{self.crew_name} {amount} reputation has been delivered.")


	def storeCrew(self):
		storage.storeInfo(self, self.instance_name, subdir="crews")
	
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

def getCrewByCallsign(crew_name):
	for crew in crews.values():
		if crew.crew_name == crew_name:
			return crew

def getOrCreateCrew(instance_name, crew_name):
	if instance_name not in crews and not loadCrew(instance_name):
		crews[instance_name] = Crew(instance_name, crew_name, template)
	elif crew_name:
		crews[instance_name].setCrewName(crew_name)
	return crews[instance_name]

def removeCrew(instance_name):
	if instance_name in crews:
		del crews[instance_name]

def loadCrew(instance_name):
	loaded = storage.loadInfo(instance_name, subdir="crews")
	if loaded is not None:
		crews[instance_name] = loaded
		return True
	else:
		return False

core.subscribe("activity", setCrewStatus)
