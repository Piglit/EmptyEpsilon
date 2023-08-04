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

function CreateSparePartsArea()

  Parts_station = SpaceStation():setTemplate("Small Station"):setFaction("Exuari"):setCallSign("X472"):setPosition(361326, 527812)

  Kw_enemies = {
    CpuShip():setFaction("Kraylor"):setTemplate("Strikeship"):setCallSign("BR5"):setPosition(377672, 540642):orderStandGround(),
    CpuShip():setFaction("Kraylor"):setTemplate("Strikeship"):setCallSign("BR6"):setPosition(377541, 545431):orderStandGround(),
    CpuShip():setFaction("Kraylor"):setTemplate("Missile Cruiser"):setCallSign("CSS4"):setPosition(373724, 542711):orderStandGround()
  }
  Investigator = Kw_enemies[1]

  Kw_stations = {
    SpaceStation():setTemplate("Large Station"):setFaction("Kraylor"):setCallSign("KZ2346"):setPosition(376303, 543016),
    SpaceStation():setTemplate("Medium Station"):setFaction("Kraylor"):setCallSign("KZ2682"):setPosition(400931, 541600),
    SpaceStation():setTemplate("Medium Station"):setFaction("Kraylor"):setCallSign("KZ2683"):setPosition(360825, 561407)
  }
  Kw_mainStation = Kw_stations[1]

  Exuari_junk_stations = {
    SpaceStation():setTemplate("Medium Station"):setFaction("Exuari"):setCallSign("X6775"):setPosition(315754, 449577),
    SpaceStation():setTemplate("Medium Station"):setFaction("Exuari"):setCallSign("X6774"):setPosition(333160, 452975),
    SpaceStation():setTemplate("Medium Station"):setFaction("Exuari"):setCallSign("XS6773"):setPosition(326495, 458049)
  }
  SpaceStation():setTemplate("Medium Station"):setFaction("Human Navy"):setCallSign("OP722"):setPosition(328913, 490292)
  SpaceStation():setTemplate("Medium Station"):setFaction("Independent"):setCallSign("DS456"):setPosition(327511, 477797)

  Nebula():setPosition(362828, 522882)
end

function InitKraylor()
  for _, e in ipairs(Kw_stations) do
    e:onTakingDamage(KWGoAggro)
  end
  for _, e in ipairs(Kw_enemies) do
    e:onTakingDamage(KWGoAggro)
  end
end


function FinishMissionSpareParts()
  Wormhole_station.mission_state = "done"
  StartMissionRepair()
end

function SpawnKWEnemies(start_aggro)
  if Difficulty >= 1 then
    local x, y = sectorToXY("AI23")
    local enemies = SpawnEnemies(x, y, random(.8,1.2), "Kraylor")
    for _, e in ipairs(enemies) do
      table.insert(Kw_enemies, e)
    end
  end
  if Difficulty >= 3 then
    local x, y = sectorToXY("AG26")
    local enemies = SpawnEnemies(x, y, random(.8,1.2), "Kraylor")
    for _, e in ipairs(enemies) do
      table.insert(Kw_enemies, e)
    end
  end
  if Difficulty == 5 then
    local x, y = sectorToXY("AI25")
    local enemies = SpawnEnemies(x, y, random(.8,1.2), "Kraylor")
    for _, e in ipairs(enemies) do
      table.insert(Kw_enemies, e)
    end
  end

  for _, e in ipairs(Kw_enemies) do
    if start_aggro then
      e:orderAttack(Player)
    else
      e:orderStandGround()
      e:onTakingDamage(KWGoAggro)
    end
  end
end

function KWGoAggro(self, instigator)
  if instigator ~= Player then return end
  for _, e in ipairs(Kw_enemies) do
    if e.goneAggro == true then return end
    e.goneAggro = true
    e:orderAttack(Player)
  end
  local repToLose = 10 * Difficulty
  Player:takeReputationPoints(repToLose)
  Player:addToShipLog(string.format(_("KraylorWarning-shipLog", "We have lost %s reputation for breaking the treaty"),repToLose), "Red")
  Kw_mainStation:sendCommsMessage(Player, _("KraylorWarning-IncCall",[[You will regret this!

You have violated our non-aggression treaty, and will soon regret your actions.]]))
  StartMissionRepair()
end

function CheckCheevoJunk()
  CHEEVOS["junk"] = true
  for _, stn in ipairs(Exuari_junk_stations) do
    if stn:isValid() then
      CHEEVOS["junk"] = false
      return
    end
  end
end

