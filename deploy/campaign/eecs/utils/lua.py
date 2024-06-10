"""ulilities for the use of lua code for EE"""

def exec(script, server="127.0.0.1:8080"):
	return requests.post(f'http://{server}/exec.lua', script).content == b''

def get(script, server="127.0.0.1:8080"):
	return requests.get(f'http://{server}/get.lua', script).content

