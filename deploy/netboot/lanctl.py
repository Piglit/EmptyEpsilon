#!/usr/bin/python3
"""
This launcher is run as a systemd-service at system startup.
It provides functionality to control the behaviour of the system via Pyro-Commands.
Deeper funtionality of single states should be implemented in other files.
"""
import Pyro4
import socket

import sys
import os
script_path = os.path.realpath(os.path.dirname(__name__))
sys.path.insert(1,script_path+"/../util/")
import pyrohelper

@Pyro4.expose
class LanController:

	def __init__(self):
		self.state = "default"

	def ping(self):
		return True

	def getState(self):
		return self.state

def start():
	controller = LanController()
	uri_srv = pyrohelper.host(controller, port=2221, objectId="Control_"+socket.gethostname())
	return uri_srv

def stop():
	print("stoping")
	pyrohelper.cleanup()

if __name__ == "__main__":
	uri = start()
	print("started. Connect with Pyro4.Proxy('"+str(uri)+"')")

