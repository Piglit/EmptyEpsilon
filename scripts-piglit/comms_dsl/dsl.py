"""Domain Specific Language (DSL) for comms scripts.
Goal: create an easily testible interface for story-based comms scripts.
How it is done:
* only allow few ee-lua-api-functions inside comms-tree.
* other ee-lua-api functions can not be called directly.
* function calls that modify game-related variables must be defined on top-level, so they can be called from a test-script.
* creating a comms-decition-tree must be easy

"""

import re
import inspect
import os.path
import datetime

class combined_condition:
	def __init__(self, first_entry):
		self.condition_list = [first_entry,]
	
	def _add_condition(self, other):
		if isinstance(other, dialog_condition):
			self.condition_list.append(other)
		elif isinstance(other, combined_condition):
			self.condition_list += other.condition_list
		else:
			raise TypeError(f"operand must be of type 'dialog_condition' or 'combined_condition' but is of type '{type(other)}'")

	def __and__(self, other):
		self.condition_list.append("and")
		self._add_condition(other)
		return self

	def __or__(self, other):
		self.condition_list.append("or")
		self._add_condition(other)
		return self

	def lua(self):
		result = ""
		for elem in self.condition_list:
			if isinstance(elem, str):
				# operator 'and' or 'or'
				result += f""" {elem} """
			elif isinstance(elem, dialog_condition):
				result += f"""({elem.lua()})"""
			else:
				raise RuntimeError("Combined condition is broken")
		return result

	def resources(self):
		result = set()
		for elem in self.condition_list:
			if isinstance(elem, dialog_condition):
				result |= elem.resources()
		return result	

class uses_resources:
	regex_digit = re.compile(r"-?\d+")
	regex_variable = re.compile(r"\s*([A-za-z_]+)\.([A-za-z_]+)\s*")

	def tokenize(expression):
		"""see python docs: regex#writing-a-tokenizer"""
		tokens = [
			("resource_id", r"[A-za-z_]+\.[A-za-z_]+"),
			("number", r"-?\d+"),
			("operator", r"[+\-*/%)(]"),
#			("comparator", r"(>=)|(<=)|(==)|(!=)|(~=)|(<)|(>)"),
#			("assignment", r"="),
			("skip", r"[ \t\n]+"),
			("mismatch", r".")
		]
		regex = "|".join("(?P<%s>)%s" % pair for pair in tokens)
		result = []
		for mo in re.finditer(regex, expression):
			kind = mo.lastgroup
			value = mo.group()
			column = mo.start()
			if kind == "mismatch":
				raise RuntimeError(f"{value!r} unexpected in '{expression}'. Position: {column}")
			if kind == "number":
				value = int(value)
			if kind == "resource_id":
				value = uses_resources.parse_resource(value) # tuple
			if kind != "skip":
				result.append((kind, value))
		return result

	def parse_resource_expression(expression):
		return uses_resources.tokenize(expression)

	def parse_resource(resource):
		result = uses_resources.regex_variable.fullmatch(resource)
		assert result is not None, f"condition syntax error in '{resource}'"
		parent, child = result.group(1,2)
		if parent in ["player", "source", "P"]:
			parent = "source"
		elif parent in ["object", "target", "station", "ship", "S"]:
			parent = "target"
		else:
			assert parent in ["player", "source", "P", "object", "target", "station", "ship", "S"]
		return (parent, child)

	def resources(resource):
		result = set()
		for part in resource:
			(kind, value) = part
			if kind == "resource_id":
				(a, b) = value
				if a == "source":
					a = "player"
				result.add(a + "." + b)
		return result

	def lua(resource):
		result = ""
		for part in resource:
			(kind, value) = part
			if kind == "resource_id":
				result += f'''{value[0]}:getResourceAmount("{value[1]}")'''
			elif kind == "number":
				result += str(value)
			elif kind == "operator":
				result += " " + value + " "
			else:
				assert False
		return result

class dialog_condition():
	regex_condition = re.compile(r"([A-za-z_\d\.+\-*/\s]+)([<>=!~]+)([A-za-z_\d\.+\-*/\s]+)")
	# both sides can be a owner-resource combi or a number
	def __init__(self, condition: str):
		result = self.regex_condition.fullmatch(condition)
		if result is None:
			raise RuntimeError(f"Missing comperator in condition: '{condition}'")
		left, comparator, right = result.group(1, 2, 3)
		#print(left, comparator, right)

		if comparator not in ["<", ">", "=", "==", "!=", "~=", "<=", ">="]:
			raise RuntimeError(f"invalid comparator: '{comparator}'")
		if comparator == "=":
			comparator = "=="
		if comparator == "!=":
			comparator = "~="
		self.comparator = comparator

		self.left = uses_resources.parse_resource_expression(left)
		self.right = uses_resources.parse_resource_expression(right)

	def lua(self):
		result = ""
		result += uses_resources.lua(self.left)
		result += f" {self.comparator} "
		result += uses_resources.lua(self.right)
		return result

	def resources(self):
		return uses_resources.resources(self.left) | uses_resources.resources(self.right)

	def __and__(self, other):
		return combined_condition(self) & other

	def __or__(self, other):
		return combined_condition(self) | other


class dialog_effect():
	"""An effect: resource manipulation."""
	regex_effect = re.compile(r"\s*([A-za-z_.]+)\s*([+\-=])")
	# left side must be a owner-resource combi
	# right side can be a owner-resource combi or a number
	def __init__(self, effect):
		result = self.regex_effect.search(effect)
		assert result is not None, f"condition syntax error in '{effect}'"
		left, operator = result.group(1, 2)
		right = effect[result.end():]
		#print(left, operator, right)
		assert operator in "+-="
		self.operator = operator

		left = uses_resources.parse_resource_expression(left)
		self.right = uses_resources.parse_resource_expression(right)
		assert isinstance(left, list)
		assert len(left) == 1
		assert isinstance(left[0], tuple)
		assert left[0][0] == "resource_id"
		self.left = left[0][1]
		assert isinstance(self.left, tuple)
		assert len(self.left) == 2

	def lua(self):
		if self.operator == "+":
			op = "increaseResourceAmount"
		elif self.operator == "-":
			op = "decreaseResourceAmount" 
		elif self.operator == "=":
			op = "setResourceAmount"
		else:
			raise KeyError(self.operator)

		result = f"""{self.left[0]}:{op}("{self.left[1]}", """
		result += uses_resources.lua(self.right) + ")\n"
		return result

	def resources(self):
		
		return uses_resources.resources([("resource_id", self.left)]) | uses_resources.resources(self.right)

class dialog_option:
	"""A selectable option and everything below."""
	def __init__(self, choice: str, message: str, children: list = []):
		self.choice = choice
		self.message = message
		self.dialog_options = []
		self.effects = []
		for c in children:
			if isinstance(c, dialog_option):
				self.dialog_options.append(c)
			elif isinstance(c, dialog_effect):
				self.effects.append(c)
			else:
				raise TypeError("list element must be of type dialog_option or dialog_effect")

	def lua(self):
		result = f"""addCommsReply("{self.choice}", function(source, target)\n"""
		result += f"""\tsendCommsMessage("{self.message}")\n"""
		for e in self.effects:
			result += "\t" + e.lua()
		for do in self.dialog_options:
			result += "\t" + do.lua()
		result += """end)\n"""
		return result

	def resources(self, recursive = True):
		result = set()
		for e in self.effects:
			result |= e.resources()
		for do in self.dialog_options:
			if recursive:
				result |= do.resources()
			elif isinstance(do, conditional_dialog_option):
				result |= do.condition.resources()
		return result

class conditional_dialog_option(dialog_option):
	"""This selectable option is only shown if the condition is met."""
	def __init__(self, condition, *args, **kwargs):
		assert isinstance(condition, dialog_condition) or isinstance(condition, combined_condition)
		self.condition = condition
		dialog_option.__init__(self, *args, **kwargs)

	def lua(self):
		result = f"""if ({self.condition.lua()}) then\n"""
		for line in dialog_option.lua(self).split("\n"):
			if line:
				result += "\t" + line + "\n"
		result += "end\n"
		return result

	def resources(self, recursive = True):
		return dialog_option.resources(self, recursive) | self.condition.resources()

class dialog_target(dialog_option):
	"""You can jump to this target with dialog_link(name)."""
	targets = {}

	def __init__(self, name: str, *args, **kwargs):
		assert name not in dialog_target.targets, f"dialog_target with name '{name}' already exists."
		self.name = name
		dialog_option.__init__(self, *args, **kwargs)
		dialog_target.targets[name] = self

	def lua(self):
		result = f"""function ct_{self.name}(source, target)\n"""
		result += f"""\tsendCommsMessage("{self.message}")\n"""
		for do in self.dialog_options:
			result += "\t" + do.lua()
		result += """end\n"""
		return result

	def lua_all():
		result = ""
		for name, target in dialog_target.targets.items():
			result += target.lua() + "\n"
		return result

class dialog_link:
	"""Jump to dialog_target(name), when selected."""
	def __init__(self, name: str, choice: str = None):
		self.name = name
		self.choice = choice
		self.prepared = False

	def prepare(self):
		"""get the target object, apply the default choice, if none was given."""
		if not self.name in dialog_target.targets:
			raise KeyError(f"dialog_target '{self.name}' was not defined.")
		self._target = dialog_target.targets[self.name]
		if self.choice is None:
			self.choice = self._target.choice
		self.prepared = True

	def lua(self):
		if not self.prepared:
			self.prepare()
		result = f"""addCommsReply("{self.choice}", ct_{self.name})\n"""
		return result

class conditional_dialog_link(dialog_link):
	"""This selectable option is only shown if the condition is met."""
	def __init__(self, condition, *args, **kwargs):
		assert isinstance(condition, dialog_condition) or isinstance(condition, combined_condition)
		self.condition = condition
		dialog_link.__init__(self, *args, **kwargs)

	def lua(self):
		result = f"""if ({self.condition.lua()}) then\n"""
		for line in dialog_link.lua(self).split("\n"):
			if line:
				result += "\t" + line + "\n"
		result += "end\n"
		return result

class station:
	stations = []

	def __init__(self, *tags):
		self.tags = tags
		self.options = []
		station.stations.append(self)

	def add_dialog(self, dialog):
		assert isinstance(dialog, dialog_option)# or isinstance(dialog, dialog_link)
		self.options.append(dialog)

	def lua(self):
		ret = f"""table.insert(getStation("{",".join(self.tags)}").comms_data.comms_functions, function(source, target)\n"""
		for o in self.options:
			for line in o.lua().split("\n"):
				if line:
					ret += "\t" + line + "\n"
		ret += "end)\n"
		return ret

	def lua_all():
		result = ""
		for target in station.stations:
			result += target.lua() + "\n"
		return result

	def resources(self):
		result = set()
		for do in self.options:
			result |= do.resources()
		return result

class script:
	def __init__(self, filename, author, description):
		self.filename = os.path.basename(filename)
		self.heading = self.filename.removesuffix(".py")
		self.date = datetime.datetime.now().date()
		self.author = author
		self.description = description

	def lua(self):
		result = f"""--[[{self.heading}
generated by dsl.py from {self.filename} on {self.date}
"""
		if self.author:
			result += f"""Author: {self.author}\n"""
		if self.description:
			result += f"""\n{self.description}\n"""
		result += "--]]\n\n"
		result += dialog_target.lua_all()
		result += station.lua_all()
		return result

def generate(author = None, description = None):
	filename = inspect.stack()[1].filename
	return script(filename, author, description)

