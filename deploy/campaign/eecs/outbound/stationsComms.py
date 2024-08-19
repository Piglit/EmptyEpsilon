"""This sends activites to the subscribed station"""

from utils import lua
import functools

import core

existing_subscription = None

def send_to_comms(station_server, station_name, crew, what, **kwargs):
	if station_name == crew.crew_name:
		return	# would cause deadlock
	msg = f"{crew.crew_name} {what}"
	msg = "".join(c for c in msg if c.isalpha() or c.isdigit() or c==" ")
	color = "cyan"
	script = f"""
		local id=getPlayerShipIndex("{station_name}")
		_OBJECT_=getPlayerShip(id)
		_OBJECT_:addToShipLog("{msg}", "{color}")
		_OBJECT_:addCustomInfo("ShipLog", "{crew.instance_name}", "{msg}")
	"""
	lua.exec(script, station_server+":8080")

def subscribe_comms_log(server, shipname):
	fun = functools.partial(send_to_comms, server, shipname)
	unsubscribe_comms_log()
	global existing_subscription
	existing_subscription = fun
	core.subscribe("activity", fun)

def unsubscribe_comms_log():
	if existing_subscription:
		core.unsubscribe("activity", existing_subscription)
