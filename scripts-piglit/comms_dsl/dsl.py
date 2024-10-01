"""Domain Specific Language (DSL) for comms scripts.
Goal: create an easily testible interface for story-based comms scripts.
How it is done:
* only allow few ee-lua-api-functions inside comms-tree.
* other ee-lua-api functions can not be called directly.
* function calls that modify game-related variables must be defined on top-level, so they can be called from a test-script.
* creating a comms-decition-tree must be easy

"""

import re

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

class dialog_condition:
	regex_outer = re.compile(r"\s*([A-za-z_.\-\d]+)\s*([<>=!~]+)\s*([A-za-z_.\-\d]+)\s*")
	regex_inner_digit = re.compile(r"-?\d+")
	regex_inner_variable = re.compile(r"\s*([A-za-z_]+.)?([A-za-z_]+)\s*")
	def __init__(self, condition: str):
		result = self.regex_outer.fullmatch(condition)
		assert result is not None, f"condition syntax error in '{condition}'"
		left, comparator, right = result.group(1, 2, 3)
		#print(left, comparator, right)

		assert comparator in ["<", ">", "=", "==", "!=", "~=", "<=", ">="], f"comparator '{comparator}' not valid"
		if comparator == "=":
			comparator = "=="
		if comparator == "!=":
			comparator = "~="
		self.comparator = comparator

		result = self.regex_inner_digit.fullmatch(left)
		if result:
			self.left = int(left)
		else:
			result = self.regex_inner_variable.fullmatch(left)
			assert result is not None, f"condition syntax error in '{left}'"
			left_parent, left_child = result.group(1,2)
			left_parent = left_parent.removesuffix(".")
			if left_parent in ["player", "source", "P"]:
				left_parent = "source"
			elif left_parent in ["object", "station", "ship", "S"]:
				left_parent = "target"
			else:
				assert left_parent in ["player", "source", "P", "object", "station", "ship", "S"]
			self.left = (left_parent, left_child)

		result = self.regex_inner_digit.fullmatch(right)
		if result:
			self.right = int(right)
		else:
			result = self.regex_inner_variable.fullmatch(right)
			assert result is not None, f"condition syntax error in '{right}'"
			right_parent, right_child = result.group(1,2)
			right_parent = right_parent.removesuffix(".")
			if right_parent in ["player", "source", "P"]:
				right_parent = "source"
			elif right_parent in ["object", "station", "ship", "S"]:
				right_parent = "target"
			else:
				assert right_parent in ["player", "source", "P", "object", "station", "ship", "S"]
			self.right = (right_parent, right_child)

	def lua(self):
		result = ""
		if isinstance(self.left, int):
			result += f"{self.left}"
		else:
			assert isinstance(self.left, tuple)
			result += f'''{self.left[0]}:getResourceAmount("{self.left[1]}")'''
		result += f" {self.comparator} "
		if isinstance(self.right, int):
			result += f"{self.right}"
		else:
			assert isinstance(self.right, tuple)
			result += f'''{self.right[0]}:getResourceAmount("{self.right[1]}")'''
		return result

	def __and__(self, other):
		return combined_condition(self) & other

	def __or__(self, other):
		return combined_condition(self) | other


class dialog_effect:
	"""An effect: resource manipulation."""
	def __init__(self, who: str, what: str, how: str, amount: int):
		if who in ["player", "source", "P"]:
			who = "source"
		elif who in ["object", "station", "ship", "S"]:
			who = "target"
		assert who in ["source", "target"]
		assert how in ["+", "-", "="]
		assert isinstance(what, str)
		assert isinstance(amount, int)
		self.who = who
		self.what = what
		self.how = how
		self.amount = amount
	
	def lua(self):
		what = ""
		if self.how == "+":
			how = "increaseResourceAmount"
		elif self.how == "-":
			how = "decreaseResourceAmount" 
		elif self.how == "=":
			how = "setResourceAmount"
		else:
			raise KeyError(self.how)
		result = f"""{self.who}:{how}("{self.what}", {self.amount})\n"""
		return result

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


