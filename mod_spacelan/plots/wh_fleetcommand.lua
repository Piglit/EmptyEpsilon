--[[ Spawns and manages the Fleet Command station
-- Upgrades allow to repair ships
-- Depends on: artifacts
-- Defines: starting position of the fleet command station
--]]
wh_fleetcommand = {}

require "ee.lua"
require "utils.lua"
require "utils_customElements.lua"

function wh_fleetcommand:init()
	self.station = nil
	self.upgrades_done = 0	-- if station gets destroyed, the respawned one will get a number of artifacts, matching the amount of upgrades.
	self.spawnFleetCommand()
	getScriptStorage().wh_fleetcommand = self 
end

function wh_fleetcommand.spawnFleetCommand()
	-- only allow spawn, if it was destroyed.
	-- You may call this function using the script interface
	if wh_fleetcommand.station ~= nil then
		if wh_fleetcommand.station:isValid() then
			return
		end
		sendMessageToCampaignServer("fleetcommand-deleted")
	end
	removeGMFunction("Create Fleetcommand")
	local posx, posy = 17500, 3500
	local fc = PlayerSpaceship():setTemplate("Targaryen"):setCallSign("Der Ball"):setPosition(posx, posy)
	fc:setJumpDrive(false):setWeaponTubeCount(0):setWeaponStorageMax("Homing", 0):setWeaponStorage("Homing", 0):setShieldsMax():setMaxScanProbeCount(0):setLongRangeRadarRange(5000)
	fc:setCanLaunchProbe(false):setCanHack(false):setCanScan(false):setCanSelfDestruct(false)
	fc:setControlCode("rundilein")
	for n=0,4 do
		fc:setBeamWeapon(n, 90,  n * 90, 0, 6, 5)
	end

	fc:setSharesEnergyWithDocked(false):setRestocksScanProbes(false):setRepairDocked(false):setRestocksMissilesDocked("none")
	fc:setResourceAmount("Artifacts", wh_fleetcommand.upgrades_done)
	fc:setResourceDescription("Artifacts", "You can spend Artifacts for upgrades")

	fc.ui_elements_active = {}
	fc.docked_ships = {}
	fc.ui_changed = true
	wh_fleetcommand.station = fc
	--wh_fleetcommand.upgrades_done = 0	-- if station gets destroyed, the respawned one will get a number of artifacts, matching the amount of upgrades of the old station.

	fc.last_pos_x, fc.last_pos_y = fc:getPosition()
	fc.jumped_time = 0
	fc.exclude_from_health_check = true

	if wh_exuari ~= nil then
		wh_exuari.state = "ambush"
		removeGMFunction("Exuari attack")
	end
	sendMessageToCampaignServer("fleetcommand-spawned", fc:getCallSign())	-- notify campaign server on where the fleet command is and what it's name is.
	wh_fleetcommand.set_upgrade_definitions()
end

function wh_fleetcommand.set_upgrade_definitions()
	local fc = wh_fleetcommand.station
	-- Docking services
	local name = "Energy Coupling"
	fc:setResourceAmount(name, -1)
	fc:setResourceCategory(name, "Dock Upgrades")
	fc:setResourceDescription(name, "Allows the station to share energy with docked ships.")
	name = "Hull Repair Scaffold"
	fc:setResourceAmount(name, -1)
	fc:setResourceCategory(name, "Dock Upgrades")
	fc:setResourceDescription(name, "Allows the station to repair the hull of docked ships.")
	name = "Probe Data Receiver"
	fc:setResourceAmount(name, -2)
	fc:setResourceCategory(name, "Dock Upgrades")
	fc:setResourceDescription(name, "Allows the station to restock docked ships with probes.")
	--name = "Torpedo Armory"
	--fc:setResourceAmount(name, -3)
	--fc:setResourceCategory(name, "Dock Upgrades")
	--fc:setResourceDescription(name, "Allows the station to restock docked ships with torpedos.")
	name = "Medical Bay"
	fc:setResourceAmount(name, -2)
	fc:setResourceCategory(name, "Dock Upgrades")
	fc:setResourceDescription(name, "Lost damcon teams of docked ships will be healed.")
	name = "Systems Repair Drydock"
	fc:setResourceAmount(name, -2)
	fc:setResourceCategory(name, "Dock Upgrades")
	fc:setResourceDescription(name, "Damaged systems of docked ships will be repaired.")
	name = "Coolant Refill Tanks"
	fc:setResourceAmount(name, -2)
	fc:setResourceCategory(name, "Dock Upgrades")
	fc:setResourceDescription(name, "Lost coolant of docked ships will be replenished.")
	name = "Drive Refit Workshop"
	fc:setResourceAmount(name, -3)
	fc:setResourceCategory(name, "Dock Upgrades")
	fc:setResourceDescription(name, "Allows docked ships to change their drive.")

	-- Station Upgrades
	name = "Jump Drive"
	fc:setResourceAmount(name, -3)
	fc:setResourceCategory(name, "Station Upgrades")
	fc:setResourceDescription(name, "Allows the station to use a jump drive.")
	name = "Missile Tubes"
	fc:setResourceAmount(name, -2)
	fc:setResourceCategory(name, "Station Upgrades")
	fc:setResourceDescription(name, "Allows the station to use homing missiles.")
	name = "Shield Generator"
	fc:setResourceAmount(name, -1)
	fc:setResourceCategory(name, "Station Upgrades")
	fc:setResourceDescription(name, "Allows the station to use shields.")
	name = "Beam Weapons"
	fc:setResourceAmount(name, -2)
	fc:setResourceCategory(name, "Station Upgrades")
	fc:setResourceDescription(name, "Allows the station to use beam weapons.")
	name = "Scan Probes"
	fc:setResourceAmount(name, -3)
	fc:setResourceCategory(name, "Station Upgrades")
	fc:setResourceDescription(name, "Allows the station to use scan probes.")
	name = "Scanning Device"
	fc:setResourceAmount(name, -2)
	fc:setResourceCategory(name, "Station Upgrades")
	fc:setResourceDescription(name, "Allows the station to scan unknown ships.")
	name = "Hacking Device"
	fc:setResourceAmount(name, -3)
	fc:setResourceCategory(name, "Station Upgrades")
	fc:setResourceDescription(name, "Allows the station to hack enemy ships.")
	name = "Self Destruction"
	fc:setResourceAmount(name, -1)
	fc:setResourceCategory(name, "Station Upgrades")
	fc:setResourceDescription(name, "Allows the station to activate self destruction.")
	name = "Mid Range Radar"
	fc:setResourceAmount(name, -1)
	fc:setResourceCategory(name, "Station Upgrades")
	fc:setResourceDescription(name, "Enlarges the station's radar range.")


	-- Ship Upgrades
	--name = "Station Command Team"
	--fc:setResourceAmount(name, -2)
	--fc:setResourceCategory(name, "Ship Upgrades")
	--fc:setResourceDescription(name, "Allows the ship to make neutral stations friendly.")
	--name = "Station Boarding Pod"
	--fc:setResourceAmount(name, -2)
	--fc:setResourceCategory(name, "Ship Upgrades")
	--fc:setResourceDescription(name, "Allows the ship to make enemy stations neutral.")
	name = "Transfer Artifact"
	fc:setResourceAmount(name, -1)
	fc:setResourceCategory(name, "Ship Upgrades")
	fc:setResourceDescription(name, "Transfer an Artifact to be used somewhere else.")
--	name = "Diplomatic Crew"
--	fc:setResourceAmount(name, -1)
--	fc:setResourceCategory(name, "Ship Upgrades")
--	fc:setResourceDescription(name, "Allows the ship to make neutral ships friendly.")
--	name = "Xenolinguistic Team"
--	fc:setResourceAmount(name, -1)
--	fc:setResourceCategory(name, "Ship Upgrades")
--	fc:setResourceDescription(name, "Allows the ship to make Kraylor ships neutral.")

end


function wh_fleetcommand.upgrade(resource)
	local fc = wh_fleetcommand.station
	local ship = fc.upgrade_selected_ship	-- nil if upgrade is not ship secific
	if resource == "Energy Coupling" then
		fc:setSharesEnergyWithDocked(true)
	elseif resource == "Hull Repair Scaffold" then
		fc:setRepairDocked(true)
	elseif resource == "Probe Data Receiver" then
		fc:setRestocksScanProbes(true)
	elseif resource == "Torpedo Armory" then
		fc:setRestocksMissilesDocked("playerships")
	elseif resource == "Jump Drive" then
		fc:setJumpDrive(true)
		fc.jumped_time = getScenarioTime() + 15*60	-- start half full
	elseif resource == "Missile Tubes" then
		fc:setWeaponTubeCount(4):setWeaponStorageMax("Homing", 40):setWeaponStorage("Homing", 40)
		local name = "Homing Missiles"
		fc:setResourceAmount(name, -1)
		fc:setResourceCategory(name, "Station Upgrades")
		fc:setResourceDescription(name, "Refill the station's homing missiles.")
	elseif resource == "Homing Missiles" then
		fc:setWeaponStorage("Homing", 40)
		wh_fleetcommand.upgrades_done = wh_fleetcommand.upgrades_done + 1
		return	-- skip discard upgrade
	elseif resource == "Shield Generator" then
		fc:setShieldsMax(1200):setShields(1200)
	elseif resource == "Beam Weapons" then
		for n=0,4 do
			fc:setBeamWeapon(n, 90,  n * 90, 2200, 6, 5)
		end
	elseif resource == "Scan Probes" then
		fc:setCanLaunchProbe(true)
		fc:setMaxScanProbeCount(12):setScanProbeCount(12)
		fc:setResourceDescription("Scan Probes", "Refill the station's scan probes.")
		fc:setResourceAmount("Scan Probes", -1)
		wh_fleetcommand.upgrades_done = wh_fleetcommand.upgrades_done + 1
		return	-- skip discard upgrade
	elseif resource == "Scanning Device" then
		fc:setCanScan(true)
	elseif resource == "Hacking Device" then
		fc:setCanHack(true)
	elseif resource == "Self Destruction" then
		fc:setCanSelfDestruct(true)
	elseif resource == "Mid Range Radar" then
		fc:setLongRangeRadarRange(30000)
		local name = "Long Range Radar"
		fc:setResourceAmount(name, -2)
		fc:setResourceCategory(name, "Station Upgrades")
		fc:setResourceDescription(name, "Further enlarges the station's radar range.")
	elseif resource == "Long Range Radar" then
		fc:setLongRangeRadarRange(60000)
	end

	if ship ~= nil then	-- ship specific
		if resource == "Transfer Artifact" then
			ship:increaseResourceAmount("Artifacts", 1)
		else
			ship:setResourceAmount(resource, 1)
			if ship.fc_upgrades_done == nil then
				ship.fc_upgrades_done = 0
			end
			ship.fc_upgrades_done = ship.fc_upgrades_done + 1
		end
	else	-- upgrade for station
		fc:setResourceAmount(resource, 1)
		wh_fleetcommand.upgrades_done = wh_fleetcommand.upgrades_done + 1
	end
end

function wh_fleetcommand:fc_menu_add_info(key, value, index)
	local fc = self.station
	customElements:addCustomInfo(fc, "Engineering", key, value, index)
	table.insert(fc.ui_elements_active, key)
end

function wh_fleetcommand:fc_menu_add_button(key, value, func, index)
	local fc = self.station
	customElements:addCustomButton(fc, "Engineering", key, value, func, index)
	table.insert(fc.ui_elements_active, key)
end

function wh_fleetcommand:fc_menu_set_status(status)
	local fc = self.station
	table.insert(fc.upgrade_menu_stack, fc.upgrade_menu_status)	-- push old
	fc.upgrade_menu_status = status
	wh_fleetcommand:fc_menu_clear()
end

function wh_fleetcommand:fc_menu_clear()
	local fc = self.station
	for _,element_name in ipairs(fc.ui_elements_active) do
		customElements:removeCustom(fc, element_name)
	end
	fc.ui_changed = true
end

function wh_fleetcommand:update_fc_menu()
	local fc = self.station
	if not fc.ui_changed then
		return
	end
	fc.ui_changed = false
	self:fc_menu_add_info("e_Artifacts_name", "Artifacts: "..tostring(fc:getResourceAmount("Artifacts")),0)
	if fc.upgrade_menu_status == nil then
		fc.upgrade_menu_stack = {}
		fc.upgrade_selected_ship = nil
		fc.upgrade_selected_resource = nil
		self:fc_menu_add_info("e_Artifacts_descr", fc:getResourceDescription("Artifacts"),1)
		self:fc_menu_add_button("e_upgrades_dock", "Dock upgrades", function() 
			wh_fleetcommand:fc_menu_set_status("upgrades_dock")
		end,10)
		self:fc_menu_add_button("e_upgrades_station", "Station upgrades", function() 
			wh_fleetcommand:fc_menu_set_status("upgrades_station")
		end,11)
		self:fc_menu_add_button("e_upgrades_ship", "Ship Artifact Transfer", function() 
			wh_fleetcommand:fc_menu_set_status("upgrades_ship")
		end,12)
	elseif fc.upgrade_menu_status == "upgrades_dock" then
		self:fc_menu_add_info("e_Artifacts_descr", "Select an upgrade to show details:",1)
		for _,resource in ipairs(fc:getResources("Dock Upgrades")) do
			local amount = fc:getResourceAmount(resource)
			if amount < 0 then
				self:fc_menu_add_button(resource, resource .. " (" .. tostring(-amount) .. ")", function()
					fc.upgrade_selected_resource = resource
					wh_fleetcommand:fc_menu_set_status("resource")
				end,20)
			end
		end
	elseif fc.upgrade_menu_status == "upgrades_station" then
		self:fc_menu_add_info("e_Artifacts_descr", "Select an upgrade to show details:",1)
		for _,resource in ipairs(fc:getResources("Station Upgrades")) do
			local amount = fc:getResourceAmount(resource)
			if amount < 0 then
				self:fc_menu_add_button(resource, resource .. " (" .. tostring(-amount) .. ")", function()
					fc.upgrade_selected_resource = resource
					wh_fleetcommand:fc_menu_set_status("resource")
				end,20)
			end
		end
	elseif fc.upgrade_menu_status == "upgrades_ship" then
		if #fc.docked_ships == 0 then
			self:fc_menu_add_info("e_Artifacts_descr", "No ships are currently docked.",1)
		else
			self:fc_menu_add_info("e_Artifacts_descr", "Select a ship for artifact transfer:",1)
		end
		fc.upgrade_selected_ship = nil
		for _,ship in ipairs(fc.docked_ships) do
			shipname = ship:getCallSign()
			self:fc_menu_add_button(shipname, shipname, function()
				fc.upgrade_selected_ship = ship
				wh_fleetcommand:fc_menu_set_status("ship")
			end,20)
		end
	elseif fc.upgrade_menu_status == "ship" then
		local ship = fc.upgrade_selected_ship
		if ship ~= nil and ship:isValid() and ship:isDocked(fc) then
			self:fc_menu_add_info("e_Artifacts_descr", "Select a transaction for "..ship:getCallSign().." to show details:",1)
			for _,resource in ipairs(fc:getResources("Ship Upgrades")) do
				local value = fc:getResourceAmount(resource)
				local amount = ship:getResourceAmount(resource)
				if amount <= 0 then
					self:fc_menu_add_button(resource, resource .. " (" .. tostring(-value) .. ")", function()
						local ship = fc.upgrade_selected_ship
						if ship ~= nil and ship:isValid() and ship:isDocked(fc) then
							fc.upgrade_selected_resource = resource
							wh_fleetcommand:fc_menu_set_status("resource")
						else
							wh_fleetcommand:fc_menu_set_status("undocked")
						end
					end,20)
				end
			end
		else
			wh_fleetcommand:fc_menu_set_status("undocked")
		end
	elseif fc.upgrade_menu_status == "upgrades_error" then
		wh_fleetcommand:fc_menu_clear()
		self:fc_menu_add_info("e_upgrade_msg", "Not enough artifacts!",1)
	elseif fc.upgrade_menu_status == "upgrades_ok" then
		wh_fleetcommand:fc_menu_clear()
		self:fc_menu_add_info("e_upgrade_msg", "Upgrade deployed!",1)
	elseif fc.upgrade_menu_status == "undocked" then
		wh_fleetcommand:fc_menu_clear()
		fc.upgrade_menu_status = nil
		fc.upgrade_menu_stack = {}
		self:fc_menu_add_info("e_upgrade_msg", "Ship is no longer docked!",1)
	elseif fc.upgrade_menu_status == "resource" then
		local resource = fc.upgrade_selected_resource
		local amount = fc:getResourceAmount(resource)
		self:fc_menu_add_info("e_upgrade_name", resource..":",2)
		self:fc_menu_add_info("e_upgrade_details", fc:getResourceDescription(resource),3)
		if amount >= 0 then
			self:fc_menu_add_info("e_upgrade_cost", "You already have this upgrade.",4)
		else
			local ship = fc.upgrade_selected_ship
			if ship ~= nil then
		   		if ship:isValid() and ship:isDocked(fc) then
					self:fc_menu_add_info("e_upgrade_cost", "Deploying this upgrade for "..ship:getCallSign().." costs "..tostring(-amount).. " artifacts",4)
				else
					wh_fleetcommand:fc_menu_set_status("undocked")
				end
			else
				self:fc_menu_add_info("e_upgrade_cost", "Deploying this upgrade costs "..tostring(-amount).. " artifacts",4)
			end
			if -amount <= fc:getResourceAmount("Artifacts") then
				self:fc_menu_add_button("e_buy", "Deploy!", function()
					local ship = fc.upgrade_selected_ship
					if ship ~= nil then
						if (not ship:isValid()) or (not ship:isDocked(fc)) then
							wh_fleetcommand:fc_menu_set_status("undocked")
							return
						end
					end
					if fc:tryDecreaseResourceAmount("Artifacts", -amount) then
						wh_fleetcommand:fc_menu_set_status("upgrades_ok")
						wh_fleetcommand.upgrade(resource)
					else
						wh_fleetcommand:fc_menu_set_status("upgrades_error")
					end
					wh_fleetcommand:fc_menu_clear()
				end,10)
			end
		end

	end
	if fc.upgrade_menu_status ~= nil then
		self:fc_menu_add_button("e_back", "Back", function() 
			fc.upgrade_menu_status = table.remove(fc.upgrade_menu_stack)	-- pop
			wh_fleetcommand:fc_menu_clear()
		end,30)
	end
end

function wh_fleetcommand:update_docked_ship(delta, ps)
	local fc = self.station
	if not vf_bescheid:woas_scho("with_artifacts") then	-- TODO, what about Campaign Artifacts
		vf_bescheid:sag_bescheid("docked_with_fc", {
			callsign=ps:getCallSign(),
			artifacts=ps:getResourceAmount("Artifacts"),
		})
	end

	-- Repair crew
	if fc:getResourceAmount("Medical Bay") > 0 then
		local max_repair_crew = ps.maxRepairCrew
		if max_repair_crew == nil then
			if ps:getHullMax() < 100 then
				max_repair_crew = 1
			else
				max_repair_crew = 3
			end
			ps.maxRepairCrew = max_repair_crew
		end
		if ps:getRepairCrewCount() < max_repair_crew then
			if ps.docked_time >= 10 then
				ps:setRepairCrewCount(ps:getRepairCrewCount()+1)
				ps.docked_time = 0
			end
		end
	end
	-- Repair systems (primary and secondary)
	if fc:getResourceAmount("Systems Repair Drydock") > 0 then
		for idx, system in ipairs(SYSTEMS) do
			ps:setSystemHealth(system, ps:getSystemHealth() + delta)
		end
		if ps.damaged_secondary_systems ~= nil then
			for _,system in ipairs(ps.damaged_secondary_systems) do
				if system == "probe" then
					ps:setCanLaunchProbe(true)
				elseif system == "hack" then
					ps:setCanHack(true)
				elseif system == "scan" then
					ps:setCanScan(true)
				elseif system == "combat_maneuver" then
					ps:setCanCombatManeuver(true)
				elseif system == "self_destruct" then
					ps:setCanSelfDestruct(true)
				end
			end
			ps.damaged_secondary_systems = {}
		end
	end
	-- Refill Coolant
	if fc:getResourceAmount("Coolant Refill Tanks") > 0 then
		if ps:getMaxCoolant() < 10 then
			ps:setMaxCoolant(math.min(ps:getMaxCoolant() + delta/10, 10))
		end
	end
	-- Refit drive
	if fc:getResourceAmount("Drive Refit Workshop") > 0 then
		if ps:hasWarpDrive() and not ps:hasJumpDrive() then
			customElements:addCustomButton(ps, "Engineering", "e_drive_refit", "Equip Jump Drive", function() 
				ps:setWarpDrive(false)
				ps:setJumpDrive(true)
			end, 10)
		end
		if ps:hasJumpDrive() and not ps:hasWarpDrive() then
			customElements:addCustomButton(ps, "Engineering", "e_drive_refit", "Equip Warp Drive", function() 
				ps:setWarpDrive(true)
				ps:setJumpDrive(false)
			end, 10)
		end
	end

	-- Artifact handling
	local amount = #ps:getResources("Campaign Artifacts") + ps:getResourceAmount("Artifacts")
	if amount > 0 then
		customElements:addCustomInfo(ps, "Relay", "e_artifact_counter", "Artifacts: "..amount, 8)
		customElements:addCustomButton(ps, "Relay", "e_artifact_send", "Transfer Artifacts", function() 
			wh_artifacts:transferArtifacts(ps, fc)
		end, 9)
	else
		customElements:removeCustom(ps, "e_artifact_counter")
		customElements:removeCustom(ps, "e_artifact_send")
	end
end

function wh_fleetcommand:gm_menu()
	local fc = self.station
	if fc == nil then
		addGMFunction("Create Fleetcommand", wh_fleetcommand.spawnFleetCommand)
	end
end
function wh_fleetcommand:update(delta)
	-- unregister status reciever if destroyed
	local fc = self.station
	if not fc:isValid() then
		sendMessageToCampaignServer("fleetcommand-deleted", "")
		self.station = nil
		plot_manager.gm_main_menu()
		return
	end

	fc.amount_last_docked_ships = #fc.docked_ships
	fc.docked_ships = {}

	for _,ps in ipairs(getActivePlayerShips()) do
		if ps:isValid() then
			if ps:isDocked(fc) then
				table.insert(fc.docked_ships,ps)
				if ps.docked_time == nil then
					ps.docked_time = 0
				end
				ps.docked_time = ps.docked_time + delta
				self:update_docked_ship(delta, ps)
			else -- not docked
				ps.docked_time = 0
				customElements:removeCustom(ps, "e_drive_refit")
				customElements:removeCustom(ps, "e_artifact_send")
				customElements:removeCustom(ps, "e_artifact_counter")
			end	
		end
	end

	if #fc.docked_ships ~= fc.amount_last_docked_ships then
		fc.ui_changed = true
	end
	self:update_fc_menu()

	-- jump handling
	--[[
	if fc:hasJumpDrive() then
		if distance(fc.last_pos_x, fc.last_pos_y, fc) > 10000 then
			-- jump happended
			fc.jumped_time = getScenarioTime()
		end
		fc.last_pos_x, fc.last_pos_y = fc:getPosition()
		if fc:getJumpDriveCharge() < 30000 then
			local delta = getScenarioTime() - fc.jumped_time	-- seconds
			-- 1U per min:
			delta = delta * 1000 / 60
			fc:setJumpDriveCharge(delta) -- max: 30000 (jump distance)
		end
	end--]]

end
