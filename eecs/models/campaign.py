"""This represents a campaign.
All logic that links scenarios and crews happens here.
The campaign state is persistent - it gets written on each change and reloaded on restart.
"""

import core
import models.crew
import models.scenario
import outbound.stationsComms
import outbound.pyroMessage
from interfaces import storage
import json
import string

class Campaign:
	def __init__(self, scenarios:list):
		models.scenario.loadScenarios(scenarios)

	def setReputationFactor(self, scenario, factor):
		models.scenario.getScenario(scenario).setReputationFactor(factor)

	def setDefaultCrewTemplate(self, scenarios, ships, briefing):
		models.crew.setCrewTemplate(scenarios, ships, briefing)

	def scenario_event(self, scenario: models.scenario.Scenario, crew: models.crew.Crew, event_topic: str, details=str|dict):

		if event_topic == "started":
			self._started(scenario, crew)

		elif event_topic == "artifact":
			self._artifact(scenario, crew, json.loads(details))

		elif event_topic == "score":
			# called by initScore, victoryScore and artifact collection, details come as json
			return self._score(scenario, crew, json.loads(details))

		elif event_topic == "progress":
			# called by sendProgressToCampaignServer
			return self._progress(scenario, crew, details)

		elif event_topic == "request_reputation":
			self._request_reputation
		elif event_topic == "request_artifacts":
			self._request_artifacts

	def _score(self, scenario, crew, details):
		if "difficulty" not in details:
			details["difficulty"] = crew.getScoreRaw("current").get("difficulty",1)	# current can be empty
		if "progress" in details:
			details["reputation"] = details["progress"] * scenario.getReputationFactor() * details["difficulty"]
		crew.updateScore(scenario.scriptId, details)
		return details.get("progress")

	def _progress(self, scenario, crew, details):
		assert isinstance(details, dict)
		difficulty = crew.getScoreRaw("current").get("difficulty",1)	# current can be empty
		progress = details["progress"]
		crew.updateScore(scenario.scriptId, {
			"progress": progress,
			"reputation": progress * scenario.getReputationFactor() * difficulty,
			"difficulty": difficulty,
		})
		return progress

	def _started(self, scenario, crew):
		crew.setBriefing("")
		crew.clearCurrentScore()

	def _artifact(self, scenario, crew, artifact):
		crew.addArtifact(artifact["name"], artifact["description"])

	def _request_reputation(self, scenario, crew, target_crew):
		if target_crew:
			models.crew.getCrewByCallsign(target_crew).sendReputation(server="localhost", reduce=True)	# XXX server is hacky
		else:
			crew.sendReputation()

	def _request_artifacts(self, scenario, crew, target_crew):
		assert isinstance(target_crew, str)
		models.crew.getCrewByCallsign(target_crew).sendArtifacts(server="localhost") # XXX server is hacky
