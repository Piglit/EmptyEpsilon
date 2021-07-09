#!/usr/bin/env python3
import requests
import Pyro4
import pyrohelper
import socket

"""
This script has to run on each EE server.
It may be called from the campaign server or custom clients.
"""

@Pyro4.expose
class GameServerScriptInterface:
	known_ship_ids = {}

	def spawn(self, callsign, template, password):
		script = f"""
			ship = PlayerSpaceship()
			rotation = random(0, 360)
			ship:setRotation(rotation)
			ship:commandTargetRotation(rotation)
			ship:setPosition((random(-100, 100), random(-100, 100)))
			ship:setTemplate("{template}")
			ship:setCallSign("{callsign}")
			ship:setControlCode("{password}")
		"""
		return self._lua(script)

	def find_playership(self, shipname):
		script = f"""id=getPlayerShipIndex("{shipname}")"""
		resp = self._lua_get(script)
		id = resp.get("id", -2)
		if id >= 0:
			GameServerScriptInterface.known_ship_ids[shipname] = id
		return id

	def _get_playership_id(self, shipname):
		if shipname in GameServerScriptInterface.known_ship_ids:
			return GameServerScriptInterface.known_ship_ids[shipname]
		else:
			id = self.find_playership(shipname)
			assert id >= 0
			return id

	def command_esystem_power(self, shipname, esystem, power):
		id = self._get_playership_id(shipname)
		script = f"""
			_OBJECT_=getPlayerShip({id})
			_OBJECT_:commandSetSystemPowerRequest("{esystem}", {power})
		"""
		return self._lua_get(script)

	def _lua_exec(self, script):
		return True
		#return requests.post('http://127.0.0.1:8080/exec.lua', script).content == b''

	def _lua_get(self, script):
		return True
		#return requests.get('http://127.0.0.1:8080/get.lua', script).content

if __name__ == "__main__":
	pyrohelper.host_named_server(GameServerScriptInterface, socket.gethostname())

