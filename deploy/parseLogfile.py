class GameState:

	def __init__(self):
		self.lastParsedLine = 0
		self.time = 0
		self.static = {}
		self.objects = {}

	def update(self, entry):
		if entry["type"] != "state":
			raise AttributeError(entry["type"])
		news = entry["new_static"]
		dels = entry["del_static"]
		objs = entry["objects"]
		self.time = entry["time"]
		for new in news:
			assert new["id"] not in self.static
			self.static[new["id"]] = new
		for d in dels:
			assert d in self.static
			print("del", d)
			del self.static[d]
		self.objects.clear()
		for o in objs:
			self.objects[o["id"]] = o

	def toList(self):
		return [*self.static.values(), *self.objects.values()]

	def parseLogfile(self):
		if self.gameLog is None:
			return {}
		files = list(filter(os.path.isfile, glob.glob("logs/game_log_*.txt")))
		files.sort(key=lambda x: os.path.getmtime(x))
		logfile = files[-1]
		with open(logfile, "rb") as file:
			startLineno = self.gameLog.lastParsedLine
			lineno = 0
			error = False
			for line in file:
				lineno += 1
				if lineno <= startLineno:
					continue
				if error:
					#error may only occure in the last line
					raise error
				try:
					self.gameLog.update(json.loads(line))
					self.gameLog.lastParsedLine = lineno
				except json.JSONDecodeError as e:
					#last one is usually corrupted
					error = e
		return self.gameLog

	def getGame(self):
		game = server.parseLogfile()
		return game.toList()

	def getTimeInGame(self):
		game = server.parseLogfile()
		return game.time

