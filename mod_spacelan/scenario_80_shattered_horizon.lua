-- Name: Shattered Horizon 
-- Type: Mission
require("utils.lua")
require("ee.lua")   -- SYSTEMS


--[[ Plots:
* SH-Mission for every player group
* longer plot-line for flight control:
    * auto: sat debris in lower orbit -> send players to capture some that are on the way
        * players need instructions on how to capture
    * GM-Triggered: Unusual readings: single milit Droid
        * capture to research
    * GM-Triggered: ...
--]]

function init()
    Script():run("util_proximity_scan.lua")

    -- set params
    probe_amount=20
    player_offset = 0
    moving_debris = {}
    -- preflight
    current_preflight_player = nil
    --preflight_checklist_comms = nil
    preflight_queue = {}
    preflight_target_practice_number = 0
    -- other
    players_startup = {}
    gravity_const = 100000000 

    local orbit=35000
    local radius=12300
 
    -- create system
    planet1 = Planet():setPosition(0, 0):setPlanetRadius(radius):setDistanceFromMovementPlane(-3000):setPlanetSurfaceTexture("planets/planet-4-hd.png"):setPlanetCloudTexture("planets/clouds-2-hd.png"):setPlanetAtmosphereTexture("planets/atmosphere.png"):setPlanetAtmosphereColor(0.0,0.5,0.5):setDescriptions(_("Endor"),_("Forest Moon of Endor")):setCallSign(_("Endor")):setFaction("Environment")

    Planet():setPosition(-5000, 2.5*orbit):setPlanetRadius(1000):setDistanceFromMovementPlane(-2000):setPlanetAtmosphereTexture("planets/star-1.png"):setPlanetAtmosphereColor(1.0,1.0,1.0)

    atmo = Zone():setColor(0,0,128)
    local zx = {}
    local zy = {}
    for i=0,15 do
        local x,y = vectorFromAngle(i*360/16, 20000)
        table.insert(zx, x)
        table.insert(zy, y)
    end
    atmo:setPoints(
        zx[1], zy[1],
        zx[2], zy[2],
        zx[3], zy[3],
        zx[4], zy[4],
        zx[5], zy[5],
        zx[6], zy[6],
        zx[7], zy[7],
        zx[8], zy[8],
        zx[9], zy[9],
        zx[10], zy[10],
        zx[11], zy[11],
        zx[12], zy[12],
        zx[13], zy[13],
        zx[14], zy[14],
        zx[15], zy[15],
        zx[16], zy[16]
    )

    -- create stations and global accessible ships
    flight_control = PlayerSpaceship():setTemplate("NavSat"):setCallSign("FC-03"):setFaction("Endor"):setPosition(-3000, -30000)
    flight_control:setDescription("A navigation satellite - the all-seeing eye of Tantal-3 flight control.")
    flight_control:setLongRangeRadarRange(2*orbit):setRotation(-90):commandTargetRotation(-90):setCanScan(false):setControlCode("ome")

    buoy = CpuShip():setTemplate("NavSat"):setCallSign("Green Buoy"):setFaction("Endor"):setPosition(-400, -20000)
    buoy:setDescription("A navigation buoy that marks the line between atmosphere and space.")
    buoy:setRotation(-90):orderIdle():setScanned(true):setCommsFunction(nil):setCanBeDestroyed(false)
    buoy2 = CpuShip():setTemplate("NavSat"):setCallSign("Red Buoy"):setFaction("Endor"):setPosition(zx[14], zy[14])
    buoy2:setDescription("A navigation buoy that marks the line between atmosphere and space.")
    buoy2:setRotation(-90):orderIdle():setScanned(true):setCommsFunction(nil):setCanBeDestroyed(false)
    buoy3 = CpuShip():setTemplate("NavSat"):setCallSign("Magenta Bouy"):setFaction("Endor"):setPosition(zx[12], zy[12])
    buoy3:setDescription("A navigation buoy that marks the line between atmosphere and space.")
    buoy3:setRotation(-90):orderIdle():setScanned(true):setCommsFunction(nil):setCanBeDestroyed(false)

    gm_dummy = CpuShip():setTemplate("NavSat"):setCallSign("Ground Crew"):setFaction("Endor"):setPosition(9999999,9999999):orderIdle():setCommsFunction(nil)

    ground=PlayerSpaceship():setTemplate("Ground Station"):setFaction("Endor"):setCallSign("Tantal-3"):setPosition(0, -radius-800)
    ground:setDescription(_("A ground station on Endor. It has a spaceport."))
    ground:setLongRangeRadarRange(70000):setRotation(-90):commandTargetRotation(-90):setCanScan(false):setControlCode("ground")
    -- comms function comms_tantal_3 is no longer used when this is a playership
    preflight_checklist_comms = ground    --set this to nil, if each ship should receive their own checklist. Otherwise ground gets all checklists
    
    geo_1=CpuShip():setTemplate("Goods Jump Freighter 5"):setFaction("New Republic"):setCallSign("Pioneer-"..math.floor(random(1,20))):setPosition(33064, -2*orbit):setDescription(_("A long haul freighter")):setScanState(SS_SIMPLE_SCAN)
    geo_2=CpuShip():setTemplate("Goods Jump Freighter 5"):setFaction("Independent"):setCallSign("Innocence-"..math.floor(random(1,20))):setPosition(-2*orbit, -33064):setDescription(_("A long haul freighter")):setScanState(SS_SIMPLE_SCAN)
    geo_3=CpuShip():setTemplate("Goods Jump Freighter 5"):setFaction("Syndicate"):setCallSign("Serpent-"..math.floor(random(1,20))):setPosition(33064, 2*orbit):setDescription(_("A long haul freighter")):setScanState(SS_SIMPLE_SCAN)

    -- place escort fighters for the freighters
    local px,py = geo_1:getPosition()
    CpuShip():setFaction("New Republic"):setTemplate("X-Wing"):setPosition(px+3000,py):orderDefendTarget(geo_1):setScanStateByFaction("Endor", SS_SIMPLE_SCAN)
    CpuShip():setFaction("New Republic"):setTemplate("X-Wing"):setPosition(px-3000,py):orderDefendTarget(geo_1):setScanStateByFaction("Endor", SS_SIMPLE_SCAN)
    CpuShip():setFaction("New Republic"):setTemplate("BTL-A4 Y-Wing"):setPosition(px,py-3000):orderDefendTarget(geo_1):setScanStateByFaction("Endor", SS_SIMPLE_SCAN)
    CpuShip():setFaction("New Republic"):setTemplate("BTL-B Y-Wing"):setPosition(px,py+3000):orderDefendTarget(geo_1):setScanStateByFaction("Endor", SS_SIMPLE_SCAN)
    px,py = geo_2:getPosition()
    CpuShip():setFaction("Imperial"):setTemplate("TIE-Fighter"):setPosition(px+3000,py):orderDefendTarget(geo_2):setScanStateByFaction("Endor", SS_SIMPLE_SCAN)
    CpuShip():setFaction("Imperial"):setTemplate("TIE-Fighter"):setPosition(px-3000,py):orderDefendTarget(geo_2):setScanStateByFaction("Endor", SS_SIMPLE_SCAN)
    CpuShip():setFaction("Imperial"):setTemplate("TIE-Bomber"):setPosition(px,py-3000):orderDefendTarget(geo_2):setScanStateByFaction("Endor", SS_SIMPLE_SCAN)
    CpuShip():setFaction("Imperial"):setTemplate("TIE-Interceptor"):setPosition(px,py+3000):orderDefendTarget(geo_2):setScanStateByFaction("Endor", SS_SIMPLE_SCAN)
    px,py = geo_3:getPosition()
    CpuShip():setFaction("Syndicate"):setTemplate(" A-24"):setPosition(px+3000,py):orderDefendTarget(geo_3)
    CpuShip():setFaction("Syndicate"):setTemplate(" G9"):setPosition(px-3000,py):orderDefendTarget(geo_3)
    CpuShip():setFaction("Syndicate"):setTemplate(" YV-929"):setPosition(px,py-3000):orderDefendTarget(geo_3)

    -- place asteroids and satellites
    px,py = planet1:getPosition()
    placeRandomAroundPoint(Asteroid,3000,orbit+radius,2*orbit+radius,px,py)
    placeRandomAroundPoint(VisualAsteroid,1000,orbit+radius,2*orbit+radius+5000,px,py)
    placeRandomAroundPoint(Asteroid,50,16000,orbit+radius,px,py)
    placeArtifactsAroundPoint (16,orbit+radius,orbit+radius+500,px,py, true)    -- broken ones
    placeArtifactsAroundPoint (16,orbit+radius,orbit+radius+500,px,py, false)   -- working ones
    for dist=orbit+radius+8000,2*orbit,500 do
        px,py = vectorFromAngle(random(0,360), dist)
        placeRandomAroundPoint(Asteroid,50,1000,5000,px,py)
    end
    px,py = geo_1:getPosition()
    placeRandomAroundPoint(Asteroid,50,4000,8000,px,py)
    px,py = geo_2:getPosition()
    placeRandomAroundPoint(Asteroid,50,4000,8000,px,py)
    px,py = geo_3:getPosition()
    placeRandomAroundPoint(Asteroid,50,4000,8000,px,py)
    createMovingDebris(20, 0, 2*orbit, 5000)

    -- add GM functions
    addGMFunction(_("buttonGM", "Lower Gravity"), lowerGravity)
    addGMFunction(_("buttonGM", "Raise Gravity"), raiseGravity)
    GMPhase1 = _("buttonGM", "Satellite Clean Up")
    addGMFunction(GMPhase1,triggerPhase1)
    GMPhase2 = _("buttonGM", "Unusual Readings")
    addGMFunction(GMPhase2,triggerPhase2)
    --GMPhase4 = _("buttonGM", "Showdown")
    --addGMFunction(GMPhase4,triggerPhase4)
    GMDebris = _("buttonGM", "Spawn moving Debris")
    addGMFunction(GMDebris,triggerMovingDebris)

    -- set database entry
    mission_data = ScienceDatabase():setName(_('Mission data'))
    item = mission_data:addEntry(_('Kessler Syndrome'))
    item:setLongDescription(_([[The Kessler Syndrome is a no longer theoretical Scenario. It describes the situation where the density of objects a planet's orbit is high enough to cause a chain reaction of collisions. Each collision will create a huge debris field of multiple objects, and many of them will collide with other objects. Ultimately, the Orbit will be full of tiny objects destroying satellites and making space flight very hard, if not impossible. Also, much of our daily life depends on satellites, like communication and navigation. The Kessler Syndrome is a serious threat to all of this. This is why clearing space debris, and preventing that kind of scenario is extremely important.
]]))
    item:setImage("kessler_syndrome.png")

    -- handle new player ships
    onNewPlayerShip(init_player)

    -- set initial mission state
    mission_state = preflight
end

function init_player(player)
    px,py = ground:getPosition()
    player:setPosition(px+(100*player_offset),py-1200)
    player:setHeading(0)
    player:commandDock(ground)
    player:addReputationPoints(50)
    preparePreflight(player)
    table.insert(players_startup, player)
    if player_offset > 0 then
        player_offset = -(player_offset+1)
    else
        player_offset = -(player_offset-1)
    end
end

------------------------ end of initialisation -----

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


-------- plotline zero: collect satellites ---------
function collect_sats(delta)
    if flight_control:isCommsInactive() then
        -- FIXME: inits comms between players, does not send the message!
        gm_dummy:sendCommsMessage(flight_control, _([[Greetings Flight Control!
We see, you have a ship off the ground.
They might help to reduce the problem of space debris in our orbit!
You will need to forward this information to the ship:
We found several suitable candidates for removal: they will appear with a four-digit call sign on your radar.
A successful scan will reveal them the correct capturing frequency. Then, the shields of the ship will have to be calibrated with the correct frequency. Make sure they activate the shields after calibration. Then they can fly towards the pieces of space junk, and it should successfully be captured.

As always, you can see this massage again, when you open your comms-log on the bottom of your screen - you may need to scroll down.
]]))
        mission_state = nil
    end
end


-- first plotline: abandoned droid, attacking if players get near
function unusual_readings(delta)
    gm_dummy:sendCommsMessage(flight_control, _([[We are getting strange readings from sector C7. It looks like the source is an abandoned droid. Please send a ship to investigate, but be careful.]]))
    spyprobe = CpuShip():setFaction("Environment"):setTemplate("ANT 615"):setCallSign("NC3"):setHullMax(100):setHull(100):setPosition(48885, -45317):orderIdle()
    spyprobe:setDescriptions(_("An abandoned droid"),_("An old military droid. Capturing frequency is blocked. Behaviour unknown."))
    spyprobe:onDestruction(function(art, player)
        mission_state=nil
        gm_dummy:sendCommsMessage(flight_control, _([[The droid was destroyed. We can no longer find out what caused it's malfunction.]]))
    end)

    mission_state=spyprobe_spawned
end

function spyprobe_spawned(delta)
    for i,p in ipairs(getActivePlayerShips()) do
        if distance(p, spyprobe) < 7000 then
            spyprobe:orderRoaming()
            explosion_timer = 0
            mission_state = start_havoc
            state_step = 0
            rx,ry = 0,0
        end
    end
end

function start_havoc(delta)
    explosion_timer=explosion_timer+delta
    if explosion_timer > 12 and state_step == 1 then
        ExplosionEffect():setPosition(rx,ry):setSize(200)
        placeRandomAroundPoint(Asteroid,8,1,500,rx,ry)
        x, y = spyprobe:getPosition()
        rx = x + random(0,1000)-500
        state_step = state_step + 1
    elseif explosion_timer > 5 and state_step == 0 then
        gm_dummy:sendCommsMessage(flight_control, _([[The droid started to attack objects in its proximity! That way, more fragments will be created that may harm other ships. You must stop it! Try to NOT destroy it, target its impulse drive instead.]]))
        local x, y = spyprobe:getPosition()
        rx = x + random(0,1000)-500
        ry = y + random(0,1000)-500
        ExplosionEffect():setPosition(rx,ry):setSize(200)
        rx=x
        ry=y
        state_step = state_step + 1
    end
    if spyprobe:getSystemHealth("impulse") <= 0.0 then
        spy_x, spy_y = spyprobe:getPosition()
        mission_state=spyprobe_disabled
    end
end

function spyprobe_disabled(delta)
    mission_state=nil
    local x, y = spyprobe:getPosition()
    local r = spyprobe:getRotation()
    ElectricExplosionEffect():setPosition(x,y):setSize(200)
    spyprobe:destroy()
    local freq = math.floor(random(20, 40)) * 20
    dormant_spyprobe=Artifact():setPosition(x, y):setCallSign("MiDro"):setScanningParameters(1, 2)
    dormant_spyprobe:setDescriptions(_("A deactivated military droid. Scan to get the capturing frequency."),_("Capturing frequency:").." "..freq..". Set your shield frequency to match the capturing frequency and activate your shields to capture the droid.")
    dormant_spyprobe:setModel("combatsat"):setRadarTraceIcon("probe_droid.png"):setRadarTraceScale(1)
    dormant_spyprobe:setRotation(r)
    dormant_spyprobe.freq=freq
    dormant_spyprobe:onPickUp(function(art, player)
        mission_state=nil
        shieldfreq= 400+(player:getShieldsFrequency())*20
        local ax, ay = art:getPosition()
        local x, y = player:getPosition()
        if shieldfreq == art.freq and player:getShieldsActive() == true then
            ElectricExplosionEffect():setPosition(x,y):setSize(200)
            player:takeDamage(1, "kinetic",ax, ay)
            player:addReputationPoints(25)
        else
            ExplosionEffect():setPosition(x,y):setSize(200)
            player:takeDamage(50, "kinetic",ax, ay)
        end
        gm_dummy:sendCommsMessage(flight_control, _([[It looks like the old droid was hit by a piece of space debris and thus reactivated. This also caused it to malfunction.]]))
    end)
end


-- second plot line    TODO

--    gm_dummy:sendCommsMessage(flight_control, _([[New orders: We have to shut down some rogue droids somehow. Therefore, you need to get a ship as close as possible to the control node that is commanding the droids. Luckily, the droids are in some kind of sleep mode right now, to recharge their batteries.
--Keep in mind that a ship should turn off all non-essential systems and devices as soon as they are getting closer to the dangerous droids.]]))
--This ship has a transmitter installed that is strong enough to overwhelm the jammer of the control node and to send a shutdown signal. But you have to be very close for it to work.
--We detected the control node at a heading of about 125 degrees from our position, but a newly formed dust cloud prevents us to get more details. We don't know if this cloud was created intentionally to serve as a hiding place. It might as well be a side effect of their destructive activities or just fuel leaking out of their old tanks. Good luck!


function towards_commandnode(delta)
    -- TODO player2 does not exist!
    if distance(player2, geo_1) > 10000 and not cloud_hint and player2:hasPlayerAtPosition("Operations") then
        ground:sendCommsMessage(player2 ,_([[The dust cloud is causing large electromagnetic interferences. Which means that as soon you are far enough away from the station, you can guess it's direction by looking at the red line at the edge of your radar screen.]]))
        cloud_hint=true
    end

    if distance(player2, command_node) < 1001 then
        for n=1,10 do
            probe[n]:orderStandGround():setSystemHealth("Maneuvering",0.5)
        end
        player2:addCustomButton("Engineering","activate_transmitter_btn",_("Activate transmitter"),activate_transmitter)
        player2:addCustomButton("Engineering+","activate_transmitter_btn_plus",_("Activate transmitter"),activate_transmitter)
        player2:removeCustom("out_of_reach_info")
        player2:removeCustom("out_of_reach_info_plus")
        mission_state=nil
   end
end

function activate_transmitter()
    charge_timer=0
    transmitter_charge=0
    transmitter_txt=0
    transmitter_step = 10
    if player2:hasPlayerAtPosition("Relay") then
        ground:sendCommsMessage(player2, _([[As soon as your transmitter is fully charged, the weapons officer has to sync the shields with the transmitter (a Button will appear on the console). Then, you yourself on Relay will have to send the signal. (There will be a button for this as well.) Good luck!]]))
    else
        ground:sendCommsMessage(player2, _([[As soon as your transmitter is fully charged, the weapons officer has to sync the shields with the transmitter (a Button will appear on the console). Then, you yourself on Operations will have to send the signal. (You will have to change your sidebar from 'Scanning' to 'Other' by pressing the 'Scanning' headline or the arrows next to it.) Good luck!]]))
    end
    mission_state=boot_transmitter
    player2:removeCustom("activate_transmitter_btn")
    player2:removeCustom("activate_transmitter_btn_plus")
    globalMessage(_("Charging of Transmitter initiated"))
    player2:addCustomInfo("Engineering","activate_transmitter_info",_("Transmitter is charging.."))
    player2:addCustomInfo("Engineering+","activate_transmitter_info_plus",_("Transmitter is charging.."))
    escalation=20
    for n=1,probe_amount do
        probe[n]:orderRoaming():setSystemHealth("Maneuvering",0.85)
    end
end

function boot_transmitter(delta)
    charge_timer=charge_timer+delta
    transmitter_charge=charge_timer+10

    if charge_timer>20 and transmitter_charge > (transmitter_txt + transmitter_step) then
        transmitter_txt = math.floor(transmitter_txt + transmitter_step)
        player2:addCustomInfo("Engineering","activate_transmitter_info",_("Transmitter charging")..": "..transmitter_txt.."%")
        player2:addCustomInfo("Engineering+","activate_transmitter_info_plus",_("Transmitter charging")..": "..transmitter_txt.."%")
    end
    if charge_timer>20 and escalation==20 then
        for n=1,10 do
            probe[n]:setImpulseMaxSpeed(100):setSystemHealth("Impulse",0.1)

        end
        escalation=30
    end
    if charge_timer>30 and escalation==30 then
        escalation=40
    end
    if charge_timer>40 and escalation==40 then
        probe[probe_amount]:setWeaponStorage("HVLI",1):setWeaponStorageMax("HVLI",1):setWeaponTubeCount(1):setImpulseMaxSpeed(100)
        escalation=60
    end
    if charge_timer>60 and escalation==60 then
        escalation=80
        transmitter_step=5
    end
    if charge_timer>80 and escalation==80 then
                player2:addCustomMessage("Operations", "send_button_message", _("If not done yet, you should now change the headline of your sidebar from 'scan' to 'other', so you can send the signal as soon as it is available."))
        transmitter_step=1.5
        escalation=85
    end
    if charge_timer>90 then
        globalMessage(_("Transmitter is ready to be synced with shields"))
        player2:removeCustom("out_of_reach_info")
        player2:removeCustom("activate_transmitter_btn")
        player2:addCustomInfo("Engineering","activate_transmitter_info",_("Transmitter fully charged"))
        player2:addCustomInfo("Engineering+","activate_transmitter_info_plus",_("Transmitter fully charged"))
        player2:addCustomInfo("Weapons","connect_to_shields_info",_("Transmitter:"))
        player2:addCustomInfo("Tactical","connect_to_shields_info_tactical",_("Transmitter:"))
        player2:addCustomButton("Weapons","connect_to_shields_btn",_("Sync with shields"),connect_to_shields)
        player2:addCustomButton("Tactical","connect_to_shields_btn_tactical",_("Sync with shields"),connect_to_shields)
        mission_state=nil
    end
end

function connect_to_shields()
    globalMessage(_("Syncing shields with transmitter. Please stand by..."))
    player2:removeCustom("connect_to_shields_btn")
    player2:removeCustom("connect_to_shields_btn_tactical")
    player2:addCustomInfo("Weapons","connect_to_shields_info",_("Syncing transmitter..."))
    player2:addCustomInfo("Tactical","connect_to_shields_info_tactical",_("Syncing transmitter..."))
    mission_state= connecting_shields
    connect_timer=0
end

function connecting_shields(delta)
    connect_timer=connect_timer+delta
    if connect_timer > 5 then
        player2:addCustomButton("Relay","send_signal_btn",_("send signal"),send_signal)
        player2:removeCustom("transmitter_unlinked_info")
        player2:addCustomButton("Operations","send_signal_btn_ops",_("send signal"),send_signal)
        player2:addCustomInfo("Weapons","connect_to_shields_info",_("Transmitter is ready"))
        player2:addCustomInfo("Tactical","connect_to_shields_info_tactical",_("Transmitter is ready"))
        mission_state=nil
    end
end

function send_signal()
    local x, y = command_node:getPosition()
    ElectricExplosionEffect():setPosition(x,y):setSize(500)
    player2:removeCustom("send_signal_btn")
    player2:removeCustom("send_signal_btn_ops")
    sending_timer=0

    BeamEffect():setSource(player2, 0, 0, 0):setTarget(command_node, 0, 0):setDuration(3):setRing(false):setTexture("texture/electric_sphere_texture.png")
    mission_state=sending_signal
    for n=1,probe_amount do
        probe[n]:setFaction("Independent"):setScanned(true):orderIdle()
    end
end

function sending_signal(delta)
    sending_timer=sending_timer+delta
    if sending_timer>3 then
        globalMessage(_("Rogue satellites shut down"))
        ground:sendCommsMessage(player2, _([[Congratulations! You saved the global satellite network from destruction. I call this a successful test run and we're gonna initiate the production of our fleet of tidying ships immediately. So eventually, we will get rid of this space junk problem once and for all. You and the rest of your crew did a great job!]]))
        mission_state=nil
    end
end

-- -------------------------------- --

function update(delta)
    moveDebris(delta)
    gravity(delta)
    permaDamageSystems(delta)

    if mission_state ~= nil then
        mission_state(delta)
    end
end

--------  GM functions
function triggerPhase1()
    mission_state = collect_sats
    removeGMFunction(GMPhase1)
end

function triggerPhase2()
    mission_state = unusual_readings
    removeGMFunction(GMPhase2)
end

function triggerPhase4()
    initSatNetwork()
    cloud_hint=false
    mission_state = towards_commandnode
    removeGMFunction(GMPhase2)
    removeGMFunction(GMPhase4)
end

function triggerMovingDebris()
    onGMClick(function(x,y) 
        onGMClick(nil)
        createMovingDebris(10, x, y, 1000)
    end)
end

function raiseGravity()
    gravity_const = gravity_const * 0.75
end

function lowerGravity()
    gravity_const = gravity_const * 1.25
end

-------- Misc. functions --------

function initSatNetwork()
    Nebula():setPosition(66578, -12988)
    Nebula():setPosition(72935, -15086)
    Nebula():setPosition(71476, -8925)

    placeProbesAroundPoint(probe_amount,2000,5000,70000,-12000)
    placeRandomAroundPoint(VisualAsteroid,50,1,5000,70000,-12000)
    command_node= WarpJammer():setPosition(70000,-12000):setRange(2500):setCallSign("Control"):setDescription(_("This is the command node that controls the rogue satellites. We have to shut it down!"))
    command_node:onDestruction(function()  -- fallback in case the command node somehow gets destroyed, so the scenario is still winnable
        command_node=Artifact():setPosition(70000,-12000):setCallSign("Control"):setModel("shield_generator"):setDescription(_("This is the command node that controls the rogue satellites. We have to shut it down!"))
    end)

    gm_dummy:sendCommsMessage(flight_control, _([[Bad news: A whole group of military droids that should have been out of service just woke up. If we don't do anything against them, they will slowly but surely destroy all objects they can find. The debris will spread all over the orbit, destroying all our communications satellites.

They emit heavy electromagnetic-signals. Your scanners will show the direction of those signals als wiggling blue line in direction 100.]]))

end

function placeProbesAroundPoint( amount, dist_min, dist_max, x0, y0)
    probe ={}
    for n=1,amount do
        local r = random(0, 360)
        local distance = random(dist_min, dist_max)
        x = x0 + math.cos(r / 180 * math.pi) * distance
        y = y0 + math.sin(r / 180 * math.pi) * distance
        probe[n] = CpuShip():setFaction("Environment"):setAI("fighter"):setTemplate("ANT 615"):setPosition(x,y):orderIdle():setCallSign("IC"..n+5):setCommsFunction(no_reply)
        probe[n]:setDescriptions(_("An old military droid"), _("An old military droid. Capturing frequency is blocked."))
        probe[n]:setImpulseMaxSpeed(0)
    end
end

function placeArtifactsAroundPoint( amount, dist_min, dist_max, x0, y0, broken)
    local callsign_counter =1000
    for n=1,amount do
        local r = random(0, 360)
        local distance = random(dist_min, dist_max)
        x = x0 + math.cos(r / 180 * math.pi) * distance
        y = y0 + math.sin(r / 180 * math.pi) * distance

        if broken then
            local freq = math.floor(random(20, 40)) * 20
            callsign_counter = callsign_counter + math.floor(random(1,200))
            local callsign = callsign_counter
            debris = Artifact():setPosition(x, y):setDescriptions(_("A piece of space junk. Scan to find out the capturing frequency"), _("Capturing frequency:").." "..freq):setScanningParameters(1, 2)
            debris.freq=freq
            if freq < 595 then
                debris:setModel("debris-cubesat")
            else
                debris:setModel("debris-blob")
            end
            debris:allowPickup(true)
            debris:setCallSign(callsign):setFaction("Endor"):setRadarTraceColor(255,235,170)

            debris:onPickUp(function(art, player)
                shieldfreq= 400+(player:getShieldsFrequency())*20
                local ax, ay = art:getPosition()
                local x, y = player:getPosition()
                if shieldfreq == art.freq and player:getShieldsActive() == true then
                    ElectricExplosionEffect():setPosition(x,y):setSize(200)
                    player:takeDamage(1, "kinetic",ax,ay )
                    player:addReputationPoints(10)
                else
                    ExplosionEffect():setPosition(ax,ay):setSize(200)
                    player:takeDamage(50, "kinetic",ax,ay )
                end
            end)

        else
            callsign="TTY"..string.format("%02d",n)
            sat = Artifact():setPosition(x, y):setDescriptions(_("An operational satellite"),_("This satellite is fully operational. Do not capture!")):setScanningParameters(1, 2)
            sat:setModel("cubesat"):setCallSign(callsign):setRadarTraceIcon("satellite.png"):setRadarTraceScale(1)
            sat:allowPickup(true)

            sat:onPickUp(function(art, player)
                local ax, ay = art:getPosition()
                local x, y = player:getPosition()
                ExplosionEffect():setPosition(ax,ay):setSize(200)
                player:takeDamage(50, "kinetic",ax,ay )
                player:setReputationPoints((player:getReputationPoints()-10))
            end)
        end
    end
end

function createMovingDebris(amount, px, py, rad)
    local objs = placeRandomAroundPoint(Asteroid,amount,0,rad,-px,-py)
    for i,o in ipairs(objs) do
        o.speed = random(0.2, 1.0)
        o.angle = angleRotation(o, planet1)
        o.distance = distance(o, planet1)
        o:setSize(50)
        table.insert(moving_debris, o)
    end
end

function moveDebris(delta)
    local px, py = planet1:getPosition()
    for i=1,#moving_debris do
        local ta = moving_debris[i]
        if ta ~= nil and ta:isValid() then
            ta.angle = ta.angle + ta.speed * delta
            if ta.angle >= 360 then 
                ta.angle = 0
            end
            local pmx, pmy = vectorFromAngle(ta.angle, ta.distance)
            ta:setPosition(px+pmx,py+pmy)
        end
    end
end

function gravity(delta)
    for _,p in ipairs(players_startup) do
        if p ~= nil and p:isValid() and p:getDockingState() == 0 then
            local angle = angleRotation(p, planet1)
            local dist_0 = distance(p, planet1)
            if dist_0 < 80000 then
                local dist_1 = (80000-dist_0)^2 / gravity_const * delta
                local pmx, pmy = vectorFromAngle(angle, dist_0 - dist_1)
                local px, py = p:getPosition()
                p:setPosition(-pmx,-pmy)
            end
        end
    end
end

function permaDamageSystems(delta)
    for _,p in ipairs(players_startup) do   -- use the same table as gravity
        if p ~= nil and p:isValid() then
            for _, system in ipairs(SYSTEMS) do
                if p:hasSystem(system) then
                    if p[system] == nil then
                        p[system] = p:getSystemHealth(system)
                    end
                    local diff = p[system] - p:getSystemHealth(system)
                    p[system] = p:getSystemHealth(system)
                    if diff > 0 then
                        p:setSystemHealthMax(system, p:getSystemHealthMax(system) - diff / 20)
                    end
                end
            end
        end
    end
end
