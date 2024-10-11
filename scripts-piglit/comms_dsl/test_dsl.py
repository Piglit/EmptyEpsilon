import pytest
import string
import datetime
from dsl import *
from dsl import dialog_option as O
from dsl import dialog_effect as E
from dsl import dialog_condition as C
from dsl import dialog_target as T
from dsl import dialog_link as L
from dsl import conditional_dialog_option as CO

def compare(s1, s2, ignore="\t"):
	mapping = {}
	if ignore == "whitespace":
		mapping = {ord(c): None for c in string.whitespace}
	elif ignore == "\t":
		mapping = {ord("\t"): None}

	return s1.translate(mapping) == s2.translate(mapping)

def test_dialog_option_simple():
	d = dialog_option("test", "text")
	expected = """addCommsReply("test", function(source, target)
		sendCommsMessage("text")
	end)
	"""
	assert compare(d.lua(), expected)

	assert compare(O("test", "text").lua(), expected)


def test_dialog_option_nested():
	d = O("test", "text", [
		O("l2a", "level 2 option a"),
		O("l2b", "level 2 option b"),
	])
	expected = """addCommsReply("test", function(source, target)
		sendCommsMessage("text")
		addCommsReply("l2a", function(source, target)
			sendCommsMessage("level 2 option a")
		end)
		addCommsReply("l2b", function(source, target)
			sendCommsMessage("level 2 option b")
		end)
	end)
	"""
	assert compare(d.lua(), expected)

def test_dialog_option_jump():
	d = dialog_target("conclusion", "default", "text")
	expected = """function ct_conclusion(source, target)
		sendCommsMessage("text")
	end
	"""
	assert compare(d.lua(), expected)

	with pytest.raises(Exception) as e_info:
		d = dialog_target("conclusion", "default", "text")
	assert e_info.value.args[0].endswith("already exists.")

	d = dialog_link("conclusion", "test")
	expected = """addCommsReply("test", ct_conclusion)\n"""
	assert compare(d.lua(), expected)

	with pytest.raises(KeyError) as e_info:
		d = dialog_link("nope", "test")
		d.prepare()
	assert e_info.value.args[0] == "dialog_target 'nope' was not defined."

	d = dialog_link("conclusion")
	expected = """addCommsReply("default", ct_conclusion)\n"""
	assert compare(d.lua(), expected)

	dialog_target.targets.clear()	# clean up class var

def test_dialog_option_effect():
	e = E("player.res + 1")
	expected = """source:increaseResourceAmount("res", 1)\n"""
	assert compare(e.lua(), expected)

	e = E("object.res - 1")
	expected = """target:decreaseResourceAmount("res", 1)\n"""
	assert compare(e.lua(), expected)

	e = E("player.res = 1")
	expected = """source:setResourceAmount("res", 1)\n"""
	assert compare(e.lua(), expected)

	d = O("test", "text", [
		E("player.stuff+ 1"),
		O("l2a", "level 2 option a"),
		E("object.stuff -1"),
	])
	expected = """addCommsReply("test", function(source, target)
		sendCommsMessage("text")
		source:increaseResourceAmount("stuff", 1)
		target:decreaseResourceAmount("stuff", 1)
		addCommsReply("l2a", function(source, target)
			sendCommsMessage("level 2 option a")
		end)
	end)
	"""
	assert compare(d.lua(), expected)

def test_dialog_option_condition():
	c = C("player.stuff > 1")
	expected = """source:getResourceAmount("stuff") > 1"""
	assert compare(c.lua(), expected)

	c = C("player.stuff >= object.foo")
	expected = """source:getResourceAmount("stuff") >= target:getResourceAmount("foo")"""
	assert compare(c.lua(), expected)

	c = C("1!=2")
	expected = """1 ~= 2"""
	assert compare(c.lua(), expected)

	c = C("1 =  2")
	expected = """1 == 2"""
	assert compare(c.lua(), expected)

	c = C("1 =  2") & C("1!=2")
	expected = """(1 == 2) and (1 ~= 2)"""
	assert compare(c.lua(), expected)

	c = C("1 =  2") | C("1!=2")
	expected = """(1 == 2) or (1 ~= 2)"""
	assert compare(c.lua(), expected)

	c = C("1 =  2") & C("1!=2") | C("1>=2")
	expected = """(1 == 2) and (1 ~= 2) or (1 >= 2)"""
	assert compare(c.lua(), expected)

	c = C("1 =  2") | C("1!=2") & C("1>=2")
	expected = """(1 == 2) or (1 ~= 2) and (1 >= 2)"""
	assert compare(c.lua(), expected)

	d = conditional_dialog_option(C("P.stuff>=100"), "test", "text", [
		E("P.stuff-100")
	])
	expected = """if (source:getResourceAmount("stuff") >= 100) then
	addCommsReply("test", function(source, target)
		sendCommsMessage("text")
		source:decreaseResourceAmount("stuff", 100)
	end)
end
	"""
	assert compare(d.lua(), expected)

def test_dialog_option_jump_condition():
	d = dialog_target("conclusion", "default", "text")
	expected = """function ct_conclusion(source, target)
		sendCommsMessage("text")
	end
	"""
	assert compare(d.lua(), expected)

	d = conditional_dialog_link(C("1!=1"), "conclusion", "test")
	expected = """if (1 ~= 1) then
	addCommsReply("test", ct_conclusion)
end
"""
	assert compare(d.lua(), expected)
	dialog_target.targets.clear()	# clean up class var

def test_add_dialog():
	d = O("test", "text")
	s = station()
	s.add_dialog(d)

	expected = """table.insert(getStation("").comms_data.comms_functions, function(source, target)
	addCommsReply("test", function(source, target)
		sendCommsMessage("text")
	end)
end)
"""
	assert compare(s.lua(), expected, ignore="whitespace")

	s.add_dialog(O("test2", "text2"))
	expected = """table.insert(getStation("").comms_data.comms_functions, function(source, target)
	addCommsReply("test", function(source, target)
		sendCommsMessage("text")
	end)
	addCommsReply("test2", function(source, target)
		sendCommsMessage("text2")
	end)
end)
"""
	assert s.lua() == expected
	#assert compare(s.lua(), expected, ignore="whitespace")

	s = station("some tag")
	expected = """table.insert(getStation("some tag").comms_data.comms_functions, function(source, target)
end)
"""
	assert s.lua() == expected

	s = station("some tag", "other")
	expected = """table.insert(getStation("some tag,other").comms_data.comms_functions, function(source, target)
end)
"""
	assert s.lua() == expected
	station.stations.clear()	# clean up class var


def test_create():
	date = datetime.datetime.now().date()
	script = generate()
	expected = f"""--[[test_dsl
generated by dsl.py from test_dsl.py on {date}
--]]

"""
	assert script.lua() == expected

	d = dialog_target("conclusion", "default", "text")
	expected += """function ct_conclusion(source, target)
	sendCommsMessage("text")
end

"""
	script = generate()
	assert script.lua() == expected

	d = dialog_target("conclusion2", "default", "text")
	expected += """function ct_conclusion2(source, target)
	sendCommsMessage("text")
end

"""
	script = generate()
	assert script.lua() == expected

	s = station("some tag", "other")
	expected += """table.insert(getStation("some tag,other").comms_data.comms_functions, function(source, target)
end)

"""
	script = generate()
	assert script.lua() == expected

	s = station("another station")
	expected += """table.insert(getStation("another station").comms_data.comms_functions, function(source, target)
end)

"""
	script = generate()
	assert script.lua() == expected

	dialog_target.targets.clear()	# clean up class var
	station.stations.clear()	# clean up class var

	script = generate("Me", "Some test script")
	expected = f"""--[[test_dsl
generated by dsl.py from test_dsl.py on {date}
Author: Me

Some test script
--]]

"""
	assert script.lua() == expected


def test_analyse_resources():
	e = E("player.res = 1")
	expected = {"player.res"}
	assert e.resources() == expected

	e = E("source.res = player.res")
	expected = {"player.res"}
	assert e.resources() == expected

	c = C("target.stuff > 1")
	expected = {"target.stuff"}
	assert c.resources() == expected

	c = C("station.stuff > ship.stuff")
	expected = {"target.stuff"}
	assert c.resources() == expected

	c = C("P.a = 2")
	expected = {"player.a"}
	assert c.resources() == expected

	c = C("S.b = P.b")
	expected = {"player.b", "target.b"}
	assert c.resources() == expected

	c = C("2 = S.c")
	expected = {"target.c"}
	assert c.resources() == expected
	
	c = C("P.a = 2") | C("S.b != P.b") & C("2 >= S.c")

	expected = {"player.a", "target.b", "player.b", "target.c"}
	assert c.resources() == expected

	d = O("test", "text", [
		E("player.stuff+ 1"),
		E("object.stuff -1"),
	])
	expected = {"player.stuff", "target.stuff"}
	assert d.resources() == expected

	d = conditional_dialog_option(C("P.stuff>=100"), "test", "text", [])

	expected = {"player.stuff"}
	assert d.resources() == expected

	s = station()
	s.add_dialog(d)
	assert s.resources() == expected

	station.stations.clear()	# clean up class var

def test_update_resources():
	d = O("test", "text", [
		E("player.HVLI + 1"),
		CO(C("player.REP >= 100") & C("target.HOMING = 1"), "test2", "text2", [
			E("player.HOMING = 1"),
			CO(C("player.REP >= 100"), "x", "y", []),
		]),
	])
	expected = {"player.HVLI", "player.REP", "target.HOMING"}
	assert d.resources(False) == expected


def test_arithmetic():
	d = CO(C("player.HVLI < player.HVLI_MAX"), "buy HVLIs", "Bought HVLIs", [
		E("player.REP - ((player.HVLI_MAX - player.HVLI) * station.hvli_cost)"),
		E("player.HVLI = player.HVLI_MAX"),
	])

	expected = {"player.HVLI", "player.HVLI_MAX", "player.REP", "target.hvli_cost"}
	assert d.resources(False) == expected
