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

# Timer
timerSource = Pyro4.Proxy("PYRONAME:round_timer")
timerNow = [sg.T("Time:", size=6), sg.T("00:00:00", key="timer.now")]
timerRound = [sg.T("", key="timer.state", size=6), sg.T("", key="timer.left"), sg.T("", key="timer.until"), sg.B("Skip", key="timer.skip", visible=False), sg.B("Edit", key="timer.edit", visible=False)]

# Ship Tree
with open("serverDB.json", "r") as file:
    data = json.load(file)

treedata = sg.TreeData()

def translate_scenario_name(scenario):
    try:
        with open(SCENARIO_DIR+"scenario_"+scenario+".lua", "r") as file:
            for line in file:
                if line.startswith("--") and "Name:" in line:
                    return line.split(":", maxsplit=1)[1].strip()
    except OSError:
        pass
    return scenario


for ship, shipData in data.items():
    status = shipData["status"]
    fields = []
    if "\t" in status:
        fields = [""] + status.split("\t")
    else:
        fields = [status]

    treedata.Insert("", ship, ship, fields)

    treedata.Insert(ship, ship+"_scenarios", "Scenarios available", [])
    for scenario in sorted(shipData["scenarios"]):
        fields = [[]]
        if shipData["scenarioSettings"] and scenario in shipData["scenarioSettings"]:
            for val in shipData["scenarioSettings"][scenario].values():
                if val:
                    fields[0].append(val)
        treedata.Insert(ship+"_scenarios", scenario, translate_scenario_name(scenario), fields)

    treedata.Insert(ship, ship+"_ships", "Ships available", [])
    for shipAvail in sorted(shipData["ships"]):
        treedata.Insert(ship+"_ships", shipAvail, shipAvail, [])


tree=sg.Tree(data=treedata,
        headings=['status', 'scenario', 'progress'],
        auto_size_columns=True,
        select_mode=sg.TABLE_SELECT_MODE_EXTENDED,
        num_rows=10,
        col0_width=15,
        key='-TREE-',
        show_expanded=False,
        enable_events=True,
        expand_x=True,
        expand_y=True,
        )



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


layout=[timerNow, timerRound, [tree]]
window=sg.Window("Flottenkommando", layout, size=(1200, 800), resizable=True, text_justification="r")
while True:
    event, values = window.read(timeout=1000)
    if event == sg.WIN_CLOSED:
       break
    elif event == "timer.skip":
        if confirm("Skip current phase?", window):
            timerSource.nextPhase()
    elif event == "timer.edit":
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
    elif event == "__TIMEOUT__":
        pass
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

