require("ee.lua")
salvage_repair_mission = {}

function salvage_repair_mission.init(SpawnEnemies, Wormhole_station, placeKraylor)
    -- Wormhole_station may be any station. Comms options are added via comms data.
--	salvage_repair_mission.Admin_station = Admin_station
--	salvage_repair_mission.CHEEVOS = CHEEVOS
--	salvage_repair_mission.Defence_station = Defence_station
	salvage_repair_mission.SpawnEnemies = SpawnEnemies
	salvage_repair_mission.Wormhole_station = Wormhole_station
    salvage_repair_mission.goneAggro = false 
    local x, y = Wormhole_station:getPosition() -- 77152, 32816
    x = x-5878
    y = y+5312
    salvage_repair_mission.Wormhole_x, salvage_repair_mission.Wormhole_y = x,y
    -- Wormholes
    WormHole():setPosition(x, y):setTargetPosition(334910, 473961)
    WormHole():setPosition(332910, 471961):setTargetPosition(x-2000, y-2000)

	salvage_repair_mission.Kw_enemies = {
    CpuShip():setFaction("Kraylor"):setTemplate("Spinebreaker"):setCallSign("BR5"):setPosition(377672, 540642):orderStandGround(),
    CpuShip():setFaction("Kraylor"):setTemplate("Spinebreaker"):setCallSign("BR6"):setPosition(377541, 545431):orderStandGround(),
    CpuShip():setFaction("Kraylor"):setTemplate("Rockbreaker"):setCallSign("CSS4"):setPosition(373724, 542711):orderStandGround()
  }

	salvage_repair_mission.Kw_stations = {}
    local stations_pos = {}
    while #stations_pos < #placeGenericStation do
        for _, obj in ipairs(stations_pos) do
            obj:destroy()
        end
        stations_pos = placeRandomObjects(VisualAsteroid, 6, 0.4, 334910, 473961, 5, 5)
        --print("Positions: "..#stations_pos)
    end

    while kraylorStationsRemain and #stations_pos > 0 do
		local si = math.random(1,#stations_pos)
		local obj = stations_pos[si]
        table.remove(stations_pos, si)
        if obj ~= nil and obj:isValid() then
            psx, psy = obj:getPosition()
            local station = placeKraylor()
            if station ~= nil then
                --print(station:getPosition())
                table.insert(salvage_repair_mission.Kw_stations, station)
            else
                kraylorStationsRemain = false
            end
            obj:destroy()
        end
    end

    placeRandomObjects(Asteroid, 30, 0.3, 334910, 473961, 7, 7)
    placeRandomObjects(VisualAsteroid, 30, 0.3, 334910, 473961, 7, 7)
    placeRandomObjects(Nebula, 15, 0.3, 334910, 473961, 8, 8)
--    SpaceStation():setTemplate("Large Station"):setFaction("Kraylor"):setCallSign("KZ2346"):setPosition(376303, 543016),
--    SpaceStation():setTemplate("Medium Station"):setFaction("Kraylor"):setCallSign("KZ2682"):setPosition(400931, 541600),
--    SpaceStation():setTemplate("Medium Station"):setFaction("Kraylor"):setCallSign("KZ2683"):setPosition(360825, 561407)
--  }
	salvage_repair_mission.Exuari_junk_stations = {
    SpaceStation():setTemplate("Medium Station"):setFaction("Exuari"):setCallSign("X6775"):setPosition(315754, 449577),
    SpaceStation():setTemplate("Medium Station"):setFaction("Exuari"):setCallSign("X6774"):setPosition(333160, 452975),
    SpaceStation():setTemplate("Medium Station"):setFaction("Exuari"):setCallSign("XS6773"):setPosition(326495, 458049)
  }
	salvage_repair_mission.Investigator = salvage_repair_mission.Kw_enemies[1]
	salvage_repair_mission.Kw_mainStation = salvage_repair_mission.Kw_stations[1]
	salvage_repair_mission.Parts_station = SpaceStation():setTemplate("Small Station"):setFaction("Exuari"):setCallSign("X472"):setPosition(351326, 517812)

    salvage_repair_mission.Investigator:setCommsFunction(salvage_repair_mission.CommsInvestigator)
    salvage_repair_mission.InitKraylor()
    salvage_repair_mission.InitPartsStation()
    if salvage_repair_mission.Wormhole_station.comms_data == nil then
        salvage_repair_mission.Wormhole_station.comms_data = {}
    end
    mergeTables(salvage_repair_mission.Wormhole_station.comms_data, {
        docked_comms_functions = {salvage_repair_mission.CommsWormholeStationDocked},
        undocked_comms_functions = {salvage_repair_mission.CommsWormholeStationUndocked},
    })
    salvage_repair_mission.Wormhole_station.insults = {}

	local storage = getScriptStorage()
	storage.salvage_repair_mission = salvage_repair_mission
end

function salvage_repair_mission.set_Difficulty(Difficulty)
	salvage_repair_mission.Difficulty = Difficulty
end

function salvage_repair_mission.set_Player(Player)
	salvage_repair_mission.Player = Player
end

function set_parameters(Difficulty, Player)
	salvage_repair_mission.set_Difficulty(Difficulty)
	salvage_repair_mission.set_Player(Player)
end


function salvage_repair_mission.check()
	if salvage_repair_mission.Player == nil or not salvage_repair_mission.Player:isValid() then return false end
	if salvage_repair_mission.Wormhole_station == nil or not salvage_repair_mission.Wormhole_station:isValid() then return false end
	return true
end	
function salvage_repair_mission.InitPartsStation()
  salvage_repair_mission.Parts_station:setCanBeDestroyed(false)
  salvage_repair_mission.Parts_station:setShieldsMax(1)
  salvage_repair_mission.Parts_station:setShields(1)
  salvage_repair_mission.Parts_station:onTakingDamage(function(self, instigator)
    if instigator == nil or not instigator:isValid() then return end
    instigator:addToShipLog(_("wormhole-shipLog", "Firing on invulnerable target"), "Yellow")
    if salvage_repair_mission.Parts_station.warned == nil then
     salvage_repair_mission.Parts_station.warned = true
      salvage_repair_mission.Wormhole_station:sendCommsMessage(instigator, _("wormhole-incCall", [[Captain, Stop!

Don't waste your time shooting at that station. It has an Exuari emergency integrity field that will prevent catastrophic hull breach. Just a waste of energy, I promise you.]]))
    end
  end)
end

function salvage_repair_mission.InitKraylor()
  for _, e in ipairs(salvage_repair_mission.Kw_stations) do
    e:onTakingDamage(salvage_repair_mission.KWGoAggro)
  end
  for _, e in ipairs(salvage_repair_mission.Kw_enemies) do
    e:onTakingDamage(salvage_repair_mission.KWGoAggro)
  end
end

--==================================================
--==
--==
--==
--==
--==
--==
--==      SPARE PARTS MISSION
--==
--==
--==
--==
--==
--==
--==
--==================================================

function salvage_repair_mission.StartMissionSpareParts(comms_source, comms_target)
  salvage_repair_mission.Player = comms_source
  salvage_repair_mission.Difficulty = 5

  local lastpart
  local missiles = comms_source:getWeaponStorage("Homing")
  for i = 0, comms_source:getWeaponTubeCount() do
    local t = comms_source:getWeaponTubeLoadType(i)
    if t == "homing" then
      missiles = missiles + 1
    end
    --if t ~= nil then comms_source:addToShipLog("DEBUG tube "..i.." type "..t.." total "..missiles, "Magenta") end
  end

  if missiles >= 6 or salvage_repair_mission.Difficulty == 5 then
    lastpart = _("wormhole-comms", "and when in doubt - apply missiles.")
  elseif salvage_repair_mission.Difficulty == 1 then
    lastpart = _("wormhole-comms", "and we've given you some extra missiles to help get the job done.")
    comms_source:setWeaponStorage("Homing", 6 - missiles + comms_source:getWeaponStorage("Homing"))
  elseif salvage_repair_mission.Difficulty == 3 then
    lastpart = _("wormhole-comms", "and go find some extra missiles to help get the job done.")
  end

  setCommsMessage(string.format(_("wormhole-comms","Great!\nThere is an old Exuari station, callsign X472, to the south east on the other side of the wormhole. It used to study the planet forming nearby, but it's been abandoned for over a century now, no one aboard and no weapons, a historical relic, really. We need you to demolish it and bring us the stabilizers from its jump drive which we can use to maintain our Hawking Scanners.\nWe have hacked the emergency integrity field so that the station can be destroyed, but there were strange disturbances when we deactivated it. We're not sure what it means, but we advise you to exercise caution...\n%s"),lastpart))

  salvage_repair_mission.Wormhole_station.mission_state = "get parts"
  sendMessageToCampaignServer("Mission spare parts: " .. salvage_repair_mission.Wormhole_station.mission_state)

  salvage_repair_mission.Parts_station:setCanBeDestroyed(true)
  salvage_repair_mission.Parts_station:onDestroyed(function (self, instigator)
    if self ~=nil and (instigator == nil or not instigator:isValid()) then
        instigator = salvage_repair_mission.closestPlayerTo(self, 100000)
    end
    salvage_repair_mission.Wormhole_station.mission_state = "return parts"
    sendMessageToCampaignServer("Mission spare parts: " .. salvage_repair_mission.Wormhole_station.mission_state)
    SupplyDrop():setFaction("Human Navy"):setPosition(salvage_repair_mission.Parts_station:getPosition()):setEnergy(200):onPickUp(function (self, grabber)
      salvage_repair_mission.Wormhole_station:sendCommsMessage(grabber, _("wormhole-incCall", [[Great, you got the parts!

You'd better hurry back, we've seen some Kraylor activity in the area. Hopefully your salvage mission didn't attract the wrong sort of attention.]]
      ))
      grabber:addToShipLog(_("wormhole-shipLog", "Return the spare parts to the Wormhole Station"), "Green")
      grabber.hasSpareParts = true
      salvage_repair_mission.Player = grabber
    end)

    local hailer = nil
    if salvage_repair_mission.Investigator:isValid() then -- salvage_repair_mission.Investigator can hail on his own if alive
      hailer = salvage_repair_mission.Investigator
    end
    if hailer ~= nil and salvage_repair_mission.Kw_mainStation:isValid() then -- hail from station if they are both alive
      hailer = salvage_repair_mission.Kw_mainStation
    end

    if hailer ~= nil then -- If is alive, give a warning
      salvage_repair_mission.SpawnKWEnemies(false)
      instigator:addToShipLog(_("KraylorWarning-shipLog", "The Kraylor are investigating our activities and have warned us not to escalate"), "Yellow")
      hailer:sendCommsMessage(instigator, _("KraylorWarning-incCall", [[Ugh, humans.

This is the Kraylor Advanced "Reasearch" Project Agency (KARPA), we have detected your suspicious activity in the vicinity.

We are sending a team to investigate what you are up to. If you fire on us, there will be trouble!]]))
    else
      salvage_repair_mission.SpawnKWEnemies(true) -- If not alive, make all reinforcements immediately aggro
    end

  end)
  salvage_repair_mission.Parts_station:onTakingDamage(function (self, instigator)
    if instigator ~= nil and instigator:isValid() then
        local x, y = salvage_repair_mission.Parts_station:getPosition()
        local x_t, y_t = instigator:getPosition()
        local x_d = x - (2 * (x - x_t)) + irandom(-1000, 1000)
        local y_d = y - (2 * (y - y_t)) + irandom(-1000, 1000)
        salvage_repair_mission.Parts_station:setPosition(x_d, y_d)
        instigator:addReputationPoints(1)
        instigator:addToShipLog(_("wormhole-shipLog", "Jump Defence Activated"),"Yellow")
    end
  end)
end

function salvage_repair_mission.UpdateMissionSpareParts()
  if not salvage_repair_mission.check() then return end
  if salvage_repair_mission.Wormhole_station.mission_state == nil or salvage_repair_mission.Wormhole_station.mission_state == "done" then return end

  if salvage_repair_mission.Wormhole_station.mission_state == "return parts" then

    -- Handle salvage_repair_mission.Investigator following salvage_repair_mission.Player
    if salvage_repair_mission.Investigator.warned == nil and salvage_repair_mission.Investigator:isValid() then
      if distance(salvage_repair_mission.Investigator, salvage_repair_mission.Player) < 7000 then
        salvage_repair_mission.Investigator:orderStandGround()
      else
        salvage_repair_mission.Investigator:orderFlyTowardsBlind(salvage_repair_mission.Player:getPosition())
      end
      if distance(salvage_repair_mission.Investigator, salvage_repair_mission.Player) > 200000 then
        local dx, dy = salvage_repair_mission.Player:getPosition()
        dx = dx + 7000
        dy = dy + 7000
        salvage_repair_mission.Investigator:setPosition(dx, dy)
      end

      if distance(salvage_repair_mission.Player, salvage_repair_mission.Wormhole_station) < 5000 and salvage_repair_mission.Player.hasSpareParts == true then
        salvage_repair_mission.Investigator.warned = true
        salvage_repair_mission.Investigator:sendCommsMessage(salvage_repair_mission.Player, _("KraylorWarning-incCall", [[Watch your back, Hugh Mon!

We don't know what you're up to, but we don't like the look of it. Keep your distance and maybe we'll leave you alone.

<The Kraylor Vessel jumps back through the wormhole>]]))
        salvage_repair_mission.Player:addToShipLog(_("KraylorWarning-shipLog", "The Kraylor seem hostile and have warned us to keep our distance"), "Yellow")
        salvage_repair_mission.Investigator:setPosition(377672, 540642)
        salvage_repair_mission.Investigator:orderStandGround()
        salvage_repair_mission.StartMissionRepair()
      end
    end
  end
end

function salvage_repair_mission.FinishMissionSpareParts()
  salvage_repair_mission.Wormhole_station.mission_state = "done"
  sendMessageToCampaignServer("Mission spare parts: " .. salvage_repair_mission.Wormhole_station.mission_state)
  salvage_repair_mission.Wormhole_station:setFaction("Human Navy")
  salvage_repair_mission.StartMissionRepair()
end

function salvage_repair_mission.SpawnKWEnemies(start_aggro)
  if salvage_repair_mission.Difficulty >= 1 then
    local x, y = sectorToXY("AI23")
    local enemies = salvage_repair_mission.SpawnEnemies(x, y, random(.8,1.2), "Kraylor")
    for _, e in ipairs(enemies) do
      table.insert(salvage_repair_mission.Kw_enemies, e)
    end
  end
  if salvage_repair_mission.Difficulty >= 3 then
    local x, y = sectorToXY("AG26")
    local enemies = salvage_repair_mission.SpawnEnemies(x, y, random(.8,1.2), "Kraylor")
    for _, e in ipairs(enemies) do
      table.insert(salvage_repair_mission.Kw_enemies, e)
    end
  end
  if salvage_repair_mission.Difficulty == 5 then
    local x, y = sectorToXY("AI25")
    local enemies = salvage_repair_mission.SpawnEnemies(x, y, random(.8,1.2), "Kraylor")
    for _, e in ipairs(enemies) do
      table.insert(salvage_repair_mission.Kw_enemies, e)
    end
  end

  for _, e in ipairs(salvage_repair_mission.Kw_enemies) do
    if start_aggro then
      e:orderAttack(salvage_repair_mission.Player)
    else
      e:orderStandGround()
      e:onTakingDamage(salvage_repair_mission.KWGoAggro)
    end
  end
end

function salvage_repair_mission.KWGoAggro(self, instigator)
  if not salvage_repair_mission.check() then return end
  if instigator == nil or not instigator:isValid() or instigator ~= salvage_repair_mission.Player then return end
  salvage_repair_mission.goneAggro = true
  sendMessageToCampaignServer("event:Kraylor beyond wormhole were attacked")
  for _, e in ipairs(salvage_repair_mission.Kw_enemies) do
    if e.goneAggro == true then return end
    e.goneAggro = true
    e:orderAttack(salvage_repair_mission.Player)
  end
  local repToLose = 10 * salvage_repair_mission.Difficulty
  salvage_repair_mission.Player:takeReputationPoints(repToLose)
  salvage_repair_mission.Player:addToShipLog(string.format(_("KraylorWarning-shipLog", "We have lost %s reputation for breaking the treaty"),repToLose), "Red")
  salvage_repair_mission.Kw_mainStation:sendCommsMessage(salvage_repair_mission.Player, _("KraylorWarning-IncCall",[[You will regret this!

You have violated our non-aggression treaty, and will soon regret your actions.]]))
  salvage_repair_mission.StartMissionRepair()
end

--[[
function salvage_repair_mission.CheckCheevoJunk()
  salvage_repair_mission.CHEEVOS["junk"] = true
  for _, stn in ipairs(salvage_repair_mission.Exuari_junk_stations) do
    if stn:isValid() then
      salvage_repair_mission.CHEEVOS["junk"] = false
      return
    end
  end
end
--]]

--==================================================
--==
--==
--==
--==
--==
--==
--==      REPAIR MISSION
--==
--==
--==
--==
--==
--==
--==
--==================================================

function salvage_repair_mission.StartMissionRepair()

  if salvage_repair_mission.Wormhole_station.tier2_mission_state == nil then
    salvage_repair_mission.Wormhole_station.tier2_mission_state = "wait for attack"
    sendMessageToCampaignServer("Mission repair: " .. salvage_repair_mission.Wormhole_station.tier2_mission_state)
  end

  -- If all the other missions are done, bump this to 2 minutes
  if salvage_repair_mission.Wormhole_station.mission_state == "done" then
    salvage_repair_mission.Wormhole_station.tier2_attack_countdown = 120
  else
    if salvage_repair_mission.Wormhole_station.tier2_attack_countdown == nil then
      salvage_repair_mission.Wormhole_station.tier2_attack_countdown = 900
    end
  end

  --salvage_repair_mission.Player:addToShipLog("DEBUG tier2_attack_countdown: ".. salvage_repair_mission.Wormhole_station.tier2_attack_countdown, "Magenta")
end

function salvage_repair_mission.UpdateMissionRepair(delta)
  if not salvage_repair_mission.check() then return end
  if salvage_repair_mission.Wormhole_station.tier2_mission_state == nil then return end

  if salvage_repair_mission.Wormhole_station.tier2_mission_state == "wait for attack" then
    salvage_repair_mission.Wormhole_station.tier2_attack_countdown = salvage_repair_mission.Wormhole_station.tier2_attack_countdown - delta
    if salvage_repair_mission.Wormhole_station.tier2_attack_countdown <= 0 then
      salvage_repair_mission.Wormhole_station.tier2_mission_state = "attack"
      sendMessageToCampaignServer("Mission repair: " .. salvage_repair_mission.Wormhole_station.tier2_mission_state)
      salvage_repair_mission.SpawnRepairEnemies()

    end
  end

  if salvage_repair_mission.Wormhole_station.tier2_mission_state == "attack" then
    local allDestroyed = true
    for _, enemy in ipairs(salvage_repair_mission.Wormhole_station.repair_enemies) do
      if enemy:isValid() then
        allDestroyed = false
        local closestPlayer = salvage_repair_mission.closestPlayerTo(enemy, 2000)
        if closestPlayer ~= nil then
          enemy:orderAttack(closestPlayer)
        else
          salvage_repair_mission.Wormhole_station:setFaction("Human Navy")
          enemy:orderAttack(salvage_repair_mission.Wormhole_station)
        end
        if distance(enemy, salvage_repair_mission.Wormhole_station) > 200000 then
          enemy:setPosition(salvage_repair_mission.Wormhole_x, salvage_repair_mission.Wormhole_y)  -- Landing point when entering southern wormhole
        end
      end
    end
    if allDestroyed then
      salvage_repair_mission.Player:addReputationPoints(20)
      salvage_repair_mission.Wormhole_station.tier2_mission_state = "damaged"
      sendMessageToCampaignServer("Mission repair: " .. salvage_repair_mission.Wormhole_station.tier2_mission_state)
      salvage_repair_mission.Wormhole_station:sendCommsMessage(salvage_repair_mission.Player, _("wormhole-incCall",[[Thanks so much, captain!

You really saved our ass there. Unfortunately our Hawking Scanner was damaged by the bomb, and we haven't been able to get it back online. Do you think you could get it fixed for us?

Please dock with us to pick up the scanner.]]))
      salvage_repair_mission.Player:addToShipLog(_("wormhole-shipLog", "Get the Hawking Scanner from the Wormhole Station"), "Green")
    end
  end
end

function salvage_repair_mission.FinishMissionRepair()
  salvage_repair_mission.Wormhole_station.tier2_mission_state = "done"
  sendMessageToCampaignServer("Mission repair: " .. salvage_repair_mission.Wormhole_station.tier2_mission_state)
end

function salvage_repair_mission.SpawnRepairEnemies()
  local x, y = salvage_repair_mission.Wormhole_station:getPosition()
  salvage_repair_mission.Wormhole_station.repair_enemies = salvage_repair_mission.SpawnEnemies(x - 5000, y - 5000, random(1.8,2.2), "Kraylor")

  -- This is needed to get the Kraylor to actually attack it
  salvage_repair_mission.Wormhole_station:setFaction("Human Navy")

  for _, enemy in ipairs(salvage_repair_mission.Wormhole_station.repair_enemies) do
    salvage_repair_mission.Wormhole_station:setFaction("Human Navy")
    enemy:orderAttack(salvage_repair_mission.Wormhole_station)
  end
  salvage_repair_mission.Wormhole_station:sendCommsMessage(salvage_repair_mission.Player, _("wormhole-incCall",[[RED ALERT!

Captain, a bomb has just gone off on our station and we are under attack from the Kraylor. We need your help immediately!]]))
  salvage_repair_mission.Player:addToShipLog(_("wormhole-shipLog","Defend the Wormhole Station"), "Red")
end

function salvage_repair_mission.CommsInvestigator(comms_source, comms_target)
  setCommsMessage(_("investigate-comms", "What do you have to say for yourself?"))
  addCommsReply(_("investigate-comms", "We're just running a salvage mission."), function ()
    setCommsMessage(_("investigate-comms", "Carry on, then, we're keeping our eye on you."))
  end)
  addCommsReply(_("investigate-comms", "Back off, this is a special military operation"), function ()
    setCommsMessage(_("investigate-comms", "You want to back up that escalation with some weapons fire?"))
  end)
end

function salvage_repair_mission.CommsWormholeStationUndocked(comms_source, comms_target)

    -- if tier2 is active:
    if salvage_repair_mission.Wormhole_station.tier2_mission_state == "attack" then
        setCommsMessage(_("wormhole-comms", [[We're under attack. Help us!]]))
        return true
    end

    if salvage_repair_mission.Wormhole_station.tier2_mission_state == "damaged" then
      addCommsReply("Do you have any orders for us?", function ()
        setCommsMessage(_("wormhole-comms", [[Come pick up our Hawking Scanner for repairs.]]))
      end)
    elseif salvage_repair_mission.Wormhole_station.tier2_mission_state == "rma" or salvage_repair_mission.Wormhole_station.tier2_mission_state == "fixed" then
      addCommsReply("Do you have any orders for us?", function ()
        setCommsMessage(_("wormhole-comms", [[Please find someone to repair our Hawking Scanner.]]))
      end)

    -- if tier1 is active:
    elseif salvage_repair_mission.Wormhole_station.mission_state == nil then
        setCommsMessage(_("wormhole-comms", [[
        Hello Captain. Have you noticed our cool wormhole?

        We're studying the energy radiating from the wormhole, and the similarities to black holes are astonishing. Please drop by if you'd like to help out.]]))
        return true
    elseif salvage_repair_mission.Wormhole_station.mission_state == "get parts" or salvage_repair_mission.Wormhole_station.mission_state == "return parts" then
      addCommsReply("Do you have any orders for us?", function ()
        setCommsMessage(_("wormhole-comms", "Please bring us the spare parts from the old Exuari station, callsign X472, to the south east on the other side of the wormhole."))
      end)
    elseif salvage_repair_mission.Wormhole_station.mission_state == "done" then
      addCommsReply("Do you have any orders for us?", function ()
        setCommsMessage(_("wormhole-comms", "No. Thanks so much for your help!"))
      end)
    end
    return  -- allow other interactions
end

function salvage_repair_mission.CommsWormholeStationDocked(comms_source, comms_target)
    -- Docked comms
    if salvage_repair_mission.Wormhole_station.tier2_mission_state ~= nil and
        salvage_repair_mission.Wormhole_station.tier2_mission_state ~= "wait for attack" then
        salvage_repair_mission.CommsWormholeStationDockedTier2(comms_source,comms_target)
        return
    end

    if salvage_repair_mission.Wormhole_station.mission_state == nil then
        salvage_repair_mission.Wormhole_station.insults["tips"] = false
        setCommsMessage(_("wormhole-comms", [[Thanks for dropping by, Captain.

        Our research is going well, but we could use some spare stabilizers for our Hawking Scanner. Would you mind salvaging some for us from the other side of the wormhole?]]))
        addCommsReply(_("wormhole-comms", "Okay, we can help with that."), salvage_repair_mission.StartMissionSpareParts)
        addCommsReply(_("wormhole-comms", "Do you pay tips?"), function()
            setCommsMessage(_("wormhole-comms", [[Maybe later, then. Goodbye.]]))
            comms_source:takeReputationPoints(2)
            salvage_repair_mission.Wormhole_station.insults["tips"] = true
        end)
        return true
    elseif salvage_repair_mission.Wormhole_station.mission_state == "get parts" or salvage_repair_mission.Wormhole_station.mission_state == "return parts" then

        if comms_source.hasSpareParts ~= nil then
          addCommsReply("We have your spare parts.", function ()
            salvage_repair_mission.Player = comms_source
            salvage_repair_mission.Wormhole_station.insults["errands"] = false
            setCommsMessage(_("wormhole-comms", [[Thanks for your help, Captain!

            These spare parts will really help with the program budget.]]))
            addCommsReply(_("wormhole-comms", "What do we get for being your errand boy?"), function()
                setCommsMessage(_("wormhole-comms", [[You get half of what would have with a smarter attitude! So rude.]]))
                comms_source:addReputationPoints(5)
                salvage_repair_mission.Wormhole_station.insults["errands"] = true
                salvage_repair_mission.FinishMissionSpareParts()
            end)
            addCommsReply(_("wormhole-comms", "We're so glad we could help"), function()
                setCommsMessage(_("wormhole-comms", [[We are too. Thanks a bunch.]]))
                comms_source:addReputationPoints(10)
                salvage_repair_mission.FinishMissionSpareParts()
            end)
          end)
        else
          addCommsReply("Do you have any orders for us?", function ()
            setCommsMessage(_("wormhole-comms", [[We still need those spare parts from X472 on the the south east on the other side of the wormhole!]]))
          end)
        end
    elseif Wormhole_station.mission_state == "done" then
      addCommsReply("Do you have any orders for us?", function ()
        setCommsMessage(_("wormhole-comms", [[No. But thanks, that was awesome]]))
      end)
    end
end

function CommsWormholeStationDockedTier2(comms_source, comms_target)

  -- DOCKER OR UNDOCKED
  if salvage_repair_mission.Wormhole_station.tier2_mission_state == "attack" then
    setCommsMessage(_("wormhole-comms", [[We're under attack. Help us!]]))
    return true
  end

    if salvage_repair_mission.Wormhole_station.tier2_mission_state == "damaged" or salvage_repair_mission.Wormhole_station.tier2_mission_state == "rma" then
      addCommsReply("Do you have any orders for us?", function ()
          salvage_repair_mission.Wormhole_station.tier2_mission_state = "rma"
          sendMessageToCampaignServer("Mission repair: " .. salvage_repair_mission.Wormhole_station.tier2_mission_state)
          salvage_repair_mission.Wormhole_station.insults["shoveit"] = false
          setCommsMessage(_("wormhole-comms", [[Thanks again, Captain.

          We need you to find someone to repair this Hawking Scanner. Please bring it back once it's working again.]]))
          addCommsReply(_("wormhole-comms", "Any idea where we should take it?"), function()
              setCommsMessage(_("wormhole-comms", [[One of the nebula researchers should be able to point you in the right direction.

              If you're not sure where to find them, ask for directions at the Admin Station]]))
          end)
          addCommsReply(_("wormhole-comms", "Have you considered shoving it where the sun don't shine?"), function()
              setCommsMessage(_("wormhole-comms", [[What is it with you, anyways?]]))
              comms_source:takeReputationPoints(2)
              salvage_repair_mission.Wormhole_station.insults["shoveit"] = true
          end)
      end)
    elseif salvage_repair_mission.Wormhole_station.tier2_mission_state == "fixed" then
        addCommsReply("We have your scanner fixed.", function ()
            salvage_repair_mission.Wormhole_station.insults["kissmyfeet"] = false
            setCommsMessage(_("wormhole-comms", [[You got it fixed?

            That's amazing, Captain. Thank you so much! You and your crew are true heros of our system; may your names live on through history.

            Glory to you and your kin.]]))
            addCommsReply(_("wormhole-comms", "You're very welcome."), function()
                setCommsMessage(_("wormhole-comms", "Goodbye captain. May peace be with you."))
                salvage_repair_mission.FinishMissionRepair()
            end)
            addCommsReply(_("wormhole-comms", "Kiss my feet!"), function()
                salvage_repair_mission.Wormhole_station.insults["kissmyfeet"] = true
                --        CheckCheevoNoWormhole()
                --        if CHEEVOS["nowormhole"] then
                setCommsMessage(_("wormhole-comms", [[I was about to call this in to Admin and have them declare you a hero, but I've had enough of you.

                YOU MAY BE A HERO, BUT YOU'RE ALSO A JERK!]]))
                --        else
                --          setCommsMessage(_("wormhole-comms", [[A real peach, you are.]]))
                --        end
                salvage_repair_mission.FinishMissionRepair()
            end)
        end)
    end
end

function salvage_repair_mission.closestPlayerTo(obj, closestDistance)
-- Return the player ship closest to passed object parameter
-- Return nil if no valid result
	if obj ~= nil and obj:isValid() then
		local closestPlayer = nil
		for pidx=1, MAX_PLAYER_SHIPS do
			local p = getPlayerShip(pidx)
			if p ~= nil and p:isValid() then
				local currentDistance = distance(p,obj)
				if currentDistance < closestDistance then
					closestPlayer = p
					closestDistance = currentDistance
				end
			end
		end
		return closestPlayer
	else
		return nil
	end
end

