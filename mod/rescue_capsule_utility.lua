rescue_capsule_util = {
	CAPTURE_DISTANCE = 100,
	pods = {},
	ships_templates_that_spawn_pods = {
		"TIE Fighter",
		"TIE Interceptor",
		"TIE Bomber",
		"TIE Reaper",
	},
}

function rescue_capsule_util:onNewPlayerShip(ship)
	if arrayContains(self.ships_templates_that_spawn_pods, ship:getTypeName()) then
		-- warning onDestroyed can only be defined once per ship!
		ship:onDestruction(function(obj,_) rescue_capsule_util.spawnRescueCapsule(obj) end)
	end
end

function rescue_capsule_util:updatePlayerShip(delta, ship)
	if ship:isValid() then
		self:addOrUpdateCollectCapsuleButton(ship)
	end
end

-- Usage:
-- player:onDestroyed(onPlayerShipDestroyedCallback)
-- onDestroyed must only be called once per object - so if you need multiple effects, create a wrapper.
function rescue_capsule_util.spawnRescueCapsule(obj)
	if obj == nil then
		error("spawnRescueCapsule is called on nil")
	end
	if obj.typeName ~= "PlayerSpaceship" then
		error("spawnRescueCapsule is only implemented for PlayerSpaceship")
	else
		local callsign = obj:getCallSign()
		local x,y = obj:getPosition()
		pod = PlayerSpaceship():setTemplate("TIE-Pilot"):setFaction("Pilot")
		pod:setCallSign(callsign):setPosition(x,y)
		pod:setCanBeDestroyed(false)
		-- configure autoconnect for a callsign, to reconnect the clients of the destroyed ship to the pod after the "ship destroyed" screen was shown.
		table.insert(rescue_capsule_util.pods, pod)
	end
end

-- Allow a player ship to collect escape capsules
-- Usage:
-- in update() call addOrUpdateCollectCapsuleButton(player_ship)
function rescue_capsule_util:addOrUpdateCollectCapsuleButton(obj)
	if obj.typeName ~= "PlayerSpaceship" then
		error("error: addOrUpdateCollectCapsuleButton is only implemented for PlayerSpaceship")
	elseif obj:getTypeName() == "TIE-Pilot" then
		-- can not rescue yourself or other pilots
		return
	else
		for i,pod in ipairs(self.pods) do
			if pod == nil or not pod:isValid() then
				table.remove(self.pods, i)
				return
			end
			local callsign = pod:getCallSign()
			local docked = pod:getDockedWith()
			local self_docked = obj:getDockedWith()
			if docked == obj then
				if self_docked ~= nil then
					obj:addCustomButton("Single", "POD_"..callsign, "Deliver "..callsign, function()
						pod:destroy()
						obj:removeCustom("POD_"..callsign)
					end, 50+i)
				else
					obj:addCustomButton("Single", "POD_"..callsign, "Release "..callsign, function()
						pod:commandUndock()
						pod:setRotationMaxSpeed(1)
						obj:removeCustom("POD_"..callsign)
						pod.docking_assist_target = nil
					end, 50+i)
				end
			elseif docked == nil and distance(obj, pod) <= self.CAPTURE_DISTANCE then
				if pod.docking_assist_target == nil then
					obj:addCustomButton("Single", "POD_"..callsign, "Rescue "..callsign, function()
						pod:setRotationMaxSpeed(1)
						pod:setSystemHealth("maneuver", 1.0)
						pod:setSystemHealth("impulse", 1.0)
						pod:commandDock(obj)	-- this should also be possible when canDock is false
						pod.docking_assist_target = obj 
						obj:removeCustom("POD_"..callsign)
					end, 50+i)
				else
					obj:addCustomButton("Single", "POD_"..callsign, "Stop rescuing "..callsign, function()
						pod.docking_assist_target = nil
						pod:commandAbortDock()
						pod:setRotationMaxSpeed(1)
					end, 50+i)
				end
			else
				obj:removeCustom("POD_"..callsign)
			end
		end
	end
end

function rescue_capsule_util:update(delta)
	-- move docking pods towards their target, for they may not have an impulse drive
	for _,pod in ipairs(self.pods) do
		if pod ~= nil and pod:isValid() then
			local target = pod.docking_assist_target
			if target ~= nil and target:isValid() then
				local dist = distance(pod, target)
				if pod:getDockedWith() ~= nil or dist > self.CAPTURE_DISTANCE then
					-- abort dock
					pod.docking_assist_target = nil
					pod:commandAbortDock()
					pod:setRotationMaxSpeed(1)
				else
					--[[ What looks good:
					-- d > 40: not much to see, move quick
					-- 40 > d > 25: beautiful cinematic, speed: 1/s
					-- d == radius: wait for turn, and speed it up
					-- d < radius: can not dock and glitch around. prevent
					--]]
					if dist > 25 then
						-- move pod to target
						local speed = (dist/25) * delta
						local angle = angleHeading(pod, target)
						local x0,y0 = pod:getPosition()
						local x1,y1 = vectorFromAngle(angle, speed, true)
						pod:setPosition(x0+x1, y0+y1)
					else
						-- rotate faster
						pod:setRotationMaxSpeed(6)
						pod:setSystemHealth("maneuver", 1.0)
						pod:setSystemHealth("impulse", 1.0)
					end
				end
			end
		end
	end
end
