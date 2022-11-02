#!/usr/bin/env python3

"""
Allies your ship with the Ktlitans.
Run 'EmptyEpsilon httpserver=8080' for this script to work.
You also need to have a ship for this script to work.

When you run this script without any arguments, your ship will be able to communicate with Ktlirans. They will obey your orders, but they may not be thir highest priority.

When you run this script with 'convert' as command line argument, you will defy the Human Navy and join the Ktlitans. This starts PVP and should be only done once.
"""

import requests
import json
import sys

def execLua(code):
	return requests.get(f"http://192.168.2.3:8080/exec.lua", data=code).content

def getCallSign():
    try:
        return requests.get(f"http://127.0.0.1:8080/get.lua?cs=getCallSign()").content
    except requests.exceptions.ConnectionError:
        print("FAILED! start EmptyEpsilon with httpserver=8080 and try again.")
        exit(1)
    
def getShip():
    reply = json.loads(getCallSign())
    if "cs" not in reply:
        print("FAILED! No ship selected.")
        exit(1)
    cs = reply["cs"]
    print("Ship: "+cs)
    return f"""
   	idx = getPlayerShipIndex("{cs}")
	ship = getPlayerShip(idx)
    """

def setPetgSpecial():
    execLua(getShip() + """ship.special_petg = true""")
    print("can now communicate with Ktlitans.")

def setFaction():    
    execLua(getShip() + """ship:setFaction("Ktlitans")""")
    print("is now allied with Ktlitans.")

if __name__ == "__main__":
    if "convert" in sys.argv:
        setFaction()
    else:
        setPetgSpecial()
