#!/usr/bin/env python3
"""data is saved in json files here. Should be on a machine with persistent storage."""

import pyrohelper
import Pyro4

import json
import glob

log = pyrohelper.connect_to_named("rk_log")
datadir = "../data"

@Pyro4.expose
class RKStorage:

	def ping(self):
		return True

	def store(self, filename, data):
		log.debug(f"store {filename}")
		filename = filename.removesuffix(".json")
		with open(f"{datadir}/{filename}.json", "w") as file:
			json.dump(data, file, indent=2)

	def load(self, filename):
		log.debug(f"load {filename}")
		filename = filename.removesuffix(".json")
		with open(f"{datadir}/{filename}.json", "r") as file:
			return json.load(file)

	def list(self, glob_expression):
		glob_expression = glob_expression.removesuffix(".json")
		# force conversion to list to reduce calls if this was a generator expression
		return [ filename.removesuffix(".json") for filename in glob.glob(f"{glob_expression}.json", root_dir=datadir) ]


rk_storage = RKStorage()

if __name__ == "__main__":
	log.info("starting rk_storage")
	pyrohelper.host_named_server(rk_storage, "rk_storage", 8004)
