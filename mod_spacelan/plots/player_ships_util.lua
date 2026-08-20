-- Player Ship utility for Shattered Horizon
local ENABLE_UPGRADES = true	-- feature flag for ship upgrades
local ENABLE_HELP = true	-- feature flag for interactive help (engineering)

require("utils_customElements.lua")	-- customElements (unified custom info)

player_ships_util = {
	active_ships = {},
	active_ships_by_faction = {},
	upgrades_by_ship = {},
	possible_upgrades = {
		"Laser",
		"Schild",
		"Antrieb",
		"Manöver",
	},
	custom_elements_index_base = {
		upgrade = 20,	-- +70
		help = 90,		-- +4
	},
}

function player_ships_util:init()
	local storage = getScriptStorage()
	storage["player_ships_util"] = self
end

function player_ships_util:spawn_player_ship(shipname, template, description, faction)
	print("Create " .. template .. " " .. shipname)
    
	if string.sub(shipname, 1, 4) == "Rho-" then	-- TODO for the fighters!
		ship:setCallSign(shipname)
		ship:commandLoadTube(0, "laser_green")
		ship:commandLoadTube(1, "laser_green")
		ship:setSystemPowerFactor("reactor", -10)
		ship:setRepairCrewCount(0)
		ship:setCanBeDestroyed(true)
	end



	if ENABLE_UPGRADES then
		ship.upgrade_changed = true
		ship.beam_weapon_data = {}
		ship.shield_data = {}
		ship.impulse_data = {}
		ship.maneuver_data = nil
		ship.coolant_data = nil
		ship.system_power_factor = {}
		ship.system_coolant_rates = {}
		ship.droid_data = nil
		ship.energy_data = nil
	end
	return ship
end


function player_ships_util:gm_menu()
	addGMFunction(_("buttonGM", "Upgrade Player Ship"), function()
		clearGMFunctions()
		for idx, data in pairs(player_ships_util.PLAYER_SHIPS) do	-- FIXME
			local shipname = data[1]
			addGMFunction(_("buttonGM", shipname), function()
				player_ships_util:upgrades_gm_menu(shipname)
			end, idx)
		end
		gm_menu_back()
	end)
end


function player_ships_util:updatePlayerShip(delta, ship)
	if ship == nil or not ship:isValid() then
		return
	end
	if ENABLE_UPGRADES and ship.upgrade_changed then
		local upgrade_levels = self.upgrades_by_ship[ship.shipname]
		if upgrade_levels ~= nil then
			self:upgrades_engineering_menu(ship, upgrade_levels)
		end
	end
	if ENABLE_HELP then
		local energy = ship:getEnergyLevel() / ship:getEnergyLevelMax()
		if energy < 0.3 then
			customElements:addCustomInfo(ship, "Engineering","help_engi_energy_0","Warnung: Energie niedrig", self.custom_elements_index_base.help)
			customElements:addCustomInfo(ship, "Engineering","help_engi_energy_1","Mögliche Maßnahmen:", self.custom_elements_index_base.help + 1)
			customElements:addCustomInfo(ship, "Engineering","help_engi_energy_2","Reaktorleistung erhöhen", self.custom_elements_index_base.help + 2)
			if energy < 0.1 then
				customElements:addCustomInfo(ship, "Engineering","help_engi_energy_0","Energielevel kritisch", self.custom_elements_index_base.help)
				customElements:addCustomInfo(ship, "Engineering","help_engi_energy_3","Systeme herunterfahren", self.custom_elements_index_base.help + 3)
			else
				customElements:removeCustom(ship, "help_engi_energy_3")
			end
			if ship:getShieldsActive() then
				customElements:addCustomInfo(ship, "Engineering","help_engi_energy_4","Schilde deaktivieren", self.custom_elements_index_base.help + 4)
			else
				customElements:removeCustom(ship, "help_engi_energy_4")
			end
		else
			customElements:removeCustom(ship, "help_engi_energy_0")
			customElements:removeCustom(ship, "help_engi_energy_1")
			customElements:removeCustom(ship, "help_engi_energy_2")
			customElements:removeCustom(ship, "help_engi_energy_3")
			customElements:removeCustom(ship, "help_engi_energy_4")
		end
	end	
end


if ENABLE_UPGRADES then
	function player_ships_util:upgrades_gm_menu(shipname)
		clearGMFunctions()
		addGMFunction(_("buttonGM", "Upgrades for ") .. shipname, function()
			player_ships_util:upgrades_gm_menu(shipname)
		end, 0)		--just an info
		local current_upgrades = player_ships_util.upgrades_by_ship[shipname]
		if current_upgrades == nil then
			current_upgrades = {}
		end
		for up_idx, up_name in ipairs(player_ships_util.possible_upgrades) do
			local level = current_upgrades[up_name] or 0
			addGMFunction(_("buttonGM", up_name) .. " " .. level, function()
				clearGMFunctions()
				addGMFunction(_("buttonGM", "Set ") .. up_name .. _(" for ") .. shipname, function()
					player_ships_util:upgrades_gm_menu(shipname)
				end, 0)	--just an info
				for i=0,2 do	
					addGMFunction(tostring(i), function() 
						player_ships_util:set_player_ship_upgrade_level(shipname, up_name, i)
						player_ships_util:upgrades_gm_menu(shipname)
					end, i+1)
				end
				gm_menu_back()
			end, up_idx)
		end
		gm_menu_back()
	end

	function player_ships_util:set_player_ship_upgrade_level(shipname, up_name, level)
		if self.upgrades_by_ship[shipname] == nil then
			self.upgrades_by_ship[shipname] = {}
		end
		self.upgrades_by_ship[shipname][up_name] = level
		if self.active_ships[shipname] ~= nil then
			self.active_ships[shipname].upgrade_changed = true	-- also set when ship spawns
		end
	end

	function player_ships_util:upgrades_engineering_menu(ship, upgrade_levels)
		-- update the menu for engineering
		if ship.upgrades_active == nil then
			ship.upgrades_active = {}
		end
		for idx, up_name in ipairs(self.possible_upgrades) do
			local level = upgrade_levels[up_name]
		   	if level == nil or level == 0 then
				customElements:removeCustom(ship, "activate_"..up_name)
			else
				if ship.upgrades_active[up_name] ~= nil then
					local effects = ship.upgrades_active[up_name][2]
					-- show effects and deactivation button
					customElements:addCustomInfo(ship, "Engineering", "status_"..up_name, up_name .. _("-Boost ist aktiv"), self.custom_elements_index_base.upgrade + idx*10)
					for e_idx,effect in ipairs(effects) do
						customElements:addCustomInfo(ship, "Engineering", "effect_"..up_name..tostring(e_idx), effect, self.custom_elements_index_base.upgrade + idx*10+e_idx)
					end
					customElements:addCustomButton(ship, "Engineering", "deactivate_"..up_name, up_name .. _("-Boost stoppen"), function()
						player_ships_util:deactivate_upgrade(ship, up_name)
					end, self.custom_elements_index_base.upgrade + idx*10+3)
					customElements:removeCustom(ship, "activate_"..up_name)
				else
					if level > 0 then
						-- show activation button
						customElements:addCustomButton(ship, "Engineering", "activate_"..up_name, up_name .. _("-Boost starten"), function()
							player_ships_util:activate_upgrade(ship, up_name, level)
						end, self.custom_elements_index_base.upgrade + 70+idx)
					end
					customElements:removeCustom(ship, "status_"..up_name)
					for i=1,5 do
						customElements:removeCustom(ship, "effect_"..up_name..tostring(i))
					end
					customElements:removeCustom(ship, "deactivate_"..up_name)
				end
			end
		end
		ship.upgrade_changed = false
	end

	function player_ships_util:activate_upgrade(ship, up_name, level)
		print("activate_upgrade", ship.shipname, up_name, level)
		if level < 1 then
			player_ships_util:deactivate_upgrade(ship, up_name)
		end
		if level > 2 then
			ship.upgrade_changed = true
			ship.upgrades_active[up_name] = nil
			error("upgrade level too high!")
			return
		end
		local effects = {}
		if up_name == "Laser" then
			for idx=0,7 do
				ship.beam_weapon_data[idx] = {
					arc = ship:getBeamWeaponArc(idx),
					dir = ship:getBeamWeaponDirection(idx),
					rng = ship:getBeamWeaponRange(idx),
					cyc = ship:getBeamWeaponCycleTime(idx),
					dmg = ship:getBeamWeaponDamage(idx),
				}
				ship:setBeamWeapon(idx,
							 ship.beam_weapon_data[idx].arc,
							 ship.beam_weapon_data[idx].dir,
							 ship.beam_weapon_data[idx].rng*(1 + level*0.2),
							 ship.beam_weapon_data[idx].cyc*(1 + level*0.5),
							 ship.beam_weapon_data[idx].dmg)
			end
			ship.system_power_factor.beamweapons = ship:getSystemPowerFactor("beamweapons")
			ship:setSystemPowerFactor("beamweapons", ship.system_power_factor.beamweapons*(1 + level*0.5))
			if level == 1 then
				effects = {"+50% Feuerrate", "+20% Reichweite", "+50% Energieverbrauch"}
			elseif level == 2 then
				effects = {"+100% Feuerrate", "+40% Reichweite", "+100% Energieverbrauch"}
			end
		elseif up_name == "Schild" then
			for idx=0,ship:getShieldCount() -1 do
				ship.shield_data[idx] = ship:getShieldMax(idx)
			end
			local shields = {}
			for idx, shield in pairs(ship.shield_data) do
				table.insert(shields, shield * (1+level))
			end
			ship:setShieldsMax(table.unpack(shields))
			ship.system_power_factor.frontshield = ship:getSystemPowerFactor("frontshield")
			ship.system_power_factor.rearshield = ship:getSystemPowerFactor("rearshield")
			ship:setSystemPowerFactor("frontshield", ship.system_power_factor.frontshield*(1 + level*0.2))
			ship:setSystemPowerFactor("rearshield", ship.system_power_factor.rearshield*(1 + level*0.2))
			if level == 1 then
				effects = {"+100% Schildkapazität", "+20% Energieverbrauch"}
			elseif level == 2 then
				effects = {"+200% Schildkapazität", "+40% Energieverbrauch"}
			end
		elseif up_name == "Antrieb" then
			ship.impulse_data.fwd, ship.impulse_data.rev = ship:getImpulseMaxSpeed()
			ship.impulse_data.acc_fwd, ship.impulse_data.acc_rev = ship:getAcceleration()
			ship:setImpulseMaxSpeed(
					ship.impulse_data.fwd * (1+level*0.25),
				   	ship.impulse_data.rev * (1+level*0.25))
			ship:setAcceleration(
					ship.impulse_data.acc_fwd * (1+level*0.4),
				   	ship.impulse_data.acc_rev * (1+level*0.4))
			ship.system_power_factor.impulse = ship:getSystemPowerFactor("impulse")
			ship:setSystemPowerFactor("impulse", ship.system_power_factor.impulse*(1 + level*0.5))
			if level == 1 then
				effects = {"+40% Höchstgeschwindigkeit", "+25% Beschleunigung", "+50% Energieverbrauch"}
			elseif level == 2 then
				effects = {"+80% Höchstgeschwindigkeit", "+50% Beschleunigung", "+100% Energieverbrauch"}
			end
		elseif up_name == "Manöver" then
			ship.maneuver_data = ship:getRotationMaxSpeed()
			ship:setRotationMaxSpeed(ship.maneuver_data * (1+level*0.2))
			ship.system_power_factor.maneuver = ship:getSystemPowerFactor("maneuver")
			ship:setSystemPowerFactor("maneuver", ship.system_power_factor.maneuver*(1 + level*0.5))
			if level == 1 then
				effects = {"+20% Manövrierbarkeit", "+50% Energieverbrauch"}
			elseif level == 2 then
				effects = {"+40% Manövrierbarkeit", "+100% Energieverbrauch"}
			end
		elseif up_name == "Kühlung" then
			ship.coolant_data = ship:getMaxCoolant()
			ship:setMaxCoolant(ship.coolant_data * (1+level*0.3))
			for _,sys in ipairs({"reactor", "beamweapons", "missilesystem", "frontshield", "rearshield", "impulse", "maneuver", "warp", "jumpdrive"}) do
				ship.system_coolant_rates[sys] = ship:getSystemCoolantRate(sys)
				ship:setSystemCoolantRate(sys, ship.system_coolant_rates[sys] * (1-level*0.2) )
			end
			if level == 1 then
				effects = {"+30% Kühlmittel", "-20% Pumpgeschwindigkeit"}
			elseif level == 2 then
				effects = {"+60% Kühlmittel", "-40% Pumpgeschwindigkeit"}
			end
		elseif up_name == "Droiden" then
			ship.droid_data = ship:getRepairCrewCount()
			ship:setRepairCrewCount(ship.droid_data + level)
			ship.energy_data = ship:getMaxEnergy()
			ship:setMaxEnergy(ship.energy_data * (1-level*0.1))
			if level == 1 then
				effects = {"+1 Droide", "-10% Energiekapazität"}
			elseif level == 2 then
				effects = {"+2 Droiden", "-20% Energiekapazität"}
			end
		end
		ship.upgrades_active[up_name] = {level, effects}
		ship.upgrade_changed = true
	end

	function player_ships_util:deactivate_upgrade(ship, up_name)
		print("deactivate_upgrade", ship.shipname, up_name)
		if up_name == "Laser" then
			for idx=0,7 do
				ship:setBeamWeapon(idx,
							 ship.beam_weapon_data[idx].arc,
							 ship.beam_weapon_data[idx].dir,
							 ship.beam_weapon_data[idx].rng,
							 ship.beam_weapon_data[idx].cyc,
							 ship.beam_weapon_data[idx].dmg)
			end
			ship:setSystemPowerFactor("beamweapons", ship.system_power_factor.beamweapons)
		elseif up_name == "Schild" then
			local shields = {}
			for idx, shield in pairs(ship.shield_data) do
				table.insert(shields, shield)
			end
			ship:setShieldsMax(table.unpack(shields))
			ship:setSystemPowerFactor("frontshield", ship.system_power_factor.frontshield)
			ship:setSystemPowerFactor("rearshield", ship.system_power_factor.rearshield)
		elseif up_name == "Antrieb" then
			ship:setImpulseMaxSpeed(
					ship.impulse_data.fwd,
				   	ship.impulse_data.rev)
			ship:setAcceleration(
					ship.impulse_data.acc_fwd,
				   	ship.impulse_data.acc_rev)
			ship:setSystemPowerFactor("impulse", ship.system_power_factor.impulse)
		elseif up_name == "Manöver" then
			ship:setRotationMaxSpeed(ship.maneuver_data)
			ship:setSystemPowerFactor("maneuver", ship.system_power_factor.maneuver)
		elseif up_name == "Kühlung" then
			ship:setMaxCoolant(ship.coolant_data)
			for _,sys in ipairs({"reactor", "beamweapons", "missilesystem", "frontshield", "rearshield", "impulse", "maneuver", "warp", "jumpdrive"}) do
				ship:setSystemCoolantRate(sys, ship.system_coolant_rates[sys])
			end
		elseif up_name == "Droiden" then
			ship:setRepairCrewCount(ship.droid_data)
			ship:setMaxEnergy(ship.energy_data)
		end
		ship.upgrades_active[up_name] = nil
		ship.upgrade_changed = true
	end
end


