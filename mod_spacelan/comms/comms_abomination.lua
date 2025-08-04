--[[
Classes:
---
Those classes are to be used as super-classes for your implementation

CommsAbomination - base class, can be used for anything
CommsEntryPoint - has function setAsCommsFunction(spaceObject), that sets this node as entry point for the dialog. Provides a "Back" dialog-option to go to this node.
CommsDocked - checks if source is docked TODO with target, abort otherwise
CommsUndocked - like docked, but the other way round.

--]]
CommsAbomination = {
	choices = {},
}

if TEST == true then
	CommsAbomination.instances = {}
	function CommsAbomination:test(env)
		assert (env)
		local allow = self:can_select(env)
		local line = self:select_choice_line(env)
		local msg, eff = self:select_message_and_effect(env)
		if eff ~= nil then
			eff(env)
		end
		return allow, line, msg
	end
end

--[[ internal stuff, do not bother with it --]]

-- is called from internal
-- accesses self.choices
function CommsAbomination:_show_choices(env)
	if env.abort_comms then
		return
	end
	for _,choice in ipairs(self.choices) do
		if choice:can_select(env) then
			addCommsReply(choice:select_choice_line(env), self:_select_choice(env, choice)
			)
		end
	end
end

-- is called from internal
-- could also be a function instead of a method
function CommsAbomination:_select_choice(env, choice)
	return function(source, target)
--		env.source = source 
--		env.target = target
		choice:_call(env)
	end
end

-- is called from internal
-- calls self:select_message_and_effect
function CommsAbomination:_call(env)
	local msg, effect = self:select_message_and_effect(env)
	setCommsMessage(msg)
	if effect ~= nil then
		effect(env)
	end
	--env.source.session = env	-- store session
	self:_show_choices(env)
end


--[[ Methods you should call but not overwrite --]]

-- call
-- creates a new subclass of CommsAbomination
function CommsAbomination:new(obj)
	obj = obj or {} -- create empty if none given 
	setmetatable(obj, self)
	self.__index = self
	obj.choices = {}	-- new one, not that of the super class
	obj.super = function() return self end
	if TEST then
		table.insert(self.instances, obj)
	end
	return obj
end

-- call
-- inserts a subclass of CommsAbomination as dialog option
function CommsAbomination:add_choice(node)
	table.insert(self.choices, node)
end



--[[ Methods your subclass of CommsAbomination should overwrite--]]

-- overwrite
-- returns if this dialog option is available and should be selectable as comms reply.
function CommsAbomination:can_select(env)
	return true
end

-- overwrite
-- returns a string, that is shown as commsReply message for the player to select. Most of the time this returns a static string, but you may randomise it or have some condition what to show. If not defined, it returns the default choice_line
function CommsAbomination:select_choice_line(env)
	if self.choice_line ~= nil then
		return self.choice_line
	else
		return ""
	end
end

-- overwrite
-- returns a string with a comms message to be shown and a function that is called after the message. The function may be empty.
function CommsAbomination:select_message_and_effect(env)
	-- we could write this shorter, but for test coverage check it is long
	local message, effect
	if self.message ~= nil then
		message = self.message
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



--[[ Derived classes --]]

-- implements setAsCommsFunction
CommsEntryPoint = CommsAbomination:new({choice_line = "Back"})

-- call
-- this sets this subclass of CommsAbomination as comms entry point for a SpaceObject
function CommsEntryPoint:setAsCommsFunction(obj, env)
	obj:setCommsFunction(self:_select_choice({}, self))
end

function CommsEntryPoint:test(env)
	self:setAsCommsFunction(env.target)
	CommsEntryPoint.super().test(self, env)	-- super must be called with a class name, not self.	
end

CommsRedirection = CommsAbomination:new()
function CommsRedirection:_call(env)
	-- select the first available choice and call it.
	-- this is usually done on entry nodes
	for _,choice in ipairs(self.choices) do
		if choice:can_select(env) then
			choice:_call(env)
		end
	end
	return nil
end

function CommsRedirection:test(env)
	CommsRedirection.super().test(self, env)
	self:_call(env)
end

CommsEntryRedirection = CommsEntryPoint:new()
CommsEntryRedirection._call = CommsRedirection._call
CommsEntryRedirection.test = CommsRedirection.test


-- checks if is docked before every interaction
CommsDocked = CommsAbomination:new()

function CommsDocked:can_select(env)
	return env.source:isDocked(env.target)
end

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
CommsUndocked = CommsAbomination:new()

function CommsUndocked:can_select(env)
	return not env.source:isDocked()
end

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

