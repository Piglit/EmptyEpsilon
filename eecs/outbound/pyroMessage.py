from utils import pyrohelper

def send(name, msg):
	pyrohelper.connect_to_named(name).recv(msg)

