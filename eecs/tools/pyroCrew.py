#!/usr/bin/env python3

import Pyro4
import json
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


