from rk_server import rk
from rk_models import ShipState
import json

def test_register_ship():
	rk.register_ship("TS-T", "Testschiff", "Phobos", "Das ist ein Test.")
	assert "TS-T" in rk.registration

def test_ship_state_change():
	rk.ship_state_change("TS-T", 127, ShipState.created)
	assert "TS-T" in rk.registration
	assert "TS-T" not in rk.starttime
	assert "TS-T" not in rk.fuelconsumption
	assert "TS-T" not in rk.damagereport
	assert "TS-T" not in rk.damagedsystems

	rk.ship_state_change("TS-T", 127, ShipState.undocked)
	assert "TS-T" in rk.registration
	assert "TS-T" in rk.starttime
	assert "TS-T" not in rk.fuelconsumption
	assert "TS-T" not in rk.damagereport
	assert "TS-T" not in rk.damagedsystems

def test_fuelconsumption_from_sensor():
	inputdata= [[1, 144], [2, 0], [12, 363], [13, 1621], [14, 3743], [16, 3599], [42, 3354], [43, 1333], [44, 370], [45, 39], [46, 911], [47, 2416], [48, 3599], [58, 2643], [59, 941], [60, 86], [61, 0], [69, 18], [70, 658], [71, 2245], [72, 3600], [79, 3350], [80, 1332], [81, 225], [82, 0], [286, 243], [287, 554], [288, 3]]
	assert "TS-T" not in rk.fuelconsumption
	rk.fuelconsumption_from_sensor("TS-T", inputdata)
	assert "TS-T" in rk.fuelconsumption
	l = len(rk.fuelconsumption["TS-T"])
	rk.fuelconsumption_from_sensor("TS-T", inputdata)
	assert l*2 == len(rk.fuelconsumption["TS-T"])

def test_damagereport_from_sensor():
	inputdata = [[25, [['frontshield', 0.34081727266311646]], {}], [57, [['rearshield', 0.3977767825126648], ['kinetic', 0.0]], ['Asteroid']]]
	assert "TS-T" not in rk.damagereport
	assert "TS-T" not in rk.damagedsystems
	rk.damagereport_from_sensor("TS-T", inputdata)
	assert "TS-T" in rk.damagereport
	assert "TS-T" in rk.damagedsystems
	rk.damagedsystems["TS-T"]["frontshield"]["amount"] == 0.34081727266311646
	l = len(rk.damagereport["TS-T"])
	rk.damagereport_from_sensor("TS-T", inputdata)
	assert l*2 == len(rk.damagereport["TS-T"])

def test_damagedsystems_to_text():
	inputdata = {
		'frontshield': {"amount": 0.34081727266311646, "instigators": []},
		'rearshield':  {"amount": 0.3977767825126648,  "instigators": []},
		'kinetic':     {"amount": 0.0, "instigators": ['Asteroid']},
	}
	ret = rk.damagedsystems_to_text(inputdata)

def test_ship_income():
	assert rk.get_ship_income("TS-T") == 0
	rk.set_ship_income("TS-T", 15000)
	assert rk.get_ship_income("TS-T") == 15000
	rk.set_ship_income("TS-T", 15000*2)
	assert rk.get_ship_income("TS-T") == 30000

def test_get_ship_cost_calculation():
	with open("../data/template_costs_distribution.json", "r") as file:
		rk.cost_template = json.load(file)
	rk.get_ship_cost_calculation("TS-T")

def test_create_default_costconfig():
	rk.create_default_costconfig()

def test_calculate_costs():
	templ = {
		"something": 50,
		"else":	25,
	}
	expected = {
		"something": 500,
		"else":	500,
	}
	result = rk.calculate_costs(1000, templ)
	assert result == expected
	result = rk.calculate_costs(1000, templ)
	assert result == expected
	templ = {
		"something": 50,
		"else":	75,
	}
	expected = {
		"something": 500,
		"else":	500,
	}
	result = rk.calculate_costs(1000, templ)
	assert result == expected
	templ = {
		"something": 50,
		"else":	25,
	}
	expected = {
		"something": 499,
		"else":	500,
	}
	result = rk.calculate_costs(999, templ)
	assert result == expected
	expected = {
		"something": 500,
		"else":	501,
	}
	result = rk.calculate_costs(1001, templ)
	assert result == expected
	templ = {
		"something": (50, {
			"sub1": 25,
			"things": 0,
		}),
		"else":	25,
	}
	expected = {
		"sub1": 0.25*0.50*1000,
		"things": 0.75*0.50*1000,
		"else":	500,
	}
	result = rk.calculate_costs(1000, templ)
	assert result == expected
	templ = {
		"something": [50, 55],
		"other": [50, 50.5],
		"else":	25,
	}
	result = rk.calculate_costs(1000, templ)
	assert 500 <= result["something"] <= 550
#	assert result["other"] in [500,510]	# no longer use randint, can be float
	assert result["else"] <= 0 
	templ = {
		"something": 50.5,
		"else":	25,
	}
	expected = {
		"something": 505,
		"else":	495,
	}
	result = rk.calculate_costs(1000, templ)
	assert result == expected

def test_reset_data():
	assert "TS-T" in rk.starttime
	assert "TS-T" in rk.fuelconsumption
	assert "TS-T" in rk.damagereport
	assert "TS-T" in rk.damagedsystems
	rk.ship_state_change("TS-T", 127, ShipState.created)
	assert "TS-T" in rk.registration
	assert "TS-T" not in rk.starttime
	assert "TS-T" not in rk.fuelconsumption
	assert "TS-T" not in rk.damagereport
	assert "TS-T" not in rk.damagedsystems

def test_load():
	rk.load_ship("TS-T")
	assert "TS-T" in rk.registration
	assert "TS-T" in rk.starttime
	assert "TS-T" in rk.fuelconsumption
	assert "TS-T" in rk.damagereport
	assert "TS-T" in rk.damagedsystems


