require "utils.lua"

vf_ambush = {}

function vf_ambush:findAmbushPositions()
	-- find all positions that can be used for ambushes
	-- get all radars in the area
	local radars = getActivePlayerShips()
	if avp_stations and avp_stations.stations then
		table.extend(radars, avp_stations.stations)
		-- use all station here, even if they are neutral or enemy
		for __, station in ipairs(avp_stations.stations) do
			if station:isValid() and
		   	station.comms_data ~= nil and
			station.comms_data.satellites ~= nil then
				table.extend(radars, station.comms_data.satellites)
			end
		end
	end

	arrayFilter(radars, function(obj)
		return obj ~= nil and obj:isValid() and obj.getLongRangeRadarRange ~= nil
	end)
	-- pairwise calculate intersection points
	local intersections = {}
	for _,p1 in ipairs(radars) do
		for _,p2 in ipairs(radars) do
			if p1 ~= p2 then
				p1x, p1y = p1:getPosition()
				p2x, p2y = p2:getPosition()
				p1r = p1:getLongRangeRadarRange() + 1000
				p2r = p2:getLongRangeRadarRange() + 1000
				local new_ints = getCircleCircleIntersection(p1x, p1y, p1r, p2x, p2y, p2r)
				table.extend(intersections, new_ints)
			end
		end
	end

	-- filter out points that are inside radar ranges
	table.filter(intersections, function(o)
		local x,y = o[1], o[2]
		for _,p in ipairs(radars) do
			if distance(p, x,y) < p:getLongRangeRadarRange() then
				return false
			end
		end
		return true
	end)
	if #intersections == 0 then
		-- radars are too far apart for their radar ranges to intersect
	end
	return intersections
end

function vf_ambush:randomPositionOutsideRadarRange(target)
	return radialPosition(target, target:getLongRangeRadarRange() + 1000, math.random(0,360))
end

function vf_ambush:findBestAmbushPosition(target)
	local intersections = self:findAmbushPositions()
	if #intersections == 0 then
		return self:randomPositionOutsideRadarRange(target)
	end
	-- selects position outside of all near radar ranges, but next to target's position
	-- get nearest ones; but ignore very far away
	local nearestDist = target:getLongRangeRadarRange() * 2
	for _,int in ipairs(intersections) do
		local x,y = table.unpack(int)
		nearestDist = math.min(nearestDist, distance(target, x,y))
	end
	table.filter(intersections, function(o)
		local x,y = table.unpack(o)
		return distance(target, x,y) <= 5000 + nearestDist
	end)

	-- choose one
	local pos = tableSelectRandom(intersections)
	if pos ~= nil then
		return table.unpack(pos)
	else
		return self:randomPositionOutsideRadarRange(target)
	end
end


