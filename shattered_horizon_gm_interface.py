#!/usr/bin/env python3

#apt install python3-dialog python3-requests

from dialog import Dialog

import pyrohelper
import requests

rk = None

SERVER = "192.168.115.250"

def _lua_exec(script):
	return requests.post(f'http://{SERVER}:8080/exec.lua', script).content == b''

playerships = {
	"Artful Dodger":			("Y2K",			"Leichter corellianischer Y2K Peregrine Frachter von Leanti Meva"),
	"Batnor Senaar":			("C70",			"Umgebauter Consular Charger C70 Retrifit von Mirsh Beskaryc"),
	"Beacon of Civility":		("CSS-1",		"Corellian Star Shuttle von Xiphias Talexecum"),
	"Beacon Runner":			("EML-850",		"Ziviles Rettungsschiff EML-850 von Dalen Voss"),
	"Black Bantha":				("YV-330",		"YV-330 Frachter von Sorc"),
	"Calamity":					("Gozanti",		"Gozanti Cruiser von Lt. Adrien"),
	"Cribania":					("Gozanti C-ROC","C-ROC Gozanti Cruiser von Valen Andrian Serris"),
	"Cropdust Nomad":			("Gozanti ",		"Gozanti Cruiser von Kell Murtry"),
	"Drexl":					("Lambda T-4a ",	"Lambda Shuttle von Endira Vask und Treuton Otro"),
	"Elza":						("DX-9",			"Umgebauter DX-9 Stormtrooper Transport von Andan Hearch"),
	"Greedy Wampa":				("GR-75",		"Umgebauter GR-75 Frachter von Kei Prine"),
	"Harlekin":					("Allanar N3",	"Leichter Allanar N3 Frachter von Viveka Torra"),
	"Hinterhand":				("UT-60D",		"UT-60D U-Wing von Tiv Ohan"),
	"Kyr'yc Laar":				("ARC-170",		"Aggressive-ReConnaisance Fighter von Kali Myk"),
	"Last Dawn":				("Peregrine yacht",	"Peregrin-Klasse Raumjacht von Atenbi"),
	"Crimson Thunder":			("Peregrine yacht",	"Peregrin-Klasse Raumjacht von Atenbi"),
	"Lightning":				("Sheathipede",	"Sheathipede von Endor Sky Marshal Ran Korra"),
	"Miss Understanding":		("HWK-1000",		"Leichter Frachter HWK-1000 von Varik Jeroos"),
	"Parsec Twister":			("EML-850",		"Leichter Frachter EML-850 von Kito Sivora"),
	"Rho-1":					("TIE-Interceptor",	"TIE-Interceptor der Rho-Staffel"),
	"Rho-2":					("TIE-Interceptor",	"TIE-Interceptor der Rho-Staffel"),
	"Rho-3":					("TIE-Interceptor",	"TIE-Interceptor der Rho-Staffel"),
	"Rho-4":					("TIE-Interceptor",	"TIE-Interceptor der Rho-Staffel"),
	"Ronin":					("Action IV",	"Modifizierter Action IV Frachter von Draic FeenX Professional Services"),
	"Sapphire":					("GX1  ",		"GX1 Short Hauler von Aurora Var'Rel"),
	"Second Chance":			("G9",			"Ein C9 Auslegefrachter von Slow Moe Jive"),
	"Sicaria":					("A-24",			"A-24 Sleuth Scout von Viveka Torra"),
	"Still Moving":				("GX1 ",			"GX1 Short Hauler von Korrun Khell und Rovan Tesk"),
	"TIE/rp 7901":				("TIE-Reaper",	"TIE Reaper Attack Lander von Ron Jelran"),
	"Thunderbolt":				("VCX-100",		"VCX-100 von Dash Meero"),
	"Udesla":					("YT-1300-B",	"Corellianischer leichter Frachter YT-1300-B von Mn'Taru und Jin-Tetsu"),
	"Vengence":					("StarViper",	"Star Viper Angriffsjäger von Fenn Bralor"),
	"Vigilant":					("UT-60D",		"UT-60D U-Wing von Kalen Dorn"),
	"VV-Frightning":			("Lambda T-4a",	"Lambda Shuttle von Val'Kinor"),
	"XW-65":					("X-Wing",		"T-65B X-Wing von Tiv Ohan"),
	"Xylon":					("G9",			"Eine G9 von Crimson Dawn"),
	"H.I.V.E.":					("Lambda T-4a",	"Lambda Shuttle des Galaktischen Imperiums"),
	"Zoomer":					("UT-60D",		"Ein U-Wing der Neuen Republik"),
}

STATIONS = {
	"0": "nothing",
	"1": "helms",
	"2": "weapons",
	"3": "engineering",
	"4": "science",
	"5": "relay",
	"6": "tactical",
	"7": "engineeringAdvanced",
	"8": "operations",
	"9": "singlePilot",
	"10": "damageControl",
	"11": "powerManagement",
	"12": "databaseView",
	"13": "altRelay",
	"14": "commsOnly",
	"15": "shipLog",
	"16": "mainscreen",
    "17": "window:0",
}
SIMULATORS = [
	("1", "Simulator 1, Wasserhaus"),
	("2", "Simulator 2, Energiehaus"),
	("3", "Simulator 3, Wasserhaus - Shuttle"),
	("4", "Simulator 4, Energiehaus - Fighters"),
]

# TODO add ips of each simulator station here (must be ips, not hostnames)
SIMULATOR_STATIONS = {
	1:	["192.168.115.241", "192.168.115.242", "192.168.115.243", "192.168.115.244"],
	2:	["192.168.115.223", "192.168.115.224", "192.168.115.225", "192.168.115.227"],
	3:	["192.168.115.142", "192.168.115.142"],
	4:	["192.168.115.133", "192.168.115.86"],
}

def get_client(ip):
	# may raise exception, you should catch it
	return pyrohelper.connect(f"PYRO:launcher@{ip}:7999")

def command_to_simulator(simulator: int, commands):
	ok = True
	msg = ""
	for ip in SIMULATOR_STATIONS[simulator]:
		try:
			get_client(ip).startEE(commands)
		except Exception as e:
			msg += str(e) + "\n"
			ok = False
	return ok, msg

d = Dialog(autowidgetsize=True)
def abort():
	d.clear()
	exit(0)

def menu():
	code, simulator = d.menu("Select a simulator", title="Shattered Horizon Launcher", choices=SIMULATORS)
	if code != d.OK:
		abort()
	simulator = int(simulator)

	# Select what to do
	actions = [
		("1", "Configure Ship"),
		("2", "Configure Stations"),
#		("3", "Add income"),
	]
	code, action = d.menu("Select an action", title="Shattered Horizon Launcher", choices=actions)
	if code != d.OK:
		abort()

	if action == "1":
		configure_ship(simulator)
	elif action == "2":
		configure_stations(simulator)
	elif action == "3":
		global rk
		if not rk:
			rk = pyrohelper.connect_to_named("rk_server")
		if rk.ping():
			shipselection()
		else:
			d.msg("no connection to Reisekosten-server")

def configure_ship(simulator):
	# Select participating ships
	avail_ships = [(name, t[1]) for name,t in playerships.items()]
	code, shipname = d.menu(f"Select a ship for simulator {simulator}.", title="Shattered Horizon Launcher", choices=avail_ships)
	if code != d.OK:
		return
	template, description = playerships[shipname]

	actions = [
		("1", "Restart all stations with tutorial with this ship", False),
		("2", "Spawn ship on server", False),
		("3", "Restart all stations without tutorial", False),
		("4", "Start repairing ship", False),
		("5", "Stop repairing ship", False),
		("6", "Set start time (CIC-Display)", False),
	]
	while True:
		code, actions_chosen = d.checklist(f"Select actions (multiple are possible).", title="Shattered Horizon Launcher", choices=actions)
		if code != d.OK:
			return

		if not actions_chosen:
			d.msgbox("No actions selected!")
			continue

		command = []	
		if "1" in actions_chosen:
			callsign = template[0] + shipname[0] + "-" + str(10+len(shipname))
			command = [f'tutorial_ship={template}', f'tutorial_callsign={callsign}', "tutorial=pfc"]
		if "2" in actions_chosen:
			script = f"""getScriptStorage()["player_ships_util"]:spawn_player_ship("{shipname}", "{template}", "{description}", "Transport{simulator}")"""
			code = d.yesno(f"Spawning {template} {shipname} in simulator {simulator}")
			if code == d.OK:
				d.clear()
				if not _lua_exec(script):
					exit(1)
		if "3" in actions_chosen:
			command =["tutorial="]
		if "1" in actions_chosen or "3" in actions_chosen:
			# restart clients
			d.yesno(f"Restarting all clients in simulator {simulator}")
			if code == d.OK:
				command += [f"autoconnectship=faction=Transport{simulator}"]
				ok, msg = command_to_simulator(simulator, command)
				if not ok:
					d.msgbox(msg)
		if "4" in actions_chosen:
			script = f"""getScriptStorage()["player_ships_util"]:startRepair("{shipname}")"""
			code = d.yesno(f"Start repairing {template} {shipname} in simulator {simulator}")
			if code == d.OK:
				d.clear()
				if not _lua_exec(script):
					exit(1)
		if "5" in actions_chosen:
			script = f"""getScriptStorage()["player_ships_util"]:stopRepair("{shipname}")"""
			code = d.yesno(f"Stop repairing {template} {shipname} in simulator {simulator}")
			if code == d.OK:
				d.clear()
				if not _lua_exec(script):
					exit(1)
		if "6" in actions_chosen:
			sim_str = ""
			if simulator == 1:
				sim_str = "von LZ blau"
			if simulator == 2:
				sim_str = "von LZ rot"
			code, time = d.inputbox(f"Startzeit {shipname} {sim_str}\n(must be int (e.g. 1400)\nSet to 0 to clear the list of starts.")
			if code == d.OK:
				d.clear()
				try:
					time=int(time)
				except:
					d.messagebox("Invalid time format (must be int). Start time not set")
					return
				if time == 0:
					for sim in range(49,55):
						script = f"""getScriptStorage()["plot_shattered_cic"]:set_infos(nil, {sim}, "")"""
						if not _lua_exec(script):
							exit(1)
				else:
					msg = f"{time}: {shipname} {sim_str}"
					script = f"""getScriptStorage()["plot_shattered_cic"]:set_infos(nil, 50+{simulator}, "{msg}")"""
					if not _lua_exec(script):
						exit(1)
					script = f"""getScriptStorage()["plot_shattered_cic"]:set_infos(nil, 50, "Anstehende Starts:")"""
					if not _lua_exec(script):
						exit(1)
					script = f"""getScriptStorage()["plot_shattered_cic"]:set_infos(nil, 49, " ")"""
					if not _lua_exec(script):
						exit(1)
		return
	
def configure_stations(simulator):
	while True:
		choices = []
		for ip in SIMULATOR_STATIONS[simulator]:
			print(f"connecting to PYRO:launcher@{ip}:7999")
			try:
				client = get_client(ip)
				choices.append((ip, "currently " + client.get_station()))
			except:
				continue
		code, client = d.menu(f"Select a client in simulator {simulator}", title="Shattered Horizon Launcher", choices=choices)
		if code != d.OK:
			return
		client = get_client(client)	# is not pyro proxy

		while True:
			actions = [
				("1", "Restart with tutorial"),
				("2", "Restart without tutorial"),
				("3", "Change station"),
			]
			code, action = d.menu("Select an action", title="Shattered Horizon Launcher", choices=actions)
			if code != d.OK:
				break
			if action == "1":
				client.startEE(["tutorial=pfc"])
				d.msgbox("Restarted client.")
				break
			if action == "2":
				client.startEE(["tutorial="])
				d.msgbox("Restarted client.")
				break
			if action == "3":
				code, station= d.menu("Select a station", title="Shattered Horizon Launcher", choices=[(id, descr) for id,descr in STATIONS.items()])
				if code != d.OK:
					break
				station = STATIONS[station]
				client.set_station(station)
				d.msgbox("Client configuration changed. Client is restarted.")

def shipselection():
	d.infobox("Loading...")
	ships = rk.get_ships(with_income = True)
	selectable_ships = [(cs, "{type} {name} ({income} credits)".format(**reg)) for cs,reg in ships.items()]
	selectable_ships.append(("refresh", "Refresh this list"))

	code, callsign = d.menu("Select a ship to modify it's income.\nIf ships work together, bot only one gets payed, split the income: Escort ships get one third, Fighters one fourth of the total income.\n\nUse arrow keys to navigate.\nPress Enter to continue.", title="GM-Interface", choices=selectable_ships)
	if code != d.OK:
		abort()
	elif callsign == "refresh":
		return
	else:
		incomemodify(callsign, ships[callsign])

def incomemodify(callsign, reg):
	d.infobox("Loading...")
	inc = abs(rk.get_ship_income(callsign))
	while True:
		code, inc = d.inputbox("Ship: " + callsign + " - {type} {name}\nNote: {note}".format(**reg) + "\n\nEnter new income.\nBasic math operations are supported.\nPress Enter to continue.\nPress Escape to abort.", title="GM-Interface", init=str(inc))
		if code != d.OK:
			return
		try:
			# DANGER: eval user input! You must trust the user here!
			inc_evaluated = eval(inc)
			if isinstance(inc_evaluated, float):
				inc_evaluated = int(inc_evaluated)
			assert isinstance(inc_evaluated, int)
			assert inc_evaluated >= 0
			code = d.yesno("Set the income of " + callsign + " {type} {name}".format(**reg) + " to " + str(inc_evaluated) + " credits?")
			while code == d.OK:
				code, tag = d.radiolist("Wie erfolgt die Auszahlung?", choices=[
					("+", "Haupt-Crew wurde bar bezahlt", False),
					("-", "Crew(s) wird von Hafenmeisterei ausbezahlt", False),
				])
				if code != d.OK:
					break
				if tag == "-":
					inc_evaluated = -inc_evaluated
				if tag in ["+", "-"]:
					d.infobox("Uploading...")
					rk.set_ship_income(callsign, inc_evaluated)
					return
		except:
			d.msgbox("Error: could not evaluate your input.")






while True:
	menu()

#import subprocess
#import time
#import random
#import os

#cwd = os.getcwd()
#os.chdir("/dev/shm")	# hack to enable tempdir

#scenarios = [
#	("Training",			"Training scenario for new players"),
#	("Shattered Horizon",   "The main scenario"),
#	("Test",				"Scenario to test ships"),
#	("None",				"Use the in-game scenario selection")
#]
#
#scenario_files = {
#	"Training":			 "scenario_20_training1.lua", 
#	"Shattered Horizon":	"scenario_80_shattered_horizon.lua",
#	"Test":				 "scenario_10_empty.lua",
#	"None":				 ""
#}

#	# Select primary ship
#	if len(callsigns) > 1:
#		choices = [(cs, playerships[cs][1]) for cs in callsigns]
#		code, primary = d.menu("Select the primary ship.\nAll other ships are considered escort ships.", title="Shattered Horizon Launcher", choices=choices)
#		if code != d.OK:
#			abort()
#		callsigns.remove(primary)
#		callsigns = [primary] + callsigns
#
#	script = "".join([spawn(cs, playerships[cs][0], i) for i, cs in enumerate(callsigns)])
#
#	code, scenario = d.menu("Select a scenario:", title="Shattered Horizon Launcher", choices=scenarios)
#	if code != d.OK:
#		abort()
#	scenario_file = scenario_files[scenario]
#
#	d.clear()
#	return script, scenario_file



#def spawn(callsign, template, offset):
#	faction = "Transport" if offset == 0 else "Escort"
#	cs = template[0] + callsign[0] + "-" + str(10+len(callsign))
#	script = f"""
#		ship = PlayerSpaceship()
#		rotation = 0
#		pos = {-offset*200}
#		ship:setRotation(rotation)
#		ship:commandTargetRotation(rotation)
#		ship:setTemplate("{template}")
#		ship:setCallSign("{cs}")
#		ship:setDescription("{callsign}")
#		ship:setFaction("{faction}")
#		ship:setCanBeDestroyed(false)
#	"""
#	return script
#	return _lua_exec(script)



#	spawn_script, scenario_file = menu()
#	if scenario_file == "scenario_80_shattered_horizon.lua":
#		paused = 0
#	else:
#		paused = 1
#	cmd = ["./EmptyEpsilon", f"server_scenario={scenario_file}", "httpserver=8080", "autoconnect=0", "autoconnectship=", "autoconnect_address=", f"startpaused={paused}"]
#	os.chdir(cwd)
#	ee = subprocess.Popen(cmd)
#	time.sleep(1)
#
#	_lua_exec(spawn_script)
#	ee.communicate()
#	input("press enter to restart")
