fa_areas = {}

require "plots/fa_area_mining.lua"

function fa_areas:init()
	self.mining = fa_area_mining:init(10000, 0)
end
