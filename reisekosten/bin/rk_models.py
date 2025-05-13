"""shared enum model between rk_http and rk_server"""
from enum import Enum

class ShipState(str, Enum):
	created	=	"created"
	deleted =	"deleted"
	docked  =	"docked"
	undocked=	"undocked"

class CostVisibility(Enum):
	# can switch between 0 and 1 or 2 and 3, depending on the original state
	hide = 0
	show = 1
	strike = 2
	nostrike = 3
	always = 4

