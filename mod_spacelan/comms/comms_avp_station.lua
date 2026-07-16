--[[
Classes:
---
Those classes are to be used as super-classes for your implementation

CommsAbomination - base class, can be used for anything
CommsEntryPoint - has function setAsCommsFunction(spaceObject), that sets this node as entry point for the dialog. Provides a "Back" dialog-option to go to this node.
CommRedirection - when this node is called, selects the first selectable choice and calls it. it has no own message to show.
CommsEntryRedirection - a combination of the two above
CommsDocked - checks if source is docked with target, abort otherwise
CommsUndocked - like docked, but the other way round.


Attributes:
---
message
choice_line


Methods:
---
Methods to call:
new(data)
add_choice(node)

Methods to overwrite:
can_select(env)
select_choice_line(env)
select_message_and_effect(env)
test(env) ?
--]]
if TEST then
	function _(msg)
		return msg
	end
end
require("comms/comms_abomination.lua")
require("comms/comms_functions.lua")
local cf = comms_functions

-- string.format()
-- gettext _() needs to be arround the string, I guess? TODO find out
--local function f = string.format
local function f(msg, ...)
	return string.format(_(msg), table.unpack({...}))
end


--[[ Declarations of nodes
- Greeting (docked/undocked)
- Spaceport (default return of docked)
- Combat Information Center (also avail undocked)
	- status report (hull/shields & services)
	- launch defense fleet
	- request supply drop
	- request reinforcements
	- show commercial info
	- show information
	- (requestJonque)
	- (requestExpediteDock)
- Hangar / Spaceport Services Management
	- services - ship related / restock ship
- Trade Hub
	- trade
- Governance Office
	- upgrade station
- Bars/Museums Entertainment & Educational Services
	- information / history / gossip
- Dispatcher
	- missions?
 --]]

-- Entry points for different cases
CommsAvpStationEntry = CommsEntryRedirection:new()

-- call checks docking state. Those are to be instanciated
CommsAvpStationDocked = CommsDocked:new()	
CommsAvpStationUndocked = CommsDocked:new()

-- Node class hierarchy (for neutral and friendly stations):
--CommsAvpStationDockedFriendly = CommsDocked:new()
--CommsAvpStationDockedNeutral = CommsDocked:new()
--CommsAvpStationUndockedFriendly = CommsUndocked:new()
--CommsAvpStationUndockedNeutral = CommsUndocked:new()

--CommsAvpStationEnemy = CommsAbomination:new()
CommsAvpStationPanic = CommsAbomination:new()

CommsAvpStationUndockedGreetings = CommsAvpStationUndocked:new()

-- subnotes of CommsAvpStationDocked -> CASD
CASD_Greetings = CommsAvpStationDocked:new({choice_line = _("Proceed to the spaceport")})
CASD_MainNode = CommsAvpStationDocked:new({choice_line = _("Back to the spaceport")})

CASD_Combat = CommsAbomination:new()
CASD_Services = CommsAvpStationDocked:new()
CASD_Trade = CommsAvpStationDocked:new()
CASD_Govern = CommsAvpStationDocked:new()
CASD_Info = CommsAvpStationDocked:new()


-- leaves from comms_functions

CommsAvpStatusReport = CommsAbomination:new()
function CommsAvpStatusReport:select_choice_line(env)
	local status_prompts = {
        "Report status",
        "Report station status",
        string.format("Report station %s status",env.target:getCallSign()),
        "What is your status?",
        string.format("What is the condition of station %s?",env.target:getCallSign()),
    }
    return arraySelectRandom(status_prompts)
end
function CommsAvpStatusReport:select_message_and_effect(env)
	return cf.stationStatusReport(env.source, env.target)
end


--[[ Linking of nodes --]]

-- entry node redirects
CommsAvpStationEntry.add_choice(CommsAvpStationPanic)
CommsAvpStationEntry.add_choice(CommsAvpStationUndockedGreetings)
CommsAvpStationEntry.add_choice(CASD_Greetings)


-- main docked node / spaceport
CASD_MainNode:add_choice(CommsAvpCombat)
CASD_MainNode:add_choice(CommsAvpServices)
CASD_MainNode:add_choice(CommsAvpTrade)
CASD_MainNode:add_choice(CommsAvpGovern)
CASD_MainNode:add_choice(CommsAvpInfo)
CASD_Greetings.choices = CASD_MainNode.choices

-- any undocked node: abort and redirect to docked greeting, when docking
CommsAvpStationUndocked:add_choice(CASD_Greetings)


--[[ Definitions of node methods --]]

function CommsAvpStationDocked:_call(env)
	if CommsAvpStationDocked.super().can_select(self, env) then
		CommsAvpStationDocked.super()._call(self, env)
	else
		setCommsMessage(f("Your ship just left the dock - you are transported back to your ship, before you could finish what you were doing."))
		-- no effects, no more choices
	end
end

function CommsAvpStationUndocked:_call(env)
	if CommsAvpStationUndocked.super().can_select(self, env) then
		CommsAvpStationUndocked.super()._call(self, env)
	else
		setCommsMessage(f("Your ship just docked with our station. To resume the communication, please visit us in the station."))
		-- no effects
	end
end

-- Panic node
function CommsAvpStationPanic:can_select(env)
	local panic_range = 5000 --cf.getPanicRange(env.target)
    return env.target:areEnemiesInRange(panic_range)
end
function CommsAvpStationPanic:select_message_and_effect(env)
	local busy_messages = {
		f("[Automated Response]\nWe're sorry, but we cannot take your take your call right now. All personnel are busy at emergency stations due to hostile entities within %.1f units",
			5000/1000),--cf.getPanicRange(env.target)/1000),
		f("[Automated Response]\nRelay officer temporarily reassigned to damage control team in anticipation of enemy attack. Call back later"),
		f("[Automated Response]\nGone to designated battle station (shield support team). Try again later"),
		f("[Automated Response]\nRelay officer reassigned to %s hull breach emergency response team",
			env.target:getCallSign()),
	}
	return arraySelectRandom(busy_messages)
end

-- Entry points, docked and undocked
function CommsAvpStationUndockedGreetings:select_message_and_effect(env)
	local source, target = env.source, env.target
	local msg = f("You are connected with the Communications Portal of %s station %s.", env.target:getFaction(), env.target:getCallSign())
    local station_greeting_prompt = {
        string.format(_("station-comms","This is %s's communications officer. Go ahead, %s. We're listening."),target:getCallSign(),source:getCallSign()),
        string.format(_("station-comms","%s to %s, receiving your communication. Proceed with your message."),target:getCallSign(),source:getCallSign()),
        string.format(_("station-comms","Confirmed, %s. You're connected to %s. Go ahead."),source:getCallSign(),target:getCallSign()),
        string.format(_("station-comms","This is the %s communications officer. Go ahead, %s."),target:getCallSign(),source:getCallSign()),
        string.format(_("station-comms","%s acknowledges %s's communication. Pray, don't keep us in suspense any longer."),target:getCallSign(),source:getCallSign()),
        string.format(_("station-comms","%s, it is positively thrilling to be the recipient of your undoubtably important message. Please enlighten us."),source:getCallSign()),
        string.format(_("station-comms","Acknowledged, %s. Try not to waste our time. What do you want?"),source:getCallSign()),
        string.format(_("station-comms","What is it now, %s? Make it quick; we're not here for small talk."),source:getCallSign()),
        string.format(_("station-comms","%s reluctantly acknowledges your communication. Make it snappy, %s."),target:getCallSign(),source:getCallSign()),
		_("station-comms","Well?"),
    }
    local prompt = cf.selectMessageByFriendlyness(station_greeting_prompt, env.target.friendlyness)

	return msg .. "\n\n'" .. prompt .. "'"
end


function CASD_Greetings:select_message_and_effect(env)
	--cf.addStationToDatabase(env.source, env.target) --TODO enable
	local source, target = env.source, env.target
	local msg = f("You arrive at the spaceport of the %s station %s.", env.target:getFaction(), env.target:getCallSign())
	-- TODO who speaks?
    local friendly_station_greeting_prompt = {
         string.format(_("station-comms","Hello, space traveler! It's a pleasure to see %s docking with us. How can we make your stay on %s more comfortable?"),source:getCallSign(),target:getCallSign()),
         string.format(_("station-comms","Greetings, cosmic colleague! %s's docking is a cause for celebration here on %s. Any messages or updates to share?"),source:getCallSign(),target:getCallSign()),
         string.format(_("station-comms","Good day, starfaring friend! Your arrival is like a cosmic reunion for %s. Any tales from your travels?"),target:getCallSign()),
         string.format(_("station-comms","Salutations, fellow communicator! %s has reached %s safe and sound. Anything exciting to share from your journey?"),source:getCallSign(),target:getCallSign()),
         string.format(_("station-comms","Hello there! Welcome to %s. It's fantastic to have you on board."),target:getCallSign()),
         string.format(_("station-comms","Hello, astral envoy! %s has made a stellar entrance. Any interesting discoveries on your voyage to %s?"),source:getCallSign(),target:getCallSign()),
         string.format(_("station-comms","Salutations, space traveler! %s's arrival marks another chapter in %s's cosmic adventures. How can we assist you today?"),source:getCallSign(),target:getCallSign()),
         string.format(_("station-comms","Welcome, %s! It's a pleasure to see you docking with %s. How's the cosmic voyage treating you?"),source:getCallSign(),target:getCallSign()),
         string.format(_("station-comms","Hello there, %s! Your arrival brings a new energy to %s. How was your journey?"),source:getCallSign(),target:getCallSign()),
         string.format(_("station-comms","Greetings, %s! Welcome to our space station. It's an honor to have you on board."),source:getCallSign()),
         string.format(_("station-comms","Hello, relay officer. I suppose we should acknowledge the docking of %s, as unremarkable as it may be."),source:getCallSign()),
         string.format(_("station-comms","Welcome, spacefaring communicator. %s docks, and the cosmos barely flinches. How typical."),source:getCallSign()),
         string.format(_("station-comms","Ah, the celestial messenger has arrived. Do enlighten us with tales of %s's travels, if you must."),source:getCallSign()),
         string.format(_("station-comms","Well, well, if it isn't %s. I trust your journey was at least mildly tolerable."),source:getCallSign()),
         string.format(_("station-comms","Ah, the starship %s graces us with its presence. How quaint. Welcome to our humble space station."),source:getCallSign()),
         string.format(_("station-comms","Welcome, spacefaring communicator. I hope %s's visit won't disrupt %s's delicate equilibrium too much."),source:getCallSign(),target:getCallSign()),
         string.format(_("station-comms","Salutations, celestial correspondent. %s's docking disrupted our routine. What urgent message do you bring, if any?"),source:getCallSign()),
         string.format(_("station-comms","Hello there, %s. Your arrival was as eagerly anticipated as a space debris collision. What's the news?"),source:getCallSign()),
         string.format(_("station-comms","Well, look who decided to drop by. What cosmic inconvenience brings %s to %s today?"),source:getCallSign(),target:getCallSign()),
         string.format(_("station-comms","Oh, joy. The starship %s has graced us with their presence. What brings you here?"),source:getCallSign()),
         string.format(_("station-comms","Greetings, stellar correspondent. %s's docking is a source of mild irritation. What cosmic drama unfolds now?"),source:getCallSign()),
         string.format(_("station-comms","Welcome aboard, cosmic messenger. %s's docking better have a good reason. We have enough on our plate without your cosmic theatrics."),source:getCallSign()),
        string.format(_("station-comms","Hello, starbound emissary. %s's presence is less of a pleasure and more of a cosmic headache. What brings you to %s?"),source:getCallSign(),target:getCallSign()),
        string.format(_("station-comms","Salutations, interstellar nuisance. %s's docking is the last thing we needed. What pressing crisis are you here to address?"),source:getCallSign()),
	}
    local prompt = cf.selectMessageByFriendlyness(friendly_station_greeting_prompt, env.target.comms_data.friendlyness+irandom(-10,10))
	return msg .. "\n\n'" .. prompt .. "'"
end

function CASD_MainNode:select_message_and_effect(env)
	return f("You are at the spaceport of the %s station %s.", env.target:getFaction(), env.target:getCallSign())
end



require("comms/test_comms_abomination.lua")	-- last line!
