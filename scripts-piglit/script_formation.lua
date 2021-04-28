script_formation = {}

require "utils.lua"
--[[
Description:
------------
This file provides some functions to create and manage ships flying in a formation.
The functions provided here aim to be at a higher level then the simple orderFlyFormation() function.
The goal is to manage several ships at once without the need to calculate formation offsets by yourself.

Usage:
------
The functions provided here are stored in the global script_formation object.
To call them, write: script_formation.<function name>.
Look at the examples at the functions below.

Functions:
----------
spawnFormation: creates a number of ships of the same type that fly in formation.
buildFormationIncremental: lowest level function. This orders a given ship into formation.
--]]



--Kraylor: inverse 4-finger formation: fighters in front of leader
--Exuari:  4-finger formation: fighters behind leader
--Human Navy: row formation: fight side by side
--Blue Star Cartell: line formation: behind each other
--Mining Corporation: undisciplined 4-finger
function factionalOffsets(faction, pos)

	local x,y -- x - to the front, y - to starport
	if faction == "Kraylor" then
		x = 300
		y = 300
	elseif faction == "Exuari" then
		x = -300
		y = 300
	elseif faction == "Mining Corporation" then
		x = random(-200,-1000)
		y = random(200,600)
	elseif faction == "Blue Star Cartell" then
		x = -300
		if pos == 3 then
			x = 2*x
		end
		y = 0
	elseif faction == "Human Navy" then
		x = 0
		y = 300
	else
		x = -1000
		y = 1000
	end
	return x,y

end

--returns leader, second
--still works if second is omitted

function script_formation.buildFormationIncremental(ship, idx, leader, second, offsetx, offsety)
	if leader == nil or not leader:isValid() then
		ship:orderRoaming()
		return ship, second
	end

	local pos = idx % 4
	local x,y -- x - to the front, y - to starport
	if offsetx ~= nil and offsety ~= nil then
		x = offsetx
		y = offsety
	else
		x,y = factionalOffsets(ship:getFaction(), pos)
	end
	if pos == 1 then
		if idx % 8 == 5 then
			ship:orderFlyFormation(leader, 0, -4*y)
		else
			ship:orderFlyFormation(leader, 4*x, 4*y)
		end
		leader = ship
		--first ship has roaming order!
	elseif pos == 2 then
		ship:orderFlyFormation(leader, x, -y)
	elseif pos == 3 then
		ship:orderFlyFormation(leader, x, y)
		second = ship
	elseif pos == 0 then
		if second == nil or not second:isValid() then
			ship:orderFlyFormation(leader, 2*x, 2*y)
		else
			ship:orderFlyFormation(second, x, y)
		end
	end
	return leader, second
end


--[[
--spawnFormation creates a group of ships of the same type, that fly in formation.
-- Parameters:
--  shipTemplate: All ships in the formation are ships from that template
--  amount: the number of ships created
--  posx, posy: around that position the formation is created
--  faction (optional): all ships of the formation belong to that faction
--  callSignPrefix (optional): the callSigns of all ships of the formation start with that name
-- Returns: a list of all created ships in the formation
--
-- Example:
-- --------
-- ```local squad = script_formation.spawnFormation("MT52 Hornet", 4, 3000, -3000, "Kraylor", "Alpha-")```
-- This creates four Kraylor Hornets at position(3000,-3000). Their callSigns are Alpha-1 to Alpha-4.
-- The ships will fly in formation. If the squadron leader is killed, the squadron will split into smaller pieces.
-- The ships are stored in the table named squad, so you can access them if needed.
-- The squads order defaults to roaming. If you want to change that, set the squad leader's order:
-- ```squad[1]:orderAttack(player)```
--]]
function script_formation.spawnFormation(shipTemplate, amount, posx, posy, faction, callSignPrefix)
	local ships = {}
	local leader, second = nil, nil -- here the current formation leaders are stored
	for index = 1, amount do
		local ship = CpuShip():setTemplate(shipTemplate)
		if faction ~= nil then
			ship:setFaction(faction)
		end
		if callSignPrefix ~= nil then
			ship:setCallSign(callSignPrefix..tostring(index))
		end
		local arc = random(0,360)
		setCirclePos(ship, posx, posy, arc, 100)
		ships[#ships+1] = ship
		leader, second = script_formation.buildFormationIncremental(ship, index, leader, second)
		-- this orders the current ship to fly in formation
		-- new leader and second-leader are returned
	end
	return ships
end

