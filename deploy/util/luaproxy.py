#!/usr/bin/env python3
from fastapi import FastAPI, Request, Body, logger
import uvicorn
import logging

proxy = FastAPI()

@proxy.get("/")
async def root():
	return {"message": "Hello Space"}


@proxy.get("/get/{callsign}")
async def get(callsign: str, request: Request):
	query = getShipObjByName(callsign)
	for first, second in request.query_params.items():
		assert first.isidentifier(), first + " is not an identifier"
		assert second.startswith("get")
	query += "&"+str(request.query_params)
	return {"EE-Query": query}

@proxy.get("/command/{callsign}")
async def command(callsign: str, request: Request):
	query = getShipObjByName(callsign)
	for first, second in request.query_params.items():
		assert first.isidentifier(), first + " is not an identifier"
		assert second.startswith("command")
	query += "&"+str(request.query_params)
	return {"EE-Query": query}

@proxy.get("/spawn")
async def command(request: Request):
	query = "_OBJECT_=PlayerSpaceship()"
	for first, second in request.query_params.items():
		assert first.startswith("set")
	query += "&"+str(request.query_params)
	return {"EE-Query": query}

def getShipObjByName(callsign):
	id = -1
	return f"_OBJECT_=getPlayerShip({id})"


if __name__ == "__main__":
	uvicorn.run("luaproxy:proxy", host="0.0.0.0", reload=True, port=8070)
