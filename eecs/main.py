#!/usr/bin/env python3
"""
This is the main executable of the eeCampaignServer.
It should start all the services
"""

import core
from models import crew
from outbound import log
from outbound import stationsComms
from outbound import luaExecutor
from interfaces import eehttp
from interfaces import pyro 
import campaign

import Pyro4
from utils import pyrohelper

import uvicorn
import logging
import os

logging.getLogger("uvicorn.access").handlers = []
logging.getLogger("uvicorn.access").propagate = False

if __name__ == "__main__":
	#pyrohelper.start_nameserver()
	# load stored crews
	os.makedirs("data/crews", exist_ok=True)
	files = os.listdir("data/crews")
	for file in files:
		crew.loadCrew(file)

	# start luaExecutor
	luaExecutor.start()

	# host crew edit pyro interface
	crews = pyro.Crews()
	scenarios = pyro.Scenarios()
	pyrohelper.host_named_server(crews, "campaign_crews")
	pyrohelper.host_named_server(scenarios, "campaign_scenarios")

	# host http interface
	uvicorn.run("main:eehttp.app", host="0.0.0.0", reload=False, port=8888)

	# shutdown
	pyrohelper.cleanup()
	luaExecutor.stop()
