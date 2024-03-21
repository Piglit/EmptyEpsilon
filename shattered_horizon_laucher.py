#!/usr/bin/env python3

#apt install python3-dialog python3-requests

from dialog import Dialog
import subprocess
import requests
import time
import random
import os

cwd = os.getcwd()
os.chdir("/dev/shm")    # hack to enable tempdir


playerships = {
    "Artful Dodger":        ("Y2K",         "Leanti Meva's Y2K Transport"),
    "Black Bantha":         ("YV-330",      "Ome Sennyd's YV-330 Transport"),
    "Bluewing":             ("U-Wing",      "Ric Halcard's U-Wing Fighter"),
    "Crate Dragon":         ("YT-2000",     "Rogan Corrs' YT-2000 Transport"),
    "Cropdust Nomad":       ("Gozanti",     "Kell Murtry's Gozanti Cruiser"),
    "Dancer":               ("YT-2400",     "Reto's YT-2400 Transport"),
    "Drexl":                ("Lambda T-4a", "Treuton Otro and Endira Vask's Lambda Shuttle"),
    "Greedy Wampa":         ("GR-75",       "~Caro~'s GR-75 Freighter"),  #TODO find out character name
    "Lonestar":             ("Kuat D7",     "Kolt's Kuat D7 Patrol"),
    "Lunaris":              ("YT-2400",     "Caex Vanta's YT-2400 Transport"),
    "Nova Crow":            ("YT-2000",     "Veeza Tosh's YT-2000 Transport"),
    "Ronin":                ("Action IV",   "Draic FeenX' Action IV Freighter"),  #TODO find out character name
    "Schiffy McSchiffface": ("KvK-P0001",   "Kit Kol's KvK-Fighter"),
    "Sicaria":              ("A-24",        "Viveca Torra's A-24 Sleuth Scout"),
    "Steelin' Ivy":         ("YV-929",      "Vada Pav's YV-929 Transport"),
    "Vengeance":            ("StarViper",   "Fenn Barlors' Star Viper Fighter"),
    "Winner":               (" X-Wing",     "Generic X-Wing"),
    "Xylon":                ("G9",          "Generic G9 for the syndicate"),
    "Yaq":                  ("Lambda T-4a", "Generic Lambda for the empire"),
    "Zoomer":               ("UT-60D",      "Generic U-Wing for the republic"),
}

scenarios = [
    ("Training",            "Training scenario for new players"),
    ("Shattered Horizon",   "The main scenario"),
    ("Test",                "Scenario to test ships"),
    ("None",                "Use the in-game scenario selection")
]

scenario_files = {
    "Training":             "scenario_20_training1.lua", 
    "Shattered Horizon":    "scenario_80_shattered_horizon.lua",
    "Test":                 "scenario_10_empty.lua",
    "None":                 ""
}

def menu():
    d = Dialog(autowidgetsize=True)

    def abort():
        d.clear()
        exit(0)

    # Select participating ships
    avail_ships = [(cs, t[1], 0) for cs,t in playerships.items()]
    code, callsigns = d.checklist("Select all ships for this scenario.\nUse arrow keys and space to select.\nPress Enter to continue.", title="Shattered Horizon Launcher", choices=avail_ships)
    if code != d.OK:
        abort()

    # Select primary ship
    if len(callsigns) > 1:
        choices = [(cs, playerships[cs][1]) for cs in callsigns]
        code, primary = d.menu("Select the primary ship.\nAll other ships are considered escort ships.", title="Shattered Horizon Launcher", choices=choices)
        if code != d.OK:
            abort()
        callsigns.remove(primary)
        callsigns = [primary] + callsigns

    script = "".join([spawn(cs, playerships[cs][0], i) for i, cs in enumerate(callsigns)])

    code, scenario = d.menu("Select a scenario:", title="Shattered Horizon Launcher", choices=scenarios)
    if code != d.OK:
        abort()
    scenario_file = scenario_files[scenario]

    d.clear()
    return script, scenario_file

def _lua_exec(script):
    return requests.post('http://127.0.0.1:8080/exec.lua', script).content == b''

def spawn(callsign, template, offset):
    faction = "Transport" if offset == 0 else "Escort"
    cs = template[0] + callsign[0] + "-" + str(10+len(callsign))
    script = f"""
        ship = PlayerSpaceship()
        rotation = 0
        pos = {-offset*200}
        ship:setRotation(rotation)
        ship:commandTargetRotation(rotation)
        ship:setTemplate("{template}")
        ship:setCallSign("{cs}")
        ship:setDescription("{callsign}")
        ship:setFaction("{faction}")
        ship:setCanBeDestroyed(false)
    """
    return script
#    return _lua_exec(script)

while True:
    spawn_script, scenario_file = menu()
    if scenario_file == "scenario_80_shattered_horizon.lua":
        paused = 0
    else:
        paused = 1
    cmd = ["./EmptyEpsilon", f"server_scenario={scenario_file}", "httpserver=8080", "autoconnect=0", "autoconnectship=", "autoconnect_address=", f"startpaused={paused}"]
    os.chdir(cwd)
    ee = subprocess.Popen(cmd)
    time.sleep(1)

    _lua_exec(spawn_script)
    ee.communicate()
    input("press enter to restart")
