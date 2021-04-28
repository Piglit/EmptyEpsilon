import pytest
from parse_lua_plots import *
from luaparser import ast

def test_get_functions():
	l = """
		function foo(arg1, arg2)
			a = 1
			return a
		end
		"""
	tree = ast.parse(l)
	ret = get_functions(tree)
	assert len(ret) == 1
	assert ret["foo"].name.id == "foo"

	l2 = """
		function foo()
			function bar()
			end
		end
		"""
	tree = ast.parse(l2)
	with pytest.raises(AssertionError, match=r"visitor and block function mismatch. Do you use nested functions?"):
		ret = get_functions(tree)

	l3 = """
		function foo()
		end

		function foo()
		end
		"""
	tree = ast.parse(l3)
	with pytest.raises(AssertionError, match=r"number of functions and function names does not match. Do you have functions with the same name?"):
		ret = get_functions(tree)

def test_get_names():
	l = """
		function foo(arg1, arg2)
			local loc
			var = 1
			indir.sec = nue
			inv:meth(b)
			fun(c)
			return b.a
		end
		"""
	tree = ast.parse(l)
	ret = get_names(tree)
	names = {"foo","arg1","arg2","loc","var","indir","sec","nue","inv","meth","b","fun","c","a"}
	assert ret == names

def test_get_global_assignments():
	l = """
		function foo(arg1, arg2)
			local loc
			var = 1
			indir.sec = nue
			inv:meth(b)
			fun(c)
			bra[ket] = 27
			return b.a
		end
		"""
	tree = ast.parse(l)
	ret = get_global_assignments(tree)
	names = {"var", ("indir", "sec", "."), ("bra", "ket", "[")}
	assert ret.keys() == names

def test_get_local_names():
	l = """
	function foo(arg1, arg2)
		local loc
		var = 1
		indir.sec = nue
		inv:meth(b)
		fun(c)
		for f1, f2 in ipairs(stuff) do
			f1 = f1 +2
		end
		for x = 1,5 do
		end
		return b.a
	end
	"""
	tree = ast.parse(l)
	funs = get_functions(tree)
	assert len(funs) == 1
	fun = funs["foo"]
	ret = get_local_names(fun)
	names = {"arg1","arg2","loc","f1","f2","x"}
	assert ret == names

	all_names = get_names(tree)
	assert names < all_names

def test_load_global_names():
	names = GLOBAL_NAMES
	assert "_" in names
	assert "foobar" not in names
	l = """
	function foo(arg1, arg2)
		local loc
		var = 1
		indir.sec = nue
		inv:meth(b)
		fun(c)
		_("str")
		return b.a
	end
	"""
	tree = ast.parse(l)
	ret = get_names(tree)
	assert "_" in ret
	assert "_" not in ret - names


def test_get_indirect_names():
	l = """
	function foo(arg1, arg2)
		local loc
		var = 1
		indir.sec = nue
		inv:meth(b)
		fun(c)
		_("str")
		eight = first:second(third(fourth, fifth).sixth(seventh))
		z = bra[ket]
		return b.a
	end

	function bar.buzz()

	end
	"""
	tree = ast.parse(l)
	funs = get_functions(tree)
	assert len(funs) == 2
	assert "bar.buzz" in funs
	fun = funs["foo"]
	ret = get_indirect_names(fun)
	names = {"indir": {("sec", ".")}, "inv": {("meth", ":")}, "first": {("second", ":")}, "b": {("a", ".")}, "third(fourth,fifth)": {("sixth", ".")}, "bra": {("ket", "[")}}
	primary = set(names.keys())
	primary2 = set(ret.keys())
	assert primary == primary2
	for key in names:
		assert ret[key] == names[key]

def test_analyse_functions():
	code = """
		function sample1(param1, param2)
			local localvar
			player:isDocked()
			string.format(_("Test"))
		end
		function plot.sample2(param)
			local f
			a = 1
			b.c = 2
			d[e] = 3
			f = 4
		end
	"""
	scenario = Scenario(code)
	summary = scenario.analyse_functions()
	assert summary["sample1"]["Local variables"] == {"param1", "param2", "localvar"}
	assert summary["sample1"]["API calls"] == {"string", "format", "_", "isDocked"}
	assert summary["sample1"]["Methods"] == {"player": [("isDocked", ":")]}
	assert summary["sample1"]["Attributes"] == {"string": [("format", ".")]}
	assert summary["sample1"]["Assignments"] == {}
	assert summary["sample1"]["Global variables"] == {"player", "sample1"}

	assert summary["plot.sample2"]["Local variables"] == {"param", "f"}
	assert summary["plot.sample2"]["API calls"] == set()
	assert summary["plot.sample2"]["Methods"] == dict()
	assert summary["plot.sample2"]["Attributes"] == {"plot": [("sample2", ".")], "b": [("c", ".")], "d": [("e", "[")]}
	assert summary["plot.sample2"]["Assignments"].keys() == {"a", ("b", "c", "."), ("d", "e", "[")}
	assert summary["plot.sample2"]["Global variables"] == {"plot", "a", "b", "d"}

def test_global_vars_from_chunk():
	code = """
		function sample1(param1, param2)
			local localvar
			player:isDocked()
			string.format(_("Test"))
		end
		function plot.sample2(param)
			local f
			a = 1
			b.c = 2
			d[e] = 3
			f = 4
		end
	"""
	plot = Plot(code, "tst")
	summary = plot.get_global_vars()
	assert summary == {"sample1", "player", "plot", "a", "b", "d"} #, "e"}	FIXME


def test_analysis_printable():
	summary = dict()
	summary["Methods"] = {
		"player": [("isDocked", ":")],
		("player", "meth", "."): [("isValid", ":"), ("stuff", ":")]
	}
	summary["Attributes"] = {
		"string": [("format", ".")],
		"stuffs": [("idx", "[")]
	}
	summary = analysis_printable(summary)
	assert summary["Methods"] == {"player": ":isDocked", "player.meth": [":isValid", ":stuff"]}
	assert summary["Attributes"] == {"string": ".format", "stuffs": "[idx"}
	
def test_indir_tuple_to_str():
	t = ("a", "b", ".")
	r = indir_tuple_to_str(t)
	assert r == "a.b"
	t = (("a", "b", ":"), "c", ".")
	r = indir_tuple_to_str(t)
	assert r == "a:b.c"
	t = ("a", ("b", "c", ":"), "[")
	r = indir_tuple_to_str(t)
	assert r == "a[b:c]"

def test_convert():
	code = """
		function sample1(param1, param2)
			local localvar
			player:isDocked()
			string.format(_("Test"))
		end
		function plot.sample2(param)
			local some
			part = 27
			somepart = 28
			partsome = 29
			part.some = 30
			part:some(34)
			part[some] = 35
			some.part = 31
			some:part(32)
			some[part] = 33
			some = "bla"..part
			some = "bla" .. part
		end
	"""
	expected = """
		function plot.sample1(param1, param2)
			local localvar
			plot.player:isDocked()
			string.format(_("Test"))
		end
		function plot.sample2(param)
			local some
			plot.part = 27
			plot.somepart = 28
			plot.partsome = 29
			plot.part.some = 30
			plot.part:some(34)
			plot.part[some] = 35
			some.part = 31
			some:part(32)
			some[plot.part] = 33
			some = "bla"..plot.part
			some = "bla" .. plot.part
		end
	"""
	scenario = Scenario(code)

	# do not replace word parts
	res = add_variable_prefix(code, set(["player", "sample1", "part", "partsome", "somepart"]), "plot")
	assert res == expected

	scenario = Scenario(expected)
	summary = scenario.function_analysis
	for summ in summary.values():
		assert summ["Global variables"] == set(["plot"])

	# must be idempotent
	res = add_variable_prefix(expected, set(["plot"]), "plot")
	assert res == expected
	

def test_create_init():
	plot = Plot("", "plot")
	plot.global_vars = ["player", "sample1"]
	res = plot.create_init()
	assert res == """plot = {}

function plot.init(player, sample1)
	plot.player = player
	plot.sample1 = sample1
end
"""

def _test_read_code_from_file():
	scenario = read_code_from_file("../../scenario_30_brokenglass.lua")
	code, tree, functions = scenario.code, scenario.tree, scenario.functions

	assert isinstance(code, str)
	assert len(code) > 10000
	assert isinstance(tree, astnodes.Chunk)
	assert isinstance(functions, dict)
	assert "init" in functions

def test_cut_function():
	code = """
-- comment1
function foo(test)
	-- comment2
	local var
	a = b
	return
end
-- comment3

function bar()
	return foo(x)
end
-- comment4"""
	expected_foo = """-- comment1
function test.foo(test)
	-- comment2
	local var
	a = b
	return
end
"""
	expected_bar = """-- comment3

function test.bar()
	return foo(x)
end
"""
	expected_both = """-- comment3

function test.bar()
	return test.foo(x)
end
-- comment1
function test.foo(test)
	-- comment2
	local var
	a = b
	return
end
"""
	expected_cut_foo = """
-- comment1
-- XXX test.foo -> test.lua
-- comment3

function bar()
	return test.foo(x)
end
-- comment4"""
	expected_cut_bar = """
-- comment1
function foo(test)
	-- comment2
	local var
	a = b
	return
end
-- comment3

-- XXX test.bar -> test.lua
-- comment4"""
	expected_cut_both = """
-- comment1
-- XXX test.foo -> test.lua
-- comment3

-- XXX test.bar -> test.lua
-- comment4"""

	scenario = Scenario(code)
	new_chunk = scenario.cut_functions("foo", "test")
	assert scenario.code == expected_cut_foo
	assert new_chunk == expected_foo

	scenario = Scenario(code)
	new_chunk = scenario.cut_functions("bar", "test")
	assert scenario.code == expected_cut_bar
	assert new_chunk == expected_bar

	scenario = Scenario(code)
	new_chunk = scenario.cut_functions(["bar", "foo"], "test")
	assert scenario.code == expected_cut_both
	assert new_chunk == expected_both

def _test_run_from_config_file():
	config = {
		"scenario": {
			"source": "../../scenario_30_brokenglass.lua",
		},
		"cut_from_scenario": {
			"StartMissionSpareParts": "spare_parts_mission"
		}
	}

	result = run_from_config_file(config)
	funcs = result["scenario_functions"]
	new_code = result["scenario_code_new"]
	new_chunks = result["extraced_code"]

	assert len(funcs) > 20
	assert "init" in funcs
	assert "StartMissionSpareParts" in funcs

	tree = ast.parse(new_code)
	funcs = get_functions(tree)
	assert "init" in funcs
	assert "StartMissionSpareParts" not in funcs

	assert "spare_parts_mission" in new_chunks
	code = new_chunks["spare_parts_mission"]
	tree = ast.parse(code)
	funcs = get_functions(tree)
	assert "spare_parts_mission.StartMissionSpareParts" in funcs

def test_patch_require():
	code = """
--- blabla

require("utils.lua")

function init()
	a = b
	-- XXX init plots
end
"""
	expected = """
--- blabla

require("utils.lua")
require("plots/test1.lua")
require("plots/test2.lua")

function init()
	a = b
	-- XXX init plots
	test1.init(a, b)
	test2.init()
end
"""
	scenario = Scenario(code)
	p1 = Plot("", "test1")
	p1.global_vars = ["a", "b"]

	p2 = Plot("", "test2")
	p2.global_vars = []
	scenario.patch_require({"test1": p1, "test2": p2}, "-- XXX init plots")

	assert scenario.code == expected


def test_claim_variable():
	code = """
function init()
	a = Stuff()
	b = {"bla", "blubb"}
end
"""
	expectedA = """
function init()
	-- XXX a was extracted
	b = {"bla", "blubb"}
end
"""
	expectedB = """
function init()
	a = Stuff()
	-- XXX b -> test.lua
end
"""
	extractedExtrA = "a = Stuff()"
	extractedExtrB = """b = {"bla", "blubb"}"""

	scenario = Scenario(code)
	extr = scenario.claim_variable("a")
	scenario.apply_changes()
	assert scenario.code == expectedA
	assert extr == extractedExtrA

	scenario = Scenario(code)
	extr = scenario.claim_variable("b", "test")
	scenario.apply_changes()
	assert scenario.code == expectedB
	assert extr == extractedExtrB

