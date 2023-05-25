salvage_repair_mission = {}

function salvage_repair_mission.init(Admin_station, CHEEVOS, Defence_station, SpawnEnemies, Wormhole_station)
	salvage_repair_mission.Admin_station = Admin_station
	salvage_repair_mission.CHEEVOS = CHEEVOS
	salvage_repair_mission.Defence_station = Defence_station
	salvage_repair_mission.SpawnEnemies = SpawnEnemies
	salvage_repair_mission.Wormhole_station = Wormhole_station
	salvage_repair_mission.Kw_enemies = {
    CpuShip():setFaction("Kraylor"):setTemplate("Spinebreaker"):setCallSign("BR5"):setPosition(377672, 540642):orderStandGround(),
    CpuShip():setFaction("Kraylor"):setTemplate("Spinebreaker"):setCallSign("BR6"):setPosition(377541, 545431):orderStandGround(),
    CpuShip():setFaction("Kraylor"):setTemplate("Rockbreaker"):setCallSign("CSS4"):setPosition(373724, 542711):orderStandGround()
  }
	salvage_repair_mission.Kw_stations = {
    SpaceStation():setTemplate("Large Station"):setFaction("Kraylor"):setCallSign("KZ2346"):setPosition(376303, 543016),
    SpaceStation():setTemplate("Medium Station"):setFaction("Kraylor"):setCallSign("KZ2682"):setPosition(400931, 541600),
    SpaceStation():setTemplate("Medium Station"):setFaction("Kraylor"):setCallSign("KZ2683"):setPosition(360825, 561407)
  }
	salvage_repair_mission.Exuari_junk_stations = {
    SpaceStation():setTemplate("Medium Station"):setFaction("Exuari"):setCallSign("X6775"):setPosition(315754, 449577),
    SpaceStation():setTemplate("Medium Station"):setFaction("Exuari"):setCallSign("X6774"):setPosition(333160, 452975),
    SpaceStation():setTemplate("Medium Station"):setFaction("Exuari"):setCallSign("XS6773"):setPosition(326495, 458049)
  }
	salvage_repair_mission.Investigator = salvage_repair_mission.Kw_enemies[1]
	salvage_repair_mission.Kw_mainStation = salvage_repair_mission.Kw_stations[1]
	salvage_repair_mission.Parts_station = SpaceStation():setTemplate("Small Station"):setFaction("Exuari"):setCallSign("X472"):setPosition(361326, 527812)
	local storage = getScriptStorage()
	storage.salvage_repair_mission = {}
	storage.salvage_repair_mission.set_Difficulty = salvage_repair_mission.set_Difficulty
	storage.salvage_repair_mission.set_Player = salvage_repair_mission.set_Player
	storage.salvage_repair_mission.set_parameters = salvage_repair_mission.set_parameters
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
	if salvage_repair_mission.Admin_station == nil or not salvage_repair_mission.Admin_station:isValid() then return false end
	if salvage_repair_mission.Defense_station == nil or not salvage_repair_mission.Defense_station:isValid() then return false end
	if salvage_repair_mission.Player == nil or not salvage_repair_mission.Player:isValid() then return false end
	if salvage_repair_mission.Wormhole_station == nil or not salvage_repair_mission.Wormhole_station:isValid() then return false end
	return true
end	
function salvage_repair_mission.InitPartsStation()
  salvage_repair_mission.Parts_station:setCanBeDestroyed(false)
  salvage_repair_mission.Parts_station:setShieldsMax(1)
  salvage_repair_mission.Parts_station:setShields(1)
  salvage_repair_mission.Parts_station:onTakingDamage(function()
    salvage_repair_mission.Player:addToShipLog(_("wormhole-shipLog", "Firing on invulnerable target"), "Yellow")
    if salvage_repair_mission.Parts_station.warned == nil then
     salvage_repair_mission.Parts_station.warned = true
      salvage_repair_mission.Wormhole_station:sendCommsMessage(salvage_repair_mission.Player, _("wormhole-incCall", [[Captain, Stop!

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

function salvage_repair_mission.StartMissionSpareParts()

  local lastpart
  local missiles = salvage_repair_mission.Player:getWeaponStorage("Homing")
  for i = 0, salvage_repair_mission.Player:getWeaponTubeCount() do
    local t = salvage_repair_mission.Player:getWeaponTubeLoadType(i)
    if t == "homing" then
      missiles = missiles + 1
    end
    --if t ~= nil then salvage_repair_mission.Player:addToShipLog("DEBUG tube "..i.." type "..t.." total "..missiles, "Magenta") end
  end

  if missiles >= 6 or salvage_repair_mission.Difficulty == 5 then
    lastpart = _("wormhole-comms", "and when in doubt - apply missiles.")
  elseif salvage_repair_mission.Difficulty == 1 then
    lastpart = _("wormhole-comms", "and we've given you some extra missiles to help get the job done.")
    salvage_repair_mission.Player:setWeaponStorage("Homing", 6 - missiles + salvage_repair_mission.Player:getWeaponStorage("Homing"))
  elseif salvage_repair_mission.Difficulty == 3 then
    lastpart = _("wormhole-comms", "and go find some extra missiles to help get the job done.")
  end

  setCommsMessage(string.format(_("wormhole-comms","Great!\nThere is an old Exuari station, callsign X472, to the SE on the other side of the wormhole. It used to study the planet forming nearby, but it's been abandoned for over a century now, no one aboard and no weapons, a historical relic, really. We need you to demolish it and bring us the stabilizers from its jump drive which we can use to maintain our Hawking Scanners.\nWe have hacked the emergency integrity field so that the station can be destroyed, but there were strange disturbances when we deactivated it. We're not sure what it means, but we advise you to exercise caution...\n%s"),lastpart))

  salvage_repair_mission.Wormhole_station.mission_state = "get parts"

  salvage_repair_mission.Parts_station:setCanBeDestroyed(true)
  salvage_repair_mission.Parts_station:onDestroyed(function ()
    salvage_repair_mission.CHEEVOS["relic"] = false
    salvage_repair_mission.Wormhole_station.mission_state = "return parts"
    local hailer = nil
    if salvage_repair_mission.Investigator:isValid() then -- salvage_repair_mission.Investigator can hail on his own if alive
      hailer = salvage_repair_mission.Investigator
    end
    if hailer ~= nil and salvage_repair_mission.Kw_mainStation:isValid() then -- hail from station if they are both alive
      hailer = salvage_repair_mission.Kw_mainStation
    end

    if hailer ~= nil then -- If is alive, give a warning
      hailer:sendCommsMessage(salvage_repair_mission.Player, _("KraylorWarning-incCall", [[Ugh, humans.

This is the Kraylor Advanced "Reasearch" Project Agency (KARPA), we have detected your suspicious activity in the vicinity.

We are sending a team to investigate what you are up to. If you fire on us, there will be trouble!]]))
      salvage_repair_mission.Player:addToShipLog(_("KraylorWarning-shipLog", "The Kraylor are investigating our activities and have warned us not to escalate"), "Yellow")
      salvage_repair_mission.SpawnKWEnemies(false)
    else
      salvage_repair_mission.SpawnKWEnemies(true) -- If not alive, make all reinforcements immediately aggro
    end
    SupplyDrop():setFaction("Human Navy"):setPosition(salvage_repair_mission.Parts_station:getPosition()):setEnergy(200):onPickUp(function ()
      salvage_repair_mission.Wormhole_station:sendCommsMessage(salvage_repair_mission.Player, _("wormhole-incCall", [[Great, you got the parts!

You'd better hurry back, we've seen some Kraylor activity in the area. Hopefully your salvage mission didn't attract the wrong sort of attention.]]
      ))
      salvage_repair_mission.Player:addToShipLog(_("wormhole-shipLog", "Return the spare parts to the Wormhole Station"), "Green")
      salvage_repair_mission.Player.hasSpareParts = true
    end)

  end)
  salvage_repair_mission.Parts_station:onTakingDamage(function ()
    local x, y = salvage_repair_mission.Parts_station:getPosition()
    local x_t, y_t = salvage_repair_mission.Player:getPosition()
    local x_d = x - (2 * (x - x_t)) + irandom(-1000, 1000)
    local y_d = y - (2 * (y - y_t)) + irandom(-1000, 1000)
    salvage_repair_mission.Parts_station:setPosition(x_d, y_d)
    salvage_repair_mission.Player:addReputationPoints(1)
    salvage_repair_mission.Player:addToShipLog(_("wormhole-shipLog", "Jump Defence Activated"),"Yellow")
  end)
end

function salvage_repair_mission.UpdateMissionSpareParts()
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
  if instigator ~= salvage_repair_mission.Player then return end
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

function salvage_repair_mission.CheckCheevoJunk()
  salvage_repair_mission.CHEEVOS["junk"] = true
  for _, stn in ipairs(salvage_repair_mission.Exuari_junk_stations) do
    if stn:isValid() then
      salvage_repair_mission.CHEEVOS["junk"] = false
      return
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
  end

  -- If all the other missions are done, bump this to 2 minutes
  if salvage_repair_mission.Admin_station.mission_state == "done" and
  salvage_repair_mission.Wormhole_station.mission_state == "done" and
  salvage_repair_mission.Defence_station.tier2_mission_state == "done" then
    salvage_repair_mission.Wormhole_station.tier2_attack_countdown = 120
  else
    if salvage_repair_mission.Wormhole_station.tier2_attack_countdown == nil then
      salvage_repair_mission.Wormhole_station.tier2_attack_countdown = 900
    end
  end

  --salvage_repair_mission.Player:addToShipLog("DEBUG tier2_attack_countdown: ".. salvage_repair_mission.Wormhole_station.tier2_attack_countdown, "Magenta")
end

function salvage_repair_mission.UpdateMissionRepair(delta)
  if salvage_repair_mission.Wormhole_station.tier2_mission_state == nil then return end

  if salvage_repair_mission.Wormhole_station.tier2_mission_state == "wait for attack" then
    salvage_repair_mission.Wormhole_station.tier2_attack_countdown = salvage_repair_mission.Wormhole_station.tier2_attack_countdown - delta
    if salvage_repair_mission.Wormhole_station.tier2_attack_countdown <= 0 then
      salvage_repair_mission.Wormhole_station.tier2_mission_state = "attack"
      salvage_repair_mission.SpawnRepairEnemies()
    end
  end

  if salvage_repair_mission.Wormhole_station.tier2_mission_state == "attack" then
    local allDestroyed = true
    for _, enemy in ipairs(salvage_repair_mission.Wormhole_station.repair_enemies) do
      if enemy:isValid() then
        allDestroyed = false
        if distance(enemy,salvage_repair_mission.Player) < 2000 then
          enemy:orderAttack(salvage_repair_mission.Player)
        else
          enemy:orderAttack(salvage_repair_mission.Wormhole_station)
        end
        if distance(enemy, salvage_repair_mission.Wormhole_station) > 200000 then
          enemy:setPosition(69274, 36128)  -- Landing point when entering southern wormhole
        end
      end
    end
    if allDestroyed then
      salvage_repair_mission.Player:addReputationPoints(20)
      salvage_repair_mission.Wormhole_station.tier2_mission_state = "damaged"
      salvage_repair_mission.Wormhole_station:sendCommsMessage(salvage_repair_mission.Player, _("wormhole-incCall",[[Thanks so much, captain!

You really saved our ass there. Unfortunately our Hawking Scanner was damaged by the bomb, and we haven't been able to get it back online. Do you think you could get it fixed for us?

Please dock with us to pick up the scanner.]]))
      salvage_repair_mission.Player:addToShipLog(_("wormhole-shipLog", "Get the Hawking Scanner from the Wormhole Station"), "Green")
    end
  end

  if salvage_repair_mission.Wormhole_station.tier2_mission_state == "done" and salvage_repair_mission.Player:getDockingState() == 0 and salvage_repair_mission.Wormhole_station.victory_comms == nil  then
    salvage_repair_mission.Wormhole_station.victory_comms = true
    salvage_repair_mission.Admin_station:openCommsTo(salvage_repair_mission.Player)
  end
end

function salvage_repair_mission.FinishMissionRepair()
  salvage_repair_mission.Wormhole_station.tier2_mission_state = "done"
end

function salvage_repair_mission.SpawnRepairEnemies()
  local x, y = salvage_repair_mission.Wormhole_station:getPosition()
  salvage_repair_mission.Wormhole_station.repair_enemies = salvage_repair_mission.SpawnEnemies(x - 5000, y - 5000, random(1.8,2.2), "Kraylor")

  -- This is needed to get the Kraylor to actually attack it
  salvage_repair_mission.Wormhole_station:setFaction("Human Navy")

  for _, enemy in ipairs(salvage_repair_mission.Wormhole_station.repair_enemies) do
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

