#!/usr/bin/python3
"""
This launcher is run as a systemd-service at system startup.
It provides functionality to control the behaviour of the system via Pyro-Commands.
Deeper funtionality of single states should be implemented in other files.
"""
import Pyro4
import socket
import time

import sys
import os
import util.pyrohelper as pyrohelper
from eectl.serverLauncher import GameServer, GameClient

@Pyro4.expose
class LanController:

	def __init__(self):
		self.state = "default"
		self.state_end = lambda : None

	def ping(self):
		return True

	def getState(self):
		return self.state

	def _changeState(self, new_state):
		self.state_end()
		self.state = new_state
		self.state_end = lambda : None

	@Pyro4.oneway
	def startServer(self):
		self._changeState("server")
		srv = GameServer()
		if srv.startMissionControlServer(shipname=socket.gethostname()):
			self.state_end = srv.stop
		else:
			self.state = "error"

	@Pyro4.oneway
	def startClient(self):
		self._changeState("client")
		cli = GameClient()
		cli.startClient(starts_x=True)


	@Pyro4.oneway
	def startProxy(self):
		self._changeState("proxy")
		srv = GameServer()
		srv.startProxy("192.168.2.3", socket.gethostname())

def start():
	controller = LanController()
	uri_srv = pyrohelper.host(controller, port=2221, objectId="Control_"+socket.gethostname())
	controller.startServer()
	return uri_srv

def stop():
	print("stoping")
	pyrohelper.cleanup()

def waitForHostname():
	hostname = socket.gethostname()
	timeout = 5
	while hostname == "pxeclient" and timeout > 0:
		print(f"waiting for hostname change (timeout: {timeout}s)")
		time.sleep(1)
		hostname = socket.gethostname()
		timeout -= 1
	if timeout > 0:
		return True
	return False

if __name__ == "__main__":
	if not waitForHostname():
		# we are a netbooted client, not part of the architecture
		print("starting game")
		controller = LanController()
		controller.startClient()
	else:
		uri = start()
		print("started. Connect with Pyro4.Proxy('"+str(uri)+"')")

