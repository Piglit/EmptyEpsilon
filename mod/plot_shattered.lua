local ENABLE_PICKUP_BY_GRABBERS = true
local ENABLE_PICKUP_DEBRIS_BY_COLISSION = true
local ENABLE_PICKUP_CARGO_BY_COLISSION = false

plot_shattered_pickup= {}
plot_shattered_droid = {}
plot_shattered_droidspy = {}
plot_shattered_network = {}
plot_shattered_gozanti = {}
plot_shattered_crashlander = {}
plot_shattered_package = {}
plot_shattered_cic = {}
plot_shattered_fleets = {}
plot_shattered_crybaby = {}

function plot_shattered_pickup:gm_menu()
    addGMFunction("Spawn Loot", function()
		clearGMFunctions()
		gm_menu_back()
		onGMClick(function(x,y) 
			plot_shattered_pickup:create_pickup(x,y)
		end)
	end)
end

function plot_shattered_pickup:create_pickup(x,y)
	local freq = math.floor(random(20, 40)) * 20
	local debris = Artifact():setPosition(x, y):setDescriptions(_("A piece of maybe valuable space junk. Scan to find out the capturing frequency"), _("Capturing frequency:").." "..freq..". " .._("Set your shield frequency to match the capturing frequency and activate your shields to capture it."))
	debris.freq=freq
	debris:setCallSign(""):setFaction("Endor"):setScanningParameters(1, 2):setRadarTraceIcon("asteroid.png"):setRadarTraceColor(164/2,164/2,250/2):setModel("shield_generator")
	debris.on_pickup = function(art, player)
		local shieldfreq= 400+(player:getShieldsFrequency())*20
		local ax, ay = art:getPosition()
		local x, y = player:getPosition()
		if shieldfreq == art.freq and player:getShieldsActive() == true then
			ElectricExplosionEffect():setPosition(x,y):setSize(200)
			player:takeDamage(1, "kinetic",ax,ay )
			player:addReputationPoints(10)
			player:addToShipLog(_("Debris captured."), "cyan")
		else
			ExplosionEffect():setPosition(ax,ay):setSize(200)
			player:takeDamage(50, "kinetic",ax,ay )
			player:addToShipLog(_("Debris was destroyed by impact"), "red")
		end
	end
	if ENABLE_PICKUP_DEBRIS_BY_COLISSION then
		debris:allowPickup(true)
		debris:onPickUp(debris.on_pickup)
	else
		debris:allowPickup(false)
	end
	if ENABLE_PICKUP_BY_GRABBERS then
		player_ships_util:add_grabbable_object(debris)
	end
end

-- TODO: Quests: clean up sats 1, 2, 4

function plot_shattered_droid:init()
    self.gm_dummy = nil --TODO some ship that sends msgs to flight control
    self.flight_control = nil -- TODO ship of flight command
end

function plot_shattered_droid:gm_menu()
    GMPhase2 = _("buttonGM", "Unusual Readings")
    addGMFunction(GMPhase2,plot_shattered_droid.triggerPhase2)
end

--------  GM functions

function plot_shattered_droid.triggerPhase2()
    clearGMFunctions()
    gm_menu_back()
    onGMClick(function(x,y) 
        onGMClick(nil)
        plot_shattered_droid.origin_x = x
        plot_shattered_droid.origin_y = y
        if plot_shattered_droid.spyprobe ~= nil and plot_shattered_droid.spyprobe:isValid() then
            plot_shattered_droid.spyprobe:destroy()
        end
        plot_shattered_droid.update = plot_shattered_droid.unusual_readings
--        removeGMFunction(GMPhase2) -- don't remove, another call removes old droid
        plot_manager.gm_main_menu()
    end)

end

-- first plotline: abandoned droid, attacking if players get near

function plot_shattered_droid:unusual_readings(delta)
    self.spyprobe = CpuShip():setFaction("Environment"):setTemplate("ANT 615"):setHullMax(100):setHull(100):setPosition(self.origin_x, self.origin_y):orderIdle()
    self.gm_dummy:sendCommsMessage(self.flight_control, string.format(_([[We are getting strange readings from sector %s. It looks like the source is an abandoned droid. Please send a ship to investigate, but be careful.]]), self.spyprobe:getSectorName()))

    self.spyprobe:setDescriptions(_("An abandoned droid"),_("An old military droid. Capturing frequency is blocked. Behaviour unknown."))
    self.spyprobe:onDestruction(function(art, player)
        plot_shattered_droid.update = nil
        local x,y = art:getPosition()
        map_shattered:createMovingDebris(4, x, y, 100)
        plot_shattered_droid.gm_dummy:sendCommsMessage(plot_shattered_droid.flight_control, _([[The droid was destroyed. We can no longer find out what caused it's malfunction.]]))
        if player ~= nil and player:isValid() and player.typeName == "playerSpaceship" then
            player:addToShipLog(_("Droid destroyed."), "red")
        end
    end)
    self.update = self.spyprobe_spawned
end

function plot_shattered_droid:spyprobe_spawned(delta)
    for i,p in ipairs(getActivePlayerShips()) do
        if distance(p, self.spyprobe) < 7000 then
            local x,y = self.spyprobe:getPosition()
            self.spyprobe:orderDefendLocation(x,y)
            self.explosion_timer = 0
            self.update = self.start_havoc
            self.spyprobe:addBroadcast(2, _("Activating... Searching targets..."))
        end
    end
end

function plot_shattered_droid:destroy_asteroid()
    local objs = self.spyprobe:getObjectsInRange(1000)
    arrayFilter(objs, function(o) return o.typeName == "Asteroid" end)
    if #objs == 0 then
        return false
    end
    local obj = objs[math.random(#objs)]
    local x, y = obj:getPosition()
    ExplosionEffect():setPosition(x, y):setSize(200)
    map_shattered:createMovingDebris(4, x, y, 500)
    obj:destroy()                  
    return true
end

function plot_shattered_droid:start_havoc(delta)
    self.explosion_timer = self.explosion_timer+delta
    if self.explosion_timer > 5 then
        self.gm_dummy:sendCommsMessage(self.flight_control, _([[The droid started to attack objects in its proximity! That way, more fragments will be created that may harm other ships. You must stop it! Instruct your ship crew that they should NOT destroy it, they should target its impulse drive instead.]]))
        self:destroy_asteroid()
        self.update = self.during_havoc
    end
end

function plot_shattered_droid:during_havoc(delta)
    self.explosion_timer = self.explosion_timer+delta
--    print(self.explosion_timer)
    if self.explosion_timer > 3 then
        self.spyprobe:setCanBeDestroyed(true)
    end
    if self.explosion_timer > 12 then
        self.spyprobe:setCanBeDestroyed(false)
        if self:destroy_asteroid() then
            self.explosion_timer = 0
        end
    end
    if self.spyprobe:getSystemHealth("impulse") <= 0.0 then
        self.spy_x, self.spy_y = self.spyprobe:getPosition()
        self.update = self.spyprobe_disabled
    end
end

function plot_shattered_droid:spyprobe_disabled(delta)
    self.update = nil
    local x, y = self.spyprobe:getPosition()
    local r = self.spyprobe:getRotation()
    ElectricExplosionEffect():setPosition(x,y):setSize(200)
    self.spyprobe:destroy()
    local freq = math.floor(random(20, 40)) * 20
    self.spyprobe=Artifact():setPosition(x, y):setCallSign("MiDro"):setScanningParameters(1, 2)
    self.spyprobe:setDescriptions(_("A deactivated military droid. Scan to get the capturing frequency."),_("Capturing frequency:").." "..freq..". " .._("Set your shield frequency to match the capturing frequency and activate your shields to capture the droid."))
    self.spyprobe:setModel("combatsat"):setRadarTraceIcon("probe_droid.png"):setRadarTraceScale(1)
    self.spyprobe:setRotation(r)
    self.spyprobe.freq=freq
	self.spyprobe.on_pickup = function(art, player)
--        plot_shattered_droid.update = nil
        local shieldfreq= 400+(player:getShieldsFrequency())*20
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
        player:addToShipLog(_("Droid captured."), "cyan")
        plot_shattered_droid.gm_dummy:sendCommsMessage(plot_shattered_droid.flight_control, string.format(_([[The malfunctioning old droid was captured by %s.]]), player:getCallSign()))
        --It looks like the old droid was hit by a piece of space debris and thus reactivated. This also caused it to malfunction.]]))
    end
	if ENABLE_PICKUP_DEBRIS_BY_COLISSION then
		self.spyprobe:allowPickup(true)
		self.spyprobe:onPickUp(self.spyprobe.on_pickup)
	else
		self.spyprobe:allowPickup(false)
	end
	if ENABLE_PICKUP_BY_GRABBERS then
		player_ships_util:add_grabbable_object(self.spyprobe)
	end
end


-- second plot line
function plot_shattered_network:init()
    -- set params
    self.probe_amount=20
    self.gm_dummy = nil
    self.flight_control = nil
    --self.cloud_hint = false
    self.player2 = nil    -- set per GM function
    self.command_node = nil
end
function plot_shattered_network:gm_menu()
    if self.command_node == nil or not self.command_node:isValid() then
        GMPhase4 = _("buttonGM", "Droid Showdown")
        addGMFunction(GMPhase4, plot_shattered_network.triggerPhase4)
    end
end

function plot_shattered_network.triggerPhase4()
    if plot_shattered_network.command_node == nil then
        clearGMFunctions()
        gm_menu_back()
        onGMClick(function(x,y) 
            onGMClick(nil)
            plot_shattered_network:initSatNetwork(x,y)    -- creates command_node
            plot_shattered_network.update = plot_shattered_network.communicate_commandnode
            plot_manager.gm_main_menu()
        end)
    else
        plot_manager.gm_main_menu()
    end
end

-------- Misc. functions --------

function plot_shattered_network:initSatNetwork(x,y)
    Nebula():setPosition(x - 3422, y -2988)
    Nebula():setPosition(x + 2935, y -5086)
    Nebula():setPosition(x + 1476, y +1075)

    self:placeProbesAroundPoint(self.probe_amount,2000,5000,x,y)
    placeRandomAroundPoint(VisualAsteroid,50,1,5000,x,y)
    self.command_node= WarpJammer():setPosition(x,y):setRange(2500):setCallSign("Control"):setDescription(_("This is the command node that controls the rogue droids. We have to shut it down!"))
    self.command_node:onDestruction(function()  -- fallback in case the command node somehow gets destroyed, so the scenario is still winnable
        plot_shattered_network.command_node=Artifact():setPosition(x,y):setCallSign("Control"):setModel("shield_generator"):setDescription(_("This is the command node that controls the rogue droids. We have to shut it down!"))
    end)

    self.gm_dummy:sendCommsMessage(self.flight_control, _([[Bad news: A whole group of military droids that should have been out of service just woke up. If we don't do anything against them, they will slowly but surely destroy all objects they can find. The debris will spread all over the orbit, destroying all our communications satellites.

They emit heavy electromagnetic-signals. Your radar will show the direction of those signals als wiggling red line.
    
Please send a ship to invesitgate.]]))

end

function plot_shattered_network:placeProbesAroundPoint(amount, dist_min, dist_max, x0, y0)
    self.probe ={}
    for n=1,amount do
        local r = random(0, 360)
        local distance = random(dist_min, dist_max)
        local x = x0 + math.cos(r / 180 * math.pi) * distance
        local y = y0 + math.sin(r / 180 * math.pi) * distance
        self.probe[n] = CpuShip():setFaction("Environment"):setAI("fighter"):setTemplate("ANT 615"):setPosition(x,y):orderIdle():setCallSign("IC"..n+5):setCommsFunction(nil)
        self.probe[n]:setDescriptions(_("An old military droid"), _("An old military droid. Capturing frequency is blocked."))
        self.probe[n]:setImpulseMaxSpeed(0)
    end
end


function plot_shattered_network:communicate_commandnode(delta)
    local objs = self.command_node:getObjectsInRange(10000)
    arrayFilter(objs, function(o) return o.typeName == "PlayerSpaceship" end)
    if #objs == 0 then
        return false
    end
    self.gm_dummy:sendCommsMessage(self.flight_control, _([[We detected a control node within the group of rougue droids, but a newly formed dust cloud prevents us to get more details. We don't know if this cloud was created intentionally to serve as a hiding place. It might as well be a side effect of their destructive activities or just fuel leaking out of old tanks.
We have to shut down the rogue droids somehow. Therefore, you need to get a ship as close as possible to the control node that is commanding the droids. Luckily, the droids are in some kind of sleep mode right now.
Notify nearby ships, that they ship should turn off all non-essential systems and devices as soon as they are getting closer to the dangerous droids.]]))
--This ship has a transmitter installed that is strong enough to overwhelm the jammer of the control node and to send a shutdown signal. But you have to be very close for it to work.
--We detected the control node at a heading of about 125 degrees from our position, but a newly formed dust cloud prevents us to get more details. We don't know if this cloud was created intentionally to serve as a hiding place. It might as well be a side effect of their destructive activities or just fuel leaking out of their old tanks. Good luck!]]))
    self.update = plot_shattered_network.towards_commandnode
end

function plot_shattered_network:towards_commandnode(delta)
    --if distance(self.player2, geo_1) > 10000 and not cloud_hint and self.player2:hasPlayerAtPosition("Operations") then
    --    self.ground:sendCommsMessage(self.player2 ,_([[The dust cloud is causing large electromagnetic interferences. Which means that as soon you are far enough away from the station, you can guess it's direction by looking at the red line at the edge of your radar screen.]]))
    --    cloud_hint=true
    --end
    local objs = self.command_node:getObjectsInRange(1000)
    arrayFilter(objs, function(o) return o.typeName == "PlayerSpaceship" end)
    if #objs == 0 then
        return false
    end
    self.player2 = objs[1]
    for n=1,10 do
        if self.probe[n]:isValid() then
            self.probe[n]:orderStandGround():setSystemHealth("Maneuvering",0.5)
        end
    end
    self.update = self.check_connection
    self.charge_timer = nil
end

function plot_shattered_network:check_connection(delta)
    if self.player2 ~= nil and self.player2:isValid() then
        if distance(self.player2, self.command_node) > 1000 then
            self.player2:addCustomInfo("Engineering","out_of_reach_info",_("Out of reach"))
            self.player2:addCustomInfo("Engineering+","out_of_reach_info_plus",_("Out of reach"))
            self.player2:removeCustom("activate_transmitter_btn")
            self.player2:removeCustom("activate_transmitter_btn_plus")
            self.player2:removeCustom("activate_transmitter_info")
            self.player2:removeCustom("activate_transmitter_info_plus")
        else
            if self.charge_timer == nil then
                self.player2:addCustomButton("Engineering","activate_transmitter_btn",_("Connect to control device"),self.activate_transmitter)
                self.player2:addCustomButton("Engineering+","activate_transmitter_btn_plus",_("Connect to control device"),self.activate_transmitter)
                if self.player2.activate_transmitter_msg == nil then
                    self.player2:addCustomMessage("Engineering", "activate_transmitter_msg", _("A droid control device appeared is in range for data transmission. You can connect to it with the button on the right."))
                    self.player2:addCustomMessage("Engineering+", "activate_transmitter_msg_plus", _("A droid control device appeared is in range for data transmission. You can connect to it with the button on the right."))
                    self.player2.activate_transmitter_msg = true
                end
            end
            self.player2:removeCustom("out_of_reach_info")
            self.player2:removeCustom("out_of_reach_info_plus")
            return true
        end
    else
        -- reset plot to last step
        self.player2 = nil
        for n=1,self.probe_amount do
            if self.probe[n]:isValid() then
                self.probe[n]:orderIdle()
            end
        end
        self.update = self.towards_commandnode
    end
    return false
end

function plot_shattered_network.activate_transmitter()
    self = plot_shattered_network
    self.charge_timer=0
    self.transmitter_charge=0
    self.transmitter_txt=0
    self.transmitter_step = 10
    self.player2:addToShipLog(_([[Connection established. Keep near the control node, to not lose connection.]]),"cyan")
    self.update = self.boot_transmitter
    self.player2:removeCustom("activate_transmitter_btn")
    self.player2:removeCustom("activate_transmitter_btn_plus")
    self.player2:addCustomInfo("Engineering","activate_transmitter_info",_("Connection established."))
    self.player2:addCustomInfo("Engineering+","activate_transmitter_info_plus",_("Connection established."))
    self.escalation=20
    for n=1,self.probe_amount do
        if self.probe[n]:isValid() then
            self.probe[n]:orderRoaming():setSystemHealth("Maneuvering",0.85)
        end
    end
end

function plot_shattered_network:boot_transmitter(delta)
    if self:check_connection(delta) == false then
        return
    end
    self.charge_timer=self.charge_timer+delta
    self.transmitter_charge=self.charge_timer+10

    if self.charge_timer>20 and self.transmitter_charge > (self.transmitter_txt + self.transmitter_step) then
        self.transmitter_txt = math.floor(self.transmitter_txt + self.transmitter_step)
        self.player2:addCustomInfo("Engineering","activate_transmitter_info",_("Transmitter charging")..": "..self.transmitter_txt.."%")
        self.player2:addCustomInfo("Engineering+","activate_transmitter_info_plus",_("Transmitter charging")..": "..self.transmitter_txt.."%")
    end
    if self.charge_timer>20 and self.escalation==20 then
        for n=1,10 do
            if self.probe[n]:isValid() then
                self.probe[n]:setImpulseMaxSpeed(100):setSystemHealth("Impulse",0.1)
            end
        end
        self.escalation=30
    end
    if self.charge_timer>30 and self.escalation==30 then
        self.escalation=40
    end
    if self.charge_timer>40 and self.escalation==40 then
        if self.probe[self.probe_amount]:isValid() then
            self.probe[self.probe_amount]:setWeaponStorage("HVLI",1):setWeaponStorageMax("HVLI",1):setWeaponTubeCount(1):setImpulseMaxSpeed(100)
        end
        self.escalation=60
    end
    if self.charge_timer>60 and self.escalation==60 then
        self.escalation=80
        self.transmitter_step=5
    end
    if self.charge_timer>80 and self.escalation==80 then
        self.player2:addCustomMessage("Operations", "send_button_message", _("If not done yet, you should now change the headline of your sidebar from 'scan' to 'other', so you can send the signal as soon as it is available."))
        self.player2:addCustomMessage("Engineering", "send_button_message_engi", _("As soon as your transmitter is fully charged, the weapons officer has to sync the shields with the transmitter (a Button will appear on the console). Then, Operations will have to send the signal. (There will be a button for this as well.)"))
        self.player2:addCustomMessage("Engineering+", "send_button_message_engi_plus", _("As soon as your transmitter is fully charged, the weapons officer has to sync the shields with the transmitter (a Button will appear on the console). Then, Operations will have to send the signal. (There will be a button for this as well.)"))
        self.transmitter_step=1.5
        self.escalation=85
    end
    if self.charge_timer>90 then
        --globalMessage(_("Transmitter is ready to be synced with shields"))
        self.player2:removeCustom("out_of_reach_info")
        self.player2:removeCustom("activate_transmitter_btn")
        self.player2:addCustomInfo("Engineering","activate_transmitter_info",_("Transmitter fully charged"))
        self.player2:addCustomInfo("Engineering+","activate_transmitter_info_plus",_("Transmitter fully charged"))
        self.player2:addCustomInfo("Weapons","connect_to_shields_info",_("Transmitter:"))
        self.player2:addCustomInfo("Tactical","connect_to_shields_info_tactical",_("Transmitter:"))
        self.player2:addCustomButton("Weapons","connect_to_shields_btn",_("Sync with shields"),self.connect_to_shields)
        self.player2:addCustomButton("Tactical","connect_to_shields_btn_tactical",_("Sync with shields"),self.connect_to_shields)
        self.update = nil
    end
end

function plot_shattered_network.connect_to_shields()
    self = plot_shattered_network
    self.player2:removeCustom("connect_to_shields_btn")
    self.player2:removeCustom("connect_to_shields_btn_tactical")
    self.player2:addCustomInfo("Weapons","connect_to_shields_info",_("Syncing transmitter..."))
    self.player2:addCustomInfo("Tactical","connect_to_shields_info_tactical",_("Syncing transmitter..."))
    self.update = self.connecting_shields
    self.connect_timer=0
end

function plot_shattered_network:connecting_shields(delta)
    self.connect_timer=self.connect_timer+delta
    if self.connect_timer > 5 then
        self.player2:addCustomButton("Relay","send_signal_btn",_("send signal"),self.send_signal)
        self.player2:removeCustom("transmitter_unlinked_info")
        self.player2:addCustomButton("Operations","send_signal_btn_ops",_("send signal"),self.send_signal)
        self.player2:addCustomInfo("Weapons","connect_to_shields_info",_("Transmitter is ready"))
        self.player2:addCustomInfo("Tactical","connect_to_shields_info_tactical",_("Transmitter is ready"))
        self.update = nil
    end
end

function plot_shattered_network.send_signal()
    self = plot_shattered_network
    local x, y = self.command_node:getPosition()
    ElectricExplosionEffect():setPosition(x,y):setSize(500)
    self.player2:removeCustom("send_signal_btn")
    self.player2:removeCustom("send_signal_btn_ops")
    self.sending_timer=0

    BeamEffect():setSource(self.player2, 0, 0, 0):setTarget(self.command_node, 0, 0):setDuration(3):setRing(false):setTexture("texture/electric_sphere_texture.png")
    self.update = self.sending_signal
    for n=1,self.probe_amount do
        if self.probe[n]:isValid() then
            self.probe[n]:setFaction("Independent"):setScanned(true):orderIdle()
        end
    end
    self.player2:removeCustom("send_signal_btn")
    self.player2:removeCustom("send_signal_btn_ops")
    self.player2:removeCustom("connect_to_shields_info")
    self.player2:removeCustom("connect_to_shields_info_tactical")
    self.player2:removeCustom("activate_transmitter_info")
    self.player2:removeCustom("activate_transmitter_info_plus")
end

function plot_shattered_network:sending_signal(delta)
    self.sending_timer=self.sending_timer+delta
    if self.sending_timer>3 then
        self.gm_dummy:sendCommsMessage(self.flight_control, _([[The rougue droids shut down. Congratulations - the ship you sent saved the global satellite network from destruction. Tell the crew, they did a great job!]]))
        self.update = nil
    end
end

-------- plotline zero: collect satellites ---------
-- legacy, not needed anymore - maybe as briefing for FC
--[[
function triggerPhase1()
    mission_state = collect_sats
    removeGMFunction(GMPhase1)
end
--]]

--function collect_sats(delta)
--    if self.flight_control:isCommsInactive() then
--        -- FIXME: inits comms between players, does not send the message!
--        self.gm_dummy:sendCommsMessage(self.flight_control, _([[Greetings Flight Control!
--We see, you have a ship off the ground.
--They might help to reduce the problem of space debris in our orbit!
--You will need to forward this information to the ship:
--We found several suitable candidates for removal: they will appear with a four-digit call sign on your radar.
--A successful scan will reveal them the correct capturing frequency. Then, the shields of the ship will have to be calibrated with the correct frequency. Make sure they activate the shields after calibration. Then they can fly towards the pieces of space junk, and it should successfully be captured.
--
--As always, you can see this massage again, when you open your comms-log on the bottom of your screen - you may need to scroll down.
--]]))
--        mission_state = nil
--    end
--end


function plot_shattered_gozanti:init()
    local px, py = 0, -40000
    self.gozanti = CpuShip():setTemplate(" Gozanti C-ROC"):setCallSign("QoW"):setDescription("Queen of Watch, ein ehemaliges imperiales Forschungsschiff"):setPosition(px, py):setFaction("Imperial"):orderRoaming():setScanStateByFaction("Endor", SS_SIMPLE_SCAN)
    CpuShip():setFaction("Imperial"):setTemplate("TIE-Fighter"):setPosition(px+3000,py):orderDefendTarget(self.gozanti):setScanStateByFaction("Endor", SS_SIMPLE_SCAN)
    CpuShip():setFaction("Imperial"):setTemplate("TIE-Fighter"):setPosition(px-3000,py):orderDefendTarget(self.gozanti):setScanStateByFaction("Endor", SS_SIMPLE_SCAN)
    CpuShip():setFaction("Imperial"):setTemplate("TIE-Bomber"):setPosition(px,py-3000):orderDefendTarget(self.gozanti):setScanStateByFaction("Endor", SS_SIMPLE_SCAN)
    CpuShip():setFaction("Imperial"):setTemplate("TIE-Interceptor"):setPosition(px,py+3000):orderDefendTarget(self.gozanti):setScanStateByFaction("Endor", SS_SIMPLE_SCAN)
    self.waypoints = {
        {0,-40000},
        {-20000, -40000},
        {-40000, -20000},
        {-20000, -40000},
        {0,-40000},
        {20000, -40000},
        {40000, -20000},
        {20000, -40000},
    }
    self.next_waypoint = 5
end

function plot_shattered_gozanti:update(delta)
    if self.gozanti ~= nil and self.gozanti:isValid() then
        if self.gozanti:getOrder() == "Roaming" then    -- reset to patrol mode
            self.gozanti:orderFlyTowards(table.unpack(self.waypoints[self.next_waypoint]))
        end
        if distance(self.gozanti, table.unpack(self.waypoints[self.next_waypoint])) < 500 then
            self.next_waypoint = self.next_waypoint + 1
            if self.next_waypoint > #self.waypoints then
                self.next_waypoint = 1
            end
            self.gozanti:orderFlyTowards(table.unpack(self.waypoints[self.next_waypoint]))
        end
    end
end



function plot_shattered_crashlander:update(delta)
	if self.ship ~= nil and self.ship:isValid() then
		local planet = map_shattered.planet
		self.ship:setEnergy(500)
		if self.ship:getSystemHealth("warp") <= 0.5 then
			self.ship:setSystemHealth("warp", 0.5)
		end
		if not self.ship:getShieldsActive() and self.ship:getHull() < self.ship:getHullMax() then
			self.ship:commandSetShields(true)
			self.ship:setSystemHealthMax("maneuver", 0)
		end
		if distance(self.ship, planet) < 14000 then
			player_ships_util:despawn_player_ship(self.shipname)
		end
	end
end




function plot_shattered_package:gm_menu()
    addGMFunction(_("buttonGM", "Lost Package"),plot_shattered_package.spawn_package)
end

--------  GM functions

function plot_shattered_package.spawn_package()
    clearGMFunctions()
    gm_menu_back()
    onGMClick(function(x,y) 
        onGMClick(nil)
		if plot_shattered_package.ship ~= nil and plot_shattered_package.ship:isValid() then
			plot_shattered_package.ship:destroy()
		end
		plot_shattered_package.ship = CpuShip():setCallSign("HW-25"):setFaction("Independent"):setTemplate("Goods Freighter 1"):setHullMax(100):setHull(20):setShieldsMax(0,0):setPosition(x, y):orderIdle():setDescriptions(_("Ein Schiffswrack"),_("Das Wrack der Wayfarer's Wisp - ein Hydrotii D-85 Frachter."))
		for i=1,10 do
			local a = Artifact():setPosition(x+random(-5000, 5000), y+random(-5000, 5000)):setModel("ammo_box"):setDescriptions(_("Eine Frachtkiste"),_("Frachtkiste: leer")):setScanningParameters(3,1):setCallSign(string.format("%d-%s%s%s-%d", irandom(1111,9999), string.char(0x40+irandom(1,26)), string.char(0x40+irandom(1,26)), string.char(0x40+irandom(1,26)), irandom(10,99)))
			if ENABLE_PICKUP_CARGO_BY_COLISSION then
				a:allowPickup(true)
			else
				a:allowPickup(false)
			end
			if ENABLE_PICKUP_BY_GRABBERS then
				player_ships_util:add_grabbable_object(a)
			end
		end
			local a = Artifact():setPosition(x+random(-2000, 2000), y+random(-2000, 2000)):setModel("ammo_box"):setDescriptions(_("Eine Frachtkiste"),_("Frachtkiste: Lieferung f. Mr. Kell Murtry")):setScanningParameters(3,1):setCallSign("4478-EXN-59")
			if ENABLE_PICKUP_CARGO_BY_COLISSION then
				a:allowPickup(true)
			else
				a:allowPickup(false)
			end
			if ENABLE_PICKUP_BY_GRABBERS then
				player_ships_util:add_grabbable_object(a)
			end
        plot_manager.gm_main_menu()
    end)
end

-- CIC
function plot_shattered_cic:init()
	self:init_cic_infos(map_shattered.flight_control)
	local storage = getScriptStorage()
	storage["plot_shattered_cic"] = self
end

function plot_shattered_cic:gm_menu()
	addGMFunction("Satelliten", function()
		clearGMFunctions()
		if map_shattered.flight_control == nil or not map_shattered.flight_control:isValid() then
			addGMFunction("CIC Sat", function()
				map_shattered.flight_control = plot_shattered_cic:spawn_sat(3000, -30000, "FC-03", _("A navigation satellite - the all-seeing eye of Tantal-3 flight control."))
				plot_shattered_cic:init_cic_infos(map_shattered.flight_control)
				plot_manager.gm_main_menu()
			end)
		else
			if map_shattered.flight_control.blocked then
				addGMFunction("Unblock CIC radar",function()
					plot_shattered_cic:unblock_cic(map_shattered.flight_control)
					plot_manager.gm_main_menu()
				end)
			else
				addGMFunction("Block CIC radar",function()
					plot_shattered_cic:block_cic(map_shattered.flight_control)
					plot_manager.gm_main_menu()
				end)
			end
		end

		if plot_shattered_cic.rebel_sat == nil or not plot_shattered_cic.rebel_sat:isValid() then
			addGMFunction("Rebel Sat", function()
				plot_shattered_cic.rebel_sat = plot_shattered_cic:spawn_sat(-40000, 15000, "RS-04", _("A navigation satellite - it transmits sensor data to the surface of Endor."))
				plot_shattered_cic:init_cic_infos(plot_shattered_cic.rebel_sat)
				plot_manager.gm_main_menu()
			end)
		else
			if plot_shattered_cic.rebel_sat.blocked then
				addGMFunction("Unblock Rebel radar",function()
					plot_shattered_cic:unblock_cic(plot_shattered_cic.rebel_sat)
					plot_manager.gm_main_menu()
				end)
			else
				addGMFunction("Block Rebel radar",function()
					plot_shattered_cic:block_cic(plot_shattered_cic.rebel_sat)
					plot_manager.gm_main_menu()
				end)
			end
		end
		gm_menu_back()
	end)
end

function plot_shattered_cic:init_cic_infos(sat)
	if sat ~= nil and sat:isValid() then
		self:set_infos(sat, 10, "SYSTEM-STATUS:")
		self:set_infos(sat, 11, "Radar-Reichweite:                60u (100%)")
		self:set_infos(sat, 12, "Sensor-Reichweite:              90u (100%)")
		if sat == map_shattered.flight_control then
			-- only for true CIC with comms
			self:set_infos(sat, 13, "Funk-Sende-Reichweite:       50u (100%)")
			self:set_infos(sat, 14, "Funk-Empfangs-Reichweite:  60u (100%)")
		end
		self:set_infos(sat, 30, " ")
		self:set_infos(sat, 31, "RADAR-SENSOR-INFO:")
		self:set_infos(sat, 32, "Rot:  Energie")
		self:set_infos(sat, 33, "Grün: Biosign")
		self:set_infos(sat, 34, "Blau:  Metall")
	end
end

function plot_shattered_cic:unblock_cic(sat)
	if sat.nebula ~= nil and sat.nebula:isValid() then
		sat.nebula:destroy()
	end
	if sat ~= nil and sat:isValid() then
		sat:commandSetAlertLevel("normal")
		self:set_infos(sat, 11, "Radar-Reichweite:               60u (100%)")
		self:set_infos(sat, 12, "Sensor-Reichweite:              90u (100%)")
		self:set_infos(sat, 40, nil)
		self:set_infos(sat, 41, nil)
		self:set_infos(sat, 42, nil)
		self:set_infos(sat, 43, nil)
		self:set_infos(sat, 44, nil)
	end
	sat.blocked = false 
end

function plot_shattered_cic:block_cic(sat)
	if sat ~= nil and sat:isValid() then
		if sat.nebula ~= nil and sat.nebula:isValid() then
			sat.nebula:destroy()
		end
		local x,y = sat:getPosition()
		sat.nebula = Nebula():setPosition(x, y):setSize(3)
		sat:commandSetAlertLevel("yellow")
		self:set_infos(sat, 11, "Radar-Reichweite:               30u ( 50%)")
		self:set_infos(sat, 12, "Sensor-Reichweite:                 ? ( 30%)")
		self:set_infos(sat, 40, " ")
		self:set_infos(sat, 41, "FEHLER / WARNUNGEN:")
		self:set_infos(sat, 42, "Warnung: Energie-Sensor gestört      ")
		self:set_infos(sat, 43, "Warnung: Biosign-Sensor ausgefallen")
		self:set_infos(sat, 44, "Warnung: Langstreckenradar gestört")
		sat.blocked = true
	end
end

function plot_shattered_cic:set_infos(sat, idx, msg)
	if sat == nil then
		sat = map_shattered.flight_control
	end
	if sat ~= nil and sat:isValid() then
		if msg == nil or msg == "" then
			sat:removeCustom("CIC_"..tostring(idx))
		else
			sat:addCustomInfo("science", "CIC_"..tostring(idx), msg, idx)
		end
	end
end

function plot_shattered_cic:spawn_sat(x,y, callsign, description)
    local sat = PlayerSpaceship():setTemplate("NavSat"):setCallSign(callsign):setFaction("Endor"):setPosition(x,y)
    sat:setDescription(description)
    sat:setLongRangeRadarRange(60000):setShortRangeRadarRange(30000):setRotation(-90):commandTargetRotation(-90):setCanScan(false)
	gravity_util.addException(sat)
	return sat
end

----- fleet arrivals

function plot_shattered_fleets:gm_menu()
    addGMFunction("Spawn Plot Fleets", function()
		clearGMFunctions()
		addGMFunction("Raider (one per click)", function()
			clearGMFunctions()
			gm_menu_back()
			onGMClick(function(x,y) 
				plot_shattered_fleets:spawn_raider(x,y)
			end)
		end)
		addGMFunction("Viper Droid", function()
			clearGMFunctions()
			gm_menu_back()
			onGMClick(function(x,y) 
				onGMClick(nil)
				plot_shattered_fleets:spawn_viper_droid(x,y)
				plot_manager.gm_main_menu()
			end)
		end)
		addGMFunction("Star Destroyer Victory", function()
			clearGMFunctions()
			gm_menu_back()
			onGMClick(function(x,y) 
				onGMClick(nil)
				plot_shattered_fleets:spawn_star_destroyer(x,y)
				plot_manager.gm_main_menu()
			end)
		end)
		addGMFunction("Breaker VIP", function()
			clearGMFunctions()
			gm_menu_back()
			onGMClick(function(x,y) 
				onGMClick(nil)
				plot_shattered_fleets:spawn_breaker(x,y)
				plot_manager.gm_main_menu()
			end)
		end)
		addGMFunction("NR Opfer Nebulon-B", function()
			clearGMFunctions()
			gm_menu_back()
			onGMClick(function(x,y) 
				onGMClick(nil)
				plot_shattered_fleets:spawn_nr_opfer(x,y)
				plot_manager.gm_main_menu()
			end)
		end)
		addGMFunction("NR Fleet", function()
			clearGMFunctions()
			gm_menu_back()
			onGMClick(function(x,y) 
			onGMClick(nil)
				plot_shattered_fleets:spawn_nr_fleet(x,y)
				plot_manager.gm_main_menu()
			end)
		end)
		gm_menu_back()
	end)
end

function plot_shattered_fleets:spawn_star_destroyer(x,y)
    self.isd = CpuShip():setTemplate(" Star Destroyer"):setFaction("Imperial"):setCallSign("Victory"):setDescription("Star Destroyer Victory"):setPosition(x,y):setScanStateByFaction("Endor", SS_SIMPLE_SCAN):orderStandGround()
    CpuShip():setFaction("Imperial"):setTemplate("TIE-Fighter"):setPosition(x+3000,y):orderDefendTarget(self.isd):setScanStateByFaction("Endor", SS_SIMPLE_SCAN)
    CpuShip():setFaction("Imperial"):setTemplate("TIE-Fighter"):setPosition(x-3000,y):orderDefendTarget(self.isd):setScanStateByFaction("Endor", SS_SIMPLE_SCAN)
    CpuShip():setFaction("Imperial"):setTemplate("TIE-Fighter"):setPosition(x-3000,y-3000):orderDefendTarget(self.isd):setScanStateByFaction("Endor", SS_SIMPLE_SCAN)
    CpuShip():setFaction("Imperial"):setTemplate("TIE-Fighter"):setPosition(x+3000,y+3000):orderDefendTarget(self.isd):setScanStateByFaction("Endor", SS_SIMPLE_SCAN)
    CpuShip():setFaction("Imperial"):setTemplate("TIE-Bomber"):setPosition(x,y-3000):orderDefendTarget(self.isd):setScanStateByFaction("Endor", SS_SIMPLE_SCAN)
    CpuShip():setFaction("Imperial"):setTemplate("TIE-Interceptor"):setPosition(x,y+3000):orderDefendTarget(self.isd):setScanStateByFaction("Endor", SS_SIMPLE_SCAN)
end

function plot_shattered_fleets:spawn_breaker(x,y)
    self.breaker = CpuShip():setTemplate(" CR90"):setFaction("Independent"):setCallSign("CB-15"):setPosition(x,y):setScanStateByFaction("Endor", SS_SIMPLE_SCAN):orderStandGround()
end

function plot_shattered_fleets:spawn_nr_fleet(x,y)
    self.mc = CpuShip():setTemplate(" MC80"):setFaction("New Republic"):setCallSign("Home One"):setDescription("Mon Calamari Cruiser Home One"):setPosition(x,y):setScanStateByFaction("Endor", SS_SIMPLE_SCAN):orderStandGround()
	CpuShip():setFaction("New Republic"):setTemplate(" X-Wing"):setPosition(x+3000,y):orderDefendTarget(self.mc):setScanStateByFaction("Endor", SS_SIMPLE_SCAN)
    CpuShip():setFaction("New Republic"):setTemplate(" X-Wing"):setPosition(x-3000,y):orderDefendTarget(self.mc):setScanStateByFaction("Endor", SS_SIMPLE_SCAN)
    CpuShip():setFaction("New Republic"):setTemplate(" X-Wing"):setPosition(x-3000,y-3000):orderDefendTarget(self.mc):setScanStateByFaction("Endor", SS_SIMPLE_SCAN)
    CpuShip():setFaction("New Republic"):setTemplate(" Y-Wing BTL-A4"):setPosition(x,y-3000):orderDefendTarget(self.mc):setScanStateByFaction("Endor", SS_SIMPLE_SCAN)
    CpuShip():setFaction("New Republic"):setTemplate(" Y-Wing BTL-B"):setPosition(x,y+3000):orderDefendTarget(self.mc):setScanStateByFaction("Endor", SS_SIMPLE_SCAN)
    CpuShip():setFaction("New Republic"):setTemplate(" Y-Wing BTL-B"):setPosition(x+3000,y+3000):orderDefendTarget(self.mc):setScanStateByFaction("Endor", SS_SIMPLE_SCAN)
    CpuShip():setFaction("New Republic"):setTemplate(" CR90"):setPosition(x+5000,y):orderFlyFormation(self.mc, 0, 5000):setScanStateByFaction("Endor", SS_SIMPLE_SCAN)
    CpuShip():setFaction("New Republic"):setTemplate(" CR90"):setPosition(x-5000,y):orderFlyFormation(self.mc, 0, -5000):setScanStateByFaction("Endor", SS_SIMPLE_SCAN)
    CpuShip():setFaction("New Republic"):setTemplate(" Nebulon-B"):setPosition(x,y+5000):orderFlyFormation(self.mc, 5000, 0):setScanStateByFaction("Endor", SS_SIMPLE_SCAN)
end

function plot_shattered_fleets:spawn_nr_opfer(x,y)
    self.opfer = CpuShip():setTemplate(" Nebulon-B"):setFaction("New Republic"):setPosition(x,y):setScanStateByFaction("Endor", SS_SIMPLE_SCAN):orderStandGround()
	CpuShip():setFaction("New Republic"):setTemplate(" X-Wing"):setPosition(x+3000,y):orderDefendTarget(self.opfer):setScanStateByFaction("Endor", SS_SIMPLE_SCAN)
    CpuShip():setFaction("New Republic"):setTemplate(" X-Wing"):setPosition(x-3000,y):orderDefendTarget(self.opfer):setScanStateByFaction("Endor", SS_SIMPLE_SCAN)
    CpuShip():setFaction("New Republic"):setTemplate(" Y-Wing BTL-A4"):setPosition(x,y-3000):orderDefendTarget(self.opfer):setScanStateByFaction("Endor", SS_SIMPLE_SCAN)
    CpuShip():setFaction("New Republic"):setTemplate(" Y-Wing BTL-B"):setPosition(x+3000,y+3000):orderDefendTarget(self.opfer):setScanStateByFaction("Endor", SS_SIMPLE_SCAN)
end

function plot_shattered_fleets:spawn_viper_droid(x,y)
    self.viper = CpuShip():setTemplate("Viper Droid"):setFaction("Environment"):setPosition(x,y):orderStandGround()
end																																				
function plot_shattered_fleets:spawn_raider(x,y)
	local templ = arraySelectRandom({
		" U-Wing", " X-Wing", " ARC-170", " UT-60D", " A-24", " T-Wing R-60", " Y-Wing BTL-B", " Y-Wing BTL-A4", " Y-Wing BTL-S3", " TIE-Fighter", " TIE-Interceptor", " TIE-Bomber", " TIE-Reaper" 
	}) 
	CpuShip():setTemplate(templ):setFaction("Raider"):setPosition(x,y):orderRoaming()
end

-----

function plot_shattered_crybaby:gm_menu()
    addGMFunction("Spawn Crybaby", function()
		clearGMFunctions()
		gm_menu_back()
		onGMClick(function(x,y) 
            onGMClick(nil)
			plot_shattered_crybaby:create_crybaby(x,y)
			plot_manager.gm_main_menu()
		end)
	end)
end
function plot_shattered_crybaby:create_crybaby(x,y)
	self.crybaby = CpuShip():setTemplate("NavSat"):setRadarTrace("star_destroyer.png"):setFaction("Environment"):setPosition(x,y):orderIdle():setCallSign("Notsignal: Gideons leichter Kreuzer"):setDescriptions("Moff Gideons leichter Kreuzer sendet ein Notsignal! Alle imperialen Schiffe müssen sofort zur Rettung kommen.", "Ein imperiales Notsignal kommt von diesem Objekt, dass sich als Moff Gideons leichter Kreuzer identifiziert.")
end
