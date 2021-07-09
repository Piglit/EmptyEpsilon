#!/usr/bin/python3

import socket
import time

hostname = socket.gethostname()
while hostname == "pxeclient" or hostname == "localhost":
	print("waiting for hostname change")
	time.sleep(1)
	hostname = socket.gethostname()

