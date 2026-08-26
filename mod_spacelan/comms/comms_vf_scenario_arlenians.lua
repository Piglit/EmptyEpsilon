
local ccc = common_comms_conditions

-- ============================================================================
-- Technology sharing
-- ============================================================================

comms_vf_station_arlenian = {
	upgrades = arrayShuffle({
		"Laser",
		"Schild",
		"Antrieb",
		"Manöver",
	}),
	upgrade_idx = 0,
}

function comms_vf_station_arlenian:select_upgrade()
	self.upgrade_idx = self.upgrade_idx + 1
	if self.upgrades[self.upgrade_idx] == nil then
		arrayShuffle(self.upgrades)	-- in place
		self.upgrade_idx = 1
	end
	return self.upgrades[self.upgrade_idx]
end

function comms_vf_station_arlenian:swap_objects(old, new)
	local swapx, swapy = old:getPosition()
	local swapRotate = old:getRotation()

	new:setPosition(swapx, swapy)
	new:setRotation(swapRotate)				--transfer orientation to NPC ship
	new:setCallSign(old:getCallSign())
	new:setFaction(old:getFaction())
	new:setScannedByFaction(old:getFaction(), true)
	new:setHull(old:getHull())
	new:setShields(old:getShieldLevel(0))	-- assume they have only one segment

	-- surroundings:
	for _,obj in ipairs(old:getObjectsInRange(30000)) do
		if (not new:isScannedBy(obj)) and old:isScannedBy(obj) then
			new:setScannedByFaction(obj:getFaction(), true)
		end
		if obj.getOrder~= nil and obj.getOrderTarget ~= nil and obj:getOrderTarget() == old then
			local order = obj:getOrder()
			if order == "Retreat" then
				obj:orderRetreat(new)
			elseif order == "Defend Target" then
				obj:orderDefendTarget(new)
			elseif order == "Attack" then
				obj:orderAttack(new)
			elseif order == "Dock" then
				obj:orderDock(new)
			end
			-- drop fly formation, since we don't get the formation parametes easily
		end
	end
end

function comms_vf_station_arlenian:change_station_to_mobile(station)
	local template = station:getTypeName() .. " - mobile"
	local new_cpu_ship = CpuShip()
	new_cpu_ship:setTemplate(template)
	self:swap_objects(station, new_cpu_ship)

	comms_vf_station.entry:set_as_comms_function(new_cpu_ship)
	new_cpu_ship.comms_data = station.comms_data
	new_cpu_ship.comms_data.gossip = nil

	-- Docking is disabled for now! So no docking services.
	station:destroy()	-- issue: this breaks the current comms session
	return new_cpu_ship
end

function comms_vf_station_arlenian:change_mobile_to_station(ship)
	local template = string.sub(ship:getTypeName(), 1, -10) -- remove " - mobile"
	local new_station = SpaceStation()
	new_station:setTemplate(template)
	self:swap_objects(ship, new_station)

	comms_vf_station.entry:set_as_comms_function(new_station)
	new_station.comms_data = ship.comms_data

	-- Docking is disabled for now! So no docking services.
	ship:destroy()
	return new_station
end

function comms_vf_station_arlenian.ensure_comms_data(env)
	if env.target.comms_data == nil then
		env.target.comms_data = {}
	end
	local comms_data = env.target.comms_data
	if comms_data._station_arlenian_init then
		return true
	end
	comms_data._station_arlenian_init = true
	comms_data.upgrade_to_offer = comms_vf_station_arlenian:select_upgrade()
	comms_data.upgrade_given_to = nil
	comms_data.escorted_by = nil
	comms_data.mother_grant_upgrades = {}
	comms_data.mother_grant_upgrades_to_players = {}	-- upgrade -> {ships}
	for __,upgrade in ipairs(comms_vf_station_arlenian.upgrades) do
		comms_data.mother_grant_upgrades_to_players[upgrade] = {}
	end
	if comms_vf_station_arlenian.is_arlenian_motherstation(env) then
		env.target.linked_motherstation = env.target
		comms_data.mother_modules = {}
	end
	if comms_data.friendlyness == nil then
		comms_data.friendlyness = math.random(1,100)
	end
	return true
end

function comms_vf_station_arlenian.is_arlenian_module(env)
	local typename = env.target:getTypeName()
	local modules = {"Arlenian Shipyard", "Arlenian Habitat", "Arlenian Hangar", "Arlenian Mining Station", "Arlenian Science Station"}
	for __, module in ipairs(modules) do
		if module == typename then
			return true
		end
		if module .. " - mobile" == typename then
			return true
		end
	end
	return false
end

function comms_vf_station_arlenian.is_arlenian_motherstation(env)
	return env.target:getTypeName() == "Arlenian Motherstation"
end
function comms_vf_station_arlenian.is_docked_with_arlenian_motherstation(env)
	local docked = env.target:getDockedWith()
	if docked ~= nil and docked:getTypeName() == "Arlenian Motherstation" then
		return true
	end
	return false
end



-- ============================================================================
-- Greeters
-- ============================================================================

comms_vf_station_arlenian.docked_greeting = CommsNodeGreeter:new({
--	message = "Docked Greeting",
	skip_in_back_stack = true,
	messages = {
		_("greeted-by-arlenian-docked", "Greetings, Captain.  We are pleased to welcome you and your crew to {target_callsign}.  We hope your stay will be comfortable, and that we may find opportunities for meaningful exchange."),
		_("greeted-by-arlenian-docked", "Welcome, Captain.  We recognize the significance of your arrival at {target_callsign}, and we are pleased to receive you.  Should there be anything you require, we will be glad to assist."),
		_("greeted-by-arlenian-docked", "Greetings, Captain.  It is good to see {source_callsign} safely arrived at {target_callsign}.  We appreciate the opportunity to speak with you and learn from your travels."),
		_("greeted-by-arlenian-docked", "Welcome to {target_callsign}, Captain.  We hope your journey was a peaceful one.  If there is anything we can do to make your time here more agreeable, please let us know."),
		_("greeted-by-arlenian-docked", "Greetings, Captain.  We welcome {source_callsign} to {target_callsign}.  May this visit prove useful to both of our peoples."),
		_("greeted-by-arlenian-docked", "Welcome, Captain.  Your arrival at {target_callsign} is appreciated.  We would be pleased to hear what brings you here and how we might be of assistance."),
		_("greeted-by-arlenian-docked", "Greetings, Captain.  We recognize {source_callsign}'s arrival and welcome you aboard {target_callsign}.  We hope there will be an opportunity for cooperation during your visit."),
		_("greeted-by-arlenian-docked", "Welcome, Captain.  It is a pleasure to receive you at {target_callsign}.  We understand that every journey has its purpose, and we are willing to hear yours."),
		_("greeted-by-arlenian-docked", "Greetings, Captain.  We are glad to see you safely docked.  Please tell us how we may assist you during your visit to {target_callsign}."),
		_("greeted-by-arlenian-docked", "Welcome, Captain.  We acknowledge your arrival aboard {target_callsign}.  If you wish to discuss your needs or intentions, we are listening."),
		_("greeted-by-arlenian-docked", "Greetings, Captain.  We recognize your arrival at {target_callsign}.  If there is a matter you wish to discuss, we are prepared to hear your perspective."),
		_("greeted-by-arlenian-docked", "Welcome, Captain.  {source_callsign} has arrived safely, and we acknowledge your presence.  Please tell us what brings you here."),
		_("greeted-by-arlenian-docked", "Greetings, Captain.  We understand that you have chosen to visit {target_callsign}.  We would prefer to begin with an understanding of your intentions."),
		_("greeted-by-arlenian-docked", "Welcome, Captain.  Your arrival is noted.  Whatever has brought {source_callsign} here, we believe it is better understood through discussion."),
		_("greeted-by-arlenian-docked", "Greetings, Captain.  We recognize that your visit to {target_callsign} may have a purpose of importance to you.  We are willing to discuss it."),
		_("greeted-by-arlenian-docked", "Captain, we acknowledge your arrival at {target_callsign}.  There may be matters between us that deserve attention.  Let us begin by understanding one another."),
		_("greeted-by-arlenian-docked", "Greetings, Captain.  We recognize your presence aboard {target_callsign}.  If there is disagreement between our peoples, we would rather understand its cause than allow it to deepen."),
		_("greeted-by-arlenian-docked", "Welcome, Captain.  Your arrival has given us reason for concern, but concern need not become hostility.  Tell us what you seek."),
		_("greeted-by-arlenian-docked", "Captain, we acknowledge your arrival.  We may not share the same understanding of recent events, but we are willing to hear your perspective."),
		_("greeted-by-arlenian-docked", "Greetings, Captain.  We recognize that our relationship has become difficult.  Even so, we believe there remains value in speaking openly."),
		_("greeted-by-arlenian-docked", "Captain, your arrival is not without consequence.  We ask only that you allow us to understand your intentions before either of our peoples takes further action."),
		_("greeted-by-arlenian-docked", "We acknowledge you, Captain.  There is considerable distance between our positions, but we do not consider understanding impossible.  Speak, and we will listen."),
		_("greeted-by-arlenian-docked", "Captain, we recognize your presence at {target_callsign}.  Our patience should not be mistaken for indifference, nor our desire for peace for weakness.  Tell us what you intend."),
		_("greeted-by-arlenian-docked", "Greetings, Captain.  Relations between us are strained, yet we remain willing to hear you.  If there is a peaceful path forward, we would prefer to find it together."),
	}
})
:add_condition(ccc.docked)
:add_condition(ccc.arlenian)


comms_vf_station_arlenian.undocked_greeting = CommsNodeGreeter:new({
--	message = "Undocked Greeting",
	skip_in_back_stack = true,
	messages = {
		_("greeted-by-arlenian-undocked", "Greetings, Captain.  This is {target_callsign}.  We welcome the opportunity to speak with you.  Please, go ahead."),
		_("greeted-by-arlenian-undocked", "Greetings, Captain.  {target_callsign} is listening.  We would be pleased to hear what you wish to discuss."),
		_("greeted-by-arlenian-undocked", "Captain, you are connected with {target_callsign}.  We recognize your request to speak, and we are listening."),
		_("greeted-by-arlenian-undocked", "This is {target_callsign}.  Greetings, Captain.  Please continue; we wish to understand what brings you to us."),
		_("greeted-by-arlenian-undocked", "Greetings, Captain.  {target_callsign} acknowledges your communication.  Please share what is on your mind."),
		_("greeted-by-arlenian-undocked", "Captain, we have received your communication.  We may have different perspectives on recent events, but we are willing to hear yours."),
		_("greeted-by-arlenian-undocked", "Greetings, Captain.  We recognize your attempt to reach us.  Please explain what you seek, and we will consider it carefully."),
		_("greeted-by-arlenian-undocked", "Captain, we are listening.  Relations between us have become difficult, but we do not believe that makes communication without value.  Please continue."),
		_("greeted-by-arlenian-undocked", "We have received your communication, Captain.  Our concerns are significant, but we remain willing to understand your position.  Speak."),
	},
})
:add_condition(ccc.undocked)
:add_condition(ccc.not_enemy_faction)
:add_condition(ccc.arlenian)

-- ============================================================================
-- Initial conversation
-- ============================================================================

comms_vf_station_arlenian.ask_for_upgrades = CommsRedirection:new({
	choice_line = _("Are you willing to share some of your technology with us?"),
})
:add_condition(ccc.docked)
:add_condition(ccc.arlenian)
:add_condition(function(env)
	return vf_upgrades ~= nil
end)
:add_test_setup(function(env)
	vf_upgrades = {
		set_player_ship_upgrade_level = function() end,
		get_player_ship_upgrade_level = function() return 0 end,
	}
	env.target.getTypeName = function() return "Arlenian Shipyard" end,
	comms_vf_station_arlenian.ensure_comms_data(env)
end)



-- ============================================================================
-- Station offers a randomly selected technology
-- ============================================================================

comms_vf_station_arlenian.test_upgrade_given = CommsNode:new({
	skip_in_back_stack = true,
	select_message = function(self,env)
		return string.format(_("We have already entrusted the vessel %s with an enhancement to its %s systems.\nWe are prepared to offer a more advanced form of that technology to a ship that helps us with a matter of importance."), env.target.comms_data.upgrade_given_to, env.target.comms_data.upgrade_to_offer)
	end,
})
:add_condition(comms_vf_station_arlenian.is_arlenian_module)
:add_condition(function(env)
	return env.target.comms_data.upgrade_given_to ~= nil
end)

comms_vf_station_arlenian.test_upgrade_available = CommsNode:new({
	skip_in_back_stack = true,
	select_message = function(self,env)
		return string.format(_("We are willing to entrust your people with an enhancement to %s systems.\nFor now, we are prepared to entrust this technology to only one vessel.\nYou may decide whether your ship should be the one to receive it, or whether another vessel would benefit more from this opportunity."), env.target.comms_data.upgrade_to_offer)
	end,
})
:add_condition(comms_vf_station_arlenian.is_arlenian_module)
:add_condition(function(env)
	-- The station has not yet provided a test upgrade.
	return env.target.comms_data.upgrade_given_to == nil
end)

comms_vf_station_arlenian.test_upgrade_confirm = CommsNode:new({
	skip_in_back_stack = true,
	choice_line = _("We would like you to install the technology on our ship."),
	select_message = function(self, env)
		return string.format(_("We have entrusted your vessel with our %s technology.\nYour Engineer may activate the upgrade at any time.\nWe ask only that you consider assisting us in return.\nIf you are willing, there is something you may be able to help us accomplish."), env.target.comms_data.upgrade_to_offer)
	end,
	effect = function(env)
		-- Give the randomly selected upgrade to the first ship that accepts.
		vf_upgrades:set_player_ship_upgrade_level(env.source, env.target.comms_data.upgrade_to_offer, 1)
		-- Record the ship/player that accepted the upgrade.
		-- This prevents any other ship from claiming this initial test upgrade.
		env.target.comms_data.upgrade_given_to = env.source:getCallSign()
		-- After receiving an upgrade enemies will attack here
		if avp_story ~= nil then
			avp_story:spawn_threat(env.target, env.source)
		end
	end,
})
:add_check(function(self, env)
	-- This ship is eligible to receive it.
	return vf_upgrades:get_player_ship_upgrade_level(env.source, env.target.comms_data.upgrade_to_offer) == 0,
	_("We recognize that your vessel already possesses this technology.\nIt would be better to entrust our contribution to a ship that does not yet possess it.")
end)
:add_check(function(self, env)
	-- The station has not yet provided a test upgrade.
	if env.target.comms_data.upgrade_given_to == nil then
		return true
	else
		return false, string.format(_("We have already entrusted this first implementation to the vessel %s.\nWe appreciate your interest, and we hope another opportunity for cooperation will arise."), env.target.comms_data.upgrade_given_to)
	end
end)
:add_test(function(self, env)
	env.target.comms_data.upgrade_given_to = "Spacy"
	self:_apply_checks(env)
end)

comms_vf_station_arlenian.test_upgrade_available:add_choice(comms_vf_station_arlenian.test_upgrade_confirm)


-- ============================================================================
-- Request for further cooperation
-- ============================================================================

comms_vf_station_arlenian.help_us = CommsNode:new({
	choice_line = _("What can we do to help?"),
	message = _("The Arlenian residing within this station has been separated from its people for some time.\nWe would like to reunite with an Arlenian Motherstation, where our knowledge and experience may once again become part of a greater whole.\nIf you are willing to assist us, we ask that you guide us to one."),
})

comms_vf_station_arlenian.help_us_accept = CommsNode:new({
	choice_line = _("We know where to find a Motherstation. Follow us."),
	message = _("We appreciate your willingness to help us.\nBefore we leave our current configuration, we would like to confirm that you wish us to accompany your vessel.\nIf you agree, we will reconfigure ourselves for travel and follow you to the Motherstation.\nWhile in travel configuration you will not be able to dock with us.\nTo enter travel configuration we will need to terminate this communication session."),
})
:add_condition(function(env)
	return avp_story and avp_story.found_motherstation == true
end)

comms_vf_station_arlenian.help_us:add_choice(comms_vf_station_arlenian.help_us_accept)
comms_vf_station_arlenian.test_upgrade_confirm:add_choice(comms_vf_station_arlenian.help_us)
comms_vf_station_arlenian.test_upgrade_given:add_choice(comms_vf_station_arlenian.help_us)

-- ============================================================================
-- Confirm conversion: station -> mobile
-- ============================================================================

comms_vf_station_arlenian.confirm_change_to_mobile = CommsNode:new({
	choice_line = _("Yes. Prepare to accompany us."),
	effect = function(env)
		env.source:commandUndock()
		env.target = comms_vf_station_arlenian:change_station_to_mobile(env.target)
		-- this terminates the comms session
		env.target:setWarpDrive(true)
		env.target:setWarpSpeed(200)
		env.target:setScannedByFaction(env.source:getFaction(), true)
		env.target:orderFlyFormation(env.source, -500, 0)
		env.target.comms_data.escorted_by = env.source
	end,
})
:add_check(function(self, env)
	-- The player is eligible to accept the escort mission.
	local following = env.target.comms_data.escorted_by
	if following == nil or not following:isValid() or following == env.source then
		return true
	end
	return false, string.format(_("We are already accompanying %s.\nWe would prefer to honor the commitment we have already made."), following:getCallSign())
end)
:add_test_setup(function(env)
	env.source.commandUndock = function(self) assert(self) return self end
	env.target.comms_data.escorted_by = env.source
	env.target.getRotation = function(self) assert(self); return 42 end
	env.target.destroy = function(self) assert(self); return nil end
end)
:add_test(function(self, env)
	env.target.comms_data.escorted_by = nil
	self:_call(env)
end)

comms_vf_station_arlenian.help_us_accept:add_choice(comms_vf_station_arlenian.confirm_change_to_mobile)


-- ============================================================================
-- Escort: station is following
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Order station to stop
-- ----------------------------------------------------------------------------

comms_vf_station_arlenian.escort_stop = CommsNode:new({
	choice_line = _("Stop here for now."),
	message = _("We understand, Captain.\nWe are stopping right here.\nBefore we return to our stationary configuration, we would like to confirm that you want us to do that.\nIn stationary configuration you will be able to dock with us again, but we will not be able to travel.\nWe can resume the journey later if you wish.\nTo enter stationary configuration, we will need to terminate this communication session for now."),
	effect = function(env)
		env.target:orderStandGround()
	end,
})
:add_condition(function(env)
	-- The station is currently following anyone. That anyone can also become invalid.
	-- So anyone can order that.
	return env.target.comms_data.escorted_by ~= nil
end)
:add_test_setup(function(env)
	env.target.getOrder = function() return "Fly in formation" end
end)

-- ============================================================================
-- Confirm conversion: mobile -> station
-- ============================================================================

comms_vf_station_arlenian.confirm_change_to_station = CommsNode:new({
	choice_line = _("Yes. Return to your stationary configuration."),
	effect = function(env)
		-- if someone else stops the station, reset the quest.
		-- now you need to dock to make them follow again.
		if env.target.comms_data.escorted_by ~= env.source then
			env.target.comms_data.escorted_by = nil
		end
		env.target = comms_vf_station_arlenian:change_mobile_to_station(env.target)
		-- terminate comms session
		if avp_story ~= nil then
			avp_story:spawn_threat(env.target, env.source)
		end
	end,
})

comms_vf_station_arlenian.escort_stop:add_choice(comms_vf_station_arlenian.confirm_change_to_station)

-- ============================================================================
-- Escort: resume following
-- ============================================================================

comms_vf_station_arlenian.escort_resume_from_mobile = CommsNode:new({
	choice_line = _("We are ready to continue. Resume following us."),
	message = _("Of course, Captain.\nWe are ready to resume our journey.\nWe will follow your vessel again and await your guidance."),
	effect = function(env)
		env.target:orderFlyFormation(env.source, -500, 0)
	end,
})
:add_condition(function(env)
	-- We have previously been stopped by the same player
	return env.target.typeName == "CpuShip" and
	env.target.comms_data.escorted_by == env.source and
	env.target.getOrder ~= nil and
	env.target:getOrder() ~= "Fly in formation"
end)

comms_vf_station_arlenian.escort_resume_from_stationary = CommsNode:new({
	choice_line = _("We are ready to continue. Resume following us."),
	message = _("Of course, Captain.\nWe are ready to resume our journey.\nWe will follow your vessel again and await your guidance.\n\nBefore we leave our current configuration, we would like to confirm that you wish us to accompany your vessel.\nIf you agree, we will reconfigure ourselves for travel and follow you to the Motherstation.\nWhile in travel configuration you will not be able to dock with us.\nTo enter travel configuration we will need to terminate this communication session."),
})
:add_condition(function(env)
	-- We have previously been stopped by the same player
	return env.target.typeName == "SpaceStation" and
	env.target.comms_data.escorted_by == env.source
end)

comms_vf_station_arlenian.escort_resume_from_stationary:add_choice(comms_vf_station_arlenian.confirm_change_to_mobile)


-- ============================================================================
-- Docking at the larger station
-- ============================================================================

comms_vf_station_arlenian.escort_dock = CommsNode:new({
	choice_line = _("The Motherstation is here. Dock with it."),
	message = _("We recognize the Motherstation ahead.\nWe will approach it carefully and prepare to join with our people.\nWe are grateful for the trust you have shown us, Captain.\nPlease speak with us again once our docking is complete."),
	effect = function(env)
		-- Tell the escorted station to dock at the selected larger station.
		local obj = env.args
		if obj ~= nil and
			obj:isValid() then
			env.target:orderDock(obj)
		end
	end,
})
:add_condition(function(env)
	-- The station is currently following the current player's ship.
	-- The station has not already been instructed to dock.
	return env.target.comms_data.escorted_by == env.source and
	env.target:getOrder() ~= "Dock"
end)
:add_condition(function(env)
	-- The escorted station is within the required range of the destination.
	for _, obj in ipairs(env.target:getObjectsInRange(5000)) do
		if obj:isValid() and obj.getTypeName ~= nil and obj:getTypeName() == "Arlenian Motherstation" then
			env.args = obj
			return true
		end
	end
end)
:add_test_setup(function(env)
	env.target.getOrder = function(self) return "roaming" end
	env.target.comms_data.escorted_by = env.source
	env.target.getObjectsInRange = function()
		return {
			{
				isValid = function() return true end,
				getTypeName = function() return "Arlenian Motherstation" end
			}
		}
	end
	env.args = env.target:getObjectsInRange()[1]
end)
:add_test(function(self, env)
end)



-- ============================================================================
-- Docking completed
-- ============================================================================

comms_vf_station_arlenian.docking_complete = CommsNode:new({
	choice_line = _("Have you finished docking?"),
	message = _("Yes, Captain.\nWe have completed the connection with the Motherstation.\nThe separation that brought us here is now behind us, and our knowledge has been reunited with our people.\nWe are grateful for the part you played in bringing us together.\nIf you agree, we will end this conversation for now and see us again on the Motherstation."),
})
:add_condition(function(env)
	-- The station is currently following the current player's ship.
	-- And is instructed to dock
	return env.target.comms_data.escorted_by == env.source and
	env.target:getOrder() == "Dock"
end)
:add_check(function(self, env)
	-- The station has successfully docked at the destination station.
	return comms_vf_station_arlenian.is_docked_with_arlenian_motherstation(env), _("We have not yet completed our connection with the Motherstation.\nPlease give us a little more time.")
end)
:add_test_setup(function(env)
	env.target.getDockedWith = function() return {
		isValid = function() return false end,
		getTypeName = function() return "Arlenian Motherstation" end,
	} end
	env.target.comms_data.escorted_by = env.source
	env.target.getOrder = function() return "Dock" end
end)
:add_test(function(self,env)
	env.target.getDockedWith = function() return {
		isValid = function() return true end,
		getTypeName = function() return "Arlenian Motherstation" end,
		comms_data = {},
	} end
	self:_call(env)

end)
-- ============================================================================
-- Confirm conversion: mobile -> docked
-- ============================================================================

comms_vf_station_arlenian.confirm_change_to_docked = CommsNode:new({
	choice_line = _("Yes, thank you. Goodbye."),
	effect = function(env)
		local station = env.target:getDockedWith()
		local old_target = env.target
		env.target = station
		comms_vf_station_arlenian.ensure_comms_data(env)
		env.target = old_target

		-- Mark the escort mission as completed.
		env.target.comms_data.escorted_by = nil
		-- Make the normal upgrade available to all eligible players.
		if not arrayContains(station.comms_data.mother_grant_upgrades, env.target.comms_data.upgrade_to_offer) then
			table.insert(station.comms_data.mother_grant_upgrades, env.target.comms_data.upgrade_to_offer)
		end
		-- make them a bit more friendly
		station.comms_data.friendlyness = station.comms_data.friendlyness + 10
		-- Enable the stronger variant for the escorting player.
		table.insert(station.comms_data.mother_grant_upgrades_to_players[env.target.comms_data.upgrade_to_offer], env.source)
		-- store docked station
		table.insert(station.comms_data.mother_modules, env.target)
		-- relink comms_data, change target
		env.target.linked_motherstation = station
--		env.target = comms_vf_station_arlenian:change_mobile_to_station(env.target) -- don't switch back, to prevent docking
		-- issue: breaks comms session!
		--env.target.comms_data = station.comms_data  -- FIXME not working so good
		env.target:setCommsFunction(nil):setCommsScript("")	-- hotfix, disable comms completely
		-- After receiving an upgrade enemies will attack here
		if avp_story ~= nil then
			avp_story:spawn_threat(station, env.source)
		end
		if avp_enemies ~= nil then
			local x,y = station:getPosition()
			local positions = {
				{x+1000, y},
				{x, y+1000},
				{x-1000, y},
				{x, y-1000},
			}
			EnemyModuleArlenians:spawnSpecialist(positions, 50 * #station.comms_data.mother_modules)
		end
	end,
})


-- ============================================================================
-- Technology available at motherstation after successful docking
-- ============================================================================

-- ----------------------------------------------------------------------------
-- No upgrades
-- ----------------------------------------------------------------------------

comms_vf_station_arlenian.no_upgrades = CommsNode:new({
	message = _("Our people have shared much knowledge with the civilizations of this region, and we remain willing to do so.\nAt present, however, no new technology has been entrusted to this Motherstation for wider sharing.\nPerhaps another Arlenian station still carries knowledge that could be brought here."),
})
:add_condition(function(env)
	return comms_vf_station_arlenian.is_arlenian_motherstation(env) and
	#env.target.comms_data.mother_grant_upgrades == 0
end)
:add_test_setup(function(env)
	env.target.getTypeName = function() return "Arlenian Motherstation" end
end)


-- ----------------------------------------------------------------------------
-- Normal upgrades
-- ----------------------------------------------------------------------------

comms_vf_station_arlenian.normal_upgrade = CommsNode:new({
	message = _("Your cooperation has helped some of our people return to the greater Arlenian community.\nIn recognition of that cooperation, we are prepared to make the following knowledge available to your people.\nUse it wisely, and may it serve as another bridge between our civilizations."),
	_show_choices = function(self, env)
		for idx, upgrade in ipairs(env.target.comms_data.mother_grant_upgrades) do
			if arrayContains(env.target.comms_data.mother_grant_upgrades_to_players[upgrade], env.source) then
				addCommsReply(
					string.format(_("Install the %s technology on our ship."), upgrade),
					self.with_upgrade:_as_comms_reply(env, {upgrade, 2})	-- level 2
				)
			else
				addCommsReply(
					string.format(_("Install the %s technology on our ship."), upgrade),
					self.with_upgrade:_as_comms_reply(env, {upgrade, 1})
				)
			end
		end
		comms_vf_station_arlenian.normal_upgrade.super()._show_choices(self, env)
	end,
	add_choice_to_all_children = function(self, node, recursive, add_to_self)
		if self.with_upgrade ~= nil then
			self.with_upgrade:add_choice(node)
			if recursive then
				self.with_upgrade:add_choice_to_all_children(node, recursive)
			end
		end
		if add_to_self then
			self:add_choice(node)
		end
		return self
	end,
	with_upgrade = CommsNode:new({
		select_message = function(self, env)
			local upgrade, level = table.unpack(env.args)
			if level == 2 then
				return string.format(_("You did more than accept our technology, Captain.\nYou helped us reunite with our people, and you honored the trust we placed in you.\nIn recognition of this, we will entrust your vessel with a more advanced expression of our %s technology.\nThis is a gift we will offer to you only once.\nOther ships of your people may still receive the more accessible form of this knowledge here."), upgrade)
			else
				return string.format(_("We are pleased to share our %s technology with your vessel.\nWe offer it in the hope that it will benefit your people and deepen the understanding between our civilizations."), upgrade)
			end
		end,
		effect = function(env)
			local upgrade, level = table.unpack(env.args)
			-- Give the upgrade to this ship.
			vf_upgrades:set_player_ship_upgrade_level(env.source, upgrade, level)
		end,
	}):add_check(function(self, env)
		local upgrade, level = table.unpack(env.args)
		-- This ship is eligible to receive it.
		return vf_upgrades:get_player_ship_upgrade_level(env.source, upgrade) < level,
		_("We recognize that your vessel already possesses this level of the technology.\nThere is no need for us to duplicate what you already have.")
	end):add_test_setup(function(env)
		env.args = {"Laser", 1}
	end):add_test(function(self,env)
		env.args = {"Antrieb", 2}
		self:_call(env)
	end),
})
:add_condition(function(env)
	return comms_vf_station_arlenian.is_arlenian_motherstation(env) and
	#env.target.comms_data.mother_grant_upgrades > 0
end)
:add_test_setup(function(env)
	env.target.comms_data.mother_grant_upgrades = {"Laser", "Antrieb"}
end)
:add_test(function(self,env)

	env.target.comms_data.mother_grant_upgrades_to_players["Laser"] = {env.source}
	self:_show_choices(env)
end)


-- ============================================================================
-- Upgrade from other Arlenian stations
-- ============================================================================
comms_vf_station_arlenian.unconditional_upgrade = CommsNode:new({
	select_message = function(self,env)
		return string.format(_("We are willing to give you an upgrade to your %s systems.\nWe are willing to give this upgrade to all %s ships that come by and dock."), env.target.comms_data.upgrade_to_offer, env.source:getFaction())
	end,
})
:add_condition(function(env)
	return (not comms_vf_station_arlenian.is_arlenian_module(env))
	and (not comms_vf_station_arlenian.is_arlenian_motherstation(env))
end)

comms_vf_station_arlenian.unconditional_upgrade_confirm = CommsNode:new({
	choice_line = _("Install the upgrade to our ship"),
	select_message = function(self, env)
		return string.format(_("Installed %s upgrade to your ship."), env.target.comms_data.upgrade_to_offer)
	end,
	effect = function(env)
		-- Give the randomly selected upgrade to the first ship that accepts.
		vf_upgrades:set_player_ship_upgrade_level(env.source, env.target.comms_data.upgrade_to_offer, 1)
		-- After receiving an upgrade enemies will attack here
		if avp_story ~= nil then
			avp_story:spawn_threat(env.target, env.source)
		end
	end,
})
:add_check(function(self, env)
	-- This ship is eligible to receive it.
	return vf_upgrades:get_player_ship_upgrade_level(env.source, env.target.comms_data.upgrade_to_offer) == 0,
	_("You already have that kind of upgrade installed on your ship.")
end)

comms_vf_station_arlenian.unconditional_upgrade:add_choice(comms_vf_station_arlenian.unconditional_upgrade_confirm)


-- ============================================================================
-- Main tree
-- ============================================================================

comms_vf_station_arlenian.escort = CommsRedirection:new({})
:add_condition(ccc.arlenian)
:add_condition(comms_vf_station_arlenian.is_arlenian_module)
comms_vf_station_arlenian.escort:add_choice(comms_vf_station_arlenian.docking_complete)
comms_vf_station_arlenian.escort:add_choice(comms_vf_station_arlenian.escort_dock)
comms_vf_station_arlenian.escort:add_choice(comms_vf_station_arlenian.escort_resume_from_stationary)
comms_vf_station_arlenian.escort:add_choice(comms_vf_station_arlenian.escort_resume_from_mobile)
comms_vf_station_arlenian.escort:add_choice(comms_vf_station_arlenian.escort_stop)


comms_vf_station_arlenian.ask_for_upgrades:add_choice(comms_vf_station_arlenian.test_upgrade_given)
comms_vf_station_arlenian.ask_for_upgrades:add_choice(comms_vf_station_arlenian.test_upgrade_available)
comms_vf_station_arlenian.ask_for_upgrades:add_choice(comms_vf_station_arlenian.no_upgrades)
comms_vf_station_arlenian.ask_for_upgrades:add_choice(comms_vf_station_arlenian.normal_upgrade)
comms_vf_station_arlenian.ask_for_upgrades:add_choice(comms_vf_station_arlenian.unconditional_upgrade)

comms_vf_station_arlenian.escort:add_choice_to_all_children(CommsBack, true, true)
comms_vf_station_arlenian.ask_for_upgrades:add_choice_to_all_children(CommsBack, true, true)

-- after back, because this one should not have a back button:
comms_vf_station_arlenian.docking_complete:add_choice(comms_vf_station_arlenian.confirm_change_to_docked)

comms_vf_station.automatic.ensure_comms_data:add_comms_data_initialiser_function(comms_vf_station_arlenian.ensure_comms_data)
comms_vf_station.main:add_choice(comms_vf_station_arlenian.ask_for_upgrades)
comms_vf_station.main:add_choice(comms_vf_station_arlenian.escort)

comms_vf_station.automatic.greeter:add_choice(comms_vf_station_arlenian.undocked_greeting, 1)
comms_vf_station.automatic.greeter:add_choice(comms_vf_station_arlenian.docked_greeting, 1)
