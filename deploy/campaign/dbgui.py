#!/usr/bin/python3
import PySimpleGUI as g
import json

SCENARIO_DIR = "../../scripts-piglit/"

g.set_options(font=("Arial Bold",14))

with open("serverDB.json", "r") as file:
    data = json.load(file)

treedata = g.TreeData()

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


tree=g.Tree(data=treedata,
        headings=['status', 'scenario', 'progress'],
        auto_size_columns=True,
        select_mode=g.TABLE_SELECT_MODE_EXTENDED,
        num_rows=10,
        col0_width=15,
        key='-TREE-',
        show_expanded=False,
        enable_events=True,
        expand_x=True,
        expand_y=True,
        )
layout=[[tree]]
window=g.Window("Tree Demo", layout, size=(1200, 800), resizable=True)
while True:
    event, values = window.read()
    print ("event:",event, "values:",values)
    if event == g.WIN_CLOSED:
       break
