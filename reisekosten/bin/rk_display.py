#!/usr/bin/env python3
"""plots, compiles shows the pdf to players. Connected to a display."""

import pyrohelper
import Pyro4

import json
import subprocess

log = pyrohelper.connect_to_named("rk_log")
datadir = "../data"

@Pyro4.expose
class RKDisplay:

	def ping(self):
		return True

	def render_costs(self, callsign, data):
		log.debug(f"render costs of {callsign}")
		with open(f"{datadir}/{callsign}_typable.json", "w") as file:
			json.dump(data, file, indent=2)
		subprocess.run(["/snap/bin/typst", "compile", f"{datadir}/rk.typ", "--root", datadir, "--font-path", datadir, "--input", f"file={callsign}_typable.json", "--input", f"plot={callsign}_plot.png", f"{datadir}/{callsign}.pdf"])
		# TODO call viewer?

	def plot_flight_data(self, callsign, data):
		""" receives flight data from rk_server.
			prepares plotable file and start rk_plot.
			matplotlib likes it to run in the main thread, so call it as a separate executable.
		"""
		log.debug(f"plot_flight_data {callsign}")
		starttime = data.get("starttime", 0)
		fuel_x, fuel_y = self.fuelconsumption_plotable(data.get("fuelconsumption", []), starttime)
		damage_x, damage_y = self.damagereport_plotable(data.get("damagereport", []), starttime)
		export_data = {
			"fuel_time": fuel_x,
			"fuel_value": fuel_y,
			"damage_time": damage_x,
			"damage_value": damage_y,
		}
		# store locally for rk_plot to read
		log.debug(f"write to {callsign}_plotable.json")
		with open(f"{datadir}/{callsign}_plotable.json", "w") as file:
			json.dump(export_data, file, indent=2)
		log.debug(f"create plot for {callsign}")
		subprocess.run(["python3", "rk_plot.py", callsign])
		# this creates data/{callsign}_plot.png


	def fuelconsumption_plotable(self, data, starttime):
		"""returns separate lists for x and y values, scaled for plotting"""
		amount_tmp = []
		time = []
		if not data:
			return [],[]
		for point in sorted(data):
			t,a = point
			time.append((t-starttime)/60.0)
			amount_tmp.append(a)
		max_amount_sprit = 100
		if len(amount_tmp) > 0:
			max_amount_sprit = max(amount_tmp)
		amount_sprit = [100 * a / max_amount_sprit for a in amount_tmp]	# output as % of max
		return time, amount_sprit

	def damagereport_plotable(self, data, starttime):
		amount_dmg = []
		time = []
		if not data:
			return [], []
		for point in sorted(data):
			t,a = point
			time.append((t-starttime)/60.0)
			amount_dmg.append(min(a, 1.0) * 50.0)	# clamp to 100%
		return time, amount_dmg

def test_fuelconsumption_plotable():
	inputdata= [[1, 144], [2, 0], [12, 363], [13, 1621], [14, 3743], [16, 3599], [42, 3354], [43, 1333], [44, 370], [45, 39], [46, 911], [47, 2416], [48, 3599], [58, 2643], [59, 941], [60, 86], [61, 0], [69, 18], [70, 658], [71, 2245], [72, 3600], [79, 3350], [80, 1332], [81, 225], [82, 0], [286, 243], [287, 554], [288, 3]]
	x,y = fuelconsumption_plotable(inputdata, 10)
	assert len(x) == len(y) == len(inputdata)
	assert sorted(x) == x
	assert x[0] == -9/60
	assert x[-1] == 278/60
	assert min(y) == 0
	assert max(y) == 100
	x,y = fuelconsumption_plotable(inputdata*2, 10)
	assert len(x) == len(y) == len(inputdata) * 2
	assert sorted(x) == x

def test_damagereport_plotable():
	inputdata = [(25, 0.34081727266311646), (57, 0.3977767825126648)]
	x,y = damagereport_plotable(inputdata, 20)
	assert len(x) == len(y) == len(inputdata)
	assert sorted(x) == x
	assert x[0] == 5/60
	assert x[-1] == 37/60
	x,y = damagereport_plotable(inputdata*2, 10)
	assert len(x) == len(y) == len(inputdata) * 2
	assert sorted(x) == x


rk_display = RKDisplay()

if __name__ == "__main__":
	log.info(f"starting rk_display")
	pyrohelper.host_named_server(rk_display, "rk_display", 8005)
