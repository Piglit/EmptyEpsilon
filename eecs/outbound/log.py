"""Logs activities to command line"""
import core
import logging
import coloredlogs

log = logging.getLogger(__name__)
coloredlogs.install(level="DEBUG", fmt="%(asctime)s\t%(levelname)s:\t%(message)s", datefmt="%H:%M:%S")
logging.getLogger("asyncio").setLevel(logging.WARNING)

#log.setLevel("INFO")
#log.addHandler(h)
#import uvicorn
#logging.getLogger("uvicorn.access").handlers = []
#logging.getLogger("uvicorn.access").propagate = False

def log_activity(crew, what, **kwargs):
	log.info(f"{crew}\t{what}")

def log_script_message(crew, scenario, topic, details):
	log.info(f"{crew}\tin {scenario} caused {topic}")
	log.debug(f"\t{details}")

core.subscribe("activity", log_activity)
core.subscribe("progress", log_activity)
core.subscribe("script_message", log_script_message)
