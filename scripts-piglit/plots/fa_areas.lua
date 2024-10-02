fa_areas = {}

require "plots/fa_area_mining.lua"

function fa_areas:init()
	self.mining = fa_area_mining:init(9*20000, 5*20000)
end
