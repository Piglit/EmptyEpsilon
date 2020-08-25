#!/usr/bin/python3

import Pyro4
import pyrohelper
import threading
import os
import time
import missionDB

import logging
from logging import info, debug
logging.basicConfig(format="%(asctime)s %(levelname)s: %(message)s", datefmt="%H:%M:%S", level=logging.DEBUG)

MISSIONS = missionDB.MISSIONS

@Pyro4.expose
class Campaign:
	_ee_nodes = {}
	_lock = threading.RLock()
	_last_return_values = {}

	def ping(self):
		return True

	def register_ee_node(self, hostname, uri_srv, uri_cli):
		# srv can be called from campaign server to run
		srv = pyrohelper.connect(uri_srv)	# srv_uri may ba accessed as srv._pyroUri
		cli = pyrohelper.connect(uri_cli)
		info(hostname + " connected.")
		with Campaign._lock:
			Campaign._ee_nodes[hostname] = {
				"server": srv,
				"client": cli
			}

	def getMissionsFor(self, hostname):
		missionFile = "missions_"+hostname
		if not os.path.exists(missionFile):
			with open(missionFile, "w") as file:
				file.write("training1\n")
		missions = {}
		with open(missionFile,"r") as file:
			for line in file:
				missionName = line.strip()
				mission = MISSIONS[missionName]
				missions[missionName] = mission
		return missions

	@Pyro4.oneway
	def startMissionFor(self, hostname, missionId):
		if hostname not in Campaign._ee_nodes:
			return False
		Campaign._last_return_values[hostname] = "pending"
		info("start mission "+missionId+" for "+hostname)
		mission = MISSIONS[missionId]
		srv = Campaign._ee_nodes[hostname]["server"]
		ret = srv.startServer(mission["scenario"], mission.get("variation"), name=hostname)
		if ret == True:
			info(hostname + " started " + mission["name"] )
			missionFile = "missions_"+hostname
			with open(missionFile, "a") as file:
				for u in mission["unlocks"]:
					file.write(u+"\n")
		else:
			info(hostname + " tried to start " + mission["name"] + ". got " +str(ret) )
		Campaign._last_return_values[hostname] = ret

	def getReturnValueFor(self, hostname):
		return Campaign._last_return_values.get(hostname)

	def unpauseFor(self, hostname):
		if hostname not in Campaign._ee_nodes:
			return False
		Campaign._last_return_values[hostname] = None 
		srv = Campaign._ee_nodes[hostname]["server"]
		srv.unpause()

	def getNodes(self):
		return Campaign._ee_nodes

	def justStart(self, hostname):
		if hostname not in Campaign._ee_nodes:
			return False
		Campaign._last_return_values[hostname] = None 
		info("just start "+hostname)
		return Campaign._ee_nodes[hostname]["server"].startGame()

	def justStop(self, hostname):
		if hostname not in Campaign._ee_nodes:
			return False
		Campaign._last_return_values[hostname] = None 
		info("just stop "+hostname)
		ok = Campaign._ee_nodes[hostname]["server"].stop()
		ok &= Campaign._ee_nodes[hostname]["client"].terminate()
		return ok

	def startScenario(self, hostname, scenario, variation=None):
		if hostname not in Campaign._ee_nodes:
			return False
		Campaign._last_return_values[hostname] = None 
		info("start scenario "+scenario+" ("+str(variation)+") for "+hostname)
		srv = Campaign._ee_nodes[hostname]["server"]
		cli = Campaign._ee_nodes[hostname]["client"]
		ok = False
		if srv.startServer(scenario, variation, name=hostname):
			ok = cli.startClient()
			ok &= srv.unpause()
		return ok

	def startProxy(self, hostname, addr):
		if hostname not in Campaign._ee_nodes:
			return False
		Campaign._last_return_values[hostname] = None 
		info("start proxy to "+addr+" for "+hostname)
		srv = Campaign._ee_nodes[hostname]["server"]
		cli = Campaign._ee_nodes[hostname]["client"]
		ok = False
		if srv.startProxy(addr, hostname):
			ok = cli.startClient()
		return ok
	

if __name__ == "__main__":
#	try:
#		pyrohelper.get_nameserver()
#	except:
#		info("starting nameserver. This should not occure in productive environment. Run python3 -m Pyro4.naming")
	pyrohelper.start_nameserver()
	pyrohelper.host_named_server(Campaign, "Campaign", port=22813)

