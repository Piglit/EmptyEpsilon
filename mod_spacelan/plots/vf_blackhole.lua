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
}

function vf_blackhole.triggerCollapse(art, player, collected)
	-- called as artifact callback, whenever an black hole stabilazier is picked up or destroyed by collision with player
	-- not called, when artifact is destroyed via other means (like falling into a black hole)
	local self = vf_blackhole
	local terrain_module = art.terrain_module
	local hole = art.hole
	hole.radius_orig = hole:getRadius()
	hole.gravity_limit_orig = gravity_util:getLimit(hole)
	hole.collapse_time_total = hole.radius_orig / 100	-- speed: 1u in 10 sec
	hole.collapse_time_bygone = 0.0001	-- must not be 0 to prevent division by 0
	hole.collapse_progress = 0.0
	-- center of mass
	if hole.distance ~= nil then	-- nil for single black holes
		hole.com_dist_orig = hole.distance
		hole.com_dist_delta = hole.com_dist_orig / hole.collapse_time	-- com travels this distance per second 
		hole.com_rota_speed_delta = hole.speed / hole.collapse_time	-- double the speed in collapse_time seconds
	end

	if self.blackholes_to_collapse[hole] == nil then
		self.blackholes_to_collapse[hole] == terrain_module
	end
end

function vf_blackhole:update(dt)
	for hole, tm in pairs(self.blackholes_to_collapse) do
		if hole ~= nil and hole:isValid() then
			hole.collapse_time_bygone = hole.collapse_time_bygone + dt
			hole.collapse_progress = hole.collapse_time_total / hole.collapse_time_bygone
			if hole.collapse_progress < 1.0 then
				-- collapse was triggered, shrink it
				local new_factor = 1 - hole.collapse_progress	-- from 1 to 0
				hole:setRadius(hole.radius_orig * new_factor)
				gravity_util:setLimit(hole, hole.gravity_limit_orig * new_factor)	-- outer limit shrinks linaer, gravity pull shrinks quadratic
				-- TODO add gravity wave
				if #tm.holes > 1 and hole.center ~= nil then
					-- move center of mass
					local amount = hole.com_dist_delta * dt
					local dir = angleRotation(hole, hole.center)
					local speed_incr = hole.com_rota_speed_delta * dt
					for _,bh in tm.holes do
						wh_rota.move_center(bh, amount, dir)	-- also adjusts distance
						bh.speed = bh.speed + speed_incr
						if hole ~= bh and distance(hole,bh) < hole:getRadius() + bh:getRadius() then
							-- TODO merge when colliding with other black hole
						end
					end
					-- move towards new center of mass
					if hole.distance ~= nil then
						hole.distance = hole.com_dist_orig * new_factor
					end
					-- TODO adjust artifacts rotation, since they don't rotate around the black holes, but the zone center!
				end

			else
				-- TODO explode
				hole:destroy()
			end
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


