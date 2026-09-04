#!/usr/bin/env python3
import datetime
import requests

def exec(script, server="127.0.0.1:8080"):
	return requests.post(f'http://{server}/exec.lua', script, timeout=5).content == b''

def timesync(server):
	now = datetime.datetime.now()
	time = f"{now.hour}:{now.minute}"
	code = f"""return getScriptStorage().vf_timesync:sync_time_human_readable("{time}")"""
	exec(code, server=server+":8080")
	print(f"sent time '{time}' to {server}")

	code = f"""return getScriptStorage().vf_bescheid:sag_bescheid("init")"""
	exec(code, server=server+":8080")
	print(f"sent bescheid init")

timesync("192.168.2.4")
