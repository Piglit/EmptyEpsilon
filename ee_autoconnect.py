#!/usr/bin/env python3

from dialog import Dialog
import subprocess

SERVER = "192.168.115.236"    # TODO adjust

d = Dialog(autowidgetsize=True)

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
subprocess.run(command)

