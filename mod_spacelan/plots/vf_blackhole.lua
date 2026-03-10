-- black hole collapse mechanic

	-- black hole collapse:
	-- single black hole - what can happen:
	-- gravity is reduced
	-- black hole gets smaller
	-- gravitational wave: huge emp
	-- neutron star - still has gravity but is a "planet"
	-- OR mass emission: asteroid shower
	-- multi bh: ones gravity is reduced, gets smaller
	-- moves closer to center, others, too. orbital speed gets faster
	-- new bh is formed, once they touch
	-- big emp

vf_blackhole = {
	blackholes_to_collapse = {},	-- hole -> terrain_module
	COLLAPSE_SPEED = 100,	-- should be 100 for playing
}

function vf_blackhole.triggerCollapse(art, player, collected)
	-- called as artifact callback, whenever an black hole stabilazier is picked up or destroyed by collision with player
	-- not called, when artifact is destroyed via other means (like falling into a black hole)
	local self = vf_blackhole
	local terrain_module = art.terrain_module
	local hole = art.hole
	hole.radius_orig = hole:getRadius()
	hole.gravity_limit_orig = gravity_util:getLimit(hole)
	hole.collapse_time_total = hole.radius_orig / vf_blackhole.COLLAPSE_SPEED -- speed: 1u in 10 sec
	hole.collapse_time_bygone = 0.0
	hole.collapse_progress = 0.0
	hole.collapsing = true	-- can be set to false to stop the collapse
	-- center of mass
	if hole.distance ~= nil then	-- nil for single black holes
		hole.com_dist_delta = hole.distance * 1.5 / hole.collapse_time_total
		hole.com_rota_speed_delta = hole.speed / hole.collapse_time_total	-- double the speed in collapse_time_total seconds
	end

	if self.blackholes_to_collapse[hole] == nil then
		self.blackholes_to_collapse[hole] = terrain_module
	end
end

function vf_blackhole:recalculateCenterOfMass(holes)
	-- clean up first
	for idx,bh in ipairs(holes) do
		if not bh:isValid() then
			table.remove(holes, idx)
			-- this messes with ipairs, so recall this function again and abort afterwards
			self:recalculateCenterOfMass(holes)
			return
		end
	end
	local x, y = 0,0
	local mass_total = 0
	for idx,bh in ipairs(holes) do
		-- now everything is valid
		local x_b, y_b = bh:getPosition()
		local mass = bh:getRadius()
		mass_total = mass_total + mass
		x = x + x_b * mass
		y = y + y_b * mass
	end
	x = x/mass_total
	y = y/mass_total
	for idx,bh in ipairs(holes) do
		wh_rota.set_center(bh, x, y)
	end
end

function vf_blackhole:collapse(hole, dt)
	hole.collapse_time_bygone = hole.collapse_time_bygone + dt
	hole.collapse_progress = hole.collapse_time_bygone / hole.collapse_time_total 
	if hole.collapse_progress < 1.0 then
		-- collapse was triggered, shrink it
		local new_factor = 1 - hole.collapse_progress	-- from 1 to 0
		hole:setRadius(hole.radius_orig * new_factor)
		gravity_util:setLimit(hole, hole.gravity_limit_orig * new_factor)	-- outer limit shrinks linaer, gravity pull shrinks quadratic
		-- TODO add gravity wave
		if hole.distance ~= nil then
			-- move towards new center of mass
			hole.distance = hole.distance - hole.com_dist_delta * dt --_orig * new_factor
		end
	else
		-- TODO explode
		hole:destroy()
		self.blackholes_to_collapse[hole] = nil
	end
end

function vf_blackhole:collide(hole, tm, dt)
	for idx,bh in ipairs(tm.holes) do
		if hole ~= bh and distance(hole,bh) < hole:getRadius() + bh:getRadius() and hole:getRadius() < bh:getRadius() then
			-- merge smaller one when colliding with other black hole
			hole.collapse_time_bygone = hole.collapse_time_bygone + dt	-- double collapse speed
			bh:setRadius(bh:getRadius() + dt*self.COLLAPSE_SPEED)
			gravity_util:setLimit(bh, gravity_util:getLimit(bh) + dt*self.COLLAPSE_SPEED)
			-- stop collapse, but still consider this hole for falling into other holes
			bh.collapsing = false
		end
	end
end

function vf_blackhole:update(dt)
	for hole, tm in pairs(self.blackholes_to_collapse) do
		if hole ~= nil and hole:isValid() and hole.collapsing then
			-- accelerate all holes
			if hole.com_rota_speed_delta ~= nil then
				local speed_incr = hole.com_rota_speed_delta * dt
				for idx,bh in ipairs(tm.holes) do
					if bh:isValid() then
						bh.speed = bh.speed + speed_incr
					end
				end
			end
			self:collapse(hole, dt)
		end
		if hole:isValid() and #tm.holes > 1 and hole.center ~= nil then
			wh_rota:update(0)	-- set new position from modified distances
			self:recalculateCenterOfMass(tm.holes)
			self:collide(hole, tm, dt)
		end
	end
end


-- example
-- dist = r_tm/3, r_bh = r_tm/4
-- 24k 
-- dist = 8
-- r = 6 dia=12
-- grav_limit = 24k (rad or rad*2/3)

-- physics
-- r = 2GM/c² - m is mass, so r can be reduced linear
-- distance to binary center of mass d1:
-- d1 = a * m2/(m1+m2) = a/(1+(m1/m2)), a = dist of mass centers, mn is mass of obj

-- m1,m2 = 6
-- a = 16
-- d = a/1+1
-- 


