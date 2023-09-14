#!/usr/bin/python3
"""
    Tabs: ships(servers), scenarios(campaign)
    ships:
        Status/Mission+Progress
        Unlocked Scenarios + Settings (add/del)
        Unlocked Ships (add/del)
        Additional Code (modify)
        Some score or so...
    scenarios
        (filename)
        Name
        Events -> unlocks + Settings
    every change saves to file
    every campaign change triggers refresh
"""
import PySimpleGUI as sg
import json
import pyrohelper
import Pyro4
import requests
from datetime import datetime

SCENARIO_DIR = "../../scripts-piglit/"
SHIP_TEMPLATES = [
        "Adder MK7",
        "Anvil",
        "Atlantis",
        "Benedict",
        "Crucible",
        "Flavia P.Falcon",
        "Hammer",
        "Hathcock",
        "Kiriya",
        "MP52 Hornet",
        "Maverick",
        "Nautilus",
        "Phobos M3P",
        "Piranha M5P",
        "Poseidon",
        "Repulse",
        "Ryu",
        "ZX-Lindworm",
    ]
SCENARIOS = [
        "00_basic", 
        "02_surrounded",
        "03_waves",
        "05_beacon",
        "06_edgeofspace",
        "07_gftp",
        "08_atlantis",
        "09_outpost",
        "20_training1",
        "21_training2",
        "22_training3",
        "23_training4",
        "24_training5",
        "25_training6",
        "50_gaps",
    ]


sg.set_options(font=("Arial Bold",14))

def error(msg, window=None):
    if window:
        window.hide()
    sg.Window("Error", [[sg.T("Error: "+msg)], [sg.B("OK")]]).read(close=True)
    if window:
        window.un_hide()

def confirm(msg, window=None):
    if window:
        window.hide()
    e,v = sg.Window("Confirm", [[sg.T(msg)], [sg.B("OK", key="ok"), sg.B("Cancel", key="cancel")]]).read(close=True)
    if window:
        window.un_hide()
    return e == "ok"

with open("serverDB.json", "r") as file:
    data = json.load(file)

def translate_scenario_name(scenario):
    try:
        with open(SCENARIO_DIR+"scenario_"+scenario+".lua", "r") as file:
            for line in file:
                if line.startswith("--") and "Name:" in line:
                    return line.split(":", maxsplit=1)[1].strip()
    except OSError:
        pass
    return scenario

def subWindowTimerEdit(window):
    window.hide()
    layoutTimerEdit = [
            [sg.Push(), sg.T("Round time:"), sg.Input(timerSource.getRoundTime()//60, size=4, key="timer.round_time"), sg.T("minutes")],
            [sg.Push(), sg.T("Pause time:"), sg.Input(timerSource.getPauseTime()//60, size=4, key="timer.pause_time"), sg.T("minutes")],
            [sg.B("OK", k="ok"), sg.B("Cancel", k="cancel")]
    ]
    windowTimerEdit = sg.Window("Edit timer", layoutTimerEdit, text_justification="r")
    while True:
        event2, values2 = windowTimerEdit.read()
        if event2 == "ok":
            try:
                round_time = int(values2["timer.round_time"])
                pause_time = int(values2["timer.pause_time"])
                timerSource.setRoundTime(60*round_time)
                timerSource.setPauseTime(60*pause_time)
            except:
                event2 = "error"
                error("Input must be a number", windowTimerEdit)
        if event2 in (sg.WIN_CLOSED, "cancel", "ok"):
            windowTimerEdit.close()
            window.un_hide()
            break
    return

def subWindowShipsEdit(parent, ship):
    parent.hide()
    avail = campaign.getShips(ship)
    layoutShipsEdit = [[
        sg.Column([[sg.T("Available ship types")],[sg.Listbox(sorted(avail), size=(20,10), k="delete.name")], [sg.B("Lock ship type", k="delete")]]),
        sg.Column([[sg.T("Locked ship types")], [sg.Listbox(sorted(set(SHIP_TEMPLATES)-set(avail)), k="add.name", size=(20,10))], [sg.B("Unlock ship type", k="add")]])],
        [sg.B("Close", k="close")]]
    window = sg.Window(f"Edit ships {ship}", layoutShipsEdit)
    while True:
        event2, values2 = window.read()
        if event2 == "delete":
            if len(values2["delete.name"]) != 1:
                error("No ship type selected", window)
            else:
                st = values2["delete.name"][0]
                if confirm(f"Remove {st} from available ship types for {ship}?", window):
                    campaign.lockShip(st, ship)
                    event2 = "close"
        elif event2 == "add":
            if len(values2["add.name"]) != 1:
                error("No ship type selected", window)
            else:
                st = values2["add.name"][0]
                if confirm(f"Make {st} available for {ship}?", window):
                    campaign.unlockShip(st, ship)
                    event2 = "close"
        if event2 in (sg.WIN_CLOSED, "close"):
            window.close()
            parent.un_hide()
            break
    return

def subWindowScenarios(parent, ship):
    parent.hide()
    avail = campaign.getScenarios(ship)
    layoutShipsEdit = [[
        sg.Column([[sg.T("Available missions")],[sg.Listbox(sorted(avail), size=(20,10), k="delete.name")], [sg.B("Lock mission", k="delete")]]),
        sg.Column([[sg.T("Locked missions")], [sg.Listbox(sorted(set(SCENARIOS)-set(avail)), k="add.name", size=(20,10))], [sg.B("Unlock mission", k="add")]])],
        [sg.B("Close", k="close")]]
    window = sg.Window(f"Edit scenarios {ship}", layoutShipsEdit)
    while True:
        event2, values2 = window.read()
        if event2 == "delete":
            if len(values2["delete.name"]) != 1:
                error("No scenario selected", window)
            else:
                st = values2["delete.name"][0]
                if confirm(f"Remove {st} from available missions for {ship}?", window):
                    campaign.lockScenario(st, ship)
                    event2 = "close"
        elif event2 == "add":
            if len(values2["add.name"]) != 1:
                error("No mission selected", window)
            else:
                st = values2["add.name"][0]
                if confirm(f"Make {st} available for {ship}?", window):
                    campaign.unlockScenario(st, ship)
                    event2 = "close"
        if event2 in (sg.WIN_CLOSED, "close"):
            window.close()
            parent.un_hide()
            break
    return

def subWindowShipSpawn(parent, ship):
    parent.hide()
    avail = campaign.getShips(ship)
    layoutShipSpawn=[
            [sg.T("Ship type"), sg.Listbox(sorted(avail), k="template", size=(20,5))],
            [sg.T("Password"), sg.In("", k="password")],
            [sg.Button("Spawn", k="ok"), sg.Button("Cancel", k="cancel")]
    ]
    window = sg.Window("Spawn ship", layoutShipSpawn, text_justification="r")
    while True:
        event2, values2 = window.read()
        if event2 == "ok":
            if len(values2["template"]) != 1:
                error("No ship type selected", window)
            else:
                code = campaign.getShipAdditionalCode(selection)
                script = f"""
                    ship = PlayerSpaceship()
                    ship:setCallSign("{ship}")
                    ship:setTemplate("{values2['template'][0]}")
                    ship:setControlCode("{values2['password']}")
                """ + code
                if confirmSpawn(window, script):
                    print(requests.get(f"http://127.0.0.1:8080/exec.lua", data=script).content)
        if event2 in (sg.WIN_CLOSED, "cancel", "ok"):
            window.close()
            parent.un_hide()
            break
    return

def confirmSpawn(parent, script):
    parent.hide()
    e,v = sg.Window("Confirm", [[sg.T("Spawn code (read only):")], [sg.Multiline(script, size=(80,20))], [sg.B("OK", key="ok"), sg.B("Cancel", key="cancel")]]).read(close=True)
    parent.un_hide()
    return e == "ok"


# Timer
timerSource = Pyro4.Proxy("PYRONAME:round_timer")
timerNow = [sg.T("Time:", size=6), sg.T("00:00:00", key="timer.now")]
timerRound = [sg.T("", key="timer.state", size=6), sg.T("", key="timer.left"), sg.T("", key="timer.until"), sg.B("Skip", key="timer.skip", visible=False), sg.B("Edit", key="timer.edit", visible=False)]

# Ship status list
campaign = Pyro4.Proxy("PYRONAME:campaign_state")
shipList = sg.Table([[]], key="shipList", headings=["Ship", "Status/Mission", "Progress"], enable_events=True,auto_size_columns=True, expand_x=True, expand_y=True, select_mode=sg.TABLE_SELECT_MODE_BROWSE)

# Ship details
shipDetails = [
    sg.Column(
        [[sg.T("Available missions:")], [sg.Listbox([], k="ship.scenarios", size=(20,10))], [sg.B("Edit", key="ship.scenarios.edit")]]),
    sg.Column(
        [[sg.T("Available ship types:")], [sg.Listbox([], k="ship.ships", size=(20,10))], [sg.B("Edit", key="ship.ships.edit")]]),
    sg.Column(
        [[sg.B("Delete selected ship", key="ship.delete")],[sg.B("Spawn ship", key="ship.spawn")]]
    )]

layout=[timerNow, timerRound, [shipList], shipDetails]
window=sg.Window("Flottenkommando", layout, size=(1200, 800), resizable=True, text_justification="r")
selection = None
selection_index = None
while True:
    event, values = window.read(timeout=1000)
    if event == sg.WIN_CLOSED:
       break
    elif event == "timer.skip":
        if confirm("Skip current phase?", window):
            timerSource.nextPhase()
    elif event == "timer.edit":
        subWindowTimerEdit(window)
    elif event == "__TIMEOUT__":
        # update shipList
        # note: this triggers event shipList, so use another branch.
        try:
            values = []
            selection_index = None
            for ship, status in campaign.getStatusAll().items():
                if "\t" in status:
                    mission, progress = status.split("\t", maxsplit=1)
                    values.append([ship, mission, progress])
                else:
                    values.append([ship, status])
                if ship == selection:
                    selection_index = len(values) -1
            if selection_index is not None:
                window["shipList"].update(values, select_rows=[selection_index])
            else:
                window["shipList"].update(values)
        except:
            window["shipList"].update([])
    elif event == "shipList":
        selection = values["shipList"]
        if selection:
            selection = window["shipList"].get()[selection[0]][0]
        try:
            scenarios = campaign.getScenarios(selection)
            scenarios = [translate_scenario_name(sc) for sc in scenarios]
            window["ship.scenarios"].update(scenarios)
            window["ship.ships"].update(campaign.getShips(selection))
        except:
            pass
    elif event == "ship.delete":
        if selection:
            if confirm(f"Delete {selection}?", window):
                campaign.deleteServer(selection)
                selection = None
                window["shipList"].update(select_rows=[])
                window.write_event_value("__TIMEOUT__", "")
        else:
            error("No ship selected", window)
    elif event == "ship.spawn":
        if selection:
            subWindowShipSpawn(window, selection)
        else:
            error("No ship selected", window)
    elif event == "ship.scenarios.edit":
        subWindowScenarios(window, selection)
    elif event == "ship.ships.edit":
        if not selection:
            error("no ship selected", window)
        else:
            subWindowShipsEdit(window, selection)
    else:
        print ("event:",event, "values:",values)

    # update timer
    try:
        t = timerSource.getTimer()
        window["timer.now"].update(t["now"])
        window["timer.state"].update(t["state"]+":")
        window["timer.left"].update(t["left"])
        window["timer.until"].update(f"({t['until']})")
        window["timer.state"].unhide_row()
        window["timer.skip"].update(visible=True)
        window["timer.edit"].update(visible=True)
    except:
        window["timer.now"].update(datetime.now().strftime("%H:%M:%S"))
        window["timer.state"].hide_row()
        window["timer.state"].update("")
        window["timer.left"].update("")
        window["timer.until"].update("")

