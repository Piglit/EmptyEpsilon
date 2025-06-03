-- TODO: if carrier captures pod, it is immediately "delivered"
ENABLE_RESCUE_BUTTONS = false
ENABLE_RESCUE_BY_GRABBER = true
require("utils_customElements.lua")


rescue_capsule_util = {
	CAPTURE_DISTANCE = 100,
	pods = {},
	ships_templates_that_spawn_pods = {
		"TIE-Fighter",
		"TIE-Interceptor",
		"TIE-Bomber",
		"TIE-Reaper",
	},
	ui_station = "Weapons",
}

function rescue_capsule_util:onNewPlayerShip(ship)
	if arrayContains(self.ships_templates_that_spawn_pods, ship:getTypeName()) then
		-- warning onDestroyed can only be defined once per ship!
		ship:onDestroyed(function(obj,_) rescue_capsule_util.spawnRescueCapsule(obj) end)
	end
end

function rescue_capsule_util:updatePlayerShip(delta, ship)
	if ENABLE_RESCUE_BUTTONS and ship:isValid() then
		self:addOrUpdateCollectCapsuleButton(ship)
	end
end

function rescue_capsule_util:gm_menu()
	addGMFunction("Spawn rescuable pilot", function()
		clearGMFunctions()
		onGMClick(function(x,y)
			rescue_capsule_util.spawnNewPilotPod(x,y)
			onGMClick(nil)
			plot_manager.gm_main_menu()
		end)
		gm_menu_back()
	end)
end

function rescue_capsule_util.spawnNewPilotPod(x,y)
	local pod = PlayerSpaceship():setTemplate("TIE-Pilot"):setFaction("Independent"):setPosition(x,y):setCanBeDestroyed(false)
	table.insert(rescue_capsule_util.pods, pod)
	if gravity_util ~= nil and gravity_util.addException ~= nil then
		gravity_util.addException(pod)
	end
	if ENABLE_RESCUE_BY_GRABBER then
		player_ships_util:add_grabbable_object(pod)
	end
	return pod
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
		local pod = rescue_capsule_util.spawnNewPilotPod(x,y)
		pod:setFaction("Pilot")
		print(callsign .. " destroyed")
		pod:setCallSign(callsign)
		-- configure autoconnect for a callsign, to reconnect the clients of the destroyed ship to the pod after the "ship destroyed" screen was shown.
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
				customElements:removeCustom(obj, "POD_DIST_"..callsign)
				if self_docked ~= nil then
					customElements:addCustomButton(obj, self.ui_station, "POD_"..callsign, string.format(_("%s abliefern"), callsign), function()
						pod:destroy()
						customElements:removeCustom(obj, "POD_"..callsign)
						customElements:removeCustom(obj, "POD_DIST_"..callsign)
					end, 50+i)
				else
					customElements:addCustomButton(obj, self.ui_station, "POD_"..callsign, string.format(_("%s rauswerfen"), callsign), function()
						pod:commandUndock()
						pod:setRotationMaxSpeed(1)
						customElements:removeCustom(obj, "POD_"..callsign)
						customElements:removeCustom(obj, "POD_DIST_"..callsign)
						pod.docking_assist_target = nil
					end, 50+i)
				end
			elseif docked == nil and distance(obj, pod) <= self.CAPTURE_DISTANCE then
				if pod.docking_assist_target == nil then
					customElements:addCustomButton(obj, self.ui_station, "POD_"..callsign, string.format(_("%s bergen"), callsign), function()
						pod:setRotationMaxSpeed(1)
						pod:setSystemHealth("maneuver", 1.0)
						pod:setSystemHealth("impulse", 1.0)
						pod:commandDock(obj)	-- this should also be possible when canDock is false
						pod.docking_assist_target = obj 
						customElements:removeCustom(obj, "POD_"..callsign)
						customElements:removeCustom(obj, "POD_DIST_"..callsign)
					end, 50+i)
				else
					customElements:addCustomButton(obj, self.ui_station, "POD_"..callsign, string.format(_("Bergung %s abbrechen"), callsign), function()
						pod.docking_assist_target = nil
						pod:commandAbortDock()
						pod:setRotationMaxSpeed(1)
					end, 50+i)
					local dist = math.floor(distance(pod, obj)) - 20 -- - radius of TIEs
					if dist > 4 then
						customElements:addCustomInfo(obj, self.ui_station, "POD_DIST_"..callsign, string.format(_("Abstand zu %s: %im"), callsign, dist), 50-i)
					else
						local darc = math.abs(1-((angleHeading(pod, obj) - pod:getHeading() - 180)%360)/180)
						customElements:addCustomInfo(obj, self.ui_station, "POD_DIST_"..callsign, string.format(_("Bergung %s: %i%%"), callsign, math.floor(darc*100-dist)), 50-i)

					end
				end
			else
				customElements:removeCustom(obj, "POD_"..callsign)
				customElements:removeCustom(obj, "POD_DIST_"..callsign)
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

function rescue_capsule_util:initTest()
	local ship1 = PlayerSpaceship():setTemplate("TIE Fighter"):setCallSign("Pod Collector"):setPosition(0,0)--:setFaction("Imperial")
	local ship2 = PlayerSpaceship():setTemplate("TIE Fighter"):setCallSign("Pod1"):setPosition(100,0)
	local ship3 = PlayerSpaceship():setTemplate("TIE Fighter"):setCallSign("Pod2"):setPosition(100,100)
	local ship4 = PlayerSpaceship():setTemplate("TIE Fighter"):setCallSign("Pod3"):setPosition(1100,1100)
	local ship5 = PlayerSpaceship():setTemplate("TIE Fighter"):setCallSign("Rival Collector"):setPosition(500,500):setFaction("Imperial")
	ship2:destroy()
	ship3:destroy()
	ship4:destroy()
end
