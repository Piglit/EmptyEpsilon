--[[ Code for coverage tests --]]

if TEST then


function setCommsMessage(msg)
end
function setCommsReply(msg)
end
irandom = math.random

local env = {
	source = {
		getCallSign = function() return "Player Ö" end,
	},
	target = {
		comms_data = {
			friendlyness = irandom(-20,120)
		},
		setCommsFunction = function()end,
		getTypeName = function() return arraySelectRandom({"Small Station","Medium Station","Large Station","Huge Station"}) end,
		getShortRangeRadarRange = function() return irandom(1000,20000)end,
		getCallSign = function() return "Station 1Ü" end,
		getFaction = function() return "Test Faction" end,
	},
}
for idx,instance in ipairs(CommsAbomination.instances) do
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
	print("test instance "..tostring(idx))
	instance:test(env)
end
print("test complete")

end	-- if TEST
