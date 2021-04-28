patrol_mission = {}

function patrol_mission.init(Admin_station, CHEEVOS, CommsBeingAttacked, Defence_station, PP1, SpawnEnemies, Wormhole_station, Difficulty)
	patrol_mission.Admin_station = Admin_station
	patrol_mission.CHEEVOS = CHEEVOS
	patrol_mission.CommsBeingAttacked = CommsBeingAttacked
	patrol_mission.Defence_station = Defence_station
	patrol_mission.PP1 = PP1
	patrol_mission.SpawnEnemies = SpawnEnemies
	patrol_mission.Wormhole_station = Wormhole_station
	patrol_mission.Difficulty = Difficulty
	patrol_mission.Drone_stations = {
    SpaceStation():setTemplate("Small Station"):setFaction("Ghosts"):setCallSign("DS6223"):setPosition(-80404, 26565),
    SpaceStation():setTemplate("Small Station"):setFaction("Ghosts"):setCallSign("DS6224"):setPosition(-84704, 30527),
    SpaceStation():setTemplate("Small Station"):setFaction("Ghosts"):setCallSign("DS6225"):setPosition(-81989, 28198),
    SpaceStation():setTemplate("Small Station"):setFaction("Ghosts"):setCallSign("DS6222"):setPosition(-80788, 21186),
    SpaceStation():setTemplate("Small Station"):setFaction("Ghosts"):setCallSign("DS6226"):setPosition(-81508, 32713),
    SpaceStation():setTemplate("Small Station"):setFaction("Ghosts"):setCallSign("DS6234"):setPosition(-83718, 24644),
    SpaceStation():setTemplate("Small Station"):setFaction("Ghosts"):setCallSign("DS1425"):setPosition(-104181, 26524),
    SpaceStation():setTemplate("Small Station"):setFaction("Ghosts"):setCallSign("DS1435"):setPosition(-106339, 23746),
    SpaceStation():setTemplate("Small Station"):setFaction("Ghosts"):setCallSign("DS6241"):setPosition(-104996, 21138),
    SpaceStation():setTemplate("Small Station"):setFaction("Ghosts"):setCallSign("DS1453"):setPosition(-101798, 22233),
    SpaceStation():setTemplate("Small Station"):setFaction("Ghosts"):setCallSign("DS1433"):setPosition(-98728, 27731),
    SpaceStation():setTemplate("Small Station"):setFaction("Ghosts"):setCallSign("DS1426"):setPosition(-99716, 24125),
    SpaceStation():setTemplate("Small Station"):setFaction("Ghosts"):setCallSign("DS6271"):setPosition(-98611, 20912),
    SpaceStation():setTemplate("Small Station"):setFaction("Ghosts"):setCallSign("DS6231"):setPosition(-87191, 27553),
    SpaceStation():setTemplate("Small Station"):setFaction("Ghosts"):setCallSign("DS6232"):setPosition(-88233, 24260),
    SpaceStation():setTemplate("Small Station"):setFaction("Ghosts"):setCallSign("DS6230"):setPosition(-93180, 27670),
    SpaceStation():setTemplate("Small Station"):setFaction("Ghosts"):setCallSign("DS6229"):setPosition(-90154, 21282),
    SpaceStation():setTemplate("Small Station"):setFaction("Ghosts"):setCallSign("DS6254"):setPosition(-113187, 33418),
    SpaceStation():setTemplate("Small Station"):setFaction("Ghosts"):setCallSign("DS6257"):setPosition(-114746, 30023),
    SpaceStation():setTemplate("Small Station"):setFaction("Ghosts"):setCallSign("DS6263"):setPosition(-118876, 34875),
    SpaceStation():setTemplate("Small Station"):setFaction("Ghosts"):setCallSign("DS6249"):setPosition(-116859, 37036),
    SpaceStation():setTemplate("Small Station"):setFaction("Ghosts"):setCallSign("DS6243"):setPosition(-113257, 21426),
    SpaceStation():setTemplate("Small Station"):setFaction("Ghosts"):setCallSign("DS6244"):setPosition(-117291, 21330),
    SpaceStation():setTemplate("Small Station"):setFaction("Ghosts"):setCallSign("DS6247"):setPosition(-115322, 26325),
    SpaceStation():setTemplate("Small Station"):setFaction("Ghosts"):setCallSign("DS1420"):setPosition(-109366, 27152),
    SpaceStation():setTemplate("Small Station"):setFaction("Ghosts"):setCallSign("DS1418"):setPosition(-107908, 34572),
    SpaceStation():setTemplate("Small Station"):setFaction("Ghosts"):setCallSign("DS1436"):setPosition(-106339, 30558),
    SpaceStation():setTemplate("Small Station"):setFaction("Ghosts"):setCallSign("DS1419"):setPosition(-110691, 30558),
    SpaceStation():setTemplate("Small Station"):setFaction("Ghosts"):setCallSign("DS1454"):setPosition(-109745, 22233),
    SpaceStation():setTemplate("Small Station"):setFaction("Ghosts"):setCallSign("DS6210"):setPosition(-84102, 34490),
    SpaceStation():setTemplate("Small Station"):setFaction("Ghosts"):setCallSign("DS6227"):setPosition(-88817, 30377),
    SpaceStation():setTemplate("Small Station"):setFaction("Ghosts"):setCallSign("DS1447"):setPosition(-94418, 22044),
    SpaceStation():setTemplate("Small Station"):setFaction("Ghosts"):setCallSign("DS1427"):setPosition(-95334, 24236),
    SpaceStation():setTemplate("Small Station"):setFaction("Ghosts"):setCallSign("DS1449"):setPosition(-94229, 33207),
    SpaceStation():setTemplate("Small Station"):setFaction("Ghosts"):setCallSign("DS1445"):setPosition(-89499, 34153),
    SpaceStation():setTemplate("Small Station"):setFaction("Ghosts"):setCallSign("DS6269"):setPosition(-96064, 35728),
    SpaceStation():setTemplate("Small Station"):setFaction("Ghosts"):setCallSign("DS6262"):setPosition(-98980, 34974),
    SpaceStation():setTemplate("Small Station"):setFaction("Ghosts"):setCallSign("DS1443"):setPosition(-103193, 34904),
    SpaceStation():setTemplate("Small Station"):setFaction("Ghosts"):setCallSign("DS1422"):setPosition(-102933, 30937),
    SpaceStation():setTemplate("Small Station"):setFaction("Ghosts"):setCallSign("DS1428"):setPosition(-95411, 29922),
    SpaceStation():setTemplate("Small Station"):setFaction("Ghosts"):setCallSign("DS1437"):setPosition(-98909, 31499),
    SpaceStation():setTemplate("Small Station"):setFaction("Ghosts"):setCallSign("DS6264"):setPosition(-118415, 29798),
    SpaceStation():setTemplate("Small Station"):setFaction("Ghosts"):setCallSign("DS6246"):setPosition(-118973, 24308),
    SpaceStation():setTemplate("Small Station"):setFaction("Ghosts"):setCallSign("DS6266"):setPosition(-118721, 38835),
    SpaceStation():setTemplate("Small Station"):setFaction("Ghosts"):setCallSign("DS6250"):setPosition(-113497, 38189),
    SpaceStation():setTemplate("Small Station"):setFaction("Ghosts"):setCallSign("DS6251"):setPosition(-109558, 37660),
    SpaceStation():setTemplate("Small Station"):setFaction("Ghosts"):setCallSign("DS6204"):setPosition(-97263, 38093),
    SpaceStation():setTemplate("Small Station"):setFaction("Ghosts"):setCallSign("DS6252"):setPosition(-107349, 38717),
    SpaceStation():setTemplate("Small Station"):setFaction("Ghosts"):setCallSign("DS6211"):setPosition(-81220, 38285),
    SpaceStation():setTemplate("Small Station"):setFaction("Ghosts"):setCallSign("DS6206"):setPosition(-85591, 38429),
    SpaceStation():setTemplate("Small Station"):setFaction("Ghosts"):setCallSign("DS6214"):setPosition(-91067, 37228),
    SpaceStation():setTemplate("Small Station"):setFaction("Ghosts"):setCallSign("DS6205"):setPosition(-92844, 39053),
    SpaceStation():setTemplate("Small Station"):setFaction("Ghosts"):setCallSign("DS6268"):setPosition(-102543, 39055)
  }

  -- Using NE instead of more intuitive NW to be backwards compatible with old grid system
  local droneNEx, droneNEy = sectorToXY("G1")
	patrol_mission.Drone_artifacts = {}
  for i = 1, 3 + patrol_mission.Difficulty do -- 4, 6, or 8 artifacts
    local a = Artifact():setPosition(droneNEx - irandom(2000, 38000), droneNEy + irandom(2000, 18000)):setModel("artifact"..i)
    table.insert(patrol_mission.Drone_artifacts, a)
  end

	patrol_mission.Patrol_stations = {
    SpaceStation():setTemplate("Medium Station"):setFaction("Human Navy"):setCallSign("NW Checkpoint"):onTakingDamage(CommsBeingAttacked):setPosition(-14904, -31057):setRepairDocked(true):setRestocksScanProbes(true):setSharesEnergyWithDocked(true),
    SpaceStation():setTemplate("Medium Station"):setFaction("Human Navy"):setCallSign("SW Checkpoint"):onTakingDamage(CommsBeingAttacked):setPosition(-29095, 37628):setRepairDocked(true):setRestocksScanProbes(true):setSharesEnergyWithDocked(true),
    SpaceStation():setTemplate("Medium Station"):setFaction("Human Navy"):setCallSign("SE Checkpoint"):onTakingDamage(CommsBeingAttacked):setPosition(73035, 26331):setRepairDocked(true):setRestocksScanProbes(true):setSharesEnergyWithDocked(true),
    SpaceStation():setTemplate("Medium Station"):setFaction("Human Navy"):setCallSign("NE Checkpoint"):onTakingDamage(CommsBeingAttacked):setPosition(75919, -30678):setRepairDocked(true):setRestocksScanProbes(true):setSharesEnergyWithDocked(true)
  }
  for _, stn in ipairs(patrol_mission.Patrol_stations) do
    stn:setCommsFunction(patrol_mission.CommsPatrolStation)
  end
	local storage = getScriptStorage()
	storage.patrol_mission = {}
	storage.patrol_mission.set_Difficulty = patrol_mission.set_Difficulty
	storage.patrol_mission.set_Player = patrol_mission.set_Player
	storage.patrol_mission.set_parameters = patrol_mission.set_parameters
end

function patrol_mission.set_Difficulty(Difficulty)
	patrol_mission.Difficulty = Difficulty
end

function patrol_mission.set_Player(Player)
	patrol_mission.Player = Player
end

function set_parameters(Difficulty, Player)
	patrol_mission.set_Difficulty(Difficulty)
	patrol_mission.set_Player(Player)
end


function patrol_mission.check()
	if patrol_mission.Admin_station == nil or not patrol_mission.Admin_station:isValid() then return false end
	if patrol_mission.Defense_station == nil or not patrol_mission.Defense_station:isValid() then return false end
	if patrol_mission.Player == nil or not patrol_mission.Player:isValid() then return false end
	if patrol_mission.Wormhole_station == nil or not patrol_mission.Wormhole_station:isValid() then return false end
	return true
end	
function patrol_mission.InitDroneStations()
  patrol_mission.Defence_station.drones_think_were_friendly = false
  patrol_mission.Defence_station.convoy_enemies = {}
  for _, stn in ipairs(patrol_mission.Drone_stations) do
    stn.spawns_left = 5
    stn:setCanBeDestroyed(false)
    stn:onTakingDamage(patrol_mission.DroneStationGoAggro)
  end
  patrol_mission.Drone_control_station = patrol_mission.Drone_stations[irandom(1,#patrol_mission.Drone_stations)]
  patrol_mission.Drone_control_station.x, patrol_mission.Drone_control_station.y = patrol_mission.Drone_control_station:getPosition()
  patrol_mission.Drone_control_station:setCanBeDestroyed(true)
  patrol_mission.Drone_control_station:setShieldsMax(patrol_mission.Drone_control_station:getShieldMax(0) - 50)
  patrol_mission.Drone_control_station:setShields(patrol_mission.Drone_control_station:getShieldMax(0))
  patrol_mission.Drone_control_station:setHullMax(patrol_mission.Drone_control_station:getHullMax() - 50)
  patrol_mission.Drone_control_station:setHull(patrol_mission.Drone_control_station:getHullMax())
  patrol_mission.Drone_control_station:setRadarSignatureInfo(1,1,1) --Not working? Only two of the lines are high, but still higher than others
  patrol_mission.Drone_control_station.spawns_left = 1
  patrol_mission.Drone_control_station:onDestroyed(patrol_mission.FinishMissionDroneNest)
end

--==================================================
--==
--==
--==
--==
--==
--==
--==      PATROL MISSION
--==
--==
--==
--==
--==
--==
--==
--==================================================

function patrol_mission.StartMissionPatrol()
  if not patrol_mission.check() then return end
  setCommsMessage(_("defenceStn-comms", [[Great!

Start at the checkpoint in the North West. You'll need to dock at each station before proceeding to the next.]]))
  patrol_mission.Defence_station.patrol_index = 1
  -- patrol_mission.Defence_station.patrolled = [0,0,0,0]
  patrol_mission.Defence_station.next_station = patrol_mission.Patrol_stations[patrol_mission.Defence_station.patrol_index]:getCallSign()
  patrol_mission.Defence_station.mission_state = "patrolling"
end

function patrol_mission.UpdateMissionPatrol()

  if not patrol_mission.check() then return end
  if patrol_mission.Defence_station.mission_state == nil or patrol_mission.Defence_station.mission_state == "done" then return end

  if patrol_mission.Defence_station.mission_state == "patrolling" then

    if(patrol_mission.Player:isDocked(patrol_mission.Patrol_stations[patrol_mission.Defence_station.patrol_index])) then

      patrol_mission.Defence_station.patrol_index = patrol_mission.Defence_station.patrol_index + 1
      if patrol_mission.Defence_station.patrol_index > #patrol_mission.Patrol_stations then
        patrol_mission.Defence_station.patrol_index = patrol_mission.Defence_station.patrol_index - #patrol_mission.Patrol_stations
        patrol_mission.Defence_station.patrol_second_round = true
      end

      patrol_mission.Defence_station.next_station = patrol_mission.Patrol_stations[patrol_mission.Defence_station.patrol_index]:getCallSign()

      -- Start attack on SW station
      if patrol_mission.Defence_station.patrol_second_round ~= nil and patrol_mission.Defence_station.patrol_index == 1 then
        patrol_mission.Defence_station.mission_state = "patrol attack"
        patrol_mission.SpawnPatrolEnemies()
      else
        patrol_mission.Defence_station:sendCommsMessage(patrol_mission.Player, string.format(_("defenceStn-incCall","Please proceed to %s"),patrol_mission.Defence_station.next_station))
        patrol_mission.Player:addToShipLog(string.format(_("defenceStn-shipLog","Please proceed to %s"),patrol_mission.Defence_station.next_station), "Green")
      end
      patrol_mission.Player:addReputationPoints(2)
    end
  end

  if patrol_mission.Defence_station.mission_state == "patrol attack" then
    local allDestroyed = true
    for _, enemy in ipairs(patrol_mission.Defence_station.patrol_enemies) do
      if enemy:isValid() then
        allDestroyed = false
        if distance(enemy,patrol_mission.Player) < 2000 then
          enemy:orderAttack(patrol_mission.Player)
        else
          enemy:orderAttack(patrol_mission.Patrol_stations[2])
        end
      end
    end
    if allDestroyed then
      patrol_mission.Defence_station:sendCommsMessage(patrol_mission.Player, _("defenceStn-incCall",[[Great work captain!

You have repelled the attackers and the SW Checkpoint is safe for now, but intelligence reports show a huge drone convoy in your vicinity to the NW.

INVESTIGATE BUT DO NOT ENGAGE! We have it on good word that attacking this convoy is extremely risky. Keep your distance, but we'd like to know where they are going.]]))
      patrol_mission.Player:addToShipLog("defenceStn-shipLog","Investigte the convoy, but DO NOT ENGAGE", "Red")

      patrol_mission.Defence_station.mission_state = "drone convoy"
      patrol_mission.SpawnConvoyEnemies()
    end
  end

  if patrol_mission.Defence_station.mission_state == "drone convoy" then
    patrol_mission.CheckConvoyArrived()
  end
end

function patrol_mission.CheckConvoyArrived()
  if not patrol_mission.check() then return end
  for _, enemy in ipairs(patrol_mission.Defence_station.convoy_enemies) do
    -- Make them disappear when they get to G0
    if enemy:isValid() then
      if distance(enemy, enemy.dx, enemy.dy) < 1000 and not enemy.goneAggro then
        enemy:destroy()
      end
    else
      if enemy.arrived == nil then
        enemy.arrived = true -- 'arrived' even if it's to valhala
        patrol_mission.Defence_station.convites_arrived = patrol_mission.Defence_station.convites_arrived + 1
      end
    end
  end

  -- Wait for half the convites to arrive during first tier patrol mission
  if patrol_mission.Defence_station.convites_arrived > (#patrol_mission.Defence_station.convoy_enemies / 2) and patrol_mission.Defence_station.tier2_mission_state == nil then
    patrol_mission.Defence_station.tier2_mission_state = "pre-start"
    patrol_mission.Defence_station:sendCommsMessage(patrol_mission.Player, _("defenceStn-incCall","Come in, Captain.\nWe have the info we need about that convoy and strongly discourage any further engagement.\nYour assistance is required with a secret mission. Dock with us to receive further instructions when you're ready."))
    patrol_mission.Player:addToShipLog(_("defenceStn-shipLog","Dock with the Defence Station to start another mission"), "Green")
    patrol_mission.SpawnMockDroneShip()
  end

  if patrol_mission.Defence_station.convites_arrived == #patrol_mission.Defence_station.convoy_enemies then
    patrol_mission.Defence_station.mission_state = "done"
    patrol_mission.Defence_station.convoy_enemies = {}
    if patrol_mission.Defence_station.tier2_mission_state == "joinconvoy" or patrol_mission.Defence_station.tier2_mission_state == "arrived" then
      patrol_mission.SpawnConvoyEnemies()
    end
  end
end

--==================================================
--==
--==
--==
--==
--==
--==
--==      DRONE MISSION
--==
--==
--==
--==
--==
--==
--==
--==================================================

function patrol_mission.StartMissionDroneNest()
  setCommsMessage(_("defenceStn-comms", [[Good luck]]))
  patrol_mission.SpawnMockDroneShip()
  patrol_mission.TransferToDrone()
  patrol_mission.Defence_station.convoy_timer = getScenarioTime()
  patrol_mission.Defence_station.tier2_mission_state = "joinconvoy"
end

function patrol_mission.UpdateMissionDroneNest()
  if not patrol_mission.check() then return end
  if patrol_mission.Defence_station.tier2_mission_state == nil or patrol_mission.Defence_station.tier2_mission_state == "done" then return end

  if patrol_mission.Defence_station.tier2_mission_state == "joinconvoy" then
    if (getScenarioTime() - patrol_mission.Defence_station.convoy_timer >= 60) and #patrol_mission.Defence_station.convoy_enemies == 0 then
      patrol_mission.SpawnConvoyEnemies()
    end

    local with_convoy = false
    if #patrol_mission.Defence_station.convoy_enemies ~= 0 then
      patrol_mission.CheckConvoyArrived()
      for _, enemy in ipairs(patrol_mission.Defence_station.convoy_enemies) do
        if enemy:isValid() and distance(patrol_mission.Player, enemy) < 5000 then
          with_convoy = true
        end
      end
    end

    local px, py = patrol_mission.Player:getPosition()
    local gx, gy = sectorToXY("G-1")  -- -120000, 20000    (-120848, 27550)
    if (px - gx > -2500) and (px - gx < 42500) and (py - gy > -2500) and (py - gy < 22500) then  -- Inside nest area
      if with_convoy and patrol_mission.Player:getFaction() == "Ghosts" and not patrol_mission.Defence_station.cover_blown then
        patrol_mission.Defence_station.tier2_mission_state = "arrived"
        patrol_mission.Defence_station.drones_think_were_friendly = true
        patrol_mission.Defence_station:sendCommsMessage(patrol_mission.Player, _("defenceStn-incCall", [[Arrived, scan the security beacons]]))
      else
        if not patrol_mission.Defence_station.cover_blown then
          patrol_mission.Defence_station.cover_blown = true
          patrol_mission.Defence_station:sendCommsMessage(patrol_mission.Player, _("defenceStn-incCall", [[Your cover has been blown and the proximity defence system remains active. We suggest leaving and trying again to arrive with a future convoy.]]))
          patrol_mission.Player:addToShipLog(_("defenceStn-shipLog", "Our cover has been blown"), "Red")
        end
      end
    else
      if patrol_mission.Defence_station.cover_blown then
        patrol_mission.Player:addToShipLog(_("defenceStn-shipLog", "We should be good to try again"), "Green")
        patrol_mission.Defence_station.cover_blown = false
      end
    end
  end

  if patrol_mission.Defence_station.tier2_mission_state == "arrived" then
    patrol_mission.CheckConvoyArrived()
  end
end

function patrol_mission.FinishMissionDroneNest ()
  if not patrol_mission.check() then return end
  if patrol_mission.MockDroneShip ~= nil and patrol_mission.MockDroneShip:isValid() then
    patrol_mission.MockDroneShip:destroy()
  end
  for _, e in ipairs(patrol_mission.Defence_station.convoy_enemies) do
    if patrol_mission.Difficulty == 5 then
      e:orderRoaming()
    else
      e:orderIdle()
    end
  end
  for _, stn in ipairs(patrol_mission.Drone_stations) do
    if stn:isValid() then
      if stn == patrol_mission.Drone_control_station then
        stn:onDestroyed(function ()
          print(patrol_mission.Player) --https://github.com/daid/EmptyEpsilon/issues/690
        end)
      end
      stn:destroy()
    end
  end
  patrol_mission.Player:setFaction("Human Navy")
  patrol_mission.Liquidation_station = SpaceStation():setTemplate("Small Station"):setFaction("Human Navy"):onTakingDamage(patrol_mission.CommsBeingAttacked):setCallSign("DB-3"):setPosition(patrol_mission.Drone_control_station.x, patrol_mission.Drone_control_station.y):setCommsFunction(patrol_mission.CommsDroneStation)
  patrol_mission.Liquidation_station:sendCommsMessage(patrol_mission.Player, _("drone-incCall", [[Great work, Captain!

We have taken control of this station and will be liquidating spare parts from the wreckage.]]))
  patrol_mission.Player:addToShipLog(_("drone-shipLog", "DB-3 has a collection of spare parts"), "Green")
  patrol_mission.Player:addReputationPoints(20)

  -- If all other discoverable missions are done, shorten the fuze on the repair mission start
  if patrol_mission.Admin_station.mission_state == "done" and
  patrol_mission.Wormhole_station.mission_state == "done" and
  patrol_mission.Wormhole_station.tier2_attack_countdown > 120 then
    patrol_mission.Wormhole_station.tier2_attack_countdown = 120
  end
  patrol_mission.Defence_station.tier2_mission_state = "done"
  patrol_mission.Defence_station.mission_state = "done"
end

function patrol_mission.UpdateDroneStations()
  if not patrol_mission.check() then return end

  -- Proximity Defence
  if patrol_mission.Defence_station.drones_think_were_friendly ~= true then
    for _, stn in ipairs(patrol_mission.Drone_stations) do
      if stn:isValid() then
        if distance(patrol_mission.Player, stn) > 80000 then return end -- Exit early (don't iterate all stations) if player is far
        if distance(patrol_mission.Player, stn) < 2000 and stn.prox_spawned == nil then
          stn.prox_spawned = true
          local x, y = stn:getPosition()
          local x_t, y_t = patrol_mission.Player:getPosition()
          local x_d = x - (2 * (x - x_t)) + irandom(-2000, 2000)
          local y_d = y - (2 * (y - y_t)) + irandom(-2000, 2000)
          local defenders = patrol_mission.SpawnEnemies(x_d, y_d, random(0.1,0.3), "Ghosts")
          for _, d in ipairs(defenders) do
            d:orderAttack(patrol_mission.Player)
            table.insert(patrol_mission.Defence_station.ghost_defenders, d)
          end
          stn:sendCommsMessage(patrol_mission.Player, _("drone-incCall", [[PROXIMITY DEFENCE SYSTEM ACTIVATED]]))
          patrol_mission.Player:addToShipLog(_("drone-shipLog", "We got too close to a drone station and it launched defences."), "Red")
          patrol_mission.CHEEVOS["distancing"] = false
        end
      end
    end
  end

  -- Security beacons
  if patrol_mission.Defence_station.tier2_mission_state ~= nil then
    if patrol_mission.Defence_station.all_beacons_scanned ~= true then
      local scanned = 0
      local desc = _("scienceDescription-beacons", "The Ghosts drone security beacons. If we scan them all, we should be able to find the control station. We'll need to get pretty close.")
      for __, a in ipairs(patrol_mission.Drone_artifacts) do
        if a:isScannedBy(patrol_mission.Player) then
          patrol_mission.CHEEVOS["DMCA"] = false
          scanned = scanned + 1
        elseif distance(patrol_mission.Player, a) < 2500 then
          if a.close_latch ~= true then
            a.close_latch = true
            a:setDescriptions(desc, _("scienceDescription-beacons", "The beamforming configuration from this beacon will help the boffins triangulate the location of the central control.")):setScanningParameters(1,1)
          end
        else
            a.close_latch = false
            a:setDescriptions(desc, ""):setScanningParameters(0,0)
        end
      end
      if scanned >= #patrol_mission.Drone_artifacts then
        patrol_mission.Defence_station.all_beacons_scanned = true
        patrol_mission.Defence_station:sendCommsMessage(patrol_mission.Player,string.format(_("defenceStn-incCall","Great work!\nOur boffins were able to piece together the data and figure out where the commands are coming from.\nYou must destroy station %s"),patrol_mission.Drone_control_station:getCallSign()))
        patrol_mission.Player:addToShipLog(string.format(_("defenceStn-shipLog","The drone control station is %s"),patrol_mission.Drone_control_station:getCallSign()), "Green")
      end
    end
  end
end

function patrol_mission.CheckDefeatConditions()
  if not patrol_mission.check() then return end
  for _, stn in ipairs(patrol_mission.Patrol_stations) do
    if not stn:isValid() then
      patrol_mission.Player:addToShipLog(_("defeat-shipLog","DEFEAT - A Patrol Station has been destroyed"), "Red")
      victory("Exuari")
    end
  end

  for _, stn in ipairs({patrol_mission.Admin_station, patrol_mission.Defence_station, patrol_mission.Wormhole_station}) do
    if not stn:isValid() then
      patrol_mission.Player:addToShipLog(_("defeat-shipLog","DEFEAT - A Core station (Admin, Defence, Wormhole) has been destroyed"), "Red")
      victory("Exuari")
    end
  end

  if patrol_mission.Defence_station.tier2_mission_state == "done" then
    if not patrol_mission.Liquidation_station:isValid() then
      patrol_mission.Player:addToShipLog(_("defeat-shipLog","DEFEAT - Station B-3 has been destroyed"), "Red")
      victory("Exuari")
    end
  end

  if not patrol_mission.Player:isValid() then victory("Exuari") end
end

function patrol_mission.CommsDroneStation(comms_source, comms_target)
  if not comms_source:isDocked(comms_target) then
    setCommsMessage(_("drone-comms", [[We oversee the B-3 liquidation of the Ghosts assets.

Dock with us to check out what we've got.]]))
  else -- DOCKED COMMS
    setCommsMessage(_("drone-comms", [[You need any of this stuff?

It's not for sale, as such. You'll need to get a requisition from the Admin Station in order to carry anything out.
]]))
    addCommsReply(_("drone-comms", "Proximity Sensor"), function ()
      setCommsMessage(_("drone-comms", "Activates when ships get too close"))
      addCommsReply(_("<- Back"), patrol_mission.CommsDroneStation)
    end)
    addCommsReply(_("drone-comms", "Intelligence Accelerator"), function ()
      setCommsMessage(_("drone-comms", "Too expensive to use for video games."))
      addCommsReply(_("<- Back"), patrol_mission.CommsDroneStation)
    end)
    addCommsReply(_("drone-comms", "Graviton Lens"), function ()
      if patrol_mission.Admin_station.req_lens == true then
        patrol_mission.Wormhole_station.tier2_mission_state = "fixed"
        setCommsMessage(_("drone-comms", [[Ooooh, a requisition!

Alright, enjoy... focusing your gravitons, I guess!]]))
      else
        setCommsMessage(_("drone-comms", "For focusing the gravitational field."))
        addCommsReply(_("<- Back"), patrol_mission.CommsDroneStation)
      end
    end)
    addCommsReply(_("drone-comms", "Holographic Projector"), function ()
      setCommsMessage(_("drone-comms", "Shows very convincing drone stations"))
      addCommsReply(_("<- Back"), patrol_mission.CommsDroneStation)
    end)
  end
end

function patrol_mission.DroneStationGoAggro(self, instigator)
  if not patrol_mission.check() then return end
  if instigator ~= patrol_mission.Player then return end

  patrol_mission.Defence_station.drones_think_were_friendly = false
  patrol_mission.Player:setFaction("Human Navy")

  if self.spawns_left > 0 then
    self.spawns_left = self.spawns_left - 1
    local x, y = self:getPosition()
    local spx, spy = vectorFromAngle(irandom(0, 360), 1500)
    local defenders = patrol_mission.SpawnEnemies(x + spx, y + spy, random(.8,1.2), "Ghosts")
    for _, ship in ipairs(defenders) do
      table.insert(patrol_mission.Defence_station.ghost_defenders, ship)
    end
  end

  if not self:getCanBeDestroyed() then
    self:setShields(self:getShieldMax(0))
    self:setHull(self:getHullMax(0))
    patrol_mission.Player:addToShipLog(_("warning-shipLog", "This station appears immune to our attacks"), "Yellow")
  end

  patrol_mission.ConvoyGoAggro(nil, instigator)
end

function patrol_mission.SpawnMockDroneShip()
  if patrol_mission.MockDroneShip == nil then
    local sx, sy = patrol_mission.Defence_station:getPosition()
    patrol_mission.MockDroneShip = CpuShip():setFaction("Ghosts"):setTemplate("Hathcock"):setCallSign("DD007"):setPosition(sx+1000,sy+1000):orderIdle()
    patrol_mission.MockDroneShip:setCommsFunction(function ()
      setCommsMessage(_("drone-comms","Do not communicate on this channel."))
    end)
    patrol_mission.MockDroneShip:setCanBeDestroyed(false)
    patrol_mission.MockDroneShip:onTakingDamage(function ()
      patrol_mission.Defence_station:sendCommsMessage(patrol_mission.Player, _("drone-incCall",[[DISENGAGE!

Captain, it's not what it looks like. Please dock with us and we will explain everything.]]))
    end)
  end
end

--==================================================
--==
--==
--==
--==
--==
--==
--==      OTHER MACHINERY
--==
--==
--==
--==
--==
--==
--==
--==================================================

function patrol_mission.TransferToDrone()
  local swapx, swapy = patrol_mission.MockDroneShip:getPosition()
  local swapRotate = patrol_mission.MockDroneShip:getRotation()
  patrol_mission.MockDroneShip:setPosition(500,500)
  patrol_mission.DroneShip = PlayerSpaceship():setFaction("Ghosts"):setTemplate("Hathcock"):setCallSign("DD007"):setPosition(swapx, swapy)
  patrol_mission.DroneShip:setRotation(swapRotate)
  patrol_mission.DroneShip:commandTargetRotation(swapRotate)
  patrol_mission.MockDroneShip:destroy()

  patrol_mission.DroneShip:setWeaponStorage("Homing", 3)
  patrol_mission.DroneShip:setWeaponStorageMax("Homing", 6)
  patrol_mission.DroneShip:setWeaponStorage("HVLI", 6)
  patrol_mission.DroneShip:setWeaponStorage("Nuke", 2)
  patrol_mission.DroneShip:setWeaponStorageMax("Nuke", 2)
  patrol_mission.DroneShip:setWeaponStorage("EMP", 2)
  patrol_mission.DroneShip:setWarpDrive(true)
  patrol_mission.DroneShip:setWarpSpeed(400)
  patrol_mission.DroneShip:setJumpDrive(false)

  patrol_mission.Player:transferPlayersToShip(patrol_mission.DroneShip)
  patrol_mission.CHEEVOS["ourship"] = false
  patrol_mission.Player = patrol_mission.DroneShip

  patrol_mission.Player:addToShipLog(_("drone-shipLog", "This ship will not activate the drone station proximity defences as long as you arrive with a convoy."),"Yellow")
end

function patrol_mission.SpawnConvoyEnemies()
  local x, y = sectorToXY("F3") -- Rand nest location
  patrol_mission.Defence_station.convoy_enemies = patrol_mission.SpawnEnemies(x + 10000, y + 15000, 40, "Ghosts")
  patrol_mission.Defence_station.convites_arrived = 0
  local dx, dy = sectorToXY("G0") -- Rand nest location
  dx = dx + 10000
  dy = dy + 10000
  for i, enemy in ipairs(patrol_mission.Defence_station.convoy_enemies) do
    enemy.dx = dx
    enemy.dy = dy
    enemy:setCallSign("D0-" .. i+42)
    enemy:setWarpDrive(true)
    enemy:setWarpSpeed(400);
    enemy:setJumpDrive(false)
    if patrol_mission.Defence_station.mission_state == "drone convoy" or
       patrol_mission.Defence_station.drones_think_were_friendly == true or
       patrol_mission.Defence_station.tier2_mission_state == "pre-start" or
       patrol_mission.Defence_station.tier2_mission_state == "joinconvoy" then
      enemy:orderFlyTowardsBlind(dx,dy)
    else
      enemy:orderAttack(patrol_mission.Player)
    end
    enemy:onTakingDamage(patrol_mission.ConvoyGoAggro)
  end
end

function patrol_mission.SpawnPatrolEnemies()
  local x, y = patrol_mission.Patrol_stations[2]:getPosition()
  patrol_mission.Defence_station.patrol_enemies = patrol_mission.SpawnEnemies(x - 5000, y - 5000, random(1.6,2), "Ghosts")

  for _, enemy in ipairs(patrol_mission.Defence_station.patrol_enemies) do
    enemy:orderAttack(patrol_mission.Patrol_stations[2])
  end
  patrol_mission.Defence_station:sendCommsMessage(patrol_mission.Player, _("defenceStnCheckpoint-IncCall",[[RED ALERT!

The SW Checkpoint is under attack. Don't mess around, get down there and help them!]]))
  patrol_mission.Player:addToShipLog(_("defenceStnCheckpoint-shipLog","Defend the SW checkpoint"), "Red")
end

function patrol_mission.ConvoyGoAggro(__, instigator)
  if not patrol_mission.check() then return end
  if instigator ~= patrol_mission.Player then return end

  if #patrol_mission.Defence_station.convoy_enemies > 0 then
  	if patrol_mission.Player.aggro_message == nil then
	    patrol_mission.Defence_station:sendCommsMessage(patrol_mission.Player, _("defenceStn-incCall", "It looks like you've aggro'd the convoy.\nGood luck to you! Try to keep them from destroying our stations!"))
	    patrol_mission.Player.aggro_message = "sent"
	end
  end

  patrol_mission.Player:setFaction("Human Navy")
  patrol_mission.Defence_station.drones_think_were_friendly = false
  for _, e in ipairs(patrol_mission.Defence_station.convoy_enemies) do
    if e.goneAggro ~= nil then return end   -- Bail if already activated
    e.goneAggro = true
    if e:isValid() then e:orderAttack(patrol_mission.Player)end
  end
end

function patrol_mission.CheckCheevoHeros()
  if not patrol_mission.check() then return end
  local total = patrol_mission.PP1:getReputationPoints()
  if patrol_mission.DroneShip ~= nil then
    total = total + patrol_mission.DroneShip:getReputationPoints()
  end
  if total > 100 then
    patrol_mission.CHEEVOS["heros"] = true
  else
    patrol_mission.CHEEVOS["heros"] = false
  end
end

function patrol_mission.CommsPatrolStation(comms_source, comms_target)
  setCommsMessage(_("checkpointsStn-comms", "Not much here bud, just doing checkpoint kinda things, ya know?"))
end

