"""A worker thread, that handles all the lua exec calls asynchronously to prevent deadlocks."""

from multiprocessing import Process, Queue
import time

from utils import lua

p = None
q = Queue()

def exec(script, server="127.0.0.1:8080", delay=0, callback=None, callbackArgs=[]):
	q.put(("exec", script, server, delay, callback, callbackArgs))
	

def work(q):
	while task := q.get():
		(function, script, server, delay, callback, callbackArgs) = task
		if delay:
			time.sleep(delay)
		ret = None
		if function == "exec":
			ret = lua.exec(script, server)
		if callback:
			callback(*callbackArgs, ret)
	

def start():
	global p
	p = Process(target=work, args=(q,))
	p.start()

def stop():
	q.put(None)
	p.join()
