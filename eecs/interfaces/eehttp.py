#!/usr/bin/env python3
"""This file contains the REST API for the eeservers."""
from fastapi import FastAPI, Request, Body, HTTPException

from pydantic import BaseModel
from typing import Optional, List
from enum import Enum
from pprint import pprint
import logging
import json
import requests
from copy import deepcopy
from urllib.parse import unquote
from random import randint
import logging
log = logging.getLogger(__name__)

from core import activity, script_message, progress
import models.crew
from models.scenarioevents import ScenarioEvents 
import models.scenario

app = FastAPI()

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

class EEServer(BaseModel):
	instance_name: str
	crew_name: str

class EEScenario(BaseModel):
	filename: str
	name: str

	def getScenario(self):
		return models.scenario.getScenario(self.filename)

	def __str__(self):
		return str(self.getScenario())

@app.post("/scenario/{event}")
async def scenario_event(event: ScenarioEvents, scenario: EEScenario, server: EEServer):
	c = models.crew.getOrCreateCrew(server.instance_name, server.crew_name)
	activity(c, event.fleet_info() + " " + str(scenario), event=event, scenario=scenario.getScenario())

@app.post("/screen")
async def screen(server: EEServer, screen: str = Body(...)):
	c = models.crew.getOrCreateCrew(server.instance_name, server.crew_name)
	activity(c, "is at " + screen)

class ScriptProgress(BaseModel):
	progress: float

@app.post("/script/progress")
async def scriptProgress(scenario: EEScenario, server: EEServer, data: ScriptProgress):
	c = models.crew.getOrCreateCrew(server.instance_name, server.crew_name)
	prog = round(data.progress * 100)
	progress(c, "is pursuing " + str(scenario) + f" ({prog}%)", scenario.getScenario(), {"progress": prog})

class ScriptMessage(BaseModel):
	topic: str 
	details: str 

@app.post("/script/message")
async def scriptMessage(scenario: EEScenario, server: EEServer, data: ScriptMessage):
	c = models.crew.getOrCreateCrew(server.instance_name, server.crew_name)
	script_message(c, scenario.getScenario(), data.topic, data.details)
#	if topic == "spyReport":
#		pyrohelper.connect_to_named("spysatReceiver").recv(details)
#	elif topic == "petgReport":
#		pyrohelper.connect_to_named("petgReceiver").recv(details)

# This transmits the campaign state of a crew to the crews server
# It it called everytime the ~serverScenarioSelectionScreen~ serverCampaignMenu is created.

class CampaignResponse(BaseModel):
	briefing: str
	scenarios: list[str]
	score: dict[str, str]
#	ships: list[str]

@app.get("/campaign/{server_name}/{crew_name}", response_model = CampaignResponse)
async def getCampaign(server_name, crew_name):
	await screen(EEServer(instance_name=server_name, crew_name=crew_name), "scenario selection")
	c = models.crew.getCrew(server_name)
	if not c:
		raise HTTPException(status_code=404, detail=f"Crew {server_name} not found.")

	scenarios = c.getScenarios()

	return {
		"briefing": c.getBriefing(),
		"scenarios": scenarios,
#		"ships": c.getShips(),	# don't know if needed...
		"score": c.getRecentScore(),
	}

class BriefingResponse(BaseModel):
	briefing: str

@app.get("/briefing/{server_name}", response_model = BriefingResponse)
async def getBriefing(server_name):
	c = models.crew.getCrew(server_name)
	if not c:
		raise HTTPException(status_code=404, detail=f"Crew {server_name} not found.")
	return {"briefing": c.getBriefing()}

class ScenarioResponse(BaseModel):
	scenarios: List[str]

@app.get("/scenarios/{server_name}", response_model = ScenarioResponse)
async def getScenarios(server_name):
	c = models.crew.getCrew(server_name)
	if not c:
		raise HTTPException(status_code=404, detail=f"Crew {server_name} not found.")
	scenarios = c.getScenarios()
	return {"scenarios": scenarios}

@app.get("/scenario_info/{server_name}/{scenario_name}")
async def getScenarioInfo(server_name, scenario_name):
	assert False, "unused"
	log.debug(server_name + "\tget scenario info for "+scenario_name)
	scenario = models.scenario.getScenario(scenario_name)
	return {"scenarioInfo": scenario.getInfo()}

@app.get("/scenario_settings/{server_name}/{scenario_name}")
async def getScenarioSettings(server_name, scenario_name):
	c = models.crew.getCrew(server_name)
	if not c:
		raise HTTPException(status_code=404, detail=f"Crew {server_name} not found.")
	scenario = models.scenario.getScenario(scenario_name)
	settings = c.getScenarioSettings(scenario.filename)
	log.debug(json.dumps(settings))
	return settings

@app.get("/ships_available/{server_name}")
async def getShipsAvailable(server_name):
	c = models.crew.getCrew(server_name)
	if not c:
		raise HTTPException(status_code=404, detail=f"Crew {server_name} not found.")
	ships = c.getShips()
	return {"ships": ships}

@app.get("/spawn_position/{server_name}/{scenario_name}")
async def getSpawnPosition(server_name, scenario_name):
	scenario_name = scenarioFileNameToMissionId(scenario_name)
	scenario = scenario_info.get(scenario_name)
	if scenario and "spawn" in scenario:
		spawn_info = scenario["spawn"]
	else:
		spawn_info = {"posx": randint(-100, 100), "posy": randint(-100, 100), "dir": randint(0,359)}
	return spawn_info 

