-- TODO, it was just moved


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



