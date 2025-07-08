--usage: 
--	local script = Script()
--	script:setVariable("position_x", position_x):setVariable("position_y", position_y)
--	script:setVariable("target_x", target_x):setVariable("target_y", target_y)
--	script:setVariable("faction_id", target:getFactionId())
--	script:setVariable("template", randomStationTemplate())
--	script:run("script_base_drop.lua")
--	script:isValid() to check, if it is completed (destroyScript() was called)

function init()
	my_ship = CpuShip():setCommsScript("comms_supply_drop.lua"):setFactionId(faction_id):setPosition(position_x, position_y):setTemplate("Goods Freighter "..tostring(irandom(1,5))):setScanned(true):orderFlyTowardsBlind(target_x, target_y)
	state = 0
end

function update(delta)
	if not my_ship:isValid() then
		destroyScript()
		return
	end
	local x, y = my_ship:getPosition()
	if state == 0 then
		if math.abs(x - target_x) < 300 and math.abs(y - target_y) < 300 then
			SpaceStation():setTemplate("Small Station"):setFactionId(faction_id):setPosition(target_x + random(-300, 300), target_y + random(-300, 300)).comms_data = {
				weapons = {
					Homing = "no",
					HVLI = "no",
					Mine = "no",
					Nuke = "no",
					EMP = "no"
				},
				services = {
					supplydrop = "no",
					reinforcements = "no",
					fighters = "no",
					refitDrive = "no"
				}
			}
			my_ship:orderFlyTowardsBlind(position_x, position_y)
			state = 1
		end
	elseif state == 1 then
		if math.abs(x - position_x) < 1500 and math.abs(y - position_y) < 1500 then
			my_ship:destroy()
			destroyScript()
			return
		end
	end
end
