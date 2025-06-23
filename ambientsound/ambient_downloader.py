#!/usr/bin/env python3
"""ambient_downloader.py - download an ambient XML file from ambient-mixer.com
 
Usage:
  ambient_downloader.py <url>
"""
__author__      = "Philooz, luna-system, Pithlit"
__copyright__   = "2017 GPL"

import re, os
import subprocess

import requests
import xml.etree.ElementTree as ET

template_url = "http://xml.ambient-mixer.com/audio-template?player=html5&id_template="
re_js_reg = re.compile(r"AmbientMixer.setup\([0-9]+\);")

def makedirs():
	if not os.path.exists("sounds"):
		os.makedirs("sounds")
	if not os.path.exists("presets"):
		os.makedirs("presets")

def download_file(url, save = False, filename = None):
	if(len(url.strip()) == 0):
		return
	response = requests.get(url)
	if not save:
		return response.text
	if filename is None:
		filename = url.split('/')[-1]
	with open(filename, "wb") as file:
		file.write(response.content)
	print(f"Saved {url} as {filename}.")

def get_correct_file(url, filename = None):
	if(filename is None):
		filename = url.split("/")[-1]
	if(not url.startswith(template_url)):
			page = download_file(url)
			val = re_js_reg.findall(str(page))[0]
			url = template_url + val
	fname = os.path.join("presets", f"{filename}.xml")
	download_file(url, True, fname)
	return fname

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

def download_sounds(xml_file):
	channels = parseXML(xml_file)
	for channel in channels:
		new_filename = channel["id_audio"]
		url = channel["url_audio"]
		ext = url.split('.')[-1]
		filename = os.path.join("sounds", f"{new_filename}.{ext}")
		filename_ogg = os.path.join("sounds", f"{new_filename}.ogg")
		if not(os.path.exists(filename) or os.path.exists(filename_ogg)):
			download_file(url, True, filename)

import argparse
if __name__ == "__main__":
	parser = argparse.ArgumentParser()
	parser.add_argument("url", help="URL of the ambient mix")
	args = parser.parse_args()
	makedirs()
	download_sounds(get_correct_file(args.url))
	subprocess.run(["dir2ogg", "sounds/", "--delete-input"])
