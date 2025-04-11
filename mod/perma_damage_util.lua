perma_damage_util = {}

function perma_damage_util:updatePlayerShip(delta, p)
	if p ~= nil and p:isValid() then
		for _, system in ipairs(SYSTEMS) do	-- SYSTEMS from ee.lua
			if p:hasSystem(system) then
				if p[system] == nil then
					p[system] = p:getSystemHealth(system)
				end
				local diff = p[system] - p:getSystemHealth(system)
				p[system] = p:getSystemHealth(system)
				if diff > 0 then
					p:setSystemHealthMax(system, p:getSystemHealthMax(system) - diff / 20)
					perma_damage_util.log_damage(p, diff, system, nil)
				end
			end
		end
	end
end

function perma_damage_util:onNewPlayerShip(ship)
	-- DANGER: this can be only set once per object
	ship.damage_log = {}
	ship.damage_log_last_time = 0
	ship:onTakingDamageDetailed(perma_damage_util.onPlayerShipTakingDamage)
end

function perma_damage_util.onPlayerShipTakingDamage(obj, amount, type, instigator)
	-- instigator may be nil:
	-- Hitting asteroids or mines: instigator is nil
	-- ship weapons set their owner as instigator
	types = {
		"energy",
		"kinetic",
		"emp",
	}
	local inst = nil
	if instigator ~= nil then
		inst = instigator.typeName
	end
	amount = amount / obj:getHullMax()
	perma_damage_util.log_damage(obj, amount, types[type+1], inst)
end

-- toJSON has problems with tables in lists...
function perma_damage_util:addDamageTypeAmount(log_table, type, amount)
	local found = false
	for idx,data in ipairs(log_table) do
		if data[1] == type then
			data[2] = data[2] + amount
			found = true
		end
	end
	if found == false then
		table.insert(log_table, {type, amount})
	end
end

function perma_damage_util.log_damage(ship, amount, type, instigator)
	-- only use arrays - toJSON is faulty otherwise
	-- amount ranges from 0 - 2: 1 means 100% damage of that system (or hull)
	-- type is a ship system or a damage type if hull was hit
	-- amount is 0, when only shields got damaged
	assert(type ~= nil)
	local time = math.floor(getScenarioTime())
	if time - ship.damage_log_last_time < 10.0 and #ship.damage_log > 0 then
		-- summarize damage reports in short time window
		local log_entry = ship.damage_log[#ship.damage_log]
		log_entry[1] = time
		perma_damage_util:addDamageTypeAmount(log_entry[2], type, amount)
		if instigator ~= nil and not arrayContains(log_entry[3], instigator) then
			table.insert(log_entry[3], instigator)
		end
	else
		-- new log entry
		-- 							   time,   systems(pairs), instigators
		table.insert(ship.damage_log, {time, {{type, amount}}, {instigator}})	-- if instigator is nil, this is an empty table
	end
	ship.damage_log_last_time = time
end

function perma_damage_util:sendDamageReport(ship)
	if #ship.damage_log > 0 then
		local data = {
			callsign = ship:getCallSign(),
			data = ship.damage_log,	-- toJSON gets confused by nesting objects in table
		}
		print(toJSON(data))
		player_ships_util:http_post("/damagereport", toJSON(data))
		ship.damage_log = {}	-- clear after send
	end
end

