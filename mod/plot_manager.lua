--[[ The plot_manager calls init, update and callback functions of all managed plot_modules, whenever the function is called from the game.
-- This is done to make scripting more modular. You can now have multiple script files, with their own init, update and callback functions, and they are called from here.
--]]


plot_manager = {}

function plot_manager:init(plot_modules)
	self.plot_modules = plot_modules
	-- distribute callbacks to modules that have an onNewPlayerShip function
	onNewPlayerShip(function(ship)
		for _,module in ipairs(plot_modules) do
			if module.onNewPlayerShip ~= nil then
				module:onNewPlayerShip(ship)
			end
		end
	end)

	-- call init and initTest on all modules that have those functions
	for _,module in ipairs(plot_modules) do
		if module.init ~= nil then
			module:init()
		end
		if TEST and module.initTest ~= nil then
			module:initTest()
		end
	end

	-- expose everything to storage for outside script access.
	-- note that plot_modules is index-addressed, which may not be optimal for scripting
	local storage = getScriptStorage()
	storage["plot_manager"] = self

end

function plot_manager:update(delta)
	-- only call getActivePlayerShips once per update
	local active_player_ships = getActivePlayerShips()

	-- call update function of all modules
	for _,module in ipairs(self.plot_modules) do
		if module.update ~= nil then
			module:update(delta)
		end
		if TEST and module.updateTest ~= nil then
			module:updateTest()
		end
		if module.updatePlayerShip ~= nil then
			for _,ship in ipairs(active_player_ships) do
				module:updatePlayerShip(delta, ship)
			end
		end
	end
end

-- This is the global update function!
-- make sure to not have another one defined elsewhere!
function update(delta)
	plot_manager:update(delta)
end
