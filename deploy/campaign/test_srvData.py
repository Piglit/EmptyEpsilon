from srvData import servers

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
	assert "Phobos" in s["ships"]

def test_getScenarios():
	ret = servers.getScenarios(serverName)
	assert "20_training1" in ret

def test_getShips():
	ret = servers.getShips(serverName)
	assert "Phobos" in ret

def test_getScenarioVariations():
	servers.clearData()
	servers.unlockScenario(scenarioName, serverName, "var1")
	assert scenarioName in servers.getScenarios(serverName)
	assert "var1" in servers.getScenarioVariations(scenarioName, serverName)
	assert None not in servers.getScenarioVariations(scenarioName, serverName)
	servers.clearData()
	servers.unlockScenario(scenarioName, serverName)
	assert "var1" not in servers.getScenarioVariations(scenarioName, serverName)
	assert None in servers.getScenarioVariations(scenarioName, serverName)
	servers.unlockScenario(scenarioName, serverName, "var1")
	assert "var1" in servers.getScenarioVariations(scenarioName, serverName)
	assert None in servers.getScenarioVariations(scenarioName, serverName)
	servers.unlockScenario(scenarioName, serverName, "*")
	assert servers.getScenarioVariations(scenarioName, serverName) == ["*"]
	servers.clearData()
	servers.unlockScenario(scenarioName, serverName, ["var1", "var2"])
	assert "var1" in servers.getScenarioVariations(scenarioName, serverName)
	assert "var2" in servers.getScenarioVariations(scenarioName, serverName)

def test_unlockScenario():
	servers.unlockScenario(scenarioName, serverName)
	assert scenarioName in servers.getScenarios(serverName)
	servers.unlockScenario(scenarioName, serverName)
	assert servers.getScenarios(serverName).count(scenarioName) == 1

def test_unlockScenarios():
	servers.clearData()
	servers.unlockScenarios([scenarioName, scenarioName+"1", scenarioName, (scenarioName, "var2"), (scenarioName+"2", [None, "var1", "var2"])], serverName)
	assert scenarioName in servers.getScenarios(serverName)
	assert scenarioName+"1" in servers.getScenarios(serverName)
	assert servers.getScenarios(serverName).count(scenarioName) == 1
	assert None in servers.getScenarioVariations(scenarioName, serverName)
	assert "var2" in servers.getScenarioVariations(scenarioName, serverName)

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


