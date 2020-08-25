"""The core interface. Those functions are called from all the interfaces."""

subscriptions = {}

def subscribe(event, fun):
	if event not in subscriptions:
		subscriptions[event] = []
	subscriptions[event].append(fun)

def unsubscribe(event, fun):
	if event not in subscriptions:
		return
	try:
		subscriptions[event].remove(fun)
	except ValueError:
		pass

# topics

def activity(crew, what, event=None, scenario=None):
	for sub in subscriptions.get("activity",[]):
		sub(crew, what, event=event, scenario=scenario)
	if event and scenario:
		scenario_event(scenario, crew, event.value)

def progress(crew, what, scenario, prog):
	for sub in subscriptions.get("progress",[]):
		sub(crew, what, scenario=scenario, details=prog)
	scenario_event(scenario, crew, "progress", details=prog)

def script_message(crew, scenario, topic, details):
	for sub in subscriptions.get("script_message",[]):
		sub(crew, scenario, topic, details)
	scenario_event(scenario, crew, topic, details=details)

def scenario_event(scenario, crew, event_topic, details={}):
	for sub in subscriptions.get("scenario_event",[]):
		sub(scenario, crew, event_topic, details=details)

