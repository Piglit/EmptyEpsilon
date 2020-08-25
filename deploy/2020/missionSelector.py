#!/usr/bin/python3

import PySimpleGUI as sg
import Pyro4
import pyrohelper
import socket
import time

LOADING_ANIMATION = "loading.gif"

campaign = pyrohelper.connect_to_named("Campaign")
hostname = socket.gethostname()
shipname = hostname[0].upper()+hostname[1:]

def missionSelect():
	try:
		campaign.ping()
	except (Pyro4.errors.ConnectionClosedError, Pyro4.errors.ProtocolError):
		campaign._pyroReconnect()

	missions = campaign.getMissionsFor(hostname)
	missionNames = []
	missionsByName = {}
	for mission in missions:
		missionNames.append(mission["name"])
		missionsByName[mission["name"]] = mission
	mission = missionsByName[missionNames[0]]["id"]

	a = sg.T("Schiff: "+shipname)
	b = sg.T("Missionsauswahl")
	c = sg.Listbox(missionNames, key="mission_select", size=(20,len(missions)), enable_events=True, select_mode="LISTBOX_SELECT_MODE_SINGLE")
	d = sg.T("Schiffstyp: "+missions[mission]["shipType"], size=(45,1), key="type")
	e = sg.T("Missionsbeschreibung:")
	brief = "\n".join(missions[mission]["briefing"]) + missions[mission].get("variation brief","")
	f = sg.Multiline(brief, size=(45,10), key="brief")
	o = sg.OK()
	layout = [[a],[b],[c],[d],[e],[f],[o]]

	window = sg.Window("Missionsauswahl", layout)

	while True:
		event, values = window.read()
		print("EVENT: "+str(event) + ": " + str(values))
		if "mission_select" in values:
			#user selected something
			key = values["mission_select"]
			if key and key[0] in missionsByName:
				mission = missionsByName[key[0]]["id"]
				window["type"].update("Schiffstyp: "+missions[mission]["shipType"])
				brief = "\n".join(missions[mission]["briefing"]) + missions[mission].get("variation brief","")
				window["brief"].update(brief)
		if event == "OK":
			window.close()
			print("starting "+mission)
			return waitForServer(mission)
		elif event in ["Exit", sg.WIN_CLOSED]:
			return

		
def waitForServer(mission):
	campaign.startMissionFor(hostname, mission)
	time.sleep(0.5)
	timeout = 0
	while True:
		status = campaign.getReturnValueFor(hostname)
		if status is None:
			sg.PopupAnimated(LOADING_ANIMATION, title="transmitting data...", message="starte Server...")
			time.sleep(0.5)
		elif status == "pending":
			sg.PopupAnimated(LOADING_ANIMATION, title="transmitting data...", message="starte Server...")
			time.sleep(0.5)
		elif status == True:
			sg.PopupAnimated(None)
			break
		elif isinstance(status, int):
			timeout = status + 2 
			while timeout >= 0:
				sg.PopupAnimated(LOADING_ANIMATION, title="transmitting data...", message="starte Server in "+str(timeout)+"s. (warte auf Socket)")
				time.sleep(0.5)
				timeout -= 0.5
			sg.PopupAnimated(None)
			campaign.startMissionFor(hostname, mission)
			time.sleep(1)
		else:
			print("error")
			sg.PopupAnimated(None)
			sg.PopupOK("Ein Fehler ist aufgetreten...")
			return missionSelect() 
	return controlPanel(mission)
	
def controlPanel(mission):
	a = sg.T("Server läuft.")
	b = sg.T("Verbindet euch mit '"+hostname+"' ("+pyrohelper.get_ip()+").")
	c = sg.Button("Pause beenden", key="pause")
	e = sg.Button("Mission beenden", key="abort")
	layout = [[a], [b], [c], [e]]
	window = sg.Window("Server Control Panel", layout)
	while True:
		event, values = window.read()
		if event == "pause":
			campaign.unpauseFor(hostname)
		elif event == "abort":
			campaign.justStop(hostname)
			window.close()
			return missionSelect() 
		elif event in ["Exit", sg.WIN_CLOSED]:
			return
	
campaign.justStop(hostname)
missionSelect()	
