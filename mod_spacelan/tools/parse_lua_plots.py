#!/usr/bin/env python3

from luaparser import ast, astnodes
import toml
import sys
import os
import re
from pprint import pprint
from function_names import global_known_names as GLOBAL_NAMES

GLOBAL_NAMES = set(GLOBAL_NAMES)

def walk_interactive(tree):
	cont = False
	for node in ast.walk(tree):
		print(node.to_json())
		if not cont:
			i = input()
			if i == "x":
				return
			if i == "c":
				cont = True

def parse_Node(node):
	if isinstance(node, astnodes.Name):
		return node.id
	elif isinstance(node, astnodes.Index):
		if node.notation == astnodes.IndexNotation.SQUARE:
			return parse_Node(node.value), parse_Node(node.idx), "["
		else:
			return parse_Node(node.value), parse_Node(node.idx), "."
	elif isinstance(node, astnodes.Invoke):
		return parse_Node(node.source), parse_Node(node.func), ":"
	elif isinstance(node, astnodes.Call):
		return str(parse_Node(node.func)) + "(" + str(parse_Node(node.args))+ ")"
	elif isinstance(node, astnodes.String):
		if len(node.s) > 10:
			return "STRING"
		else:
			return '"'+str(node.s)+'"'
	elif isinstance(node, astnodes.Number):
		return str(node.n)
	elif isinstance(node, list):
		return ",".join([str(parse_Node(n)) for n in node])
	else:
		return str(node.to_json())

def get_functions(root):
	"""returns all the names function of the file"""
	assert isinstance(root, astnodes.Chunk)
	assert isinstance(root.body, astnodes.Block)
	assert isinstance(root.body.body, list)
	top_level = list()
	for node in root.body.body:
		if isinstance(node, astnodes.Function):
			top_level.append(node)

	visited = list()
	class FunctionVisitor(ast.ASTVisitor):
		def visit_Function(self, node):
			visited.append(node)
	FunctionVisitor().visit(root)
	assert top_level == visited, "visitor and block function mismatch. Do you use nested functions?"

	functions = {}
	for f in top_level:
		name = f.name
		if isinstance(name, astnodes.Name):
			name = name.id
		elif isinstance(name, astnodes.Index):
			assert isinstance(name.value, astnodes.Name)
			assert isinstance(name.idx, astnodes.Name)
			name = name.value.id + "." + name.idx.id
		else:
			assert False
		functions[name] = f

	assert len(top_level) == len(functions),"number of functions and function names does not match. Do you have functions with the same name?"
	return functions

	
def get_names(node):
	"""Returns all names under the given node"""
	class NameVisitor(ast.ASTVisitor):
		"""collects all names under the given node"""
		def __init__(self):
			self.knownNames = set()
			super().__init__()

		def visit_Name(self, node):
			name = node.id
			self.knownNames.add(name)

	nv = NameVisitor()
	nv.visit(node)
	return nv.knownNames


def get_global_assignments(node):
	"""Returns all lvalue names that are global assignments"""
	class AssignVisitor(ast.ASTVisitor):
		def __init__(self):
			self.knownNames = set()
			self.knownNodes = {}
			super().__init__()

		def visit_Assign(self, node):
			for target, value in zip(node.targets, node.values):
				name = parse_Node(target)
				self.knownNames.add(name)
				if name not in self.knownNodes:
					self.knownNodes[name] = []
				self.knownNodes[name].append(node)

	av = AssignVisitor()
	av.visit(node)
	return av.knownNodes


def get_local_names(function):
	"""returns all local variable names under the given function"""
	class LocalVisitor(ast.ASTVisitor):
		def __init__(self):
			self.knownNames = set()
			super().__init__()

		def visit_LocalAssign(self, node):
			for n in node.targets:
				name = n.id
				self.knownNames.add(name)

		def visit_Fornum(self, node):
			name = node.target.id
			self.knownNames.add(name)

		def visit_Forin(self, node):
			for n in node.targets:
				name = n.id
				self.knownNames.add(name)

	args = function.args
	args = set([arg.id for arg in args])
	lv = LocalVisitor()
	lv.visit(function)
	return args | lv.knownNames


def get_indirect_names(node):
	"""returns component names"""
	class IndirectVisitor(ast.ASTVisitor):
		def __init__(self):
			self.knownNames = {}
			super().__init__()

		def visit_Index(self, node):
			l,r,s = parse_Node(node)
			if l not in self.knownNames:
				self.knownNames[l] = set()
			self.knownNames[l].add((r,s))

		def visit_Invoke(self, node):
			l,r,s = parse_Node(node)
			if l not in self.knownNames:
				self.knownNames[l] = set()
			self.knownNames[l].add((r,s))

#		def visit_Call(self, node):
#			print('Call: ',parse_Node(node))


	iv = IndirectVisitor()
	iv.visit(node)
	return iv.knownNames

def getAttributesAndMethodsFromIndirect(names):
	attrs = dict()
	meths = dict()
	attr_names = set()
	for k,vs in names.items():
		for val,sep in vs:
			if sep in [".","["]:
				if k not in attrs:
					attrs[k] = []
				attrs[k].append((val,sep))
				attr_names.add(val)
			elif sep == ":":
				if k not in meths:
					meths[k] = []
				meths[k].append((val,sep))
			else:
				assert sep in [".", "[", ":"]
	return attrs, meths, attr_names



def indir_tuple_to_str(tup):
	a,b,s = tup
	if isinstance(a, tuple):
		a = indir_tuple_to_str(a)
	if isinstance(b, tuple):
		b = indir_tuple_to_str(b)
	if s == "[":
		return a+s+b+"]"
	return a+s+b


def analysis_printable(summary):
	meth = summary["Methods"]
	attr = summary["Attributes"]
	meth_new = dict()
	attr_new = dict()
	for key,values in meth.items():
		if isinstance(key, tuple):
			key = indir_tuple_to_str(key)
		meth_new[key] = []
		for val in values:
			name, sep = val
			if isinstance(name, tuple):
				name = indir_tuple_to_str(name)
			meth_new[key].append(sep+name)
		if len(meth_new[key]) == 1:
			meth_new[key] = meth_new[key][0]
	summary["Methods"] = meth_new
	for key,values in attr.items():
		if isinstance(key, tuple):
			key = indir_tuple_to_str(key)
		attr_new[key] = []
		for val in values:
			name, sep = val
			if isinstance(name, tuple):
				name = indir_tuple_to_str(name)
			attr_new[key].append(sep+name)
		if len(attr_new[key]) == 1:
			attr_new[key] = attr_new[key][0]
	summary["Attributes"] = attr_new

	return summary

def add_variable_prefix(code, variables, prefix):
	assert prefix
	for var in variables:
		if var != prefix:
			code = re.sub(r"([^.:]|\.\.)\b%s\b" % var, r"\1"+prefix+"."+var, code)
	return code



class Scenario:
	"""A scenario from a file where plots are extracted"""
	def __init__(self, code):
		assert isinstance(code, str)
		self.code = code
		self.tree = ast.parse(self.code)
		self.functions = get_functions(self.tree)	# dict[name]: astnodes.Function
		self.function_analysis = self.analyse_functions()
		self.patches = []
		self.var_prefixes = []

	def add_code_patch(self, insert_code, start_char, stop_char=None):
		"""
		inserts code at position stop_char, removes old code until stop_char.
		this is cached, and applied when apply_changes is called.
		"""
		if stop_char is None:
			self.patches.append((start_char, start_char, insert_code))
		else:
			self.patches.append((start_char, stop_char, insert_code))

	def add_variable_prefix(self, variables, prefix):
		self.var_prefixes.append((variables, prefix))
		
	def apply_changes(self):
		"""apply patches from all previous add_code_patch and add_variable_prefix calls"""
		# patches
		start = 0
		new_code = ""
		for next_stop, next_start, insert in sorted(self.patches):
			assert next_stop > start
			new_code += self.code[start:next_stop] + insert
			start = next_start
		new_code += self.code[start:]

		# prefixes
		for variables, prefix in self.var_prefixes:
			new_code = add_variable_prefix(new_code, variables, prefix)

		# this basically creates a new scenario
		self.code = new_code
		self.tree = ast.parse(self.code)
		self.functions = get_functions(self.tree)
		self.function_analysis = self.analyse_functions()
		self.patches = []
		self.var_prefixes = []


	def cut_functions(self, function_names, moved_to):
		"""moves functions from code to a seperate string.
			replaces the functions in the code with a comment.
			returns the modified code and the extracted functions.
			comments before the extraced functions stay in the code,
			but also get duplicated to the new chunk.
		"""

		code = self.code
		if isinstance(function_names, str):
			function_names = [function_names]
		tree = self.tree
		functions = self.functions
		new_chunk = ""

		for function_name in function_names:
			f = functions[function_name]
			insert = f"-- XXX {function_name} -> {moved_to}.lua"
			if f.comments and f.comments[0].start_char < f.start_char:
				new_chunk += code[f.comments[0].start_char: f.stop_char+1]+"\n\n"
			else:
				new_chunk += code[f.start_char : f.stop_char+1]+"\n\n"
			self.add_code_patch(insert, f.start_char, f.stop_char+1)
		self.add_variable_prefix(function_names, moved_to)
		self.apply_changes()
		new_chunk = add_variable_prefix(new_chunk, function_names, moved_to)
		return new_chunk

	def patch_require(self, plots, init_mark):
		code = self.code
		requirements = [f'require("plots/{m}.lua")' for m in plots.keys()]
		requirements = "\n".join(requirements)
		inits = []
		for module, plot in plots.items():
			arguments = plot.get_init_arguments()
			inits.append(f'{module}.init({arguments})')

		# add requirements
		pos = code.find("\n\nfunction init()")
		assert pos != -1, "could not find '\\n\\nfunction init()'"
		self.add_code_patch("\n"+requirements, pos)
#		code = code[:pos] + "\n" + requirements + code[pos:]
		# add inits
		pos = code.find(init_mark)
		assert pos != -1, f"could not find '{init_mark}'"
		whitespace = ""
		while code[pos-1] in " \t":
			whitespace += code[pos-1]
			pos = pos-1
		pos += len(init_mark) + len(whitespace)
		whitespace = "\n" + whitespace
		while code[pos] != "\n":
			pos += 1
		inits = whitespace.join(inits)
		self.add_code_patch(whitespace+inits, pos)
#		code = code[:pos] + whitespace + inits + code[pos:]
		self.apply_changes()
		return self.code

	def claim_variable(self, var, moved_to=""):
		code = self.functions["init"]
		assignments = self.function_analysis["init"]["Assignments"]
		if var not in assignments:
			return None
		assert len(assignments[var]) == 1
		node = assignments[var][0]

		start = node.start_char
		stop = node.stop_char +1
		extracted = self.code[start:stop]
		if moved_to:
			insert = f"-- XXX {var} -> {moved_to}.lua"
		else:
			insert = f"-- XXX {var} was extracted"
		self.add_code_patch(insert, start, stop)
		return extracted

	def claim_variables(self, vars, moved_to=""):
		extracted = {}
		for var in vars:
			extracted[var] = self.claim_variable(var, moved_to)
		self.add_variable_prefix(vars, moved_to)
		self.apply_changes()
		return extracted

	def analyse_functions(self):
		analysis = {}
		for f_name, node in self.functions.items():
			assert isinstance(node, astnodes.Function)
			names = get_names(node)
			local = get_local_names(node)
			indirect = get_indirect_names(node)
			assign = get_global_assignments(node)
			for name in local:
				if name in assign:
					del assign[name]
			attr, meth, attr_names = getAttributesAndMethodsFromIndirect(indirect)
			summary = {
				"Local variables": local,
				"API calls": names & GLOBAL_NAMES,
				"Methods": meth,
				"Attributes": attr,
				"Assignments": assign,
				"Global variables": names-local-GLOBAL_NAMES-attr_names
			}
			analysis[f_name] = summary
		return analysis

class Plot(Scenario):
	"""A plot that will be written to a file.
		A plot is a scenario with a name
	"""
	def __init__(self, code, name, ignore=[]):
		self.name = name
		Scenario.__init__(self, code)
		self.global_vars = self.get_global_vars() - {name} - set(ignore)
		self.claimed_vars = {}
		self.relevant_objects = set()
		self.setable_parameters = set()

	def set_claimed_variables(self, claimed):
		self.claimed_vars = claimed
		for var in claimed:
			if var in self.global_vars:
				self.global_vars.remove(var)

	def set_relevant_objects(self, relevant_objects):
		self.relevant_objects = set(relevant_objects)

	def set_setable_parameters(self, setable_parameters):
		self.setable_parameters = set(setable_parameters)

	def create_init(self):
		variables = sorted(self.global_vars - self.setable_parameters)
		prefix = self.name
		params = ", ".join(variables)
		code = f"""{prefix} = {{}}"""
#		for var in self.claimed_vars:
#			code += f"""
#{prefix}.{var} = nil"""	# irrelevant: = nil is the same as not in the table at all.
		code += f"""

function {prefix}.init({params})"""
		for var in variables:
			code += f"""
	{prefix}.{var} = {var}"""
		code2 = ""
		for var, c in self.claimed_vars.items():
			if c:
				code2 += f"""
	{c}"""
		code2 = add_variable_prefix(code2, self.claimed_vars.keys(), self.name)
		code += code2

		code_all_params = ""
		code_functions = ""
		code_storage = f"""
	local storage = getScriptStorage()
	storage.{prefix} = {{}}"""

		for var in sorted(self.setable_parameters):
			code_functions += f"""
function {prefix}.set_{var}({var})
	{prefix}.{var} = {var}
end
"""
			code_storage += f"""
	storage.{prefix}.set_{var} = {prefix}.set_{var}"""
			code_all_params += f"""
	{prefix}.set_{var}({var})"""

		code_all_params = """
function set_parameters(""" + ", ".join(sorted(self.setable_parameters)) + ")" + code_all_params + """
end

"""
		code += code_storage + f"""
	storage.{prefix}.set_parameters = {prefix}.set_parameters
end
"""
		code += code_functions + code_all_params

		code_check = f"""
function {prefix}.check()"""
		for var in sorted(self.relevant_objects):
			code_check += f"""
	if {prefix}.{var} == nil or not {prefix}.{var}:isValid() then return false end"""
		code_check += """
	return true
end	
"""
		code += code_check
		return code

	def get_global_vars(self):
		variables = set()
		for summ in self.function_analysis.values():
			variables |= summ["Global variables"]
		return variables

	def get_code(self):
		code = add_variable_prefix(self.code, self.global_vars, self.name)
		code = add_variable_prefix(code, self.claimed_vars.keys(), self.name)
		code = self.create_init() + code
		return code

	def get_init_arguments(self):
		return ", ".join(sorted(self.global_vars - self.setable_parameters))

def read_code_from_file(filename):
	with open(filename, "r") as file:
		code = file.read()
	return Scenario(code)




def run_from_config_file(config):
	result = {}
	filename = config["scenario"].get("intermediate")
	if not filename or not os.path.isfile(filename):
		filename = config["scenario"]["source"]
	assert os.path.isfile(filename), f"{filename} not found"
	scenario = read_code_from_file(filename)
#	result["scenario_functions"] = get_functions(tree)

	modules = {}
	ignore_functions = config["ignore"]["functions"]
#		result["extraced_code"] = {}
#		result["global variables"] = {}
	for target, function_names in config["cut_functions_from_scenario"].items():
		print(f"extract functions for {target}")
#			assert target not in targets:
#			targets[target] = []
		chunk = scenario.cut_functions(function_names, target)
		modules[target] = Plot(chunk, target, ignore_functions)

	for target, variable_names in config["relevant_objects"].items():
		modules[target].set_relevant_objects(variable_names)

	for target, variable_names in config["setable_parameters"].items():
		modules[target].set_setable_parameters(variable_names)

	for target, variable_names in config["claim_variables"].items():
		print(f"extract variables for {target}")
		extracted = scenario.claim_variables(variable_names, target)
		modules[target].set_claimed_variables(extracted)
		modules[target].apply_changes()

	print("create init functions")
	scenario.patch_require(modules, config["scenario"]["initMark"])
	result["scenario_code_new"] = scenario.code

	return scenario, modules

if __name__ == "__main__":
	filename = sys.argv[1]
	config = toml.load(filename)
	scenario, plots = run_from_config_file(config)

	# write to file
	print("writing scenario")
	filename = config["scenario"].get("intermediate")
	if filename:
		with open(filename, "w") as file:
			file.write(scenario.code)

	filename = config["scenario"].get("target")
	if filename:
		with open(filename, "w") as file:
			file.write(scenario.code)

	for name, plot in plots.items():
		print(f"writing {name}")
		with open(name+".new.lua", "w") as file:
			file.write(plot.get_code())

#	for name, vars in result["global variables"].items():
#		print(name + u"\u2500"*(os.get_terminal_size().columns-len(name)))
#		for var in vars:
#			print(var)



#		pprint(analysis_printable(summary))
#	print()
#	print(80*"-")
#	print("Functions:", list(functions.keys()))
#	print("Global variables:",variables-functions.keys())
#	plot_name = filename.removesuffix(".lua")
#	plot_name = plot_name.removesuffix(".new")
#	print(f"replace_plot_functions.py <file> {plot_name} "+ " ".join(functions.keys()))
#
#
#	new_code = add_variable_prefix(code, variables, plot_name)
#	variables -= set(functions.keys())
#	if plot_name not in variables:
#		new_code = create_init(variables, plot_name) + new_code
#	
#	with open(plot_name+".new.lua", "w") as file:
#		file.write(new_code)
#		#walk_interactive(f)



#	IndirectVisitor().visit(tree)
#	v = NameVisitor()
#	v.visit(tree)
#	v.knownNames
#
#	DumbVisitor().visit(tree)
#
#	LocalVisitor().visit(tree)
#	v.knownNames
