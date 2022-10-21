#!/usr/bin/env python3
"""This file contains the REST API fpr the eeCampaign.
It is run as the main executable, since it starts the web-server.
"""
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
from random import randint

from campaignScenarios import scenarioInfos
from serverControl import servers
from utils import removeprefix, removesuffix
import pyrohelper

# note: uvicorn logging is a bitch
logging.getLogger("uvicorn.access").handlers = []
logging.getLogger("uvicorn.access").propagate = False

log = logging.getLogger(__name__)
h = logging.StreamHandler()
h.setFormatter(logging.Formatter("%(asctime)s\t%(levelname)s:\t%(message)s", datefmt="%H:%M:%S"))
log.setLevel("INFO")
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

	def getId(self):
		return scenarioFileNameToMissionId(self.filename)

	def __str__(self):
		readable = self.name
		if logging.DEBUG >= log.level:
			readable += " ("+self.getId() + "; " + self.filename+")"
		return readable

class EEProxyShipInfo(BaseModel):
	server_ip: str
	callsign: str
	password: str
	template: str
	drive: str
	x: int
	y: int
	rota: int

class EEProxyDestroyInfo(BaseModel):
	server_ip: str
	callsign: str

class ScenarioInfoVictory(EEServerScenarioInfo):
	faction: str

class ScenarioInfoScriptMessage(EEServerScenarioInfo):
	script_message: str

def runScenarioInfoCallback(scenario_id, callback_name, server_name, **kwargs):
	"""possible callbacks:
		@start - when scenario is started
		@victory[faction] - when victory is declared
		@end - when mission is aborted or finished
	"""
	info = scenarioInfos.get(scenario_id)
	if info and callback_name in info:
		if isinstance(info[callback_name], list):
			for cb in info[callback_name]:
				cb(server_name, **kwargs)
		else:
			info[callback_name](server_name, **kwargs)

@app.post("/scenario_start")
async def scenario_start(scenario_info: EEServerScenarioInfo, server_name: str = Body(...)):
	log.info(server_name + "\tstarted scenario " + str(scenario_info))
	runScenarioInfoCallback(scenario_info.getId(), "@start", server_name)
	servers.setStatus(scenario_info.name + "\tstarted", server_name)
	servers.storeData()

@app.post("/proxySpawn")
async def proxySpawn(ship: EEProxyShipInfo):
	log.info(ship.callsign + "\tspawned ship " + str(ship.template) + " with "+ str(ship.drive) + " drive on " + str(ship.server_ip))
	additionalCode = servers.getShipAdditionalCode(ship.callsign)
	script = """
		ship = PlayerSpaceship()
		ship:setRotation({ship.rota})
		ship:commandTargetRotation({ship.rota})
		ship:setPosition({ship.x}, {ship.y})
		ship:setTemplate("{ship.template}")
		ship:setCallSign("{ship.callsign}")
		ship:setControlCode("{ship.password}")
	""" + additionalCode
	script = script.format(**locals())
	if ship.drive == "warp":
		script += "\nship:setWarpDrive(true):setJumpDrive(false)"
	elif ship.drive == "jump":
		script += "\nship:setWarpDrive(false):setJumpDrive(true)"

	log.debug(script)
	result = requests.get(f"http://{ship.server_ip}:8080/exec.lua", data=script)
	log.debug(result)

@app.post("/proxyDestroy")
async def proxySpawn(ship: EEProxyDestroyInfo):
	log.info(ship.callsign + "\tdestroyed on " + str(ship.server_ip))
	script = f"""
		idx = getPlayerShipIndex("{ship.callsign}")
		ship = getPlayerShip(idx)
		ship:destroy()
	"""
	log.debug(script)
	result = requests.get(f"http://{ship.server_ip}:8080/exec.lua", data=script)
	log.debug(result)

@app.post("/scenario_end")
async def scenario_end(scenario_info: EEServerScenarioInfo, server_name: str = Body(...)):
	log.info(server_name + "\taborted scenario " + str(scenario_info))
	servers.setStatus(scenario_info.name + "\taborted", server_name)
	runScenarioInfoCallback(scenario_info.getId(), "@end", server_name)

@app.post("/scenario_victory")
async def scenario_victory(scenario_info: ScenarioInfoVictory, server_name: str = Body(...)):
	victory_faction = scenario_info.faction
	log.info(server_name + "\tfinished scenario " + str(scenario_info) + "\twinner: " + victory_faction)
	servers.setStatus(scenario_info.name + "\t"+victory_faction+" won", server_name)
	call = "@victory["+victory_faction+"]"
	runScenarioInfoCallback(scenario_info.getId(), call, server_name)

@app.post("/script_message")
async def script_message(scenario_info: ScenarioInfoScriptMessage, server_name: str = Body(...)):
	# unused
	scm = scenario_info.script_message
	log.info(server_name + "\tscript message   " + str(scenario_info) + "\t" + scm)
	if scm.startswith("unlockScenarios:[") and scm.endswith("]"):
		unlock = scm.split("[", maxsplit=1)[1]
		unlock = unlock.strip("]")
		unlock = unlock.split(",")
		unlock = list(map(strip,unlock))
		unlockScenarios(notification.server_name, unlock)
	elif scm.startswith("unlockShips:[") and scm.endswith("]"):
		unlock = scm.split("[", maxsplit=1)[1]
		unlock = unlock.strip("]")
		unlock = unlock.split(",")
		unlock = list(map(strip,unlock))
		unlockShips(notification.server_name, unlock)
	elif scm.startswith("setProgress:"):
		prog = scm.split(":", maxsplit=1)[1]
		prog = prog.strip()
		servers.setStatus(scenario_info.name + "\t"+prog, server_name)
	elif scm.startswith("spyReport:")
		msg = scm.split(":", maxsplit=1)[1]
		log.info(msg)	#TODO send to some message receiver

class ScenarioResponse(BaseModel):
	scenarios: List[str]

@app.get("/scenarios/{server_name}", response_model = ScenarioResponse)
async def getScenarios(server_name):
	server_name = unquote(server_name)
	log.debug(server_name + "\tget scenarios")
	servers.setStatus("selecting mission", server_name)
	scenarios = servers.getScenarios(server_name)
	scenarios = ["scenario_"+s+".lua" for s in scenarios] 
	return {"scenarios": scenarios}

@app.get("/scenario_info/{server_name}/{scenario_name}")
async def getScenarioInfo(server_name, scenario_name):
	server_name = unquote(server_name)
	log.debug(server_name + "\tget scenario info for "+scenario_name)
	scenario_name = scenarioFileNameToMissionId(scenario_name)
	info = deepcopy(scenarioInfos[scenario_name]["info"])
	info = {"scenarioInfo": info}
	#log.debug(json.dumps(info))
	return info

@app.get("/scenario_settings/{server_name}/{scenario_name}")
async def getScenarioSettings(server_name, scenario_name):
	server_name = unquote(server_name)
	log.debug(server_name + "\tget scenario settings for "+scenario_name)
	scenario_name = scenarioFileNameToMissionId(scenario_name)
	settings = servers.getScenarioSettings(scenario_name, server_name)
	log.debug(json.dumps(settings))
	return settings

@app.get("/ships_available/{server_name}")
async def getShipsAvailable(server_name):
	server_name = unquote(server_name)
	log.debug(server_name + "\tget ships avail")
	ships = servers.getShips(server_name)
	return {"ships": ships}

@app.get("/spawn_position/{server_name}/{scenario_name}")
async def getSpawnPosition(server_name, scenario_name):
	server_name = unquote(server_name)
	log.debug(server_name + "\tget spawn position for "+scenario_name)
	scenario_name = scenarioFileNameToMissionId(scenario_name)
	scenario = scenario_info.get(scenario_name)
	if scenario and "spawn" in scenario:
		spawn_info = scenario["spawn"]
	else:
		spawn_info = {"posx": randint(-100, 100), "posy": randint(-100, 100), "dir": randint(0,359)}
	return spawn_info 

if __name__ == "__main__":
	uvicorn.run("eeCampaignServer:app", host="0.0.0.0", reload=False, port=8888)
	pyrohelper.cleanup()
