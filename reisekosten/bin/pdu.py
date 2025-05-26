#!/usr/bin/env python3
"""http interface for custom hardware.
	Custom reactor control hardware can send its status here.
	Needs python packages fastapi and uvicorn installed.
"""

from fastapi import FastAPI, Request
import uvicorn
import requests 
import json

SERVER = "192.168.115.236"
def _lua_exec(script):
	return requests.post(f'http://{SERVER}:8080/exec.lua', script).content == b''

app = FastAPI()

@app.post("/reactor_control")
async def reactor_control(request: Request):
	# for this to work, header "content-type" must be set to "application/json".
	j = await request.json()
	values = set_reactor_input(j)
	values = wrap_values_in_lua(values)
	script = f"""getScriptStorage()["player_ships_util"].set_pdu{values}"""
	_lua_exec(script)

@app.post("/pingpost")
async def ping():
	pass

def wrap_values_in_lua(values):
	rets = [ k + " = " + json.dumps(v) for k,v in values.items() ]
	rets = ", ".join(rets)
	return "{" + rets + "}"

def set_reactor_input(data):
	# in
	sim = int(data['PDU_ID'].split("_")[1])
	active = (data['PDU'] == 'ACTIVE')
	boost_power = data['Power Boost']
	boost_coolant = data['Coolant Boost']
	consumption_shields = data['Shields']
	consumption_drives = data['Drives']
	consumption_weapons = data['Weapons']

	tuner = data['Tuner']
	if tuner == "NONE":
		tuner = 0
	else:
		tuner = int(tuner.split(" ")[1])

	boost_factor = 2
	if tuner == 1:
		# boost inverter
		boost_factor = 0.5
		# rotate power distribution
		consumption_shields, consumption_drives, consumption_weapons = consumption_drives, consumption_weapons, consumption_shields
	elif tuner == 2:
		# lock energy after reaching 200%
		pass
	elif tuner == 3:
		# halleluja - locks all power settings, when system gets damage
		pass

	default_rate = 0.3
	default_cool = 1.2
	# default values
	output = {
		"faction": f"Transport{sim}",
		"weapons_rate": default_rate,
		"weapons_cool": default_cool,
		"weapons_consume": 3,
		"drive_rate": default_rate,
		"drive_cool": default_cool,
		"drive_consume": 4,
		"shields_rate": default_rate,
		"shields_cool": default_cool,
		"shields_consume": 5,
		"tuner": tuner,
		"active": active,
		"error": "",
		"warning": "",
		"note": "",
		"note2": "",
	}

	# modify output
	if not active:
		output["weapons_rate"] = 0
		output["drive_rate"] = 0
		output["shields_rate"] = 0
		output["error"] = "Main line not connected"
		output["note"] = "Energy distribution not possible"
	else:
		if consumption_drives == 0:
			output["drive_rate"] = 0
			output["error"] = "Drive line not connected"
			output["note"] = "No power distribution"
		elif consumption_shields == 0:
			output["shields_rate"] = 0
			output["error"] = "Shield line not connected"
			output["note"] = "No power distribution"
		elif consumption_weapons == 0:
			output["weapons_rate"] = 0
			output["error"] = "Weapon line not connected"
			output["note"] = "No power distribution"
		else:
			output["drive_consume"] = consumption_drives
			output["shields_consume"] = consumption_shields
			output["weapons_consume"] = consumption_weapons
			if boost_power == "WEAPONS":
				output["weapons_rate"] = default_rate * boost_factor
				output["note"] += "weapons rate"
			if boost_power == "DRIVES":
				output["drive_rate"] = default_rate * boost_factor
				output["note"] += "drives rate"
			if boost_power == "SHIELDS":
				output["shields_rate"] = default_rate * boost_factor
				output["note"] += "shields rate"
			if boost_coolant == "WEAPONS":
				output["weapons_cool"] = default_cool * boost_factor
				output["note2"] += "weapons coolant"
			if boost_coolant == "DRIVES":
				output["drive_cool"] = default_cool * boost_factor
				output["note2"] += "drives coolant"
			if boost_coolant == "SHIELDS":
				output["shields_cool"] = default_cool * boost_factor
				output["note2"] += "shields coolant"
			if boost_coolant != "NONE" or boost_power != "NONE":
				output["warning"] = "System overclocked"
			elif consumption_drives != 4 or consumption_shields != 5 or consumption_weapons != 3:
				output["warning"] = "Non-standard energy consumption"
	return output

def test_set_reactor_input():
	#PDU_ID ist die von der Kiste. 1 oder 2.
	#Tuner ist der kleine Hack/Turbo/Stöpsel Dingens. Der macht sonst an den Werten nix. Gibt's in NONE, Type(1-3).
	#PDU ACTIVE/OFF. Ob die Energieversorgung überhaupt funktioniert (das schalte ich OFF, wenn die beiden Input Kabel falsch oder gar nicht stecken)
	#Power/Coolant Boost gibt's in NONE oder SHIELDS/DRIVES/WEAPONS. Damit wollten wir dann die flow rate erhöhen.
	#Shields/drives/weapons gibt's in (0, 3,4,5) und gibt't wieder, an welchem der drei "Power outputs" das jeweilige System angestöpselt ist.
	data = {
		'PDU_ID': 'PDU_1',
		'Tuner': 'TYPE 3',
		'PDU': 'ACTIVE',
		'Power Boost': 'SHIELDS',
		'Coolant Boost': 'SHIELDS',
		'Shields': 5,
		'Drives': 3,
		'Weapons': 4
	}
	set_reactor_input(data)
	data = {
		'PDU_ID': 'PDU_2',
		'Tuner': 'TYPE 3',
		'PDU': 'OFF',
		'Power Boost': 'NONE',
		'Coolant Boost': 'NONE',
		'Shields': 5,
		'Drives': 3,
		'Weapons': 4
	}
	set_reactor_input(data)

if __name__ == "__main__":
	uvicorn.run("pdu:app", host="127.0.0.1", port=9001, reload=True)
	
	# Test (from outside of this script)
	# requests.post("http://127.0.0.1:9001/reactor_control", json={"mode": "test", "data": {"something_nested": "a", "something_else": "b"}}).json()

