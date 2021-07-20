import luaproxy
from fastapi.testclient import TestClient

testClient = TestClient(luaproxy.proxy)

def test_root():
	response = testClient.get("/")
	assert response.status_code == 200, response.reason
	assert response.json() == {"message": "Hello Space"}

def test_get():
	query = "power=getSystemPower('reactor')&coolant=getSystemCoolant('reactor')"
	response = testClient.get("/get/Testship?"+query)
	assert response.status_code == 200, response.reason
	#assert response.json() == {"EE-Query": "_OBJECT_=getPlayerShip(-1)&"+query}, response.json()

def test_command():
	query = "power=commandSetSystemPower('reactor', 200.0)&coolant=commandSetSystemCoolant('reactor', 200.0)"
	response = testClient.get("/command/Testship?"+query)
	assert response.status_code == 200, response.reason

def test_spawn():
	query = "setCallsign('Testship')&setTemplate('Hathcock')"
	response = testClient.get("/spwan?"+query)
	assert response.status_code == 200, response.reason
