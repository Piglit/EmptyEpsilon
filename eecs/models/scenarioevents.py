from enum import Enum
from pydantic import BaseModel

class ScenarioEvents(str, Enum):
	started = "started"
	paused = "paused"
	unpaused = "unpaused"
	slowed = "slowed"
	quit = "quit"
	victory = "victory"
	defeat = "defeat"
	end = "end"
	joined = "joined"

	def fleet_info(self):
		if self == "started":
			return "is prepared for"
		if self == "unpaused":
			return "is pursuing"
		if self == "quit":
			return "returned from"
		if self == "victory":
			return "was victorious in"
		if self == "defeat":
			return "was defeated in"
		if self == "end":
			return "reached the end of"
		if self == "joined":
			return "joined"
		return self

