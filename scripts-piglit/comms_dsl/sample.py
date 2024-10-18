from dsl import dialog_option as O
from dsl import dialog_effect as E
from dsl import dialog_condition as C
from dsl import dialog_target as T
from dsl import dialog_link as L
from dsl import conditional_dialog_option as CO
from dsl import station as S
from dsl import generate



s = S()
# supply drop
s.add_dialog(CO(C("R.friendly") & C("R.undocked") & C("P.REP < 100"),
	"Can you send a supply drop? (100 rep)",
	"Not enough reputation!"
))
s.add_dialog(CO(C("R.friendly") & C("R.undocked") & C("P.REP >= 100"),
	"Can you send a supply drop? (100 rep)",
	"""We have dispatched a supply ship toward your current position.
If you would like that ship to go to somewhere else, create a waypoint and contact the supply ship.""",
	[
		E("P.REP - 100"),
		E("S.send_supply_drop = 1")
	]
))

# reinforcements
s.add_dialog(CO(C("R.friendly") & C("R.undocked"), "Please send reinforcements!", "What kind of reinforcement ship would you like?", [
	CO(C("P.REP < 100"),  "MT52 Hornet (100 Rep.)", "Not enough reputation!"),
	CO(C("P.REP >= 100"), "MT52 Hornet (100 Rep.)",
		"""We have dispatched a MT52 Hornet to assist towards your position.
If you would like that ship to go to somewhere else, create a waypoint and contact the ship.""",
		[
			E("P.REP - 100"),
			E("S.send_reinforcement_hornet = 1")
		]
	)
	CO(C("P.REP < 100"),  "WX-Lindworm (100 Rep.)", "Not enough reputation!"),
	CO(C("P.REP >= 100"), "WX-Lindworm (100 Rep.)",
		"""We have dispatched a WX-Lindworm to assist towards your position.
If you would like that ship to go to somewhere else, create a waypoint and contact the ship.""",
		[
			E("P.REP - 100"),
			E("S.send_reinforcement_lindworm = 1")
		]
	)
	CO(C("P.REP < 200"),  "Adder MK5 (200 Rep.)", "Not enough reputation!"),
	CO(C("P.REP >= 200"), "Adder MK5 (200 Rep.)",
		"""We have dispatched a Adder MK5 to assist towards your position.
If you would like that ship to go to somewhere else, create a waypoint and contact the ship.""",
		[
			E("P.REP - 200"),
			E("S.send_reinforcement_adder = 1")
		]
	)
	CO(C("P.REP < 300"),  "Phobos T3 (300 Rep.)", "Not enough reputation!"),
	CO(C("P.REP >= 300"), "Phobos T3 (300 Rep.)",
		"""We have dispatched a Phobos T3 to assist towards your position.
If you would like that ship to go to somewhere else, create a waypoint and contact the ship.""",
		[
			E("P.REP - 300"),
			E("S.send_reinforcement_adder = 1")
		]
	)
	L("Back", "MAIN")
]))

# missiles
missile_types = {
	# name, cost_friendly, cost_neutral, text
	"HOMING":	(2,5, "Do you have spare homing missiles for us?")
	"HVLI":		(2,5, "Can you restock us with HVLI?")
	"Mine":		(10,None, "Please re-stock our mines."),
	"Nuke":		(15,None, "Can you supply us with some nukes?"),
	"EMP":		(10,None, "Please re-stock our EMP missiles.")
}

def resupply_weapon(name):
	cost_friendly, cost_neutral, text = (missile_types[name])
	return [
		CO(C("R.friendly") & C("R.docked") & C(f"P.{name} < P.{name}_MAX") & C(f"P.REP >= {cost_friendly} * (P.{name}_MAX - P.{name})"),
			f"{text} ({cost_friendly} rep each)",
			"You are fully loaded and ready to explode things."
			[
				E(f"P.REP - {cost_friendly} * (P.{name}_MAX - P.{name})"),
				E(f"P.{name} = P.{name}_MAX"),
				L("Back", "MAIN")
			]
		),
		CO(C("R.friendly") & C("R.docked") & C(f"P.{name} < P.{name}_MAX") & C(f"P.REP < {cost_friendly} * (P.{name}_MAX - P.{name})"),
			f"{text} ({cost_friendly} rep each)",
			"Not enough reputation.",
			[L("Back", "MAIN")]
		),
		CO(C("R.friendly") & C("R.docked") & C(f"P.{name} >= P.{name}_MAX"),
			f"{text} ({cost_friendly} rep each)",
			"Sorry, sir, but you are as fully stocked as I can allow.",
			[L("Back", "MAIN")]
		),
	] + [
		CO(C("R.neutral") & C("R.docked") & C(f"P.{name} < P.{name}_MAX / 2") & C(f"P.REP >= {cost_neutral} * (P.{name}_MAX / 2 - P.{name})"),
			f"{text} ({cost_neutral} rep each)",
			"We generously resupplied you with some weapon charges.\nPut them to good use.",
			[
				E(f"P.REP - {cost_neutral} * (P.{name}_MAX / 2 - P.{name})"),
				E(f"P.{name} = P.{name}_MAX / 2"),
				L("Back", "MAIN")
			]
		),
		CO(C("R.neutral") & C("R.docked") & C(f"P.{name} < P.{name}_MAX / 2") & C(f"P.REP < {cost_neutral} * (P.{name}_MAX / 2 - P.{name})"),
			f"{text} ({cost_neutral} rep each)",
			"Not enough reputation.",
			[L("Back", "MAIN")]
		),
		CO(C("R.neutral") & C("R.docked") & C(f"P.{name} >= P.{name}_MAX / 2"),
			f"{text} ({cost_neutral} rep each)",
			"Sorry, sir, but you are as fully stocked as I can allow.",
			[L("Back", "MAIN")]
		),
	] if cost_neutral else []

for missile in missile_types:
	for dialog in resupply_weapon(missile):
		s.add_dialog(dialog)

s.add_dialog(CO(C("R.neutral") & C("R.docked"),
	"Can you supply us with some nukes?",
	"We do not deal in weapons of mass destruction."
	[L("Back", "MAIN")]
))

s.add_dialog(CO(C("R.neutral") & C("R.docked"),
	"Please re-stock our EMP missiles.",
	"We do not deal in weapons of mass disruption."
	[L("Back", "MAIN")]
))

s.add_dialog(CO(C("R.neutral") & C("R.docked"),
	"Please re-stock our mines.",
	"We do not deal in weapons of mass destruction."
	[L("Back", "MAIN")]
))

# status report
s.add_dialog(O("Report status", """Station status:
Hull: %s      Shield: %s""", [L("Back", "MAIN")]))

script = generate()
