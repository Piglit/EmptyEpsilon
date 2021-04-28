--- Basic station comms.
--
-- Station comms that allows buying ordnance, supply drop, and reinforcements.
-- Default script for any `SpaceStation`.
--
-- @script comms_station

-- uses `mergeTables`
require("utils.lua")

-- NOTE this could be imported
local MISSILE_TYPES = {"Homing", "Nuke", "Mine", "EMP", "HVLI"}

--- Main menu of communication.
--
-- - Prepares `comms_data`.
-- - If the station is not an enemy and no enemies are nearby, the dialog is
--   provided by `commsStationUndocked` or `commsStationDocked`.
--   (Back buttons go to the main menu in order to check for enemies again.)
--
-- @tparam PlayerSpaceship comms_source
-- @tparam SpaceStation comms_target
function commsStationMainMenu(comms_source, comms_target)
    if comms_target.comms_data == nil then
        comms_target.comms_data = {}
    end
    mergeTables(
        comms_target.comms_data,
        {
            friendlyness = random(0.0, 100.0),
            surrender_hull_threshold = math.random(40,80),
            weapons = {
                Homing = "neutral",
                HVLI = "neutral",
                Mine = "neutral",
                Nuke = "friend",
                EMP = "friend"
            },
            weapon_cost = {
                Homing = 2,
                HVLI = 2,
                Mine = 2,
                Nuke = 15,
                EMP = 10
            },
            services = {
                supplydrop = "friend",
                reinforcements = "friend"
            },
            service_cost = {
                supplydrop = 100,
                reinforcements = 150,
                phobos_reinforcement = 300,
                lindworm_reinforcement = 100,
                hornet_reinforcement = 100,
                adder_reinforcement = 200,
                fighterInterceptor = 150,
                fighterBomber = 175,
                fighterScout = 200,
                refitDrive = 150,
            },
            reputation_cost_multipliers = {
                friend = 1.0,
                neutral = 2.5
            },
            max_weapon_refill_amount = {
                friend = 1.0,
                neutral = 0.5
            },
            docked_comms_functions = {},
            undocked_comms_functions = {},
            enemy_comms_functions = {},
        }
    )

    local ret = nil
    if comms_source:isEnemy(comms_target) then
        if #comms_target.comms_data.enemy_comms_functions == 0 then
            return false
        end
        for _,f in ipairs(comms_target.comms_data.enemy_comms_functions) do
            ret = f(comms_source, comms_target)
            if ret ~= nil then
                return ret
            end
        end
        return true 
    end

    if comms_target:areEnemiesInRange(5000) then
        setCommsMessage(_("station-comms", "We are under attack! No time for chatting!"))
        return true
    end
    if not comms_source:isDocked(comms_target) then
        for _,f in ipairs(comms_target.comms_data.undocked_comms_functions) do
            ret = f(comms_source, comms_target)
            if ret ~= nil then
                return ret
            end
        end
        ret = commsStationUndocked(comms_source, comms_target)
    else
        for _,f in ipairs(comms_target.comms_data.docked_comms_functions) do
            ret = f(comms_source, comms_target)
            if ret ~= nil then
                return ret
            end
        end
        ret = commsStationDocked(comms_source, comms_target)
    end
    if ret ~= nil then
        return ret
    end
    return true
end

--- Handle communications while docked with this station.
--
-- @tparam PlayerSpaceship comms_source
-- @tparam SpaceStation comms_target
function commsStationDocked(comms_source, comms_target)
    local message
    if comms_source:isFriendly(comms_target) then
        message = string.format(_("station-comms", "Good day, officer! Welcome to %s.\nWhat can we do for you today?"), comms_target:getCallSign())
    else
        message = string.format(_("station-comms", "Welcome to our lovely station %s."), comms_target:getCallSign())
    end
    setCommsMessage(message)

    local reply_messages = {
        ["Homing"] = _("ammo-comms", "Do you have spare homing missiles for us?"),
        ["HVLI"] = _("ammo-comms", "Can you restock us with HVLI?"),
        ["Mine"] = _("ammo-comms", "Please re-stock our mines."),
        ["Nuke"] = _("ammo-comms", "Can you supply us with some nukes?"),
        ["EMP"] = _("ammo-comms", "Please re-stock our EMP missiles.")
    }

    for idx, missile_type in ipairs(MISSILE_TYPES) do
        if comms_source:getWeaponStorageMax(missile_type) > 0 then
            addCommsReply(
                string.format(_("ammo-comms", "%s (%d rep each)"), reply_messages[missile_type], getWeaponCost(comms_source, comms_target, missile_type)),
                function(comms_source, comms_target)
                    handleWeaponRestock(comms_source, comms_target, missile_type)
                end
            )
        end
    end
--    local ptype = player:getTypeName()
--    if isAllowedTo(comms_target.comms_data.services.fighters) then
--            if ptype == "Atlantis" or ptype == "Crucible" or ptype == "Maverick" or ptype == "Benedict" or ptype == "Kiriya" then
--                addCommsReply("Visit fighter bay", function()
--                    handleBuyShips()
--                end)
--            end
--    end
    if isAllowedTo(comms_target.comms_data.services.refitDrive) then
        if player:hasWarpDrive() ~= player:hasJumpDrive() then
            -- logical XOR with hasWarpDrive and hasJumpDrive
            addCommsReply("Refit your ships drive", function()
                handleChangeDrive()
            end)
        end
    end
end

function handleChangeDrive()
    if player:hasWarpDrive() and not player:hasJumpDrive() then
        setCommsMessage(string.format("Do you want us to change your warp drive to a jump drive? For only %i reputation.", getServiceCost("refitDrive")))
        addCommsReply("Make it so!", function()
            if not player:takeReputationPoints(getServiceCost("refitDrive")) then
                setCommsMessage("Insufficient reputation")
            else
                player:setWarpDrive(false)
                player:setJumpDrive(true)
                setCommsMessage("Consider it done.")
                return true
            end
        end)
    end
    if player:hasJumpDrive() and not player:hasWarpDrive() then
        setCommsMessage(string.format("Do you want us to change your jump drive to a warp drive? For only %i reputation.", getServiceCost("refitDrive")))
        addCommsReply("Make it so!", function()
            if not player:takeReputationPoints(getServiceCost("refitDrive")) then
                setCommsMessage("Insufficient reputation")
            else
                player:setWarpDrive(true)
                player:setJumpDrive(false)
                setCommsMessage("Consider it done.")
                return true
            end
        end)
    end
    addCommsReply("Back", mainMenu)
end

function handleBuyShips()
    setCommsMessage("Here you can start fighters that can be taken by your pilots. You do have a fighter pilot waiting, do you?")
    addCommsReply(string.format("Purchase unmanned MP52 Hornet Interceptor for %i reputation", getServiceCost("fighterInterceptor")), function()
        if not player:takeReputationPoints(getServiceCost("fighterInterceptor")) then
            setCommsMessage("Insufficient reputation")
        else
            local ship = PlayerSpaceship():setTemplate("MP52 Hornet"):setFactionId(player:getFactionId())
            ship:setAutoCoolant(true)
            ship:commandSetAutoRepair(true)
            ship:setPosition(comms_target:getPosition())
            setCommsMessage("We have dispatched " .. ship:getCallSign() .. " to be manned by one of your pilots")
            return true
        end
        addCommsReply("Back", mainMenu)
    end)
    addCommsReply(string.format("Purchase unmanned ZX-Lindworm Bomber for %i reputation", getServiceCost("fighterBomber")), function()
        if not player:takeReputationPoints(getServiceCost("fighterBomber")) then
            setCommsMessage("Insufficient reputation")
        else
            local ship = PlayerSpaceship():setTemplate("ZX-Lindworm"):setFactionId(player:getFactionId())
            ship:setAutoCoolant(true)
            ship:commandSetAutoRepair(true)
            ship:setPosition(comms_target:getPosition())
            setCommsMessage("We have dispatched " .. ship:getCallSign() .. " to be manned by one of your pilots")
            return true
        end
        addCommsReply("Back", mainMenu)
    end)
    addCommsReply(string.format("Purchase unmanned Adder MK7 Scout for %i reputation", getServiceCost("fighterScout")), function()
        if not player:takeReputationPoints(getServiceCost("fighterScout")) then
            setCommsMessage("Insufficient reputation")
        else
            local ship = PlayerSpaceship():setTemplate("Adder MK7"):setFactionId(player:getFactionId())
            ship:setAutoCoolant(true)
            ship:commandSetAutoRepair(true)
            ship:setPosition(comms_target:getPosition())
            setCommsMessage("We have dispatched " .. ship:getCallSign() .. " to be manned by one of your pilots")
            return true
        end
        addCommsReply("Back", mainMenu)
    end)
    addCommsReply("Back", mainMenu)
end

--- Handle weapon restock.
--
-- @tparam PlayerSpaceship comms_source
-- @tparam SpaceStation comms_target
-- @tparam string weapon the missile type
function handleWeaponRestock(comms_source, comms_target, weapon)
    if not comms_source:isDocked(comms_target) then
        setCommsMessage(_("station-comms", "You need to stay docked for that action."))
        return
    end

    if not isAllowedTo(comms_source, comms_target, comms_target.comms_data.weapons[weapon]) then
        local message
        if weapon == "Nuke" then
            message = _("ammo-comms", "We do not deal in weapons of mass destruction.")
        elseif weapon == "EMP" then
            message = _("ammo-comms", "We do not deal in weapons of mass disruption.")
        else
            message = _("ammo-comms", "We do not deal in those weapons.")
        end
        setCommsMessage(message)
        return
    end

    local points_per_item = getWeaponCost(comms_source, comms_target, weapon)
    local item_amount = math.floor(comms_source:getWeaponStorageMax(weapon) * comms_target.comms_data.max_weapon_refill_amount[getFriendStatus(comms_source, comms_target)]) - comms_source:getWeaponStorage(weapon)
    if item_amount <= 0 then
        local message
        if weapon == "Nuke" then
            message = _("ammo-comms", "All nukes are charged and primed for destruction.")
        else
            message = _("ammo-comms", "Sorry, sir, but you are as fully stocked as I can allow.")
        end
        setCommsMessage(message)
        addCommsReply(_("Back"), commsStationMainMenu)
    else
        if not comms_source:takeReputationPoints(points_per_item * item_amount) then
            setCommsMessage(_("needRep-comms", "Not enough reputation."))
            return
        end
        comms_source:setWeaponStorage(weapon, comms_source:getWeaponStorage(weapon) + item_amount)
        local message
        if comms_source:getWeaponStorage(weapon) == comms_source:getWeaponStorageMax(weapon) then
            message = _("ammo-comms", "You are fully loaded and ready to explode things.")
        else
            message = _("ammo-comms", "We generously resupplied you with some weapon charges.\nPut them to good use.")
        end
        setCommsMessage(message)
        addCommsReply(_("Back"), commsStationMainMenu)
    end
end

--- Handle communications when we are not docked with the station.
--
-- @tparam PlayerSpaceship comms_source
-- @tparam SpaceStation comms_target
function commsStationUndocked(comms_source, comms_target)
    local message
    if comms_source:isFriendly(comms_target) then
        message = string.format(_("station-comms", "This is %s. Good day, officer.\nIf you need supplies, please dock with us first."), comms_target:getCallSign())
    else
        message = string.format(_("station-comms", "This is %s. Greetings.\nIf you want to do business, please dock with us first."), comms_target:getCallSign())
    end
    setCommsMessage(message)

    -- supply drop
    if isAllowedTo(comms_source, comms_target, comms_target.comms_data.services.supplydrop) then
        addCommsReply(
            string.format(_("stationAssist-comms", "Can you send a supply drop? (%d rep)"), getServiceCost(comms_source, comms_target, "supplydrop")),
            --
            commsStationSupplyDrop
        )
    end

    -- reinforcements
    if isAllowedTo(comms_source, comms_target, comms_target.comms_data.services.reinforcements) then
        addCommsReply(
            string.format(_("stationAssist-comms", "Please send reinforcements! (%d rep)"), getServiceCost(comms_source, comms_target, "reinforcements")),
            --
            commsStationReinforcements
        )
    end
end

--- Ask for a waypoint and deliver supply drop to it.
--
-- Uses the script `supply_drop.lua`
--
-- @tparam PlayerSpaceship comms_source
-- @tparam SpaceStation comms_target
function commsStationSupplyDrop(comms_source, comms_target)
    if comms_source:getWaypointCount() < 1 then
        setCommsMessage(_("stationAssist-comms", "You need to set a waypoint before you can request backup."))
    else
        setCommsMessage(_("stationAssist-comms", "To which waypoint should we deliver your supplies?"))
        for n = 1, comms_source:getWaypointCount() do
            addCommsReply(
                formatWaypoint(n),
                function(comms_source, comms_target)
                    local message
                    if comms_source:takeReputationPoints(getServiceCost(comms_source, comms_target, "supplydrop")) then
                        local position_x, position_y = comms_target:getPosition()
                        local target_x, target_y = comms_source:getWaypoint(n)
                        local script = Script()
                        script:setVariable("position_x", position_x):setVariable("position_y", position_y)
                        script:setVariable("target_x", target_x):setVariable("target_y", target_y)
                        script:setVariable("faction_id", comms_target:getFactionId()):run("supply_drop.lua")
                        message = string.format(_("stationAssist-comms", "We have dispatched a supply ship toward %s."), formatWaypoint(n))
                    else
                        message = _("needRep-comms", "Not enough reputation!")
                    end
                    setCommsMessage(message)
                    addCommsReply(_("Back"), commsStationMainMenu)
                end
            )
        end
    end
    addCommsReply(_("Back"), commsStationMainMenu)
end

--- Ask for a waypoint and send reinforcements to defend it.
--
-- @tparam PlayerSpaceship comms_source
-- @tparam SpaceStation comms_target
function commsStationReinforcements(comms_source, comms_target)
    setCommsMessage(_("commsStation", "What kind of reinforcement ship would you like?"))
    addCommsReply(string.format(_("commsStation", "MT52 Hornet (%d rep)"), getServiceCost(comms_source, comms_target, "hornet_reinforcement")), function()
        string.format("")
        commsStationSpecificReinforcement(comms_source, comms_target, "hornet_reinforcement")
    end)
    addCommsReply(string.format(_("commsStation", "WX-Lindworm (%d rep)"), getServiceCost(comms_source, comms_target, "lindworm_reinforcement")), function()
        string.format("")
        commsStationSpecificReinforcement(comms_source, comms_target, "lindworm_reinforcement")
    end)
    addCommsReply(string.format(_("commsStation", "Adder MK5 (%d rep)"), getServiceCost(comms_source, comms_target, "adder_reinforcement")), function()
        string.format("")
        commsStationSpecificReinforcement(comms_source, comms_target, "adder_reinforcement")
    end)
    addCommsReply(string.format(_("commsStation", "Phobos T3 (%d rep)"), getServiceCost(comms_source, comms_target, "phobos_reinforcement")), function()
        string.format("")
        commsStationSpecificReinforcement(comms_source, comms_target, "phobos_reinforcement")
    end)
    addCommsReply(_("button", "Back"), commsStationMainMenu)
end
function commsStationSpecificReinforcement(comms_source, comms_target, reinforcement_type)
    if comms_source:getWaypointCount() < 1 then
        setCommsMessage(_("stationAssist-comms", "You need to set a waypoint before you can request reinforcements."))
    else
        setCommsMessage(_("stationAssist-comms", "To which waypoint should we dispatch the reinforcements?"))
        for n = 1, comms_source:getWaypointCount() do
            addCommsReply(
                formatWaypoint(n),
                function(comms_source, comms_target)
                    local message
                    if comms_source:takeReputationPoints(getServiceCost(comms_source, comms_target, reinforcement_type)) then
                        local reinforcement_template = {
                            ["hornet_reinforcement"] =	    "MT52 Hornet",
                            ["lindworm_reinforcement"] =	"WX-Lindworm",
                            ["adder_reinforcement"] =       "Adder MK5",
                            ["phobos_reinforcement"] =	    "Phobos T3",
                        }
                        local ship = CpuShip():setFactionId(comms_target:getFactionId()):setPosition(comms_target:getPosition()):setTemplate(reinforcement_template[reinforcement_type]):setScanned(true):orderDefendLocation(comms_source:getWaypoint(n))
                        message = string.format(_("stationAssist-comms", "We have dispatched %s to assist at %s."), ship:getCallSign(), formatWaypoint(n))
                    else
                        message = _("needRep-comms", "Not enough reputation!")
                    end
                    setCommsMessage(message)
                    addCommsReply(_("Back"), commsStationMainMenu)
                end
            )
        end
    end
    addCommsReply(_("Back"), commsStationMainMenu)
end

--- isAllowedTo
--
-- @tparam PlayerSpaceship comms_source
-- @tparam SpaceStation comms_target
-- @tparam string state
-- @treturn boolean true if allowed
function isAllowedTo(comms_source, comms_target, state)
    -- TODO reconsider the logic of these conditions
    if state == "friend" and comms_source:isFriendly(comms_target) then
        return true
    end
    if state == "neutral" and not comms_source:isEnemy(comms_target) then
        return true
    end
    return false
end

--- Return the number of reputation points that a specified weapon costs for the
-- current player.
--
-- @tparam PlayerSpaceship comms_source
-- @tparam SpaceStation comms_target
-- @tparam string weapon the missile type
-- @treturn integer the cost
function getWeaponCost(comms_source, comms_target, weapon)
    local relation = getFriendStatus(comms_source, comms_target)
    return math.ceil(comms_target.comms_data.weapon_cost[weapon] * comms_target.comms_data.reputation_cost_multipliers[relation])
end

--- Return the number of reputation points that a specified service costs for
-- the current player.
--
-- @tparam PlayerSpaceship comms_source
-- @tparam SpaceStation comms_target
-- @tparam string service the service
-- @treturn integer the cost
function getServiceCost(comms_source, comms_target, service)
    return math.ceil(comms_target.comms_data.service_cost[service])
end

--- Return "friend" or "neutral".
--
-- @tparam PlayerSpaceship comms_source
-- @tparam SpaceStation comms_target
-- @treturn string the status
function getFriendStatus(comms_source, comms_target)
    if comms_source:isFriendly(comms_target) then
        return "friend"
    else
        return "neutral"
    end
end

--- Format integer i as "WP i".
--
-- @tparam integer i the index of the waypoint
-- @treturn string "WP i"
function formatWaypoint(i)
    return string.format(_("stationAssist-comms", "WP %d"), i)
end

-- `comms_source` and `comms_target` are global in comms script.
commsStationMainMenu(comms_source, comms_target)
