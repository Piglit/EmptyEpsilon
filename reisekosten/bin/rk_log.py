#!/usr/bin/env python3
"""log sink, where all logs get displayed. Should be visible to GM without efford."""

import pyrohelper
import Pyro4

import logging
import coloredlogs
log = logging.getLogger(__name__)
coloredlogs.install(level="DEBUG", logger=log, fmt="%(asctime)s\t%(levelname)s:\t%(message)s", datefmt="%H:%M:%S")

@Pyro4.expose
class RKLogger:
	
	def ping(self):
		return True

	def debug(self, msg):
		log.debug(msg)

	def info(self, msg):
		log.info(msg)

	def warning(self, msg):
		log.warning(msg)

	def error(self, msg):
		log.error(msg)

	def critical(self, msg):
		log.critical(msg)

rk_log = RKLogger()

if __name__ == "__main__":
	pyrohelper.host_named_server(rk_log, "rk_log", 8003)
