#!/usr/bin/python3
import subprocess
import time

with open("/proc/sys/net/ipv4/tcp_fin_timeout","w") as file:
	file.write("20")

print("starting launcher")
command = ["./serverLauncher.py"]
launcher = subprocess.Popen(command)

time.sleep(2)

print("starting selector")
command = ["./missionSelector.py"]
selector = subprocess.Popen(command)

selector.wait()
launcher.wait()

#scenario:
	# since i can not terminate a scenario after victory, the server controller must be able to stop the server
	# so no client on the server
