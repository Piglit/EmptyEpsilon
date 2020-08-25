"""ulilities for the use of lua code for EE"""

import requests

def sanitize_lua_string(string):
	# the good
	string = string.translate(str.maketrans({
		"'": "`",
		'"': "``",
		"ä": "ae",
		"ö": "oe",
		"ü": "ue",
		"Ä": "AE",
		"Ö": "OE",
		"Ü": "UE",
	}))
	# the whitelist
	return "".join(c for c in string if (c.isalnum() and c.isascii()) or c in " .,:;-_#+*!$%&()=?[]`")

def exec(script, server="127.0.0.1:8080"):
	return requests.post(f'http://{server}/exec.lua', script, timeout=5).content == b''

def get(script, server="127.0.0.1:8080"):
	return requests.get(f'http://{server}/get.lua', script, timeout=5).content

