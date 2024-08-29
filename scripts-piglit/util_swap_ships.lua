-- utility functions to swap ships and transfer crew.
-- beware, that attributes that only slayer ships have get deleted when transfering
-- this means, that swapping back and forth will reset some attributes
-- also note, that script defined attributes will get deleted, too.

SwapCountdown = nil

function swapPlayerAndCpuShip(player_ship, cpu_ship)
	local swapx, swapy = cpu_ship:getPosition()	--save NPC ship location
	local swapRotate = cpu_ship:getRotation()		--save NPC ship orientation
	cpu_ship:setPosition(500,500)			--move NPC ship away
	local template = cpu_ship:getTypeName():sub(2)

	local new_player_ship = PlayerSpaceship():setTemplate(template):setPosition(swapx,swapy)
	new_player_ship:setRotation(swapRotate)		--set orientation that was saved
	new_player_ship:commandTargetRotation(swapRotate)
	new_player_ship:setCallSign(cpu_ship:getCallSign())
	new_player_ship:setFaction(cpu_ship:getFaction())
	new_player_ship:setSystemHealth("reactor", cpu_ship:getSystemHealth("reactor"))
	new_player_ship:setSystemHealth("beamweapons", cpu_ship:getSystemHealth("beamweapons"))
	new_player_ship:setSystemHealth("maneuver", cpu_ship:getSystemHealth("maneuver"))
	new_player_ship:setSystemHealth("missilesystem", cpu_ship:getSystemHealth("missilesystem"))
	new_player_ship:setSystemHealth("impulse", cpu_ship:getSystemHealth("impulse"))
	new_player_ship:setSystemHealth("warp", cpu_ship:getSystemHealth("warp"))
	new_player_ship:setSystemHealth("jumpdrive", cpu_ship:getSystemHealth("jumpdrive"))
	new_player_ship:setSystemHealth("frontshield", cpu_ship:getSystemHealth("frontshield"))
	new_player_ship:setSystemHealth("rearshield", cpu_ship:getSystemHealth("rearshield"))
	new_player_ship:setHull(cpu_ship:getHull())
	new_player_ship:setShields(cpu_ship:getShieldLevel(0), cpu_ship:getShieldLevel(1))	--transfer shield statistics to NPC ship
	new_player_ship:setEnergy(new_player_ship:getEnergy()*0.75)

	cpu_ship:destroy()				--goodbye NPC ship

	swapx, swapy = player_ship:getPosition()		--save current position
	swapRotate = player_ship:getRotation()		--save current orientation
	player_ship:transferPlayersToShip(new_player_ship)	--switch players to new ship
	player_ship:setPosition(1000,1000)			--move away
	template = " "..player_ship:getTypeName()

	local new_cpu_ship = CpuShip():setTemplate(template):setPosition(swapx, swapy)
	new_cpu_ship:setRotation(swapRotate)				--transfer orientation to NPC ship
	new_cpu_ship:setCallSign(player_ship:getCallSign())
	new_cpu_ship:setFaction(player_ship:getFaction())
	new_cpu_ship:setScannedByFaction(player_ship:getFaction(), true)
	new_cpu_ship:setSystemHealth("reactor", player_ship:getSystemHealth("reactor"))
	new_cpu_ship:setSystemHealth("beamweapons", player_ship:getSystemHealth("beamweapons"))
	new_cpu_ship:setSystemHealth("maneuver", player_ship:getSystemHealth("maneuver"))
	new_cpu_ship:setSystemHealth("missilesystem", player_ship:getSystemHealth("missilesystem"))
	new_cpu_ship:setSystemHealth("impulse", player_ship:getSystemHealth("impulse"))
	new_cpu_ship:setSystemHealth("warp", player_ship:getSystemHealth("warp"))
	new_cpu_ship:setSystemHealth("jumpdrive", player_ship:getSystemHealth("jumpdrive"))
	new_cpu_ship:setSystemHealth("frontshield", player_ship:getSystemHealth("frontshield"))
	new_cpu_ship:setSystemHealth("rearshield", player_ship:getSystemHealth("rearshield"))
	new_cpu_ship:setHull(player_ship:getHull())	--transfer hull statistics to NPC ship
	new_cpu_ship:setShields(player_ship:getShieldLevel(0), player_ship:getShieldLevel(1))	--transfer shield statistics to NPC ship
	new_cpu_ship:orderIdle()							--NPC ship does nothing
	player_ship:destroy()				--goodbye player fighter

	new_player_ship:addToShipLog("Crew transfer complete", "green")
	return new_player_ship, new_cpu_ship
end

-- like swap, but no new cpu ship is spawned.
-- designed for crew pods
function boardCpuShip(player_ship, cpu_ship)
	local swapx, swapy = cpu_ship:getPosition()	--save NPC ship location
	local swapRotate = cpu_ship:getRotation()		--save NPC ship orientation
	cpu_ship:setPosition(500,500)			--move NPC ship away
	local template = cpu_ship:getTypeName():sub(2)

	local new_player_ship = PlayerSpaceship():setTemplate(template):setPosition(swapx,swapy)
	new_player_ship:setRotation(swapRotate)		--set orientation that was saved
	new_player_ship:commandTargetRotation(swapRotate)
	new_player_ship:setFaction(cpu_ship:getFaction())
	new_player_ship:setSystemHealth("reactor", cpu_ship:getSystemHealth("reactor"))
	new_player_ship:setSystemHealth("beamweapons", cpu_ship:getSystemHealth("beamweapons"))
	new_player_ship:setSystemHealth("maneuver", cpu_ship:getSystemHealth("maneuver"))
	new_player_ship:setSystemHealth("missilesystem", cpu_ship:getSystemHealth("missilesystem"))
	new_player_ship:setSystemHealth("impulse", cpu_ship:getSystemHealth("impulse"))
	new_player_ship:setSystemHealth("warp", cpu_ship:getSystemHealth("warp"))
	new_player_ship:setSystemHealth("jumpdrive", cpu_ship:getSystemHealth("jumpdrive"))
	new_player_ship:setSystemHealth("frontshield", cpu_ship:getSystemHealth("frontshield"))
	new_player_ship:setSystemHealth("rearshield", cpu_ship:getSystemHealth("rearshield"))
	new_player_ship:setHull(cpu_ship:getHull())
	new_player_ship:setEnergy(new_player_ship:getEnergy()*0.75)
	new_player_ship:setShields(cpu_ship:getShieldLevel(0), cpu_ship:getShieldLevel(1))
	new_player_ship:setCallSign(player_ship:getCallSign())	-- keep old callsign

	cpu_ship:destroy()				--goodbye NPC ship
	player_ship:transferPlayersToShip(new_player_ship)	--switch players to new ship
	player_ship:destroy()				--goodbye player fighter

	new_player_ship:addToShipLog("Crew transfer complete", "green")
	return new_player_ship
end


function swapCountdown(swapFunction, player_ship, cpu_ship, callback)
	SwapCountdown = {
		swapFunction = swapFunction,
		player_ship = player_ship,
		cpu_ship = cpu_ship,
		time = 10,
		callback = callback,
	}
end

function updateSwapCountdown(delta)
	if SwapCountdown ~= nil then
		local time = SwapCountdown.time - delta
		SwapCountdown.time = time
		local cpu_ship = SwapCountdown.cpu_ship
		local player_ship = SwapCountdown.player_ship
		local text = ""
		if time <= 0 then
			ps, cs = SwapCountdown.swapFunction(player_ship, cpu_ship)
			if SwapCountdown.callback ~= nil then
				SwapCountdown.callback(ps, cs)
			end
			SwapCountdown = nil
			text = "Transfer completed"
		else
			if cpu_ship == nil or not cpu_ship:isValid() or player_ship == nil or not player_ship:isValid() then
				text = "Transfer aborted!"
			else
				text = string.format(_("", "Transfer to %s in %d"), cpu_ship:getCallSign(), math.floor(time))
			end
		end
		globalMessage(text)
		setBanner(text)

		if time <= 0 then
			setBanner("")
		end
	end	
end
