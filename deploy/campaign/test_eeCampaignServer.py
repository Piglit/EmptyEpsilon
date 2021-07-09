#!/usr/bin/env python3
import eeCampaignServer
import uvicorn
from fastapi.testclient import TestClient
from copy import deepcopy
from pprint import pprint
import pytest
import os
import random
import urllib

from srvData import servers

testClient = TestClient(eeCampaignServer.app)

@pytest.fixture()
def scenario_info():
	return {
		"scenario_info": {
			"filename": "scenario_00_test.lua",
			"name": "Test",
			"variation": "None",
		},
		"server_name": "Server",
	}

@pytest.fixture()
def scenario_info_proxy():
	return {
		"callsign": "Testship",
		"template": "Atlantis",
		"password": "testi",
		"server_ip": "127.0.0.1",
	}

@pytest.fixture(autouse=True)
def cleanup():
	servers.clearData()

def test_root():
	response = testClient.get("/")
	assert response.status_code == 200, response.reason
	assert response.json() == {"message": "Hello Space"}

def test_debug():
	response = testClient.post("/debug", json = {"debug": "debug"})
	assert response.status_code == 200, response.reason

def test_scenario_start(scenario_info):
	response = testClient.post("/scenario_start", json = scenario_info)
	assert response.status_code == 200, response.reason
	assert "01_test2" in servers.getScenarios(scenario_info["server_name"])

def test_scenario_join(scenario_info_proxy):
	response = testClient.post("/proxySpawn", json = scenario_info_proxy)
	assert response.status_code == 200, response.reason

def test_scenario_end(scenario_info):
	response = testClient.post("/scenario_end", json = scenario_info)
	assert response.status_code == 200, response.reason
	assert "Hathcock" in servers.getShips(scenario_info["server_name"])

def test_scenario_victory(scenario_info):
	local_scenario_info_test = deepcopy(scenario_info)
	for case in ["Kraylor", "Independent"]:
		local_scenario_info_test["scenario_info"]["faction"] = case
		response = testClient.post("/scenario_victory", json = local_scenario_info_test)
		assert response.status_code == 200, response.reason
		assert "09_outpost" not in servers.getScenarios(local_scenario_info_test["server_name"])

	local_scenario_info_test["scenario_info"]["faction"] = "Human Navy" 
	response = testClient.post("/scenario_victory", json = local_scenario_info_test)
	assert response.status_code == 200, response.reason
	assert "09_outpost" in servers.getScenarios(local_scenario_info_test["server_name"])


	local_scenario_info_test["scenario_info"]["faction"] = case

"Human Navy"

def test_script_message(scenario_info):
	local_scenario_info_test = deepcopy(scenario_info)
	local_scenario_info_test["scenario_info"]["script_message"] = "unlock: ['test1', 'test2']"
	response = testClient.post("/script_message", json = local_scenario_info_test)
	assert response.status_code == 200, response.reason

def test_getScenarios():
	server_name = "Testserver"
	missionFile = "missions_" + server_name
	response = testClient.get("/scenarios/"+server_name)
	assert response.status_code == 200, response.reason
	assert response.json() == {"scenarios": ["scenario_20_training1.lua"]}

	# add one
	servers.unlockScenario("00_test", server_name)
	response = testClient.get("/scenarios/"+server_name)
	assert response.status_code == 200, response.reason
	assert response.json() == {"scenarios": ["scenario_20_training1.lua", "scenario_00_test.lua"]}

	# add duplicate
	servers.unlockScenario("00_test", server_name)
	response = testClient.get("/scenarios/"+server_name)
	assert response.status_code == 200, response.reason
	assert response.json() == {"scenarios": ["scenario_20_training1.lua", "scenario_00_test.lua"]}

	# urlencode
	server_name = "Test Server"
	server_name = urllib.parse.quote(server_name)
	response = testClient.get("/scenarios/"+server_name)
	assert response.status_code == 200, response.reason

def test_getShips():
	server_name = "Testserver"
	response = testClient.get("/ships_available/"+server_name)
	assert response.status_code == 200, response.reason
	assert response.json() == {"ships": ["Phobos"]}
	servers.unlockShip("Hathcock", server_name)
	response = testClient.get("/ships_available/"+server_name)
	assert response.status_code == 200, response.reason
	assert "Hathcock" in response.json()["ships"]
	
def test_getScenarioInfo():
	server_name = "Testserver"
	missionId = "00_basic"
	servers.unlockScenario(missionId, server_name)
	missionId = "scenario_00_basic.lua"
	response = testClient.get("/scenario_info/"+server_name+"/"+missionId)
	missionId = "00_basic"
	assert response.status_code == 200, response.reason
	assert response.json()["scenarioInfo"]["Name"] == "Basic"
	assert response.json()["scenarioInfo"]["Type"] == "Basic"
	assert "Description" in response.json()["scenarioInfo"]
	for key in response.json()["scenarioInfo"]:
		assert not key.startswith("variation")
	servers.unlockScenario(missionId, server_name, "var1")
	response = testClient.get("/scenario_info/"+server_name+"/"+missionId)
	assert "variation[var1]" in response.json()["scenarioInfo"]
	# proxy
	missionId = "59_border"
	servers.unlockScenario(missionId, server_name)
	response = testClient.get("/scenario_info/"+server_name+"/"+missionId)
	assert response.status_code == 200, response.reason
	assert "Proxy" in response.json()["scenarioInfo"]
	assert response.json()["scenarioInfo"]["Proxy"] == "192.168.2.3"

def test_fuzzy_workflow():
	server_name = "Testserver"
	response = testClient.get("/scenarios/"+server_name)
	assert response.status_code == 200, response.reason
	scenarios = response.json()["scenarios"]
	assert scenarios == ["scenario_20_training1.lua"]

	i = 10

	while i > 0:
		i -= 1
		scenario = random.choice(scenarios)
		response = testClient.get("/scenario_info/"+server_name+"/"+scenario)
		assert response.status_code == 200, response.reason
		variations = servers.getScenarioVariations(eeCampaignServer.scenarioFileNameToMissionId(scenario), server_name)
		variation = random.choice(variations)
		reqdata = {
			"scenario_info": {
				"filename": scenario,
				"name": "TestDummyDane",
				"variation": str(variation),
			},
			"server_name": server_name,
		}
		response = testClient.post("/scenario_start", json = reqdata)
		assert response.status_code == 200, response.reason
		if random.getrandbits(1):
			response = testClient.post("/scenario_end", json = reqdata)
			assert response.status_code == 200, response.reason
		if True: #random.getrandbits(1):
			reqdata["scenario_info"]["faction"] = "Human Navy"
			response = testClient.post("/scenario_victory", json = reqdata)
			assert response.status_code == 200, response.reason
			del reqdata["scenario_info"]["faction"]
			response = testClient.post("/scenario_end", json = reqdata)
			assert response.status_code == 200, response.reason
		else:
			reqdata["scenario_info"]["faction"] = "Kraylor"
			response = testClient.post("/scenario_victory", json = reqdata)
			assert response.status_code == 200, response.reason
			del reqdata["scenario_info"]["faction"]
			response = testClient.post("/scenario_end", json = reqdata)
			assert response.status_code == 200, response.reason
		response = testClient.get("/scenarios/"+server_name)
		assert response.status_code == 200, response.reason
		scenarios = response.json()["scenarios"]
	servers.storeData()

if __name__ == "__main__":
	uvicorn.run("eeCampaignServer:app", host="0.0.0.0", reload=False, port=8888)

