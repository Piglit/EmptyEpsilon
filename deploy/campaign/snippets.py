#!/usr/bin/env python3

"""several calls to the Pyro-Interface used for this campaing.
To be used in ipython: '%run snippets.py' loads this file.
You can call all the functions from here.
If you edit this rile, just run '%run snippets.py' again to reload.
"""
import Pyro4
import requests

def getCampaign():
	return Pyro4.Proxy("PYRONAME:campaign_state")

def getRoundTimer():
	return Pyro4.Proxy("PYRONAME:round_timer")

campaign = getCampaign()
roundTimer = getRoundTimer()

def addCode(ship, additionalCode):
	code = campaign.getShipAdditionalCode(ship)
	campaign.setShipAdditionalCode(code+additionalCode, ship)

def clearCode(ship):
	code = campaign.getShipAdditionalCode(ship)
	if "ship.special" in code:
		print("WARNING: special was removed!")
	campaign.setShipAdditionalCode("", ship)

def showCode(ship):
	code = campaign.getShipAdditionalCode(ship)
	print(f"Spawn Code for {ship} is now:")
	print(code)
	print()

def execLua(code):
	return requests.get(f"http://127.0.0.1:8080/exec.lua", data=code).content	# TODO change ip

def prepareForAllies(ship):
	clearCode(ship)
	addCode(ship, """
if math.abs({ship.x}) < 100 and math.abs({ship.y}) < 100 then 
	ship:setRotation(180)
	ship:commandTargetRotation(180)
	ship:setPosition(100000, random(-100, 100))
	ship:commandImpulse(1)
end
""")
	campaign.unlockScenario("49_allies", ship)
	print(f"unlocked scenario 49_allies for {ship}")

def prepareForAlliesFirstShip(ship):
	prepareForAllies(ship)
	addCode(ship, "\nship:setTemplate('Adder MK7')")
	grantSpecial(ship, "buy_stations")
	print("Ship is now fixed to Adder MK7. Clean up that code after ship spawned!")

def grantSpecial(ship, special):
	assert special in ["buy_stations", "buy_ships", "intimidate_stations", "intimidate_ships"]
	campaign = getCampaign()
	code = campaign.getShipAdditionalCode(ship)
	code += "\nship.special_"+special+" = true"
	campaign.setShipAdditionalCode(code, ship)
	print("Special granted. It will work when ship spawns, but not yet if ship already exists.")

def spawnablePrototypes(ship, otherCallsign, otherPW, spawnX, spawnY):
	script = """
		if "{ship.template}" == "Hammer" or "{ship.template}" == "Anvil" then
			ship2 = PlayerSpaceship()
			if "{ship.template}" == "Hammer" then 
				ship2:setTemplate("Anvil")
			elseif "{ship.template}" == "Anvil" then
				ship2:setTemplate("Hammer")
			end
			ship2:setRotation({ship.rota}+180)
			ship2:commandTargetRotation({ship.rota}+180)
			ship2:setPosition({ship.x}, {ship.y})
			if "{ship.drive}" == "warp" then
				ship2:setWarpDrive(false):setJumpDrive(true)
			else
				ship2:setWarpDrive(true):setJumpDrive(false)
			end""" + f"""
			ship2:setCallSign("{otherCallsign}")
			ship2:setControlCode("{otherPW}")
			ship2:setPosition({spawnX}, {spawnY})
			ship:setPosition({spawnX}, {spawnY})
		end
	"""
	clearCode(ship)
	addCode(ship, script)
	campaign.unlockShips(["Hammer", "Anvil"], ship)
	print(f"unlocked Hammer and Anvil for {ship}.")
	print(f"Do not forget to unlock them for {otherCallsign}, too.")

def spawnSpySat(spawnX, spawnY):
	script = f"""
		ship = PlayerSpaceship()
		ship:setPosition({spawnX}, {spawnY})
		ship:setTemplate("SpySat")
		ship:setCallSign("SpySat")
		table.insert(getScriptStorage().scenario.spySats, ship)
	"""
	execLua(script)
	print("Note: SpySat sets its control code to the name of the closest ship.")
	print("If there are multiple SpySats, consider renaming them to make then distinguishable")

def startTimedEnemies():
	roundTimer.setOnPause("""
	scenario = getScriptStorage().scenario
	scenario.makeFleetAggro("Kraylor")
	scenario.makeFleetAggro("Exuari")
	""")
	roundTimer.setOnRound("""
	scenario = getScriptStorage().scenario
	scenario.spawnDefensiveFleet(300, "Kraylor")
	scenario.spawnDefensiveFleet(300, "Exuari")
	""")

def ktlitanPlotStep():
	execLua("""getScriptStorage().scenario.ktlitanOrders()""")
	execLua("""getScriptStorage().scenario.spawnDefensiveFleet(100, "Ktlitans")""")

def setDifficulty(difficulty):
	assert isinstance(difficulty, int)
	execLua(f"""getScriptStorage().scenario.difficulty = {difficulty}""")

def getShip(callsign):
	return f"""
	idx = getPlayerShipIndex("{ship.callsign}")
	ship = getPlayerShip(idx)
	"""
