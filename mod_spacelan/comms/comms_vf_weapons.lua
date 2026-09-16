--[[
Weapon-related communications and restocking
=============================================

This module handles buying weapons through a communications menu.
It is intended to be used for stations, but not limited to them.

At a high level, it does the following:

1. Sets up the station's weapon sales information.
Each weapon can be:
* true   - sold with unlimited supply
* number - sold with a limited number remaining
* false  - not sold

If no information has been configured for a weapon, the module automatically makes it available with a randomly generated price.

2. Keeps track of the price and display name of each weapon type.

3. Determines which weapons the station currently sells and displays them in the communications menu.

4. Calculates how many missiles the ship can buy.
The amount is limited by:
* the station's remaining stock (if the station has limited stock),
* the amount of storage space available on the ship,
* faction-related restrictions on storage.

5. Creates purchase choices for:
* one missile,
* roughly half of the maximum possible amount,
* the maximum possible amount.

6. When a purchase is selected, the module checks that:
* the weapon is still being sold,
* enough of that weapon is available,
* the ship has enough storage space,
* the ship has enough reputation to pay for it.

7. If all checks succeed, the purchase:
* deducts reputation from the ship,
* adds the missiles to the ship's weapon storage, and
* decreases the station's remaining stock if the weapon is limited.

Important terminology:
----------------------

"weapon_available" describes the station's supply, not the ship's current ammunition:
true   = unlimited supply
number = that many missiles remain
false  = the weapon is not sold

"weapon_cost" is the price of ONE missile. The total price of a purchase is calculated as:
weapon_cost * amount

The module also stores the weapon's display description in "weapon_desc".

The functions near the top of the file are small helper functions used
by the communications menu and purchase checks. The "restock" node
contains the actual player-facing communications flow.
--]]


--require("lib_comms_nodes")
local MISSILE_TYPES = {"Homing", "Nuke", "Mine", "EMP", "HVLI"}
local ccc = common_comms_conditions	-- from lib_comms_nodes

comms_vf_weapons = {}

--[[
Ensures that env.target.comms_data contains all data needed for weapon sales.

This function is safe to call multiple times. It only initializes the weapon data once.
It should be called once before the other functions here are called.
Is it called from the station pipeline and at the beginning of the tests.

For each weapon, weapon_available can be:
true   = unlimited supply
number = limited supply; the number is the amount remaining
false  = the weapon is not sold

Missing prices and descriptions are filled in with defaults.
Per default all weapons are sold, just like in the original comms_ship.lua
]]
function comms_vf_weapons.ensure_comms_data(env)
	local comms_data = env.target.comms_data
	assert(comms_data)
	if comms_data._weapons_initialized then
		return
	end
	local default_costs = {
		Homing = math.random(1,4),
		HVLI    = math.random(1,3),
		Mine    = math.random(2,5),
		Nuke    = math.random(12,18),
		EMP     = math.random(7,13),
	}
	local missile_types_desc = {
		["Nuke"]	=_("situationReport-comms","nukes"),
		["EMP"]		=_("situationReport-comms","EMPs"),
		["Homing"]	=_("situationReport-comms","homings"),
		["Mine"]	=_("situationReport-comms","mines"),
		["HVLI"]	=_("situationReport-comms","HVLIs"),
	}

	if comms_data.weapon_available == nil then
		comms_data.weapon_available = {}
	end
	if comms_data.weapon_cost == nil then
		comms_data.weapon_cost = {}
	end
	if comms_data.weapon_desc == nil then
		comms_data.weapon_desc = {}
	end

	if comms_data.weapon_factional_limit == nil then
		comms_data.weapon_factional_limit = true
	end
	for _, missile in ipairs(MISSILE_TYPES) do
		if comms_data.weapon_available[missile] == nil then
			comms_data.weapon_available[missile] = true
		end
		if comms_data.weapon_cost[missile] == nil then
			assert(default_costs[missile] ~= nil)
			comms_data.weapon_cost[missile] = default_costs[missile]
		end
		if comms_data.weapon_desc[missile] == nil then
			comms_data.weapon_desc[missile] = missile_types_desc[missile]
		end
	end
	if comms_data.service_available["sell_weapons"] == nil then
		comms_data.service_available["sell_weapons"] = true
	end
	comms_data._weapons_initialized = true
end

--[[
Returns whether the station currently sells the given weapon.

Returns true when the weapon is either:
* sold with unlimited supply, or
* sold with a limited supply greater than zero.

Returns false when the weapon is not sold or its limited supply has reached zero.
]]
function comms_vf_weapons.is_weapon_available(env, missile_type)
	if not env.target.comms_data.service_available["sell_weapons"] then
		return false
	end
	local avail = env.target.comms_data.weapon_available[missile_type]
	return avail == true or
		(type(avail) == "number" and
		avail > 0)
end

--[[
Returns whether the station has a limited supply of the given weapon.

A weapon is considered limited when weapon_available contains a number.
Weapons with a value of true have unlimited supply.
]]
function comms_vf_weapons.is_weapon_limited(env, missile_type)
	local avail = env.target.comms_data.weapon_available[missile_type]
	return type(avail) == "number"
end

--[[
Returns whether the station can provide the requested amount of the given weapon.

For weapons with unlimited supply, this always returns true.
For weapons with limited supply, it checks whether enough missiles remain.

This function only checks the station's supply. It does not check the ship's storage space or reputation.
]]
function comms_vf_weapons.has_weapon_quantity_avail(env, missile_type, amount)
	local avail = env.target.comms_data.weapon_available[missile_type]
	if avail == true then
		return true
	else
		return type(avail) == "number" and avail >= amount
	end
end

--[[
Returns a list containing all weapon types that the station currently sells.

Weapons that are not available, or whose limited supply has reached zero, are excluded from the returned list.
The weapon sales data is initialized automatically before the list is created.

This function is called weapons_available_message, which is called from outside from within the status report.
]]
function comms_vf_weapons.get_available_weapons(env)
	comms_vf_weapons.ensure_comms_data(env)
	local available_missiles = {}
	for _,missile in ipairs(MISSILE_TYPES) do
		if comms_vf_weapons.is_weapon_available(env, missile) then
			table.insert(available_missiles, missile)
		end
	end
	return available_missiles
end


-- returns the amount of buyable weapons
function comms_vf_weapons.get_max_weapon_storage(env, missile)
	local storage = env.source:getWeaponStorage(missile)
	local max = env.source:getWeaponStorageMax(missile)
	if env.target.comms_data.weapon_factional_limit and not env.target:isFriendly(env.source) then
		max = math.ceil(max/2)
	end
	return math.max(0, max - storage)
end

--[[
Returns the current reputation cost of one missile of the given type.

Returns nil when the weapon is not available for purchase.

The station's reputation cost multiplier is applied when one is configured.
]]
function comms_vf_weapons.get_weapon_cost(env, missile)
	comms_vf_weapons.ensure_comms_data(env)
	if not comms_vf_weapons.is_weapon_available(env, missile) then
		return nil	-- avail
	end
	local cost = env.target.comms_data.weapon_cost[missile]
	assert(cost ~= nil)
	cost = CommsNodeServiceBuyable.apply_reputation_cost_multiplier(env, cost)
	return math.ceil(cost)
end

--[[
Creates the text shown to the player describing the ordnance currently available at the station.

The message includes each available weapon, its remaining quantity when the supply is limited, and its price per missile.

Returns:
message - the text to display
available - true when at least one weapon can be purchased

This function is called from the outside from within the status report.
]]
function comms_vf_weapons.weapons_available_message(env)
	local missile_provision_msgs = {}
	for __, missile in ipairs(comms_vf_weapons.get_available_weapons(env)) do
		local cost = comms_vf_weapons.get_weapon_cost(env, missile)
		if cost ~= nil then
			if comms_vf_weapons.is_weapon_limited(env, missile) then
				table.insert(missile_provision_msgs,
				string.format(_("situationReport-comms","%d %s for %d rep"),
				env.target.comms_data.weapon_available[missile],
				env.target.comms_data.weapon_desc[missile], cost))
			else
				table.insert(missile_provision_msgs,
				string.format(_("situationReport-comms","%s for %d rep"),
				env.target.comms_data.weapon_desc[missile], cost))
			end
		end
	end
	if #missile_provision_msgs == 0 then
		return _("situationReport-comms","No ordnance available."), false
	else
		return string.format(_("situationReport-comms","Ordnance available: \n  %s"),
		table.concat(missile_provision_msgs, "\n  ")), true
	end
end

-- called from comms_vf_station_management
function comms_vf_weapons.increase_available_weapons(env)
	if env.target.comms_data.size_factor == nil then
		env.target.comms_data.size_factor = env.target:getHullMax() / 100	-- 1.5 to 8
	end
	for missile, avail in pairs(env.target.comms_data.weapon_available) do
		if avail == false then
			env.target.comms_data.weapon_available[missile] = math.floor(math.random(1,5) * env.target.comms_data.size_factor)
		elseif type(avail) == "number" then
			env.target.comms_data.weapon_available[missile] = math.floor(env.target.comms_data.weapon_available[missile] + math.floor(math.random(5,10) * env.target.comms_data.size_factor))
		end
	end
end

function comms_vf_weapons.disable_weapon_factional_limit(env)
	env.target.comms_data.weapon_factional_limit = false
end

comms_vf_weapons.info_weapons = CommsNode:new({
	choice_line = _("What weapons do you sell?"),
	select_message = function(self, env)
        return comms_vf_weapons.weapons_available_message(env)
	end,
})


--[[
Calculates the purchase information for one weapon type.

This determines:
* whether the weapon can be purchased,
* its price per missile,
* how many missiles are available,
* how many missiles the ship can store,
* the maximum quantity the player can buy,
* the quantity and price for the "half" purchase option,
* the quantity and price for the "full" purchase option.

The maximum purchase quantity is limited by both the station's available supply and the ship's available storage space.

Returns a table containing all of this information.
If the weapon cannot be purchased, the returned table has available = false.
]]
function comms_vf_weapons.get_missile_data(env, missile_type)
	local comms_data = env.target.comms_data
	local missile_data = {}
	--missile_data.missile_type = missile_type
	missile_data.cost = comms_vf_weapons.get_weapon_cost(env, missile_type) -- does all the nil checks
	if missile_data.cost == nil then
		missile_data.available = false
		return missile_data
	end
	missile_data.available = true
	if comms_vf_weapons.is_weapon_limited(env, missile_type) then
		missile_data.amount_available = comms_data.weapon_available[missile_type]
	end

	missile_data.amount_storable = comms_vf_weapons.get_max_weapon_storage(env, missile_type)
	if missile_data.amount_available == nil then
		missile_data.amount_available = missile_data.amount_storable
	end

	-- Determine the maximum number the player can buy.
	-- This is limited by both:
	--   1. how many the station has available, and
	--   2. how many the player's ship can store.
	missile_data.amount_full = math.min(missile_data.amount_available, missile_data.amount_storable)
	missile_data.amount_half = math.floor(missile_data.amount_full / 2)
	missile_data.cost_full = math.ceil(missile_data.amount_full * missile_data.cost)
	missile_data.cost_half= math.ceil(missile_data.amount_half * missile_data.cost)

-- TODO in next iteration of the script:
--		if comms_data.raise_weapon_cost then
--			-- raise the cost by 10 % after each buy
--			missile_data.raise_cost = 0.1
--			if comms_vf_weapons.is_weapon_limited(env, missile_type) then
--				missile_data.raise_cost = comms_data.raise_weapon_cost
--			end
--			missile_data.cost_full = missile_data.cost_full + math.ceil((missile_data.amount_full * (missile_data.amount_full +1)) * 0.5 * missile_data.raise_cost)
--			missile_data.cost_half = missile_data.cost_half + math.ceil((missile_data.amount_half * (missile_data.amount_half +1)) * 0.5 * missile_data.raise_cost)
--		end

	return missile_data	
end

--[[
Comms~node used to restock the player's ship with ordnance.

The node first shows which weapons are available for purchase.
It then offers different quantities for each weapon and passes the selected
weapon, quantity, and calculated price to the "with_missile" node.
]]
comms_vf_weapons.restock = CommsNode:new({
	choice_line = _("Restock ordnance"),
	select_message = function(self, env)
		if env.target.comms_data.service_available["sell_weapons"] == false then
			return _("You have to understand that our people are pacifists, so we will not sell weapons to you.")
		end
		local msg, ok = comms_vf_weapons.weapons_available_message(env)
		if not ok then
			return _("We do not sell weapons.")
		else
			return string.format(_("What type of ordnance do you need?\n%s"), msg)
		end
	end,
	_show_choices = function(self, env)
		if env.target.comms_data.service_available["sell_weapons"] then
			for idx, missile_type in ipairs(MISSILE_TYPES) do
				local missile_data = comms_vf_weapons.get_missile_data(env, missile_type)
				if missile_data.available then
					-- The single one option is always selectable as long as missile_data.available is set.
					-- It may still not be buyable, for different reasons - the reason is shown in the message after selectin it.
					addCommsReply(
						string.format(_("Buy one %s missile for %.0f reputation"), missile_type, missile_data.cost),
						self.with_missile:_as_comms_reply(env, {
							missile_type=missile_type,
							missile_data=missile_data,
							amount=1
						})
					)
					-- only display half, if it is not the same as one or full
					if missile_data.amount_half > 1 and missile_data.amount_half < missile_data.amount_full then
						addCommsReply(
							string.format(_("Buy %d %s missiles for %.0f reputation"),
								missile_data.amount_half, missile_type, missile_data.cost_half),
							self.with_missile:_as_comms_reply(env, {
								missile_type=missile_type,
								missile_data=missile_data,
								amount=missile_data.amount_half
							}
						)
					)
					end
					if missile_data.amount_full > 1 then
						addCommsReply(
							string.format(_("Buy %d %s missiles for %.0f reputation"),
								missile_data.amount_full, missile_type, missile_data.cost_full),
						self.with_missile:_as_comms_reply(env, {
							missile_type=missile_type,
							missile_data=missile_data,
							amount=missile_data.amount_full
							}
						)
					)
					end
				end
			end
		end
		comms_vf_weapons.restock.super()._show_choices(self, env)
	end,
	with_missile = CommsNode:new()	-- created here, filled below
}):add_condition(ccc.docked)

comms_vf_weapons.restock:add_test_setup(function(env)
	env.target.comms_data.weapon_available.Homing = true
	env.target.comms_data.weapon_available.Nuke = 7 
	env.target.comms_data.weapon_available.EMP = nil
	env.target.comms_data.weapon_cost.Homing = 10
	env.target.comms_data.weapon_cost.Nuke = 21
end)

comms_vf_weapons.restock:add_test(function(self, env)
	env.target.isFriendly = function(self, obj) assert(self); assert(obj); return false end
	self:_call(env)
	env.target.isFriendly = function(self, obj) assert(self); assert(obj); return true end
	local backup = comms_vf_station.apply_reputation_cost_multiplier
	comms_vf_station.apply_reputation_cost_multiplier = nil
	self:_show_choices(env)
	self:_call(env)
	comms_vf_station.apply_reputation_cost_multiplier = backup
	env.target.comms_data._weapons_initialized = false
	env.target.comms_data.weapon_available = nil
	self:_call(env)
	env.target.comms_data.weapon_available = {
		Nuke = false,
		EMP = false,
		Homing = false,
		Mine = false,
		HVLI = false,
	}
	self:_call(env)
	env.target.comms_data.weapon_available = {
		Nuke = 8,
		EMP = false,
		Homing = false,
		Mine = false,
		HVLI = false,
	}
	env.source.getWeaponStorageMax = function(self, m_type) assert(self); assert(type(m_type) == "string", m_type) return 8 end
	self:_show_choices(env)
	self:_call(env)
	env.target.isFriendly = function(self, obj) assert(self); assert(obj); return false end
	env.target.comms_data.weapon_factional_limit = true
	self:_show_choices(env)
	self:_call(env)
	env.target.isFriendly = function() return false end
	self:_call(env)
end)


--[[
Communications node that handles the purchase of a selected weapon.

The checks below validate the purchase before anything is changed.
If all checks succeed, the effect deducts reputation, adds the
missiles to the ship, and reduces the station's stock when applicable.
]]
-- comms_vf_weapons.restock.with_missile -- defined above

-- Check 1: Is this weapon still being sold?
comms_vf_weapons.restock.with_missile:add_check(function(self, env)
	assert(env.args.missile_type)
	return comms_vf_weapons.is_weapon_available(env, env.args.missile_type), _("We do no longer sell that weapon.")
end)

-- Check 2: If the station has limited stock, does it have enough missiles left to fulfill this purchase?
comms_vf_weapons.restock.with_missile:add_check(function(self, env)
	-- Does the station have enough stock?
	assert(env.args.amount)
	return comms_vf_weapons.has_weapon_quantity_avail(env, env.args.missile_type, env.args.amount), "We do not have that many missiles left."
end)

-- Check 3: Does the player's ship have enough storage space?
comms_vf_weapons.restock.with_missile:add_check(function(self, env)
	local missile_type = env.args.missile_type
	local amount = env.args.amount
	local storage = env.source:getWeaponStorage(missile_type)
	local max = env.source:getWeaponStorageMax(missile_type)
	return max - storage >= amount, string.format(_("You do not have enough storage space for %d %s missiles"), amount, missile_type)
end)

-- Check 4: Apply any additional storage restriction for customers that are not friendly with the station's faction.
comms_vf_weapons.restock.with_missile:add_check(function(self, env)
	-- after factional reduction, does the station want to sell this amount?
	local missile_type = env.args.missile_type
	local amount = env.args.amount
	return comms_vf_weapons.get_max_weapon_storage(env, missile_type) >= amount, _("Our customer regulations forbid selling you more of that weapon.")
end)

-- Check 5: Does the player's faction have enough reputation to pay for the requested number of missiles?
comms_vf_weapons.restock.with_missile:add_check(function(self, env)
	-- Does the ship have enough reputation?
	assert(env.args.missile_data.cost)
	local amount = env.args.amount
	local cost = env.args.missile_data.cost	-- pre-calculated. You can accept an offer later, even if the cost would have risen, as long as you do not close the comms node. This is effectifly how tradng works. We do not want the price to change between the offer and accepting it.
	return env.source:getReputationPoints() >= cost * amount, _("You do not have enough reputation.")
end)

-- Complete the purchase.
--
-- The price stored in missile_data was calculated when the purchase option was created,
-- so the player pays the price that was shown in the offer.
--
-- On success:
--   1. reputation is deducted,
--   2. missiles are added to the ship,
--   3. limited station stock is reduced.
comms_vf_weapons.restock.with_missile:add_effect(function(self, env)
	assert(env.args)
	local missile_type = env.args.missile_type
	local amount = env.args.amount
	local comms_data = env.target.comms_data
	local missile_data = env.args.missile_data
	local cost = missile_data.cost	-- pre-calculated
	if not env.source:takeReputationPoints(cost * amount) then
		return false, _("You do not have enough reputation.")
	end
	local storage = env.source:getWeaponStorage(missile_type)
	storage = storage + amount
	env.source:setWeaponStorage(missile_type, storage)
	if comms_vf_weapons.is_weapon_limited(env, missile_type) then
		comms_data.weapon_available[missile_type] = comms_data.weapon_available[missile_type] -amount
	end
	-- TODO raise costs
	return true, ""
end)

comms_vf_weapons.restock.with_missile.select_message = function(self, env)
	local missile_type = env.args.missile_type
	local amount = env.args.amount
	local cost = env.args.missile_data.cost
	return string.format(_("You bought %d %s missiles for %.0f reputation."), amount, missile_type, cost * amount)
end

comms_vf_weapons.restock.with_missile:add_test_setup(function(env)
	env.source.getReputationPoints = function(self) assert(self); return 27 end
	env.source.takeReputationPoints = function(self, amount) assert(self); return amount <= 27 end
	env.source.getWeaponStorageMax = function(self, m_type) assert(self); assert(type(m_type) == "string", m_type) return 7 end
	env.source.getWeaponStorage = function(self, m_type) assert(self); assert(type(m_type) == "string", m_type) return 4 end
	env.source.setWeaponStorage = function(self, m_type, amount) assert(self); assert(type(m_type) == "string", m_type); assert(amount <= 7) end
	env.args = {missile_type = "Homing", amount=1, missile_data={
		cost = 4
	}}
	comms_vf_weapons.ensure_comms_data(env)
end)

comms_vf_weapons.restock.with_missile:add_test(function(self,env)
	env.target.comms_data.weapon_available.Homing = true
	self:_call(env)
	env.target.comms_data.weapon_available.Homing = 0
	self:_call(env)
	env.target.comms_data.weapon_available.Homing = false
	self:_call(env)
	env.target.comms_data.weapon_available.Homing = 12
	self:_call(env)
	env.target.comms_data.weapon_cost.Homing = nil
	self:_call(env)
	env.args.missile_data.cost = 500
	self:_apply_effects(env)
	env.target.comms_data.weapon_available.Homing = 12
	env.args.missile_data.cost = 5
	self:_apply_effects(env)
	self:_call(env)
	env.source.getReputationPoints = function(self) assert(self); return 0 end
	env.source.takeReputationPoints = function(self, amount) assert(self); assert(amount); return false end
	self:_call(env)
	env.source.getReputationPoints = function(self) assert(self); return 27 end
	env.target.comms_data.weapon_available.Homing = true
	self:_call(env)
	env.source.takeReputationPoints = function(self, amount) assert(self); assert(amount); return true end
	self:_call(env)
	env.target.comms_data.weapon_factional_limit = true
	self:_call(env)
	env.target.isFriendly = function() return false end
	self:_call(env)
	env.target.isFriendly = function() return true end
	self:_call(env)
	env.target.comms_data.weapon_factional_limit = false
	self:_call(env)
end)


comms_vf_weapons.restock.with_missile:add_choice(CommsBack)
comms_vf_weapons.restock.with_missile:add_condition(ccc.docked)

comms_vf_weapons.info_weapons:add_choice(CommsBack)
comms_vf_weapons.restock:add_choice_to_all_children(CommsBack, true, true)

comms_vf_station.automatic.ensure_comms_data:add_comms_data_initialiser_function(comms_vf_weapons.ensure_comms_data)
comms_vf_station.info.main:add_choice(comms_vf_weapons.info_weapons,3)
comms_vf_station.main:add_choice(comms_vf_weapons.restock, 2)
