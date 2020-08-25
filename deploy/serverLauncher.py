#!/usr/bin/env python3
import subprocess
import requests
import os
import time
import Pyro4
from Pyro4 import naming
import pyrohelper
import os
import sys
import threading
import socket
from time import sleep
import datetime

_starts_x = False # global, depends on machine
with open("/proc/sys/net/ipv4/tcp_fin_timeout","r") as file:
	_socket_timeout = datetime.timedelta(seconds=int(file.read()))

# Notice: When server or proxy are cloesed, the listen socket remains in TIMED_WAIT state.
# The duration is configured in the os in /proc/sys/net/ipv4/tcp_fin_timeout.
# Until this timeout, starting a server or proxy will fail to listen on the socket!

@Pyro4.expose
class GameServer:
	_process = None
	_http_allowed = False
	_socket_timeout_started = None

	def ping(self):
		return True

	def isRunning(self):
		if GameServer._process is not None and GameServer._process.poll() is None:
			return True
		return False
	
	def waitUntilEnd(self):
		if GameServer._process is None:
			return False
		return GameServer._process.wait()

	def _startWithArgs(self, cmds):
		now = datetime.datetime.now()
		if GameServer._socket_timeout_started:
			delta = now - GameServer._socket_timeout_started
			if delta < _socket_timeout:
				return delta.seconds	# please retry in delta seconds ...
		if GameServer._process is not None:
			return False
		command = ["./EmptyEpsilon"]
		command += cmds
		if _starts_x:
			command = ["/usr/bin/startx"] + command + ["--", "-logfile", "/tmp/x.log"]
		GameServer._process = subprocess.Popen(command, cwd="..")
		print("started server")
		time.sleep(2.0)
		GameServer._socket_timeout_started = datetime.datetime.now()
		if GameServer._process.poll() is not None:
			GameServer._process = None
			return False
		return True

	def startGame(self):
		command = []
		return self._startWithArgs(command)

	def startServer(self, scenario, variation="", name=""):
		command = ["httpserver=8080"]
		command += ["headless=%s" % (scenario)]
		if variation:
			command += ["variation=%s" % (variation)]
#		if config.server_password is not None:
#			command += ["headless_password=%s" % (config.server_password)]
		command += ["startpaused=1"]
		if name:
			command += ["headless_name=%s" % (name)]
		GameServer._http_allowed = True
		return self._startWithArgs(command)

	def startProxy(self, host, name):
		command = ["proxy=%s:35666::35666:%s" % (host,name)]
		return self._startWithArgs(command)
	
	def pause(self):
		return self._lua("pauseGame()")

	def unpause(self):
		return self._lua("unpauseGame()")

	def stop(self):
		if not GameServer._http_allowed:
			return self.terminate()
		if GameServer._process is None:
			return False
		print("stopping server")
		if GameServer._process.poll() is None:
			try:
				self._lua("shutdownGame()")
			except:
				self.terminate()
		GameServer._process.wait()
		GameServer._process = None
		GameServer._http_allowed = False
		return True

	def terminate(self):
		if GameServer._process is None:
			return 0
		print("terminating server")
		GameServer._http_allowed = False
		GameServer._process.terminate()
		try: 
			ret = GameServer._process.wait(timeout=10)
		except subprocess.TimeoutExpired:
			GameServer._process.kill()
			ret = GameServer._process.wait()
		GameServer._process = None
		return ret

	def getScenarios(self):
		result = []
		for filename in sorted(filter(lambda f: f.startswith("scenario_") and f.endswith(".lua"), os.listdir("../scripts/"))):
			result.append(filename)
		return result

	def runScript(self, script):
		return self._lua(script)

	def _lua(self, script):
		if GameServer._process is None or not GameServer._http_allowed:
			return False
		return requests.post('http://127.0.0.1:8080/exec.lua', script).content == b''

@Pyro4.expose
class GameClient:
	_process = None

	def ping(self):
		return True

	def isRunning(self):
		if GameClient._process is not None and GameClient._process.poll() is None:
			return True
		return False

	def waitUntilEnd(self):
		if GameClient._process is None:
			return False
		return GameClient._process.wait()

	def startClient(self, addr="127.0.0.1", crewPos=14, ship=""):
		if GameClient._process is not None:
			return False
		command = ["./EmptyEpsilon"]
		command += ["autoconnect=%s" % (crewPos)]
		command += ["autoconnect_address=%s" % (addr)]
		if ship:
			command += ["autoconnect_ship=callsign:%s" % (ship)]
		if _starts_x:
			command = ["/usr/bin/startx"] + command + ["--", "-logfile", "/tmp/x.log"]
		GameClient._process = subprocess.Popen(command, cwd="..")
		print("starting client")
		time.sleep(2.0)
		if GameClient._process.poll() is not None:
			GameClient._process = None
			return False
		return True
	
	def terminate(self):
		if GameClient._process is None:
			return 0
		print("terminating client")
		GameClient._process.terminate()
		try: 
			ret = GameClient._process.wait(timeout=10)
		except subprocess.TimeoutExpired:
			GameClient._process.kill()
			ret = GameClient._process.wait()
		GameClient._process = None
		return ret

	@Pyro4.oneway
	def linkToServer(self):
		if GameClient._process is None:
			return False
		if GameServer._process is None:
			return False
		GameServer._process.wait()
		self.terminate()

def maintainConnection(hostname, uri_srv, uri_cli):
	print("searching for campaing server...")
	campaign = pyrohelper.connect_to_named("Campaign")
	print("connecting to campaign server...")
	campaign.register_ee_node(hostname, uri_srv, uri_cli)
	print("connected to campaign server.")
	while True:
		time.sleep(10)
		try:
			campaign.ping()
		except (Pyro4.errors.ConnectionClosedError, Pyro4.errors.ProtocolError):
			# connection was lost
			print("connection to campaign server lost.")
			try:
				campaign._pyroReconnect()
				print("connecting to campaign server...")
				campaign.register_ee_node(hostname, uri_srv, uri_cli)
				print("connected to campaign server.")
			except:
				pass

if __name__ == "__main__":
	uri_srv = pyrohelper.host(GameServer)
	uri_cli = pyrohelper.host(GameClient)
	hostname = socket.gethostname()
	maintainConnection(hostname, uri_srv, uri_cli)




