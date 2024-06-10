"""This sends activites to the subscribed station"""

from utils import lua
import functools

def send_to_comms(station_server, station_name, _, crew_name, what):
	msg = f"{crew_name} {what}"
	color = "cyan"
	script = f"""
		local id=getPlayerShipIndex("{station_name}")
		_OBJECT_=getPlayerShip(id)
		_OBJECT_:addToShipLog({msg}, {color})
	"""
	lua.exec(script, station_server)

def subscribe_comms_log(server, shipname):
	fun = functools.partial(send_to_comms, server, shipname)
	core.subscribe("activity", fun)
