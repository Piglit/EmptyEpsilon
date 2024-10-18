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

class Resource:
	def __init__(self, owner, name):
		assert owner in ["player", "source", "P", "object", "target", "station", "ship", "S"]
		self.owner_input = owner
		self.name = name
		if owner in ["player", "source", "P"]:
			self.owner_code = "source"
			self.owner_readable = "player"
		elif owner in ["object", "target", "station", "ship", "S"]:
			self.owner_code = "target"
			self.owner_readable = "target"
		else:
			assert False

	def resources(self):
		return {self.owner_readable + "." + self.name}

	def lua(self):
		return f'''{self.owner_code}:getResourceAmount("{self.name}")'''

	def __str__(self):
		return self.owner_input + "." + self.name
	
	def __eq__(self, other):
		if isinstance(other, Resource):
			return self.owner_code == other.owner_code and self.name == other.name
		elif isinstance(other, str):
			return [self.owner_input, self.name] == other.split(".")
		else:
			return False


class Expression:
	def __init__(self, tokens):
		self.tokens = tokens

	def resources(self):
		result = set()
		for token in self.tokens:
			assert isinstance(token, tuple)
			(kind, value) = token
			if kind == "resource_id":
				result |= value.resources()
		return result

	def lua(self):
		result = ""
		for token in self.tokens:
			(kind, value) = token
			if kind == "resource_id":
				result += value.lua()
			elif kind == "number":
				result += str(value)
			elif kind == "operator":
				result += " " + value + " "
			elif kind == "parenthesis":
				result += value
			else:
				assert False
		return result


class Parser:
	regex_resource = re.compile(r"\s*([A-za-z_]+)\.([A-za-z_]+)\s*")

	regex_tokens = "|".join("(?P<%s>)%s" % pair for pair in [
		("resource_id", r"[A-za-z_]+\.[A-za-z_]+"),
		("number", r"-?\d+"),
		("operator", r"[+\-*/%]"),
		("parenthesis", r"[)(]"),
		("relation", r"[<>]"),
		("negator", r"[~!]"),
		("equals", r"="),
		("skip", r"[ \t\n]+"),
		("mismatch", r".")
	])

	def tokenize(text):
		"""see python docs: regex#writing-a-tokenizer"""
		result = []
		for mo in re.finditer(Parser.regex_tokens, text):
			kind = mo.lastgroup
			value = mo.group()
			column = mo.start()
			if kind == "mismatch":
				raise RuntimeError(f"{value!r} unexpected in '{text}'. Position: {column}")
			if kind == "number":
				value = int(value)
			if kind == "resource_id":
				res = Parser.regex_resource.fullmatch(value)
				if res is None:
					raise RuntimeError(f"'{res}' causes syntax error in '{text}'")
				parent, child = res.group(1,2)
				value = Resource(parent, child)

			if kind != "skip":
				result.append((kind, value))
		return result

	def expression(tokens, text, depth=0):
		"""Grammer:
			expression  : expression operator expression
						| resource_id
						| number
						| ( expression )
		"""
		if len(tokens) == 0:
			raise RuntimeError(f"Missing expression after '{text}'")
		elif tokens[0][0] == "parenthesis":
			if tokens[0][1] == "(":
				# consume (, expression must follow
				Parser.expression(tokens[1:], text, depth+1)
			elif tokens[0][1] == ")":
				if depth <= 0:
					raise RuntimeError(f"too many ')' in expression '{text}'")
				if len(tokens) == 1:
					# end of input reached after )
					if depth > 1:
						raise RuntimeError(f"missing ')' in expression '{text}'")
				elif tokens[1][1] == ")":
					# consume first ), continue
					Parser.expression(tokens[1:], text, depth-1)
				elif tokens[1][0] == "operator":
					# consume ) and operator, expression must follow
					Parser.expression(tokens[2:], text, depth-1)
				else:
					raise RuntimeError(f"missing operator after ')' in expression '{text}'.")
		elif tokens[0][0] not in ["resource_id", "number"]:
			raise RuntimeError(f"'{str(tokens[0][1])}' unexpected in expression '{text}.'")
		elif len(tokens) == 1:
			# last item was resource_id or number
			pass
		elif len(tokens) == 2:
			# consume first (resource_id or number), second must be )
			if tokens[1][1] == ")":
				Parser.expression(tokens[1:], text, depth)
			else:
				raise RuntimeError(f"'{str(tokens[-2][1])} {str(tokens[-1][1])}' unexpected in expression '{text}'.")
		elif len(tokens) >= 3:
			if tokens[1][0] == "operator":
				# consume first token (resource_id or number) and second token (operator)
				# next must be expression
				if tokens[2][0] in ["resource_id", "number"] or tokens[2][1] == "(":
					Parser.expression(tokens[2:], text, depth)
				else:
					raise RuntimeError(f"'{tokens[2][1]}' unexpected after '{tokens[0][1]} {tokens[1][1]}' in expression '{text}'.")
					
			elif tokens[1][1] == ")":
				# consume first (resource_id or number), second must be )
				Parser.expression(tokens[1:], text, depth)
			else:
				raise RuntimeError(f"'{tokens[1][1]}' unexpected after '{tokens[0][1]}' in expression '{text}'.")
		else:
			raise RuntimeError(f"invalid expression '{text}'.")

		return Expression(tokens)
			
	def assignment(text):
		"""Grammer:
		assignment	: resource_id ass_operator expression

		ass_operator: operator
					| equals
		"""
		tokens = Parser.tokenize(text)
		if len(tokens) < 2:
			raise RuntimeError(f"'{text}' is not a valid assignment.")

		if tokens[0][0] != "resource_id":
			raise RuntimeError(f"Effect must start with resource: '{text}'")
		target = tokens[0][1]

		if tokens[1][0] not in ["operator", "equals"]:
			# fixes the following expression: 'P.foo -1' to 'P.foo - 1'
			if tokens[1][0] == "number" and tokens[1][1] < 0:
				tokens = [tokens[0], ("operator", "-"), ("number", -tokens[1][1])] + tokens[2:]
			else:
				raise RuntimeError(f"'{tokens[1][1]}' is not a valid assignment operator in '{text}'")
		operator = tokens[1][1]

		if len(tokens) < 3:
			raise RuntimeError(f"Missing expression after '{text}'")
			
		exp = Parser.expression(tokens[2:], text)
		return target, operator, exp
	
	def condition(text):
		"""Grammer:
		condition	: expression comparator expression

		comparator	: relation
					| relation equals
					| negator equals
					| equals
		"""
		tokens = Parser.tokenize(text)
		left = []
		comparator = ""
		right = []
		# sort into left, comparator, right
		for token in tokens:
			if not right and token[0] in ["relation", "equals", "negator"]:
				comparator += token[1]
			elif not comparator:
				left.append(token)
			else:
				right.append(token)

		if comparator not in ["<", ">", "=", "==", "!=", "~=", "<=", ">="]:
			raise RuntimeError(f"invalid comparator: '{comparator}' in '{text}'")

		if not left:
			raise RuntimeError(f"'{text}' is missing the left side of the condition")

		if not right:
			raise RuntimeError(f"'{text}' is missing the right side of the condition")

		return Parser.expression(left, text), comparator, Parser.expression(right, text)


class dialog_condition():
	# both sides can be a owner-resource combi or a number or arithmetic expression
	def __init__(self, condition: str):
		self.left, comparator, self.right = Parser.condition(condition)
		if comparator == "=":
			comparator = "=="
		if comparator == "!=":
			comparator = "~="
		self.comparator = comparator
		assert isinstance(self.left, Expression)
		assert isinstance(self.right, Expression)

	def lua(self):
		result = ""
		result += self.left.lua()
		result += f" {self.comparator} "
		result += self.right.lua()
		return result

	def resources(self):
		return self.left.resources() | self.right.resources()

	def __and__(self, other):
		return combined_condition(self) & other

	def __or__(self, other):
		return combined_condition(self) | other

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


class dialog_effect():
	"""An effect: resource manipulation."""
	# left side must be a owner-resource combi
	# right side can be a owner-resource combi or an arithmetic expression
	def __init__(self, effect):
		self.target, self.operator, self.expression = Parser.assignment(effect)
		assert isinstance(self.target, Resource)
		assert isinstance(self.expression, Expression)
		if self.operator == "+":
			self.operator_code = "increaseResourceAmount"
		elif self.operator == "-":
			self.operator_code = "decreaseResourceAmount" 
		elif self.operator == "=":
			self.operator_code= "setResourceAmount"
		else:
			raise KeyError(self.operator)

	def lua(self):
		result = f"""{self.target.owner_code}:{self.operator_code}("{self.target.name}", """
		result += self.expression.lua() + ")\n"
		return result

	def resources(self):
		return self.target.resources() | self.expression.resources()

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

