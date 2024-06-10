import pytest
from models.scenario import Scenario

def test_scenario():
	s = Scenario("scenario_00_basic.lua")
	assert s.name == "Basic Battle"
	assert s.categories == ["Basic"]
	assert s.settings
	assert s.scriptId == "00_basic"
	assert s.gmId == "basic"
