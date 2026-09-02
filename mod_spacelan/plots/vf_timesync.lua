--[[
Start game super slow
call timesync that syncs game time with real time
on first player ship arrived: unslow
--]]

vf_timesync = {
	desired_time = 0,
	timesync_active = false
}


function vf_timesync:init()
	superSlowGame()	-- one in game second per real time minute
end

function vf_timesync:sync_time(time_in_sec)
	-- give the time in seconds of that day
	assert(type(time_in_sec) == "number")
	-- set game time minute to real time hour
	self.desired_time = time_in_sec/60
	sc_time = getScenarioTime()
	if self.desired_time > sc_time then
		self.desired_time = self.desired_time + (self.desired_time - sc_time)/60
		unslowGame()
		self.timesync_active = true
	end
end

function vf_timesync:sync_time_human_readable(time_str)
	-- format "12:34"
	local idx_sep = string.find(time_str, ":")
	local hour = string.sub(time_str, 1, idx_sep-1)
	local minute = string.sub(time_str, idx_sep+1)
	local seconds = tonumber(hour) * 60 * 60 + tonumber(minute) * 60
	return self:sync_time(seconds)
end

function vf_timesync:onNewPlayerShip()
	-- whenever a player spawns start running normally
	unslowGame()
end

function vf_timesync:update(delta)
	if self.timesync_active then
		if self.desired_time <= getScenarioTime() then
			self.timesync_active = false
			superSlowGame()
		end
	end
end

function vf_timesync:initTest()
	self:sync_time(90*60)	-- 1:30
end
