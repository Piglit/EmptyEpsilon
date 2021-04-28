lost_mission = {}

function lost_mission.init(Admin_station, CHEEVOS, CommsBeingAttacked, Wormhole_station)
	lost_mission.Admin_station = Admin_station
	lost_mission.CHEEVOS = CHEEVOS
	lost_mission.CommsBeingAttacked = CommsBeingAttacked
	lost_mission.Wormhole_station = Wormhole_station
	lost_mission.Colony_stations = {
    SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCallSign("E437"):setPosition(34457, -71084):setCommsFunction(lost_mission.CommsColonyStation),
    SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCallSign("E146"):setPosition(31997, -76192):setCommsFunction(lost_mission.CommsColonyStation),
    SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCallSign("E544"):setPosition(23031, -75857):setCommsFunction(lost_mission.CommsColonyStation),
    SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCallSign("E236"):setPosition(25371, -73885):setCommsFunction(lost_mission.CommsColonyStation),
    SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCallSign("E245"):setPosition(29204, -74511):setCommsFunction(lost_mission.CommsColonyStation),
    SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCallSign("E335"):setPosition(25371, -78805):setCommsFunction(lost_mission.CommsColonyStation),
    SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCallSign("E338"):setPosition(27077, -70894):setCommsFunction(lost_mission.CommsColonyStation),
    SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCallSign("E465"):setPosition(37335, -71048):setCommsFunction(lost_mission.CommsColonyStation),
    SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCallSign("E939"):setPosition(35632, -65750):setCommsFunction(lost_mission.CommsColonyStation),
    SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCallSign("E869"):setPosition(29010, -63480):setCommsFunction(lost_mission.CommsColonyStation),
    SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCallSign("E166"):setPosition(23668, -68398):setCommsFunction(lost_mission.CommsColonyStation),
    SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCallSign("E770"):setPosition(30334, -67832):setCommsFunction(lost_mission.CommsColonyStation),
    SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCallSign("E671"):setPosition(29388, -79374):setCommsFunction(lost_mission.CommsColonyStation),
    SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCallSign("Z649"):setPosition(31984, -82788):setCommsFunction(lost_mission.CommsColonyStation),
    SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCallSign("Z128"):setPosition(26390, -83457):setCommsFunction(lost_mission.CommsColonyStation),
    SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCallSign("Z342"):setPosition(22418, -88122):setCommsFunction(lost_mission.CommsColonyStation),
    SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCallSign("Z929"):setPosition(21252, -84484):setCommsFunction(lost_mission.CommsColonyStation),
    SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCallSign("Z243"):setPosition(27527, -87933):setCommsFunction(lost_mission.CommsColonyStation),
    SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCallSign("Z750"):setPosition(31280, -87888):setCommsFunction(lost_mission.CommsColonyStation),
    SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCallSign("Z848"):setPosition(33846, -85391):setCommsFunction(lost_mission.CommsColonyStation),
    SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCallSign("Z417"):setPosition(26361, -95457):setCommsFunction(lost_mission.CommsColonyStation),
    SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCallSign("Z359"):setPosition(29766, -97160):setCommsFunction(lost_mission.CommsColonyStation),
    SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCallSign("Z532"):setPosition(32257, -91906):setCommsFunction(lost_mission.CommsColonyStation),
    SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCallSign("Z118"):setPosition(32037, -93754):setCommsFunction(lost_mission.CommsColonyStation),
    SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCallSign("Z441"):setPosition(23248, -92193):setCommsFunction(lost_mission.CommsColonyStation),
    SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCallSign("Z260"):setPosition(35632, -98484):setCommsFunction(lost_mission.CommsColonyStation),
    SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCallSign("H419"):setPosition(43760, -87132):setCommsFunction(lost_mission.CommsColonyStation),
    SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCallSign("H823"):setPosition(51901, -87244):setCommsFunction(lost_mission.CommsColonyStation),
    SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCallSign("H663"):setPosition(52483, -91098):setCommsFunction(lost_mission.CommsColonyStation),
    SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCallSign("H524"):setPosition(52658, -82703):setCommsFunction(lost_mission.CommsColonyStation),
    SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCallSign("H158"):setPosition(48343, -89446):setCommsFunction(lost_mission.CommsColonyStation),
    SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCallSign("H251"):setPosition(43488, -97649):setCommsFunction(lost_mission.CommsColonyStation),
    SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCallSign("H320"):setPosition(42444, -94700):setCommsFunction(lost_mission.CommsColonyStation),
    SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCallSign("H252"):setPosition(43958, -91294):setCommsFunction(lost_mission.CommsColonyStation),
    SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCallSign("H425"):setPosition(56016, -90406):setCommsFunction(lost_mission.CommsColonyStation),
    SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCallSign("H922"):setPosition(57203, -94511):setCommsFunction(lost_mission.CommsColonyStation),
    SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCallSign("H762"):setPosition(54743, -97917):setCommsFunction(lost_mission.CommsColonyStation),
    SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCallSign("H121"):setPosition(49445, -94511):setCommsFunction(lost_mission.CommsColonyStation),
    SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCallSign("H364"):setPosition(47845, -98361):setCommsFunction(lost_mission.CommsColonyStation),
    SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCallSign("X627"):setPosition(51248, -69291):setCommsFunction(lost_mission.CommsColonyStation),
    SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCallSign("X957"):setPosition(43438, -68261):setCommsFunction(lost_mission.CommsColonyStation),
    SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCallSign("X726"):setPosition(55485, -68625):setCommsFunction(lost_mission.CommsColonyStation),
    SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCallSign("X547"):setPosition(49960, -63472):setCommsFunction(lost_mission.CommsColonyStation),
    SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCallSign("X856"):setPosition(46654, -65612):setCommsFunction(lost_mission.CommsColonyStation),
    SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCallSign("X254"):setPosition(53771, -63981):setCommsFunction(lost_mission.CommsColonyStation),
    SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCallSign("X155"):setPosition(43248, -64098):setCommsFunction(lost_mission.CommsColonyStation),
    SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCallSign("X267"):setPosition(53986, -71427):setCommsFunction(lost_mission.CommsColonyStation),
    SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCallSign("X134"):setPosition(56067, -75779):setCommsFunction(lost_mission.CommsColonyStation),
    SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCallSign("X468"):setPosition(49256, -78617):setCommsFunction(lost_mission.CommsColonyStation),
    SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCallSign("X333"):setPosition(50794, -73146):setCommsFunction(lost_mission.CommsColonyStation),
    SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCallSign("X361"):setPosition(45996, -70975):setCommsFunction(lost_mission.CommsColonyStation)
  }
	local storage = getScriptStorage()
	storage.lost_mission = {}
	storage.lost_mission.set_Difficulty = lost_mission.set_Difficulty
	storage.lost_mission.set_Player = lost_mission.set_Player
	storage.lost_mission.set_parameters = lost_mission.set_parameters
end

function lost_mission.set_Difficulty(Difficulty)
	lost_mission.Difficulty = Difficulty
end

function lost_mission.set_Player(Player)
	lost_mission.Player = Player
end

function set_parameters(Difficulty, Player)
	lost_mission.set_Difficulty(Difficulty)
	lost_mission.set_Player(Player)
end


function lost_mission.check()
	if lost_mission.Admin_station == nil or not lost_mission.Admin_station:isValid() then return false end
	if lost_mission.Player == nil or not lost_mission.Player:isValid() then return false end
	if lost_mission.Wormhole_station == nil or not lost_mission.Wormhole_station:isValid() then return false end
	return true
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

function lost_mission.StartMissionLost()
  -- for bonus, art in pairs(lost_mission.Admin_station.nebula_bonuses) do
  --   local nx, ny = art:getPosition()
  --   lost_mission.Player:addToShipLog("DEBUG: "..bonus.." @ "..nx..", "..ny, "Blue")
  -- end
  setCommsMessage(_("adminStn-comms",
[[Sorry to interrupt, but we've just recieved an urgent call.

It seems one of our researchers, Dr. Hendrix, and her crew have lost their way in a nearby nebula and need our help. They were running experiments in the nebula when their engines and transponder went offline. Please follow our scout vessel, SR7, to the nebula and search for them.]]))

  lost_mission.Admin_station.x, lost_mission.Admin_station.y = lost_mission.Admin_station:getPosition()
  lost_mission.Admin_station.assist_ship = CpuShip():setCallSign("SR7"):setPosition(lost_mission.Admin_station.x + 200, lost_mission.Admin_station.y):orderFlyTowardsBlind(sectorToXY("D6")):setFaction("Human Navy"):setTemplate("Ktlitan Scout"):setWarpDrive(true):setCommsScript(""):setCommsFunction(function ()
    if lost_mission.Admin_station.assist_ship.state == "flyToNebula" or lost_mission.Admin_station.assist_ship.state == "waiting" then
      setCommsMessage(_("adminStn-comms", "Meet me at the edge of the nebula"))
    end
  end) -- Rand Nebula location
  lost_mission.Admin_station.assist_ship.state = "flyToNebula"
  lost_mission.Admin_station.mission_state = "lost"
  lost_mission.Admin_station.lost_ship:destroy()
end

function lost_mission.UpdateMissionLost()
  if lost_mission.Admin_station.mission_state == nil or lost_mission.Admin_station.mission_state == "done" then return end

  if lost_mission.Admin_station.assist_ship.state == "flyToNebula" and distance(lost_mission.Admin_station.assist_ship, sectorToXY("D6")) <= 1000 then
    lost_mission.Admin_station.assist_ship.state = "waiting"
    lost_mission.Admin_station.assist_ship:orderStandGround()
  end

  if lost_mission.Admin_station.assist_ship.state == "waiting" and distance(lost_mission.Admin_station.assist_ship, lost_mission.Player) <= 20000 then
    lost_mission.Admin_station.assist_ship:sendCommsMessage(lost_mission.Player, _("adminStn-incCall", [[Ready to head in?

The nebula is very thick, so we will need to get close to find a ship with no transponder. Probes won't show the ship, but your relay station should be able to pick it up at 20U or less. There may be hazards, so be careful.

I'll follow you. Let's find Dr. Hendrix and bring her crew home.]]))
    lost_mission.Player:addToShipLog(_("adminStn-shipLog", "Fly into the Nebula and find Dr. Hendrix"), "Green")
    lost_mission.Admin_station.assist_ship:orderFlyFormation(lost_mission.Player, 2300, 1700)
    lost_mission.Admin_station.assist_ship.state = "done"
    lost_mission.Admin_station.assist_ship:setCommsScript("comms_ship.lua")
  end

  if lost_mission.Admin_station.mission_state == "lost" then
    if distance(lost_mission.Player, lost_mission.Admin_station.lost_location_x, lost_mission.Admin_station.lost_location_y) <= 20000 then -- Must be 20U from lost ship to find it
      lost_mission.Admin_station.found_ship = CpuShip():setFaction("Human Navy"):onTakingDamage(lost_mission.CommsBeingAttacked):setTemplate("Equipment Freighter 2"):setWarpDrive(true):setCallSign("SV1"):setPosition(lost_mission.Admin_station.lost_location_x, lost_mission.Admin_station.lost_location_y):setCanBeDestroyed(false)
      lost_mission.Admin_station.mission_state = "almost found"
      lost_mission.Admin_station.found_ship:setCommsFunction(lost_mission.CommsFoundShip)
    end
  end

  if lost_mission.Admin_station.mission_state == "found" and lost_mission.Admin_station.found_ship:isDocked(lost_mission.Admin_station.hendrix_station) then
    lost_mission.Admin_station.mission_state = "done"
    lost_mission.Admin_station.found_ship:setCanBeDestroyed(true)
    lost_mission.Admin_station.found_ship:destroy()
  end
end

function lost_mission.FinishMissionLost()
  lost_mission.Player:setLongRangeRadarRange(lost_mission.Player:getLongRangeRadarRange() * 1.20)
  lost_mission.Player:addToShipLog(_("finishMissionNebulae-shipLog","Sensors have been upgraded."),"Green")
  lost_mission.Player:addReputationPoints(5)

  -- Send to a random colony station
  lost_mission.Admin_station.hendrix_station = lost_mission.Colony_stations[irandom(1, #lost_mission.Colony_stations)]
  --lost_mission.Player:addToShipLog("DEBUG hedrix station is: "..lost_mission.Admin_station.hendrix_station:getCallSign(), "Magenta")

  if lost_mission.Admin_station.found_ship == nil then -- To account for GM force-finish
    lost_mission.Admin_station.mission_state = "done"
  else
    -- Temporarily adjust the call sign so that the station name doesn't show in ship log
    local tmpCall = lost_mission.Admin_station.hendrix_station:getCallSign()
    lost_mission.Admin_station.hendrix_station:setCallSign("Colony Station")
    lost_mission.Admin_station.found_ship:orderDock(lost_mission.Admin_station.hendrix_station)
    lost_mission.Admin_station.hendrix_station:setCallSign(tmpCall)
    lost_mission.Admin_station.mission_state = "found"
  end
  if lost_mission.Admin_station.assist_ship ~= nil and lost_mission.Admin_station.assist_ship:isValid() then
    lost_mission.Admin_station.assist_ship:orderDefendTarget(lost_mission.Admin_station)
    lost_mission.Admin_station.assist_ship.state = "done"
    lost_mission.Admin_station.assist_ship:setCommsScript("comms_ship.lua")
  end
end

function lost_mission.CommsFoundShip(comms_source, comms_target)
  if lost_mission.Admin_station.mission_state == "almost found" then
      setCommsMessage(_("found-comms", [[Come in? Dr. Hendrix here... Come in?

Oh thank heavens, we're found! We thought we might be stuck here for good!

We need to install a new hyperplasma full bridge rectifier, but our plasma conduit driver has gone missing. You must have one in your engine room? If you let us borrow it, we will upgrade your sensors with our new experimental modifications.]]))
      addCommsReply(_("found-comms", "Sure, you can borrow our conduit driver!"), function ()
        setCommsMessage(_("found-comms", [[Great. Your sensors are upgraded. We'll get this rectifier installed and be on our way.

Thanks again, Captain. If you ever need some help with your Hawking Scanners, look me up!]]))
      end)

      lost_mission.FinishMissionLost()

  elseif lost_mission.Admin_station.mission_state == "found" then
      setCommsMessage(_("found-comms", "Thanks so much for finding us!"))
  end
end

function lost_mission.CommsColonyStation(comms_source, comms_target)
  setCommsMessage(_("colony-comms", "Well, what I can do for you?"))

  if lost_mission.Admin_station.mission_state == "done" and lost_mission.Wormhole_station.tier2_mission_state == "rma" then
    addCommsReply(_("colony-comms", "We're looking for Dr. Hendrix"), function ()
      if comms_target ~= lost_mission.Admin_station.hendrix_station then
        lost_mission.CHEEVOS["eyeondr"] = false
        lost_mission.HendrixHints(comms_target)
        setCommsMessage(comms_target.hendrix_hint)
      else
        if not comms_source:isDocked(comms_target) then
          setCommsMessage(_("colony-comms", [[I.....zzzZ
Hello?
...
The nearby NeZula somzzzzzzimes messssssses with our long range commcommcommcomm somet...

...

....dock...pr...b..
...r]]))
        else
          setCommsMessage(_("colony-comms", [[I am Dr. Hendrix.

If I remember that voice correctly, you are the crew from the Navy ship that saved me when I was stranded in the nebula!

What can I do for you?]]))
          addCommsReply(_("colony-comms", "Can you fix this Hawking Scanner?"), function ()
            setCommsMessage(_("colony-comms", [[Let me have a look...

Ah, I see why it's giving you trouble. Everything reads as okay, but the Graviton Lens is mis-calibrated somehow so it's throwing off the whole system.

The good news is that it's easy to swap these out, the tech at the wormhole station should be able to do it. The bad news is that we have a shortage of Graviton Lenses right now because of those drone convoys.

I've put in a requisition for one in your name. If you can find one in a Navy storehouse, bring it to the wormhole station and they should be good to go.]]))
          lost_mission.Player:addToShipLog(_("colony-shipLog", "Find a Graviton Lens"), "Green")
          lost_mission.Admin_station.req_lens = true
          end)
        end
      end
    end)
  else
    -- Variations on the colony station comms (NEEDED)
    addCommsReply(_("colony-comms", "Some filler text and whatever. What are we even doing here?"), function ()
      setCommsMessage(_("colony-comms", "Dude, where even ARE we?"))
    end)
  end
end

function lost_mission.HendrixHints(stn)
  if stn.hendrix_hint ~= nil then return end

  if lost_mission.Difficulty ~= 1 and irandom(1,13 - lost_mission.Difficulty) == 1 then -- Hints every time on easy, but unhelpful 1/10 on med and 1/8 on hard
    stn.hendrix_hint = _("hendrixHints-comms", "Sorry, I don't know where Dr. Hendrix lives")
    return
  end

  local hendrix_callsign = lost_mission.Admin_station.hendrix_station:getCallSign()
  local char = irandom(1,4)
  local hint = hendrix_callsign:sub(char,char)
  if char == 1 then
    stn.hendrix_hint = string.format(_("hendrixHints-comms","Dr. Hendrix, of course! I'm pretty sure she was on a %s-class station, but darned if I can remember which one."),hint)
  else
    stn.hendrix_hint = string.format(_("hendrixHints-comms","Gosh, Dr. Hendrix. Okay. Sorry, but honestly all I remember is that her address definitely has a '%s' in it."),hint)
  end
end

