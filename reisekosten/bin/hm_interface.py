#!/usr/bin/env python3

#apt install python3-dialog python3-requests
from dialog import Dialog
import pyrohelper
from time import sleep

from rk_models import CostVisibility
rk = pyrohelper.connect_to_named("rk_server")
d = Dialog(autowidgetsize=True)
common_kwargs = {
	"title": "Hafenmeisterei-Konsole",
	"no_shadow": True,
	"yes_label": "Ja",
	"no_label": "Abbrechen",
}

"""
Choose ship:
 * list (callsign, name, template)
 * test
 * refresh?

What to do:
 * Rechnung anzeigen
 * Gebühren anpassen
 * Rabatte anpassen
 * Strafzahlungen anpassen
 * Rechnung drucken?
 * Kassieren/Auszahlen -> Vorgang beenden.

Anpassen:
 * chooselist(item)
"""



def abort():
	d.clear()
	exit(0)

def get_descriptive_line(registration_entry):
	return 

def start():
	while True:
		d.infobox("Lade Daten...")
		if rk.ping():
			shipselection()
		else:
			print("no connection to Reisekosten-server")
			sleep(1)

def shipselection():
	d.infobox("Lade Daten...")
	ships = rk.get_mission_finished_ships()
	selectable_ships = [(cs, "{type} {name}".format(**reg)) for cs,reg in ships.items()]
	selectable_ships.append(("Aktualisieren", "Aktualisiert diese Liste"))

	code, callsign = d.menu("Wähle ein Schiff:.\n\nPfeiltasten: navigieren\nEnter: fortfahren", choices=selectable_ships, **common_kwargs)
	if code != d.OK:
		return
	elif callsign == "Aktualisieren":
		return
	else:
		actionmenu(callsign, ships[callsign])

def actionmenu(callsign, ship):
	choices = [
		("1", "Rechnung anzeigen"),
		("2", "Gebühren anpassen"),
		("3", "Rabatte anpassen"),
		("4", "Strafzahlungen anpassen"),
#		("5", "Rechnung drucken"),
		("5", "Kassieren/Auszahlen -> Vorgang beenden."),
	]
	while True:
		code, action = d.menu("Wähle eine Aktion\n\nPfeiltasten/Zahlentasten: navigieren\nEnter: fortfahren", choices=choices, **common_kwargs)
		if code != d.OK:
			return
		elif action == "1":
			rk.send_costs_to_display(callsign)
			d.msgbox("Rechnungsanzeige wurde aktualisiert.", **common_kwargs)
		elif action == "2":
			adjust("Gebühren", callsign)
		elif action == "3":
			adjust("Rabatte", callsign)
		elif action == "4":
			adjust("Strafzahlungen", callsign)
		elif action == "5":
			costs = rk.get_ship_costs(callsign)
			payment = costs.get("payment", 0)
			msg = ""
			if payment > 0:
				msg = f"Die fällige Summe von {payment} Credits muss nun von der Schiffscrew bezahlt werden.\n\nWurde die Summe bezahlt?"
			if payment < 0:
				msg = f"Die Summe von {payment} Credits kann nun an die Schiffscrew ausbezahlt werden.\n\nWurde die Summe ausbezahlt?"
			code = d.yesno(msg, **common_kwargs)
			if code == d.OK:
				rk.finish_payment(callsign)
				d.msgbox("Vorgang abgeschlossen.")
				return


def adjust(what, callsign):
	template = []
	if what == "Gebühren":
		template = rk.get_cost_template_topic_values("Verhandelbar")
	elif what == "Rabatte":
		template = rk.get_cost_template_topic_values("Rabatte")
	elif what == "Strafzahlungen":
		template = rk.get_cost_template_topic_values("Rabatte", negative=True)
	assert template

	config = {item: CostVisibility(cfg) for item, cfg in rk.get_ship_costconfig(callsign).items()}
	costs = rk.get_ship_costs(callsign)

	while True:
		choices = []
		for idx, item in enumerate(template, 1):
			cfg = config.get(item) not in [CostVisibility.hide, CostVisibility.strike]
			cost = costs.get(item)
			if cost:
				item += f" ({cost})"
			choices.append((f"%x" % idx, item, cfg))
		code, tags = d.checklist(f"Wähle die {what} aus, die auf der Rechnung aufgelistet werden sollen.\n\nPfeiltasten/Zahlentasten: navigieren\nLeertaste: aktivieren/deaktiviren\nEnter: fortfahren", choices=choices, **common_kwargs)
		if code != d.OK:
			return
		

		added = []
		removed = []
		for idx, item in enumerate(template, 1):
			if f"%x" % idx in tags:
				# selected
				if config.get(item) in [CostVisibility.hide, CostVisibility.strike]:
					added.append(item)

			else:
				# de-selected
				if config.get(item) in [CostVisibility.show, CostVisibility.nostrike]:
					removed.append(item)

		msg = "Sollen folgende Änderungen vorgenommen werden:"
		if added:
			msg += f"\n{what} hinzufügen:\n * "
			msg += "\n * ".join(added)
		if removed:
			msg += f"\n{what} entfernen:\n * "
			msg += "\n * ".join(removed)
		if not added and not removed:
			msg = "Keine Änderung vornehmen?"
		code = d.yesno(msg, **common_kwargs)
		if code == d.OK:
			if added or removed:
				batch = rk._pyroBatch()
				for item in added:
					batch.set_ship_costs_config(callsign, item, CostVisibility(config[item].value +1))
				for item in removed:
					batch.set_ship_costs_config(callsign, item, CostVisibility(config[item].value -1))
				batch()
			return

start()
