from utils import pyrohelper
from outbound.log import log
import Pyro4

def send(name, msg):
    try:
        pyrohelper.connect_to_named(name).recv(msg)
    except Pyro4.errors.NamingError as e:
        log.error(f"pyro connect failed: {e}")
        

