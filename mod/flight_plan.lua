--[[ Utility for cutscene-like flight-plans
--]]
flight_plan = {
	sequence = {},
	index = 1,
	observer = nil,	-- if this is a player ship, create buttons for relay for the flight plan
	objects = {}, -- those get destroyed when the fligh plan is finished
	on_finish = nil,	-- this is called after the finish function is run
	color = "cyan",	-- the color of the instructions log entries
}

function flight_plan:init()
	addGMFunction("Flight Plan - End", function() flight_plan.finished()end)
	addGMFunction("Flight Plan - Start", function() flight_plan.next() end)
end

function flight_plan.next()
	local self = flight_plan
	removeGMFunction("Flight Plan - Start")
	removeGMFunction("Flight Plan - Restart")
	removeGMFunction("Flight Plan - Next")
	local fun = self.sequence[self.index]
	self.index = self.index + 1
	if fun == nil or #self.sequence < self.index then
		addGMFunction("Flight Plan - Restart", flight_plan.next)
		if self.observer ~= nil and self.observer:isValid() then
			self.observer:addCustomButton("Relay", "fpn_relay", "Flight plan - Restart", flight_plan.next)
			self.observer:addCustomButton("AltRelay", "fpn_map", "Flight plan - Restart", flight_plan.next)
			self.observer:addCustomButton("ShipLog", "fpn_log", "Flight plan - Restart", flight_plan.next)
		end
		self.index = 1
	else
		addGMFunction("Flight Plan - Next", flight_plan.next)
		if self.observer ~= nil and self.observer:isValid() then
			self.observer:addCustomButton("Relay", "fpn_relay", "Flight plan - Next", flight_plan.next)
			self.observer:addCustomButton("AltRelay", "fpn_map", "Flight plan - Next", flight_plan.next)
			self.observer:addCustomButton("ShipLog", "fpn_log", "Flight plan - Next", flight_plan.next)
		end
	end
	if fun ~= nil then
		fun()
	end
end

function flight_plan:addInstructions(instructions)
	if type(instructions) == "string" then
		instructions = {instructions}
	end
	assert(type(instructions) == "table", "Parameter for flight_plan:addInstructions() must be string or table of strings")
	for _,instruction in ipairs(instructions) do
		assert(type(instruction) == "string", "Parameter for flight_plan:addInstructions() must be string or table of strings")
		self:addToSequence(function()
			if flight_plan.observer ~= nil and flight_plan.observer:isValid() then
				flight_plan.observer:addToShipLog(instruction, flight_plan.color)
			end
		end)
	end
end

function flight_plan:addToSequence(fun)
	assert(type(fun) == "function", "Parameter for flight_plan:addToSequence() must be a function")
	table.insert(self.sequence, fun)
end

function flight_plan:setOnFinish(fun)
	assert(type(fun) == "function", "Parameter for flight_plan:setOnFinish() must be a function")
	self.on_finish = fun
end

function flight_plan:clearObjects()
	for _,obj in ipairs(self.objects) do
		if obj:isValid() then
			obj:destroy()
		end
	end
end

function flight_plan.finished()
	removeGMFunction("Flight Plan - Start")
	removeGMFunction("Flight Plan - Restart")
	removeGMFunction("Flight Plan - Next")
	removeGMFunction("Flight Plan - End")
	if flight_plan.observer ~= nil and flight_plan.observer:isValid() then
		flight_plan.observer:removeCustom("fpn_relay")
		flight_plan.observer:removeCustom("fpn_map")
		flight_plan.observer:removeCustom("fpn_log")
	end
	flight_plan:clearObjects()
	if flight_plan.on_finish ~= nil then
		flight_plan.on_finish()
	end
end
