--[[ Utility to spawn collectible Artifacts
-- contains logic to transfer artifacts and knowledge to a station
-- can be called from anywhere, no dependencies.
--]]
wh_artifacts = {}


function wh_artifacts:init()
	self.callsign_counter = 1000
	self.artifacts_total = 0
	self.artifacts_collected = 0
	self.artifacts_destroyed = 0
	self.artifacts_delivered = 0
	self.artifacts = {}
	self.generic_infos = {}

	self.strategic_db = ScienceDatabase():setName("Strategic Information"):setLongDescription("Ships of the fleet can gather strategic information by collecting artifacts or completing missions. When a ship with strategic information docks with the fleet command station, the strategic information gets uploaded to all ship databases.")

	self.artsplosions = {}
	getScriptStorage().wh_artifacts = self 
end

function wh_artifacts:initTest()
	PlayerSpaceship():setTemplate("Adder MK7"):setCallSign("Artifact Collector"):setPosition(-10000,0):setRotation(90):commandTargetRotation(90)

	self:placeGenericArtifact(-10000, 1000):setScanningParameters(1, 1):setScanned(true)
	self:placeDetailedArtifact(-10000, 2000, "Test", "Testdescription"):setScanningParameters(1, 1)
	self:addGenericInfo("Keks1", "Keksinhalt1")
	self:addGenericInfo("Keks1", "Keksinhalt2")
	self:placeGenericArtifact(-10000, 3000):setScanningParameters(1, 1):setScanned(true)
	self:placeGenericArtifact(-10000, 4000):setScanningParameters(1, 1)
end

function wh_artifacts:addGenericInfo(name, info)
	-- the artifact description will be determined on pickup
	-- last in fist out!
	table.insert(self.generic_infos, {name, info})
end

function wh_artifacts:placeGenericArtifact(x,y,callback)
	local freq = math.floor(random(20, 40)) * 20
	self.callsign_counter = self.callsign_counter + math.floor(random(1,200))
	local callsign = self.callsign_counter
	local artifact = Artifact():setPosition(x, y)
	artifact:setDescriptions(_("A piece of space junk. Scan to find out the capturing frequency"), _("\nCapturing frequency:").." "..freq.. ".\nCalibrate your shields to this frequency and activate them to capture it.")
	artifact:setScanningParameters(4, 1)

	artifact.freq=freq
	if freq < 595 then
		artifact:setModel("debris-cubesat")
	else
		artifact:setModel("debris-blob")
	end
	artifact.callback = callback	-- can be nil
	artifact:allowPickup(true)
	artifact:setCallSign(callsign):setRadarTraceColor(96,128,255)
	artifact:onPickUp(wh_artifacts.onPickUp)
	self.artifacts_total = self.artifacts_total + 1
	artifact.resource_name = "#generic#"
	artifact.resource_descr = nil 
	artifact.info_collected = "Artifact collected\n\nDeliver it to the fleet command station.\nEach recovered artifact can be used to upgrade the fleet command station."
	artifact.info_destroyed = "Artifact was destroyed.\nTo collect artifacts you need to have shields active and calibrated to the capturing frequency of the artifact."

	table.insert(self.artifacts, artifact)
	
	return artifact 
end

function wh_artifacts:placeDetailedArtifact(x,y,name,info,callback)
	local artifact = self:placeGenericArtifact(x,y,callback)
	if name == nil or info == nil then
		error("invalid usage: placeDetailedArtifact needs name and info parameters")
		return artifact
	end
	artifact:setDescriptions(_(name..". Scan to find out the capturing frequency"), name.._("\nCapturing frequency:").." "..artifact.freq.. ".\nCalibrate your shields to this frequency and activate them to capture it.")
	artifact.resource_name = name
	artifact.resource_descr = info 
	artifact.info_collected = "Collected "..name..".\n\n"..info.."\n\nDeliver it to the fleet command station to upload strategic information for the fleet.\nEach recovered artifact can be used to upgrade the fleet command station."
	artifact.info_destroyed = name .. " was destroyed.\nTo collect artifacts you need to have shields active and calibrated to the capturing frequency of the artifact."
	return artifact
end

function wh_artifacts.onPickUp(art, player)
	shieldfreq = 400+(player:getShieldsFrequency())*20
	local ax, ay = art:getPosition()
	local x, y = player:getPosition()
	if shieldfreq == art.freq and player:getShieldsActive() == true then
		ElectricExplosionEffect():setPosition(x,y):setSize(200)
		player:takeDamage(1, "kinetic", ax, ay)
		player:addReputationPoints(20)
		player:increaseResourceAmount("Artifacts", 1)
		player:setResourceDescription("Artifacts", "Deliver Artifacts to the fleet command station.")
		if art.resource_name == "#generic#" then
			-- pop from list, may be nil, if list is empty
			art.resource_name, art.resource_descr = table.unpack(table.remove(wh_artifacts.generic_infos))
			if art.resource_name ~= nil and art.resource_descr ~= nil then
				art.info_collected = "Collected "..art.resource_name..".\n\n"..art.resource_descr.."\n\nDeliver it to the fleet command station to upload strategic information for the fleet.\nEach recovered artifact can be used to upgrade the fleet command station."
			end
		end

		if art.callback ~= nil then
			art.callback(art, player, true)	-- can modify the infos
		end

		if art.resource_name ~= nil then
			player:increaseResourceAmount(art.resource_name, 1)
			player:setResourceCategory(art.resource_name, "Strategic Information")
			if art.resource_descr ~= nil then
				player:setResourceDescription(art.resource_name, art.resource_descr)
			end
		end
		wh_artifacts.artifacts_collected = wh_artifacts.artifacts_collected + 1
		player:addCustomMessage("Science", "artifact_gathered", art.info_collected)
		player:addCustomMessage("Operations", "artifact_gathered", art.info_collected)
		player:addCustomMessage("Single", "artifact_gathered", art.info_collected)
		player:addToShipLog(art.info_collected.."\n(Reputation +20)", "magenta")
	else
		ExplosionEffect():setPosition(ax,ay):setSize(200)
		player:takeDamage(50, "kinetic", ax, ay)
		wh_artifacts.artifacts_destroyed = wh_artifacts.artifacts_destroyed + 1
		if art.callback ~= nil then
			art.callback(art, player, false)	-- can modify the infos
		end
		player:addCustomMessage("Science", "artifact_destroyed", art.info_destroyed)
		player:addCustomMessage("Operations", "artifact_destroyed", art.info_destroyed)
		player:addCustomMessage("Single", "artifact_destroyed", art.info_destroyed)
		player:addToShipLog(art.info_destroyed, "magenta")
	end
end

function wh_artifacts:transferArtifacts(ps, fc)
	-- ps: player ship
	-- fc: fleet command station
	-- both must be already verified and should be docked

	-- campaign artifacts
	local arts = ps:getResources("Campaign Artifacts")
	local valid = 0
	for _,a in ipairs(arts) do
		if fc:getResourceAmount(a) < 1 then
			-- this artifact was not delivered by another ship yet
			local info = ps:getResourceDescription(a)
			ps:increaseResourceAmount("Artifacts", 1)	-- add as artifact
			valid = valid + 1
		end
		ps:setResourceCategory(a, "Strategic Information")	-- change category, keep descr.
	end
	if #arts > 0 then
		local msg_ps = ""
		if valid > 1 then
			msg_ps = tostring(#valid) .. " of your " .. tostring(#arts) .. " artifacts from previous missions contain new strategic information for the fleet command and are applicable for station upgrades."
		elseif valid == 1 then
			msg_ps = "One of your artifacts from previous missions contains new strategic information for the fleet command and is applicable for station upgrades."
		else
			msg_ps = "None of your Artifacts from previous missions are applicable for station upgrades, since the fleet command already possesses similar artifacts."
		end
		ps:addToShipLog(msg_ps, "magenta")
	end

	-- scenario artifacts
	arts = ps:getResourceAmount("Artifacts")
	if arts > 0 then
		self.artifacts_delivered = self.artifacts_delivered + arts
		local msg = tostring(arts) .. " Artifact"
		if arts > 1 then
			msg = msg.."s"
		end
		local msg_ps = "Transferred " .. msg .. " to the station. The fleet command may use them for upgrades."
		ps:addReputationPoints(20 * arts)
		ps:transferResource("Artifacts", arts, fc)
		msg_ps = msg_ps .. "\n(Reputation +"..(20*arts)..")"
		ps:addToShipLog(msg_ps, "magenta")
		local msg_fc = "Received " .. msg .. " from ".. ps:getCallSign() .. "."
		fc:addToShipLog(msg_fc, "magenta")
	end

	-- strategic information
	local sis = ps:getResources("Strategic Information")
	for _,si in ipairs(sis) do
		local info = ps:getResourceDescription(si)
		if self.strategic_db:getEntryByName(si) == nil then
			self.strategic_db:addEntry(si):setLongDescription(info)
			fc:addToShipLog("Received strategic information from "..ps:getCallSign()..": "..si, "cyan")
		end
		ps:transferResource(si, ps:getResourceAmount(si), fc)
	end
	if #sis > 0 then
		ps:addReputationPoints(5 * #sis)
		local msg = "Strategic information was uploaded to the fleet's databases."
		msg = msg .. "\n(Reputation +"..tostring(5*#sis)..")"
		ps:addToShipLog(msg, "magenta")
		fc:addToShipLog("Strategic Information from "..ps:getCallSign().." has been uploaded to the fleet database.", "magenta")
	end
end

function wh_artifacts:artsplosion(x,y,amount,details)
	-- scatter amount artifacts in different directions
	local arts = {
		origin_x = x,
		origin_y = y,
		distance = 0,
		angles = {},
		objects = {},
		finished = false
	}
	for n=1,amount do
		local a = Artifact():setPosition(x, y):allowPickup(false):setRadarTraceColor(255,128,255)
		a.resource_name = details[n][1]
		a.resource_descr = details[n][2]
		table.insert(arts.objects, a)
		table.insert(arts.angles, random(0,360))
	end
	table.insert(self.artsplosions, arts)
end

function wh_artifacts:update(delta)
	for _,artsplosion in ipairs(self.artsplosions) do
		artsplosion.distance = artsplosion.distance + delta * 500 -- 1U in 2 sec
		for i,obj in ipairs(artsplosion.objects) do
			if obj ~= nil and obj:isValid() then
				local angle = artsplosion.angles[i]
				setCirclePos(obj, artsplosion.origin_x, artsplosion.origin_y, angle, artsplosion.distance)
				if artsplosion.distance > 1000 then
					local x,y = obj:getPosition()	
					self:placeDetailedArtifact(x,y, obj.resource_name, obj.resource_descr)
					obj:destroy()
				end
			end
		end
		if artsplosion.distance > 1000 then
			artsplosion.finished = true
		end
	end
	table.filter(self.artsplosions, function(o)
		return not o.finished
	end)
end
