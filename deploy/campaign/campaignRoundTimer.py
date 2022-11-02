#!/usr/bin/env python3
"""
Rundentimer
---

30 min Spiel
10 min Pause (Flottenbesprechung)

* Zeiten währenddessen anpassbar
* Kommunizieren: Banner? Chat-Nachricht?
* Slow Down during Pause
"""

import pyrohelper
import Pyro4
from datetime import datetime, timedelta
from threading import Timer
import requests

def _strfdelta(delta):
	rem = delta.seconds
	h, rem = divmod(rem, 3600)
	m, s = divmod(rem, 60)
	return f"{h:02}:{m:02}:{s:02}"


@Pyro4.expose
class CampaignRoundTimer:
	def __init__(self):
		self.round_time = 30*60
		self.pause_time = 10*60
		self.state = "Pause"
		self.timer = None
		self.warn_timer = None
		self.started = datetime.now()
		self.until = datetime.now()
		self.EEServer = "127.0.0.1"
		self.on_pause = ""
		self.on_round = ""
		self.startRound()

	def _sendEEcmd(self, cmd):
		try:
			requests.get(f"http://{self.EEServer}:8080/exec.lua", data=cmd)
			print(cmd)
		except Exception as e:
			print(e)

	def startRound(self):
		print(f"Start round ({self.round_time//60} minutes)")
		if self.timer:
			self.timer.cancel()
		self.started = datetime.now()
		self.until = datetime.now() + timedelta(seconds=self.round_time)
		self.state = "Round"
		self._sendEEcmd("unslowGame()")
		self._sendEEcmd("setScanningComplexity('normal')")
		self._sendEEcmd("setHackingDifficulty(2)")
		self._sendEEcmd("globalMessage('', 0)")
		self.timer = Timer(self.round_time, self.startPause)
		self.timer.start()
		if self.on_round:
			self._sendEEcmd(self.on_round)

	def startPause(self):
		print(f"Start pause ({self.pause_time//60} minutes)")
		if self.timer:
			self.timer.cancel()
		self.started = datetime.now()
		self.until = datetime.now() + timedelta(seconds=self.pause_time)
		self.state = "Pause"
		self._sendEEcmd("slowGame()")
		self._sendEEcmd("setScanningComplexity('none')")
		self._sendEEcmd("setHackingDifficulty(3)")
		self._sendEEcmd(f"""globalMessage('Flottenbesprechung bis {self.until.strftime("%H:%M")}')""")
		self.timer = Timer(self.pause_time, self.startRound)
		self.timer.start()
		if self.on_pause:
			self._sendEEcmd(self.on_pause)

	def setRoundTime(self, seconds):
		self.round_time = seconds

	def setPauseTime(self, seconds):
		self.pause_time = seconds

	def setOnPause(self, code):
		self.on_pause = code

	def setOnRound(self, code):
		self.on_round = code

	def nextPhase(self):
		if self.state == "Round":
			self.startPause()
		else:
			self.startRound()

	def getTimer(self):
		return {
			"state": self.state,
			"started": self.started.strftime("%H:%M:%S"),
			"until": self.until.strftime("%H:%M:%S"),
			"now": datetime.now().strftime("%H:%M:%S"),
			"left": _strfdelta(self.until - datetime.now())
		}

	def setEEServer(self, addr):
		self.EEServer = addr

crt = CampaignRoundTimer()
pyrohelper.host_named_server(crt, "round_timer")


