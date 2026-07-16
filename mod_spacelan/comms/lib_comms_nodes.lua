--[[
lib_comms_nodes
================
A node-based framework for creating scriptable communications dialogs.

WHY
---
The EE communications API normally uses setCommsMessage() and
addCommsReply() with nested functions. This works well for small dialogs,
but larger dialogs can become difficult to visualize and test.

This library represents a dialog as a tree of CommsNodes instead:

Node
+-- Choice A
¦   +-- Choice A1
¦   +-- Choice A2
+-- Choice B

The design has two main goals:
* The dialog structure should be easy to see and understand.
* Dialog behavior should be testable entirely from script with a mocked API.


BASIC CONCEPT
-------------
A CommsNode represents one step in a dialog.
A node can define:
* choice_line - the text shown as a selectable comms reply
* message     - the message shown after selecting the node
* conditions  - determine whether the node is available
* checks      - validate whether the operation may be performed
* effects     - perform the operation
* choices     - further CommsNodes available after this node

A typical dialog therefore looks like:
root
+-- "Ask about the mission"
|       +-- "Accept"
|       +-- "Decline"
+-- "Ask about the station"
+-- "Goodbye"


QUICK EXAMPLE
-------------
local root = CommsNode:new{
	message = "Welcome, captain."
}

root:add_choice(CommsNode:new{
	choice_line = "Who are you?",
	message = "I am a merchant."
})

root:add_choice(CommsNode:new{
	choice_line = "Goodbye.",
	message = "Goodbye."
})

root:set_as_comms_function(station)

When the station is hailed, `root` is called.

The player sees:

Welcome, captain.

> Who are you?
> Goodbye.

Selecting "Who are you?" calls that child node, which displays its
message and any choices attached to it.


NODE LIFECYCLE
-------------
When a node is called, the following happens:

1. Run checks
2. If all checks pass, run effects
3. If the effects succeed, select the message
4. Display the message
5. Display all selectable child nodes

Conditions are different from checks:

condition
Controls whether a node is visible/selectable.

check
Runs when the node is selected and can prevent its effects from being performed.
TODO: a condition can be re-evaluated as check, since it is not neccessarily true at that time.

effect
Performs the operation represented by the node.

For example:
condition -> "Is this service available?"
check     -> "Does the player have enough reputation?"
effect    -> "Take the reputation points"


CONDITIONS
----------
Conditions control visibility.

node:add_condition(function(env)
	return env.source:getFaction() == env.target:getFaction()
end)

A node is selectable only when all of its conditions return true.
Reusable conditions are provided in `common_comms_conditions`.


CHECKS AND EFFECTS
------------------
Checks and effects are functions receiving:

function(self, env)

They return:

true, nil

on success, or:

false, "Failure message"

on failure.

Checks run before effects.
Effects are only executed when all checks have succeeded.
This allows operations such as:

check  -> verify that the player has enough reputation
effect -> charge the reputation cost


NAVIGATION
----------
Nodes normally lead to their children.
Several specialized nodes provide other navigation patterns:

CommsRedirection
Automatically continues to the first selectable child.
Useful for conditional routing and nodes that should not require a visible player choice.

CommsPipeline
Calls all selectable children in sequence.
Useful for entry points and sequences of conditional effects.

CommsBack
Returns to the previous node.

Some navigation nodes are marked `skip_in_back_stack` so that they
do not become visible steps when using CommsBack.


REUSABLE NODE TYPES
-------------------
CommsNode uses Lua's prototype mechanism.
A node can therefore be used as a prototype for another node type:

MyNode = CommsNode:new{
...
}

MySpecialNode = MyNode:new{
...
}

Instances inherit methods and attributes from their prototype.
Override methods such as:

select_choice_line(env)
select_message(env)
_can_select(env)
_call(env)

when a node needs behavior different from the default implementation.

Most users only need `CommsNode:new{...}` and the `add_*` methods.
Prototype inheritance is primarily useful when creating reusable node types.


TESTING
-------
The library is designed so that dialogs and node types can be tested
without the real EE communications API.
Nodes can define:

add_test_setup(function(env)
...
end)

and:

add_test(function(self, env)
...
end)

Test setup prepares a mocked environment. Tests then exercise the node's behavior.

Inherited test setup and test functions are copied when creating a derived node.

When `TEST` is enabled, created node instances are registered in
`CommsNode_instances`, allowing the test suite to discover them.


BUILT-IN UTILITY NODES
----------------------
CommsNodeMsgByFaction
Selects messages according to the target's faction and supports
message placeholders such as {callsign}, {faction}, {sector}, etc.

CommsNodeWaypointSelect
Creates one reply for each waypoint.

CommsNodeObjectSelect
Creates replies for selectable objects within a range.
The subclasses define what objects are selectable.

CommsNodeEnemySelect
Object selection restricted to enemies.

CommsNodeNotEnemySelect
Object selection restricted to non-enemies.

CommsNodeIdentifiedSelect
Object selection restricted to objects scanned by the player.

CommsNodeUnidentifiedSelect
Object selection restricted to objects not scanned by the player.

CommsNodeServiceAvailable
Makes a node available only when a service is registered in `target.comms_data.service_available`.

CommsNodeServiceBuyable
Extends CommsNodeServiceAvailable with a reputation cost.


COMMON CONDITIONS
-----------------
`common_comms_conditions` contains reusable conditions together with their test setup.
Those are defined:

same_faction
friendly_faction
enemy_faction
neutral_faction
not_enemy_faction
scanned
unscanned
docked
undocked
disabled


API OVERVIEW
------------

CommsNode:new(obj)
Create a node or a derived node type.

CommsNode:add_choice(node)
Add a child dialog option.

CommsNode:add_choice_to_all_children(node, recursive)
Add a node to the children of all currently registered choices.
Note that only children are affected, that are registered at the time this function is called.

CommsNode:add_condition(condition)
Add a visibility condition.

CommsNode:add_check(check)
Add an execution check.

CommsNode:add_effect(effect)
Add an effect.

CommsNode:add_test_setup(test)
Add test setup code.

CommsNode:add_test(test)
Add a test.

CommsNode:set_as_comms_function(obj)
Register the node as the communications function of an object.
--]]



-- compatibility with older lua versions
if table.unpack == nil then
	-- luacov: disable
	table.unpack = unpack
	-- luacov: enable
end
if log == nil then
	log = print
end


if TEST then
	CommsNode_instances = {}
end
--[[
CommsNode - base class / default implementation
	Attributes:
		choice_line (string, optional):	choice_line is shown as commsReply
		message (string, optional): selecting this choice displays the message as commsMessage
		effect (function(env), optional): selecting this choice calls the function as effect
	Methods:
		new(table): table may contain the Attributes above
		add_choice(CommsNode): add a CommsNode as selectable choice below this node
		add_condition(function -> bool): add a function that returns if this node can be shown.
		add_test_setup(function): a function that is run before test()
		set_as_comms_function(SpaceObject): start with this node when that SpaceObject is hailed.
	User-Definable-Methods:
			These methods are optional and can be defined by the user.
			If not defined, the methods of a super class will be used.
			The default implementations returns the Attributes, if defined.
			Otherwise empty strings and effect-functions will be used.
		select_choice_line(env) -> string: returns a line that is shown as commsReply
--]]
CommsNode = {
	-- empty for new objects:
	_choices = {},		-- array of CommsNodes
	-- inherited to instances:
	_conditions = {},	-- control visibility. array functions() -> bool. Only if all eval to true, this node is shown
	_checks = {},		-- control execution. array functions() -> bool, string. Called in order. Abort if one returns false and return the string. Effects are only run if all checks pass.
	_effects = {},		-- perform transaction. array functions() -> bool, string. Called in order after checks have passed. Abort if one returns false and return the string.
	_test_setup_steps = {},	-- array of functions. Those are run before test() is run.
	_tests = {},		-- array of functions. Those are run in the test step. 
}


--[[ Methods you should call but not overwrite --]]


-- call from outside
-- creates a new subclass of CommsNode
function CommsNode:new(obj)
	obj = obj or {} -- create empty if none given 
	setmetatable(obj, self)	-- share the same metamethods, like __index
	self.__index = self	-- when an absent field is accessed, lookup using getmetatable().__index : so we look in the super class
	obj.super = function() return self end	-- self:super() returns the direct parent class
	-- tables
	obj._choices = {}	-- new one, not that of the super class
	-- use table.unpack to clone refs to the elements of the super class to the new object
	obj._conditions = {table.unpack(self._conditions)}	
	obj._checks = {table.unpack(self._checks)}
	obj._effects= {table.unpack(self._effects)}
	obj._test_setup_steps = {table.unpack(self._test_setup_steps)}
	obj._tests = {table.unpack(self._tests)}
	if TEST then
		table.insert(CommsNode_instances, obj)
	end
	return obj
end

-- call from outside
-- insert a condition. Conditions are inherited to subclasses.
-- conditions can be given as a function or as a table containing the keys "condition" (function) and "test_setup" (function)
function CommsNode:add_condition(cond)
	assert(cond)
	--log("ac",self.message, self.choice_line, #self._conditions)
	if type(cond) == "table" then
		assert(cond.test_setup)
		assert(cond.condition)
		self:add_test_setup(cond.test_setup)
		cond = cond.condition
	end
	assert(type(cond) == "function")
	table.insert(self._conditions, cond)
	return self
end

function CommsNode:add_check(check)
	assert(type(check) == "function")
	table.insert(self._checks, check)
	return self
end

function CommsNode:add_effect(effect)
	assert(type(effect) == "function")
	table.insert(self._effects, effect)
	return self
end

-- call from outside
-- inserts a CommsNode as dialog option.
function CommsNode:add_choice(node)
	assert(node)
	table.insert(self._choices, node)
	return self
end

-- call from outside
-- inserts a CommsNode as dialog option to all currently registered choices of this node.
-- useful for back buttons
function CommsNode:add_choice_to_all_children(node, recursive)
	for _,choice in ipairs(self._choices) do
		if not arrayContains(choice._choices, node) then
			choice:add_choice(node)
			if recursive then
				choice:add_choice_to_all_children(node, recursive)
			end
		end
	end
	return self
end

-- call from outside
-- insert a step for the test_setup function. These are inherited to subclasses.
function CommsNode:add_test_setup(test)
	assert(type(test) == "function")
	table.insert(self._test_setup_steps, test)
	return self
end

-- call from outside
-- insert a step for the tests function. These are inherited to subclasses.
function CommsNode:add_test(test)
	assert(type(test) == "function")
	table.insert(self._tests, test)
	return self
end

-- call from outside
-- start with this node when opening comms.
-- choice_line and conditions are irrelevant here
function CommsNode:create_comms_main_function()
	assert(self)
	return function(source, target)
		local env = {
			source = source,
			target = target,
			call_stack = {}, -- used for back buttons
		}
		assert(self)	-- without this assertion EE crashes
		self:_call(env)
	end
end
function CommsNode:set_as_comms_function(obj)
	assert(obj)
	obj:setCommsFunction(self:create_comms_main_function())
end


--[[ Methods your subclass of CommsNode should overwrite--]]


-- overwrite
-- returns a string, that is shown as commsReply message for the player to select. Most of the time this returns a static string, but you may randomise it or have some condition what to show. If not defined, it returns the default choice_line
function CommsNode:select_choice_line(env)
	if self.choice_line ~= nil then
		return self.choice_line
	else
		return ""
	end
end

function CommsNode:select_message(env)
	if self.message ~= nil then
		return self.message
	else
		return ""
	end
end


--[[ internal stuff, do not bother with it --]]

-- used for debugging. Use log("something", self:_id())
function CommsNode:_id()
	local id = self.choice_line
	if id == nil then
		id = self.message
	end
	return id
end

-- is called from internal
-- returns if this dialog option is available and should be selectable as comms reply.
-- iterates over conditions - they must all be true
function CommsNode:_can_select(env)
	--log("cn-cs", id)
	if env.last_operation_ok == false and not self.selectable_even_if_checks_failed then
		return false
	end
	for _, cond in ipairs(self._conditions) do
		if not cond(env) then
			return false
		end
	end
	return true
end

function CommsNode:_apply_checks(env)
	env.last_operation_ok = true
	local ok, msg
	for idx, check in ipairs(self._checks) do
		--log("ac", idx)
		ok, msg = check(self, env)
		assert(type(ok) == "boolean")
		env.last_operation_ok = ok
		if not ok then
			assert(type(msg) == "string")
			return false, msg
		end
	end
	return true, nil
end

function CommsNode:_apply_effects(env)
	local ok, msg
	for _, effect in ipairs(self._effects) do
		ok, msg = effect(self, env)
		assert(type(ok) == "boolean")
		env.last_operation_ok = ok	-- mainly used for checks, but can also be used for effects
		if not ok then
			assert(type(msg) == "string")
			return false, msg
		end
	end

	if self.effect ~= nil then
		self.effect(env)
	end

	return true, nil
end

-- is called from internal
-- accesses self._choices
function CommsNode:_show_choices(env)
	--log("cn-sc", #self._choices)
	if env.abort_comms then
		return
	end
	for _,choice in ipairs(self._choices) do
		if choice:_can_select(env) then
			addCommsReply(choice:select_choice_line(env), choice:_as_comms_reply(env))
		end
	end
end

-- is called from internal
function CommsNode:_call(env)
	--log("cn-c")
	assert(env)
	table.insert(env.call_stack, self)
	local ok, msg = self:_apply_checks(env)
	if ok then
		ok, msg = self:_apply_effects(env)
		if ok then
			msg = self:select_message(env)
		end
	end
	env.last_msg = msg
	setCommsMessage(msg)
	self:_show_choices(env)	-- warning: this is called, even if checks failed! Needed for Back, but could be differen.
end

-- is called from internal
-- provides the interface for EE
-- env is restored here
function CommsNode:_as_comms_reply(env, args)
	--log("cn-cf", self.choice_line)
	return function(source, target)
		--log("cn-f", self.choice_line)
		assert(env ~= nil)
		if args ~= nil then
			env.args = args
		end
		self:_call(env)--source.comms_session)
	end
end


function CommsNode:setup_test(env)
	assert (env)
	for _, step in ipairs(self._test_setup_steps) do
		step(env)
	end
	return self
end
function CommsNode:test(env)
	assert (env)
	for _, step in ipairs(self._tests) do
		step(self, env)
	end
	return self
end

CommsNode:add_test(function(self, env)
	--print("test: ", env)
	self:_can_select(env)
	self:select_choice_line(env)
	self:_call(env)
	return self
end)


--[[ Derived classes --]]

--[[CommsRedirection
	The CommsRedirection is a CommsNodes that automatically continues with the first selectable choice.
	If has no own message or effect (if some are given, they are ignored).
	It can have it's own choice_line - if none is given, the choice_line of the first selectable choice is used.
	It is selectable if all it's conditions are fulfilled and any of it's choices are selectable.
	You may use it with a single choice to alter the choice_line of that choice for the current instance,
	or you may use it to select the fitting node from multiple nodes with different conditions.
--]]
CommsRedirection = CommsNode:new{
	skip_in_back_stack = true
}

function CommsRedirection:_can_select(env)
	if not CommsRedirection.super()._can_select(self, env) then
		return false
	end
	-- if one choice is valid 
	local ok = false
	for _,choice in ipairs(self._choices) do
		if choice:_can_select(env) then
			ok = true
		end
	end
	return ok
end

function CommsRedirection:_call(env)
	-- select the first available choice and call it.
	-- this is usually done on entry nodes
	for _,choice in ipairs(self._choices) do
		if choice:_can_select(env) then
			return choice:_call(env)
		end
	end
	return nil
end

function CommsRedirection:select_choice_line(env)
	if self.choice_line ~= nil then
		return self.choice_line
	else
		for _,choice in ipairs(self._choices) do
			if choice:_can_select(env) then
				return choice:select_choice_line(env)
			end
		end
	end
	return ""
end


--[[CommsPipeline
	When called, all selectable choices are called one after the other.
	Usually used as entry points or to run multiple effects with different conditions.
	Can also be used to chain multiple messaged
--]]
CommsPipeline = CommsNode:new{
	skip_in_back_stack = true
}

function CommsPipeline:_call(env)
	local msg = ""
	for _, choice in ipairs(self._choices) do
		if choice:_can_select(env) then
			choice:_call(env)
			if type(env.last_msg) == "string" then
				msg = msg .. env.last_msg
			end
		end
	end
	setCommsMessage(msg)
end

--[[CommsBack
	CommsBack continues with the last called CommsNode.
	Per default the choice_line is "Back".
	It is selectable if the target node is also still selectable.
	If a node has skip_in_back_stack set to true (like in CommsRedirection-nodes) that node is skipped when pressing Back. 
--]]

CommsBack = CommsNode:new{
	choice_line = "Back",
	selectable_even_if_checks_failed = true
}

function CommsBack:_can_select(env)
	if not CommsBack.super()._can_select(self, env) then
		return false
	end
	local last_node = env.call_stack[#env.call_stack-1]
	return last_node ~= nil and
		last_node:_can_select(env)
end

function CommsBack:_call(env)
	table.remove(env.call_stack)	-- pop the current element
	local last_node = table.remove(env.call_stack)	-- pop the last element
	while last_node do
		if last_node.skip_in_back_stack then
			last_node = table.remove(env.call_stack)
		else
			return last_node:_call(env)	-- last element is added again
		end
	end
end


--[[
	Utility nodes
--]]

CommsNodeMsgByFaction = CommsNode:new{
	messages_by_faction = {}
}
function CommsNodeMsgByFaction:select_choice_line(env)
	if self.choice_line == nil and
		self.message ~= nil and
		self.messages_by_faction[self.message] ~= nil and
		self.messages_by_faction[self.message].choice_line ~= nil then
		return self.messages_by_faction[self.message].choice_line
	end
	return CommsNodeMsgByFaction.super().select_choice_line(self, env)
end
function CommsNodeMsgByFaction:select_message(env)
	if self.message ~= nil then
		local message = self:select_factional_message(env, self.message)
		if message == nil then
			message = "...\n(no response)"

		end
		return self:replace_message_placeholders(message, env) 
	else
		return ""
	end
end
function CommsNodeMsgByFaction:select_factional_message(env, id)
	if env.target.orig_faction == nil then
		env.target.orig_faction = env.target:getFaction()
	end
	if self.messages_by_faction[id] ~= nil then
		if self.messages_by_faction[id][env.target.orig_faction] ~= nil then
			return self.messages_by_faction[id][env.target.orig_faction]
		elseif self.messages_by_faction[id]["Independent"] ~= nil then
			return self.messages_by_faction[id]["Independent"]
		elseif self.messages_by_faction[id]["Human Navy"] ~= nil then
			return self.messages_by_faction[id]["Human Navy"]
		end
	end
	print("could not find factional message for ", env.target.orig_faction, id)
	return nil
end
function CommsNodeMsgByFaction:replace_message_placeholders(msg, env)
	msg = string.gsub(msg, "%. ", ".\n")	-- also add newline. may cause problems...
	msg = string.gsub(msg, "{callsign}", env.target:getCallSign())
	msg = string.gsub(msg, "{template}", env.target:getTypeName() or "")
	msg = string.gsub(msg, "{faction}", env.target:getFaction())
	msg = string.gsub(msg, "{sector}", env.target:getSectorName())
	msg = string.gsub(msg, "{zone}", env.target.zone_name or "")
	return msg
end
CommsNodeMsgByFaction:add_test_setup(function(env)
	env.target.getCallSign = function(self) assert(self); return "test" end
	env.target.getTypeName = function(self) assert(self); return "test" end
	env.target.getFaction = function(self) assert(self); return "test" end
	env.target.getSectorName = function(self) assert(self); return "test" end
end)


CommsNodeWaypointSelect = CommsNode:new({
	skip_in_back_stack = true,
	select_message = function(self, env)
		if env.source:getWaypointCount() > 0 then
			return "Select a waypoint"
		else
			return "Set a waypoint first."
		end
	end,
	_show_choices = function(self, env)
		if self.with_waypoint ~= nil and self.with_waypoint:_can_select(env) then
			for idx = 1, env.source:getWaypointCount() do
				assert(env)
				assert(idx)
				addCommsReply("Waypoint "..idx, self.with_waypoint:_as_comms_reply(env, idx))
			end
		end
		CommsNodeWaypointSelect.super()._show_choices(self, env)
	end,
	test_setup_child = function(env)
		env.args = 2
		env.source.getWaypoint = function(self, idx) assert(self); return idx*2, idx*2+1 end
	end,
	add_choice_to_all_children = function(self, node, recursive)
		if self.with_waypoint ~= nil then
			self.with_waypoint:add_choice(node)
			if recursive then
				self.with_waypoint:add_choice_to_all_children(node, recursive)
			end
		end
	end,
})
CommsNodeWaypointSelect:add_test(function(self, env)
	--log("wt")
	env.source.getWaypointCount = function(self) return 0 end
	self:select_message(env)
	env.source.getWaypointCount = function(self) return 2 end
	self:select_message(env)
	if self.with_waypoint ~= nil then
		self.with_waypoint:setup_test(env)
		self.with_waypoint:test(env)
	else
		self.with_waypoint = CommsNode
		self.with_waypoint:_as_comms_reply(env, env.args)(env.source, env.target)
	end
	--env.args = nil
end)

CommsNodeWaypointSelect:add_test_setup(function(env)
	-- this is also called by tests of with_waypoint
	--log("ws")
	env.args = 2
	env.source.getWaypointCount = function(self) return 2 end
	env.source.getWaypoint = function(self, idx) return idx*2, idx*2+1 end
end)


CommsNodeObjectSelect = CommsNode:new({
	skip_in_back_stack = true,
	range = 5000,
	select_message = function(self, env)
		for _, obj in ipairs(env.target:getObjectsInRange(self.range)) do
			if self:can_select_object(env, obj) then
				return "Select a target"
			end
		end
		return string.format("There are no valid targets within the range of %iu.", math.floor(self.range/1000))
	end,
	_show_choices = function(self, env)
		for _, obj in ipairs(env.target:getObjectsInRange(self.range)) do
			if self:can_select_object(env, obj) then
		   		if obj.getCallSign ~= nil then
					addCommsReply(obj:getCallSign(), self.with_object:_as_comms_reply(env, obj))
				end
			end
		end
		CommsNodeObjectSelect.super()._show_choices(self, env)
	end,
	can_select_object = function(self,env,obj)
		-- dummy impl
		return false
	end,
	add_choice_to_all_children = function(self, node, recursive)
		self.with_object:add_choice(node)
		if recursive then
			self.with_object:add_choice_to_all_children(node, recursive)
		end
	end,
	test_setup_child = function(env)
		env.args = {
			isValid = function(self) assert(self); return true end,
			getCallSign = function(self) assert(self); return "testobj" end,
		}
	end,
})
CommsNodeObjectSelect:add_test(function(self, env)
	if self.with_object then
		assert(#env.target:getObjectsInRange(1)>=4)
		for _, obj in ipairs(env.target:getObjectsInRange(1)) do
			assert(obj)
			local old_env_args = env.args
			if self:can_select_object(env, obj) then 
				env.args = obj
				assert(env.args)
				self.with_object:_call(env)
			end
			env.args = old_env_args
		end
	else
		self.with_object = CommsNode
		self.with_object:_as_comms_reply(env, env.args)(env.source, env.target)
	end
end)

CommsNodeObjectSelect:add_test_setup(function(env)
	env.objects_in_range = {
				{isValid = function(self) assert(self); return true end, getCallSign = function(self) assert(self); return "testobj" end},
				{isValid = function(self) assert(self); return false end, getCallSign = function(self) assert(self); return "testobj" end},
				{isValid = function(self) assert(self); return true end},
				{isValid = function(self) assert(self); return false end},
		}
	env.target.getObjectsInRange = function(self, range)
		assert(self)
		assert(type(range) == "number")
		return env.objects_in_range
	end
end)

local function enemySelectTestPrep(env)
	assert(env.objects_in_range)
	table.insert(env.objects_in_range, {
		isValid = function(self) assert(self); return true end,
		getCallSign = function(self) assert(self); return "testobj" end,
		isEnemy = function(self, obj) assert(self); assert(obj); return true end
	})
	table.insert(env.objects_in_range, {
		isValid = function(self) assert(self); return true end,
		getCallSign = function(self) assert(self); return "testobj" end,
		isEnemy = function(self, obj) assert(self); assert(obj); return false end
	})
end

CommsNodeEnemySelect = CommsNodeObjectSelect:new({
	can_select_object = function(self, env, obj)
		return obj ~= nil and 
			obj ~= env.source and
			obj:isValid() and 
			obj.isEnemy ~= nil and
			obj:isEnemy(env.target)
	end,
})
CommsNodeEnemySelect:add_test_setup(enemySelectTestPrep)

CommsNodeNotEnemySelect = CommsNodeObjectSelect:new({
	can_select_object = function(self, env, obj)
		return (obj ~= nil and
			obj ~= env.target and
			obj:isValid() and
			obj.isEnemy ~= nil and
			(not obj:isEnemy(env.target))) 
	end,
})
CommsNodeNotEnemySelect:add_test_setup(enemySelectTestPrep)

local function identifiedSelectTestPrep(env)
	assert(env.objects_in_range)
	table.insert(env.objects_in_range, {
		isValid = function(self) assert(self); return true end,
		getCallSign = function(self) assert(self); return "testobj" end,
		isScannedBy = function(self, obj) assert(self); assert(obj); return true end
	})
	table.insert(env.objects_in_range, {
		isValid = function(self) assert(self); return true end,
		getCallSign = function(self) assert(self); return "testobj" end,
		isScannedBy = function(self, obj) assert(self); assert(obj); return false end
	})
end

-- object must be unidentified by source, not nearby target
CommsNodeUnidentifiedSelect = CommsNodeObjectSelect:new({
	can_select_object = function(self, env, obj)
		return (obj ~= nil and
			obj ~= env.target and
			obj:isValid() and
			obj.isScannedBy ~= nil and
			(not obj:isScannedBy(env.source))) 
	end,
})
CommsNodeUnidentifiedSelect:add_test_setup(identifiedSelectTestPrep) 

-- object must be identified by source, not by target
CommsNodeIdentifiedSelect = CommsNodeObjectSelect:new({
	can_select_object = function(self, env, obj)
		return (obj ~= nil and
			obj ~= env.target and
			obj:isValid() and
			obj.isScannedBy ~= nil and
			obj:isScannedBy(env.source)) 
	end,
})
CommsNodeIdentifiedSelect:add_test_setup(identifiedSelectTestPrep) 


-- checks for service_available in comms_data
CommsNodeServiceAvailable = CommsNode:new({
	service_name = "dummy",
})
function CommsNodeServiceAvailable:service_available(env)
	assert(self)
	assert(env)
	local ok = env.target.comms_data and
	env.target.comms_data.service_available and
	env.target.comms_data.service_available[self.service_name] == true
	return ok
end
CommsNodeServiceAvailable._can_select = function(self, env)
	return CommsNodeServiceAvailable.super()._can_select(self, env) and
	self:service_available(env)
end
CommsNodeServiceAvailable:add_check(function(self, env)
	local ok = self:service_available(env)
	return ok, "This service is no longer available."
end)
CommsNodeServiceAvailable:add_test_setup(function(env)
	env.target.comms_data.service_available = {}
	env.target.comms_data.service_available["dummy"] = true
end)
CommsNodeServiceAvailable:add_test(function(self, env)
	env.target.comms_data.service_available[self.service_name] = false
	self:_can_select(env)
	env.target.comms_data.service_available[self.service_name] = true
end)

-- upon selection takes the costs - defined in effects
CommsNodeServiceBuyable = CommsNodeServiceAvailable:new({})
function CommsNodeServiceBuyable:service_available(env)
	assert(self)
	return CommsNodeServiceBuyable.super().service_available(self, env) and
	env.target.comms_data.service_cost and
	type(env.target.comms_data.service_cost[self.service_name]) == "number"
end
function CommsNodeServiceBuyable.apply_reputation_cost_multiplier(env, cost)
	assert(type(cost) == "number")
	if env.target.comms_data.reputation_cost_multipliers == nil then
		return cost
	end
	if env.target:isFriendly(env.source) and
		env.target.comms_data.reputation_cost_multipliers.friend ~= nil then
		return cost * env.target.comms_data.reputation_cost_multipliers.friend
	end
	if env.target.comms_data.reputation_cost_multipliers.neutral ~= nil then
		return cost * env.target.comms_data.reputation_cost_multipliers.neutral
	end
	return cost
end

function CommsNodeServiceBuyable:service_cost(env)
	assert(self.service_name)
	assert(env.target.comms_data.service_cost)
	local cost = env.target.comms_data.service_cost[self.service_name]
	assert(type(cost) == "number", string.format('env.target.comms_data.service_cost["%s"] must be a number but is %s', self.service_name, type(cost)))
	cost = self.apply_reputation_cost_multiplier(env, cost)
	return math.ceil(cost)
end
CommsNodeServiceBuyable:add_check(function(self, env)
	local cost = self:service_cost(env)
	return env.source:getReputationPoints() >= cost, "Insufficient reputation"
end)
CommsNodeServiceBuyable:add_effect(function(self, env)
	local cost = self:service_cost(env)
	if env.source.takeReputationPoints then
		return env.source:takeReputationPoints(cost), "Insufficient reputation"
	end
	return true
end)
CommsNodeServiceBuyable:add_test_setup(function(env)
	env.target.comms_data.service_cost = {}
	env.target.comms_data.service_cost["dummy"] = 27
	env.source.getReputationPoints = function(self) assert(self); return 27 end
	env.source.takeReputationPoints = function(self, amount) assert(self); assert(amount) return amount <= 27 end
end)
CommsNodeServiceBuyable:add_test(function(self, env)
	env.source.takeReputationPoints = nil
	local ok, msg = self:_apply_effects(env)
	assert(ok)
	assert(msg == nil)
	env.source.takeReputationPoints = function(self, amount) assert(self); assert(amount) return amount <= 27 end
	env.target.comms_data.reputation_cost_multipliers = {}
	env.target.isFriendly = function() return true end
	local ok, msg = self:_apply_checks(env)
end)

-- upon selection takes the costs - defined in effects
CommsNodeServiceBuyableArtifacts = CommsNodeServiceAvailable:new({})
function CommsNodeServiceBuyableArtifacts:service_available(env)
	assert(self)
	return CommsNodeServiceBuyableArtifacts.super().service_available(self, env) and
	env.target.comms_data.service_artifact_cost and
	type(env.target.comms_data.service_artifact_cost[self.service_name]) == "number"
end
-- no reputation_cost_multipliers for artifacts

function CommsNodeServiceBuyableArtifacts:service_cost(env)
	assert(self.service_name)
	assert(env.target.comms_data.service_artifact_cost)
	local cost = env.target.comms_data.service_artifact_cost[self.service_name]
	assert(type(cost) == "number", string.format('env.target.comms_data.service_artifact_cost["%s"] must be a number but is %s', self.service_name, type(cost)))
	return math.ceil(cost)
end
CommsNodeServiceBuyableArtifacts:add_check(function(self, env)
	local cost = self:service_cost(env)
	return env.source:getResourceAmount("Artifacts") >= cost, "You do not have that many artifacts"
end)
CommsNodeServiceBuyableArtifacts:add_effect(function(self, env)
	local cost = self:service_cost(env)
	return env.source:decreaseResourceAmount("Artifacts", cost), "You do not have that many artifacts"
end)
CommsNodeServiceBuyableArtifacts:add_test_setup(function(env)
	env.target.comms_data.service_artifact_cost = {}
	env.target.comms_data.service_artifact_cost["dummy"] = 27
	env.source.getResourceAmount = function(self) assert(self); return 2 end
	env.source.decreaseResourceAmount = function(self, name, amount) assert(self); assert(amount) return amount <= 2 end
end)
CommsNodeServiceBuyableArtifacts:add_test(function(self, env)
	local ok, msg = self:_apply_effects(env)
	--assert(ok)
	--assert(msg == nil)
	env.target.isFriendly = function() return true end
	local ok, msg = self:_apply_checks(env)
end)


--[[
	Utility conditions, including their tests
--]]


common_comms_conditions = {
	same_faction = {
		condition = function(env)
			return env.source:getFaction() == env.target:getFaction()
		end,
		test_setup = function(env)
			env.source.getFaction = function(self) assert(self); return "Test Faction" end
			env.target.getFaction = function(self) assert(self); return "Test Faction" end
		end,
	},
	friendly_faction = {
		condition = function(env)
			return env.source:isFriendly(env.target)
		end,
		test_setup = function(env)
			env.source.isFriendly = function(self, obj) assert(self); assert(obj); return true end
		end,
	},
	enemy_faction = {
		condition = function(env)
			return env.source:isEnemy(env.target)
		end,
		test_setup = function(env)
			env.source.isEnemy = function(self, obj) assert(self); assert(obj); return true end
		end,
	},
	neutral_faction = {
		condition = function(env)
			return (not env.source:isFriendly(env.target)) and
				(not env.source:isEnemy(env.target))
		end,
		test_setup = function(env)
			env.source.isEnemy = function(self, obj) assert(self); assert(obj); return false end
			env.source.isFriendly = function(self, obj) assert(self); assert(obj); return false end
		end,
	},
	not_enemy_faction = {
		condition = function(env)
			return not env.source:isEnemy(env.target)
		end,
		test_setup = function(env)
			env.source.isEnemy = function(self, obj) assert(self); assert(obj); return false end
		end,
	},
	scanned = {
		condition = function(env)
			return env.target:isScannedBy(env.source)
		end,
		test_setup = function(env)
			env.target.isScannedBy = function(self, obj) assert(self); assert(obj); return true end
		end,
	},
	unscanned = {
		condition = function(env)
			return not env.target:isScannedBy(env.source)
		end,
		test_setup = function(env)
			env.target.isScannedBy = function(self, obj) assert(self); assert(obj); return false end
		end,
	},
	docked = {
		condition = function(env)
			return env.source:isDocked(env.target)
		end,
		test_setup = function(env)
			env.source.isDocked = function(self, obj) assert(self); assert(obj); return true end
		end,
	},
	undocked = {
		condition = function(env)
			return not env.source:isDocked(env.target)
		end,
		test_setup = function(env)
			env.source.isDocked = function(self, obj) assert(self); assert(obj); return false end
		end,
	},
	disabled = {
		condition = function(env)
			return false
		end,
		test_setup = function(env)
		end,
	},




}


