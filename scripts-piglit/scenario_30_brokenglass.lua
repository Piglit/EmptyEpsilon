-- Name: Broken Glass
-- Description: Support research activities in the Zeta Belt and keep the researchers safe. Difficulty balances and 10 achievements to complete.
---
---Duration: Plan for 3+ hours on Easy, with harder difficulties taking longer
---Player ships: 1
---
---Author: Chris Sibbit. Revisions: Xansta, Muerte Jan2023
---Created: Dec2022
---Feedback: USN Discord: https://discord.gg/7Kr32ezJFF in the #ee-scenario-feedback channel
-- Type: Replayable Mission
-- Setting[Difficulty]: Configures the difficulty in the scenario. Default is Easy
-- Difficulty[Easy|Default]: Minor enemy resistance and easier missions.
-- Difficulty[Medium]: More robust resistance with more risk (takes longer).
-- Difficulty[Hard]: Significant enemy resistance.

require("utils.lua")
require("plots/lost_mission.lua")
require("plots/salvage_repair_mission.lua")
require("plots/patrol_mission.lua")

function init()

  SetSettings()

  -- == Core area
  Coreplanet = Planet():setPosition(29855, -4285):setPlanetRadius(3000):setPlanetAtmosphereColor(0.20,0.20,1.00):setDistanceFromMovementPlane(-2000.00):setPlanetAtmosphereTexture("planets/atmosphere.png"):setPlanetSurfaceTexture("planets/planet-1.png"):setPlanetCloudTexture("planets/clouds-1.png"):setPlanetCloudRadius(3150.00)
  Planet():setPosition(30179, 9539):setOrbit(Coreplanet, 120):setPlanetRadius(1000):setDistanceFromMovementPlane(-2000.00):setPlanetSurfaceTexture("planets/moon-1.png"):setPlanetCloudRadius(1050.00):setAxialRotationTime(20.00):setPlanetAtmosphereColor(0.20,0.20,1.00):setPlanetAtmosphereTexture("planets/atmosphere.png")

  -- Mission stations
  Admin_station =  SpaceStation():setTemplate("Small Station"):setFaction("Human Navy"):onTakingDamage(CommsBeingAttacked):setCallSign("Admin Stn"):setPosition(35170, -8650):setRepairDocked(true):setRestocksScanProbes(true):setSharesEnergyWithDocked(true)
  Defence_station = SpaceStation():setTemplate("Medium Station"):setFaction("Human Navy"):onTakingDamage(CommsBeingAttacked):setCallSign("Defence Stn"):setPosition(-9366, 7900):setRepairDocked(true):setRestocksScanProbes(true):setSharesEnergyWithDocked(true)
  Wormhole_station = SpaceStation():setTemplate("Medium Station"):setFaction("Independent"):onTakingDamage(CommsBeingAttacked):setCallSign("Wormhole Stn"):setPosition(77152, 32816):setRepairDocked(true):setRestocksScanProbes(true):setSharesEnergyWithDocked(true)

  -- Resupply stations
  Resupply_stations = {
    SpaceStation():setTemplate("Medium Station"):setFaction("Human Navy"):setCallSign("DS917"):setPosition(21309, -8207):setRepairDocked(true):setRestocksScanProbes(true):setSharesEnergyWithDocked(true),
    SpaceStation():setTemplate("Medium Station"):setFaction("Human Navy"):setCallSign("DS921"):setPosition(26395, 29186):setRepairDocked(true):setRestocksScanProbes(true):setSharesEnergyWithDocked(true),
    SpaceStation():setTemplate("Huge Station"):setFaction("Human Navy"):setCallSign("DS963"):setPosition(15750, 15698):setRepairDocked(true):setRestocksScanProbes(true):setSharesEnergyWithDocked(true)
  }

  -- Patrol Stations
  -- XXX patrol_mission.Patrol_stations -> patrol_mission.lua

  -- Convoy visibility
  Lookout_stations = {
    SpaceStation():setTemplate("Medium Station"):setFaction("Human Navy"):setCallSign("DS819"):setPosition(-44255, 22569):setRepairDocked(true):setRestocksScanProbes(true):setSharesEnergyWithDocked(true),
    SpaceStation():setTemplate("Medium Station"):setFaction("Human Navy"):setCallSign("DS818"):setPosition(-35690, 21033):setRepairDocked(true):setRestocksScanProbes(true):setSharesEnergyWithDocked(true)
  }
  SpaceStation():setTemplate("Medium Station"):setFaction("Ghosts"):setCallSign("DS820"):setPosition(-38789, 14192)
  SpaceStation():setTemplate("Medium Station"):setFaction("Ghosts"):setCallSign("DS821"):setPosition(-47557, 15983)

  -- Wormholes
  WormHole():setPosition(71274, 38128):setTargetPosition(334910, 473961)
  WormHole():setPosition(332910, 471961):setTargetPosition(69274, 36128)

  -- == Western Belt
  Asteroid():setPosition(11802, 69624):setSize(128)
  Asteroid():setPosition(10934, 68384):setSize(122)
  Asteroid():setPosition(15771, 74834):setSize(113)
  Asteroid():setPosition(15523, 71981):setSize(115)
  Asteroid():setPosition(19988, 68632):setSize(112)
  Asteroid():setPosition(1384, 68384):setSize(123)
  Asteroid():setPosition(-1806, 65192):setSize(129)
  Asteroid():setPosition(-3808, 63960):setSize(121)
  Asteroid():setPosition(639, 62555):setSize(119)
  Asteroid():setPosition(4360, 64043):setSize(118)
  Asteroid():setPosition(8453, 63547):setSize(124)
  Asteroid():setPosition(5601, 68384):setSize(126)
  Asteroid():setPosition(-496, 57029):setSize(118)
  Asteroid():setPosition(-2422, 57568):setSize(130)
  Asteroid():setPosition(3740, 56601):setSize(112)
  Asteroid():setPosition(2004, 55113):setSize(124)
  Asteroid():setPosition(43, 54872):setSize(115)
  Asteroid():setPosition(-3346, 61033):setSize(115)
  Asteroid():setPosition(428, 61572):setSize(128)
  Asteroid():setPosition(-1729, 61264):setSize(129)
  Asteroid():setPosition(1044, 58492):setSize(129)
  Asteroid():setPosition(-2499, 59493):setSize(122)
  Asteroid():setPosition(1198, 53717):setSize(118)
  Asteroid():setPosition(-2807, 53332):setSize(110)
  Asteroid():setPosition(-2653, 55411):setSize(110)
  Asteroid():setPosition(-3500, 46709):setSize(113)
  Asteroid():setPosition(-3115, 48480):setSize(115)
  Asteroid():setPosition(-5194, 50714):setSize(113)
  Asteroid():setPosition(-1575, 51407):setSize(119)
  Asteroid():setPosition(-188, 49635):setSize(122)
  Asteroid():setPosition(-650, 47017):setSize(123)
  Asteroid():setPosition(659, 45323):setSize(125)
  Asteroid():setPosition(2969, 47017):setSize(115)
  Asteroid():setPosition(1737, 50637):setSize(117)
  Asteroid():setPosition(-1343, 44476):setSize(114)
  Asteroid():setPosition(-6580, 44630):setSize(114)
  Asteroid():setPosition(-3423, 45400):setSize(111)
  Asteroid():setPosition(-3731, 43089):setSize(117)
  Asteroid():setPosition(-2275, 41442):setSize(117)
  Asteroid():setPosition(-5348, 42011):setSize(121)
  Asteroid():setPosition(-4640, 41442):setSize(122)
  Asteroid():setPosition(386, 42329):setSize(112)
  Asteroid():setPosition(-6676, -2264):setSize(116)
  Asteroid():setPosition(-6567, -15439):setSize(115)
  Asteroid():setPosition(-7135, -13925):setSize(111)
  Asteroid():setPosition(-11397, -16132):setSize(119)
  Asteroid():setPosition(-2972, -11844):setSize(117)
  Asteroid():setPosition(-19342, -20974):setSize(118)
  Asteroid():setPosition(-20758, -23197):setSize(118)
  Asteroid():setPosition(-21326, -18845):setSize(116)
  Asteroid():setPosition(-18443, -22568):setSize(126)
  Asteroid():setPosition(-17163, -23007):setSize(116)
  Asteroid():setPosition(-10351, -19601):setSize(124)
  Asteroid():setPosition(-16739, -21574):setSize(114)
  Asteroid():setPosition(-16611, -19236):setSize(126)
  Asteroid():setPosition(-13843, -17626):setSize(124)
  Asteroid():setPosition(-12811, -18655):setSize(114)
  Asteroid():setPosition(-14136, -20926):setSize(112)
  Asteroid():setPosition(-13000, -22629):setSize(123)
  Asteroid():setPosition(-3653, 18428):setSize(126)
  Asteroid():setPosition(-2092, 19915):setSize(115)
  Asteroid():setPosition(780, 20351):setSize(112)
  Asteroid():setPosition(-1289, 20844):setSize(110)
  Asteroid():setPosition(-828, 17833):setSize(123)
  Asteroid():setPosition(-3505, 21849):setSize(129)
  Asteroid():setPosition(-977, 22964):setSize(121)
  Asteroid():setPosition(-4936, 22125):setSize(117)
  Asteroid():setPosition(-5921, 25181):setSize(126)
  Asteroid():setPosition(-6567, 18964):setSize(124)
  Asteroid():setPosition(-2984, 8018):setSize(119)
  Asteroid():setPosition(-1423, 10100):setSize(115)
  Asteroid():setPosition(-902, 13446):setSize(116)
  Asteroid():setPosition(-3282, 12480):setSize(112)
  Asteroid():setPosition(-5914, 15481):setSize(129)
  Asteroid():setPosition(-2761, 17090):setSize(121)
  Asteroid():setPosition(-4471, 16569):setSize(111)
  Asteroid():setPosition(-3579, 13372):setSize(125)
  Asteroid():setPosition(-5261, 10582):setSize(122)
  Asteroid():setPosition(-977, 11885):setSize(123)
  Asteroid():setPosition(386, 15522):setSize(129)
  Asteroid():setPosition(-5724, 28039):setSize(128)
  Asteroid():setPosition(-4640, 30108):setSize(126)
  Asteroid():setPosition(-3556, 26068):setSize(114)
  Asteroid():setPosition(-2965, 28039):setSize(126)
  Asteroid():setPosition(-2472, 29813):setSize(112)
  Asteroid():setPosition(-1092, 24294):setSize(120)
  Asteroid():setPosition(-2570, 24885):setSize(127)
  Asteroid():setPosition(-1585, 25378):setSize(112)
  Asteroid():setPosition(-3753, 31587):setSize(120)
  Asteroid():setPosition(-2669, 33262):setSize(117)
  Asteroid():setPosition(-2373, 34543):setSize(126)
  Asteroid():setPosition(-1486, 31981):setSize(129)
  Asteroid():setPosition(879, 32769):setSize(111)
  Asteroid():setPosition(-994, 27447):setSize(125)
  Asteroid():setPosition(-994, 30207):setSize(126)
  Asteroid():setPosition(-2910, -1648):setSize(128)
  Asteroid():setPosition(-2241, -1127):setSize(130)
  Asteroid():setPosition(-3505, -681):setSize(128)
  Asteroid():setPosition(-1943, -5663):setSize(127)
  Asteroid():setPosition(-4769, -5068):setSize(114)
  Asteroid():setPosition(-3505, 6234):setSize(113)
  Asteroid():setPosition(-2910, 3780):setSize(110)
  Asteroid():setPosition(-1646, 7349):setSize(127)
  Asteroid():setPosition(-2687, 880):setSize(124)
  Asteroid():setPosition(-4049, 34740):setSize(114)
  Asteroid():setPosition(-5724, 33853):setSize(113)
  Asteroid():setPosition(-1051, 62):setSize(119)
  Asteroid():setPosition(-382, 6457):setSize(116)
  Asteroid():setPosition(-1869, -6704):setSize(128)
  Asteroid():setPosition(-1497, -10719):setSize(117)
  Asteroid():setPosition(-1571, 3631):setSize(123)
  Asteroid():setPosition(-1720, -8340):setSize(127)
  Asteroid():setPosition(-1274, -3284):setSize(118)
  Asteroid():setPosition(-382, -1574):setSize(113)
  Asteroid():setPosition(64, -5068):setSize(111)
  Asteroid():setPosition(-501, 40062):setSize(113)
  Asteroid():setPosition(-2275, 38190):setSize(113)
  Asteroid():setPosition(-3753, 40062):setSize(118)
  Asteroid():setPosition(-2866, 36317):setSize(128)
  Asteroid():setPosition(-4049, 36810):setSize(124)
  Asteroid():setPosition(1372, 39077):setSize(128)
  Asteroid():setPosition(583, 36416):setSize(117)
  Asteroid():setPosition(-1191, 37007):setSize(111)
  Asteroid():setPosition(-1011, 2028):setSize(119)
  Asteroid():setPosition(-3579, -2912):setSize(128)
  Asteroid():setPosition(-2646, -3222):setSize(112)
  Asteroid():setPosition(-5261, 2852):setSize(115)
  Asteroid():setPosition(-1958, 5385):setSize(124)
  Asteroid():setPosition(-6414, 31784):setSize(127)
  Asteroid():setPosition(-6316, 36712):setSize(124)
  Asteroid():setPosition(-6118, 39175):setSize(115)
  Asteroid():setPosition(-4443, 38880):setSize(111)
  Asteroid():setPosition(-2373, 40062):setSize(117)
  Asteroid():setPosition(-1571, -6035):setSize(113)
  Asteroid():setPosition(-4248, -9307):setSize(113)
  Asteroid():setPosition(-1486, 34543):setSize(122)
  Asteroid():setPosition(-1200, -8117):setSize(123)

  -- == Northern Nebula
  Nebula():setPosition(-21211, -53117)
  Nebula():setPosition(-28590, -51225)
  Nebula():setPosition(-35024, -47251)
  Nebula():setPosition(-33888, -56333)
  Nebula():setPosition(-28590, -58982)
  Nebula():setPosition(-53377, -55387)
  Nebula():setPosition(-52431, -44981)
  Nebula():setPosition(-43728, -54631)
  Nebula():setPosition(-45241, -46116)
  Nebula():setPosition(-24995, -44791)
  Nebula():setPosition(-14399, -44602)
  Nebula():setPosition(-13832, -52360)
  Nebula():setPosition(-11183, -43278)
  Nebula():setPosition(-33113, -63623)
  Nebula():setPosition(-27798, -64147)
  Nebula():setPosition(-35818, -74415)
  Nebula():setPosition(-24693, -70199)
  Nebula():setPosition(-16178, -72422)
  Nebula():setPosition(-18751, -58982)
  Nebula():setPosition(-21287, -63623)
  Nebula():setPosition(-14759, -65516)
  Nebula():setPosition(-8231, -70341)
  Nebula():setPosition(-9480, -57280)
  Nebula():setPosition(-11935, -60613)
  Nebula():setPosition(9442, -63524)
  Nebula():setPosition(3009, -57847)
  Nebula():setPosition(8117, -55955)
  Nebula():setPosition(14172, -62956)
  Nebula():setPosition(17767, -67876)
  Nebula():setPosition(17200, -77715)
  Nebula():setPosition(14929, -44602)
  Nebula():setPosition(7550, -47062)
  Nebula():setPosition(16064, -51035)
  Nebula():setPosition(15686, -56144)
  Nebula():setPosition(7928, -72227)
  Nebula():setPosition(4144, -70525)
  Nebula():setPosition(-64, -73670)
  Nebula():setPosition(-1169, -68092)
  Nebula():setPosition(-5676, -63529)
  Nebula():setPosition(-28023, -42142)
  Nebula():setPosition(-4560, -44034)
  Nebula():setPosition(-19, -45548)
  Nebula():setPosition(-4560, -50468)
  Nebula():setPosition(1684, -50657)
  Nebula():setPosition(-54778, -74551)
  Nebula():setPosition(-48817, -74693)
  Nebula():setPosition(-46641, -62677)
  Nebula():setPosition(-42952, -67881)
  Nebula():setPosition(-55345, -64475)
  Nebula():setPosition(-50893, -69818)
  Nebula():setPosition(-15043, -87417)
  Nebula():setPosition(-9745, -81741)
  Nebula():setPosition(-23746, -83633)
  Nebula():setPosition(-19773, -79092)
  Nebula():setPosition(-11448, -76206)
  Nebula():setPosition(-27625, -90587)
  Nebula():setPosition(-29442, -85516)
  Nebula():setPosition(-34532, -81930)
  Nebula():setPosition(-35572, -90776)
  Nebula():setPosition(-20052, -94899)
  Nebula():setPosition(-13333, -94475)
  Nebula():setPosition(-29612, -94986)
  Nebula():setPosition(-28571, -76301)
  Nebula():setPosition(15497, -96069)
  Nebula():setPosition(7171, -95501)
  Nebula():setPosition(9442, -90771)
  Nebula():setPosition(9743, -88816)
  Nebula():setPosition(2630, -78661)
  Nebula():setPosition(-675, -82229)
  Nebula():setPosition(8874, -83770)
  Nebula():setPosition(16254, -88689)
  Nebula():setPosition(13226, -83013)
  Nebula():setPosition(1306, -88311)
  Nebula():setPosition(3784, -86457)
  Nebula():setPosition(-5014, -75355)
  Nebula():setPosition(-1086, -93571)
  Nebula():setPosition(-6147, -82981)
  Nebula():setPosition(-6675, -89873)
  Nebula():setPosition(-5525, -97105)
  Nebula():setPosition(-36819, -95056)
  Nebula():setPosition(-47114, -92100)
  Nebula():setPosition(-37938, -76632)
  Nebula():setPosition(-43425, -85904)
  Nebula():setPosition(-47966, -84201)
  Nebula():setPosition(-42839, -79845)
  Nebula():setPosition(13424, -38769)
  Nebula():setPosition(2630, -97771)
  Nebula():setPosition(-41816, -97493)
  Nebula():setPosition(-52318, -97871)
  Nebula():setPosition(-16923, -39021)
  Nebula():setPosition(-25108, -35621)
  Nebula():setPosition(-54322, -37888)
  Nebula():setPosition(-39841, -38014)
  Nebula():setPosition(-44878, -38265)
  Nebula():setPosition(-55724, -82356)
  Nebula():setPosition(-55913, -91627)
  Nebula():setPosition(-40126, -63572)
  Nebula():setPosition(-33018, -68732)
  Nebula():setPosition(-71826, -63072)
  Nebula():setPosition(-71574, -67102)
  Nebula():setPosition(-67670, -72013)
  Nebula():setPosition(-63389, -63954)
  Nebula():setPosition(-64270, -51235)
  Nebula():setPosition(-58478, -67228)
  Nebula():setPosition(-64522, -77553)
  Nebula():setPosition(-63893, -96190)
  Nebula():setPosition(-58856, -100849)
  Nebula():setPosition(-36190, -101353)
  Nebula():setPosition(-4205, -108026)
  Nebula():setPosition(-28886, -106264)
  Nebula():setPosition(-61248, -41539)
  Nebula():setPosition(-33797, -31088)
  Nebula():setPosition(22364, -54132)
  Nebula():setPosition(24127, -61561)

  -- A representative ship to get lost
  local northNebulaTLx, northNebulaTLy = sectorToXY("A2")
  Admin_station.lost_ship = CpuShip():setFaction("Human Navy"):setTemplate("Equipment Freighter 2"):setCallSign("VS1"):setPosition(northNebulaTLx + irandom(0, 80000), northNebulaTLy + irandom(0,60000)):orderRoaming():setCommsFunction(function()
    setCommsMessage(_("lost-comms", "We're pretty busy scanning for treasure... I mean, conducting research in this nebula. Can we call you back?"))
  end)

  -- Pick random location in nebula for ship to get lost to
  Admin_station.lost_location_x = northNebulaTLx + irandom(0, 60000)
  Admin_station.lost_location_y = northNebulaTLy + irandom(0, 60000)

  -- Some nebula mines
  for _ = 0, (7 * Difficulty) do -- 8, 22, or 36 mines
    Mine():setPosition(northNebulaTLx + irandom(0, 80000), northNebulaTLy + irandom(0,60000))
  end

  -- Some nebula treasure
  Admin_station.nebula_bonuses = {
    nuke = Artifact():setRadarSignatureInfo(0.8,0.25,0),
    repair = Artifact():setRadarSignatureInfo(0,0,0.25),
    rep = Artifact():setRadarSignatureInfo(0.25,0.25,0),
    surprise_attack = Artifact():setRadarSignatureInfo(0,0.8,0)
  }
  for i, bonus in pairs(Admin_station.nebula_bonuses) do
    bonus:setModel("artifact2"):setDescriptions(_("scienceDescription-artifact", "Just a hollow spherical apparition. Kinda looks like it's hiding something."),_("scienceDescription-artifact", "It seems to have changed shape.")):setScanningParameters(1,1):setRadarSignatureInfo(0.25,0,0):setPosition(northNebulaTLx + irandom(0, 80000), northNebulaTLy + irandom(0,60000))
  end

  Admin_station.nebula_bonuses.nuke.onFullScan = function (self)
    self:setModel("ammo_box"):allowPickup(true):onPickUp(function ()
      self.wasFound = true
      Player:setWeaponStorageMax("Nuke", Player:getWeaponStorageMax("Nuke") + 1)
      Player:setWeaponStorage("Nuke", Player:getWeaponStorage("Nuke") + 1)
      Player:addToShipLog(_("nebulaBonuses-shipLog", "A Nuke and additional nuke storage have been added to our arsenal"),"Green")
    end)
  end

  Admin_station.nebula_bonuses.repair.onFullScan = function (self)
    self:setModel("artifact1"):allowPickup(true):onPickUp(function ()
      self.wasFound = true
      Player:setRepairCrewCount(Player:getRepairCrewCount() + 1)
      Player:addToShipLog(_("nebulaBbonuses-shipLog", "A stranded repair crew has been rescued"),"Green")
    end)
  end

  Admin_station.nebula_bonuses.rep.onFullScan = function (self)
    self:setModel("artifact3"):allowPickup(true):onPickUp(function ()
      self.wasFound = true
      Player:addReputationPoints(5)
      Player:addToShipLog(_("nebulaBonuses-shipLog", "This scientific data is sure to raise our reputation with the eggheads."),"Green")
    end)
  end

  Admin_station.nebula_bonuses.surprise_attack.onFullScan = function (self)
    self:setModel("artifact8"):allowPickup(false)
    self:setCallSign("DD Alpha")
    self:sendCommsMessage(Player, _("nebulaBonuses-incCall", "DRONE SELF DEFENCE SYSTEM ACTIVATED"))
    Player:addToShipLog(_("nebulaBonuses-shipLog", "DRONE SELF DEFENCE SYSTEM ACTIVATED"), "Red")
    self:setCallSign("")
    local x, y = self:getPosition()
    local defenders = SpawnEnemies(x + irandom(-5000, 5000), y + irandom(-5000, 5000), random(.6,1), "Ghosts")
    for _, ship in ipairs(defenders) do
      table.insert(Defence_station.ghost_defenders, ship)
    end
    Player:addToShipLog(_("nebulaBonuses-shipLog", "We have activated a drone defence system!"),"Red")
  end

  -- == Drone area
  -- XXX patrol_mission.Drone_stations -> patrol_mission.lua


  -- XXX patrol_mission.Drone_artifacts -> patrol_mission.lua

-- == Other side of the wormhole

  -- XXX salvage_repair_mission.Parts_station -> salvage_repair_mission.lua

  -- XXX salvage_repair_mission.Kw_enemies -> salvage_repair_mission.lua
  -- XXX salvage_repair_mission.Investigator -> salvage_repair_mission.lua

  -- XXX salvage_repair_mission.Kw_stations -> salvage_repair_mission.lua
  -- XXX salvage_repair_mission.Kw_mainStation -> salvage_repair_mission.lua

  -- XXX salvage_repair_mission.Exuari_junk_stations -> salvage_repair_mission.lua
  SpaceStation():setTemplate("Medium Station"):setFaction("Human Navy"):setCallSign("OP722"):setPosition(328913, 490292)
  SpaceStation():setTemplate("Medium Station"):setFaction("Independent"):setCallSign("DS456"):setPosition(327511, 477797)

  Nebula():setPosition(362828, 522882)

  Asteroid():setPosition(387008, 497476):setSize(122)
  Asteroid():setPosition(387875, 493898):setSize(129)
  Asteroid():setPosition(378443, 492489):setSize(116)
  Asteroid():setPosition(366193, 493898):setSize(112)
  Asteroid():setPosition(369337, 492272):setSize(120)
  Asteroid():setPosition(361893, 551120):setSize(127)
  Asteroid():setPosition(365929, 552289):setSize(112)
  Asteroid():setPosition(362637, 553244):setSize(119)
  Asteroid():setPosition(376020, 552501):setSize(125)
  Asteroid():setPosition(372841, 552495):setSize(113)
  Asteroid():setPosition(386111, 549739):setSize(116)
  Asteroid():setPosition(385898, 551970):setSize(124)
  Asteroid():setPosition(377401, 554307):setSize(125)
  Asteroid():setPosition(383349, 551970):setSize(112)
  Asteroid():setPosition(374757, 494657):setSize(112)
  Asteroid():setPosition(371288, 494441):setSize(123)
  Asteroid():setPosition(370949, 491946):setSize(118)
  Asteroid():setPosition(384189, 495199):setSize(127)
  Asteroid():setPosition(384731, 493356):setSize(117)
  Asteroid():setPosition(381804, 492381):setSize(118)
  Asteroid():setPosition(379310, 495091):setSize(121)
  Asteroid():setPosition(387658, 496500):setSize(125)
  Asteroid():setPosition(386791, 495091):setSize(128)
  Asteroid():setPosition(386217, 556325):setSize(125)
  Asteroid():setPosition(389510, 554838):setSize(112)
  Asteroid():setPosition(383774, 554094):setSize(113)
  Asteroid():setPosition(388979, 549846):setSize(115)
  Asteroid():setPosition(389492, 552116):setSize(125)
  Asteroid():setPosition(356370, 552926):setSize(116)
  Asteroid():setPosition(359028, 553441):setSize(121)
  Asteroid():setPosition(380481, 552289):setSize(115)
  Asteroid():setPosition(388023, 553669):setSize(125)
  Asteroid():setPosition(385474, 554413):setSize(121)
  Asteroid():setPosition(361856, 489670):setSize(128)
  Asteroid():setPosition(369554, 489887):setSize(121)
  Asteroid():setPosition(372084, 490432):setSize(113)
  Asteroid():setPosition(356219, 489237):setSize(127)
  Asteroid():setPosition(358821, 489128):setSize(130)
  Asteroid():setPosition(357954, 493140):setSize(126)
  Asteroid():setPosition(358062, 490971):setSize(125)
  Asteroid():setPosition(366301, 490104):setSize(125)
  Asteroid():setPosition(363266, 487611):setSize(118)
  Asteroid():setPosition(376275, 490538):setSize(116)
  Asteroid():setPosition(377571, 487972):setSize(124)
  Asteroid():setPosition(373456, 487827):setSize(113)
  Asteroid():setPosition(370192, 487405):setSize(115)
  Asteroid():setPosition(380069, 490863):setSize(126)
  Asteroid():setPosition(380031, 488919):setSize(129)
  Asteroid():setPosition(375191, 492706):setSize(127)
  Asteroid():setPosition(360664, 491730):setSize(127)
  Asteroid():setPosition(382671, 490755):setSize(122)
  Asteroid():setPosition(385165, 491947):setSize(120)
  Asteroid():setPosition(382112, 494217):setSize(127)
  Asteroid():setPosition(390249, 493838):setSize(112)
  Asteroid():setPosition(364442, 557175):setSize(128)
  Asteroid():setPosition(366885, 555050):setSize(125)
  Asteroid():setPosition(366992, 557281):setSize(114)
  Asteroid():setPosition(355626, 556644):setSize(112)
  Asteroid():setPosition(358461, 550792):setSize(121)
  Asteroid():setPosition(343702, 550413):setSize(111)
  Asteroid():setPosition(348293, 555414):setSize(113)
  Asteroid():setPosition(341810, 547575):setSize(123)
  Asteroid():setPosition(342377, 541710):setSize(128)
  Asteroid():setPosition(364655, 554519):setSize(118)
  Asteroid():setPosition(361575, 556962):setSize(116)
  Asteroid():setPosition(359556, 557281):setSize(123)
  Asteroid():setPosition(351059, 553244):setSize(116)
  Asteroid():setPosition(351590, 556325):setSize(127)
  Asteroid():setPosition(352758, 554307):setSize(115)
  Asteroid():setPosition(352121, 550270):setSize(125)
  Asteroid():setPosition(348811, 551170):setSize(120)
  Asteroid():setPosition(371559, 555688):setSize(127)
  Asteroid():setPosition(374533, 555263):setSize(115)
  Asteroid():setPosition(374214, 557387):setSize(123)
  Asteroid():setPosition(383349, 556962):setSize(121)
  Asteroid():setPosition(377507, 557706):setSize(128)
  Asteroid():setPosition(382302, 550035):setSize(111)
  Asteroid():setPosition(369541, 557175):setSize(119)
  Asteroid():setPosition(369328, 554307):setSize(117)
  Asteroid():setPosition(381331, 554944):setSize(122)
  Asteroid():setPosition(379842, 557414):setSize(121)
  Asteroid():setPosition(336512, 534709):setSize(113)
  Asteroid():setPosition(332917, 526762):setSize(124)
  Asteroid():setPosition(333552, 512009):setSize(116)
  Asteroid():setPosition(333669, 503222):setSize(125)
  Asteroid():setPosition(335838, 500728):setSize(130)
  Asteroid():setPosition(339918, 501218):setSize(111)
  Asteroid():setPosition(336922, 509076):setSize(127)
  Asteroid():setPosition(336380, 506799):setSize(115)
  Asteroid():setPosition(339524, 507450):setSize(110)
  Asteroid():setPosition(334103, 506691):setSize(114)
  Asteroid():setPosition(334320, 509726):setSize(122)
  Asteroid():setPosition(338982, 511136):setSize(110)
  Asteroid():setPosition(336322, 520517):setSize(112)
  Asteroid():setPosition(340485, 510489):setSize(128)
  Asteroid():setPosition(338889, 512562):setSize(114)
  Asteroid():setPosition(335296, 503981):setSize(126)
  Asteroid():setPosition(338982, 504848):setSize(118)
  Asteroid():setPosition(342054, 501930):setSize(113)
  Asteroid():setPosition(338440, 502571):setSize(127)
  Asteroid():setPosition(332682, 501527):setSize(114)
  Asteroid():setPosition(352208, 492056):setSize(116)
  Asteroid():setPosition(353292, 494332):setSize(128)
  Asteroid():setPosition(350148, 495525):setSize(125)
  Asteroid():setPosition(350798, 488803):setSize(114)
  Asteroid():setPosition(352967, 487936):setSize(126)
  Asteroid():setPosition(350690, 491297):setSize(124)
  Asteroid():setPosition(350690, 493573):setSize(120)
  Asteroid():setPosition(352641, 495850):setSize(113)
  Asteroid():setPosition(343860, 495308):setSize(127)
  Asteroid():setPosition(348197, 492598):setSize(114)
  Asteroid():setPosition(345920, 493682):setSize(110)
  Asteroid():setPosition(348197, 490321):setSize(129)
  Asteroid():setPosition(344511, 491080):setSize(122)
  Asteroid():setPosition(340538, 494588):setSize(120)
  Asteroid():setPosition(340139, 498259):setSize(130)
  Asteroid():setPosition(342559, 499970):setSize(120)
  Asteroid():setPosition(342559, 497368):setSize(111)
  Asteroid():setPosition(345703, 498777):setSize(129)
  Asteroid():setPosition(394380, 501270):setSize(123)
  Asteroid():setPosition(396223, 502246):setSize(127)
  Asteroid():setPosition(397632, 500945):setSize(117)
  Asteroid():setPosition(395138, 499427):setSize(130)
  Asteroid():setPosition(394054, 497910):setSize(126)
  Asteroid():setPosition(391952, 497812):setSize(112)
  Asteroid():setPosition(390477, 497042):setSize(129)
  Asteroid():setPosition(392645, 498885):setSize(128)
  Asteroid():setPosition(390260, 494657):setSize(122)
  Asteroid():setPosition(392645, 495091):setSize(113)
  Asteroid():setPosition(392862, 496717):setSize(115)
  Asteroid():setPosition(395883, 547827):setSize(121)
  Asteroid():setPosition(394608, 547721):setSize(127)
  Asteroid():setPosition(394608, 549421):setSize(110)
  Asteroid():setPosition(402548, 553819):setSize(111)
  Asteroid():setPosition(397901, 542623):setSize(125)
  Asteroid():setPosition(397264, 544216):setSize(112)
  Asteroid():setPosition(396945, 546128):setSize(122)
  Asteroid():setPosition(397051, 539861):setSize(129)
  Asteroid():setPosition(398645, 540286):setSize(120)
  Asteroid():setPosition(408792, 533762):setSize(115)
  Asteroid():setPosition(395357, 544548):setSize(128)
  Asteroid():setPosition(392484, 547615):setSize(114)
  Asteroid():setPosition(392484, 550695):setSize(129)
  Asteroid():setPosition(392590, 552820):setSize(118)
  Asteroid():setPosition(403683, 523166):setSize(110)
  Asteroid():setPosition(402358, 515598):setSize(127)
  Asteroid():setPosition(399709, 538682):setSize(127)
  Asteroid():setPosition(397817, 514652):setSize(116)
  Asteroid():setPosition(398574, 503110):setSize(123)
  Asteroid():setPosition(401034, 503110):setSize(115)
  Asteroid():setPosition(398385, 521085):setSize(114)
  Asteroid():setPosition(398196, 537547):setSize(123)
  Asteroid():setPosition(399709, 529789):setSize(119)
  Asteroid():setPosition(360230, 486418):setSize(117)
  Asteroid():setPosition(358170, 485551):setSize(113)
  Asteroid():setPosition(354376, 486852):setSize(114)
  Asteroid():setPosition(363948, 491568):setSize(115)
  Asteroid():setPosition(354614, 491044):setSize(130)
  Asteroid():setPosition(357648, 482768):setSize(129)
  Asteroid():setPosition(351855, 485388):setSize(125)
  Asteroid():setPosition(344544, 488837):setSize(122)
  Asteroid():setPosition(348406, 497665):setSize(124)
  Asteroid():setPosition(342475, 492285):setSize(123)
  Asteroid():setPosition(345436, 550018):setSize(120)
  Asteroid():setPosition(347500, 548748):setSize(123)
  Asteroid():setPosition(344325, 553192):setSize(116)
  Asteroid():setPosition(337818, 547954):setSize(129)
  Asteroid():setPosition(344008, 544939):setSize(129)
  Asteroid():setPosition(341309, 550653):setSize(111)
  Asteroid():setPosition(337234, 497389):setSize(128)
  Asteroid():setPosition(334484, 539225):setSize(126)
  Asteroid():setPosition(330457, 538114):setSize(122)
  Asteroid():setPosition(331310, 528749):setSize(122)
  Asteroid():setPosition(331151, 534145):setSize(114)
  Asteroid():setPosition(338452, 538114):setSize(116)
  Asteroid():setPosition(333691, 537320):setSize(128)
  Asteroid():setPosition(336706, 541447):setSize(122)
  Asteroid():setPosition(336548, 544145):setSize(113)
  Asteroid():setPosition(339246, 543986):setSize(116)
  Asteroid():setPosition(332421, 521130):setSize(114)
  Asteroid():setPosition(330457, 505002):setSize(119)
  Asteroid():setPosition(333849, 531606):setSize(114)
  Asteroid():setPosition(335913, 526527):setSize(114)
  Asteroid():setPosition(360772, 483708):setSize(121)
  Asteroid():setPosition(365868, 485984):setSize(123)
  Asteroid():setPosition(366735, 482082):setSize(122)
  Asteroid():setPosition(407021, 533511):setSize(119)
  Asteroid():setPosition(404641, 525416):setSize(114)
  Asteroid():setPosition(401149, 525416):setSize(127)
  Asteroid():setPosition(404323, 528908):setSize(126)
  Asteroid():setPosition(402101, 532717):setSize(115)
  Asteroid():setPosition(401942, 519225):setSize(116)
  Asteroid():setPosition(399085, 516844):setSize(113)
  Asteroid():setPosition(390802, 501162):setSize(125)
  Asteroid():setPosition(391195, 502731):setSize(130)
  Asteroid():setPosition(391384, 544358):setSize(127)
  Asteroid():setPosition(331627, 509702):setSize(120)
  Asteroid():setPosition(341923, 507045):setSize(119)
  Asteroid():setPosition(335754, 529384):setSize(130)
  Asteroid():setPosition(339405, 541606):setSize(117)
  Asteroid():setPosition(332103, 542240):setSize(114)
  Asteroid():setPosition(334643, 523035):setSize(115)
  Asteroid():setPosition(330040, 525098):setSize(125)
  Asteroid():setPosition(335913, 513511):setSize(129)
  Asteroid():setPosition(334960, 517003):setSize(122)
  Asteroid():setPosition(329889, 519382):setSize(126)

  -- Northern colony
  Colony_area_station = SpaceStation():setTemplate("Medium Station"):setFaction("Human Navy"):setCallSign("DS806"):setPosition(40015, -60153)
  Planet():setPosition(41835, -78305):setPlanetRadius(5000):setPlanetCloudRadius(5200.00):setPlanetAtmosphereColor(0.8,0.20,0.40):setPlanetSurfaceTexture("planets/gas-2.png")
  -- XXX lost_mission.Colony_stations -> lost_mission.lua

  Asteroid():setPosition(-86049, 1110):setSize(119)
  Asteroid():setPosition(-85670, 1677):setSize(120)
  Asteroid():setPosition(-83967, 3380):setSize(117)
  Asteroid():setPosition(-77534, 12273):setSize(123)
  Asteroid():setPosition(-77345, 13030):setSize(119)
  Asteroid():setPosition(-71290, 20599):setSize(124)
  Asteroid():setPosition(-68452, 23437):setSize(115)
  Asteroid():setPosition(-68641, 31573):setSize(119)
  Asteroid():setPosition(-72425, 46521):setSize(129)
  Asteroid():setPosition(-81886, 59766):setSize(116)
  Asteroid():setPosition(-89833, 57874):setSize(121)
  Asteroid():setPosition(-79048, 45575):setSize(123)
  Asteroid():setPosition(-75642, 33655):setSize(122)
  Asteroid():setPosition(-77345, 25897):setSize(119)
  Asteroid():setPosition(-82454, 17382):setSize(111)
  Asteroid():setPosition(-84346, 4137):setSize(130)
  Asteroid():setPosition(-75831, -2485):setSize(119)
  Asteroid():setPosition(-62964, 12652):setSize(127)
  Asteroid():setPosition(-59559, 39331):setSize(127)
  Asteroid():setPosition(-67506, 8111):setSize(126)
  Asteroid():setPosition(-70155, 61469):setSize(124)

  -- == END OF MAIN MAP ==

--==================================================
--==
--==
--==
--==
--==
--==
--==      SETUP
--==
--==
--==
--==
--==
--==
--==
--==================================================

  InitPlayer()
  InitGM()

  Admin_station:setCommsFunction(CommsAdminStation)
  Defence_station:setCommsFunction(CommsDefenceStation)
  Defence_station.harass_enemies = {}
  Defence_station.ghost_defenders = {}
  Wormhole_station:setCommsFunction(CommsWormholeStation)
  Wormhole_station.insults = {}

  -- XXX init plots
  lost_mission.init(Admin_station, CHEEVOS, CommsBeingAttacked, Wormhole_station)
  salvage_repair_mission.init(Admin_station, CHEEVOS, Defence_station, SpawnEnemies, Wormhole_station)
  patrol_mission.init(Admin_station, CHEEVOS, CommsBeingAttacked, Defence_station, PP1, SpawnEnemies, Wormhole_station, Difficulty)

  salvage_repair_mission.Investigator:setCommsFunction(salvage_repair_mission.CommsInvestigator)

  salvage_repair_mission.InitKraylor()
  salvage_repair_mission.InitPartsStation()
  patrol_mission.InitDroneStations()
  InitCheevos()
  InitTraffic()

  Defence_station:sendCommsMessage(Player, _("defenceStn-incCall", [[Greetings, Captain.

You've been assigned a tour of duty in the Zeta Belt. It's neutral territory with a bit of everything... nebulae, asteroids, baby planets, and dangerous old scrap.

We don't see many Kraylor around here, but we have a non-aggression treaty with them, so should you encounter any, think twice before engaging. The main security risk is from those damned Ghost and Exuari drones and that keep flying around.

Your primary orders are to support all the research facilities in the area, both Human and Independent. Their safety must be guaranteed, including helping them with dangerous operations. If you can't find anything to do, check in here and we can set you up with a patrol route.

Your ship, the Propitious 1, is well equipped but not exactly a war vessel, so conduct yourself carefully and try not to breach the peace tumultuously.
]]))

end

function InitPlayer()
  allowNewPlayerShips(false)
  Player = PlayerSpaceship():setFaction("Human Navy"):setTemplate("Phobos M3P"):setCallSign("Propitious 1"):setPosition(8785, 800)
  Player:setJumpDrive(true)
  Player:setRotation(0):commandTargetRotation(0)
  Player:setWeaponStorageMax("Nuke", 0)
  Player:setWeaponStorage("Homing", 4)
  Player:setWeaponStorage("Nuke", 0)
  Player:setWeaponStorage("Mine", 0)
  Player:setWeaponStorage("EMP", 0)
  Player:setWeaponStorage("HVLI", 6)
  Player:setLongRangeRadarRange(20000)
  PP1 = Player
end

function InitGM ()
	clearGMFunctions()
	addGMFunction(_("buttonGM","+Start Mission"),gmStartMission)
	addGMFunction(_("buttonGM","+Finish Mission"),gmFinishMission)
	addGMFunction(_("buttonGM","+Spawn Stuff"),gmSpawnStuff)
end
function gmSpawnStuff()
	clearGMFunctions()
	addGMFunction(_("buttonGM","-From Spawn Stuff"),InitGM)
	addGMFunction(_("buttonGM","Convoy Enemies"), patrol_mission.SpawnConvoyEnemies)
	addGMFunction(_("buttonGM","Harrasment"), SpawnHarrasment)
end
function gmFinishMission()
	clearGMFunctions()
	addGMFunction(_("buttonGM","-From Finish Mission"),InitGM)
	addGMFunction(_("buttonGM","Lost"),lost_mission.FinishMissionLost)
	addGMFunction(_("buttonGM","Spare Parts"),salvage_repair_mission.FinishMissionSpareParts)
	addGMFunction(_("buttonGM","Drone Nest"),patrol_mission.FinishMissionDroneNest)
	addGMFunction(_("buttonGM","Repair"),salvage_repair_mission.FinishMissionRepair)
end
function gmStartMission()
	clearGMFunctions()
	addGMFunction(_("buttonGM","-From Start Mission"),InitGM)
	addGMFunction(_("buttonGM","Lost"), lost_mission.StartMissionLost)
	addGMFunction(_("buttonGM","Patrol"),function ()
		Defence_station.mission_state = "patrol attack"
		patrol_mission.SpawnPatrolEnemies()
	end)
	addGMFunction(_("buttonGM","Spare Parts"),salvage_repair_mission.StartMissionSpareParts)
	addGMFunction(_("buttonGM","Drone Nest"), patrol_mission.StartMissionDroneNest)
	addGMFunction(_("buttonGM","Repair"), function ()
		Wormhole_station.tier2_attack_countdown = 0
		Wormhole_station.tier2_mission_state = "wait for attack"
	end)
end
-- XXX patrol_mission.InitDroneStations -> patrol_mission.lua


-- XXX salvage_repair_mission.InitPartsStation -> salvage_repair_mission.lua

-- XXX salvage_repair_mission.InitKraylor -> salvage_repair_mission.lua

function InitTraffic()
  Traffic = {}
  Traffic.docked_ships = {}
  Traffic.leaving_ships = {}
  Traffic.new_ships = {}
  Traffic.factions = {'Independent', 'Independent', 'Independent', 'Independent', 'Arlenians', 'Arlenians', 'TSN'}
  Traffic.types = {'Atlantis', 'Transport1x2', 'Maverick', 'Kiriya', 'Hathcock', 'Flavia P.Falcon'}
  Traffic.srcdest = {'J2','D0','B10','J8','zz1','zz6','zz8','D10','H11','K5'}
  Traffic.stations = {Admin_station, Defence_station, Wormhole_station, Colony_area_station}
  for _, stn in ipairs(patrol_mission.Patrol_stations) do
    table.insert(Traffic.stations,stn)
  end
  for _, stn in ipairs(Resupply_stations) do
    table.insert(Traffic.stations,stn)
  end
  for _, stn in ipairs(Lookout_stations) do
    table.insert(Traffic.stations,stn)
  end
  Traffic.timer = getScenarioTime()
end

--translate variations into a numeric Difficulty value
function SetSettings()
  if string.find(getScenarioSetting("Difficulty"),"Easy") then
    Difficulty = 1
  elseif string.find(getScenarioSetting("Difficulty"),"Medium") then
    Difficulty = 3
  elseif string.find(getScenarioSetting("Difficulty"),"Hard") then
    Difficulty = 5
  else
    Difficulty = 1    --default (Easy)
  end
end

function InitCheevos()
  -- CHEEVOS
-- * Collect all the good nebula treasures ("Experienced treasure hunter")
-- * Destroy all Exuari space stations (can leave spare parts station) ("Clean up the useless space junk")
-- * Leave the spare parts station intact ("Historical relic preservation")
-- * Never trigger a proximity spawn ("Social distancing")
-- * Defeat all the drone stations without using enemy ship ("Our ship is all we need")
-- * Defeat all the drone stations without using the beacons ("No DMCA violations")
-- * Leave no Convites on the map ("I ain't afraid of no ghosts")
-- * Find Dr. Hendrix without asking any stations ("Keep an eye on that doctor")
-- * Use all the insulting options at the wormhole ("Ban wormhole research")
-- * Finish with a combined reputation > 300 ("Heros for the ages")
-- * Grand slam - all cheevos in one run

  CHEEVOS = {}
  CHEEVOS["treasure"] = false -- DONE
  CHEEVOS["junk"] = false -- DONE
  CHEEVOS["relic"] = true -- DONE
  CHEEVOS["distancing"] = true -- DONE
  CHEEVOS["ourship"] = true -- DONE
  CHEEVOS["DMCA"] = true -- DONE
  CHEEVOS["noghosts"] = false -- DONE
  CHEEVOS["eyeondr"] = true -- DONE
  CHEEVOS["nowormhole"] = false -- DONE
  CHEEVOS["heros"] = false -- DONE
  CHEEVOS["grandslam"] = false -- DONE
end

--==================================================
--==
--==
--==
--==
--==
--==
--==      ENEMY SPAWNING
--==
--==
--==
--==
--==
--==
--==
--==================================================

function SpawnEnemies(xOrigin, yOrigin, danger, enemyFaction)
    return spawn_enemies_faction(xOrigin, yOrigin, danger, enemyFaction)
    --[[
  -- square grid deployment
  local fleetPosDelta1x = {0,1,0,-1, 0,1,-1, 1,-1,2,0,-2, 0,2,-2, 2,-2,2, 2,-2,-2,1,-1, 1,-1}
  local fleetPosDelta1y = {0,0,1, 0,-1,1,-1,-1, 1,0,2, 0,-2,2,-2,-2, 2,1,-1, 1,-1,2, 2,-2,-2}
  -- rough hexagonal deployment
  local fleetPosDelta2x = {0,2,-2,1,-1, 1, 1,4,-4,0, 0,2,-2,-2, 2,3,-3, 3,-3,6,-6,1,-1, 1,-1,3,-3, 3,-3,4,-4, 4,-4,5,-5, 5,-5}
  local fleetPosDelta2y = {0,0, 0,1, 1,-1,-1,0, 0,2,-2,2,-2, 2,-2,1,-1,-1, 1,0, 0,3, 3,-3,-3,3,-3,-3, 3,2,-2,-2, 2,1,-1,-1, 1}
  --Ship Template Name List
  local stnl = {"MT52 Hornet","MU52 Hornet","Adder MK5","Adder MK4","WX-Lindworm","Adder MK6","Phobos T3","Phobos M3","Piranha F8","Piranha F12","Ranus U","Nirvana R5A","Stalker Q7","Stalker R7","Atlantis X23","Starhammer II","Fighter","Cruiser","Missile Cruiser","Strikeship","Adv. Striker","Dreadnought","Battlestation","Blockade Runner","Ktlitan Fighter","Ktlitan Breaker","Ktlitan Worker","Ktlitan Drone","Ktlitan Feeder","Ktlitan Scout","Ktlitan Destroyer","Storm"}
  --Ship Template Score List
  local stsl = {5            ,5            ,7          ,6          ,7            ,8          ,15         ,16         ,15          ,15           ,25       ,20           ,25          ,25          ,50            ,70             ,6        ,18       ,14               ,30          ,27            ,80           ,100            ,65               ,6                ,45               ,40              ,4              ,48              ,8              ,50                 ,22}

  if enemyFaction == nil then
    enemyFaction = "Kraylor"
  end
  if danger == nil then
    danger = 1
  end
  local enemyStrength = math.max(danger * Difficulty * 10, 5)	--assume Player ship at strength 10 (balance variable)
  local enemyPosition = 0
  local sp = irandom(500,800)			--random spacing of spawned group
  local deployConfig = irandom(1,100)	--randomly choose between squarish formation and hexagonish formation
  local enemyList = {}
  -- Reminder: stsl and stnl are ship template score and name list
  while enemyStrength > 0 do
    local shipTemplateType = irandom(1,#stsl)
    while stsl[shipTemplateType] > enemyStrength * 1.1 + 5 do
      shipTemplateType = irandom(1,#stsl)
    end
    local ship = CpuShip():setFaction(enemyFaction):orderRoaming():setTemplate(stnl[shipTemplateType])
    enemyPosition = enemyPosition + 1
    if deployConfig < 50 then
      if enemyPosition > #fleetPosDelta1x then enemyPosition = 1 end
      ship:setPosition(xOrigin+fleetPosDelta1x[enemyPosition]*sp,yOrigin+fleetPosDelta1y[enemyPosition]*sp)
    else
      if enemyPosition > #fleetPosDelta2x then enemyPosition = 1 end
      ship:setPosition(xOrigin+fleetPosDelta2x[enemyPosition]*sp,yOrigin+fleetPosDelta2y[enemyPosition]*sp)
    end
    table.insert(enemyList, ship)
    enemyStrength = enemyStrength - stsl[shipTemplateType]
  end
  return enemyList
  --]]
end

-- XXX patrol_mission.SpawnPatrolEnemies -> patrol_mission.lua

-- XXX patrol_mission.SpawnConvoyEnemies -> patrol_mission.lua

-- XXX patrol_mission.ConvoyGoAggro -> patrol_mission.lua

-- XXX patrol_mission.DroneStationGoAggro -> patrol_mission.lua

-- XXX salvage_repair_mission.SpawnKWEnemies -> salvage_repair_mission.lua

-- XXX salvage_repair_mission.KWGoAggro -> salvage_repair_mission.lua

-- XXX patrol_mission.SpawnMockDroneShip -> patrol_mission.lua

-- XXX salvage_repair_mission.SpawnRepairEnemies -> salvage_repair_mission.lua

function SpawnHarrasment()
  local x, y = Player:getPosition()
  local spx, spy = vectorFromAngle(irandom(0, 360), 40000)

  Defence_station.harass_enemies = SpawnEnemies(x + spx, y + spy, random(0.25,0.5), "Exuari")

  for _, enemy in ipairs(Defence_station.harass_enemies) do
    enemy:setWarpDrive(false)
    enemy:setJumpDrive(true)
    enemy:orderAttack(Player)
  end
end

--==================================================
--==
--==
--==
--==
--==
--==
--==      COMMS
--==
--==
--==
--==
--==
--==
--==
--==================================================

function CommsWormholeStation(comms_source, comms_target)

  if Wormhole_station.tier2_mission_state ~= nil and
  Wormhole_station.tier2_mission_state ~= "wait for attack" then
    CommsWormholeStationTier2(comms_source,comms_target)
    return
  end

  if not comms_source:isDocked(comms_target) then
    if Wormhole_station.mission_state == nil then
      setCommsMessage(_("wormhole-comms", [[
Hello Captain. Have you noticed our cool wormhole?

We're studying the energy radiating from the wormhole, and the similarities to black holes are astonishing. Please drop by if you'd like to help out.]]))
    elseif Wormhole_station.mission_state == "get parts" or Wormhole_station.mission_state == "return parts" then
      setCommsMessage(_("wormhole-comms", "Please bring us the spare parts!"))
    elseif Wormhole_station.mission_state == "done" then
      setCommsMessage(_("wormhole-comms", "Thanks so much for your help!"))
    end

  else
    -- Docked comms
    if Wormhole_station.mission_state == nil then
      Wormhole_station.insults["tips"] = false
      setCommsMessage(_("wormhole-comms", [[Thanks for dropping by, Captain.

Our research is going well, but we could use some spare stabilizers for our Hawking Scanner. Would you mind salvaging some for us from the other side of the wormhole?]]))
      addCommsReply(_("wormhole-comms", "Okay, we can help with that."), salvage_repair_mission.StartMissionSpareParts)
      addCommsReply(_("wormhole-comms", "Do you pay tips?"), function()
        setCommsMessage(_("wormhole-comms", [[Maybe later, then. Goodbye.]]))
        Player:takeReputationPoints(2)
        Wormhole_station.insults["tips"] = true
      end)
    elseif Wormhole_station.mission_state == "get parts" or Wormhole_station.mission_state == "return parts" then

      if Player.hasSpareParts ~= nil then
        Wormhole_station.insults["errands"] = false
        setCommsMessage(_("wormhole-comms", [[Thanks for your help, Captain!

These spare parts will really help with the program budget.]]))
        addCommsReply(_("wormhole-comms", "What do we get for being your errand boy?"), function()
          setCommsMessage(_("wormhole-comms", [[You get half of what would have with a smarter attitude! So rude.]]))
          Player:addReputationPoints(5)
          Wormhole_station.insults["errands"] = true
          salvage_repair_mission.FinishMissionSpareParts()
        end)
        addCommsReply(_("wormhole-comms", "We're so glad we could help"), function()
          setCommsMessage(_("wormhole-comms", [[We are too. Thanks a bunch.]]))
          Player:addReputationPoints(10)
          salvage_repair_mission.FinishMissionSpareParts()
        end)
      else
        setCommsMessage(_("wormhole-comms", [[We still need those spare parts from X472 on the other side of the wormhole!]]))
      end
    elseif Wormhole_station.mission_state == "done" then
        setCommsMessage(_("wormhole-comms", [[Thanks that was awesome]]))
    end
  end
end

function CommsWormholeStationTier2(comms_source, comms_target)

  -- DOCKER OR UNDOCKED
  if Wormhole_station.tier2_mission_state == "attack" then
    setCommsMessage(_("wormhole-comms", [[We're under attack. Help us!]]))
    return
  end

  if not comms_source:isDocked(comms_target) then -- UNDOCKED
    if Wormhole_station.tier2_mission_state == "damaged" then
      setCommsMessage(_("wormhole-comms", [[Come pick up our Hawking Scanner for repairs.]]))
    elseif Wormhole_station.tier2_mission_state == "rma" or Wormhole_station.tier2_mission_state == "fixed" then
      setCommsMessage(_("wormhole-comms", [[Please find someone to repair our Hawking Scanner.]]))
    end
  else -- DOCKED
    if Wormhole_station.tier2_mission_state == "damaged" or Wormhole_station.tier2_mission_state == "rma" then
      Wormhole_station.tier2_mission_state = "rma"
      Wormhole_station.insults["shoveit"] = false
      setCommsMessage(_("wormhole-comms", [[Thanks again, Captain.

We need you to find someone to repair this Hawking Scanner. Please bring it back once it's working again.]]))
      addCommsReply(_("wormhole-comms", "Any idea where we should take it?"), function()
        setCommsMessage(_("wormhole-comms", [[One of the nebula researchers should be able to point you in the right direction.

If you're not sure where to find them, ask for directions at the Admin Station]]))
      end)
      addCommsReply(_("wormhole-comms", "Have you considered shoving it where the sun don't shine?"), function()
        setCommsMessage(_("wormhole-comms", [[What is it with you, anyways?]]))
        Player:takeReputationPoints(2)
        Wormhole_station.insults["shoveit"] = true
      end)
    elseif Wormhole_station.tier2_mission_state == "fixed" then
      Wormhole_station.insults["kissmyfeet"] = false
      setCommsMessage(_("wormhole-comms", [[You got it fixed?

That's amazing, Captain. Thank you so much! You and your crew are true heros of our system; may your names live on through history.

Glory to you and your kin.]]))
      addCommsReply(_("wormhole-comms", "You're very welcome."), function()
        setCommsMessage(_("wormhole-comms", "Goodbye captain. May peace be with you."))
        salvage_repair_mission.FinishMissionRepair()
      end)
      addCommsReply(_("wormhole-comms", "Kiss my feet!"), function()
        Wormhole_station.insults["kissmyfeet"] = true
        CheckCheevoNoWormhole()
        if CHEEVOS["nowormhole"] then
         setCommsMessage(_("wormhole-comms", [[I was about to call this in to Admin and have them declare you victorious, but I've had enough of you.

YOU MAY BE A HERO, BUT YOU'RE ALSO A JERK!]]))
        else
          setCommsMessage(_("wormhole-comms", [[A real peach, you are.]]))
        end
        salvage_repair_mission.FinishMissionRepair()
      end)
    end
  end
end

-- XXX lost_mission.CommsColonyStation -> lost_mission.lua

-- XXX patrol_mission.CommsPatrolStation -> patrol_mission.lua

function CommsDefenceStation(comms_source, comms_target)

  -- DOCKED or UNDOCKED
  if Defence_station.mission_state == "patrol attack" then
    setCommsMessage(_("defenceStn-comms", "Defend the SW Checkpoint now!"))
    return
  elseif Defence_station.mission_state == "patrolling" then
    setCommsMessage(string.format(_("defenceStn-comms","You are on 'patrol'.\nSee that you make it to %s next."), Defence_station.next_station))
    return
  elseif Defence_station.mission_state == "drone convoy" and Defence_station.tier2_mission_state == nil then
    setCommsMessage(_("defenceStn-comms", [[Your orders are to follow the convoy to see where it goes]]))
    return
  elseif Defence_station.tier2_mission_state == "joinconvoy" then
    setCommsMessage(_("defenceStn-comms", [[Your orders are to join a convoy and infiltrate the drone nests.]]))
    return
  elseif Defence_station.tier2_mission_state == "arrived" then
    setCommsMessage(_("defenceStn-comms", [[Your orders are to scan those beacons and find the defence grid controller]]))
    return
  elseif Defence_station.tier2_mission_state == "done" and Defence_station.tier2_final_comms == nil then
    Defence_station.tier2_final_comms = "done"
    local extra_string = ""
    if patrol_mission.DroneShip ~= nil then
      extra_string = _("defenceStn-comms", "We are keeping the 007, and you can continue to fly it, or switch back to the Propitious 1 at any time. We'll keep it docked here at the station for you.")
    end
    setCommsMessage(string.format(_("defenceStn-comms","Great work, Captain!\nDestroying the central control eliminated all the other drone stations and stopped the convoys in their tracks! Of course, you are authorized to mop up any resistance that might remain, but we're calling this a job well done.\n%s"),extra_string))
    return
  end


  -- UNDOCKED
  if not comms_source:isDocked(comms_target) then
    setCommsMessage(_("defenceStn-comms", [[Good day, soldier.

We shouldn't talk over this channel, please dock to the station when you have a chance.]]))
  else
    -- DOCKED
    if Defence_station.mission_state == nil then
      setCommsMessage(_("defenceStn-comms", [[Welcome aboard.

We need you to patrol the area. It's not exciting work, but it's got to be done. No rush, just make sure you visit each checkpoint in order, and we'll let you know if anything more pressing comes up.]]))
      addCommsReply(_("defenceStn-comms", "Okay. We're ready to start the patrol"), patrol_mission.StartMissionPatrol)
    end

    if Defence_station.tier2_mission_state == "pre-start" then
      setCommsMessage(_("defenceStn-comms", [[Welcome back, Captain.

We've tracked that convoy to a huge nest of drone stations in the west. The stations all form part of one proximity defence grid, and we have identified some beacons that appear to be related to its operation. We're hoping that if we can get a closer look at them, we might be able to figure out how to knock out the central control.

There is a drone ship docked here which you can use to infiltrate the nests. If you arrive with a convoy, you should automatically be granted access and we think the proximity defences will remain disabled while you stay in the area. Of course, if you start firing, then all bets are probably off.

Hop in that drone ship, find the beacons, and get close enough to scan them - EASY!]]))
      addCommsReply(_("defenceStn-comms", "We're ready to infiltrate the drone nest"), patrol_mission.StartMissionDroneNest)
      addCommsReply(_("defenceStn-comms", "(Object) Isn't that a treaty violation!?"), function ()
        setCommsMessage(_("defenceStn-comms", [[(Objecting)
Sir, decoding the communications of alien defence systems is a violation of the Deepspace Militarized Citizenry Accord (DMCA).
[...]
Captain, are you angling for a good samaritan's award or something? Get out of here with that legal mumbo-jumbo.

However you want to do it, you need to find that central control. Get on it!]]))
        addCommsReply(_("defenceStn-comms", "Okay, we'll figure it out."), patrol_mission.StartMissionDroneNest)
      end)
    end

    if Defence_station.tier2_mission_state == "done" then
      setCommsMessage(_("defenceStn-comms", [[Great job on that drone nest, Captain.

Remember, your primary orders are to support the research facilities in the area. See to it that they all get the assistance they need.]]))

      if Player:getCallSign() == "DD007" then
        addCommsReply(_("defenceStn-comms",  "We'd rather crew the Propitious 1"), function ()
          Player:transferPlayersToShip(PP1)
          Player = PP1
          setCommsMessage(_("defenceStn-comms", [[Very well. Good Hunting.]]))
        end)
      else
        if patrol_mission.DroneShip ~= nil then
          addCommsReply(_("defenceStn-comms", "We'd rather crew the DD007"), function ()
            Player:transferPlayersToShip(patrol_mission.DroneShip)
            CHEEVOS["ourship"] = false
            Player = patrol_mission.DroneShip
            setCommsMessage(_("defenceStn-comms", [[Very well. Good Hunting.]]))
          end)
        end
      end
    end
  end
end

function CommsAdminStation(comms_source, comms_target)

  if Wormhole_station.tier2_mission_state == "done" then
    CheckCheevos()
    -- Does the _() translation work here?
    setCommsMessage(string.format(_("adminStnEndTips-comms","VICTORY!\nYour tour of duty is complete and your accomplishments will be the talk of legends.\nCHEEVOS!\n* Experienced treasure hunter - %s\n* Clean up the useless space junk - %s\n* Historical relic preservation - %s\n* Social distancing - %s\n* Our ship is all we need - %s\n* No DMCA violations - %s\n* I ain't afraid of no ghosts - %s\n* Keep an eye on that doctor - %s\n* Ban wormhole research - %s\n* Heros for the ages - %s\n* Grand slam - %s"),CheevoString("treasure"),CheevoString("junk"),CheevoString("relic"),CheevoString("distancing"),CheevoString("ourship"),CheevoString("DMCA"),CheevoString("noghosts"),CheevoString("eyeondr"),CheevoString("nowormhole"),CheevoString("heros"),CheevoString("grandslam")))
    addCommsReply(_("adminStnEndTips-comms", "Hints for each CHEEVO"), function ()
      setCommsMessage(_("adminStnEndTips-comms", "Select the achievement for a hint"))
      addCommsReply(_("adminStnEndTips-comms", "Experienced treasure hunter"), function ()
        setCommsMessage(_("adminStnEndTips-comms", "The locals are known to hunt treasure in the nebula"))
        addCommsReply(_("<- Back"), CommsAdminStation)
      end)
      addCommsReply(_("adminStnEndTips-comms", "Clean up the space junk"), function ()
        setCommsMessage(_("adminStnEndTips-comms", "So many long abandoned stations"))
        addCommsReply(_("<- Back"), CommsAdminStation)
      end)
      addCommsReply(_("adminStnEndTips-comms", "Historical relic preservation"), function ()
        setCommsMessage(_("adminStnEndTips-comms", "Destroying that old station might spook the Kraylor"))
        addCommsReply(_("<- Back"), CommsAdminStation)
      end)
      addCommsReply(_("adminStnEndTips-comms", "Social distancing"), function ()
        setCommsMessage(_("adminStnEndTips-comms", "Don't get too proximate"))
        addCommsReply(_("<- Back"), CommsAdminStation)
      end)
      addCommsReply(_("adminStnEndTips-comms", "Our ship is all we need"), function ()
        setCommsMessage(_("adminStnEndTips-comms", "We'll stick with the ship we know, thanks"))
        addCommsReply(_("<- Back"), CommsAdminStation)
      end)
      addCommsReply(_("adminStnEndTips-comms", "No DMCA violations"), function ()
        setCommsMessage(_("adminStnEndTips-comms", "Hacking alien defense systems is illegal"))
        addCommsReply(_("<- Back"), CommsAdminStation)
      end)
      addCommsReply(_("adminStnEndTips-comms", "I ain't afraid of no ghosts"), function ()
        setCommsMessage(_("adminStnEndTips-comms", "No one is afraid if there are NO GHOSTS"))
        addCommsReply(_("<- Back"), CommsAdminStation)
      end)
      addCommsReply(_("adminStnEndTips-comms", "Keep an eye on that doctor"), function ()
        setCommsMessage(_("adminStnEndTips-comms", "Do we really need to ask for directions?"))
        addCommsReply(_("<- Back"), CommsAdminStation)
      end)
      addCommsReply(_("adminStnEndTips-comms", "Ban wormhole research"), function ()
        setCommsMessage(_("adminStnEndTips-comms", "I just can't stand wormholes, or their researchers!"))
        addCommsReply(_("<- Back"), CommsAdminStation)
      end)
      addCommsReply(_("adminStnEndTips-comms", "Heros for the ages"), function ()
        setCommsMessage(_("adminStnEndTips-comms", "Their reputation is unmatched"))
        addCommsReply(_("<- Back"), CommsAdminStation)
      end)
      addCommsReply(_("adminStnEndTips-comms", "Grand Slam"), function ()
        setCommsMessage(_("adminStnEndTips-comms", "You can do it, but can you do it ALL?"))
        addCommsReply(_("<- Back"), CommsAdminStation)
      end)
    end)
    addCommsReply(_("adminStnEnd-comms", "Click here to lance the champagne!"), function ()
      setCommsMessage(_("adminStnEnd-comms", "Booyah!!!"))
      victory("Human Navy")
    end)
    return
  end

  if not comms_source:isDocked(comms_target) then
    if Admin_station.mission_state == nil then
      setCommsMessage(_("adminStn-comms", [[We are the station that co-ordinates research activities in the nearby nebulae.

If you're not busy, please drop by to learn more about our projects.]]))
    elseif Admin_station.mission_state == "lost" then
        setCommsMessage(_("adminStn-comms", "Please bring our researchers home!"))
    elseif Admin_station.mission_state == "found" or Admin_station.mission_state == "done" then
        setCommsMessage(_("adminStn-comms", "Thanks so much for finding our researchers! Dock with us if you'd like to chat."))
    end
  else
    -- Docked comms
    if Admin_station.mission_state == nil then
      setCommsMessage(_("adminStn-comms", [[We are so glad to have you aboard. What can we help you with?]]))
      addCommsReply(_("adminStn-comms", "How long have you been operating in this system?"), lost_mission.StartMissionLost)
      addCommsReply(_("adminStn-comms", "Where is the colony where your researchers live?"), lost_mission.StartMissionLost)
      addCommsReply(_("adminStn-comms", "Tell us about the nearby nebulae."), lost_mission.StartMissionLost)
      addCommsReply(_("adminStn-comms", "Are there any Kraylor in the area?"), lost_mission.StartMissionLost)
      addCommsReply(_("adminStn-comms", "Are there any Exuari in the area?"), lost_mission.StartMissionLost)
    elseif Admin_station.mission_state == "lost" then
        setCommsMessage(_("adminStn-comms", "Please bring our researchers home!"))
    elseif Admin_station.mission_state == "found" or Admin_station.mission_state == "done" then
        setCommsMessage(_("adminStn-comms", [[Always a pleasure to have you as our honoured guests.]]))
        if Wormhole_station.tier2_mission_state == "rma" then
          addCommsReply(_("adminStn-comms", "Any idea where we can get a Hawking Scanner fixed?"), function ()
            setCommsMessage(_("adminStn-comms", [[Dr. Hendrix, who you rescued earlier, is the leading expert on those scanners.]]))
          end)
        end
        addCommsReply(_("adminStn-comms", "How long have you been operating in this system?"), function ()
          setCommsMessage(_("adminStn-comms", [[We have been operating here for about 50 years]]))
          addCommsReply(_("<- Back"), CommsAdminStation)
        end)
        addCommsReply(_("adminStn-comms", "Where is the colony where your researchers live?"), function ()
          setCommsMessage(_("adminStn-comms", [[You'll find it to the east of the nebulae]]))
          addCommsReply(_("<- Back"), CommsAdminStation)
        end)
        addCommsReply(_("adminStn-comms", "Tell us about the nearby nebulae."), function ()
          setCommsMessage(_("adminStn-comms", [[Well I suppose you already know about the nebulae. They are to the north.

Did you know that it's a popular place to hunt for treasure?]]))
          addCommsReply(_("<- Back"), CommsAdminStation)
        end)
        addCommsReply(_("adminStn-comms", "Are there any Kraylor in the area?"), function ()
          setCommsMessage(_("adminStn-comms", [[We see some from time to time, but with the non-aggression treaty, they haven't been too much trouble.]]))
          addCommsReply(_("<- Back"), CommsAdminStation)
        end)
        addCommsReply(_("adminStn-comms", "Are there any Exuari in the area?"), function ()
          setCommsMessage(_("adminStn-comms", [[Old space junk, mostly. We haven't seen any real Exauri activity in decades.]]))
          addCommsReply(_("<- Back"), CommsAdminStation)
        end)
    end
  end
end

-- XXX lost_mission.CommsFoundShip -> lost_mission.lua

-- XXX salvage_repair_mission.CommsInvestigator -> salvage_repair_mission.lua

-- XXX patrol_mission.CommsDroneStation -> patrol_mission.lua


function CommsBeingAttacked (self, instigator)
  if self.lastAttackedComms == nil or ((getScenarioTime() - self.lastAttackedComms) > 300) then
    self:sendCommsMessage(Player,string.format(_("attack-incCall","HELP!\nWe are taking damage from %s and might need assistance."),instigator:getCallSign()))
    self.lastAttackedComms = getScenarioTime()
  end
  if self.lastAttackedLog == nil or ((getScenarioTime() - self.lastAttackedLog) > 30) then
    Player:addToShipLog(string.format(_("attack-shipLog","%s is taking damage!"),self:getCallSign()), "RED")
    self.lastAttackedLog = getScenarioTime()
  end
end
--==================================================
--==
--==
--==
--==
--==
--==
--==      LOST MISSION
--==
--==
--==
--==
--==
--==
--==
--==================================================

-- XXX lost_mission.StartMissionLost -> lost_mission.lua


-- XXX lost_mission.UpdateMissionLost -> lost_mission.lua

-- XXX lost_mission.FinishMissionLost -> lost_mission.lua

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

-- XXX patrol_mission.StartMissionPatrol -> patrol_mission.lua


-- XXX patrol_mission.UpdateMissionPatrol -> patrol_mission.lua

-- XXX patrol_mission.CheckConvoyArrived -> patrol_mission.lua

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

-- XXX salvage_repair_mission.StartMissionSpareParts -> salvage_repair_mission.lua

-- XXX salvage_repair_mission.UpdateMissionSpareParts -> salvage_repair_mission.lua

-- XXX salvage_repair_mission.FinishMissionSpareParts -> salvage_repair_mission.lua
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

-- XXX patrol_mission.StartMissionDroneNest -> patrol_mission.lua

-- XXX patrol_mission.UpdateMissionDroneNest -> patrol_mission.lua

-- XXX patrol_mission.FinishMissionDroneNest -> patrol_mission.lua

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

-- XXX salvage_repair_mission.StartMissionRepair -> salvage_repair_mission.lua

-- XXX salvage_repair_mission.UpdateMissionRepair -> salvage_repair_mission.lua

-- XXX salvage_repair_mission.FinishMissionRepair -> salvage_repair_mission.lua


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

-- XXX patrol_mission.TransferToDrone -> patrol_mission.lua

function TransferToPP1()
  Player:addToShipLog(_("drone-shipLog", "It's nice to be back aboard the Propitious 1"),"Yellow")
  Player:transferPlayersToShip(PP1)
end

function UpdateNebulaBonuses()
  for _, bonus in pairs(Admin_station.nebula_bonuses) do
    if bonus.revealed == nil then
      if bonus:isScannedBy(Player) then
        bonus.revealed = true
        bonus:onFullScan()
      end
    end
  end
end

-- XXX patrol_mission.UpdateDroneStations -> patrol_mission.lua

function UpdateHarassment()
  local alldead = true
  for _, enemy in ipairs(Defence_station.harass_enemies) do
    if enemy:isValid() then
      alldead = false
      if distance(enemy, Player) > 240000 then
        local angle = (angleRotation(enemy, Player) + 180) % 360
        local px, py = Player:getPosition()
        local vx, vy = vectorFromAngle(angle, 60000)
        enemy:setPosition(px + vx, py + vy)
      end
      enemy:orderAttack(Player)
    end
  end
  if alldead and Defence_station.harass_timer == nil then
    Defence_station.harass_timer = getScenarioTime()
  end
  if Defence_station.harass_timer ~= nil and getScenarioTime() - Defence_station.harass_timer > 300 then
    Defence_station.harass_timer = nil
    SpawnHarrasment()
  end
end

function UpdateTraffic()

  for i=#Traffic.new_ships,1,-1 do
    local ship = Traffic.new_ships[i]
    if ship:isValid() and ship:getDockingState() == 1 then
      ship.docked_at = getScenarioTime()
      table.remove(Traffic.new_ships, i)
      table.insert(Traffic.docked_ships, ship)
    end
  end

  for i=#Traffic.docked_ships,1,-1 do
    local ship = Traffic.docked_ships[i]
    if ship:isValid() and getScenarioTime() - ship.docked_at >= 60 then
        local dst = Traffic.srcdest[irandom(1,#Traffic.srcdest)]
        table.remove(Traffic.docked_ships, i)
        table.insert(Traffic.leaving_ships, ship)
        ship.dx, ship.dy = sectorToXY(dst)
        ship:orderFlyTowards(ship.dx, ship.dy)
    end
  end

  for i=#Traffic.leaving_ships,1,-1 do
    local ship = Traffic.leaving_ships[i]
    if ship:isValid() and distance(ship, ship.dx, ship.dy) <= 5000 then
        table.remove(Traffic.leaving_ships, i)
        ship:destroy()
    end
  end

  -- Spawn code below here
  if getScenarioTime() - Traffic.timer < 30 or (#Traffic.new_ships + #Traffic.docked_ships + #Traffic.leaving_ships) > 25 then return end

  Traffic.timer = getScenarioTime()
  local faction = Traffic.factions[irandom(1,#Traffic.factions)]
  local type = Traffic.types[irandom(1,#Traffic.types)]
  local src = Traffic.srcdest[irandom(1,#Traffic.srcdest)]
  local station = Traffic.stations[irandom(1,#Traffic.stations)]
  local new_ship = CpuShip():setFaction(faction):setTemplate(type):setPosition(sectorToXY(src)):orderDock(station)
  if faction == "TSN" then
    new_ship:setCommsFunction(function () setCommsMessage(_("newShip-comms", "Too busy to talk today, Captain.")) end)
  end
  table.insert(Traffic.new_ships, new_ship)
end

-- XXX lost_mission.HendrixHints -> lost_mission.lua

-- XXX patrol_mission.CheckDefeatConditions -> patrol_mission.lua

function CheckCheevoTreasure()
  CHEEVOS["treasure"] = true
  for name, bonus in pairs(Admin_station.nebula_bonuses) do
    if bonus.wasFound ~= true and (name == "nuke" or name == "repair" or name == "rep") then
      CHEEVOS["treasure"] = false
      return
    end
  end
end

-- XXX salvage_repair_mission.CheckCheevoJunk -> salvage_repair_mission.lua

function CheckCheevoNoGhosts()
  CHEEVOS["noghosts"] = true
  for _, ship in ipairs(Defence_station.convoy_enemies) do
    if ship:isValid() then
      CHEEVOS["noghosts"] = false
      return
    end
  end

  for _, ship in ipairs(Defence_station.ghost_defenders) do
    if ship:isValid() then
      CHEEVOS["noghosts"] = false
      return
    end
  end
end

function CheckCheevoNoWormhole()
  CHEEVOS["nowormhole"] = true
  for _, val in pairs(Wormhole_station.insults) do
    if val ~= true then
      CHEEVOS["nowormhole"] = false
      return
    end
  end
end

-- XXX patrol_mission.CheckCheevoHeros -> patrol_mission.lua

function CheckCheevoGrandSlam()
  CHEEVOS["grandslam"] = true
  for _, val in pairs(CHEEVOS) do
    if val ~= true then
      CHEEVOS["grandslam"] = false
      return
    end
  end
end

function CheckCheevos()
  CheckCheevoTreasure()
  salvage_repair_mission.CheckCheevoJunk()
  CheckCheevoNoGhosts()
  CheckCheevoNoWormhole()
  patrol_mission.CheckCheevoHeros()
  CheckCheevoGrandSlam()
end

function CheevoString(name)
  if CHEEVOS[name] then
    return _("adminStn-comms","SUCCESS!!!")
  else
    return _("adminStn-comms","INCOMPLETE")
  end
end

function update(delta)
  patrol_mission.CheckDefeatConditions()
  UpdateNebulaBonuses()
  patrol_mission.UpdateDroneStations()
  lost_mission.UpdateMissionLost()
  patrol_mission.UpdateMissionPatrol()
  salvage_repair_mission.UpdateMissionSpareParts()
  patrol_mission.UpdateMissionDroneNest()
  salvage_repair_mission.UpdateMissionRepair(delta)
  UpdateHarassment()
  UpdateTraffic()
end
