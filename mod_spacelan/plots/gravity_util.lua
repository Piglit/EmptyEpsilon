gravity_util = {
    gravity_const = 100000000,
	sources = {},	-- source -> limit
	exceptions = {}
}

function gravity_util.raiseGravity()
    gravity_util.gravity_const = gravity_util.gravity_const * 0.75
	print("AntiGravity is now "..(gravity_util.gravity_const/1000000) .. "%")
end

function gravity_util.lowerGravity()
    gravity_util.gravity_const = gravity_util.gravity_const * 1.25
	print("AntiGravity is now "..(gravity_util.gravity_const/1000000) .. "%")
end

function gravity_util:gm_menu()
    addGMFunction(_("buttonGM", "Lower Gravity"), gravity_util.lowerGravity)
    addGMFunction(_("buttonGM", "Raise Gravity"), gravity_util.raiseGravity)
end

function gravity_util.addGravitySource(planet, outer_limit)
	if planet ~= nil and planet:isValid() then
		gravity_util.sources[planet] = outer_limit
--		table.insert(gravity_util.sources, {planet, outer_limit})
	end
end

function gravity_util.addException(playership)
	table.insert(gravity_util.exceptions, playership)
end

function gravity_util:updatePlayerShip(delta, p)
	if p ~= nil and p:isValid() and p:getDockingState() == 0 then
		if arrayContains(self.exceptions, p) then
			return
		end
		--for idx,s in ipairs(gravity_util.sources) do
			--local source = s[1]
			--local limit = s[2]
		for source, limit in pairs(gravity_util.sources) do
			if source == nil or not source:isValid() then
				--table.remove(gravity_util.source, idx)
				gravity_util[source] = nil
				return
			end
			local angle = angleRotation(p, source)
			local dist_0 = distance(p, source)
			if dist_0 < limit then
				local dist_1 = (limit-dist_0)^2 / self.gravity_const * delta
				local pmx, pmy = vectorFromAngle(angle, dist_0 - dist_1)
				local sx, sy = source:getPosition()
				p:setPosition(sx-pmx,sy-pmy)
			end
		end
	end
end

function gravity_util:getLimit(source)
	return self.sources[source]
end

function gravity_util:setLimit(source, limit)
	-- same as addGravitySource
	assert(self.sources[source] ~= nil and self.sources[source]:isValid())
	self.sources[source] = limit
end
