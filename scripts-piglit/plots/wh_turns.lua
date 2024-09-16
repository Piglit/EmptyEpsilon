--[[

Chapters:
earlyPause:
	super slow
	enemies from wormhole get deleted
	ends with first player spawn after self.init() (station does not count): unslow
inGame:
	turn 1 starts on wormhole jump
	after 30 Min -> soft slow -> after 10 Min -> unslow -> onWormholeJump -> nextTurn
	onWormholeJump(station) -> lateGame
lateGame:																			 
 	after 45 min -> slow -> after 10 Min -> unslow -> nextTurn
--]]

wh_turns = {}

-- TODO soft slow

function wh_turns:init()
	self.state = "interlude"	-- states: turn -> pause -> interlude
	self.turnTime = 30*60
	self.pauseTime = 10*60	-- real time

	self.countdown = 0
	self.nextFunction = nil
	self.nextFunctionTurn = self.startPause
	self.nextFunctionPause = self.startInterlude	-- will be set to startTurn after fleet command jumped

	self.chapter = "earlyPause"	-- "inGame", "lateGame"
	self.turn = 0
	self.onStart = {}
	self.onPause = {}

	superSlowGame()
	wh_wormhole:addOnTeleport(self.onWormhole)

	getScriptStorage().wh_turns = self
end

function wh_turns:initTest()
	unslowGame()
end

function wh_turns:startTurn()
	self.state = "turn"
	self.countdown = self.turnTime
	self.nextFunction = self.nextFunctionTurn 
	self.turn = self.turn + 1
	unslowGame()
	setScanningComplexity('normal')
	setHackingDifficulty(2)
	globalMessage('', 0)
	for id, script in pairs(self.onStart) do
		script()
	end
	sendMessageToCampaignServer("turn", self.turnTime)
end

function wh_turns:startPause()
	self.state = "pause"
	self.countdown = self.pauseTime / 10	--paused
	self.nextFunction = self.nextFunctionPause
	slowGame()
	setScanningComplexity('none')
	setHackingDifficulty(3)
	--local endTime = os.date("%H:%M", os.time() + self.pauseTime)	-- FIXME: os not avail
	--globalMessage('Flottenbesprechung bis '..endTime)
	for id, script in pairs(self.onPause) do
		script()
	end
	sendMessageToCampaignServer("pause", self.pauseTime)
end

function wh_turns:startInterlude()
	self.state = "interlude"
	unslowGame()
	setScanningComplexity('normal')
	setHackingDifficulty(2)
	globalMessage('', 0)
	-- wait until player uses wormhole to start next turn
	sendMessageToCampaignServer("interlude")
end

function wh_turns.onWormhole(wormhole, teleportee)

	if wh_turns.chapter == "inGame" and teleportee.typeName == "PlayerSpaceship" and wormhole == wh_wormhole.wormhole_a then
		if (wh_turns.state == "interlude" or self.state == "pause") then
			wh_turns:startTurn()
		end
		if teleportee == wh_fleetcommand.station then
			wh_turns.lateGame = "lateGame"
			wh_turns.nextFunctionPause = wh_turns.startTurn
			wh_turns.turnTime = 45*60
		end
	end
	if wh_turns.chapter == "earlyPause" and teleportee.typeName == "CpuShip" then
		teleportee:destroy()
	end
end

function wh_turns:addOnStart(identifier, script)
	self.onStart[identifier] = script
end

function wh_turns:removeOnStart(identifier)
	self.onStart[identifier] = nil
end

function wh_turns:addOnPause(identifier, script)
	self.onPause[identifier] = script
end

function wh_turns:removeOnPause(identifier)
	self.onPause[identifier] = nil
end

function wh_turns:onNewPlayerShip(ship)
	if self.chapter == "earlyPause" then
		unslowGame()
		self.chapter = "inGame"
	end
end

function wh_turns:update(delta)
	self.countdown = self.countdown - delta
	if self.nextFunction ~= nil and self.countdown <= 0 then
		self:nextFunction()
	end
end
