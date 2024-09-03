--[[ Places the first swarm of enemies and controls their behaviour.
Depends on: terrain & everything placed in the sector;
Creates two trigger-functions that have to be called from the outside.
--]]
wh_locusts = {}

require("utils.lua")

function wh_locusts:init()
	local center_x, center_y = 100000,0

	local swarm_rings = 7
	local swarm_slots = 166
	self.swarm_gather_threshold = swarm_slots/swarm_rings
	self.swarm_gather = "idle"

	self.hex_ring_positions = {
		{angle = 0,		dist = 1},					--1
		{angle = 120,	dist = 1},					--2
		{angle = 240,	dist = 1},					--3
		{angle = 60,	dist = 1},					--4
		{angle = 180,	dist = 1},					--5
		{angle = 300,	dist = 1},					--6
		{angle = 0,		dist = 2},					--7
		{angle = 120,	dist = 2},					--8
		{angle = 240,	dist = 2},					--9
		{angle = 60,	dist = 2},					--10
		{angle = 180,	dist = 2},					--11
		{angle = 300,	dist = 2},					--12
		{angle = 30,	dist = 1.7320508075689},	--13
		{angle = 150,	dist = 1.7320508075689},	--14
		{angle = 270,	dist = 1.7320508075689},	--15
		{angle = 90,	dist = 1.7320508075689},	--16
		{angle = 210,	dist = 1.7320508075689},	--17
		{angle = 330,	dist = 1.7320508075689},	--18
		{angle = 0,		dist = 3},					--19
		{angle = 120,	dist = 3},					--20
		{angle = 240,	dist = 3},					--21
		{angle = 60,	dist = 3},					--22
		{angle = 180,	dist = 3},					--23
		{angle = 300,	dist = 3},					--24
		{angle = 20,	dist = 2.645751310646},		--25
		{angle = 140,	dist = 2.645751310646},		--26
		{angle = 260,	dist = 2.645751310646},		--27
		{angle = 80,	dist = 2.645751310646},		--28
		{angle = 200,	dist = 2.645751310646},		--29
		{angle = 320,	dist = 2.645751310646},		--30
		{angle = 40,	dist = 2.645751310646},		--31
		{angle = 160,	dist = 2.645751310646},		--32
		{angle = 280,	dist = 2.645751310646},		--33
		{angle = 100,	dist = 2.645751310646},		--34
		{angle = 220,	dist = 2.645751310646},		--35
		{angle = 340,	dist = 2.645751310646},		--36
		{angle = 0,		dist = 4},					--37
		{angle = 120,	dist = 4},					--37
		{angle = 240,	dist = 4},					--37
		{angle = 60,	dist = 4},					--38
		{angle = 180,	dist = 4},					--39
		{angle = 300,	dist = 4},					--40
		{angle = 30,	dist = 3.4641016151378},	--41
		{angle = 150,	dist = 3.4641016151378},	--42
		{angle = 270,	dist = 3.4641016151378},	--43
		{angle = 90,	dist = 3.4641016151378},	--44
		{angle = 210,	dist = 3.4641016151378},	--45
		{angle = 330,	dist = 3.4641016151378},	--46
		{angle = 15,	dist = 3.605551275464},		--47
		{angle = 135,	dist = 3.605551275464},		--48
		{angle = 255,	dist = 3.605551275464},		--49
		{angle = 75,	dist = 3.605551275464},		--50
		{angle = 195,	dist = 3.605551275464},		--51
		{angle = 315,	dist = 3.605551275464},		--52
		{angle = 45,	dist = 3.605551275464},		--53
		{angle = 165,	dist = 3.605551275464},		--54
		{angle = 285,	dist = 3.605551275464},		--55
		{angle = 105,	dist = 3.605551275464},		--56
		{angle = 225,	dist = 3.605551275464},		--57
		{angle = 345,	dist = 3.605551275464},		--58
		{angle = 0,		dist = 5},					--59
		{angle = 120,	dist = 5},					--60
		{angle = 240,	dist = 5},					--61
		{angle = 60,	dist = 5},					--62
		{angle = 180,	dist = 5},					--63
		{angle = 300,	dist = 5},					--64
		{angle = 12,	dist = 4.5825756949558},	--65
		{angle = 132,	dist = 4.5825756949558},	--66
		{angle = 252,	dist = 4.5825756949558},	--67
		{angle = 72,	dist = 4.5825756949558},	--68
		{angle = 192,	dist = 4.5825756949558},	--69
		{angle = 312,	dist = 4.5825756949558},	--70
		{angle = 48,	dist = 4.5825756949558},	--71
		{angle = 168,	dist = 4.5825756949558},	--72
		{angle = 288,	dist = 4.5825756949558},	--73
		{angle = 108,	dist = 4.5825756949558},	--74
		{angle = 228,	dist = 4.5825756949558},	--75
		{angle = 348,	dist = 4.5825756949558},	--76
		{angle = 24,	dist = 4.3588989435407},	--77
		{angle = 144,	dist = 4.3588989435407},	--78
		{angle = 264,	dist = 4.3588989435407},	--79
		{angle = 84,	dist = 4.3588989435407},	--80
		{angle = 204,	dist = 4.3588989435407},	--81
		{angle = 324,	dist = 4.3588989435407},	--82
		{angle = 36,	dist = 4.3588989435407},	--83
		{angle = 156,	dist = 4.3588989435407},	--84
		{angle = 276,	dist = 4.3588989435407},	--85
		{angle = 96,	dist = 4.3588989435407},	--86
		{angle = 216,	dist = 4.3588989435407},	--87
		{angle = 336,	dist = 4.3588989435407},	--88
		{angle = 0,		dist = 6},					--89
		{angle = 120,	dist = 6},					--90
		{angle = 240,	dist = 6},					--91
		{angle = 60,	dist = 6},					--92
		{angle = 180,	dist = 6},					--93
		{angle = 300,	dist = 6},					--94
		{angle = 10,	dist = 5.56776436283},		--95
		{angle = 130,	dist = 5.56776436283},		--96
		{angle = 250,	dist = 5.56776436283},		--97
		{angle = 70,	dist = 5.56776436283},		--98
		{angle = 190,	dist = 5.56776436283},		--99
		{angle = 310,	dist = 5.56776436283},		--100
		{angle = 50,	dist = 5.56776436283},		--101
		{angle = 170,	dist = 5.56776436283},		--102
		{angle = 290,	dist = 5.56776436283},		--103
		{angle = 110,	dist = 5.56776436283},		--104
		{angle = 230,	dist = 5.56776436283},		--105
		{angle = 350,	dist = 5.56776436283},		--106
		{angle = 20,	dist = 5.2915026221292},	--107
		{angle = 140,	dist = 5.2915026221292},	--108
		{angle = 260,	dist = 5.2915026221292},	--109
		{angle = 80,	dist = 5.2915026221292},	--110
		{angle = 200,	dist = 5.2915026221292},	--111
		{angle = 320,	dist = 5.2915026221292},	--112
		{angle = 40,	dist = 5.2915026221292},	--113
		{angle = 160,	dist = 5.2915026221292},	--114
		{angle = 280,	dist = 5.2915026221292},	--115
		{angle = 100,	dist = 5.2915026221292},	--116
		{angle = 220,	dist = 5.2915026221292},	--117
		{angle = 340,	dist = 5.2915026221292},	--118
		{angle = 30,	dist = 5.1961524227066},	--119
		{angle = 150,	dist = 5.1961524227066},	--120
		{angle = 270,	dist = 5.1961524227066},	--121
		{angle = 90,	dist = 5.1961524227066},	--122
		{angle = 210,	dist = 5.1961524227066},	--123
		{angle = 330,	dist = 5.1961524227066},	--124
		{angle = 0,			dist = 7},				--125
		{angle = 120,		dist = 7},				--126
		{angle = 240,		dist = 7},				--127
		{angle = 60,		dist = 7},				--128
		{angle = 180,		dist = 7},				--129
		{angle = 300,		dist = 7},				--130
		{angle = 60/7,		dist = 6.557438524302},	--131
		{angle = 60/7+120,	dist = 6.557438524302},	--132
		{angle = 60/7+240,	dist = 6.557438524302},	--133
		{angle = 60/7+60,	dist = 6.557438524302},	--134
		{angle = 60/7+180,	dist = 6.557438524302},	--135
		{angle = 60/7+300,	dist = 6.557438524302},	--136
		{angle = 60/7*6,	dist = 6.557438524302},	--137
		{angle = 60/7*6+120,dist = 6.557438524302},	--138
		{angle = 60/7*6+240,dist = 6.557438524302},	--139
		{angle = 60/7*6+60,	dist = 6.557438524302},	--140
		{angle = 60/7*6+180,dist = 6.557438524302},	--141
		{angle = 60/7*6+300,dist = 6.557438524302},	--142
		{angle = 60/7*2,	dist = 6.2449979983984},--143
		{angle = 60/7*2+120,dist = 6.2449979983984},--144
		{angle = 60/7*2+240,dist = 6.2449979983984},--145
		{angle = 60/7*2+60,	dist = 6.2449979983984},--146
		{angle = 60/7*2+180,dist = 6.2449979983984},--147
		{angle = 60/7*2+300,dist = 6.2449979983984},--148
		{angle = 60/7*5,	dist = 6.2449979983984},--149
		{angle = 60/7*5+120,dist = 6.2449979983984},--150
		{angle = 60/7*5+240,dist = 6.2449979983984},--151
		{angle = 60/7*5+60,	dist = 6.2449979983984},--152
		{angle = 60/7*5+180,dist = 6.2449979983984},--153
		{angle = 60/7*5+300,dist = 6.2449979983984},--154
		{angle = 60/7*3,	dist = 6.0827625302982},--155
		{angle = 60/7*3+120,dist = 6.0827625302982},--156
		{angle = 60/7*3+240,dist = 6.0827625302982},--157
		{angle = 60/7*3+60,	dist = 6.0827625302982},--158
		{angle = 60/7*3+180,dist = 6.0827625302982},--159
		{angle = 60/7*3+300,dist = 6.0827625302982},--160
		{angle = 60/7*4,	dist = 6.0827625302982},--161
		{angle = 60/7*4+120,dist = 6.0827625302982},--162
		{angle = 60/7*4+240,dist = 6.0827625302982},--163
		{angle = 60/7*4+60,	dist = 6.0827625302982},--164
		{angle = 60/7*4+180,dist = 6.0827625302982},--165
		{angle = 60/7*4+300,dist = 6.0827625302982},--166
	}

	self.swarm_ships = {}
	repeat
		local ox, oy = vectorFromAngle(random(0,360),random(6000,100000))
		ox = ox + center_x
		oy = oy + center_y
		local obj_list = getObjectsInRadius(ox, oy, 1500)
		if #obj_list == 0 then
			local ship = CpuShip():setTemplate("Ktlitan Drone"):setFaction("Ktlitans"):setPosition(ox,oy)
			ship:setAI("fighter")
			ship:setTypeName("Locust")
			ship:setImpulseMaxSpeed(300)
			ship:setRotationMaxSpeed(30)
			ship:setScanningParameters(1,1)
			ship:orderStandGround()
			ship.fight = false 
			ship:onTakingDamage(function(self, instigator) 
				--						Arc Dir	Range	Cycle time			Damage
				self:setBeamWeapon(0,	40,	0,	600,	4 + random(-1,1),	6 + random(-1,1))
				self:setRotationMaxSpeed(15 + random(-2,2))
				self.fight = true
			end)
			table.insert(self.swarm_ships,ship)
		end
	until(#self.swarm_ships > swarm_slots)

	addGMFunction("locusts swarm", self.trigger_gather_swarm)
	addGMFunction("locusts modify", self.trigger_modify_behaviour)
	getScriptStorage().wh_terrain = self
end

-- trigger in turn 2
function wh_locusts.trigger_gather_swarm()
	wh_locusts.swarm_gather = "ready"
	removeGMFunction("locusts swarm")
	wh_artifacts:addGenericInfo("locust movement analysis", "All the Ktlitans on our sensors have started moving. They seem to be converging on a central location.")
end

-- trigger in turn 3
function wh_locusts.trigger_modify_behaviour()
	for i,ship in ipairs(wh_locusts.swarm_ships) do
		if ship:isValid() then
			ship:setAI("default")
		end
	end
	removeGMFunction("locusts modify")
end

-- sets the center, where the locusts should meet
function wh_locusts:setCenter()
	local total_x = 0
	local total_y = 0
	local ship_count = 0
	for i,ship in ipairs(self.swarm_ships) do
		if ship:isValid() then
			local x, y = ship:getPosition()
			total_x = total_x + x
			total_y = total_y + y
			ship_count = ship_count + 1
		end
	end
	self.gather_x = total_x/ship_count
	self.gather_y = total_y/ship_count
	-- avoid black hole
	local bh = wh_terrain.blackhole
	if distance(self.gather_x, self.gather_y, bh) < 10000 then
		local angle = angleRotation(bh, self.gather_x, self.gather_y)
		local gx, gy = vectorFromAngle(angle, 10000)
		self.gather_x = self.gather_x + gx
		self.gather_y = self.gather_y + gy
	end
end

-- cures the locust nearest to the center to the leader
-- orders all locusts to follow the leader
function wh_locusts:createFormation()
	local closest_ship = nil
	local closest_ship_dist = 500000
	for i,ship in ipairs(self.swarm_ships) do
		if ship:isValid() then
			local current_dist = distance(ship,self.gather_x,self.gather_y)
			if current_dist < closest_ship_dist then
				closest_ship_dist = current_dist
				closest_ship = ship
			end
		end
	end
	self.lead_ship = closest_ship
	if self.lead_ship ~= nil and self.lead_ship:isValid() then
		self.lead_ship:orderRoaming():setImpulseMaxSpeed(110):setRotationMaxSpeed(20)
		local flight_angle = self.lead_ship:getHeading()
		local spawn_distance = 1000
		local j = 0
		for i,ship in ipairs(self.swarm_ships) do
			if ship ~= self.lead_ship then
				j = j + 1
				local form = self.hex_ring_positions[j]
				local form_prime_x, form_prime_y = vectorFromAngle(form.angle, form.dist * spawn_distance)
				ship:orderFlyFormation(self.lead_ship,form_prime_x,form_prime_y)
			end
		end
	end
end

function wh_locusts:updateSwarm()
	if #self.swarm_ships > 0 then
		for i,ship in ipairs(self.swarm_ships) do
			if ship ~= nil and ship:isValid() then
				if ship:areEnemiesInRange(3000) then
					if ship.fight == false then
						ship:orderRoaming()	-- calling this every tick results in strange behaviour.
						-- after taking damage they fall back to fighterAI
					end
				else
					ship.fight = false
				end
			else
				self.swarm_ships[i] = self.swarm_ships[#self.swarm_ships]
				self.swarm_ships[#self.swarm_ships] = nil
				break
			end
		end
	else
		-- locust plot is over
		self.swarm_gather = "over"
		return
	end
	if self.swarm_gather == "ready" then
		self:setCenter()
		for i,ship in ipairs(self.swarm_ships) do
			if ship:isValid() then
				ship:orderFlyTowards(self.gather_x,self.gather_y)
			end
		end
		self.swarm_gather = "started"
	elseif self.swarm_gather == "started" then
		local swarmed_count = 0
		for i,ship in ipairs(self.swarm_ships) do
			if distance(ship,self.gather_x,self.gather_y) < 10000 then
				swarmed_count = swarmed_count + 1
			end
		end
		if swarmed_count > self.swarm_gather_threshold then
			self:createFormation()
			self.swarm_gather = "gathered"
		end
	elseif self.swarm_gather == "gathered" then
		if self.lead_ship == nil or not self.lead_ship:isValid() then
			self:setCenter()
			self:createFormation()
		end
	end
end

function wh_locusts:update(delta)
	if self.swarm_gather ~= "over" then
		self:updateSwarm()
	end
end
