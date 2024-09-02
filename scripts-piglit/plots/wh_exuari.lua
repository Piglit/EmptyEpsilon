--[[ Exuari Ambushes
As long as fleet command is not through the wormhole, exuari ambush travellers.
After that, exuari come through the hole.
After: wormhole
--]]

require "luax.lua"
require "utils.lua"

wh_exuari = {}

function wh_exuari:init()
	self.ships = {}
	self.testeroids = {}	-- only for testing

	self.state = "ambush"
	self.shipClasses = {
		["fighter"] = {
			"Dagger",
			"Blade",
			"Gunner",
			"Shooter",
			"Jagger",
		},
		["striker"] = {
			"Racer",
			"Hunter",
			"Strike",
			"Dash",
		},
		["frigate"] = {
			"Guard",
			"Sentinel",
			"Warden",
		},
		["artillery"] = {
			"Flash",
			"Ranger",
			"Buster",
		},
		["carrier"] = {
			"Ryder",
			"Zeppelin",
			"Craver",
			"Ridge",
		},
	}

	wh_wormhole:addOnTeleport(self.onTeleport)

	getScriptStorage().wh_exuari = self
end

function wh_exuari:initTest()
	PlayerSpaceship():setTemplate("Adder MK7"):setCallSign("Wormhole jumper"):setPosition(-10000,15000):setRotation(-90):commandTargetRotation(-90):setResourceAmount("Artifacts", 4)
	wh_wormhole.wormhole_b:setPosition(-10000, 10000)
	wh_rota.objects = {}

	wh_artifacts:placeDetailedArtifact(-280000,-10000, "CaptureTest", "Has been captured")
	local ship = CpuShip():setTemplate("Strike"):setPosition(-280000,-20000)
	ship.artifacts = {}
	table.insert(self.ships, ship)
end

function wh_exuari.onTeleport(wormhole, teleportee)
	if wh_exuari.state == "ambush" and wormhole == wh_wormhole.wormhole_b and teleportee.typeName == "PlayerSpaceship" then
		local value = teleportee:getResourceAmount("Artifacts")
		print(string.format("Exuari behold wormhole use with %d artifacts.", value))
		if value > 1 then
			wh_exuari:spawnAmbush(teleportee, value)
		end
	end
end

function wh_exuari:findAmbushPositions()
	-- find all positions that can be used for ambushes
	-- get all players in the area
	local players = getActivePlayerShips()
	table.filter(players, function(o)
		local x,y = o:getPosition()
		return x < 0 and o:isValid() 
	end)

	-- pairwise calculate intersection points
	local intersections = {}
	for _,p1 in ipairs(players) do
		for _,p2 in ipairs(players) do
			if p1 ~= p2 then
				p1x, p1y = p1:getPosition()
				p2x, p2y = p2:getPosition()
				p1r = p1:getLongRangeRadarRange() + 100
				p2r = p2:getLongRangeRadarRange() + 100
				local new_ints = getCircleCircleIntersection(p1x, p1y, p1r, p2x, p2y, p2r)
				table.extend(intersections, new_ints)
			end
		end
	end

	-- filter points that are inside radar ranges
	table.filter(intersections, function(o)
		local x,y = o[1], o[2]
		for _,p in ipairs(players) do
			if distance(p, x,y) < p:getLongRangeRadarRange() then
				return false
			end
		end
		return true
	end)
	if #intersections == 0 then
		--print("ERROR: no ambush position found" .. tostring(getScenarioTime()))
	end
	return intersections
end

function wh_exuari:findAmbushPosition(target)
	local intersections = self:findAmbushPositions()
	if #intersections == 0 then
		print("ERROR: no ambush position found")
		return nil
	end
	-- calculates position outside of all near radar ranges, but next to target's position
	-- get nearest ones
	local nearestDist = 99999999
	for _,int in ipairs(intersections) do
		local x,y = table.unpack(int)
		nearestDist = math.min(nearestDist, distance(target, x,y))
	end
	table.filter(intersections, function(o)
		local x,y = table.unpack(o)
		return distance(target, x,y) - nearestDist < 1000 
	end)

	-- choose one
	local pos = tableSelectRandom(intersections)
	if pos ~= nil then
		return table.unpack(pos)
	else
		table.dump(intersections)
		return nil
	end
end

function wh_exuari:spawnAmbush(target, strength)
	local x,y = self:findAmbushPosition(target)
	if x == nil then
		print("ERROR: no near ambush position found")
		return
	end
	local ambushFleet = {
		fighter = {},
		striker = {},
		frigate = {},
		artillery = {},
--		carrier = {},
	}
	for i=1,strength do
		table.insert(ambushFleet.fighter, tableSelectRandom(self.shipClasses.fighter))
		if i % 2 == 0 then
			table.insert(ambushFleet.striker, tableSelectRandom(self.shipClasses.striker))
		end
		if i % 3 == 0 then
			table.insert(ambushFleet.artillery, tableSelectRandom(self.shipClasses.artillery))
		end
		if i % 4 == 0 then
			table.insert(ambushFleet.frigate, tableSelectRandom(self.shipClasses.frigate))
		end
	end

	-- spawn them!
	for k,ships in pairs(ambushFleet) do
		local leader, second = nil, nil
		for idx,template in ipairs(ships) do
			local ship = CpuShip():setTemplate(template):setPosition(x,y)
			ship.artifacts = {}
			table.insert(self.ships, ship)
			leader, second = script_formation.buildFormationIncremental(ship, idx, leader, second)
		end
		if leader ~= nil then
			leader:orderAttack(target)
		end
	end
end

function wh_exuari.onDestruction(ship, instigator)
	if ship.artifacts == nil or #ship.artifacts == 0 then
		return
	end
	local details = {}
	for _,art in ipairs(ship.artifacts) do
		table.insert(details, art)
	end
	local x,y = ship:getPosition()
	wh_artifacts:artsplosion(x,y,#details,details)
end

function wh_exuari:updateTest(delta)
	local intersections = self:findAmbushPositions()
	for _,ast in ipairs(self.testeroids) do
		ast:destroy()
	end
	self.testeroids = {}
	for _,int in ipairs(intersections) do
		local x,y = table.unpack(int)
		table.insert(self.testeroids, Artifact():setPosition(x,y))
	end
end

function wh_exuari:update(delta)
	-- pull artifacts
	table.filter(self.ships, function(obj)
		return obj:isValid()
	end)
	for _,ship in ipairs(self.ships) do
		local objs = ship:getObjectsInRange(5000)
		local x_ship,y_ship = ship:getPosition()
		table.filter(objs, function(obj)
			return (obj.typeName == "Artifact")
		end)
		for _,obj in ipairs(objs) do
			if obj.resource_name ~= nil and obj.resource_descr ~= nil then
				-- only steal plot relevant artifacts
				local angle = angleRotation(ship, obj)
				local dist = distance(ship, obj)
   				dist = dist - (1000*500/dist) * delta
				dist = math.max(dist, 0)
				setCirclePos(obj, x_ship, y_ship, angle, dist)
				if dist < 100 then
					table.insert(ship.artifacts, {obj.resource_name, obj.resource_descr})
					obj:destroy()
					local x_1,y_1 = vectorFromAngle(random(0,360), 100000)
					if x_1 > 0 then
						x_1 = -x_1	-- not towards playable area
					end
					ship:orderFlyTowardsBlind(x_ship+x_1,y_ship+y_1)
					ship:onDestruction(wh_exuari.onDestruction)
				end
			end
		end
	end
end
