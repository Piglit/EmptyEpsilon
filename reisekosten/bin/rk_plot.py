#!/usr/bin/env python3
import sys
import json
#import subprocess

import matplotlib as mpl
import matplotlib.pyplot as plt
from matplotlib.ticker import FormatStrFormatter
import numpy as np

datadir = "../data"

def plot(data, callsign):
	"""Create plot of fuelconsumption and damagereport for the given callsign"""
	mpl.rcParams["axes.linewidth"] = 4
	mpl.rcParams["axes.edgecolor"] = "cccccc"
	plt.plot(data["fuel_time"], data["fuel_value"], "b-")	# blue line
	if data["fuel_time"]:
		plt.xticks(np.arange(0,data["fuel_time"][-1]+5,10))
	else:
		plt.xticks([0])

	if data["damage_time"]: 
		plt.stem(data["damage_time"], data["damage_value"], linefmt="r:", markerfmt="x", basefmt=" ")

	plt.legend(["Treibstoffverbrauch", "Schadensmeldung"])
	plt.gca().xaxis.set_major_formatter(FormatStrFormatter("%d min"))
	plt.gca().yaxis.set_major_formatter(FormatStrFormatter("%d%%"))
#		plt.xlabel("Flugzeit")
#		plt.ylabel("")
#		plt.title("Treibstoffverbrauch")
	plt.savefig(f"{datadir}/{callsign}_plot.png", format="png", bbox_inches="tight")
#		plt.show()

	# Fonts:
	# Cyberfall
	# MJGranada-Granada
	# Norfolk Bold
	# MSU1
	# GovernmentAgentBB

if __name__ == "__main__":
	callsign = sys.argv[1]
	with open(f"{datadir}/{callsign}_plotable.json", "r") as file:
		data = json.load(file)
	plot(data, callsign)

