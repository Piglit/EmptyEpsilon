import pytest
import string
from dsl import *
from dsl import dialog_option as O
from dsl import dialog_effect as E
from dsl import dialog_condition as C

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
	e = E("player", "res", "+", 1)
	expected = """source:increaseResourceAmount("res", 1)\n"""
	assert compare(e.lua(), expected)

	e = E("object", "res", "-", 1)
	expected = """target:decreaseResourceAmount("res", 1)\n"""
	assert compare(e.lua(), expected)

	e = E("player", "res", "=", 1)
	expected = """source:setResourceAmount("res", 1)\n"""
	assert compare(e.lua(), expected)

	d = O("test", "text", [
		E("player", "stuff", "+", 1),
		O("l2a", "level 2 option a"),
		E("object", "stuff", "-", 1),
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
		E("P", "stuff", "-", 100)
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

