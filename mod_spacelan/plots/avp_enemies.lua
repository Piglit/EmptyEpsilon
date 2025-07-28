avp_enemies = {
<<<<<<< HEAD
	modules = {},
	factions = {
		"Kraylor",
		"Exuari",
		"Ktlitans",
		"Ghosts",
	},
}

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

function avp_enemies:spawn(positions, faction, strength)
	if faction == nil then
		if self.faction_index > #self.factions then
			arrayShuffle(self.factions)
			self.faction_index = 1
		end
		faction = self.factions[self.faction_index]
		self.faction_index = self.faction_index +1
	end

	if avp_enemies.modules[faction] ~= nil then
		avp_enemies[faction]:spawnEnemiesAtPositions(positions, strength)
	else
		EnemyModule:spawnEnemiesAtPositions(positions, strength)
	end
end

local EnemyModule = {}

function EnemyModule:new(obj)
	obj = obj or {} -- create empty if none given 
	setmetatable(obj, self)
	self.__index = self
	if obj.faction ~= nil and avp_enemy_modules.modules[obj.faction] == nil then
		avp_enemy_modules.modules[obj.faction] = obj
	else
		table.insert(avp_enemy_modules.modules, obj)
	end
	return obj
end

-- may place one or several ships at each given position
-- cycle through positions until the total strength of enemies is greater than the given strength
-- entry point for custom modules
function EnemyModule:spawnEnemiesAtPositions(positions, strength)
	local idx = 0
	local ships = {}
	while strength > 0 do
		idx = (idx % #positions) + 1
		local pos = positions[idx]
		local ship = self:spawnShipAtPosition("Drone", pos)
		table.insert(ships, ship)
		strength = strength - 5
	end
	return ships
end

function EnemyModule:spawnShipAtPosition(template, position)
	local ship = CpuShip():setTemplate(template):setPosition(pos[1],pos[2])
	if self.faction ~= nil then
		ship:setFaction(self.faction):setScannedByFaction(self.faction, true)
	end
	local used_strength = ship_template_strength[template]
	return ship, used_strength
end

function EnemyModule:getClassTemplate(class)
	-- returns a template of a specific ship class.
	-- ship classes must be defined when creating a new subclass of EnemyModule
	assert (self.classes ~= nil)
	assert (self.classes[class] ~= nil)
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
	while base_strength >= 100 do
		last_strength = self:spawnBase(positions[position_index], base_strength)
		base_strength = base_strength - last_strength
		position_index = position_index % #positions + 1
	end
	flotilla_strength = flotilla_strength + base_strength
	while flotilla_strength >= 50 do
		if irandom(1,3) == 1 then
			-- 33%: 4 Rockbreakers, 66%: 1 *bringer, 2 Rockbreakers
			last_strength = self:spawnBreakerFlotilla(positions[position_index], flotilla_strength)
		else
			last_strength = self:spawnBringerFlotilla(positions[position_index], flotilla_strength)
		end
		flotilla_strength = flotilla_strength - last_strength
		position_index = position_index % #positions + 1
	end
	marauder_strength = marauder_strength + flotilla_strength
	while marauder_strength > 0 do
		last_strength = self:spawnMarauder(positions[position_index], marauder_strength)
		marauder_strength = marauder_strength - last_strength
		position_index = position_index % #positions + 1
	end
end

function EnemyModuleKraylor:addDrones(ship, min, max, strength)
	max = math.min(max, math.floor(strength / 5))
	local drones_amount	= max
	if min < max then
		drones_amount = irandom(min,max)
	end
	if drones_amount > 0 then
		script_hangar.create(ship, "Drone", drones_amount)
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
	return used_strength
end

function EnemyModuleKraylor:spawnBreakerFlotilla(pos, strength)
	-- spawns a small group of ships, flying in formation
	local formationLeader, formationSecond
	total_used_strength = 0
	for index = 1, 4 do
		local template = self:getClassTemplate("breakers")
		local ship, used_strength = self:spawnShipAtPosition(template, pos)
		if index == 1 then
			ship:orderDefendLocation(pos[1], pos[2])
		end
		formationLeader, formationSecond = script_formation.buildFormationIncremental(ship, index, formationLeader, formationSecond)
		total_used_strength = total_used_strength + used_strength
		if total_used_strength >= strength then
			break
		end
	end
	return total_used_strength
end

function EnemyModuleKraylor:spawnBringerFlotilla(pos, strength)
	-- spawns a small group of ships, flying in formation
	-- lead by a stronger leader
	local formationLeader, formationSecond
	local template = self:getClassTemplate("bringers")
	local leader, total_used_strength = self:spawnShipAtPosition(template, pos)
	leader:orderDefendLocation(pos[1], pos[2])
	formationLeader = leader
	for index = 2, 3 do
		if total_used_strength >= strength then
			break
		end
		template = self:getClassTemplate("breakers")
		local ship, used_strength = self:spawnShipAtPosition(template, pos)
		formationLeader, formationSecond = script_formation.buildFormationIncremental(ship, index, formationLeader, formationSecond)
		total_used_strength = total_used_strength + used_strength
	end

	total_used_strength = total_used_strength + self:addDrones(leader, 1, 2, strength - total_used_strength)
	return total_used_strength
end


function EnemyModuleKraylor:spawnBase(pos, strength)
	local station, total_used_strength = self:spawnShipAtPosition("Battlestation", pos)
	station:orderStandGround()
	for index = 1, 3 do
		if total_used_strength >= strength then
			break
		end
		local template = self:getClassTemplate("breakers")
		local ship, used_strength = self:spawnShipAtPosition(template, pos)
		ship:orderDefendTarget(station)
		total_used_strength = total_used_strength + used_strength
	end
	total_used_strength = total_used_strength + self:addDrones(station, 2, 4, strength - total_used_strength)
	return total_used_strength
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
	--[[TODO better strategy
		send a captial ship and two fighters
	--]]
	local position_index
	while strength >= 0 do
		position_index = position_index % #positions + 1
		local formationLeader, formationSecond = nil, nil
		local template = self:getClassTemplate("capitals")
		local formationLeader, used_strength = self:spawnShipAtPosition(template, positions[position_index])
		formationLeader:orderRoaming()
		strength = strength - used_strength
		for index = 2,3 do
			if strength > 0 then
				local template = self:getClassTemplate("fighters")
				local ship, used_strength = self:spawnShipAtPosition(template, positions[position_index])
				formationLeader, formationSecond = script_formation.buildFormationIncremental(ship, index, formationLeader, formationSecond)
				strength = strength - used_strength
			end
		end
	end
end

