#!/usr/bin/env python3
"""
This is the main executable of the eeCampaignServer.
It should start all the services
"""

import core
from outbound import log
from outbound import stationsComms
from interfaces import eehttp
from interfaces import crew_pyro 
import campaign

from utils import pyrohelper

import uvicorn
import logging

logging.getLogger("uvicorn.access").handlers = []
logging.getLogger("uvicorn.access").propagate = False

if __name__ == "__main__":
	pyrohelper.start_nameserver()
	uvicorn.run("main:eehttp.app", host="0.0.0.0", reload=False, port=8888)
	pyrohelper.cleanup()
	servers = crew_pyro.Crews()
	pyrohelper.host_named_server(servers, "campaign_state")
