from models.crew import *
import core
import models.scenario

serverName = "testserver"
scenarioName = "00_test"
crewName = "Testship"

Crew.storeCrew = lambda self: 0 
Crew.loadCrew = lambda name: False

def test_removeCrew():
	crew = getOrCreateCrew(serverName, crewName)
	removeCrew(serverName)
	assert not crews

def test_setCrewName():
	assert not crews
	crew = getOrCreateCrew(serverName, crewName)
	core.activity(crew, "did nothing", "nothing")
	assert serverName in crews
	assert crews[serverName].crew_name == crewName
	assert crews[serverName].status == "did nothing" 
	assert getCrew(serverName)
	removeCrew(serverName)
	assert getCrew(serverName) == None

def test_template():
	models.scenario.loadScenarios(["scenario_20_training1.lua"])
	crew = getOrCreateCrew(serverName, crewName)
	assert template["scenarios"] == []
	assert template["ships"] == []
	assert template["briefing"] == ""
	core.activity(crew, "did nothing", "nothing")
	assert getCrew(serverName).getScenarios() == []
	assert getCrew(serverName).getShips() == []
	assert getCrew(serverName).getBriefing() == ""
	setCrewTemplate(["20_training1"], ["Phobos M3P"], "Hello Crew!")
	crew = getOrCreateCrew(serverName+"1", crewName+"1")
	core.activity(crew, "did nothing", "nothing")
	assert getCrew(serverName+"1").getScenarios() == [models.scenario.getScenario("20_training1").filename]
	assert getCrew(serverName+"1").getShips() == ["Phobos M3P"]
	assert getCrew(serverName+"1").getBriefing() == "Hello Crew!"
	assert getCrew(serverName).getScenarios() == []
	assert getCrew(serverName).getShips() == []
	assert getCrew(serverName).getBriefing() == ""
	setCrewTemplate(["20_training1"], ["Phobos M3P"], "Hello Crew der {crew_name}!")
	crew = getOrCreateCrew(serverName+"2", crewName+"2")
	core.activity(crew, "did nothing", "nothing")
	assert getCrew(serverName+"2").getBriefing() == f"Hello Crew der {crewName}2!"
	setCrewTemplate([], [], "")
	removeCrew(serverName)
	removeCrew(serverName+"1")
	removeCrew(serverName+"2")

def test_briefing():
	crew = getOrCreateCrew(serverName, crewName)
	crew.setBriefing("Test")
	assert crew.getBriefing() == "Test"
	removeCrew(serverName)

def test_score():
	score = {
		"artifacts":True,
		"progress":100,
		"time":9.478441022336483
	}	
	scenario = "scenario_20_training1.lua"
	expected = {
		"current_scenario_name":	"Training: Cruiser",
		"current_time":				"0:00:09",
		"best_time":				"0:00:09",
		"fleet_time":				"0:00:09",	
		"fleet_time_name":			crewName,
		"current_progress":			"100%",
		"best_progress":			"100%",
		"fleet_progress":			"100%",
		"fleet_progress_name":		crewName,
		"current_artifacts":		"1",
		"best_artifacts":			"1",
		"fleet_artifacts":			"1",
		"fleet_artifacts_name":		crewName,
	}
	crew = getOrCreateCrew(serverName, crewName)
	crew.updateScore(scenario, score)
	result = crew.getRecentScore()
	assert result == expected
	

def test_getOrCreateCrew():
	s = getOrCreateCrew(serverName, crewName)
	t = getOrCreateCrew(serverName, crewName)
	assert s == t

def _test_getScenarioSettings():
	servers.clearData()
	servers.unlockScenario(scenarioName, serverName, {"setting1": ["a","b","c"]})
	assert scenarioName in servers.getScenarios(serverName)
	assert "setting1" in servers.getScenarioSettings(scenarioName, serverName)
	servers.clearData()
	servers.unlockScenario(scenarioName, serverName)
	assert "setting1" not in servers.getScenarioSettings(scenarioName, serverName)
	assert {} == servers.getScenarioSettings(scenarioName, serverName)
	servers.unlockScenario(scenarioName, serverName, {"setting1": []})
	assert "setting1" in servers.getScenarioSettings(scenarioName, serverName)
	servers.clearData()
	servers.unlockScenario(scenarioName, serverName, {"setting1": ["a","b","c"]})
	servers.unlockScenario(scenarioName, serverName, {"setting1": ["b","d"]})
	servers.unlockScenario(scenarioName, serverName, {"setting2": ["a"]})
	assert "setting1" in servers.getScenarioSettings(scenarioName, serverName)
	assert "setting2" in servers.getScenarioSettings(scenarioName, serverName)
	assert "a" in servers.getScenarioSettings(scenarioName, serverName)["setting1"]
	assert "b" in servers.getScenarioSettings(scenarioName, serverName)["setting1"]
	assert "c" in servers.getScenarioSettings(scenarioName, serverName)["setting1"]
	assert "d" in servers.getScenarioSettings(scenarioName, serverName)["setting1"]

def _test_unlockScenario():
	servers.unlockScenario(scenarioName, serverName)
	assert scenarioName in servers.getScenarios(serverName)
	servers.unlockScenario(scenarioName, serverName)
	assert servers.getScenarios(serverName).count(scenarioName) == 1

def _test_unlockScenarios():
	servers.clearData()
	servers.unlockScenarios([scenarioName, scenarioName+"1", scenarioName, (scenarioName, {}), (scenarioName+"2", {"Difficulty": ["default"]}), (scenarioName+"3", {"Difficulty": ["easy", "hard"], "Time": []})], serverName)
	assert scenarioName in servers.getScenarios(serverName)
	assert scenarioName+"1" in servers.getScenarios(serverName)
	assert servers.getScenarios(serverName).count(scenarioName) == 1
	assert len(servers.getScenarioSettings(scenarioName, serverName)) == 0
	assert "Difficulty" not in servers.getScenarioSettings(scenarioName, serverName)
	assert "Difficulty" in servers.getScenarioSettings(scenarioName+"2", serverName)

def _test_unlockShip():
	servers.unlockShip(shipName, serverName)
	assert shipName in servers.getShips(serverName)
	servers.unlockShip(shipName, serverName)
	assert servers.getShips(serverName).count(shipName) == 1

def _test_unlockShips():
	servers.unlockShips([shipName, shipName+"1", shipName], serverName)
	assert shipName in servers.getShips(serverName)
	assert shipName+"1" in servers.getShips(serverName)
	assert servers.getShips(serverName).count(shipName) == 1

def _test_store_and_load():
	servers.getOrCreateServer("stored")
	servers.storeData()
	servers.servers = None
	servers.loadData()
	assert "stored" in servers.servers

def _test_setStatus():
	servers.getOrCreateServer("Testserver")
	assert "idle" == servers.getStatus("Testserver")
	servers.setStatus("testing", "Testserver")
	assert "testing" == servers.getStatus("Testserver")
	assert "idle" == servers.getStatus("Testserver2")
	entries = servers.getStatusAll()
	assert "Testserver" in entries
	assert "Testserver2" in entries
	assert "Hurz!" not in entries
	print(entries)


