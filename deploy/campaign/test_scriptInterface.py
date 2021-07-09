#!/usr/bin/env python3

from scriptInterface import *

def test_spawn():
	data = {
		"callsign": "testship",
		"template": "Phobos",
		"password":	"testi",
	}
	assert spawn(**data)

def test_set_esystem():
	data = {
		"shipname": "testship",
		"esystem": "reactor",
		"power": 1.5,	# 150 percent
	}
	assert command_esystem_power(**data)

	data = {
		"shipname": "testship",
		"esystem": "reactor",
		"coolant": 1.0,	# 100 percent
	}
	assert command_esystem_coolant(**data)

if __name__ == "__main__":
	test_spawn()
