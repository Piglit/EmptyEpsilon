--[[ Rotation utility
-- makes object orbit other objects or positions
-- No Dependencies
-- Can be called from other modules that rely on orbit-rotation
--]]
wh_rota = {}

require "utils.lua"

function wh_rota:init()
	self.objects = {}
end

function wh_rota:add_object(object, speed, center, center_y)
    if type(center) == "number" and type(center_y) == "number" then
		center = {center, center_y}
		center.getPosition = function(self)
			return self[1], self[2]
		end
	elseif type(center) == "table" and center_y == nil and center.getPosition ~= nil then
		--OK
	else
        print(type(object), type(speed), type(center), type(center_y))
        error("wh_rota:add_object() function used incorrectly", 2)
	end
	object.center = center
	object.angle = angleRotation(object, center)
	object.distance = distance(object, center)
	object.speed = speed
	table.insert(self.objects, object)
end

function wh_rota:update(delta)
	-- move nebulae
    for i=1,#self.objects do
        local obj = self.objects[i]
        if obj ~= nil and obj:isValid() then
            obj.angle = obj.angle + obj.speed * delta
            if obj.angle >= 360 then 
                obj.angle = 0
            end
            local pmx, pmy = vectorFromAngle(obj.angle, obj.distance)
			local cx, cy = obj.center:getPosition()
            obj:setPosition(cx+pmx, cy+pmy)
        end
    end
end
