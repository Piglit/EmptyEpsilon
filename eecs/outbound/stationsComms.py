"""This sends activites to the subscribed station"""

from utils import lua
from outbound import luaExecutor
from interfaces import storage
import functools
import json
import requests
from pprint import pprint

import core

existing_subscription = storage.loadInfo("station_comms_subscription") # or None if not found
backlog = []

def sanitize_message(crew, what):
	crew_name = lua.sanitize_lua_string(crew.crew_name)
	what = lua.sanitize_lua_string(what)
	instance_name = lua.sanitize_lua_string(crew.instance_name)
	return f"{crew_name} {what}", instance_name

def turntime(msg):
	if not existing_subscription:
		return
	(station_server, station_name) = existing_subscription
	color = "yellow"
	script = f"""
		local id=getPlayerShipIndex("{station_name}")
		_OBJECT_=getPlayerShip(id)
		_OBJECT_:addToShipLog("{msg}", "{color}")
		_OBJECT_:addCustomInfo("ShipLog", "turntime", "{msg}", 1)"""
	luaExecutor.exec(script, station_server+":8080", 1)

def turnwarning():
	if not existing_subscription:
		return
	(station_server, station_name) = existing_subscription
	color = "yellow"
	msg = "Flottenbesprechung beginnt in 5 Minuten. Bitte Schiffe zurückrufen."
	script = f"""
		local id=getPlayerShipIndex("{station_name}")
		_OBJECT_=getPlayerShip(id)
		_OBJECT_:addToShipLog("{msg}", "{color}")"""
	luaExecutor.exec(script, station_server+":8080", 1)


def backlog_append(crew, what, **kwargs):
	msg, instance_name = sanitize_message(crew, what)
	backlog.append((msg, instance_name))
	if existing_subscription:
		backlog_send()

def backlog_send():
	(station_server, station_name) = existing_subscription
	station_name = lua.sanitize_lua_string(station_name)
	script = f"""
		local id=getPlayerShipIndex("{station_name}")
		_OBJECT_=getPlayerShip(id)"""
	for data in backlog:
		(msg, instance_name) = data
		if station_server == instance_name:
			continue
		color = "cyan"
		script += f"""
			_OBJECT_:addToShipLog("{msg}", "{color}")
			_OBJECT_:addCustomInfo("ShipLog", "{instance_name}", "{msg}")"""
	luaExecutor.exec(script, station_server+":8080", 0, _callback)

def _callback(success):
	if success:
		backlog.clear()

def status_update(crew, what, **kwargs):
	if not existing_subscription:
		return
	(station_server, station_name) = existing_subscription
	station_name = lua.sanitize_lua_string(station_name)
	msg, instance_name = sanitize_message(crew, what)
	script = f"""
		local id=getPlayerShipIndex("{station_name}")
		_OBJECT_=getPlayerShip(id)
		_OBJECT_:addCustomInfo("ShipLog", "{instance_name}", "{msg}")"""
	try:
		lua.exec(script, station_server+":8080")
	except requests.exceptions.ConnectionError:
		pass

def subscribe_comms_log(server, shipname):
	existing_subscription = (server, shipname)
	storage.storeInfo(existing_subscription, "station_comms_subscription")

def unsubscribe_comms_log():
	global existing_subscription
	if existing_subscription:
		existing_subscription = None
	storage.storeInfo("", "station_comms_subscription")

core.subscribe("activity", backlog_append)
core.subscribe("progress", status_update)



