#!/usr/bin/lua
--[[ Code for coverage tests --]]
--require("serpent")
TEST=true
function arrayContains(array, element)
	for _,value in ipairs(array) do
		if value == element then
			return true
		end
	end
	return false
end
function Script()
	return {
		setVariable = function(self, var, val) assert(self); assert(var); assert(val); return self end,
		run = function(self, script) assert(self); assert(script); return self end,
	}
end
function setCommsMessage(msg)
end
function addCommsReply(msg)
end
SDB = {
	_content = {}
}
function sdb_get_entires(self)
	--log("getEntries", serpent.block(self._content))
	return self._content
end
function sdb_add_entry(self, name)
	self[name] = {
		addEntry = sdb_add_entry,
		getEntries = sdb_get_entires,
		_content = {},
		setLongDescription = function(self, text) assert(self); assert(type(text) == "string") end,
		getName = function(self) assert(name); return name end,
		destroy = function(self) self=nil end,
		setKeyValue = function(self, key, value) assert(self); assert(key); assert(value) end,
		setImage = function(self, img) assert(self); assert(img); end,
		getImage = function(self, img) assert(self); return "image" end,
		setModelDataName = function(self, name) assert(self); assert(name); end,
		getModelDataName = function(self) assert(self); return "test" end,
	}
	table.insert(self._content, self[name])
	return self[name]
end
function queryScienceDatabase(...)
	local arg = {...}
	local current = SDB
	for i,v in ipairs(arg) do
		--log("query", string.rep("\t", i-1), v)
		if current[v] == nil then
			return nil
		else
			current = current[v]
		end
	end
	return current
end
function ScienceDatabase()
	return {
		setName = function(self, name)
			sdb_add_entry(SDB, name)
			return SDB[name]
		end,
	}
end
irandom = math.random
math.atan2 = math.atan
function distance()
	return 1000
end
function angleHeading()
	return 180
end
function _(a,b)
	return b or a
end
function arraySelectRandom(array)
    local array_item_count = #array
    if array_item_count == 0 then
        return nil
    end
    return array[math.random(1,#array)]    
end
arraySelectRandom({})
function CpuShip()
	return {
		setFactionId = function(self, num) assert(self); assert(num == 1); return self end,
		setPosition= function(self, x, y) assert(self); assert(x); assert(y);return self end,
		setTemplate = function(self, arg) assert(self); assert(arg); return self end,
		setScanned = function(self, arg) assert(self); assert(arg); return self end,
		orderDefendLocation = function(self, x, y) assert(self); assert(x); assert(y);return self end,
		getCallSign = function(self) assert(self); return "test" end,
		setCallSign = function(self, arg) assert(self); assert(arg); return self end,
		setShortRangeRadarRange = function(self, arg) assert(self); assert(arg); return self end,
	}
end

wh_rota = {
	add_object = function(self, obj) assert(self); assert(obj) end
}

require("lib_comms_nodes")
require("comms_vf_ship")
require("comms_vf_weapons")
require("comms_vf_military")
require("comms_vf_station")
require("comms_vf_scenario_management")


local env = {
	source = {
		getCallSign = function() return "Player Ö" end,
		getFaction = function() return "Test Faction" end,
	},
	target = {
		comms_data = {
			friendlyness = irandom(-20,120)
		},
		getTypeName = function() return arraySelectRandom({"Small Station","Medium Station","Large Station","Huge Station"}) end,
		getShortRangeRadarRange = function() return irandom(1000,20000)end,
		getCallSign = function() return "Station 1Ü" end,
		getFaction = function() return "Test Faction" end,
		getTypeName = function() return "Ship" end,
		getSectorName = function() return "XY" end,
	},
	call_stack = {},
}

local sample = CommsNode:new{
	choice_line = "choice",
	message = "message",
	effect = function(env) assert(env.target ~= nil) end,
}
sample:add_choice(sample)

local sample2 = CommsNode:new():test(env)

function test_cf(e)
	e.target.setCommsFunction = function(self, cf)
		assert(e ~= nil)
		cf(e.source, e.target)
	end
	sample:set_as_comms_function(e.target)
end
test_cf(env)

local redirect = CommsRedirection:new({
	choice_line = "Redirect"
}):add_choice(sample)
redirect:new():add_condition(function() return false end)
sample:add_choice_to_all_children(CommsBack, true)
sample:_call(env)
sample:_call(env)
CommsBack:_call(env)
sample.skip_in_back_stack = true
sample:_call(env)
CommsBack:_call(env)


CommsNodeMsgByFaction.messages_by_faction.test_indep = {Independent = "Indep"}
CommsNodeMsgByFaction.messages_by_faction.test_hn = {["Human Navy"]= "HN"}
CommsNodeMsgByFaction.messages_by_faction.test_ok = {["Test Faction"]= "TF"}
local msg = CommsNodeMsgByFaction:new{
	message = "test_fail - lookup will fail"
}
msg = CommsNodeMsgByFaction:new{
	message = "test_indep"
}
msg = CommsNodeMsgByFaction:new{
	message = "test_hn"
}
msg = CommsNodeMsgByFaction:new{
	message = "test_ok"
}

CommsBack:new{
	message = "custom back"
}:add_condition(common_comms_conditions.disabled)

for idx,instance in ipairs(CommsNode_instances) do
--[[
	local boolean_methods_source = {
		isDocked = true,
		isEnemy = false,
		isFriendly = true,
	}
	local boolean_methods_target= {
		areEnemiesInRange = false,
	}
	for method,value in pairs(boolean_methods_source) do
		if math.random(1,4) == 1 then
			value = not value
		end
		env.source[method] = function() return value end
	end
	for method,value in pairs(boolean_methods_target) do
		if math.random(1,4) == 1 then
			value = not value
		end
		env.target[method] = function() return value end
	end
--]]
	local inst_name = instance:_id()
	if inst_name == nil then
		inst_name = tostring(idx)
	else
		inst_name = string.sub(inst_name, 1, 20)
	end
	env.args = nil
-- TODO: goal: new env for every test
--	env = {
--		source = {},
--		target = {},
--		call_stack = {},
--	}
	print(string.format("test instance %s", inst_name))
	instance:setup_test(env)
	instance:test(env)
end
print("test complete")

