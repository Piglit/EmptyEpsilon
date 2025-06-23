#!/usr/bin/env python3
"""ambient.py - plays an ambient mix with pygame. Mash CTRL+C to quit.
 
Usage:
  ambient.py <file>
"""
__author__      = "Philooz, luna-system, Pithlit"
__copyright__   = "2017 GPL"

import random, sys
import pygame
import xml.etree.ElementTree as ET

pygame.mixer.init()
pygame.mixer.pre_init(44100, -16, 2, 2048)
pygame.init()
pygame.mixer.set_num_channels(16)

clock = pygame.time.Clock()

CLOCK_TICKER = 10
MAX_AMBIENT_MIXER_CHANNELS = 8
CROSSFADE_DURATION_MS = 2000

unit_duration_map = {
	'1m': 60*CLOCK_TICKER,
	'10m': 600*CLOCK_TICKER,
	'1h': 3600*CLOCK_TICKER
}

def chop_interval(num, prec, max, len):
	num += 1
	values = [random.randint(0, prec) for _ in range(num)]
	norm = sum(values)
	anc = 0
	max_ar = max - 1.5*len*num
	for i in range(num):
		old = values[i]
		values[i] += anc
		anc += old
		values[i] /= norm
		values[i] *= max_ar+i*1.5*len
		values[i] = int(values[i])
	return values

class Channel():
	def __init__(self, channel_id, id_audio, name_audio = "", volume = "100", random = "false", random_counter = "1", random_unit = "1h", mute = "false", balance = "0", crossfade = "false", **kwargs):
		try:
			self.sound_object = pygame.mixer.Sound(f"sounds/{id_audio}.ogg")
		except Exception:
			print(
				f'Error while loading sound "sounds/{id_audio}.ogg". Did you convert it to ogg?'
			)
			sys.exit()
		self.channel_object = pygame.mixer.Channel(channel_id*2)
		self.name = name_audio
		#Normalize volume
		self.volume = int(volume)
		self.sound_object.set_volume(self.volume/100.0)
		#Adjust balance
		self.balance = int(balance)
		self.left_volume = 1.0 if (self.balance <= 0) else (1.0-self.balance/100)
		self.right_volume = 1.0 if (self.balance >= 0) else (1.0+self.balance/100)
		self.channel_object.set_volume(self.left_volume, self.right_volume)
		#Set random
		self.channel_id = channel_id
		self.id_audio = id_audio
		self.random = random == "true"
		self.random_counter = int(random_counter)
		self.random_unit = random_unit
		self.play_at = []
		self.current_tick = 0
		self.mute = mute == "true"
		self.crossfade = crossfade == "true"
		self.crossfade_channel_object = pygame.mixer.Channel(channel_id*2+1)
		self.crossfade_channel_object.set_volume(self.left_volume, self.right_volume)
		self.fading = False
	
	def __repr__(self):
		mid_part = "(looping)"
		if(self.random):
			mid_part = f"(random {self.random_counter} per {self.random_unit})"
		if(self.crossfade):
			mid_part = "(looping, crossfade)"
		return f"Channel {self.channel_id} : {self.name} {mid_part}, {self.id_audio}.ogg (volume {self.volume}, balance {self.balance})"

	def compute_next_ticks(self):
		val = unit_duration_map[self.random_unit]
		sound_len = self.sound_object.get_length()*1.5
		self.play_at = chop_interval(self.random_counter, 100, val, sound_len)

	def play(self, force = False):
		if force:
			self.channel_object.play(self.sound_object)
		elif self.mute or self.random:
			return
		elif self.crossfade:
			self.channel_object.play(self.sound_object, loops = 0, fade_ms = CROSSFADE_DURATION_MS)

	def tick(self):
		if self.mute:
			return
		self.current_tick += 1
		if self.random:
			if self.play_at:
				ref = self.play_at[0]
				if self.current_tick > ref:
					#print("Playing : {}".format(self.play_at))
					self.play_at.pop(0)
					if(len(self.play_at) >= 1):
						self.play(True)
			else:
				self.current_tick = 0
				self.compute_next_ticks()
				#print("Recomputed : {}".format(self.play_at))
		elif self.crossfade:
			if not self.fading:
				if self.current_tick / CLOCK_TICKER >= self.sound_object.get_length() - CROSSFADE_DURATION_MS / 1000:
#					self.channel_object.fadeout(CROSSFADE_DURATION_MS)
					self.fading = True
					self.crossfade_channel_object.play(self.sound_object, loops = 0, fade_ms = CROSSFADE_DURATION_MS)
					self.current_tick = 0
			else:
				if self.current_tick >= CLOCK_TICKER:
					self.fading = False
					self.channel_object, self.crossfade_channel_object = self.crossfade_channel_object, self.channel_object

def parseXML(xml_file):
	tree = ET.parse(xml_file)
	root = tree.getroot()
	assert root.tag == "audio_template"
	channels = []
	for channel in root:
		if channel.tag.startswith("channel"):
			dic = {}
			for attribute in channel:
				dic[attribute.tag] = attribute.text
			channels.append(dic)
	return channels

def bootstrap_chanlist(chans_to_load):
	channels = [
		Channel(c_id, **c_val)
		for c_id, c_val in enumerate(chans_to_load)
		if c_val["id_audio"] not in ('', '0')
	]
	for channel in channels:
		print(f'Loaded {channel}.')
		channel.play()
	return channels

def tick_channels(channels):
	clock.tick(CLOCK_TICKER)
	for channel in channels:
		channel.tick()

if __name__ == "__main__":
	import argparse
	parser = argparse.ArgumentParser()
	parser.add_argument("file", help="XML file of the ambient mix to play. Make sure you have the correct 'sounds/' folder in your current working directory.")
	args = parser.parse_args()
	channels = bootstrap_chanlist(parseXML(args.file))
	print('Press CTRL+C to exit.')
	while True:
		tick_channels(channels)
