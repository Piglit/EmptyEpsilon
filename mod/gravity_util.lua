GRAVITY = {
    gravity_const = 100000000
	sources = {}
}

local function raiseGravity()
    GRAVITY.gravity_const = GRAVITY.gravity_const * 0.75
end

local function lowerGravity()
    GRAVITY.gravity_const = GRAVITY.gravity_const * 1.25
end

GRAVITY.addGMFunctions = function()
    addGMFunction(_("buttonGM", "Lower Gravity"), lowerGravity)
    addGMFunction(_("buttonGM", "Raise Gravity"), raiseGravity)
end

GRAVITY.addGravitySource = function(planet, outer_limit)
	if planet ~= nil and planet:isValid() then
		table.insert(GRAVITY.sources, {planet, outer_limit})
	end
end

GRAVITY.update = function(delta)
    for _,p in ipairs(getActivePlayerShips()) do
        if p ~= nil and p:isValid() and p:getDockingState() == 0 then
			for idx,s in ipairs(GRAVITY.sources) do
				local source = s[1]
				local limit = s[2]
				if source == nil or not source:isValid() then
					table.remove(GRAVITY.source, idx)
					return
				end
				local angle = angleRotation(p, source)
				local dist_0 = distance(p, source)
				if dist_0 < limit then
					local dist_1 = (limit-dist_0)^2 / gravity_const * delta
					local pmx, pmy = vectorFromAngle(angle, dist_0 - dist_1)
					local px, py = p:getPosition()
					p:setPosition(-pmx,-pmy)
				end
			end
        end
    end
end

