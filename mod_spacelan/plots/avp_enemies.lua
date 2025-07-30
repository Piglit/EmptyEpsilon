avp_enemies = {
	modules = {},
}

--[[ assume the existence of the following lists:
* stl[faction][template] = value
* stln[faction] = {templates}
* stnl = {templates}
* stsl = {values}
* ship_template_strength[template] = value
--]]

function avp_enemies:spawn(positions, faction, strength)
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

EnemyModuleKraylor = EnemyModule:new{
	faction="Kraylor",
	breakers = arrayShuffle({
		"Rockbreaker",
		"Rockbreaker Merchant",
		"Rockbreaker Murderer",
		"Rockbreaker Mercenary",
		"Rockbreaker Marauder",
		"Rockbreaker Military",
	}),
	breaker_index = 0,
	bringers = arrayShuffle({
		"Deathbringer",
		"Painbringer",
		"Doombringer"
	}),
	bringer_index = 0,
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
		last_strength = self:spawnFlotilla(positions[position_index], flotilla_strength)
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

function EnemyModuleKraylor:spawnMarauder(pos, strength)
	local template = "Spinebreaker"
	if strength < 24 then
		template = "Rockbreaker"
	elseif irandom(1,2) == 1 then
		-- 50% Spinebreaker, 50% Rockbreaker
		template = self:getBreakerTemplate()
	end
	local ship, used_strength = self:spawnShipAtPosition(template, pos)
	if strength - used_strength > 5 and irandom(1,2) == 1 then
		-- 50% add drone in hangar
		script_hangar.create(ship, "Drone", 1)
		used_strength = used_strength + 5
	end
	return used_strength
end

function EnemyModuleKraylor:spawnFlotilla(pos, strength)

end

function EnemyModuleKraylor:spawnBase(pos, strength)

end

function EnemyModuleKraylor:getBreakerTemplate()
	self.breaker_index = self.breaker_index +1
	if self.breaker_index > #self.breakers then
		self.breakers = arrayShuffle(self.breakers)
		self.breaker_index = 1
	end
	return self.breakers[breaker_index]
end

function EnemyModuleKraylor:getBringerTemplate()
	self.bringer_index = self.bringer_index +1
	if self.bringer_index > #self.bringers then
		self.bringers = arrayShuffle(self.bringers)
		self.bringer_index = 1
	end
	return self.bringers[bringer_index]
end


function EnemyModuleKraylor:createShips(templates)
	local formationLeader = nil
	local formationSecond = nil
	if #templates > 1 then
		for index,template in ipairs(templates) do
			local ship = CpuShip():setTemplate(template)
			ship:setFaction(self.faction):setScannedByFaction(self.faction, true)
			ship:orderRoaming()	-- only the first one, the other ones get flyFormation
			formationLeader, formationSecond = script_formation.buildFormationIncremental(ship, index, formationLeader, formationSecond)
		end
		-- maybe disable jump
	else
		script_hangar.create(ship[1], "Drone", 2)
	end
end
