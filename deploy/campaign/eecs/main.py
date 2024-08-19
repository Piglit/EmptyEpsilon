#!/usr/bin/env python3
"""
This is the main executable of the eeCampaignServer.
It should start all the services
"""

import core
from models import crew
from outbound import log
from outbound import stationsComms
from interfaces import eehttp
from interfaces import crew_pyro 
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
	files = os.listdir("data/crews")
	for file in files:
		crew.loadCrew(file)

	# host crew edit pyro interface
	servers = crew_pyro.Crews()
	#Pyro4.util.SerializerBase.register_class_to_dict(crew.Crew, lambda c: c.__dict__)
	pyrohelper.host_named_server(servers, "campaign_crews")

	# host http interface
	uvicorn.run("main:eehttp.app", host="0.0.0.0", reload=False, port=8888)
	pyrohelper.cleanup()

