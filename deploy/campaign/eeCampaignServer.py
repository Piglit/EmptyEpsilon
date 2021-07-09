#!/usr/bin/env python3
from fastapi import FastAPI, Request, Body, logger
from fastapi.testclient import TestClient
from pydantic import BaseModel
from typing import Optional, List
from pprint import pprint
import uvicorn
import logging
import os
import json
import requests
from copy import deepcopy
from urllib.parse import unquote

from scenarioInfo import scenarioInfos
from srvData import servers
from utils import removeprefix, removesuffix
import pyrohelper

#MISSIONS = missionDB.MISSIONS

# note: uvicorn logging is a bitch
logging.getLogger("uvicorn.access").handlers = []
logging.getLogger("uvicorn.access").propagate = False

log = logging.getLogger(__name__)
h = logging.StreamHandler()
h.setFormatter(logging.Formatter("%(asctime)s\t%(levelname)s:\t%(message)s", datefmt="%H:%M:%S"))
log.setLevel("DEBUG")
log.addHandler(h)

app = FastAPI()
testClient = TestClient(app)

def scenarioFileNameToMissionId(scenario_name):
	return removesuffix(removeprefix(scenario_name, "scenario_"), ".lua")

@app.get("/")
async def root():
	return {"message": "Hello Space"}

@app.post("/debug")
async def postDebug(request : Request):
	log.debug(request.method)
	log.debug(request.url)
	log.debug(request.headers)
	log.debug(request.query_params)
	log.debug(request.path_params)
	j = await request.body()
	log.debug(j)
	j = await request.json()
	log.debug(j)

class EEServerScenarioInfo(BaseModel):
	filename: str
	name: str
	variation: str

	def getId(self):
		return scenarioFileNameToMissionId(self.filename)

	def __str__(self):
		readable = self.name
		if self.variation and self.variation != "None":
			readable += " ["+self.variation+"]"
		if logging.DEBUG >= log.level:
			readable += " ("+self.getId() + "; " + self.filename+")"
		return readable

class EEProxyShipInfo(BaseModel):
	server_ip: str
	callsign: str
	password: str
	template: str

class ScenarioInfoVictory(EEServerScenarioInfo):
	faction: str

class ScenarioInfoScriptMessage(EEServerScenarioInfo):
	script_message: str

def runScenarioInfoCallback(scenario_id, callback_name, server_name, **kwargs):
	info = scenarioInfos.get(scenario_id)
	if info and callback_name in info:
		if isinstance(info[callback_name], list):
			for cb in info[callback_name]:
				cb(server_name, **kwargs)
		else:
			info[callback_name](server_name, **kwargs)

@app.post("/scenario_start")
async def scenario_start(scenario_info: EEServerScenarioInfo, server_name: str = Body(...)):
	log.info(server_name + "\tstarted scenario" + str(scenario_info))
	runScenarioInfoCallback(scenario_info.getId(), "@start", server_name)
	servers.storeData()

@app.post("/proxySpawn")
async def proxySpawn(ship = EEProxyShipInfo):
	log.info(ship.callsign + "\tspawned ship " + str(ship.template) + " on " + str(ship.server_ip))
	command = f"PlayerSpaceship():setFaction('Human Navy'):setTemplate('{ship.template}'):setCallSign('{ship.callsign}'):setControlCode('{ship.password}')"
	result = requests.get(f"{ship.server_ip}/exec.lua", data=command)
	log.debug(result)

@app.post("/scenario_end")
async def scenario_end(scenario_info: EEServerScenarioInfo, server_name: str = Body(...)):
	log.info(server_name + "\taborted scenario" + str(scenario_info))
	runScenarioInfoCallback(scenario_info.getId(), "@end", server_name)

@app.post("/scenario_victory")
async def scenario_victory(scenario_info: ScenarioInfoVictory, server_name: str = Body(...)):
	victory_faction = scenario_info.faction
	log.info(server_name + "\tfinished scenario " + str(scenario_info) + "\twinner: " + victory_faction)
	call = "@victory["+victory_faction+"]"
	runScenarioInfoCallback(scenario_info.getId(), call, server_name)

@app.post("/script_message")
async def script_message(scenario_info: ScenarioInfoScriptMessage, server_name: str = Body(...)):
	# unused
	scm = scenario_info.script_message
	log.info(server_name + "\tscript message   " + str(scenario_info) + "\t:" + scm)
	if scm.startswith("unlock:[") and scm.endswith("]"):
		unlock = scm.split("[", maxsplit=1)[1]
		unlock = unlock.strip("]")
		unlock = unlock.split(",")
		unlock = list(map(strip,unlock))
		unlockMissions(notification.server_name, unlock)

class ScenarioResponse(BaseModel):
	scenarios: List[str]

@app.get("/scenarios/{server_name}", response_model = ScenarioResponse)
async def getScenarios(server_name):
	server_name = unquote(server_name)
	log.debug(server_name + "\tget scenarios")
	scenarios = servers.getScenarios(server_name)
	scenarios = ["scenario_"+s+".lua" for s in scenarios] 
	return {"scenarios": scenarios}

@app.get("/scenario_info/{server_name}/{scenario_name}")
async def getScenarioInfo(server_name, scenario_name):
	server_name = unquote(server_name)
	log.debug(server_name + "\tget scenario info for "+scenario_name)
	scenario_name = scenarioFileNameToMissionId(scenario_name)
	info = deepcopy(scenarioInfos[scenario_name]["info"])
	variations = servers.getScenarioVariations(scenario_name, server_name)
	#EE expects key = variation[name], value = descr
	if "*" in variations:
		for v, descr in scenarioInfos[scenario_name]["variations"].items():
			info["variation["+v+"]"] = descr
	else:
		for v in variations:
			if v is not None:
				# we can currently not forbid the default variation in EE
				descr = scenarioInfos[scenario_name]["variations"].get(v, "no description available")
				info["variation["+v+"]"] = descr
	info = {"scenarioInfo": info}
	#log.debug(json.dumps(info))
	return info

@app.get("/ships_available/{server_name}")
async def getShipsAvailable(server_name):
	server_name = unquote(server_name)
	log.debug(server_name + "\tget ships avail")
	ships = servers.getShips(server_name)
	return {"ships": ships}

if __name__ == "__main__":
	uvicorn.run("eeCampaignServer:app", host="0.0.0.0", reload=False, port=8888)
	pyrohelper.cleanup()
