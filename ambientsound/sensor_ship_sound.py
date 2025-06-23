#!/usr/bin/env python3

import requests
import json
import time
import math
import multiprocessing

import ambient

def getLua(code):
	""" Calls the get endpoint of the lua api.
		Example:
		"cs=getCallSign()"
		returns {"cs": "Starcruiser Kirk"}
	"""
	try:
		content = requests.get(f"http://127.0.0.1:8080/get.lua?{code}").content
	except requests.exceptions.ConnectionError:
		print("FAILED! start EmptyEpsilon with httpserver=8080 and try again.")
		return None
	return json.loads(content)

def mapShipStatsToChannels():
	result = getLua("""velx,vely=getVelocity()&dock=getDockingState()&velMax=getImpulseMaxSpeed()&warp=getCurrentWarpSpeed()""")
	if not result or not "dock" in result:
		return [0.1,0.1,0.1,0.1,0.1]
	dock = result["dock"]
	if dock == 2:
		return [0.1,0.1,0.1,0.1,0.1]
	velx = result["velx"]
	vely = result["vely"]
	velMax = result["velMax"]
	warp = result["warp"]
	rel_speed = math.sqrt(velx*velx + vely*vely) / velMax # 0-3
	flight_sound = 0.2 + rel_speed / (2.3*0.8)
	heavy_engines = 0.17 + rel_speed / 6
	return [flight_sound, 1, 1, heavy_engines, 1]

def setVolume(vol, channel):
	channel.sound_object.set_volume(vol * channel.volume/100)

def adjustVolumeFromGame(channels):		
	volumes = mapShipStatsToChannels()
	for id,vol in enumerate(volumes):
		setVolume(vol, channels[id])

if __name__ == "__main__":
	channels = ambient.bootstrap_chanlist(ambient.parseXML("presets/small-spaceship-engine-hum.xml"))
	print('Press CTRL+C to exit.')
	while True:
		ambient.tick_channels(channels)
		adjustVolumeFromGame(channels)

