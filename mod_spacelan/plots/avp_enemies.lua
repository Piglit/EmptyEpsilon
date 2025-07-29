avp_enemies = {
	modules = {},
}

--[[ assume the existence of the following lists:
* stl[faction][template] = value
* stln[faction] = {templates}
* stnl = {templates}
* stsl = {values}
--]]


function avp_enemies:spawn(positions)
	for _,pos in ipairs(positions) do
		local ship = CpuShip():setTemplate("Deathbringer"):setFaction("Kraylor"):setPosition(pos[1], pos[2])
	end
end



local EnemyModule = {}

function EnemyModule:new(obj)
	obj = obj or {} -- create empty if none given 
	setmetatable(obj, self)
	self.__index = self
	table.insert(avp_enemy_modules.modules, obj)
	return obj
end

EnemyModuleKraylor = EnemyModule:new{faction="Kraylor"}

function EnemyModuleKraylor:selectTemplates(strength)
	local templates = {}
	local rand = random(1,100)
	local bringers = arrayShuffle({"Deathbringer", "Painbringer", "Doombringer"})
	local breakers = arrayShuffle({
		"Rockbreaker",
		"Rockbreaker Merchant",
		"Rockbreaker Murderer",
		"Rockbreaker Mercenary",
		"Rockbreaker Marauder",
		"Rockbreaker Military",
	})
	if strength >= 100 and rand % 3 == 0 then
		-- Flottillas pattern: one bringer and two breakers
		table.insert(templates, table.remove(bringers))
		table.insert(templates, table.remove(breakers))
		table.insert(templates, table.remove(breakers))
	elseif rand >= 50 then
		-- Marauder pattern: one single roaming ship
		table.insert(templates, table.remove(breakers))
	else
		-- Marauder pattern: 50% Spinebreaker
		table.insert(templates, "Spinebreaker")
	end
	return templates
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
