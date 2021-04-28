-- this file extends the CpuShip with the additional :setStrategy function.
-- currently only exuari strategies are supported
-- it is assumed, that all ships start with idle order.

require("utils.lua")
require("script_formation.lua")
script_strategy = {}

function script_strategy:init()
	self.shipLists = {
		exuariFighters = {},
		exuariStrikers = {},
		exuariDefenders = {},
		exuariArtilleries = {},
		exuariCarriers = {},
	}
end

function script_strategy:update(delta)
	-- remove destroyed ships from lists.
	for _, list in ipairs(self.shipLists) do
		for i,ship in ipairs(list) do
			if not ship:isValid() then
				table.remove(list, i)
				break
			end
		end
	end
	local ss = self.shipLists
	handleFormation(ss.exuariFighters)
	handleStationAttack(ss.exuariStrikers)
	handleDefenders(ss)
	handleStationAttack(ss.exuariArtilleries)
	handleMissileRestock(ss.exuariArtilleries, ss.exuariCarriers, delta)
	handleCarriers(ss.exuariCarriers)
	return
end

function script_strategy.setStrategy(ship, strategy)
	if strategy == "exuariGeneric" then
		local strategies = {
			["Dagger"]= "exuariFighter",
			["Blade"]= "exuariFighter",
			["Gunner"]= "exuariFighter",
			["Shooter"]= "exuariFighter",
			["Jagger"]= "exuariFighter",
			["Racer"]= "exuariStriker",
			["Hunter"]= "exuariStriker",
			["Strike"]= "exuariStriker",
			["Dash"]= "exuariStriker",
			["Guard"]= "exuariDefender",
			["Sentinel"]= "exuariDefender",
			["Warden"]= "exuariDefender",
			["Flash"]= "exuariArtillery",
			["Ranger"]= "exuariArtillery",
			["Saviour"]= "exuariArtillery",
			["Ryder"]= "exuariCarrier",
			["Fortress"]= "exuariCarrier",
		}
		local templ = ship:getTypeName()
		local new_strategy = strategies[templ]
		if new_strategy == nil then
			ship:orderRoaming()
			return ship
		else
			strategy = new_strategy
		end
	end
	if strategy == "exuariFighter" then
		table.insert(script_strategy.shipLists.exuariFighters, ship)
	elseif strategy == "exuariStriker" then
		table.insert(script_strategy.shipLists.exuariStrikers, ship)
	elseif strategy == "exuariDefender" then
		table.insert(script_strategy.shipLists.exuariDefenders, ship)
	elseif strategy == "exuariArtillery" then
		table.insert(script_strategy.shipLists.exuariArtilleries, ship)
	elseif strategy == "exuariCarrier" then
		table.insert(script_strategy.shipLists.exuariCarriers, ship)
	else
		error("no such strategy: "..strategy)
	end
	--default order is idle
	return ship
end

function handleFormation(ships)
	--The ships in *ships* tend to group together in a flight formation, if they are not in combat.
	--Typically used for fighters
	--A leader is chosen automaticaly: leader continues roaming
	--Looking for enemies in 8u range; looking for other ships from *list* in 10u.
	--Formation is self-repairing
	for i,ship in ipairs(ships) do
		local reassignOrder = false
		if ship:getOrder() == "Roaming" and not ship:areEnemiesInRange(8000) then
			reassignOrder = true
		elseif ship:getOrder() == "Fly in Formation" and not ship:getOrderTarget():isValid() then 
			reassignOrder = true
		elseif ship:getOrder() == "Idle" then
			reassignOrder = true
		end
		if reassignOrder then
			ship.leader = nil
			for _, friend in ipairs(ships) do
				if friend ~= ship and friend:isValid() and ship:getFactionId() == friend:getFactionId() and distance(ship, friend) <= 10000 then
					if follow(ship, friend) then
						-- follow returns true, if a leader is accepted and followed.
						break
					end
				end
			end
			if ship.leader == nil and ship:getOrder() ~= "Roaming" then
				-- no leader found
				ship:orderRoaming()
			end
		end
	end
end

function follow(ship, leader)
	--try to follow the leader. returns false, if ship itself is the leader
	--returns true if new leader was assigned
	if leader == ship or leader == nil or not leader:isValid() then
		return false
	end

	if leader.leader ~= nil then
		return follow(ship, leader.leader)
	end
	
	--leader now is really a valid leader
	
	-- change leadership
	ship.leader = leader
	if leader.followed_by == nil then
		leader.followed_by = {}
	end
	table.insert(leader.followed_by, ship)

	-- build formation
	if #leader.followed_by <= 4 then
		-- including fifth ship 
		script_formation.buildFormationIncremental(ship, #leader.followed_by + 1, leader)
	else
		local last_leader_idx = ((#leader.followed_by-2) // 4) * 4
		-- last leaders index in followed list, groups of four.
		script_formation.buildFormationIncremental(ship, #leader.followed_by + 1, leader.followed_by[last_leader_idx])
	end

	-- TODO test with many fighters!

	if ship.followed_by ~= nil then
		for _, follower in ipairs(ship.followed_by) do
			if follower:isValid() then
				follow(follower, leader)
			end
		end
		ship.followed_by = {}
	end
	return true	
end

function handleStationAttack(list)
	-- Strikers and Artillery prefer stations as targets, but get distracted by other targets
	-- use FlyTowards as order. When Coordinates are reached, if changes to Defend Location
	for i,ship in ipairs(list) do
		if ship:getOrder() == "Idle" or ship:getOrder() == "Defend Location" then
			-- select new station as target
			local best_target = findNearestStation(ship, ship.isEnemy)
			if best_target == nil then
				flyAround(ship)
			else
				ship:orderFlyTowards(best_target:getPosition())
			end
		end
	end
end

function handleMissileRestock(list, carriers, delta)
	-- Artillery will dock on a carrier, when running out of missiles
	for i,ship in ipairs(list) do
		if ship:getOrder() == "Dock" then
			-- restocking missiles
			local target = ship:getOrderTarget()
			if not target:isValid() then
				ship:orderIdle()
				return
			end
			if ship:isDocked(target) then
				ship.out_of_missiles = false
				local nextMissile = nil 
				for _,missile in ipairs{"Homing", "HVLI", "Nuke", "EMP"} do
					if ship:getWeaponStorage(missile) < ship:getWeaponStorageMax(missile) then
						nextMissile = missile
						ship.out_of_missiles = true
						break
					end
				end
				if not ship.out_of_missiles then
					ship:orderIdle()
				elseif target.typeName ~= "SpaceStation" then
					--since docked ships do not supply with missiles:
					if ship.missile_reload_delay == nil then
						ship.missile_reload_delay = 10
					end
					ship.missile_reload_delay = ship.missile_reload_delay - delta
					if ship.missile_reload_delay <= 0 then
						ship.missile_reload_delay = nil
						ship:setWeaponStorage(nextMissile, ship:getWeaponStorage(nextMissile)+1)
					end
				end
			end
		elseif ship:getOrder() == "Fly towards (ignore all)" and ship.out_of_missiles then	--TODO test - does nil evaluate to false?
			-- init suicide
			if distance(ship, ship:getOrderTargetLocation()) <= 100 then --Fixme getRadius!
				ship.orderStandGround()
				-- TODO maybe add animation
				ship.suicide_counter = 10
			end
		elseif ship:getOrder() == "Stand Ground" and ship.suicide_counter ~= nil then
			-- suicide
			ship.suicide_counter = ship.suicide_counter - delta
			if ship.suicide_counter < 0 then
				ship.suicide_counter = nil
				local x,y = ship:getPosition()
				Mine():setPosition(x,y)
			end
		else
			ship.out_of_missiles = true
			for _,missile in ipairs{"Homing", "HVLI", "Nuke", "EMP"} do
				if ship:getWeaponStorage(missile) > 0 then
					ship.out_of_missiles = false
					--break
				end
			end
			if ship.out_of_missiles then
				-- select near stations as target
				local best_target = findNearestStation(ship, ship.isFriendly)
				-- select carriers as target
				for _,friend in ipairs(carriers) do
					if friend:isValid() and ship:isFriendly(friend) then
						if best_target == nil then
							best_target = friend
						elseif distance(ship, best_target) > distance(ship, friend) then
							best_target = friend 
						end
					end
				end
				if best_target ~= nil then
					-- dock and restock
					ship:orderDock(best_target)
				else
					best_target = findNearestStation(ship, ship.isEnemy)
					if best_target ~= nil then
						-- suicide
						ship:orderFlyTowardsBlind(best_target:getPosition())
					else
						-- do nothing here - fall back to station seeking.
						-- XXX this case is expenive in computation: all this is called every tick!
					end
				end
			end
		end
	end
end

function findNearestStation(ship, filter)
	local best_target = nil
	for _,obj in ipairs(ship:getObjectsInRange(getLongRangeRadarRange())) do
		if obj.typeName == "SpaceStation" and filter(ship, obj) then
			if best_target == nil then
				best_target = obj
			elseif distance(ship, best_target) > distance(ship, obj) then
				best_target = obj
			end
		end
	end
	return best_target
end

function flyAround(ship)
	-- like roaming, but falls back to Defend Location when target is reached
	local x, y = radialPosition(ship, getLongRangeRadarRange, random(0,360))
	ship:orderFlyTowards(x,y)
end

function handleDefenders(ss)
	-- Defenders look for other capital ships to defend
	-- If none are found, they follow smaller ships
	-- If there are none left, they slowly crawl around
	-- Never follow other defenders to prevent circular defenses
	-- Note that Defenders do not defend stations on their own.
	-- To defend stations, use a direct order.
	-- This can be done in addition to this strategy
	for i,ship in ipairs(ss.exuariDefenders) do
		if ship:getOrder() == "Idle" or ship:getOrder() == "Roaming" or ship:getOrder() == "Defend Location" then
			local lists = {ss.exuariCarriers, ss.exuariArtilleries, ss.exuariStrikers, ss.exuariFighters}
			local best_target = nil
			for _, list in ipairs(lists) do
				for _,friend in ipairs(list) do
					if friend:isValid() and ship:isFriendly(friend) then
						if distance(ship, friend) <= getLongRangeRadarRange() then
							if best_target == nil then
								best_target = friend
							elseif distance(ship, best_target) > distance(ship, friend) then
								best_target = friend 
							end
						end
					end
				end
				if best_target ~= nil then
					ship:orderDefendTarget(best_target)
					break
				end
			end
			if best_target == nil then
				flyAround(ship)
			end
		end
	end
end

function handleCarriers(ships)
	for i,ship in ipairs(ships) do
		--TODO 
		-- maybe flyTowards enemy station?
		if ship:getOrder() == "Idle" then
			ship:orderDefendLocation(ship:getPosition())
		end
		-- It would make sense to add a Hangar. But this should be done within the mission script.
	end
end
