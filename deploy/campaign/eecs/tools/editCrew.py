#!/usr/bin/env python3

import Pyro4
from pprint import pprint

print("usage: ipython")
print("%run editCrew.py")
print()
crews = Pyro4.Proxy("PYRONAME:campaign_crews")
crews.ping()
print("Crew-instances:")
print("---------------")
pprint(crews.list().keys())
print()
print("Methods:")
print("--------")
meth = dir(crews)
print("list() - lists all instances")
print("get(instance) - gets all stats of that instance")
for m in meth:
	if not m.startswith("_") and m not in ["list", "get"]:
		print(m + "(instance, param)")
print()
print("main object: crews")


### Dialog interface, just run the script

from dialog import Dialog

d = Dialog(autowidgetsize=True)
d.set_background_title("GM-Interface for crew status")

def selectCrew():
	instances = crews.list()
	menu_items = [(i,o['crew_name']) for i,o in instances.items()]
	code, tag = d.menu("Select crew", choices=menu_items)
	if code == d.OK:
		return tag
	return None

def showCrew(instance):
	while True:
		crew = crews.get(instance)
		msg = ""
		for k,v in crew.items():
			msg += f"{k:>12}:\t{v}\n"
		#d.scrollbox(msg)
		choice_details = {
			"name": ("set crew name", "setCrewName", "crew_name"),
			"status": ("set status", "setStatus", "status"),
			"unlockScenario": ("unlock a scenario", "unlockScenario"),
			"lockScenario": ("lock a scenario", "lockScenario"),
			"unlockShip": ("unlock a ship", "unlockShip"),
			"lockShip": ("lock a ship", "lockShip"),
#			"setBriefing": ("change the briefing text", "setBriefing", "briefing"),
		}
		code, tag = d.menu(msg, choices=[(k, v[0]) for k,v in choice_details.items()])
		if code == d.OK:
			editCrew(instance, *choice_details[tag])
		else:
			return

def editCrew(instance, descr, function, default_attr=None):
	default = ""
	if default_attr:
		default = crews.get(instance)[default_attr]
	code, entry = d.inputbox(instance + " - " + descr, init=default)
	if code == d.OK:
		crews.__getattr__(function)(instance, entry)

while True:
	instance = selectCrew()
	if not instance:
		break
	showCrew(instance)

