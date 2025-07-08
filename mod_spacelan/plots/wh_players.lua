--[[ Handles player stats
-- test depends on wormhole
--]]

wh_players = {}
require "xansta_mods.lua"
require "utils.lua"

function wh_players:init()
	-- Select wich of xanstas stuff to use; uses global vars
	feature_cargoInventory = true	-- only until there is a seperate screen for it
	feature_autoCoolant = false
	feature_crewFate = true
	feature_coolantNebulae = false

	self.playerShipStats = {
		["Atlantis"]			= { strength = 52,	cargo = 6,	distance = 400,	probes = 10,},
		["Benedict"]			= { strength = 10,	cargo = 9,	distance = 400,	probes = 10,},
		["Crucible"]			= { strength = 45,	cargo = 5,	distance = 200,	probes = 9,},
		["Ender"]				= { strength = 100,	cargo = 20,	distance = 2000,probes = 12,},
		["Flavia P.Falcon"]		= { strength = 13,	cargo = 15,	distance = 200,	probes = 8,},
		["Hathcock"]			= { strength = 30,	cargo = 6,	distance = 200,	probes = 8,},
		["Kiriya"]				= { strength = 10,	cargo = 9,	distance = 400,	probes = 10,},
		["Maverick"]			= { strength = 45,	cargo = 5,	distance = 200,	probes = 9,},
		["MP52 Hornet"] 		= { strength = 7, 	cargo = 1,	distance = 100,	probes = 5,},
		["Nautilus"]			= { strength = 12,	cargo = 7,	distance = 200,	probes = 10,},
		["Phobos M3P"]			= { strength = 19,	cargo = 10,	distance = 200,	probes = 6,},
		["Piranha M5P"]			= { strength = 16,	cargo = 8,	distance = 200,	probes = 6,},
		["Player Cruiser"]		= { strength = 40,	cargo = 6,	distance = 400,	probes = 10,},
		["Player Missile Cr."]	= { strength = 45,	cargo = 8,	distance = 200,	probes = 9,},
		["Player Fighter"]		= { strength = 7,	cargo = 3,	distance = 100,	probes = 4,},
		["Repulse"]				= { strength = 14,	cargo = 12,	distance = 200,	probes = 8,},
		["Striker"]				= { strength = 8,	cargo = 4,	distance = 200,	probes = 6,},
		["ZX-Lindworm"]			= { strength = 8,	cargo = 1,	distance = 100,	probes = 4,},
		["Ryu"]					= { strength = 9,	cargo = 1,	distance = 100,	probes = 4,},
		["Adder MK7"]			= { strength = 10,	cargo = 3,	distance = 100,	probes = 4,},
		["Pod"]					= { strength = 1,	cargo = 0,	distance = 100,	probes = 0,},
		["Poseidon"]			= { strength = 30,	cargo = 6,	distance = 400,	probes = 10,},
		["Targaryen"]			= { strength = 1,	cargo = 0,	distance = 1200,probes = 12,},
	}

	self.shipsByInstance = {}
	getScriptStorage().wh_players = self
end

function wh_players:initTest()
	self:onProxySpawn("localhost", "TestSpawn", "Phobos M3P", "warp", "")
end

function wh_players:onProxySpawn(instance, callsign, template, drive, password)
	if self.shipsByInstance[instance] ~= nil and self.shipsByInstance[instance]:isValid() then
		return callsign -- a ship for your proxy already exists
	end
	local ship = PlayerSpaceship():setTemplate(template):setCallSign(callsign):setControlCode(password)
	if drive == "warp" then
		ship:setWarpDrive(true):setJumpDrive(false)
	elseif ship.drive == "jump" then
		ship:setWarpDrive(false):setJumpDrive(true)
	end

	if self.shipsByInstance[instance] == nil then
		self:spawnedShipEnterSector(ship, callsign)
	else
		self:respawnedPlayerShip(ship)
	end
	sendMessageToCampaignServer("request_reputation", callsign)
	sendMessageToCampaignServer("request_artifacts", callsign)
	self.shipsByInstance[instance] = ship
	return callsign
end

function wh_players:spawnedShipEnterSector(ship, callsign)
	local angle = wh_wormhole.wormhole_a.angle
	local ax, ay = vectorFromAngle(angle, -25000)	-- opposite side
	ship:setPosition(wh_wormhole.a_center[1]+ax, wh_wormhole.a_center[2]+ay)
	ship:setRotation(angle):commandTargetRotation(angle)
end

function wh_players:respawnedPlayerShip(ship)
	local station = getScriptStorage().wh_fleetcommand.station
	if station ~= nil and station:isValid() then
		local x,y = station:getPosition()
		setCirclePos(ship, x,y, random(0,360), 500)
		ship:commandDock(station)
	else
		self:spawnedShipEnterSector(ship)
	end
end

function wh_players:onNewPlayerShip(p)
	self:updatePlayerSoftTemplate(p)
	p:onDestruction(wh_players.onDestruction)
end
function wh_players:updatePlayerSoftTemplate(p)
	--set defaults for those ships not found in the list
	p.shipScore = 24
	p.maxCargo = 5
	p.cargo = p.maxCargo
	p.goods = {}
	local tempTypeName = p:getTypeName()
	if tempTypeName ~= nil then
		if self.playerShipStats[tempTypeName] ~= nil then
			p.shipScore = self.playerShipStats[tempTypeName].strength
			p.maxCargo = self.playerShipStats[tempTypeName].cargo
			p.cargo = p.maxCargo
			p:setMaxScanProbeCount(self.playerShipStats[tempTypeName].probes)
			p:setScanProbeCount(p:getMaxScanProbeCount())
			p.score_settings_source = tempTypeName
		else
			addGMMessage(string.format("Player ship %s's template type (%s) could not be found in table PlayerShipStats",p:getCallSign(),tempTypeName))
		end
	end
	p.maxRepairCrew = p:getRepairCrewCount()
	p.healthyShield = 1.0
	p.prevShield = 1.0
	p.healthyReactor = 1.0
	p.prevReactor = 1.0
	p.healthyManeuver = 1.0
	p.prevManeuver = 1.0
	p.healthyImpulse = 1.0
	p.prevImpulse = 1.0
	if p:getBeamWeaponRange(0) > 0 then
		p.healthyBeam = 1.0
		p.prevBeam = 1.0
	end
	local tube_count = p:getWeaponTubeCount()
	if tube_count > 0 then
		p.healthyMissile = 1.0
		p.prevMissile = 1.0
		local size_letter = {
			["small"] = 	"S",
			["medium"] =	"M",
			["large"] =		"L",
		}
		p.tube_size = ""
		for i=1,tube_count do
			p.tube_size = p.tube_size .. size_letter[p:getTubeSize(i-1)]
		end
	end
	if p:hasWarpDrive() then
		p.healthyWarp = 1.0
		p.prevWarp = 1.0
	end
	if p:hasJumpDrive() then
		p.healthyJump = 1.0
		p.prevJump = 1.0
	end
	p.skip_next_health_check = false
	p.initialCoolant = p:getMaxCoolant()
	local system_types = {"reactor","beamweapons","missilesystem","maneuver","impulse","warp","jumpdrive","frontshield","rearshield"}
	p.normal_coolant_rate = {}
	p.normal_power_rate = {}
	for _, system in ipairs(system_types) do
		p.normal_coolant_rate[system] = p:getSystemCoolantRate(system)
		p.normal_power_rate[system] = p:getSystemPowerRate(system)
	end
	p.docked_time = 0
end

function wh_players.onDestruction(player, instigator)
	local amount = player:getResourceAmount("Artifacts")
	local details = {}
	for _,name in ipairs(player:getResources("Strategic Information")) do
		local descr = player:getResourceDescription(name)
		table.insert(details, {name, descr})
	end
	amount = math.min(amount, #details)
	local x,y = player:getPosition()
	wh_artifacts:artsplosion(x,y,amount,details)
end

function wh_players:update(delta)
	xanstas_player_update(delta)
end
