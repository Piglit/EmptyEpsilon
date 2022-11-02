from serverControl import servers

serverName = "testserver"
scenarioName = "00_test"
shipName = "Testship"

def test_clearData():
	servers.getOrCreateServer(serverName)
	servers.clearData()
	assert not servers.servers

def test_getOrCreateSrv():
	s = servers.getOrCreateServer(serverName)
	t = servers.getOrCreateServer(serverName)
	assert s == t
	assert "ships" in s
	assert "Phobos M3P" in s["ships"]

def test_getScenarios():
	ret = servers.getScenarios(serverName)
	assert "20_training1" in ret

def test_getShips():
	ret = servers.getShips(serverName)
	assert "Phobos M3P" in ret

def test_getScenarioSettings():
	servers.clearData()
	servers.unlockScenario(scenarioName, serverName, {"setting1": ["a","b","c"]})
	assert scenarioName in servers.getScenarios(serverName)
	assert "setting1" in servers.getScenarioSettings(scenarioName, serverName)
	servers.clearData()
	servers.unlockScenario(scenarioName, serverName)
	assert "setting1" not in servers.getScenarioSettings(scenarioName, serverName)
	assert {} == servers.getScenarioSettings(scenarioName, serverName)
	servers.unlockScenario(scenarioName, serverName, {"setting1": []})
	assert "setting1" in servers.getScenarioSettings(scenarioName, serverName)
	servers.clearData()
	servers.unlockScenario(scenarioName, serverName, {"setting1": ["a","b","c"]})
	servers.unlockScenario(scenarioName, serverName, {"setting1": ["b","d"]})
	servers.unlockScenario(scenarioName, serverName, {"setting2": ["a"]})
	assert "setting1" in servers.getScenarioSettings(scenarioName, serverName)
	assert "setting2" in servers.getScenarioSettings(scenarioName, serverName)
	assert "a" in servers.getScenarioSettings(scenarioName, serverName)["setting1"]
	assert "b" in servers.getScenarioSettings(scenarioName, serverName)["setting1"]
	assert "c" in servers.getScenarioSettings(scenarioName, serverName)["setting1"]
	assert "d" in servers.getScenarioSettings(scenarioName, serverName)["setting1"]

def test_unlockScenario():
	servers.unlockScenario(scenarioName, serverName)
	assert scenarioName in servers.getScenarios(serverName)
	servers.unlockScenario(scenarioName, serverName)
	assert servers.getScenarios(serverName).count(scenarioName) == 1

def test_unlockScenarios():
	servers.clearData()
	servers.unlockScenarios([scenarioName, scenarioName+"1", scenarioName, (scenarioName, {}), (scenarioName+"2", {"Difficulty": ["default"]}), (scenarioName+"3", {"Difficulty": ["easy", "hard"], "Time": []})], serverName)
	assert scenarioName in servers.getScenarios(serverName)
	assert scenarioName+"1" in servers.getScenarios(serverName)
	assert servers.getScenarios(serverName).count(scenarioName) == 1
	assert len(servers.getScenarioSettings(scenarioName, serverName)) == 0
	assert "Difficulty" not in servers.getScenarioSettings(scenarioName, serverName)
	assert "Difficulty" in servers.getScenarioSettings(scenarioName+"2", serverName)

def test_unlockShip():
	servers.unlockShip(shipName, serverName)
	assert shipName in servers.getShips(serverName)
	servers.unlockShip(shipName, serverName)
	assert servers.getShips(serverName).count(shipName) == 1

def test_unlockShips():
	servers.unlockShips([shipName, shipName+"1", shipName], serverName)
	assert shipName in servers.getShips(serverName)
	assert shipName+"1" in servers.getShips(serverName)
	assert servers.getShips(serverName).count(shipName) == 1

def test_store_and_load():
	servers.getOrCreateServer("stored")
	servers.storeData()
	servers.servers = None
	servers.loadData()
	assert "stored" in servers.servers

def test_setStatus():
	servers.getOrCreateServer("Testserver")
	assert "idle" == servers.getStatus("Testserver")
	servers.setStatus("testing", "Testserver")
	assert "testing" == servers.getStatus("Testserver")
	assert "idle" == servers.getStatus("Testserver2")
	entries = servers.getStatusAll()
	assert "Testserver" in entries
	assert "Testserver2" in entries
	assert "Hurz!" not in entries
	print(entries)

