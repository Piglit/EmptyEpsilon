#!/usr/bin/python3
import Pyro4
from time import sleep
from datetime import datetime

campaign = Pyro4.Proxy("PYRONAME:campaign_state")
format = "{:<16}{:<24}{}"
timer = Pyro4.Proxy("PYRONAME:round_timer")

while(True):
    # clear term
    sleep(1)
    print(chr(27)+"[2J")
    print("Time: "+datetime.now().strftime("%H:%M:%S"))
    stati = campaign.getStatusAll()
    try:
        t = timer.getTimer()
        print(f"{t['state']} {t['left']} ({t['until']})")
    except:
        pass
    print(format.format("Ship", "Mission", "Progress"))
    print(80*"-")
    for srv, status in stati.items():
        if "\t" in status:
            mission, progress = status.split("\t", maxsplit=1)
            print(format.format(srv,mission,progress))
        else:
            print(format.format(srv,status, ""))

