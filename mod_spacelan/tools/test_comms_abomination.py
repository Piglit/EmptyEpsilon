import lupa
import pytest
import os
import random
import subprocess

lua = lupa.LuaRuntime()
BASEPATH = os.path.dirname(__file__) + "/../"

def lua_require(filename):
	"""loads and executes the code of the given lua file"""
	filename = BASEPATH + filename
	print("REQUIRE",filename)
	try: 
		with open(filename, "r") as file:
			code = file.read()
			lua.execute(code)
	except Exception as e:
		raise
		print(e)

lua.execute("TEST = true params = {...} require = params[1]", lua_require)
g = lua.globals()

messages = []
replies = []

def lua_setCommsMessage(message):
#	print(message)
	messages.append(message)

def lua_addCommsReply(message, callback):
#	print(message)
	replies.append((message, callback))

class lua_SpaceObject():
	def setCommsFunction(self,cb):
		cb({},{})

lua.execute("params = {...} setCommsMessage = params[1] addCommsReply = params[2] SpaceObject = params[3]", lua_setCommsMessage, lua_addCommsReply, lua_SpaceObject)

# Base tests

@pytest.fixture(scope="session")
def comms_abomination():
	lua_require("plots/comms_abomination.lua")

def test_new(comms_abomination):
	lua.execute("""ca = CommsAbomination:new{{}}""")
	assert (g.ca)

def test_can_select(comms_abomination):
	lua.execute("""ret = ca:can_select()""")
	assert (g.ret == True)


def test_select_choice_line(comms_abomination):
	lua.execute("""ret = ca:select_choice_line({})""")
	assert (type(g.ret) == str)

def test_select_message_and_effect(comms_abomination):
	lua.execute("""msg, eff = ca:select_message_and_effect({})""")
	assert (type(g.msg) == str)
#	assert (isinstance(g.eff, lupa._lupa.LuaFunction))

def test_handle_effect(comms_abomination):
	lua.execute("""env = {} eff(env)""")

def test_call(comms_abomination):
	assert(len(messages) == 0)
	lua.execute("""ca:_call({source={}})""")
	assert(len(messages) == 1)

def test_show_choices(comms_abomination):
	assert(len(replies) == 0)
	lua.execute("""ca:_show_choices({})""")
	assert(len(replies) == 0)
	lua.execute("""ca:add_choice(ca)""")
	lua.execute("""ca:_show_choices({})""")
	assert(len(replies) == 1)
	replies[0][1]()
	assert(len(messages) == 2)

def test_select_choice(comms_abomination):
	lua.execute("""cb = ca:_select_choice({test=true}, ca)""")
	lua.execute("""cb({},{})""")

# subclass tests

def test_sublcass(comms_abomination):
	assert(len(g.ca.choices) == 1)
	lua.execute("""sub = ca:new({choice_line = "tcl", message = "tm", effect = function(env) env.test = true end})""")
	assert(len(g.ca.choices) == 1)
	assert(len(g.sub.choices) == 0)
	lua.execute("""sub:add_choice(ca)""")
	assert(len(g.sub.choices) == 1)
	assert(len(g.ca.choices) == 1)
	lua.execute("""function sub:can_select(env) return false end""")
	lua.execute("""ret = ca:can_select()""")
	assert (g.ret == True)
	lua.execute("""ret = sub:can_select()""")
	assert (g.ret == False)
	lua.execute("""ret = sub:select_choice_line({})""")
	assert (g.ret == "tcl")
	lua.execute("""msg, eff = sub:select_message_and_effect({})""")
	assert (g.msg == "tm")
	env = {"test":False}
	g.eff(env)
	assert(env['test'] == True)

def test_instances(comms_abomination):
	lua.execute("""instances = CommsAbomination.instances""")
	for instance in g.instances.values():
		# you always have to pass the instance as first argument 'self'
		instance.test(instance, {})

def test_setAsCommsFunction(comms_abomination):
	lua.execute("""ep = CommsEntryPoint:new()""")
	lua.execute("""ep:add_choice(ca)""")
	lua.execute("""ep:setAsCommsFunction(SpaceObject())""")

def test_super(comms_abomination):
	lua.execute("""s1 = CommsAbomination:new()""")
	lua.execute("""function s1:super_test() return "1" end""")
	assert(g.s1.super_test(g.s1) == "1")
	lua.execute("""s2 = s1:new()""")
	lua.execute("""function s2:super_test() return "2" end""")
	assert(g.s1.super_test(g.s1) == "1")
	assert(g.s2.super_test(g.s2) == "2")
	lua.execute("""s3 = s2:new()""")
	lua.execute("""function s3:super_test() return s3.super().super_test(self) .. "3" end""")
	assert(g.s1.super_test(g.s1) == "1")
	assert(g.s2.super_test(g.s2) == "2")
	assert(g.s3.super_test(g.s3) == "23")
	lua.execute("""s4 = s3:new()""")
	lua.execute("""function s4:super_test() return s4.super().super_test(self) .. "4" end""")
	assert(g.s1.super_test(g.s1) == "1")
	assert(g.s2.super_test(g.s2) == "2")
	assert(g.s3.super_test(g.s3) == "23")
	assert(g.s4.super_test(g.s4) == "234")
	lua.execute("""s5 = s4:new()""")
	assert(g.s4.super_test(g.s4) == "234")
	assert(g.s5.super_test(g.s5) == "234")

def test_coverage():
	cmd = ["rm", "luacov.stats.out"]
	subprocess.run(cmd, cwd=BASEPATH+"plots")
	cmd = ["lua", "-e", "TEST=true MOCKAPI=true RUNTESTS=true", "-lluacov", "comms_abomination.lua"]
	subprocess.run(cmd, cwd=BASEPATH+"plots", check=True)
	cmd = ["luacov", "comms_abomination.lua"]
	subprocess.run(cmd, cwd=BASEPATH+"plots")

