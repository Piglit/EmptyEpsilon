"""Test the eehttp interface"""

from fastapi.testclient import TestClient
from interfaces.eehttp import app, ScenarioEvents
tc = TestClient(app)

import outbound.log	# subscribes the logger to core.activity
import models.crew
import models.scenario
from models.scenarioevents import ScenarioEvents

def test_root():
	r = tc.get("/")
	assert r.status_code == 200

def test_debug():
	r = tc.post("/debug", json={"test": "test"})
	assert r.status_code == 200

def test_scenario():
	models.scenario.loadScenarios(["scenario_00_basic.lua"])
	for event in ScenarioEvents:
		r = tc.post(f"/scenario/{event.value}", json={"scenario": {"filename": "scenario_00_basic.lua", "name": "test"}, "server": {"instance_name": "testpc", "crew_name": "Testi"}})
		assert r.status_code == 200
	models.scenario.clearScenarios()

def test_screen():
	r = tc.post(f"/screen", json={"screen": "testscreen", "server": {"instance_name": "testpc", "crew_name": "Testi"}})
	assert r.status_code == 200

def test_getBriefing():
	r = tc.get(f"/briefing/testpc")
	assert r.status_code == 200
	assert r.json() == {"briefing": {}}

	r = tc.get(f"/briefing/nopc")
	assert r.status_code == 404

def test_getScenarios():
	models.scenario.loadScenarios(["scenario_10_empty.lua"])
	r = tc.get(f"/scenarios/testpc")
	assert r.status_code == 200
	assert r.json() == {"scenarios": []}
	models.crew.getCrew("testpc").unlockScenario("10_empty")
	r = tc.get(f"/scenarios/testpc")
	assert r.status_code == 200
	assert r.json() == {"scenarios": ["scenario_10_empty.lua"]}
	models.scenario.clearScenarios()

def test_scriptProgress():
	r = tc.post(f"/script/progress", json={"scenario": {"filename": "scenario_00_basic.lua", "name": "test"}, "server": {"instance_name": "testpc", "crew_name": "Testi"}, "data": {"progress": 1/3}})
	assert r.status_code == 200

def test_scriptMessage():
	r = tc.post(f"/script/message", json={"scenario": {"filename": "scenario_00_basic.lua", "name": "test"}, "server": {"instance_name": "testpc", "crew_name": "Testi"}, "data": {"topic": "test", "details": "blubb"}})
	assert r.status_code == 200

def test_getCampaign():
	#models.scenario.loadScenarios(["scenario_10_empty.lua"])
	models.crew.setCrewTemplate(["empty"], ["Phobos M3P"], "Hi!")
	r = tc.get(f"/campaign/camptest/testi")
	assert r.status_code == 200
	assert r.json() == {"scenarios": ["scenario_10_empty.lua"],
#						"ships": ["Phobos M3P"],
						"briefing": "Hi!"}
	models.scenario.clearScenarios()

