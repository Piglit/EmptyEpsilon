avp_enemies = {
	modules = {},
	factions = {
		"Kraylor",
		"Exuari",
		"Ktlitans",
		"Ghosts",
		"Criminals",
	},
}

local EnemyModule = {}

--[[ assume the existence of the following lists:
* stl[faction][template] = value
* stln[faction] = {templates}
* stnl = {templates}
* stsl = {values}
* ship_template_strength[template] = value
--]]

function avp_enemies:init()
	self.faction_index = #self.factions +1
end

function avp_enemies:update(dt)
	EnemyModuleKtlitans:updateDrones(dt)
end

function avp_enemies:spawn(positions, faction, strength)
	if faction == nil then
		if self.faction_index > #self.factions then
			arrayShuffle(self.factions)
			self.faction_index = 1
		end
		faction = self.factions[self.faction_index]
		self.faction_index = self.faction_index +1
	end

	local fleet
	if avp_enemies.modules[faction] ~= nil then
		fleet = avp_enemies.modules[faction]:spawnEnemiesAtPositions(positions, strength)
	else
		fleet = EnemyModule:spawnEnemiesAtPositions(positions, strength)
	end
	return fleet, faction
end

function EnemyModule:new(obj)
	obj = obj or {} -- create empty if none given 
	setmetatable(obj, self)
	self.__index = self
	if obj.faction ~= nil and avp_enemies.modules[obj.faction] == nil then
		avp_enemies.modules[obj.faction] = obj
	else
		table.insert(avp_enemies.modules, obj)
	end
	return obj
end

-- may place one or several ships at each given position
-- cycle through positions until the total strength of enemies is greater than the given strength
-- entry point for custom modules
function EnemyModule:spawnEnemiesAtPositions(positions, strength)
	print("Called spawn, but is disabled")
	return nil
--	local idx = 0
--	local ships = {}
--	while strength > 0 do
--		idx = (idx % #positions) + 1
--		local pos = positions[idx]
--		local ship = self:spawnShipAtPosition("Drone", pos)
--		table.insert(ships, ship)
--		strength = strength - 5
--	end
--	return ships
end

function EnemyModule:spawnShipAtPosition(template, pos)
	assert(template ~= nil, "template is nil")
	local ship = CpuShip():setTemplate(template):setPosition(pos[1],pos[2])
	if self.faction ~= nil then
		ship:setFaction(self.faction):setScannedByFaction(self.faction, true)
	end
	local used_strength = ship_template_strength[template]
	assert(used_strength ~= nil, "template "..template.." not in template list")
	return ship, used_strength
end

function EnemyModule:getClassTemplate(class)
	-- returns a template of a specific ship class.
	-- ship classes must be defined when creating a new subclass of EnemyModule
	assert (self.classes ~= nil)
	assert (self.classes[class] ~= nil, class)
	local class_templates = self.classes[class]
	local class_index = self.classes[class.."_index"] or 0
	class_index = class_index +1
	if class_index > #class_templates then
		class_templates = arrayShuffle(self.classes[class])
		class_index = 1
	end
	self.classes[class.."_index"] = class_index
	return class_templates[class_index]
end

function EnemyModule:spawnFormation(pos, strength, templates)
	local rotation = random(1,360)
	local x,y = pos[1], pos[2]
	local formationLeader, formationSecond
	local total_used_strength = 0
	local first_leader
	for index, template in ipairs(templates) do
		local ship, used_strength = self:spawnShipAtPosition(template, {x,y})
		if first_leader == nil then
			first_leader = ship
		end
		ship:setRotation(rotation)
		formationLeader, formationSecond = script_formation.buildFormationIncremental(ship, index, formationLeader, formationSecond)
		total_used_strength = total_used_strength + used_strength

		-- for the next ship
		if total_used_strength >= strength then
			break
		end
		rotation = rotation - 360/#templates
		x,y = radialPosition(pos[1], pos[2], 400, rotation)
	end
	return total_used_strength, first_leader 
end

function EnemyModule:addBossHangar(carrier, hangar_classes)
	-- add 3, 5, 7, 9, ... ships of each class to the hangar.
	for idx,grp in ipairs(hangar_classes) do
		for i = idx, idx*2+1 do
			local template = self:getClassTemplate(grp)
			if i == idx then
				if idx == 1 and carrier.typeName == "CpuShip" then
					script_hangar:create(carrier, template, 1, nil, true)	-- mothership leads the first class
					script_hangar:config(carrier, "formation_offset_x", 500)
					script_hangar:config(carrier, "formation_offset_y", -1000)
				else
					script_hangar:create(carrier, template, 1)	-- one bay per class
				end
			else
				script_hangar:append(carrier, template, 1)
			end
		end
		script_hangar:config(carrier, "cooldownMax", 60/idx)
		script_hangar:config(carrier, "triggerRange", 50000 - 10000*idx)
		script_hangar:config(carrier, "arc", 90+90*idx)
	end	
	return carrier
end

--[[ Kraylor --]]

EnemyModuleKraylor = EnemyModule:new{
	faction="Kraylor",
	classes={
		breakers = arrayShuffle({
			"Rockbreaker",
			"Rockbreaker Merchant",
			"Rockbreaker Murderer",
			"Rockbreaker Mercenary",
			"Rockbreaker Marauder",
			"Rockbreaker Military",
		}),
		bringers = arrayShuffle({
			"Deathbringer",
			"Painbringer",
			"Doombringer"
		}),
	}
}

function EnemyModuleKraylor:spawnEnemiesAtPositions(positions, strength)
	--[[ split fleet into three parts:
		* Marauders - single ships, roaming. 1 ship ~ 27 strength, 1/3 strength
		* Flotillas - small groups, patrolling the bases. 1 dread, 2 ships ~ 50 - 100 strength, 1/3 strength 
		* Bases - stationary, spawning marauders. 1 base, 3 ships ~ 100 strength, 1/3 strength
	--]]
	local position_index = 1
	local last_strength = 0
	local base_strength, flotilla_strength, marauder_strength = strength/3, strength/3, strength/3
	local ship
	local fleet = {}
	while base_strength >= 100 do
		last_strength, ship = self:spawnBase(positions[position_index], base_strength)
		base_strength = base_strength - last_strength
		table.insert(fleet, ship)
		position_index = position_index % #positions + 1
	end
	flotilla_strength = flotilla_strength + base_strength
	while flotilla_strength >= 50 do
		if irandom(1,3) == 1 then
			-- 33%: 4 Rockbreakers, 66%: 1 *bringer, 2 Rockbreakers
			last_strength, ship = self:spawnBreakerFlotilla(positions[position_index], flotilla_strength)
		else
			last_strength, ship = self:spawnBringerFlotilla(positions[position_index], flotilla_strength)
		end
		flotilla_strength = flotilla_strength - last_strength
		table.insert(fleet, ship)
		position_index = position_index % #positions + 1
	end
	marauder_strength = marauder_strength + flotilla_strength
	while marauder_strength > 0 do
		last_strength, ship = self:spawnMarauder(positions[position_index], marauder_strength)
		marauder_strength = marauder_strength - last_strength
		table.insert(fleet, ship)
		position_index = position_index % #positions + 1
	end
	return fleet
end

function EnemyModuleKraylor:addDrones(ship, min, max, strength)
	max = math.min(max, math.floor(strength / 5))
	local drones_amount	= max
	if min < max then
		drones_amount = irandom(min,max)
	end
	if drones_amount > 0 then
		script_hangar:create(ship, "Drone", drones_amount)
		return 5 * drones_amount
	end
	return 0
end

function EnemyModuleKraylor:spawnMarauder(pos, strength)
	-- spawn one Marauder. 50% Spinebreaker, 50% Rockbreaker
	-- if enough strength is given, it may launch a drone on contact (50% chance)
	local template = "Spinebreaker"
	if strength < 24 then
		template = "Rockbreaker"
	elseif irandom(1,2) == 1 then
		-- 50% Spinebreaker, 50% Rockbreaker
		template = self:getClassTemplate("breakers")
	end
	local ship, used_strength = self:spawnShipAtPosition(template, pos)
	ship:orderRoaming()
	-- 50% add drone in hangar
	used_strength = used_strength + self:addDrones(ship, 0, 1, strength - used_strength)
	return used_strength, ship
end

function EnemyModuleKraylor:spawnBreakerFlotilla(pos, strength)
	-- spawns a small group of ships, flying in formation
	local templates = {
		self:getClassTemplate("breakers"),
		self:getClassTemplate("breakers"),
		self:getClassTemplate("breakers"),
		self:getClassTemplate("breakers"),
	}
	local total_used_strength, leader = self:spawnFormation(pos, strength, templates)
	leader:orderDefendLocation(pos[1], pos[2])
	leader:setImpulseMaxSpeed(0.9 * leader:getImpulseMaxSpeed())
	return total_used_strength, leader
end

function EnemyModuleKraylor:spawnBringerFlotilla(pos, strength)
	-- spawns a small group of ships, flying in formation
	-- lead by a stronger leader
	local templates = {
		self:getClassTemplate("bringers"),
		self:getClassTemplate("breakers"),
		self:getClassTemplate("breakers"),
	}
	local total_used_strength, leader = self:spawnFormation(pos, strength, templates)
	leader:orderDefendLocation(pos[1], pos[2])
	total_used_strength = total_used_strength + self:addDrones(leader, 1, 2, strength - total_used_strength)
	return total_used_strength, leader
end

function EnemyModuleKraylor:spawnBase(pos, strength)
	local templates = {
		"Battlestation",
		self:getClassTemplate("breakers"),
		self:getClassTemplate("breakers"),
	}
	local total_used_strength, station = self:spawnFormation(pos, strength, templates)
	station:orderStandGround()
	total_used_strength = total_used_strength + self:addDrones(station, 2, 4, strength - total_used_strength)
	return total_used_strength, station
end

function EnemyModuleKraylor:spawnBossBases()
	local bases = {}
	for i=1, 4 do
		local base = CpuShip():setTemplate("Battlestation"):orderStandGround():setFaction("Kraylor")
		self:addBossHangar(base, {"bringers", "breakers"})
		table.insert(bases, base)
	end
	return bases
end

function EnemyModuleKraylor:spawnBossMothership()
	local carrier = CpuShip():setTemplate("Goddess of Destruction"):orderStandGround():setFaction("Kraylor")
	self:addBossHangar(carrier, {"bringers", "breakers"})
	return carrier
end

--[[ Ktlitans --]]

EnemyModuleKtlitans = EnemyModule:new{
	faction="Ktlitans",
	classes={
		drones = {
			"Ktlitan Drone",
			"Lite Drone",
			"Heavy Drone",
			"Gnat",
		},
		workers = {
			"Ktlitan Worker",
			"Cleaner",
			"Undertaker",
			"Nurse",
			"Builder",
		},
		fighters = {
			"Ktlitan Fighter",
			"K2 Fighter",
			"K3 Fighter",
			"Ktlitan Scout",
			"Ktlitan Breaker",
			"K2 Breaker",
			"Ktlitan Feeder",
			"Ktlitan Destroyer",
		},
		queens = {
			"Ktlitan Queen",
			"Diva",	--mobile
			"Tsarina",
		}
	},
	swarm_ships = {},
}

function EnemyModuleKtlitans:spawnEnemiesAtPositions(positions, strength)
	local hive_strength, expedition_strength = strength/2, strength/3
	strength = strength - hive_strength - expedition_strength
	local last_strength, ship
	local position_index = 1
	local fleet = {}
	if hive_strength >= 200 then
		last_strength, ship = self:spawnHive(positions[position_index], hive_strength)
		hive_strength = hive_strength - last_strength
		table.insert(fleet, ship)
		position_index = position_index % #positions + 1
	end
	expedition_strength = expedition_strength + hive_strength
	while expedition_strength >= 20 do
		local templates = arrayShuffle({table.unpack(self.classes.fighters)})	-- quick and dirty clone of table with unpack and repack
		table.insert(templates, 1, "Ktlitan Scout")
		local last_strength, ship = self:spawnFormation(positions[position_index], expedition_strength, templates)
		expedition_strength = expedition_strength - last_strength
		table.insert(fleet, ship)
		position_index = position_index % #positions + 1
	end
	strength = strength + expedition_strength
	while strength > 0 do
		local template = self:getClassTemplate("drones")
		ship, last_strength = self:spawnShipAtPosition(template, positions[position_index])
		ship:orderStandGround()
		strength = strength - last_strength
		table.insert(self.swarm_ships, ship)
		table.insert(fleet, ship)
		position_index = position_index % #positions + 1
	end
	return fleet
end

function EnemyModuleKtlitans:spawnHive(pos, strength)
	--[[ Creates a queen surrounded by workers.
		 The queen can spawn as many drones as there are workers in case of an attack
		 The quenn does also spawn drones over time
	--]]
	local queen, total_used_strength = self:spawnShipAtPosition(self:getClassTemplate("queens"), pos)
	queen:orderDefendLocation(pos[1],pos[2])

	while total_used_strength < strength do
		local templates = arrayShuffle(self.classes.workers)
		local used_strength, leader = self:spawnFormation(pos, strength-total_used_strength, templates)
		leader:orderDefendTarget(queen)

		local template = self:getClassTemplate("drones")
		script_hangar:append(queen, template, 1)	-- add one random drone to emergency hangar
		total_used_strength = total_used_strength + used_strength + ship_template_strength[template]
	end

	template = self:getClassTemplate("drones")
	script_hangar:create(queen, template, 100)	-- produce over time in separate hangar
	script_hangar:config(queen, "cooldownMax", 600)	-- 10 Minutes
	script_hangar:config(queen, "triggerRange", 1000000) -- everywhere
	return total_used_strength, queen
end

function EnemyModuleKtlitans:updateDrones(dt)
	if self.swarm_ships ~= nil then
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
	end
end

function EnemyModuleKtlitans:spawnBoss()
	local stationSizeRandom = random(1,100)
	local sizeTemplate
	if stationSizeRandom <= 66 then
		sizeTemplate = "Diva"
	else
		sizeTemplate = "Tsarina"
	end
	local carrier = CpuShip():setTemplate(sizeTemplate):orderStandGround():setFaction("Ktlitans")
	self:addBossHangar(carrier, {"fighters", "workers", "drones"})
	script_hangar:config(carrier, "onLaunch", function(c, s, i)	-- for the drones:
		table.insert(EnemyModuleKtlitans.swarm_ships, s)
	end)

	return carrier
end

--[[ Exuari --]]

EnemyModuleExuari = EnemyModule:new{
	faction="Exuari",
	classes={
		fighters = arrayShuffle({
			"Dagger",
			"Blade",
			"Gunner",
			"Shooter",
			"Jagger",
		}),
		strikers = arrayShuffle({
			"Racer",
			"Hunter",
			"Strike",
			"Dash",
		}),
		frigates = arrayShuffle({
			"Guard",
			"Sentinel",
			"Warden",
		}),
		artillery = arrayShuffle({
			"Flash",
			"Ranger",
			"Buster",
		}),
		carriers = arrayShuffle({
			"Ryder",
			"Zeppelin",
			"Craver",
			"Ridge",
		}),
	}
}

function EnemyModuleExuari:spawnEnemiesAtPositions(positions, strength)
	--[[
		* single carrier, that launches fighters and strikers, surrounded by frigates
		* death teams: artillery, with fighter sqads
	--]]
	local carrier_strength, death_team_strength, striker_strength = strength/2, strength/4, strength/4
	local last_strength, template, carrier, ship
	local fleet_leaders = {}
	local position_index = 1
	if carrier_strength >= 500 then
		template = "Ridge"
	elseif carrier_strength >= 300 then
		template = "Craver"
	elseif carrier_strength >= 200 then
		template = "Zeppelin"
	elseif carrier_strength >= 100 then
		template = "Ryder"
	elseif carrier_strength >= 50 then
		template = self:getClassTemplate("frigates")
	else
		template = nil
	end
	if template then
		local rotation = random(1,360)
		carrier, last_strength = self:spawnShipAtPosition(template, positions[position_index])
		carrier_strength = carrier_strength - last_strength
		carrier:orderStandGround()
		table.insert(fleet_leaders, carrier)
		while carrier_strength > 20 do
			rotation = rotation + 47
			local x,y = radialPosition(positions[position_index][1], positions[position_index][2], 3000, rotation)
			template = self:getClassTemplate("frigates")
			ship, last_strength = self:spawnShipAtPosition(template, {x,y})
			carrier_strength = carrier_strength - last_strength
			ship:setRotation(rotation)
			ship:orderDefendTarget(carrier)
			if carrier_strength > 0 then
				template = self:getClassTemplate("fighters")
				script_hangar:append(carrier, template, 1)
				carrier_strength = carrier_strength - ship_template_strength[template]
			end
		end
		template = self:getClassTemplate("strikers")
		carrier_strength = carrier_strength - ship_template_strength[template]
		script_hangar:create(carrier, template, 1)	-- strikers in separate hangar
		script_hangar:config(carrier, "cooldownMax", 60)	-- 1 Minute
		script_hangar:config(carrier, "triggerRange", 50000) -- huge radius
	end
	while carrier ~= nil and striker_strength > 0 do
		template = self:getClassTemplate("strikers")
		script_hangar:append(carrier, template, 1)
		striker_strength = striker_strength - ship_template_strength[template]
	end
	death_team_strength = death_team_strength + carrier_strength + striker_strength
	while death_team_strength >= 0 do
		position_index = position_index % #positions + 1
		local templates = {
			self:getClassTemplate("artillery"),
			self:getClassTemplate("fighters"),
			self:getClassTemplate("fighters"),
			self:getClassTemplate("fighters"),
		}
		last_strength, ship = self:spawnFormation(positions[position_index], death_team_strength, templates)
		death_team_strength = death_team_strength - last_strength
		table.insert(fleet_leaders, ship)
	end
	return fleet_leaders
end

function EnemyModuleExuari:spawnBoss(pos)
	local stationSizeRandom = random(1,100)
	local sizeTemplate
	if stationSizeRandom <= 66 then
		sizeTemplate = "Craver"
	else
		sizeTemplate = "Ridge"
	end
	local carrier = CpuShip():setTemplate(sizeTemplate):orderStandGround():setFaction("Exuari")
	self:addBossHangar(carrier, {"frigates", "artillery", "strikers", "fighters"})
	return carrier
end

--[[ Ghosts --]]

EnemyModuleGhosts = EnemyModule:new{
	faction="Ghosts",
	classes={
		fighters = arrayShuffle({
			"Advanced Hornet",
			"Advanced Lindworm",
			"Advanced Adder MK5",
			"Advanced Adder MK4",
		}),
		capitals = arrayShuffle({
			"Phobos G4",
			"Piranha G4",
			"Nirvana 0x81",
			"Solar Storm",
		}),
	}
}

function EnemyModuleGhosts:spawnEnemiesAtPositions(positions, strength)
	--[[TODO better strategy?
		always send a captial ship and two fighters
	--]]
	local position_index = 0
	local fleet_leaders = {}
	while strength >= 0 do
		position_index = position_index % #positions + 1
		local templates = {
			self:getClassTemplate("capitals"),
			self:getClassTemplate("fighters"),
			self:getClassTemplate("fighters"),
		}
		local used_strength, leader = self:spawnFormation(positions[position_index], strength, templates)
		strength = strength - used_strength
		table.insert(fleet_leaders, leader)
	end
	return fleet_leaders
end


--[[ Criminals --]]

EnemyModuleCriminals = EnemyModule:new{
	faction="Criminals",
	classes={
		fighters = arrayShuffle({
			"Red Hornet",
			"Red Lindworm",
			"Red Adder MK5",
			"Red Adder MK4",
		}),
		capitals = arrayShuffle({
			"Phobos Firehawk",
			"Piranha F12.M",
			"Nirvana Thunder Child",
			"Lightning Storm",
		}),
	}
}

function EnemyModuleCriminals:spawnEnemiesAtPositions(positions, strength)
	--[[ Small groups of ships, combinations of captial ships and fighters	--]]
	local position_index = 0
	local fleet_leaders = {}
	while strength >= 0 do
		local templates
		local composition = irandom(1,3)
		position_index = position_index % #positions + 1
		if composition == 1 then
			templates = {
				self:getClassTemplate("capitals"),
				self:getClassTemplate("fighters"),
				self:getClassTemplate("fighters"),
			}
		elseif composition == 2 then
			templates = {
				self:getClassTemplate("capitals"),
				self:getClassTemplate("capitals"),
			}
		else
			templates = {
				self:getClassTemplate("fighters"),
				self:getClassTemplate("fighters"),
				self:getClassTemplate("fighters"),
				self:getClassTemplate("fighters"),
			}
		end
		local used_strength, leader = self:spawnFormation(positions[position_index], strength, templates)
		strength = strength - used_strength
		table.insert(fleet_leaders, leader)
	end
	return fleet_leaders
end

--[[ Arlenians --]]

EnemyModuleArlenians = EnemyModule:new{
	faction="Arlenians",
	classes={
		fighters = arrayShuffle({"Widow", "Matron", "Goldfinch", "Gentoo", "Hoatzin"}),
		transports = arrayShuffle({"Macaw", "Spix", "Pigeon", "Grosbeak"}),
		escorts = arrayShuffle({"Woodpecker", "Swallow", "Linnet"}),
		cruisers = arrayShuffle({"Pheasant", "Grebe", "Pochard", "Crane"}),
	}
}

function EnemyModuleArlenians:spawnEnemiesAtPositions(positions, strength)
	local position_index = 0
	local fleet_leaders = {}
	while strength >= 0 do
		position_index = position_index % #positions + 1
		local templates
		if position_index % 2 == 1 then
			templates = {
				self:getClassTemplate("fighters"),
				self:getClassTemplate("fighters"),
				self:getClassTemplate("fighters"),
				self:getClassTemplate("fighters"),
			}
		else	
			templates = {
				self:getClassTemplate("escorts"),
				self:getClassTemplate("transports"),
				self:getClassTemplate("escorts"),
				self:getClassTemplate("transports"),
				self:getClassTemplate("cruisers"),
				self:getClassTemplate("transports"),
			}
		end
		local used_strength, leader = self:spawnFormation(positions[position_index], strength, templates)
		strength = strength - used_strength
		table.insert(fleet_leaders, leader)
	end
	return fleet_leaders
end


