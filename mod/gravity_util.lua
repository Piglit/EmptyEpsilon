GRAVITY = {
    gravity_const = 100000000,
	sources = {},
	exceptions = {}
}

function GRAVITY.raiseGravity()
    GRAVITY.gravity_const = GRAVITY.gravity_const * 0.75
	print("AntiGravity is now "..(GRAVITY.gravity_const/1000000) .. "%")
end

function GRAVITY.lowerGravity()
    GRAVITY.gravity_const = GRAVITY.gravity_const * 1.25
	print("AntiGravity is now "..(GRAVITY.gravity_const/1000000) .. "%")
end

function GRAVITY:gm_menu()
    addGMFunction(_("buttonGM", "Lower Gravity"), GRAVITY.lowerGravity)
    addGMFunction(_("buttonGM", "Raise Gravity"), GRAVITY.raiseGravity)
end

function GRAVITY.addGravitySource(planet, outer_limit)
	if planet ~= nil and planet:isValid() then
		table.insert(GRAVITY.sources, {planet, outer_limit})
	end
end

function GRAVITY.addException(playership)
	table.insert(GRAVITY.exceptions, playership)
end

function GRAVITY:updatePlayerShip(delta, p)
	if p ~= nil and p:isValid() and p:getDockingState() == 0 then
		if arrayContains(self.exceptions, p) then
			return
		end
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
				local dist_1 = (limit-dist_0)^2 / self.gravity_const * delta
				local pmx, pmy = vectorFromAngle(angle, dist_0 - dist_1)
				local px, py = p:getPosition()
				p:setPosition(-pmx,-pmy)
			end
		end
	end
end

