"""Represents a scenario"""
from pydantic import BaseModel
from pathlib import Path

PATH = Path(__file__).parent.parent.parent / "scripts-piglit"

class ScenarioSetting:
	def __init__(self, key: str, description: str):
		self.key = key
		self.description = description
		self.options = []	# maybe a better data structure is possible here.

	def addOption(self, option, description):
		self.options += (option, description)

class Scenario:
	def __init__(self, filename):
		assert filename.startswith("scenario"), f"filename '{filename}' has wrong format."
		assert filename.endswith(".lua"), f"filename '{filename}' has wrong format."
		self.filename = filename
		self.scriptId = filename.removeprefix("scenario_").removesuffix(".lua")
		assert "_" in self.scriptId, f"filename '{filename}' has wrong format."
		self.gmId = self.scriptId.split("_", maxsplit=1)[1]
		self.categories = []
		self.settings = []
		self.load_file()
		assert self.name
	
	def getInfo(self):
		# unused
		ret = {}
		for key in ["name", "description", "short description", "objective", "duration", "difficulty"]:
			if hasattr(self, key):
				ret[key] = getattr(self, key)
		return ret

	def load_file(self):
		with open(PATH/self.filename, "r") as file:
			value = ""
			key = ""
			for line in file:
				line = line.strip()
				if not line.startswith("--"):
					break
				if line.startswith("---"):
					line = line.removeprefix("---").strip()
					value = value + "\n" + line
				else:
					line = line.removeprefix("--").strip()
					if ":" not in line:
						key = ""
						continue
					self.addKeyValue(key, value)
					key, value = line.split(":", maxsplit=1)
					key = key.strip()
					value = value.strip()
			self.addKeyValue(key, value)

	def addKeyValue(self, key, value):
		if not key:
			return
		additional = ""
		if "[" in key and key.endswith("]"):
			key, additional = key[:-1].split("[", maxsplit=1)
		if key.lower() in ["name", "description", "author", "proxy", "short description", "objective", "duration", "difficulty"]:
			self.__dict__[key.lower()] = value
		elif key.lower() in ["type", "category"]:
			self.categories.append(value)
		elif key.lower() == "variation" and additional:
			if not self.addSettingOption("variation", additional, value):
				setting = ScenarioSetting("variation", "Select a scenario variation")
				setting.addOption("None", "")
				self.settings.append(setting)
				self.addSettingOption("variation", additional, value);
		elif key.lower() == "setting" and additional:
			self.settings.append(ScenarioSetting(additional, value))
		elif additional == "" or not self.addSettingOption(key, additional, value):
			raise RuntimeError(f"Unknown scenario meta data: {key}:{value}")

	def addSettingOption(self, key, option, description):
		tag = ""
		if "|" in option:
			option, tag = option.split("|", maxsplit=1)
		for setting in self.settings:
			if setting.key == key:
				setting.addOption(option, description)
				if tag == "default":
					setting.setDefaultOption = option
				return True
		return False

	def __str__(self):
		return self.name

# the same scenario will get stored under different names!
scenarios = {}
scenarios_unique = {}
def loadScenarios(filenames):
	if isinstance(filenames, str):
		filenames = [filenames]
	assert isinstance(filenames, list)
	for fn in filenames:
		s = Scenario(fn)
		assert fn not in scenarios
		scenarios[fn] = s
		scenarios_unique[fn] = s
		assert s.scriptId not in scenarios
		scenarios[s.scriptId] = s
		assert s.gmId not in scenarios
		scenarios[s.gmId] = s

def getScenario(name):
	"""get a scenario by filename or scriptId or gmId"""
	return scenarios[name]

def clearScenarios():
	scenarios = {}
