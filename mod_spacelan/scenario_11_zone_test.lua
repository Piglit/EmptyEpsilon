-- Name: Zone test
-- Description: For testing if zone logic and replication works properly
-- Type: Development

--- Scenario
-- @script scenario_11_empty

require("utils.lua")
require("comms/comms_vf_ship.lua")

local zone_absolute_move = nil
local zone_relative_move = nil
local zone_only_text_move = nil
local zone_recreate = nil
local cycle = 0

function init()
	-- static Zones
	local static_origin = -10000;
	local static_size = 8000;
	
	-- static absolute
	Zone()
		:setColor(255, 0, 0)
		:setPoints(static_origin,static_origin,  static_origin,static_origin+static_size, static_origin+static_size,static_origin+static_size, static_origin+static_size,static_origin)
		:setLabel("Static Absolute")

	-- static relative
	Zone()
		:setColor(255, 0, 255)
		:setPosition(-static_origin, static_origin)
		:setLabel("Static Relative")
		:setOutline(false,  static_size,static_size,  static_size,-static_size,  -static_size,-static_size,  -static_size,static_size)

	-- zone that moves absolutely
	zone_absolute_move = Zone()
		:setColor(0, 255, 0)
		:setLabel("Absolute Move")
		
	-- zone that moves relatively (only the position changes, not the outline)
	zone_relative_move = Zone()
		:setColor(0, 0, 255)
		:setLabel("Relative Move")
		:setOutline(false,  static_size,static_size,  static_size,-static_size,  -static_size,-static_size,  -static_size,static_size)
		
	-- zone that moves only its text
	zone_only_text_move = Zone()
		:setColor(0, 255, 255)
		:setLabel("Text Only Move")
		:setOutline(true,  5000+static_size,static_size,  5000+static_size,-static_size,  5000-static_size,-static_size,  5000-static_size,static_size)

end

function update(delta)
	local oldSecond = math.floor(cycle)
	cycle = cycle + delta
	local newSecond = math.floor(cycle)
	
	local xoff = 10000 + math.sin(cycle*2)*10000
	local yoff = 10000
	local xdist = math.cos(cycle) * 10000
	local ydist = math.sin(cycle) * 6000
	zone_absolute_move:setPoints(xoff+xdist,yoff+ydist,  xoff-ydist,yoff+xdist,  xoff-xdist,yoff-ydist,  xoff+ydist,yoff-xdist)
	
	-- this will move the zone as well, if it's relative (which this one is)
	zone_relative_move:setTextPosition(math.cos(cycle)*1000, 10000+math.sin(cycle)*1000)
	
	zone_only_text_move:setTextPosition(10000+math.cos(cycle)*1000, math.sin(cycle)*1000)
	
	if (oldSecond ~= newSecond) then
		if(zone_recreate == nil) then
			-- re-create this Zone
			zone_recreate = Zone()
				:setColor(255, 255, 255)
				:setLabel("Recreated")
				:setPoints(-10000, 5000,  -5000,10000,  -10000,15000, -15000,7000)
		else
			zone_recreate:destroy()
			zone_recreate = nil
		end
	end
end

-- Set callback function
onNewPlayerShip(
    function(ship)
        -- Decide what you do with new ships:
        print(ship, ship.typeName, ship:getTypeName(), ship:getCallSign())
        -- ship:destroy()
    end
)
