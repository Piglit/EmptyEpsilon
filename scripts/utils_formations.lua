formations = {}

require "utils.lua"
--[[
Description:
------------
This file provides some functions to create and manage ships flying in a formation.
The functions provided here aim to be at a higher level then the simple orderFlyFormation() function.
The goal is to manage several ships at once without the need to calculate formation offsets by yourself.

Usage:
------
The functions provided here are stored in the global formations object.
To call them, write: formations.<function name>.
Look at the examples at the functions below.

Functions:
----------
spawn: creates a number of ships of the same type that fly in formation.
buildFormationIncremental: lowest level function. This orders a given ship into formation.
--]]



--[[
--spawn: creates a group of ships of the same type, that fly in formation.
-- Parameters:
--  shipTemplate: All ships in the formation are ships from that template
--  amount: the number of ships created
--  posx, posy: around that position the formation is created
--  faction (optional): all ships of the formation belong to that faction
--	shape (optional): shape of the formation. can be one of ["factional"]
--  callSignPrefix (optional): the callSigns of all ships of the formation start with that name
-- Returns: a list of all created ships in the formation
--
-- Example:
-- --------
-- ```local squad = formations:spawn("MT52 Hornet", 4, 3000, -3000, "Kraylor", "factional", "Alpha-")```
-- This creates four Kraylor Hornets at position(3000,-3000). Their callSigns are Alpha-1 to Alpha-4.
-- The ships will fly in formation. If the squadron leader is killed, the squadron will split into smaller pieces.
-- The ships are stored in the table named squad, so you can access them if needed.
-- The squads order defaults to roaming. If you want to change that, set the squad leader's order:
-- ```squad[1]:orderAttack(player)```
--]]
function formations:spawn(shipTemplate, amount, posx, posy, faction, shape, callSignPrefix)
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
		ships = formations:addShip(ship, ships, shape)
		-- this orders the current ship to fly in formation
		-- new leader and second-leader are returned
	end
	return ships
end


function formations:addShip(ship, shipList, shape, distance)-- idx, leader, second, shape, offsetx, offsety)
	-- validate argumets
	if shipList == nil then
		shipList = {}
	end
	if ship == nil or not ship:isValid() then
		return shipList
	end
	if shape == "factional" or shape == nil then
		shape = ship.getFaction()
	end
	if formations[shape] == nil then
		shape = "square"
	end
	local shapeFunction = formations[shape]
	if distance == nil then
		distance = 300
	end

	-- add ship to formation list, get it's index
	local idx = #shipList+1
	table.insert(shipList, ship)

	-- determine what other ship to follow
	local leaderIdx, x, y = shapeFunction(idx) -- x: to the front, y: to starport
	local leader = shipList[leaderIdx]	-- TODO test if this can fail with index out of bounds 

	-- issue orders
	if leader == nil or not leader:isValid() then
		ship:orderRoaming()
	else
		ship:orderFlyFormation(leader, x*distance, y*distance)
	end

	-- return updated shipList
	return shipList


	local leader = shipList[1]
	local second = shipList[2]
	if leader == nil or not leader:isValid() then
		ship:orderRoaming()
		return ship, second
	end

end

-- special formations get the ships index and return a leaders index and offsets to that leader

formation["Independent"] = function(index)
	-- Independent ships build an unordered convoy, a randomized column formation
	x = math.random(0.66,3.33)
	y = math.random(0.66,2)
	return index-1, x, y
end

formation["Human Navy"] = function(index)
	-- Human Navy ships fight side by side, in row formation
	return index-1, 0, 1
end

formation["Kraylor"] = function(index)
	-- inverse 4-finger formation: followers in front of leader
	local idx, x, y, = formation["4-finger"](index)
	return idx, -x, y
end

formation["Exuari"] = function(index)
	-- 4-finger formation: followers behind leader
	return formation["4-finger"](index)
end

formation["Arlenians"] = function(index)
	-- Arlenians ships follow each other in a tight column formation
	return index-1, -1, 0
end

formation["Ghosts"] = function(index)
	-- square formation for the ai 
	return formation["square"](index)
end

formation["Ktlitans"] = function(index)
	-- hexagon formation for the hive
	return formation["hexagon"](index)
end

formation["TSN"] = function(index)
	-- TSN uses echelon formation
	return index-1, -1, 1
end

formation["USN"] = function(index)
	-- TSN also uses echelon formation, but inverted
	return index-1, -1, -1
end

formation["CUF"] = function(index)
	-- CUF uses a V-Formation
	if index == 2 then
		return index-1, -1, 1
	end
	if index % 2 == 0 then
		return index-2, -1, 1
	else
		return index-2, -1, -1
	end
end

-- helper function for 4-finger based formations
formation["4-finger"] = function(index)
	local pos = index % 4
	if pos == 1 then
		if index % 8 == 5 then
			return index-4,  0, -4
		else
			return index-8, -4,  4
		end
	elseif pos == 2 then
		return index-1 , -1, -1
	elseif pos == 3 then
		return index-2 , -1,  1
	elseif pos == 0 then
		return index-1 , -1,  1
	end
end

-- helper functions for vector arithmetics
local function rotate(coords)
	--rotate (x,y) by 45 degrees
	local x_0,y_0 = unpack(coords)
	local x_1 = x_0+y_0
	local y_1 = -x_0+y_0
	return {x_1, y_1}
end

local function scale(coords, factor)
	local x,y = unpack(coords)
	return {x*factor, y*factor}
end

local function add(coords, other)
	local x_0,y_0 = unpack(coords)
	local x_1,y_1 = unpack(other)
	return {x_0+x_1, y_0+y_1}
end

local function diff(coords, other)
	local x_0,y_0 = coords
	local x_1,y_1 = other 
	return {x_1-x_0, y_1-y_0}
end

local function invert(coords)
	--point reflection
	local x,y = unpack(coords)
	return {-x,-y}
end

formation["square"] = function(i)
	matrix = {
		{ 1, 0},
		{-1, 0},
		{ 0, 1},
		{ 0,-1},
	}
	fill = {
		{ 0, 1},
		{ 0,-1},
		{-1, 0},
		{ 1, 0},
		{ 0, 1},
		{ 0,-1},
		{-1, 0},
		{ 1, 0},
	}
	cpos = (i-2)%4 +1	-- <- 1..4
	rpos = 0
	itr = 0
	offset = 0
	rot = math.floor((i-2) / 4) +1
	ring = math.floor(math.ceil(math.sqrt(i))/2)
	ring_last = math.pow(((ring-1)*2+1), 2)
	pos = matrix[cpos]
	pos = scale(pos, ring)
	if rot % 2 == 0 then
		pos = rotate(pos)
	end
	if i > ring_last+8 then
		rpos = i - ring_last - 8 -- -1
		offset = fill[rpos % 8]
		itr = math.floor((rpos-1) / 8) + 1
		offset = scale(offset, itr)
		pos = add(pos, offset)
	end
	--print(i, rot, ring, ring_last, rpos, offset, itr, pos)
	return 1, unpack(pos)
end

formation["hexagon"] = function(i)
	matrix = {
		{ 2, 0},
		{-2, 0},
		{ 1, 1},
		{-1,-1},
		{ 1,-1},
		{-1, 1},
	}
	fill = {
		{-1, 1},
		{ 1,-1},
		{-2, 0},
		{ 2, 0},
		{ 1, 1},
		{-1,-1},
	}

	cpos = (i-2)%6 +1	-- <- 1..6
	ring = math.ceil((math.sqrt(8*((i-1)/6)+1)-1)/2)
	ring_last = (ring*(ring-1))*3+1
	pos = matrix[cpos]
	pos = scale(pos, ring)
	if i > ring_last +6 then
		rpos = i - ring_last - 6 -- -1
		offset = fill[rpos % 6]
		itr = math.floor((rpos-1) / 6) + 1
		offset = scale(offset, itr)
		pos = add(pos, offset)
	end
	return 0, unpack(pos)
end

