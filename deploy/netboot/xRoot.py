#!/usr/bin/python3
import subprocess
import time

with open("/proc/sys/net/ipv4/tcp_fin_timeout","w") as file:
	file.write("20")

state = None
try: 
	with open("state","r") as file:
		state = file.readline().strip()
except:
	pass

if state is None:
	print("starting ee")
	command = ["./EmptyEpsilon"]
	process = subprocess.Popen(command, cwd="../..")
	process.wait()

if state == "escpae":
	print("starting escape")
	pass

if state == "server":
	print("starting server")
	command = ["./EmptyEpsilon", "campaign_server=192.168.2.3:8888", "alternative_server=1"]
	process = subprocess.Popen(command, cwd="../..")
	process.wait()

if state == "proxy":
	print("starting proxy")
	pass

if state == "client":
	print("starting client")
	command = ["./EmptyEpsilon", "campaign_server=''", "alternative_server=0"]
	process = subprocess.Popen(command, cwd="../..")
	process.wait()

#print("starting launcher")
#command = ["./serverLauncher.py"]
#launcher = subprocess.Popen(command)

#time.sleep(2)
#
#print("starting selector")
#command = ["./missionSelector.py"]
#selector = subprocess.Popen(command)

#selector.wait()



#scenario:
	# since i can not terminate a scenario after victory, the server controller must be able to stop the server
	# so no client on the server
