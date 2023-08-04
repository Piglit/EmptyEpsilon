testAssign = {}

function testAssign.init(CHEEVOS, Difficulty, Exuari_junk_stations, Investigator, Kw_enemies, Kw_mainStation, Kw_stations, Parts_station, Player, SpawnEnemies, StartMissionRepair, Wormhole_station)
	testAssign.CHEEVOS = CHEEVOS
	testAssign.Difficulty = Difficulty
	testAssign.Exuari_junk_stations = Exuari_junk_stations
	testAssign.Investigator = Investigator
	testAssign.Kw_enemies = Kw_enemies
	testAssign.Kw_mainStation = Kw_mainStation
	testAssign.Kw_stations = Kw_stations
	testAssign.Parts_station = Parts_station
	testAssign.Player = Player
	testAssign.SpawnEnemies = SpawnEnemies
	testAssign.StartMissionRepair = StartMissionRepair
	testAssign.Wormhole_station = Wormhole_station
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

function testAssign.CreateSparePartsArea()

  testAssign.Parts_station = SpaceStation():setTemplate("Small Station"):setFaction("Exuari"):setCallSign("X472"):setPosition(361326, 527812)

  testAssign.Kw_enemies = {
    CpuShip():setFaction("Kraylor"):setTemplate("Strikeship"):setCallSign("BR5"):setPosition(377672, 540642):orderStandGround(),
    CpuShip():setFaction("Kraylor"):setTemplate("Strikeship"):setCallSign("BR6"):setPosition(377541, 545431):orderStandGround(),
    CpuShip():setFaction("Kraylor"):setTemplate("Missile Cruiser"):setCallSign("CSS4"):setPosition(373724, 542711):orderStandGround()
  }
  testAssign.Investigator = testAssign.Kw_enemies[1]

  testAssign.Kw_stations = {
    SpaceStation():setTemplate("Large Station"):setFaction("Kraylor"):setCallSign("KZ2346"):setPosition(376303, 543016),
    SpaceStation():setTemplate("Medium Station"):setFaction("Kraylor"):setCallSign("KZ2682"):setPosition(400931, 541600),
    SpaceStation():setTemplate("Medium Station"):setFaction("Kraylor"):setCallSign("KZ2683"):setPosition(360825, 561407)
  }
  testAssign.Kw_mainStation = testAssign.Kw_stations[1]

  testAssign.Exuari_junk_stations = {
    SpaceStation():setTemplate("Medium Station"):setFaction("Exuari"):setCallSign("X6775"):setPosition(315754, 449577),
    SpaceStation():setTemplate("Medium Station"):setFaction("Exuari"):setCallSign("X6774"):setPosition(333160, 452975),
    SpaceStation():setTemplate("Medium Station"):setFaction("Exuari"):setCallSign("XS6773"):setPosition(326495, 458049)
  }
  SpaceStation():setTemplate("Medium Station"):setFaction("Human Navy"):setCallSign("OP722"):setPosition(328913, 490292)
  SpaceStation():setTemplate("Medium Station"):setFaction("Independent"):setCallSign("DS456"):setPosition(327511, 477797)

  Nebula():setPosition(362828, 522882)
end

function testAssign.InitKraylor()
  for _, e in ipairs(testAssign.Kw_stations) do
    e:onTakingDamage(testAssign.KWGoAggro)
  end
  for _, e in ipairs(testAssign.Kw_enemies) do
    e:onTakingDamage(testAssign.KWGoAggro)
  end
end


function testAssign.FinishMissionSpareParts()
  testAssign.Wormhole_station.mission_state = "done"
  testAssign.StartMissionRepair()
end

function testAssign.SpawnKWEnemies(start_aggro)
  if testAssign.Difficulty >= 1 then
    local x, y = sectorToXY("AI23")
    local enemies = testAssign.SpawnEnemies(x, y, random(.8,1.2), "Kraylor")
    for _, e in ipairs(enemies) do
      table.insert(testAssign.Kw_enemies, e)
    end
  end
  if testAssign.Difficulty >= 3 then
    local x, y = sectorToXY("AG26")
    local enemies = testAssign.SpawnEnemies(x, y, random(.8,1.2), "Kraylor")
    for _, e in ipairs(enemies) do
      table.insert(testAssign.Kw_enemies, e)
    end
  end
  if testAssign.Difficulty == 5 then
    local x, y = sectorToXY("AI25")
    local enemies = testAssign.SpawnEnemies(x, y, random(.8,1.2), "Kraylor")
    for _, e in ipairs(enemies) do
      table.insert(testAssign.Kw_enemies, e)
    end
  end

  for _, e in ipairs(testAssign.Kw_enemies) do
    if start_aggro then
      e:orderAttack(testAssign.Player)
    else
      e:orderStandGround()
      e:onTakingDamage(testAssign.KWGoAggro)
    end
  end
end

function testAssign.KWGoAggro(self, instigator)
  if instigator ~= testAssign.Player then return end
  for _, e in ipairs(testAssign.Kw_enemies) do
    if e.goneAggro == true then return end
    e.goneAggro = true
    e:orderAttack(testAssign.Player)
  end
  local repToLose = 10 * testAssign.Difficulty
  testAssign.Player:takeReputationPoints(repToLose)
  testAssign.Player:addToShipLog(string.format(_("KraylorWarning-shipLog", "We have lost %s reputation for breaking the treaty"),repToLose), "Red")
  testAssign.Kw_mainStation:sendCommsMessage(testAssign.Player, _("KraylorWarning-IncCall",[[You will regret this!

You have violated our non-aggression treaty, and will soon regret your actions.]]))
  testAssign.StartMissionRepair()
end

function testAssign.CheckCheevoJunk()
  testAssign.CHEEVOS["junk"] = true
  for _, stn in ipairs(testAssign.Exuari_junk_stations) do
    if stn:isValid() then
      testAssign.CHEEVOS["junk"] = false
      return
    end
  end
end

