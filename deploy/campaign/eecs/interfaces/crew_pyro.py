import Pyro4

@Pyro4.expose
class Crews:
	def __init__(self):
		self.crew_servers = {}

	def ping(self):
		return True

	def getCrew(self, instance_name, crew_name):
		if instance_name not in self.crew_servers:
			self.crew_servers[instance_name] = Crew(instance_name, crew_name)
			self.crew_servers[instance_name].setDefaultValues()
		return self.crew_servers[instance_name]

	def storeCrew(self, instance_name, crew):
		self.crew_servers[instance_name] = crew
		
