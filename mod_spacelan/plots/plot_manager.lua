--[[ The plot_manager calls init, update and callback functions of all managed plot_modules, whenever the function is called from the game.
-- This is done to make scripting more modular. You can now have multiple script files, with their own init, update and callback functions, and they are called from here.
--]]

PLOT_DIRECTORY = "" -- use "plots/" for spacelan or "" for sw

plot_manager = {
	plot_modules_by_name = {},	-- unordered, used for script access
	plot_modules_by_index= {},	-- this one is ordered
	init_run = false,
}


-- distributes global script calls (like onNewPlayerShip()) to all modules.
-- this function can be called multiple times.
-- Param plot_modules: list of modules as string or table:
-- string: requires lua file, that must have a global table with the same name as the file.
-- table (string, table): name and global table.
function plot_manager:init(plot_modules)
	if not self.init_run then
		-- distribute callbacks to modules that have an onNewPlayerShip function
		onNewPlayerShip(function(ship)
			for _,module in ipairs(self.plot_modules_by_index) do
				if module.onNewPlayerShip ~= nil then
					module:onNewPlayerShip(ship)
				end
			end
			ship:onProbeLaunch(plot_manager.onProbeLaunch)
		end)

		-- expose everything to storage for outside script access.
		local storage = getScriptStorage()
		storage["plot_manager"] = self

		self.init_run = true
	end

	for i, module_name in ipairs(plot_modules) do
		assert(self.plot_modules_by_name[module_name] == nil, "module " ..i.. " is already initialised.")
		local name, module
		if type(module_name) == "table" then
			-- modules global table is given as parameter
			name = module_name[1]
			module = module_name[2]
			assert(type(name) == "string", "plot_module name is not a string")
		elseif type(module_name) == "string" then
			-- require file and store global object in modules
			name = module_name
			require(PLOT_DIRECTORY..name..".lua")
			module = _G[name]	-- get the global table of the module with the same name
			assert(module ~= nil, name .. " is not a global table in "..PLOT_DIRECTORY..name..".lua")
		end
		assert(type(module) == "table", "plot_module table is not a table but "..type(module))

		self.plot_modules_by_name[name] = module
		table.insert(self.plot_modules_by_index, module)

		-- call init and initTest on all modules that have those functions
		if module.init ~= nil then
			module:init()
		end
		if TEST and module.initTest ~= nil then
			module:initTest()
		end
	end
	self.gm_main_menu()

	-- expose everything to storage for outside script access.
	local storage = getScriptStorage()
	storage["plot_manager"] = self
end

function plot_manager.onProbeLaunch(ship, probe)
	for _,module in ipairs(plot_manager.plot_modules_by_index) do
		if module.onProbeLaunch ~= nil then
			module:onProbeLaunch(ship, probe)
		end
	end
end

function plot_manager.gm_main_menu()
	clearGMFunctions()
	onGMClick(nil)
	for _,module in ipairs(plot_manager.plot_modules_by_index) do
		if module.gm_menu ~= nil then
			module:gm_menu()	-- create gm functions
		end
	end
end

-- global function for back to menu button
function gm_menu_back()
    addGMFunction(_("buttonGM", "Back to Main Menu"),plot_manager.gm_main_menu)
end

function plot_manager:update(delta)
	-- only call getActivePlayerShips once per update
	local active_player_ships = getActivePlayerShips()

	-- call update function of all modules
	for _,module in ipairs(self.plot_modules_by_index) do
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
