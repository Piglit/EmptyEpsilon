#!/usr/bin/env python3

#apt install python3-dialog python3-requests
from dialog import Dialog
import pyrohelper
from time import sleep

rk = pyrohelper.connect_to_named("rk_server")
d = Dialog(autowidgetsize=True)

"""
Choose ship:
 * list (callsign, name, template, income)

Modify income
 * Label (callsign, name, template, note)
 * str (income)
"""

def abort():
	d.clear()
	exit(0)

def get_descriptive_line(registration_entry):
	return 

def start():
	while True:
		d.infobox("Loading...")
		if rk.ping():
			shipselection()
		else:
			print("no connection to Reisekosten-server")
			sleep(1)

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

start()
