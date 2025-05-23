#!/usr/bin/env python3
"""http interface where EmptyEpsilon connects to. Runs on the same machine as EE-Server."""

import pyrohelper
rk = pyrohelper.connect_to_named("rk_server")

from fastapi import FastAPI, Request #, Body, HTTPException
from pydantic import BaseModel

import logging
import uvicorn
import json
log = logging.getLogger(__name__)	# does not log to log-service, only displays on terminal!

from rk_models import ShipState

# disable uvicorn OK log messages
class UvicornLogFilter(logging.Filter):
	def filter(self, record):
		if record.args and len(record.args) >= 4:
			if record.args[4] == 200:	# block 200 OK access messages
				return False
		return True
logging.getLogger("uvicorn.access").addFilter(UvicornLogFilter())


app = FastAPI()

# Models
# ShipState is in rk_models.py
class ShipRegistrationReq(BaseModel):
	callsign: str
	shipname: str
	template: str
	description: str

class ShipStateReq(BaseModel):
	callsign: str
	timestamp: float
	state: ShipState 

class Report(BaseModel):
	callsign: str
	data: list 

# Endpoints (for EE httpPost request from lua)
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

@app.post("/register_ship")
async def ship_register(d: ShipRegistrationReq):
	rk.register_ship(d.callsign, d.shipname, d.template, d.description)

@app.post("/ship_state")
async def ship_state_change(d: ShipStateReq):
	rk.ship_state_change(d.callsign, int(d.timestamp), d.state)

@app.post("/fuelconsumption")
async def fuelconsumption_from_sensor(d : Report):
	rk.fuelconsumption_from_sensor(d.callsign, d.data)

@app.post("/damagereport")
async def damagereport_from_sensor(d : Report):
	rk.damagereport_from_sensor(d.callsign, d.data)

@app.post("/reactor_control")
async def reactor_control(request: Request):
	j = await request.json()
	log.debug(j)

@app.post("/pingpost")
async def ping():
	pass

if __name__ == "__main__":
	uvicorn.run("rk_http:app", host="127.0.0.1", port=8002, reload=False)
