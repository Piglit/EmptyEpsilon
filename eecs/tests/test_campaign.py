from models.campaign import *
import models.scenario
import models.crew

def test_campaign():
	models.crew.removeCrew("testi-campaign")
	camp = Campaign(["scenario_00_basic.lua"])
	assert models.scenario.getScenario("basic")
	camp.setReputationFactor("basic", 0.5)
	assert models.scenario.getScenario("basic").getReputationFactor() == 0.5
	camp.setDefaultCrewTemplate(["00_basic"], ["Phobos M3P"], "Hi!")
	c = models.crew.getOrCreateCrew("testi-campaign", "Testcrew")
	assert c.getBriefing() == "Hi!"
	models.scenario.clearScenarios()

def test_scenario_event():
	models.crew.removeCrew("testi-campaign")
	camp = Campaign(["scenario_00_basic.lua"])
	s = models.scenario.getScenario("basic")
	c = models.crew.getOrCreateCrew("testi-campaign", "Testcrew")
	details = {
		"progress": 50,
	}
	camp._progress(s, c, details)
	assert(c.getScoreRaw("current")["reputation"] == 50)
	camp.setReputationFactor("basic", 0.5)
	camp._score(s, c, details)
	assert(c.getScoreRaw("current")["reputation"] == 25)
	camp._started(s, c)
	assert(c.getBriefing() == "" )
	camp._artifact(s, c, {"name": "Testifact", "description": ""})
	def sse(scenario, crew, event_topic, details, progress):
		print(progress)
#	camp.addScenarioSpecificEvent("00_basic", sse)
#	camp.scenario_event(s, c, "progress", details)
