--[[ Rotation utility
-- makes object orbit other objects or positions
-- No Dependencies
-- Can be called from other modules that rely on orbit-rotation
--]]
wh_rota = {
	objects = {}
}

require "utils.lua"

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

function wh_rota.set_center(object, x,y)
	-- set the center of mass and adjust the distance and angle acordingly
	object.center[1], object.center[2] = x, y
	object.distance = distance(object, object.center)
	object.angle = angleRotation(object.center, object)
end

function wh_rota.move_center(object, amount, direction)
	-- moves the center of mass and adjust the distance and angle acordingly
	if object == nil or not object:isValid() or object.center == nil then
		error("wh_rota.move_center called with invalid object")
		return
	end
	local x,y = vectorFromAngle(direction, amount)
	x,y = object.center[1]+x, object.center[2]+y
	wh_rota.set_center(object, x,y)
end

function wh_rota:update(delta)
	-- move nebulae
    for i=1,#self.objects do
        local obj = self.objects[i]
        if obj ~= nil and obj:isValid() and math.abs(obj.distance) > 0.001 then
            obj.angle = obj.angle + obj.speed * delta
			local pmx, pmy = vectorFromAngle(obj.angle, obj.distance)
			local cx, cy = obj.center:getPosition()
            obj:setPosition(cx+pmx, cy+pmy)
        end
    end
end
