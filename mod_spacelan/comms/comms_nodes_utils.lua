require("comms/lib_comms_nodes.lua")

CommsNodeWaypointSelect = CommsNode:new{
	message = "Select a waypoint",
	_show_choices = function(self, env)
		log("wp-sc")
		for idx = 1, env.source:getWaypointCount() do
			assert(env)
			assert(idx)
			addCommsReply("Waypoint "..idx, self.with_waypoint:_as_comms_reply(env, idx))
		end
		CommsNodeWaypointSelect.super()._show_choices(self, env)	-- can add further choices
	end,
	test = function(self, env)
		env.waypoint_id = 1
		env.source.getWaypointCount = function(self) return 2 end
		env.source.getWaypoint = function(self, idx) return idx*2, idx*2+1 end
		local allow = self:_can_select(env)
		local line = self:select_choice_line(env)
		local msg, eff = self:select_message_and_effect(env)
		if eff ~= nil then
			eff(env)
		end
		self:_show_choices(env)
		self:_call(env)
		self:_as_comms_reply(env)(env.source, env.target)
		return allow, line, msg
	end
}
CommsNodeObjectSelect = CommsNode:new{
	message = "Select a target",
	_show_choices = function(self, env)
		log("os-sc")
		if env.abort_comms then
			return
		end
		for idx, obj in ipairs(env.source:getObjectsInRange(5000)) do
			if self:can_select_object(env, obj) and obj.getCallSign ~= nil then
				assert(obj)
				addCommsReply(obj:getCallSign(), self.with_object:_as_comms_reply(env, obj))
			end
		end
		CommsNodeObjectSelect.super()._show_choices(self, env)	-- can add further choices
	end,
	can_select_object = function(env,obj)
		-- dummy impl
		return false
	end,
	test = function(self, env)
		env.source.getObjectsInRange = function(self, _)
			return {
				{isEnemy = function() return true end, isValid = function() return true end},
				{isEnemy = function() return false end, isValid = function() return true end},
			}
		end
		self:_show_choices(env)
		self:_call(env)
		if env.testobj == nil then
			env.testobj = env.source.getObjectsInRange()[1]
		end
		self:_as_comms_reply(env)(env.source, env.target)
	end
}
CommsNodeEnemySelect = CommsNodeObjectSelect:new({
	can_select_object = function(self, env, obj)
		return obj ~= nil and obj:isValid() and obj:isEnemy(env.target)
	end,
	test = function(self, env)
		env.testobj = {isEnemy = function() return true end, isValid = function() return true end}
		CommsNodeObjectSelect.test(self,env)
	end
})

CommsNodeNotEnemySelect = CommsNodeObjectSelect:new({
	can_select_object = function(self, env, obj)
		return obj ~= nil and obj:isValid() and not obj:isEnemy(env.target)
	end,
	test = function(self, env)
		env.testobj = {isEnemy = function() return false end, isValid = function() return true end}
		CommsNodeObjectSelect.test(self,env)
	end
})


CommsNodeMsgByFaction = CommsNode:new()
function CommsNodeMsgByFaction:select_message_and_effect(env)
	local message, effect
	if env.target.orig_faction == nil then
		env.target.orig_faction = env.target:getFaction()
	end
	if self.message ~= nil then
		message = self:select_message(env.target.orig_faction, self.message)
		if message == nil then
			message = "...\n(no response)"
			print("could not find factional message for ", env.target.orig_faction, self.message)
		end
	else
		message = ""
	end
	if self.effect ~= nil then
		effect = self.effect
	else
		effect = function(env) end
	end
	return message, effect
end
function CommsNodeMsgByFaction:select_message(faction, id)
	if self.messages_by_faction[faction] ~= nil then
		if self.messages_by_faction[faction][id] ~= nil then
			return self.messages_by_faction[faction][id]
		end
	end
	return nil
end



-- checks if is docked before every interaction
CommsDocked = CommsNode:new():add_condition(function(env)
	return env.source:isDocked(env.target)
end)

-- overwrite or call with super:
--[[ Example:
	function DerivedFromCommsDocked:select_message_and_effect(env)
		local msg, eff = DerivedFromCommsDocked.super().select_message_and_effect(self,env)
		if msg == true then
			...
		end
		return mgs, eff
--]]
function CommsDocked:select_message_and_effect(env)
	if not env.source:isDocked(env.target) then
		return "undocked!", nil
	end
	return true, nil 
end

function CommsDocked:test(env)
	env.source.isDocked = function(self) return true end
	CommsDocked.super().test(self,env)

	env.source.isDocked = function(self) return false end
	CommsDocked.super().test(self,env)
end


-- checks if is undocked before every interaction
CommsUndocked = CommsNode:new():add_condition(function(env)
	return not env.source:isDocked()
end)

-- overwrite or call with super:
--[[ Example:
	function DerivedFromCommsUndocked:select_message_and_effect(env)
		local msg, eff = DerivedFromCommsUndocked.super().select_message_and_effect(self,env)
		if msg == true then
			...
		end
		return mgs, eff
--]]
function CommsUndocked:select_message_and_effect(env)
	if env.source:isDocked() then
		return "docked!", nil
	end
	return true, nil 
end

function CommsUndocked:test(env)
	env.source.isDocked = function(self) return false end
	CommsUndocked.super().test(self,env)

	env.source.isDocked = function(self) return true end
	CommsUndocked.super().test(self,env)
end

