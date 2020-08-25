import Pyro4
import pytest
import lanctl

@pytest.fixture(scope="session", autouse=True)
def ctl():
	uri = lanctl.start()
	controller = Pyro4.Proxy(uri)
	yield controller
	lanctl.stop()

def test_ping(ctl):
	assert ctl.ping()

def test_getState(ctl):
	assert ctl.getState() == "default"

	
