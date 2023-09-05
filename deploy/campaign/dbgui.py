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
from datetime import datetime

SCENARIO_DIR = "../../scripts-piglit/"

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

def subWindowShipsEdit(window, selection):
    window.hide()
    avail = campaign.getShips(selection)
    layoutShipsEdit = [[sg.Listbox(avail, size=(20,10)), sg.B("Delete selected", k="delete")], [sg.Input("", k="add.name", size=20), sg.B("Add new ship", k="add")], [sg.B("Close", k="close")]]
    windowShipsEdit = sg.Window(f"Edit ships {selection}", layoutShipsEdit)
    while True:
        event2, values2 = windowShipsEdit.read()
        if event2 == "delete":
            print(values2)
        elif event2 == "add":
            print(values2)
        if event2 in (sg.WIN_CLOSED, "close"):
            windowShipsEdit.close()
            window.un_hide()
            break
    return

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
        [[sg.B("Delete selected ship", key="ship.delete")]]
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
    elif event == "ship.scenarios.edit":
        error("not implemented", window)
    elif event == "ship.ships.edit":
        if not selection:
            error("no ship selected", window)
        else:
            error("not implemented", window)
#           subWindowShipsEdit(window, selection)
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

