
import Pyro4
import Pyro4.naming
import socket
import threading
from time import sleep

IP = None
NS = None

def get_ip():
	if IP:
		return IP
	s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
	try:
		# doesn't even have to be reachable	
		s.connect(('10.255.255.255', 1))	
		ip = s.getsockname()[0]	
	except:	
		ip = '127.0.0.1'	
	finally:	
		s.close()	
	return ip

def broadcast_recive_and_reply(callback, listenPort=35666):
	ip = get_ip()
		
	s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM | socket.SOCK_NONBLOCK)
	try:
		s.bind((ip, listenPort))
		while(s):
			data, addr = s.recvfrom(1024)
			resp = callback(data, addr)
			if resp:
				s.send(resp, addr)
	finally:	
		s.close()	
	return s

def get_nameserver(host=None):
	global NS
	if NS and NS.ping():
		return NS
	try:
		NS = Pyro4.locateNS(host)
	except Pyro4.errors.NamingError:
		NS = None
	return NS

def start_nameserver():
	# no other nameserver must be running on the network!! 
	# start our own nameserver
	# we could as well look for an existing nameserver before; but waiting for the timeout makes things go slow
	global NS
	ip = get_ip()
	threading.Thread(target=Pyro4.naming.startNSloop, kwargs={"host": ip}).start()
	nameserver = None 
	failcount = 0
	while not nameserver and failcount < 3:
		nameserver = get_nameserver(host=ip)	# host is optional; if not given, use UDP bradcast to find it
		if not nameserver:
			sleep(0.1)
			failcount += 1
	nameserver.ping()
	NS = nameserver
	return nameserver

def host_named_server(register_class, name, port=0):
	#set port for autoreconnect.
	if port != 0:
		uri = host(register_class, port=port, objectId=name)
	else:
		uri = host(register_class)
	nameserver = get_nameserver()
	if nameserver:
		nameserver.register(name,uri)
		print('Pyro server running on ' + get_ip() +'. Connect custom python clients with Pyro4.Proxy("PYRONAME:'+name+'")')
	else:
		print('Could not find Pyro naming server. Connect with Pyro4.Proxy("'+str(uri)+'")')

def host(exposed_class, port=0, objectId=None):
	ip = get_ip()
	daemon = Pyro4.Daemon(host=ip, port=port)
	uri = daemon.register(exposed_class, objectId=objectId)
	threading.Thread(target=daemon.requestLoop).start()	# start the event loop of the server to wait for calls
	return uri

def connect(uri):
	connection = Pyro4.Proxy(uri)
	connection.ping()
	return connection

def connect_to_named(name):
	return connect("PYRONAME:"+name)
	
