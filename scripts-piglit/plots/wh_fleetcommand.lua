--[[ Spawns and manages the Fleet Command station
-- Upgrades allow to repair ships
-- Depends on: artifacts
-- Defines: starting position of the fleet command station
--]]
wh_fleetcommand = {}

require "ee.lua"
require "utils.lua"

function wh_fleetcommand:init()
	self.station = nil
	wh_fleetcommand.upgrades_done = 0	-- if station gets destroyed, the respawned one will get a number of artifacts, matching the amount of upgrades.
	self:spawnFleetCommand()
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
	local posx, posy = -280000, 0
	local fc = PlayerSpaceship():setTemplate("Targaryen"):setCallSign("Der Ball"):setPosition(posx, posy)
	fc:setJumpDrive(false):setWeaponTubeCount(0):setWeaponStorageMax("Homing", 0):setWeaponStorage("Homing", 0):setShieldsMax():setMaxScanProbeCount(0)
	fc:setCanLaunchProbe(false):setCanHack(false):setCanScan(false):setCanSelfDestruct(false)
	for n=0,4 do
		fc:setBeamWeapon(n, 90,  n * 90, 0, 6, 5)
	end

	fc:setSharesEnergyWithDocked(false):setRestocksScanProbes(false):setRepairDocked(false):setRestocksMissilesDocked("none")
	fc:setResourceAmount("Artifacts", wh_fleetcommand.upgrades_done)
	fc:setResourceDescription("Artifacts", "You can spend Artifacts for upgrades")

	-- Docking services
	local name = "Energy Coupling"
	fc:setResourceAmount(name, -1)
	fc:setResourceCategory(name, "Dock Upgrades")
	fc:setResourceDescription(name, "Allows the station to share energy with docked ships.")
	name = "Hull Repair Scaffold"
	fc:setResourceAmount(name, -1)
	fc:setResourceCategory(name, "Dock Upgrades")
	fc:setResourceDescription(name, "Allows the station to repair the hull of docked ships.")
	name = "Science Probe Factory"
	fc:setResourceAmount(name, -2)
	fc:setResourceCategory(name, "Dock Upgrades")
	fc:setResourceDescription(name, "Allows the station to restock docked ships with probes.")
	name = "Torpedo Armory"
	fc:setResourceAmount(name, -3)
	fc:setResourceCategory(name, "Dock Upgrades")
	fc:setResourceDescription(name, "Allows the station to restock docked ships with torpedos.")
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
	fc:setResourceDescription(name, "Allows docked ships to chance their drive.")

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

	-- Ship Upgrades
	name = "Station Command Team"
	fc:setResourceAmount(name, -2)
	fc:setResourceCategory(name, "Ship Upgrades")
	fc:setResourceDescription(name, "Allows the ship to make neutral stations friendly.")
	name = "Station Boarding Pod"
	fc:setResourceAmount(name, -2)
	fc:setResourceCategory(name, "Ship Upgrades")
	fc:setResourceDescription(name, "Allows the ship to make enemy stations neutral.")
	name = "Diplomatic Crew"
	fc:setResourceAmount(name, -1)
	fc:setResourceCategory(name, "Ship Upgrades")
	fc:setResourceDescription(name, "Allows the ship to make neutral ships friendly.")
	name = "Xenolinguistic Team"
	fc:setResourceAmount(name, -1)
	fc:setResourceCategory(name, "Ship Upgrades")
	fc:setResourceDescription(name, "Allows the ship to make Kraylor ships neutral.")

	wh_fleetcommand.station = fc
	wh_fleetcommand.upgrades_done = 0	-- if station gets destroyed, the respawned one will get a number of artifacts, matching the amount of upgrades of the old station.

	fc.last_pos_x, fc.last_pos_y = fc:getPosition()
	fc.jumped_time = 0
	fc.exclude_from_health_check = true
	sendMessageToCampaignServer("fleetcommand-spawned", fc:getCallSign())	-- notify campaign server on where the fleet command is and what it's name is.
end


function wh_fleetcommand.upgrade(resource)
	local fc = wh_fleetcommand.station
	local ship = fc.upgrade_selected_ship	-- nil if upgrade is not ship secific
	if resource == "Energy Coupling" then
		fc:setSharesEnergyWithDocked(true)
	elseif resource == "Hull Repair Scaffold" then
		fc:setRepairDocked(true)
	elseif resource == "Science Probe Factory" then
		fc:setRestocksScanProbes(false)
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
	end
	if ship ~= nil then	-- ship specific
		ship:setResourceAmount(resource, 1)
		if ship.fc_upgrades_done == nil then
			ship.fc_upgrades_done = 0
		end
		ship.fc_upgrades_done = ship.fc_upgrades_done + 1
	else	-- upgrade for station
		fc:setResourceAmount(resource, 1)
		wh_fleetcommand.upgrades_done = wh_fleetcommand.upgrades_done + 1	-- unused
	end

end

function wh_fleetcommand:update(delta)
	-- unregister status reciever if destroyed
	local fc = self.station
	if fc == nil then
		removeGMFunction("Create Fleetcommand")
		addGMFunction("Create Fleetcommand", wh_fleetcommand.spawnFleetCommand)
		return
	end
	if not fc:isValid() then
		sendMessageToCampaignServer("fleetcommand-deleted")
		self.station = nil
		return
	end
	fc.docked_ships = {}

	for _,ps in ipairs(getActivePlayerShips()) do
		if ps:isValid() then
			if ps:isDocked(fc) then
				table.insert(fc.docked_ships,ps)
				ps.docked_time = ps.docked_time + delta

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
								p:setCanLaunchProbe(false)
							elseif system == "hack" then
								p:setCanHack(false)
							elseif system == "scan" then
								p:setCanScan(false)
							elseif system == "combat_maneuver" then
								p:setCanCombatManeuver(false)
							elseif system == "self_destruct" then
								p:setCanSelfDestruct(false)
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
						ps:addCustomButton("Engineering", "e_drive_refit", "Equip Jump Drive", function() 
							ps:setWarpDrive(false)
							ps:setJumpDrive(true)
						end)
						ps:addCustomButton("Engineering+", "e_drive_refit+", "Equip Jump Drive", function() 
							ps:setWarpDrive(false)
							ps:setJumpDrive(true)
						end)
					end
					if ps:hasJumpDrive() and not ps:hasWarpDrive() then
						ps:addCustomButton("Engineering", "e_drive_refit", "Equip Warp Drive", function() 
							ps:setWarpDrive(true)
							ps:setJumpDrive(false)
						end)
						ps:addCustomButton("Engineering+", "e_drive_refit+", "Equip Warp Drive", function() 
							ps:setWarpDrive(true)
							ps:setJumpDrive(false)
						end)
					end
				end

				-- Artifact handling
				wh_artifacts:transferArtifacts(ps, fc)
			else -- not docked
				ps.docked_time = 0
				ps:removeCustom("e_drive_refit")
			end	
		end
	end

	-- jump handling
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
	end

	-- update handling
	fc:addCustomInfo("Engineering+", "e_Artifacts_name", "Artifacts: "..tostring(fc:getResourceAmount("Artifacts")),0)
	if fc.upgrade_menu_status == nil then
		fc:addCustomInfo("Engineering+", "e_Artifacts_descr", fc:getResourceDescription("Artifacts"),1)
		fc:addCustomButton("Engineering+", "e_upgrades_dock", "Dock upgrades", function() 
			fc.upgrade_menu_status = "upgrades_dock"
			fc:removeCustom("e_upgrades_dock")
			fc:removeCustom("e_upgrades_station")
			fc:removeCustom("e_upgrades_ship")
			fc:removeCustom("e_Artifacts_descr")
		end,10)
		fc:addCustomButton("Engineering+", "e_upgrades_station", "Station upgrades", function() 
			fc.upgrade_menu_status = "upgrades_station"
			fc:removeCustom("e_upgrades_dock")
			fc:removeCustom("e_upgrades_station")
			fc:removeCustom("e_upgrades_ship")
			fc:removeCustom("e_Artifacts_descr")
		end,11)
		fc:addCustomButton("Engineering+", "e_upgrades_ship", "Ship upgrades", function() 
			fc.upgrade_menu_status = "upgrades_ship"
			fc:removeCustom("e_upgrades_dock")
			fc:removeCustom("e_upgrades_station")
			fc:removeCustom("e_upgrades_ship")
			fc:removeCustom("e_Artifacts_descr")
		end,12)
	elseif fc.upgrade_menu_status == "upgrades_dock" then
		fc:addCustomInfo("Engineering+", "e_Artifacts_descr", "Select an upgrade to show details:",1)
		for _,resource in ipairs(fc:getResources("Dock Upgrades")) do
			local amount = fc:getResourceAmount(resource)
			if amount < 0 then
				fc:addCustomButton("Engineering+", resource, resource .. " (" .. tostring(-amount) .. ")", function()
					fc.last_upgrade_menu = fc.upgrade_menu_status
					fc.upgrade_menu_status = resource
					for _,resource in ipairs(fc:getResources("Dock Upgrades")) do
						fc:removeCustom(resource)
					end
					fc:removeCustom("e_Artifacts_descr")
					fc:removeCustom("e_back")
				end,20)
			end
		end
		fc:addCustomButton("Engineering+", "e_back", "Cancel", function() 
			for _,resource in ipairs(fc:getResources("Dock Upgrades")) do
				fc:removeCustom(resource)
			end
			fc.upgrade_menu_status = nil
			fc:removeCustom("e_Artifacts_descr")
			fc:removeCustom("e_back")
		end,30)
	elseif fc.upgrade_menu_status == "upgrades_station" then
		fc:addCustomInfo("Engineering+", "e_Artifacts_descr", "Select an upgrade to show details:",1)
		for _,resource in ipairs(fc:getResources("Station Upgrades")) do
			local amount = fc:getResourceAmount(resource)
			if amount < 0 then
				fc:addCustomButton("Engineering+", resource, resource .. " (" .. tostring(-amount) .. ")", function()
					fc.last_upgrade_menu = fc.upgrade_menu_status
					fc.upgrade_menu_status = resource
					for _,resource in ipairs(fc:getResources("Station Upgrades")) do
						fc:removeCustom(resource)
					end
					fc:removeCustom("e_Artifacts_descr")
					fc:removeCustom("e_back")
				end,20)
			end
		end
		fc:addCustomButton("Engineering+", "e_back", "Cancel", function() 
			for _,resource in ipairs(fc:getResources("Station Upgrades")) do
				fc:removeCustom(resource)
			end
			fc.upgrade_menu_status = nil
			fc:removeCustom("e_Artifacts_descr")
			fc:removeCustom("e_back")
		end,30)
	elseif fc.upgrade_menu_status == "upgrades_ship" then
		if #fc.docked_ships == 0 then
			fc:addCustomInfo("Engineering+", "e_Artifacts_descr", "No ships are currently docked.",1)
		else
			fc:addCustomInfo("Engineering+", "e_Artifacts_descr", "Select a ship for upgrades:",1)
		end
		fc.last_docked_ships = {}
		fc.upgrade_selected_ship = nil
		for _,ship in ipairs(fc.docked_ships) do
			shipname = ship:getCallSign()
			table.insert(fc.last_docked_ships, shipname)
			fc:addCustomButton("Engineering+", shipname, shipname, function()
				fc.last_upgrade_menu = fc.upgrade_menu_status
				fc.upgrade_menu_status = "ship"
				fc.upgrade_selected_ship = ship
				for _,shipname in ipairs(fc.last_docked_ships) do
					fc:removeCustom(shipname)
				end
				fc:removeCustom("e_Artifacts_descr")
				fc:removeCustom("e_back")
			end,20)
		end
		fc:addCustomButton("Engineering+", "e_back", "Cancel", function() 
			for _,shipname in ipairs(fc.last_docked_ships) do
				fc:removeCustom(shipname)
			end
			fc.upgrade_menu_status = nil
			fc:removeCustom("e_Artifacts_descr")
			fc:removeCustom("e_back")
		end,30)
	elseif fc.upgrade_menu_status == "ship" then
		local ship = fc.upgrade_selected_ship
		fc:addCustomInfo("Engineering+", "e_Artifacts_descr", "Select an upgrade for "..ship:getCallSign().." to show details:",1)
		for _,resource in ipairs(fc:getResources("Ship Upgrades")) do
			local value = fc:getResourceAmount(resource)
			local amount = ship:getResourceAmount(resource)
			if amount <= 0 then
				fc:addCustomButton("Engineering+", resource, resource .. " (" .. tostring(-value) .. ")", function()
					fc.last_upgrade_menu = ship:getCallSign()
					fc.upgrade_menu_status = resource
					for _,resource in ipairs(fc:getResources("Ship Upgrades")) do
						fc:removeCustom(resource)
					end
					fc:removeCustom("e_Artifacts_descr")
					fc:removeCustom("e_back")
				end,20)
			end
		end
		fc:addCustomButton("Engineering+", "e_back", "Cancel", function() 
			for _,resource in ipairs(fc:getResources("Ship Upgrades")) do
				fc:removeCustom(resource)
			end
			fc.upgrade_menu_status = "upgrades_ship"
			fc.upgrade_selected_ship = nil
			fc:removeCustom("e_Artifacts_descr")
			fc:removeCustom("e_back")
		end,30)

	elseif fc.upgrade_menu_status == "upgrades_error" then
		fc:addCustomInfo("Engineering+", "e_upgrade_msg", "Not enough artifacts!",1)
		fc:addCustomButton("Engineering+", "e_back", "Back", function() 
			fc.upgrade_menu_status = nil 
			fc.upgrade_selected_ship = nil
			fc:removeCustom("e_upgrade_msg")
			fc:removeCustom("e_back")
		end,10)
	elseif fc.upgrade_menu_status == "upgrades_ok" then
		fc:addCustomInfo("Engineering+", "e_upgrade_msg", "Upgrade deployed!",1)
		fc:addCustomButton("Engineering+", "e_back", "Back", function() 
			fc.upgrade_menu_status = nil
			fc.upgrade_selected_ship = nil
			fc:removeCustom("e_upgrade_msg")
			fc:removeCustom("e_back")
		end,10)
	else 
		local resource = fc.upgrade_menu_status
		local amount = fc:getResourceAmount(resource)
		fc:addCustomInfo("Engineering+", "e_upgrade_name", resource..":",2)
		fc:addCustomInfo("Engineering+", "e_upgrade_detais", fc:getResourceDescription(resource),3)
		if amount >= 0 then
			fc:addCustomInfo("Engineering+", "e_upgrade_cost", "You already have this upgrade.",4)
		else
			if fc.upgrade_selected_ship ~= nil then
				fc:addCustomInfo("Engineering+", "e_upgrade_cost", "Deploying this upgrade for "..fc.upgrade_selected_ship:getCallSign().." costs "..tostring(-amount).. " artifacts",4)
			else
				fc:addCustomInfo("Engineering+", "e_upgrade_cost", "Deploying this upgrade costs "..tostring(-amount).. " artifacts",4)
			end
			if -amount <= fc:getResourceAmount("Artifacts") then
				fc:addCustomButton("Engineering+", "e_buy", "Deploy!", function()
					if fc:tryDecreaseResourceAmount("Artifacts", -amount) then
						fc.upgrade_menu_status = "upgrades_ok"
						wh_fleetcommand.upgrade(resource)
					else
						fc.upgrade_menu_status = "upgrades_error"
					end
					fc:removeCustom("e_upgrade_name")
					fc:removeCustom("e_upgrade_detais")
					fc:removeCustom("e_upgrade_cost")
					fc:removeCustom("e_buy")
					fc:removeCustom("e_back")
				end,10)
			end
		end
		fc:addCustomButton("Engineering+", "e_back", "Back", function() 
			fc.upgrade_menu_status = fc.last_upgrade_menu
			fc:removeCustom("e_upgrade_name")
			fc:removeCustom("e_upgrade_detais")
			fc:removeCustom("e_upgrade_cost")
			fc:removeCustom("e_buy")
			fc:removeCustom("e_back")
		end,20)
	end
end
