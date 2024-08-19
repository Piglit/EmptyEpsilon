"""ulilities for the use of lua code for EE"""

import requests

def exec(script, server="127.0.0.1:8080"):
	return requests.post(f'http://{server}/exec.lua', script, timeout=5).content == b''

def get(script, server="127.0.0.1:8080"):
	return requests.get(f'http://{server}/get.lua', script, timeout=5).content

