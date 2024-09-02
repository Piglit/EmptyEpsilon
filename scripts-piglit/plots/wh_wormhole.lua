--[[ Creates two wormholes that are connected to each other
-- Positions are fixed
-- Depends on: rota
--]]
wh_wormhole = {}

require "utils.lua"
require "ee.lua"
require "luax.lua"

function wh_wormhole:init()
   	self.a_center = {-280000, 0}
   	self.b_center = {100000, 0}

	self.onTeleportFunctions = {}
	table.insert(self.onTeleportFunctions, self.wormholeTax)

	-- speed means degree per second
	local distance = 30000
	local speed = 90/1800	-- 90 degree in 30 minutes

	self.wormhole_a = WormHole():setPosition(self.a_center[1], self.a_center[2]+distance)
	self.wormhole_a:setTargetPosition(self.b_center[1], self.b_center[2]-distance-5000)
	wh_rota:add_object(self.wormhole_a, speed, self.a_center[1], self.a_center[2])
	self.wormhole_a:onTeleportation(self.onTeleport)

	self.wormhole_b = WormHole():setPosition(self.b_center[1], self.b_center[2]+distance)
	self.wormhole_b:setTargetPosition(self.a_center[1], self.a_center[2]+distance-5000)
	wh_rota:add_object(self.wormhole_b, -speed, self.b_center[1], self.b_center[2])	-- b rotates counter-clockwise
	self.wormhole_b:onTeleportation(self.onTeleport)

	-- asteroids around the entries
	self.asteroids_a = placeRandomAroundPoint(Asteroid,20,300,5000,self.a_center[1],self.a_center[2]+distance)
	self.asteroids_b = placeRandomAroundPoint(Asteroid,20,300,5000,self.b_center[1],self.b_center[2]+distance)
	for _,obj in ipairs(self.asteroids_a) do
		wh_rota:add_object(obj, random(0.2,0.8), self.wormhole_a)
	end
	for _,obj in ipairs(self.asteroids_b) do
		wh_rota:add_object(obj, random(0.2,0.8), self.wormhole_b)
	end

	local storage = getScriptStorage()
	storage.wh_wormhole = self
end

function wh_wormhole:update(delta)
	-- set targets
	-- a teleports outwards
	-- b teleports inwards
	local ax, ay = vectorFromAngle(self.wormhole_b.angle, 35000)
	local bx, by = vectorFromAngle(self.wormhole_a.angle, 25000)
	self.wormhole_a:setTargetPosition(self.b_center[1]+ax, self.b_center[2]+ay)
	self.wormhole_b:setTargetPosition(self.a_center[1]+bx, self.a_center[2]+by)
end

function wh_wormhole:addOnTeleport(fun)
	table.insert(self.onTeleportFunctions, fun)
end

function wh_wormhole.onTeleport(wormhole, teleportee)
	for _,fun in ipairs(wh_wormhole.onTeleportFunctions) do
		fun(wormhole, teleportee)
	end
end

function wh_wormhole.wormholeTax(wormhole, teleportee)
	if teleportee.typeName == "CpuShip" or teleportee.typeName == "PlayerSpaceship" then
		local systems_avail = {}
		for _,sys in ipairs(SYSTEMS) do
			if teleportee:hasSystem(sys) and teleportee:getSystemHealth(sys) > 0 then
				table.insert(systems_avail, sys)
			end
		end
		table.shuffle(systems_avail)
		local damage = 0.64
		for _,sys in ipairs(systems_avail) do
			teleportee:setSystemHeat(sys, teleportee:getSystemHeat(sys)+damage)
			damage = damage/2
			teleportee:setSystemHealth(sys, teleportee:getSystemHealth(sys)-damage)
		end
		if teleportee.typeName == "PlayerSpaceship" then
			teleportee:setEnergy(teleportee:getEnergy()*0.75)
		end
		if teleportee.typeName == "CpuShip" then
			teleportee:orderRoaming()	-- abort current order 
		end
		teleportee.skip_next_health_check = true
	end
end
