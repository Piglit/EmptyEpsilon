
-- old preflight code - not working without adjustments

function init()
    current_preflight_player = nil
    --preflight_checklist_comms = nil
    preflight_queue = {}
    preflight_target_practice_number = 0

end

function preparePreflight(player)
    table.insert(preflight_queue, player)
    player.preflight_queue = {}
    player.preflight_queue_current_index = 1
    player.preflight_state = nil
    
    addPreflightCheck(player, "dock", "wait", {
        check_fun = preflightDelay
    })

    addPreflightCheck(player, "greet", "preflight", {
        check_fun = pfGreet,    
        post_comms = {
            "Launch sequence initiated.",
            "Proceed with pre-flight checks.",
            {"Comms check: come in, %s %s", "yellow", 
                function (str,d,p,c) return string.format(str, p:getTypeName(), p:getDescription()) end
            },
            {"wait or repeat until crew responds", "cyan"},
            "Your communication system seems to be working.",
            "Please transmit your transponder code",
            {"Transponder code / callsign: %s", "cyan",
                function (str,d,p,c) return string.format(str, p:getCallSign()) end
            },
            {"Transponder code %s confirmed.", "yellow",
                function (str,d,p,c) return string.format(str, p:getCallSign()) end
            },
        }
    })
    
    addPreflightCheck(player, "systems", "preflight", {
        pre_fun = function(d,p,c) p.start_next_system_idx = 1 end,     --reactor
        pre_comms = {
            "Systems check:",
            "Power up your reactor to 100% from the Engineering console, as you are currently in powered down mode.",
        },
        check_fun = pfSystemsCheck,
        post_comms = {"All engineering systems are go."},
    })
    
    addPreflightCheck(player, "heat", "preflight", {
        enable_fun = function(d,p,c)
            for _,sys in ipairs(SYSTEMS) do
                if p:hasSystem(sys) and p:getSystemHeat(sys) > 0 then
                    return true
                end
            end
            return false
        end,
        pre_comms = {
            "Double check that none of your systems are above 100% power.",
            "Otherwise that system will overheat soon, damaging it.",
            "You may need to direct coolant to a system that has built up heat."
        },
        check_fun = function(d,p,c)
            for _,sys in ipairs(SYSTEMS) do
                if p:hasSystem(sys) and p:getSystemHeat(sys) > 0.1 then
                    return false
                end
            end
            return true
        end,
    })

    addPreflightCheck(player, "scan-1", "preflight", {
        enable_fun = function(d,p,c) return p:getCanScan() and (p:hasPlayerAtPosition("science") or p:hasPlayerAtPosition("operations")) end,
        pre_fun = function(d,p,c)
            pfTargetPractice(d,p,c) 
            practice:setScanned(false)
            end,
        pre_comms = {
            "Starting sensor check.",
            "You should see an unidentified object on your screens.",
            "Select it on your sensor console and perform a scan on it.",
        },
        check_fun = function(d,p,c)
            if practice == nil or not practice:isValid() then
                return "abort"
            end
            return practice:isScannedBy(p)
        end,
        abort_comms = {
            "Contact with target lost.",
            "Sensor check failed.",
            "Notice that you will have to pay for destroyed targeting practice droids.",
            "Launching another droid.",
        },
        post_comms = {
            {"Scan complete, target scanned.", "cyan"},
            "You should be able to see some details of the object. Confirm the type of the object.",
            {"Confirm type name: %s", "cyan",
                function (str,d,p,c) return string.format(str, practice:getTypeName()) end
            },
            
        }
    })
    
    addPreflightCheck(player, "scan-2", "preflight", {
        enable_fun = function(d,p,c) return p:getCanScan() and (p:hasPlayerAtPosition("science") or p:hasPlayerAtPosition("operations")) and areBeamShieldFrequenciesUsed() and p:hasSystem("frontshield")  end,
        pre_fun = pfTargetPractice,
        pre_comms = {
            "You may perform a second scan to get a tactical analysis of the object.",
        },
        check_fun = function(d,p,c)
            return true 
--            if practice == nil or not practice:isValid() then
--                return "abort"
--            end
--            return practice:isFullyScannedBy(p)
        end,
        abort_comms = {
            "Contact with target lost.",
            "Sensor check failed.",
            "Notice that you will have to pay for destroyed targeting practice droids.",
            "Launching another droid.",
            "Select it on your sensor console and perform a scan on it.",
            "When the scan is complete, you should be able to see some details of the object."
        },
--        post_comms = {
--            {"Second scan complete.", "cyan"},
--            "Switch from target description to tactical analysis.",
--            "Find the shield frequency, where your shields would receive the least damage by the object's lasers.",
--            {"Confirm optimal shield frequency: %d THz", "cyan", 
--                function (str,d,p,c) return string.format(str, practice:getBeamFrequency() * 20 +400) end
--            },
--            "Sensor check complete."
--        }
    })
    
    addPreflightCheck(player, "shields-1", "preflight", {
        enable_fun = function(d,p,c) return p:hasSystem("frontshield") end,
        pre_comms = {
            "Starting shields check.",
            "Activate your shields from your weapons or engineering console."
        },
        check_fun = function(d,p,c) return p:getShieldsActive() end,
        post_comms = {
            {"Shields are active", "cyan"}
        }
    })
    
    addPreflightCheck(player, "shields-freq", "preflight", {
        enable_fun = function(d,p,c) return p:getCanScan() and (p:hasPlayerAtPosition("science") or p:hasPlayerAtPosition("operations")) and (p:hasPlayerAtPosition("weapons") or p:hasPlayerAtPosition("engineering+")) and areBeamShieldFrequenciesUsed() and p:hasSystem("frontshield")  end,
        pre_fun = pfTargetPractice,
        pre_comms = {
            {"Recalibrate your shields to %s THz", "yellow", 
            function (str,d,p,c) return string.format(str, practice:getBeamFrequency() * 20 +400) end
            }
        },
        check_fun = function(d,p,c)
            if practice == nil or not practice:isValid() then
                return "abort"
            end
            return p:getShieldsFrequency() == practice:getBeamFrequency()
        end,
        abort_comms = {
            "Contact with target lost.",
            "Notice that you will have to pay for destroyed targeting practice droids.",
            "Launching another droid.",
        },
        post_comms = {
            {"Calibrating shield frequency.", "cyan"},
            "Notice that calibrating shields does take some time and will deactivate the shields until calibration is complete.",
            "Shield are go."
        }
    })
    
    addPreflightCheck(player, "shields-2", "preflight", {
        enable_fun = function(d,p,c) return p:hasSystem("frontshield") and p:getShieldsActive() end,
        pre_comms = {
            "Deactivate your shields to complete shield check."
        },
        check_fun = function(d,p,c) return not p:getShieldsActive() end,
        post_comms = {
            {"Shields are inactive", "cyan"},
            "Shield check complete."
        }
    })
    
    addPreflightCheck(player, "missile", "preflight", {
        enable_fun = function(d,p,c) return p:hasSystem(SYS_MISSILESYSTEM) end,
        pre_comms = {
            "Starting missile system check.",
            "Load your missile tubes.",
            "Do not fire any missiles during the pre-flight sequence."
        },
        check_fun = function(d,p,c)
            return p:getWeaponTubeLoadType(0) ~= nil 
        end,
        post_comms = {
            {"Missile loaded.", "cyan"},
        }
            
    })
    
    addPreflightCheck(player, "target-1", "preflight", {
        enable_fun = function(d,p,c) return p:hasSystem(SYS_BEAMWEAPONS) or p:hasSystem(SYS_MISSILESYSTEM) end,
        pre_fun = pfTargetPractice,
        pre_comms = {
            "Starting target system check.",
            {"Select %s on your weapons console.", "yellow",
                function (str,d,p,c) return string.format(str, practice:getCallSign()) end
            }
        },
        check_fun = function(d,p,c)
            if practice == nil or not practice:isValid() then
                return "abort"
            end
            return p:getTarget() == practice
        end,
        abort_comms = {
            "Contact with target lost.",
            "Notice that you will have to pay for destroyed targeting practice droids.",
            "Launching another droid.",
        },
        post_comms = {
            {"Target locked.", "cyan"},
        },
    })
    
    addPreflightCheck(player, "beams", "preflight", {
        enable_fun = function(d,p,c) return p:hasSystem(SYS_BEAMWEAPONS) and p:hasPlayerAtPosition("weapons") and p:getCanScan() and areBeamShieldFrequenciesUsed() end,
        pre_fun = pfTargetPractice,
        pre_comms = {
            "Starting laser system check.",
            {"Set your laser beams to a frequency of %d THz.", "yellow",
                function (str,d,p,c) return string.format(str, math.abs((((practice:getShieldsFrequency() + 10) % 20) * 20 +400))) end
            }
        },
        check_fun = function(d,p,c)
            if practice == nil or not practice:isValid() then
                return "abort"
            end
            return math.abs(((practice:getShieldsFrequency() + 10) % 20) -p:getBeamFrequency()) <= 1
        end,
        abort_comms = {
            "Contact with target lost.",
            "Notice that you will have to pay for destroyed targeting practice droids.",
            "Launching another droid.",
        },
        post_comms = {
            {"Frequency calibrated to %s THz", "cyan", function (str,d,p,c) return string.format(str, p:getBeamFrequency()*20+400) end},
        },
    })

    addPreflightCheck(player, "target-2", "preflight", {
        enable_fun = function(d,p,c) return p:hasSystem(SYS_BEAMWEAPONS) or p:hasSystem(SYS_MISSILESYSTEM) end,
        pre_comms = {
            "Remove your target selection to finish weapon system checks.",
        },
        check_fun = function(d,p,c)
            return p:getTarget() ~= practice
        end,
        post_comms = {
            {"Target clear.", "cyan"},
            "Weapons systems are go."
        },
    })
--[[
    addPreflightCheck(player, "impulse-cool", "launch", {
        pre_comms = {
            "All systems are go.",
            {"%s %s, you have permission to launch", "yellow",
                function(str,d,p,c) return string.format(str, p:getTypeName(), p:getCallSign()) end
            },
            "Starting launch sequence.",
            "Set the power of your impulse drive to 200%.",
            "Direct all coolant to your impulse systems."
        },
        check_fun = function(d,p,c)
            return p:getSystemCoolant(SYS_IMPULSE) >= 9
        end,
        post_comms = {
            {"Impulse coolant is %d%%.", "cyan",
                function(str,d,p,c) return string.format(str, math.floor(p:getSystemCoolant(SYS_IMPULSE)*10)) end
            }
        },
    })
    
    addPreflightCheck(player, "impulse-power", "launch", {
        check_fun = function(d,p,c)
            return p:getSystemPower(SYS_IMPULSE) >= 2
        end,
        post_comms = {
            {"Impulse power is %d%%.", "cyan",
                function (str,d,p,c) return string.format(str, math.floor(p:getSystemPower(SYS_IMPULSE)*100)) end
            }
        },
    })
--]]    
    addPreflightCheck(player, "undock", "launch", {
        pre_comms = {
            "All systems are go.",
            {"%s %s, you have permission to launch", "yellow",
                function(str,d,p,c) return string.format(str, p:getTypeName(), p:getCallSign()) end
            },
            "Release the docking clamps from your pilot's console.",
            "Set the power of your impulse drive to 200%.",
            "Direct all coolant to your impulse systems.",
        },
        check_fun = function(d,p,c)
            return p:getDockingState() == 0
        end,
        post_comms = {
            {"Undocking", "cyan"},
            "Make sure your heading towards green bouy.",
            "Set your impulse drive to full forward power on your pilot's console.",
        },
    })

    addPreflightCheck(player, "scan-3", "launch", {
        enable_fun = function(d,p,c) return not p:getCanScan() or not (p:hasPlayerAtPosition("science") or p:hasPlayerAtPosition("operations")) end,
        pre_fun = function(d,p,c)
            pfTargetPractice(d,p,c) 
            practice:setScanned(false)
            end,
        pre_comms = {
            "Sensor check.",
            {"Fly close to the unidentified object %s to identify it.", "yellow",
            function (str,d,p,c) return string.format(str, practice:getCallSign()) end},
            "Make sure not to have is in your target selection."
        },
        check_fun = function(d,p,c)
            if practice == nil or not practice:isValid() then
                return "abort"
            end
            return practice:isScannedBy(p)
        end,
        abort_comms = {
            "Contact with target lost.",
            "Sensor check failed.",
            "Notice that you will have to pay for destroyed targeting practice droids.",
            "Launching another droid.",
        },
        post_comms = {
            {"Scan complete, target scanned.", "cyan"},
        }
    })
    
    addPreflightCheck(player, "speed-up", "launch", {
        enable_fun = function(d,p,c) return p:getCanCombatManeuver()
end, 
        pre_comms = {
            "You may boost your speed using your combat maneuver.",
            "Be aware that this causes heat. Make sure your impulse systems do not overheat."
        },
        check_fun = function(d,p,c) return true end,
    })
    
    addPreflightCheck(player, "clear-atmo", "launch", {
        pre_comms = {
            "Proceed towards the buoy and leave the atmosphere."
        },
        check_fun = function(d,p,c) return not atmo:isInside(p) end,
        post_comms = {
            {"Leaving atmosphere now.", "cyan"},
            "Launch sequence complete.",
            "Flight Control will take over now.",
            "Ground control out."
        }
    })
    
    addPreflightCheck(player, "faction", "finished", {
        check_fun = function(d,p,c)
            p:setFaction("Transport")
            if practice ~= nil and practice:isValid() then
                practice:destroy()
            end
            return true
        end,
    })
end

function addPreflightCheck(player, name, group, check)
    --for k,v in pairs(check) do
    --    player:addToShipLog(k..": "..tostring(v), "red")
    --end
    
    check.name = name
    check.group = group
    
    -- test if the check should be enabled
    if check["enable_fun"] == nil then
        check.enable_fun = function(d,p,c) return true end
    end
    assert(type(check.enable_fun) == "function")
    
    -- function that inits the check
    if check["pre_fun"] == nil then
        check.pre_fun = function(d,p,c) return end
    end
    assert(type(check.pre_fun) == "function")
    
    -- comms table that is displayed before the check
    if check["pre_comms"] == nil then
        check.pre_comms = {}
    end
    assert(type(check.pre_comms) == "table")
    
    -- function that checks if the check was complete
    -- can return true, false, "abort"
    assert(check["check_fun"] ~= nil)
    assert(type(check.check_fun) == "function")
    
    -- comms table is displayed when abort is reached
    if check["abort_comms"] == nil then
        check.abort_comms = {}
    end
    assert(type(check.abort_comms) == "table")
    
    -- comms table is displayed when check is finished
    if check["post_comms"] == nil then
        check.post_comms = {}
    end
    assert(type(check.post_comms) == "table")
    
    table.insert(player.preflight_queue, check)
end

function preflightRun(delta, player, comms)
    local state = player.preflight_state
    local idx = player.preflight_queue_current_index
    local check = player.preflight_queue[idx]
    if check == nil then
        return true
    end
    if state == nil then
        state = "enable_fun"
    end
    --comms:addToShipLog(tostring(idx).." "..state, "red")
    if state == "enable_fun" then
        if check[state](delta, player, comms) then
            state = "pre_fun"
        else
            idx = idx +1
        end
    elseif state == "pre_fun" then
        if last_check_name ~= nil then
            removeGMFunction("Skip check "..last_check_name)
        end
        addGMFunction("Skip check "..check.name, GMSkipPreflightCheck)
        last_check_name = check.name
        
        if last_check_group ~= nil then
            removeGMFunction("Skip group "..last_check_group)
        end
        addGMFunction("Skip group "..check.group, GMSkipPreflightGroup)
        last_check_group = check.group
        
        check[state](delta, player, comms)
        state = "pre_comms"
        player.preflightChecklistRun_timer = 3.0
        player.preflightChecklistRun_number = 0
        player.preflightChecklistRun_entires = check[state]
    elseif state == "check_fun" then
        local ok = check[state](delta, player, comms)
        if ok == true then
            state = "post_comms"
            player.preflightChecklistRun_timer = 1.0
            player.preflightChecklistRun_number = 0
            player.preflightChecklistRun_entires = check[state]
        elseif ok == "abort" then
            state = "abort_comms"
            player.preflightChecklistRun_timer = 1.0
            player.preflightChecklistRun_number = 0
            player.preflightChecklistRun_entires = check[state]
        end
    elseif state == "pre_comms" or state == "abort_comms" or state == "post_comms" then
        if preflightChecklistRun(delta, player, comms) then
            -- finished
            if state == "pre_comms" then
                state = "check_fun"
            elseif state == "abort_comms" then
                state = "pre_fun"
            elseif state == "post_comms" then
                state = "enable_fun"
                idx = idx +1
            end
        end
    end
    
    player.preflight_state = state
    player.preflight_queue_current_index = idx
    return false
end

function GMSkipPreflightCheck()
    local player = current_preflight_player
    if player ~= nil then
        player.preflight_queue_current_index = player.preflight_queue_current_index + 1
        player.preflight_state = nil
    end
end

function GMSkipPreflightGroup()
    local player = current_preflight_player
    if player ~= nil then
        local idx = player.preflight_queue_current_index
        local check = player.preflight_queue[idx]
        if check ~= nil then
            local group = check.group
            while check ~= nil and check.group == group do
                idx = idx+1
                check = player.preflight_queue[idx]
            end
            player.preflight_queue_current_index = idx
            player.preflight_state = nil
        end
    end
end

function GMSkipPreflightPlayer()
    local player = current_preflight_player
    if player ~= nil then
        table.insert(preflight_queue, player)
        removeGMFunction("Skip check "..player:getCallSign())
        current_preflight_player = nil
    end
end

function preflightChecklistRun(delta, player, comms)
    if comms:isCommsInactive() then
        player.preflightChecklistRun_timer = player.preflightChecklistRun_timer - delta
        if player.preflightChecklistRun_timer < 0 then
            player.preflightChecklistRun_number = player.preflightChecklistRun_number +1
            player.preflightChecklistRun_timer = 3.0
            if player.preflightChecklistRun_number <= #player.preflightChecklistRun_entires then
                local msg = player.preflightChecklistRun_entires[player.preflightChecklistRun_number]
                local color = "yellow"
                if type(msg) == "table" then
                    if #msg == 2 then
                        msg,color = msg[1], msg[2]
                    elseif #msg == 3 then
                        msg,color = msg[3](msg[1], delta, player, comms), msg[2]
                    end
                end
                comms:addToShipLog(msg, color)
                player:addToShipLog(msg, color)
            end
            if player.preflightChecklistRun_number >= #player.preflightChecklistRun_entires then
                return true
            end
        end
    end
    return false
end

function preflight(delta)
    for _,p in ipairs(preflight_queue) do
        if p:isValid() then
            preflightDelay(delta, p)
        end
    end
    -- Start one after the other, in order of creation. Main ship is always created first
    if current_preflight_player == nil then 
        if #preflight_queue >= 1 then
            current_preflight_player = preflight_queue[1]
            table.remove(preflight_queue, 1)
            if current_preflight_player:isValid
            () then
                addGMFunction("Skip check "..current_preflight_player:getCallSign(), GMSkipPreflightPlayer)
            end
        else
            if last_check_name ~= nil then
                removeGMFunction("Skip check "..last_check_name)
            end
            if last_check_group ~= nil then
                removeGMFunction("Skip check "..last_check_group)
            end
        end
    end
    
    if current_preflight_player ~= nil then
        if not current_preflight_player:isValid() then
            removeGMFunction("Skip check "..current_preflight_player:getCallSign())
            current_preflight_player = nil
            return
        end
        if preflight_checklist_comms == nil or not preflight_checklist_comms:isValid() then
            if preflightRun(delta, current_preflight_player, current_preflight_player) then            -- ship gets checklist
                removeGMFunction("Skip check "..current_preflight_player:getCallSign())
                current_preflight_player = nil
            end
        else
            if preflightRun(delta, current_preflight_player, preflight_checklist_comms)    then -- ground gets checklist
                removeGMFunction("Skip check "..current_preflight_player:getCallSign())
                current_preflight_player = nil
            end
        end
    end
end

function preflightDelay(delta, player, _)
    -- force players to dock until they are cleared for pre-flight
    if player:isDocked(ground) then
        player.start_next_system_idx = 1
        for _, system in ipairs(SYSTEMS) do
            player:setSystemPower(system, 0.0)
            player:commandSetSystemPowerRequest(system, 0.0)
        end
        return true
    else
        player:commandDock(ground)
        return false
    end
end

function pfGreet(delta, player, comms)
    if comms:isCommsInactive() then
        gm_dummy:sendCommsMessage(comms,
        string.format([[Come in %s,
        
%s %s (%s) is ready for pre-flight checks.

You will receive a checklist to read out loud to the crew via the comms log.

Open the comms log on the bottom of your screen.
Read everything out loud that is printed in yellow.
Everything printed in cyan is only for your information, like expected answers or actual system status of the ship. You may use this to detect misinformation in the communication with the crew.

You can close this communication channel now.
]], comms:getCallSign(), player:getTypeName(), player:getCallSign(), player:getDescription()))
        return true
    end
end

function pfSystemsCheck(delta, player, comms)
    local system_idx = player.start_next_system_idx
    local system = SYSTEMS[system_idx]
    if system_idx <= #SYSTEMS and player:hasSystem(system) then
        local power = player:getSystemPower(system)
        -- add status every few seconds, if > 0
        player.preflightChecklistRun_timer = player.preflightChecklistRun_timer - delta
        if power >= 1 then
            comms:addToShipLog(string.format("%s is go", system), "cyan")
            player:addToShipLog(string.format("%s is go", system), "cyan")
            player.last_power = 0
            system_idx = system_idx + 1
            system = SYSTEMS[system_idx]            
            while system_idx <= #SYSTEMS do
                if player:hasSystem(system) then
                    comms:addToShipLog(string.format("Power up your %s to 100%%", system), "yellow")
                    player:addToShipLog(string.format("Power up your %s to 100%%", system), "yellow")
                    break
                end
                system_idx = system_idx + 1
                system = SYSTEMS[system_idx]
            end
            player.start_next_system_idx = system_idx
        elseif power > 0 and player.preflightChecklistRun_timer < 0  and power ~= player.last_power then
            player.preflightChecklistRun_timer = 1.5
            player.last_power = power
            comms:addToShipLog(string.format("%s power at %i%%", system, math.floor(power*100)), "cyan")
            player:addToShipLog(string.format("%s power at %i%%", system, math.floor(power*100)), "cyan")
        elseif player.preflightHeatWarning == nil and player.preflightChecklistRun_timer < 0 then
            for _,sys in ipairs(SYSTEMS) do
                if player:hasSystem(sys) and player:getSystemHeat(sys) > 0.1 then
                    comms:addToShipLog(string.format("We detect heat building up in your %s. Lower power or direct coolant to this system to prevent overheating.", sys), "yellow")
                    player:addToShipLog(string.format("We detect heat building up in your %s. Lower power or direct coolant to this system to prevent overheating.", sys), "yellow")
                    player.preflightChecklistRun_timer = 1.5
                    player.preflightHeatWarning = true
                end
            end
        end
    else    -- system_idx > #SYSTEMS or system got removed during powering up
        return true
    end
end

function pfTargetPractice(delta, player, comms)
    if practice == nil or not practice:isValid() then
        preflight_target_practice_number = preflight_target_practice_number+1
        local cs = "TP-0"..tostring(preflight_target_practice_number)
        local tn = "Probe-Droid "..tostring(math.floor(random(100,999)))
        local px, py = player:getPosition()
        local dx, dy = vectorFromAngle(70, 2100)
        practice = CpuShip():setTemplate("ANT 615")
        practice:setDescription("A droid for targeting practice")
        practice:setPosition(px-dx, py-dy):setRotation(0)
        practice:setCommsFunction(nil):setFaction("Raider"):setScanned(false)
        practice:setShieldsMax(10):setShields(10)
        practice:setCallSign(cs)
        practice:setTypeName(tn)
        local newFreq = practice:getBeamFrequency()
        newFreq = (newFreq + 5) % 20
        player:setShieldsFrequency(newFreq)
        newFreq = player:getBeamFrequency()
        newFreq = (newFreq + 5) % 20
        practice:setShieldsFrequency(newFreq)
    end
end




