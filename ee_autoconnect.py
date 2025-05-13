#!/usr/bin/env python3
"""This launcher is started on each client and starts EE.
It can be called over network to restart clients with certain options.
"""


import subprocess
import os
import sys
import pyrohelper
import Pyro4
import atexit
if os.environ["EE_SERVER"]:
	SERVER = os.environ["EE_SERVER"]
else:
	SERVER = "192.168.115.236"

TEST=False

@Pyro4.expose
class EELauncher:
	__CONFIG_PATH = "~/.emptyepsilon/"
	def __init__(self):
		self.ip = pyrohelper.get_ip()
		self.simulator = 0
		self.station = "default"
		self.child = None
		if not os.path.exists("~/.emptyepsilon/NO_AUTO_START"):
			self.child = subprocess.Popen(["./EmptyEpsilon", f"autoconnect_address={SERVER}"])

	def get_simulator(self):
		return self.simulator

	def set_simulator(self, simulator:int):
		self.simulator = simulator
		self.stopEE()	# EE writes config at stop, so stop before change
		self.setConfigItem("autoconnectship", "faction=Transport{simulator}")
		self.startEE([])

	def get_station(self):
		if self.station != "default":
			return self.station
		else:
			return self.getConfigItem("autoconnect")

	def set_station(self, station:str):
		self.station = station
		self.stopEE()	# EE writes config at stop, so stop before change
		self.setConfigItem("autoconnect", station)
		self.startEE([])

	def startEE(self, args:list[str]):
		command = ["./EmptyEpsilon"] + args
		if TEST:
			# Default commands should be in config, since command line overwrites config
			command += ["autoconnect=operations", "language=de", "httpserver=8080", f"autoconnect_address={SERVER}"] #"tutorial=pfc"
		if self.child:
			self.stopEE()
		print(command)
		self.child = subprocess.Popen(command)

	def stopEE(self):
		if not self.child:
			return
		self.child.terminate()
		self.child.wait()


	def setConfigItem(self, key, value):
		"""set a config option until the pc reboots. For permanent settings, write it to the config file on the server."""
		self._replaceInIni(key, value)

	def getConfigItem(self, key):
		lines = []
		try:
			with open(self._getIniFilename(), "rt") as f:
				for line in f:
				   if line.split("=")[0].strip() == key:
					   return line.split("=")[1].strip()
		except IOError:
			pass
		return ""

	def _getIniFilename(self):
		return "/home/user/.emptyepsilon/options.ini"
		# try if this is writable on overlayfs - otherwise use this clients specific ini file

	def _replaceInIni(self, key, value):
		lines = []
		try:
			f = open(self._getIniFilename(), "rt")
			for line in f:
			   if line.split("=")[0].strip() != key:
				   lines.append(line)
			f.close()
		except IOError:
			pass
		lines.append("%s=%s\n" % (key, value))
		f = open(self._getIniFilename(), "wt")
		for line in lines:
			f.write(line)
		f.close()

	def ping(self):
		return True

eel = EELauncher()

def on_exit():
	eel.stopEE()

if __name__ == "__main__":
	uri = pyrohelper.host(eel, 7999, "launcher")
	print(uri)
	atexit.register(on_exit)

stations = [
	("0", "nothing"),
	("1", "helms"),
	("2", "weapons"),
	("3", "engineering"),
	("4", "science"),
	("5", "relay"),
	("6", "tactical"),
	("7", "engineeringAdvanced"),
	("8", "operations"),
	("9", "singlePilot"),
	("10", "damageControl"),
	("11", "powerManagement"),
	("12", "databaseView"),
	("13", "altRelay"),
	("14", "commsOnly"),
	("15", "shipLog"),
]

factions = [
	("FC-03", "Tantal 3 Flight Control"),
	("Tantal-3", "Tantal 3 Ground Control"),
	("Transport", "Main transport craft"),
	("Escort", "Escort ship"),
	("None", "None")
]



def launch_command_from_dialog():
	from dialog import Dialog

	d = Dialog(autowidgetsize=True)
	code, station = d.menu("Select station:", title="Ship Connector", choices=stations)
	if code != d.OK:
		d.clear()
		exit(0)

	code, faction = d.menu("Select ship:", title="Ship Connector", choices=factions)
	if code != d.OK:
		d.clear()
		exit(0)

	if faction not in ["FC-03", "Tantal-3"]:
		if faction == "None":
			acs = f""
		else:
			acs = f"solo;faction={faction}"
	else:
		acs = f"callsign={faction}"

	command = ["./EmptyEpsilon", "server_scenario=", "httpserver=", f"autoconnect={station}", f"autoconnectship={acs}", f"autoconnect_address={SERVER}"]
	d.clear()
	return command

#subprocess.run(launch_command_from_dialog())

