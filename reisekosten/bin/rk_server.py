#!/usr/bin/env python3
import os
import random
import copy

import pytest

import pyrohelper
import Pyro4

import json

from rk_models import ShipState, CostVisibility

log = pyrohelper.connect_to_named("rk_log")
storage = pyrohelper.connect_to_named("rk_storage")
display = pyrohelper.connect_to_named("rk_display")

# Accessible storage class
@Pyro4.expose
class Reisekosten:

	def __init__(self):
		self._storage_items = [
			"registration",
            "starttime",
            "fuelconsumption",
            "damagereport",
            "damagedsystems",
            "damagetext",
            "income",
            "costs",
			"costconfig",
			"finished_payment"
		]
		self.registration = {}
		self.starttime = {}
		self.fuelconsumption = {}
		self.damagereport = {}
		self.damagedsystems = {}
		self.damagetext = {}
		self.income = {}
		self.costs = {}
		self.costconfig = {}
		self.finished_payment = {}

	# function for all remote scripts, gm and storage

	def get_ship(self, callsign, filter_items=None):
		"""returns all data of one ship, identified by callsign."""
		result = {}
		if callsign not in self.registration:
			raise KeyError(callsign)
		for item in self._storage_items:
			if filter_items is None or item in filter_items:
				result[item] = getattr(self, item).get(callsign)
		if not filter_items or "income" in filter_items:
			result["income"] = result.get("income") or 0
		return result

	# functions that use rk_storage, callable by gm or script

	def load_ship(self, callsign):
		data = storage.load(f"{callsign}_ship")
		for item in self._storage_items:
			if item in data:
				getattr(self, item)[callsign] = data[item]
			elif callsign in getattr(self, item):
				del getattr(self, item)[callsign]

	def load_all_ships(self):
		for filename in storage.list("*_ship"):
			callsign = filename.removesuffix("_ship")
			self.load_ship(callsign)

	def save_ship(self, callsign):
		if callsign == "Test":
			return
		data = self.get_ship(callsign)
		storage.store(f"{callsign}_ship", data)

	def save_all_ships(self):
		for callsign in self.registration:
			if callsign == "Test":
				continue
			data = self.get_ship(callsign)
			storage.store(f"{callsign}_ship", data)


	# update functions, called from rk_http by EE

	# not oneway or async, since other calls depend on this one.
	def register_ship(self, callsign, shipname, template, description):
		log.info(f"{callsign} registered as {template} {shipname} ({description})")
		self.registration[callsign] = {
			"callsign": callsign,
			"type": template,
			"name": shipname,
			"note": description,
		}

	@Pyro4.oneway
	def ship_state_change(self, callsign: str, timestamp: int, state: ShipState):
		log.info(f"{callsign} {state} (T={int(timestamp)})")
		if state == ShipState.created:
			# reset all data when ship is created
			for item in self._storage_items:
				if item != "registration":
					if callsign in getattr(self, item):
						del getattr(self, item)[callsign]
			
		if state == ShipState.undocked:
			# on first undock start mission time of that ship
			# store the registration and starttime, delete anything else in storage.
			if callsign not in self.starttime:
				self.starttime[callsign] = int(timestamp)
				self.save_ship(callsign)

		if state == ShipState.deleted:
			# when ship despawns and income was set, export the finished ship data
			# GM can also call finish_ship via Pyro, if something went wrong.
			if self.income.get(callsign, 0) != 0:
				self.finish_mission(callsign)
			else:
				self.save_ship(callsign)
				log.warning(f"{callsign} was deleted but income was not set. You need to call finish_mission({callsign}) manually!")

	@Pyro4.oneway
	def fuelconsumption_from_sensor(self, callsign: str, data: list):
		log.debug(f"Ship {callsign} fuelconsumption {data}")
		if callsign not in self.fuelconsumption:
			self.fuelconsumption[callsign] = data
		else:
			self.fuelconsumption[callsign] += data
		log.info(f"Spritverbrauch von {callsign} aktualisiert ({len(data)}/{len(self.fuelconsumption[callsign])})")

	@Pyro4.oneway
	def damagereport_from_sensor(self, callsign: str, data: list):
		"""Split damagereport in two:
			* the timestamps with the total amount of damage -> damagereport
			* the accumulated damage of each system -> damagedsystems
		"""
		log.debug(f"Ship {callsign} damagereport {data}")
		if callsign not in self.damagedsystems:
			self.damagedsystems[callsign] = {}
		if callsign not in self.damagereport:
			self.damagereport[callsign] = []

		for point in data:
			total = 0
			time,systems,instigators = point
			for pair in systems:
				s,a = pair
				if s not in self.damagedsystems[callsign]:
					self.damagedsystems[callsign][s] = {
						"amount": a,
						"instigators": [],
					}
				else:
					self.damagedsystems[callsign][s]["amount"] += a
				if instigators:
					self.damagedsystems[callsign][s]["instigators"] += instigators
				total += a
			self.damagereport[callsign].append((time,total))
		# re-generates damagetext everytime the ship docks!
		self.damagetext[callsign] = self.damagedsystems_to_text(self.damagedsystems[callsign])
		log.info(f"Schadensbericht von {callsign} aktualisiert ({len(data)}/{len(self.damagereport[callsign])})")

	# output functions and helpers

	def damagedsystems_to_text(self, data):
		if "frontshield" in data and "rearshield" in data:
			data["frontshield"]["amount"] += data["rearshield"]["amount"]
			data["frontshield"]["instigators"] += data["rearshield"]["instigators"]
			del data["rearshield"]

		secondary_words = {
			"halterung":		["zerbrochen", "gesprungen", "verbogen", "abgefallen"],
			"gehäuse":			["zersplittert", "gebrochen", "gesprungen", "verbogen", "abgefallen"],
			"einspeisung":		["explodiert", "unauffindbar", "blockiert", "verbogen"],
			"leitung":			["explodiert", "durchgebrannt", "blockiert", "verbogen", "entmantelt", "abgefallen"],
			"belüftung":		["gesprungen", "blockiert", "verbogen", "abgefallen"],
			"-Energiekopplung":	["explodiert", "gesprungen", "durchgebrannt"],
			"stabilistator":	["explodiert", "verbogen", "blockiert", "zusammengebrochen", "abgefallen"],
			"konverter":		["explodiert", "verbogen", "blockiert", "zusammengebrochen", "abgefallen"],
		}

		used_words = set()

		report = ""
		first_report = ""
		for pair in reversed(sorted(data.items(), key=lambda pair: pair[1]["amount"])):
			dmgtype, data = pair
			amount = data["amount"]

			instigators = set(data["instigators"])
			instigators_str = ""
			if "Asteroid" in instigators and "CpuShip" in instigators:
				instigators_str = "durch Trümmereinschlag und Beschuss "
			elif "Asteroid" in instigators:
				instigators_str = "durch Trümmereinschlag "
			elif "CpuShip" in instigators:
				instigators_str = "durch Beschuss "
			elif not instigators:
				instigators_str = "durch Überhitzung "

			if dmgtype in ["kinetic", "energy", "emp"]:
				if amount == 0:
					amount_str = "nicht nennenswerte "
				elif amount <= 0.1:
					amount_str = "kaum "
				elif amount <= 0.3:
					amount_str = "leichte "
				elif amount <= 0.5:
					amount_str = ""
				elif amount <= 1.0:
					amount_str = "schwere "
				elif amount <= 1.5:
					amount_str = "ernsthafte "
				elif amount <= 2.0:
					amount_str = "gravierende "
				else:
					amount_str = "fast irreparable "

				first_report = {
					"kinetic": f"\n* Schiff weist {amount_str}Einschlagspuren {instigators_str}auf.",
					"energy": f"\n* Schiff weist {amount_str}Energiewaffenspuren {instigators_str}auf.",
					"emp": f"\n* Schiffselektronik wurde {instigators_str}in Mitleidenschaft gezogen.",
				}[dmgtype]
			else:
				dmgtype_str = {
					"reactor": "Reaktor",
					"beamweapons": "Laserwaffen",
					"missilesystem": "Raketenwerfer",
					"maneuver": "Manövriertriebwerk",
					"impulse": "Triebwerk",
					"frontshield": "Schildgenerator",
					"rearshield": "Schildgenerator",
				}[dmgtype]

				if secondary_words:
					secondary_str, tertiary_strs = random.choice(list(secondary_words.items()))
					del secondary_words[secondary_str]
					tertiary_strs = [ts for ts in tertiary_strs if ts not in used_words]
					tertiary_str = "beschädigt"
					if tertiary_strs:
						# amount 0-2+
						# effects 1-5
						idx = max(1,min(int(amount * len(tertiary_strs) / 2.0), len(tertiary_strs)))
#						print(dmgtype, idx, len(tertiary_strs))
						tertiary_str = tertiary_strs[-idx]
						used_words.add(tertiary_str)
						
					report += f"\n* {dmgtype_str}{secondary_str} {instigators_str}{tertiary_str}."

		report = "Schadensbericht:\n----------------" + first_report + report
		return report

	def create_default_costconfig(self):
		template = self.cost_template
		result = {}
		for item in template["Gebühren"][1]:
			result[item] = CostVisibility.always
		for item in template["Verhandelbar"][1]:
			result[item] = CostVisibility.nostrike
		for item in template["Rabatte"][1]:
			result[item] = CostVisibility.hide
		return result

	def get_ship_cost_calculation(self, callsign):
		amount = self.income.get(callsign, 0)
		if amount == 0:
			raise RuntimeError("Ship has no income!")
		elif amount < 0:
			pass
			# no payment was made - payment will be made by Hafenmeisterei
		assert self.cost_template
		template = copy.deepcopy(self.cost_template)
		dmg = self.damagedsystems.get(callsign)
		if dmg:
			dmg_amount = 0
			for dmgdata in dmg.values():
				dmg_amount += 5 * dmgdata.get("amount", 0)	# amount: 0-2 per system
			template["Reparaturen"] = max(min(dmg_amount, 35), 12)
		else:
			template["Reparaturen"] = 25 # data probably not found!

		template["Treibstoffkosten"] = 0	# remainder
		result = self.calculate_costs(amount, template)
		result["payment"] = amount - result["Gewinn"]
		return result

	def calculate_costs(self, total_amount, template):
		"""converts a (nested) template with percentual values and the total amount of income to a flat dict with the total values in credits of each leave of template.
		Example template:
			{	
				"something": (50, {		# 50% of total is split upon the following items
					"sub1": [25, 50.5],	# random between 25% and 50.5%
					"things": 0,		# remainder of the items under "something"
				}),
				"else":	25,				# fixed 25% of total_amount
				"remainder": 0,			# remainder of that level (25% in this example)
			}
		Results in (with 1000 as total_amount):
			{
				"sub1": 235,
				"things": 265,
				"else":	250,
				"remainder": 250,
			}
			# notice that "something" is not listed, since it is not a leave

		Keys starting with _ are used for calculation but not shown in the result.
		Negative values do not count towards the total amount. They represent possible cost reductions.
		"""
		spent_amount = 0
		last_key = None
		result = {}
		assert template
		for key, value in template.items():
			percent = 0
			sub_data = None
			if isinstance(value, tuple) or isinstance(value, list):
				(percent, second) = value
				assert (isinstance(percent, int) or isinstance(percent, float))
				if isinstance(second, dict):
					assert second
					sub_data = second
				elif isinstance(second, int) or isinstance(percent, float):
					assert second > percent
					percent = random.uniform(percent, second)
			elif isinstance(value, int) or isinstance(value, float):
				percent = value
			else:
				assert(False)

			new_amount = int((percent * total_amount) // 100)
			if percent > 0:
				spent_amount += new_amount
			if sub_data:
				result.update(self.calculate_costs(new_amount, sub_data))
			elif not key.startswith("_"):
				result[key] = new_amount
				last_key = key
			else:
				pass # amount may be calculated, but is hidden in result

		result[last_key] += total_amount - spent_amount	# last entry gets remainder
		return result

	# finish EE and GM interaction and start HM interaction

	def finish_mission(self, callsign):
		"""called when the ship despawns and income was set.
			can also be called by GM manually after the mission is over.
		"""
		log.info("finishing {type} {name} ({callsign})".format(**(self.registration[callsign])))
		display.plot_flight_data(callsign, self.get_ship(callsign, filter_items=["starttime", "fuelconsumption", "damagereport"]))
		self.costs[callsign] = self.get_ship_cost_calculation(callsign)
		self.costconfig[callsign] = self.create_default_costconfig()
		self.save_ship(callsign)

	def create_test_ship(self):
		self.registration["Test"] = {
			"callsign": "Test",
			"type": "-",
			"name": "Test",
			"note": "Kein real existierendes Schiff. Die Einträge dienen zum Anlernen von neuem Personal in der Hafenmeisterei.",
		}
		self.starttime["Test"] = 0
		self.fuelconsumption["Test"] = []
		self.damagereport["Test"] = []
		self.damagedsystems["Test"] = {}
		self.damagetext["Test"] = "Keine Schadensmeldungen."
		self.income["Test"] = 20000
		self.costs["Test"] = self.get_ship_cost_calculation("Test")
		self.costconfig["Test"] = self.create_default_costconfig()
		self.finished_payment["Test"] = False
		display.plot_flight_data("Test", self.get_ship("Test", filter_items=["starttime", "fuelconsumption", "damagereport"]))


# GM-Interface Functions

	def load_cost_template(self):
		"""use this to manipulate the cost distribution at runtime"""
		self.cost_template = storage.load("template_costs_distribution")

	def get_ship_income(self, callsign: str):
		return self.income.get(callsign, 0)

	def set_ship_income(self, callsign: str , amount: int):
		assert isinstance(callsign, str)
		assert isinstance(amount, int)
		self.income[callsign] = amount

	def get_ship_damagereport(self, callsign: str):
		return self.damagetext.get(callsign)

	def set_ship_damagereport(self, callsign:str , text: str):
		assert isinstance(callsign, str)
		assert isinstance(text, str)
		self.damagetext[callsign] = text

	def get_ships(self, with_income=False):
		if not with_income:
			return self.registration
		result = copy.deepcopy(self.registration)
		for cs in result:
			result[cs]["income"] = self.get_ship_income(cs)
		return result

	def ping(self):
		log.ping()
		storage.ping()
		display.ping()
		return True


# HM-Interface Functions
	
	def get_mission_finished_ships(self):
		# remove ships, where the payment was finished
		result = {}
		self.create_test_ship()
		#for callsign in self.costs:
		#	if not self.finished_payment.get(callsign):
		#		result[callsign] = self.registration[callsign]
		result["Test"] = {
			"callsign": "Schiff",
			"type": "Raumschiff",
			"name": "",
			"note": "Gebühren des aktuellen Schiffs anpassen",
		}
		return result

	def get_ship_costs(self, callsign: str):
		return self.costs[callsign]

	def get_ship_costconfig(self, callsign: str):
		return self.costconfig[callsign]

	def get_cost_template_topic_values(self, topic, negative=False):
		_filter = lambda x: x>0
		if negative:
			_filter = lambda x: x<0
		return [ k for k,v in self.cost_template.get(topic, [0,{}])[1].items() if _filter(v) ]

	# not oneway or async, since this one is not threadsafe
	# but it should be called batched (with _pyroBatch()) from the client
	def set_ship_costs_config(self, callsign: str, item: str, value: int or CostVisibility):
		old = CostVisibility(self.costconfig[callsign][item])
		amount = self.costs[callsign][item]
		value = CostVisibility(value)
		if old.value < value.value:
			# -> show
			self.costs[callsign]["payment"] += amount
		elif old.value > value.value:
			# -> hide
			self.costs[callsign]["payment"] -= amount
		self.costconfig[callsign][item] = value

	def send_costs_to_display(self, callsign: str):
		data = self.get_ship(callsign, filter_items=[
			"registration",
            "damagetext",
            "costs",
			"costconfig"
		])
		display.render_costs(callsign, data)
	
	def finish_payment(self, callsign):
		self.finished_payment[callsign] = True
		self.save_ship(callsign)

rk = Reisekosten()

if __name__ == "__main__":
	log.info("starting rk_server")
	rk.load_cost_template()
	rk.load_all_ships()
	pyrohelper.host_named_server(rk, "rk_server", 8001)

