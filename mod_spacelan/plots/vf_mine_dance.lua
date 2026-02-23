-- rotating and seeking mines mechanic

vf_mine_dance = {
	dancing_mines = {},
	seeking_mines = {},
}

function vf_mine_dance:addDancingMine(centre_object, mine, limit, clockwise)
	if self.dancing_mines[centre_object] == nil then
		self.dancing_mines[centre_object] = {}
	end
	table.insert(self.dancing_mines[centre_object], mine)
	if clockwise then
		mine.angular_velocity = 1	-- TODO confirm direction
	else
		mine.angular_velocity = -1
	end
	mine.radial_velocity = 1
	mine.limit = limit
	mine.vector_x = 0
	mine.vector_y = 0
	mine.is_dancing = true
end

function vf_mine_dance:addSeekingMine(mine)
	if mine.vector_x == nil then
		mine.vector_x = 0
		mine.vector_y = 0
	end
	table.insert(self.seeking_mines, mine)
end

function vf_mine_dance:updateDance(delta)
	if delta == 0 then return end
	for centre, mines in pairs(self.dancing_mines) do
		if not centre:isValid() then
			for idx,mine in ipairs(mines) do
				mine.is_dancing = false
				self:addSeekingMine(mine)
			end
			self.dancing_mines[centre] = nil
		else
			local x0,y0 = centre:getPosition()
			arrayFilter(mines, function(obj)
				return obj ~= nil and obj:isValid() and obj.is_dancing
			end)
			for idx,mine in ipairs(mines) do
				assert(mine.angular_velocity ~= nil)
				local x1,y1 = mine:getPosition()
				local dist = distance(x0, y0, x1, y1)
				if dist <= mine.limit and dist > 0.001 then
					local angle = angleRotation(x0, y0, x1, y1)
					local target_angle = angle + mine.angular_velocity * delta
					local target_dist = dist + mine.radial_velocity * delta
					local x2,y2 = vectorFromAngle(target_angle, target_dist)
					mine:setPosition(x0+x2,y0+y2)
					-- TODO test: right direction or sign/order error?
					mine.vector_x = (x0+x2-x1)	/ delta
					mine.vector_y = (y0+y2-y1)	/ delta
					-- speed up
					-- after 60 sec we travelled 60 deg and raised speed by 1 
					-- after 6 min we have gone full circle and speed is raised by 6
					mine.radial_velocity = mine.radial_velocity + delta/60
				else
					mine.is_dancing = false
					self:addSeekingMine(mine)
				end
			end
		end
	end
end

function vf_mine_dance:updateSeek(delta)
	local targets = getActivePlayerShips()
	arrayFilter(self.seeking_mines, function(obj)
		return obj ~= nil and obj:isValid()
	end)
	for _, mine in ipairs(self.seeking_mines) do
		local x0,y0 = mine:getPosition()
		for _,target in ipairs(targets) do
			if distance(target, mine) < 5000 then
				-- simple implementation
				local x1,y1 = target:getPosition()
				local x2,y2 = x1-x0, y1-y0
				local dist = distance(x0,y0,x1,y1)
				if dist > 0.001 then
					x2,y2 = x2*delta/dist, y2*delta/dist	-- unit vector
					mine.vector_x, mine.vector_y = mine.vector_x + x2, mine.vector_y + y2
				end
			end
		end
		local x3,y3 = x0 + mine.vector_x*delta, y0 + mine.vector_y*delta
		-- finite and nan check
		if x3 > -math.huge and x3 < math.huge and x3 == x3 and
		   y3 > -math.huge and y3 < math.huge and y3 == y3 then
			mine:setPosition(x3,y3)
		end
	end
end

function vf_mine_dance:update(delta)
	self:updateDance(delta)
	self:updateSeek(delta)
end
