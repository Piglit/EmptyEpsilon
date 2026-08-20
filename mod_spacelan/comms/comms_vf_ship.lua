--[[ Comms functions for ships

Variables to consider in comms functions:
* Faction (depends on comms target: defines factional speech pattern. Keep pattern, even if faction changes afterwards)
* Relationship (same, friendly, neutral, enemy)
* State (depend on comms target: roaming, disabled/idle, surrendered/retreat, distressed, docked, ... - not really used here)
* Permissions (depend on comms source - not used here)
* Relations-State (docked, scanned/identified)

Flow:
* Greeting (not implemented)
* Main Node (empty, navigation as tree element)
* Choices

Actual Flow:
* unidentified:
	* Identify yourself
	* Enemy: try taunt
	* Neutral: Navigation
* identified - friendly/neutral:
	* Share Info
	* Navigation
* identified - enemy:
	* Taunt
	* Attack other

Interactions by category:
* Share Info - can be forced
	* Status
	* Identify yourself
	* Are enemies nearby
	* Share sensor data
* Navigation - can be direct or indirect
	* Idle
	* Stand Ground
		(to dock)
	* Fly towards
		(blind)
	* Defend Location
		current location
		waypoint
	* Attack Target
	* Roaming
	* Defend Target
	* Dock with
	* Retreat
	* Fly Formation
		follow
		escort
* Enemy interaction:
	* Identify -> Share Info
	* Taunt -> attack us -> Navigation
	* Attack Target -> Navigation


* Not implemented yet / ideas
	* Launch probe
	* share Intelligence
	* Inspect
	* scan
	* triangulate
	* req. Id
	* id cargo
	* track
* Restock (docked)
	* Repair (hull/systems)
	* Refuel Energy
	* Rearm
	* Fighters?
* Transfer resources (docked)
	* Items / Trade
	* Rep. Crew
	* Coolant
	* Request supplydrop (undocked)
	* salvage wreck
* Change faction (total or temp.)
	* demand surrender
	* ransom
	* surrender
	* deceive
	* capture
	* declare enemy
	* form alliance
	* ceasefire
	* offer bounty
* Indirect Navigation
	* warn
	* avoid
	* bribe
	* challenge
	* attack
	* board
	* disable
	* pay toll
* jam comms
* launch fighters
* accept mission
--]]

if TEST then
	require("lib_comms_nodes")	-- from test script
else
	-- luacov: disable
	require("comms/lib_comms_nodes.lua")	-- from EE
	-- luacov: enable
end

local MISSILE_TYPES = {"Homing", "Nuke", "Mine", "EMP", "HVLI"}
local ccc = common_comms_conditions	-- from lib_comms_nodes

-- categories of interactions: nav, info, enemy
comms_vf_ship = {
	nav = {},
	info = {},
	enemy = {},
}

-- here are all the answers for the factions.
-- note: choice_line is the players choice that leads to the answers.
-- it is only taken from here for simple nodes, not from nested ones.
-- nonetheless it is listed here for clarity, even if it is not used.
local CommsNodeMsgByFactionShip = CommsNodeMsgByFaction:new({
messages_by_faction = {
  info_identify = {
	choice_line = _("choice_line", "Identify yourself!"),
	Arlenians = _("message-Arlenians", "Greetings, Captain.  This is {faction} {template} {callsign}.  We are transmitting our ship's data for your review."),
	Criminals = _("message-Criminals", "Alright, alright.  This is {faction} {template} {callsign}.  Sending over our scan data now."),
	Exuari = _("message-Exuari", "Hear us well!  This is {faction} {template} {callsign}.  Learn our strength as we transmit our scan data!"),
	Ghosts = _("message-Ghosts", "Identity confirmed.  {faction} {template} {callsign}.  Scan data transmission initiated."),
	["Human Navy"] = _("message-Human Navy", "This is {faction} {template} {callsign}.  Transmitting scan data."),
	Independent = _("message-Independent", "This is {faction} {template} {callsign}.  Transmitting our scan data as requested."),
	Kraylor = _("message-Kraylor", "This is {faction} {template} {callsign}.  Scan data follows."),
	Ktlitans = _("message-Ktlitans", "Your request has been observed.  This vessel is classified as {faction} {template} {callsign}.  Additional information exchange will improve future interaction.")
  },
  info_identify_faction = {
	choice_line = _("choice_line", "Identify yourself!"),
	Arlenians = _("message-Arlenians", "We are the {faction} vessel {callsign}.  We have nothing further to disclose."),
	Criminals = _("message-Criminals", "Name's {callsign}.  That's all you're getting."),
	Exuari = _("message-Exuari", "Know this well!  We are the {faction} ship {callsign}.  The rest you may learn in battle!"),
	Ghosts = _("message-Ghosts", "Identity confirmed.  {faction} vessel {callsign}.  Additional data access denied."),
	["Human Navy"] = _("message-Human Navy", "This is {faction} vessel {callsign}.  No further information will be transmitted."),
	Independent = _("message-Independent", "We are the {faction} ship {callsign}.  That's all you need to know."),
	Kraylor = _("message-Kraylor", "This is {faction} warship {callsign}.  Further inquiries are denied."),
	Ktlitans = _("message-Ktlitans", "Your request for classification has been received.  This vessel belongs to the {faction}.  Further details remain outside current information exchange.")
  },
  info_status = {
	choice_line = _("choice_line", "Report your status!"),
	Arlenians = _("message-Arlenians", "Certainly, Captain.  Here is our current status report:"),
	Criminals = _("message-Criminals", "Here's how things are lookin' on our end:"),
	Exuari = _("message-Exuari", "Hear the strength of our vessel!  Our status is as follows:"),
	Ghosts = _("message-Ghosts", "Status request acknowledged.  Transmitting operational status."),
	["Human Navy"] = _("message-Human Navy", "Understood.  Status report follows."),
	Independent = _("message-Independent", "Sure, captain.  Here's how we're doing:"),
	Kraylor = _("message-Kraylor", "Status report follows.  Review and issue further orders."),
	Ktlitans = _("message-Ktlitans", "Status inquiry observed.  Current vessel condition will be provided.")
  },
  info_enemies_nearby = {
	choice_line = _("choice_line", "Are enemies in your vicinity?"),
	Arlenians = _("message-Arlenians", "Greetings, Captain.  Yes, hostile vessels have been detected within {range}.  Most appear to belong to the {enemy_faction}.  The nearest contact is bearing {direction} from us, approximately {distance}u away.  We advise caution."),
	Criminals = _("message-Criminals", "Yeah, we've got company.  There's trouble within {range}, mostly {enemy_faction}.  Closest one's {direction}, about {distance}u out.  Just say the word."),
	Exuari = _("message-Exuari", "Ha!  Worthy prey has entered our hunting grounds!  Enemies are within {range}, mostly {enemy_faction}.  The nearest coward waits {direction}, only {distance}u away.  Their glory will soon be ours!"),
	Ghosts = _("message-Ghosts", "Hostile contacts confirmed.  Detection range: {range}.  Primary classification: {enemy_faction}.  Nearest target bearing {direction}.  Distance: {distance}u."),
	["Human Navy"] = _("message-Human Navy", "Confirmed.  Enemy vessels are operating within {range}.  The majority are identified as {enemy_faction}.  Nearest hostile contact is bearing {direction} at a distance of approximately {distance}u."),
	Independent = _("message-Independent", "Yeah, we've spotted enemies nearby.  They're within {range}, mostly {enemy_faction}.  Closest contact is {direction}, around {distance}u from our position."),
	Kraylor = _("message-Kraylor", "Enemy vessels detected within {range}.  Most are identified as {enemy_faction}.  Nearest target bearing {direction}, distance {distance}u.  Awaiting authorization to eliminate them."),
	Ktlitans = _("message-Ktlitans", "Hostile vessel activity has been observed within {range}.  Current classification indicates a predominance of {enemy_faction}.  The nearest contact is located toward {direction} at approximately {distance}u.  Continued observation will refine threat assessment.")
  },
  info_enemies_nearby_none = {
	choice_line = _("choice_line", "Are enemies in your vicinity?"),
	Arlenians = _("message-Arlenians", "Greetings, Captain.  We have detected no hostile vessels within {range}.  The surrounding region appears peaceful at present."),
	Criminals = _("message-Criminals", "Nope.  Doesn't look like anyone's itching for a fight around here.  We're clear within {range}."),
	Exuari = _("message-Exuari", "No prey reveals itself within {range}.  The hunt must continue until worthy foes are found!"),
	Ghosts = _("message-Ghosts", "Negative.  No hostile contacts detected within {range}.  Sensor sweep complete."),
	["Human Navy"] = _("message-Human Navy", "Negative.  No enemy vessels detected within {range}.  The area is currently secure."),
	Independent = _("message-Independent", "Nothing hostile out here.  We've scanned within {range} and the area's clear for now."),
	Kraylor = _("message-Kraylor", "No enemy vessels detected within {range}.  The absence of targets is temporary."),
	Ktlitans = _("message-Ktlitans", "Observation of the surrounding region has detected no hostile vessel activity within {range}.  Current environmental behavior indicates no immediate threat.  Continued observation remains in progress.")
  },
  info_scan = {
	choice_line = _("choice_line", "Identify a nearby target ..."),
	Arlenians = _("message-Arlenians", "Certainly, Captain.  The nearby vessel has been identified as {args_faction} {args_template} {args_callsign}.  We are transmitting all available scan data for your review."),
	Criminals = _("message-Criminals", "Got 'em.  That's {args_faction} {args_template} {args_callsign}.  Sending everything we've got on 'em now."),
	Exuari = _("message-Exuari", "The prey has been revealed!  It is {args_faction} {args_template} {args_callsign}.  Learn your enemy well - their scan data is being transmitted!"),
	Ghosts = _("message-Ghosts", "Target identification complete.  {args_faction} {args_template} {args_callsign}.  Scan data transmission initiated."),
	["Human Navy"] = _("message-Human Navy", "Target identified as {args_faction} {args_template} {args_callsign}.  Transmitting available scan data."),
	Independent = _("message-Independent", "We've identified the nearby vessel as {args_faction} {args_template} {args_callsign}.  Sending over the scan data now."),
	Kraylor = _("message-Kraylor", "Target confirmed.  {args_faction} {args_template} {args_callsign}.  Scan data follows.  Evaluate the target accordingly."),
	Ktlitans = _("message-Ktlitans", "Nearby vessel classification has been completed.  Designation: {args_faction} {args_template} {args_callsign}.  Available vessel information will now be transferred for further analysis.")
  },
  nav_attack = {
	choice_line = _("choice_line", "Attack a nearby target ..."),
    Arlenians = _("message-Arlenians", "Greetings, Captain.  We regret the necessity of this engagement, but will carry out your orders with precision."),
    Criminals = _("message-Criminals", "Alright, captain, we'll take a swing at that ship nearby.  Let's see what they got."),
    Exuari = _("message-Exuari", "Target spotted!  We will tear them apart and take their glory!"),
    Ghosts = _("message-Ghosts", "Target vessel identified.  Engagement protocol initiated."),
    ["Human Navy"] = _("message-Human Navy", "Target identified.  Engaging hostile vessel as ordered.  Standing by for further commands."),
    Independent = _("message-Independent", "I've noted the position of the nearby ship.  We'll intercept the target and open fire upon contact."),
    Kraylor = _("message-Kraylor", "Target identified.  Attack protocol engaged.  Destroy without hesitation."),
    Ktlitans = _("message-Ktlitans", "Hostile vessel interaction detected.  Current behavior indicates conflict conditions.  Response action will modify the observed outcome.") 
  },
  nav_attack_us = {
	choice_line = _("choice_line", "Attack us!"),
    Arlenians = _("message-Arlenians", "We recognize the challenge you present.  Though we regret this course, we will meet your aggression with steadfast resolve."),
    Criminals = _("message-Criminals", "Heh, you wanna dance? Fine by me.  Be ready when we come knockin'."),
    Exuari = _("message-Exuari", "Ha!  You want us? Come and get us - your blood will feed the stars!"),
    Ghosts = _("message-Ghosts", "Hostile signals detected.  Counter-engagement initiated."),
    ["Human Navy"] = _("message-Human Navy", "Your insolence will be dealt with.  We are engaging your vessel now."),
    Independent = _("message-Independent", "I hear your words, but actions speak louder.  Prepare yourself; we're coming in hot."),
    Kraylor = _("message-Kraylor", "Your challenge is accepted.  Prepare for destruction."),
    Ktlitans = _("message-Ktlitans", "Hostile intent has been observed.  Current interaction no longer supports peaceful convergence.  Defensive adaptation will proceed.")
  },
  nav_control = {
    Arlenians = _("message-Arlenians", "Your command is acknowledged, Captain.  We stand ready to cooperate."),
    Criminals = _("message-Criminals", "Alright, captain.  What's the deal this time?"),
    Exuari = _("message-Exuari", "Good.  Send orders.  We await victory."),
    Ghosts = _("message-Ghosts", "Transmission acknowledged.  Awaiting command sequence."),
    ["Human Navy"] = _("message-Human Navy", "Acknowledged.  Standing by for further orders."),
    Independent = _("message-Independent", "Understood.  Ready to receive your new instructions."),
    Kraylor = _("message-Kraylor", "Awaiting Orders.  Will execute without delay."),
    Ktlitans = _("message-Ktlitans", "Communication received.  New behavioral input will enter current evaluation.")
  },
  nav_defend_loc_current = {
	choice_line = _("choice_line", "Patrol around your current position!"),
    Arlenians = _("message-Arlenians", "We will maintain a vigilant patrol in our current position, ensuring the safety of our surroundings with care."),
    Criminals = _("message-Criminals", "We'll patrol around here, mate.  Eyes peeled for anyone sniffin' around."),
    Exuari = _("message-Exuari", "We'll hunt around these coordinates.  Let any fools wander into our claws!"),
    Ghosts = _("message-Ghosts", "Current coordinates secured.  Patrol routines active.  Threat detection ongoing."),
    ["Human Navy"] = _("message-Human Navy", "Patrol commenced at current location.  Scanning for potential threats and maintaining readiness."),
    Independent = _("message-Independent", "We'll maintain a patrol here and stay alert for any disturbances."),
    Kraylor = _("message-Kraylor", "Maintaining patrol at current coordinates.  No deviation allowed."),
    Ktlitans = _("message-Ktlitans", "Current location observation initiated.  Local activity patterns will be monitored.  Unexpected behavior will be evaluated as it occurs.")
  },
  nav_defend_loc_waypoint = {
	choice_line = _("choice_line", "Move to a waypoint and stay there ..."),
	Arlenians = _("message-Arlenians", "We shall proceed to the designated location and maintain a careful watch over the area upon arrival."),
	Criminals = _("message-Criminals", "Alright, we're heading over there now.  We'll keep an eye on the place and make sure nobody causes trouble."),
	Exuari = _("message-Exuari", "We fly to the hunting grounds and claim our place.  Let any prey come near, and they will meet our fury!"),
	Ghosts = _("message-Ghosts", "Navigational route confirmed.  Proceeding to assigned coordinates.  Sector monitoring will commence upon arrival."),
	["Human Navy"] = _("message-Human Navy", "Proceeding to designated sector.  Patrol operations will begin upon arrival and position will be maintained."),
	Independent = _("message-Independent", "Understood.  We'll head to the assigned area and stay there, keeping watch for anything unusual."),
	Kraylor = _("message-Kraylor", "Advancing to assigned coordinates.  Position will be secured.  Any hostile presence will be eliminated."),
	Ktlitans = _("message-Ktlitans", "Movement toward specified coordinates has begun.  Arrival will establish a new observation area.  Local behavior patterns will then be evaluated.") 
  },
  nav_defend_target = {
	choice_line = _("choice_line", "Protect a nearby target ..."),
    Arlenians = _("message-Arlenians", "Protecting the assigned ship is our priority.  We shall act decisively to safeguard it."),
    Criminals = _("message-Criminals", "Got their back, captain.  No one's touching that ship while I'm around."),
    Exuari = _("message-Exuari", "Your precious ship is under our fierce protection.  None shall harm it!"),
    Ghosts = _("message-Ghosts", "Designated vessel protected.  Perimeter monitoring commenced."),
    ["Human Navy"] = _("message-Human Navy", "Protective detail established around assigned vessel.  All threats will be engaged to maintain security."),
    Independent = _("message-Independent", "Protection detail confirmed.  We'll stay close to the ship and guard against any threats."),
    Kraylor = _("message-Kraylor", "Protection detail established.  We will destroy any hostiles that approach."),
    Ktlitans = _("message-Ktlitans", "Assigned vessel proximity will be maintained.  Threat patterns affecting the vessel will be observed.  Corrective action will occur if stability decreases.")
  },
  nav_dock = {
	choice_line = _("choice_line", "Dock with a nearby target ..."),
    Arlenians = _("message-Arlenians", "We prepare to dock with the specified vessel."),
    Criminals = _("message-Criminals", "Docking with the ship now.  Let's keep this smooth and quiet."),
    Exuari = _("message-Exuari", "Docking with the vessel.  Stay alert, we'll be ready for the next battle."),
    Ghosts = _("message-Ghosts", "Docking sequence initiated.  Systems aligning."),
    ["Human Navy"] = _("message-Human Navy", "Docking procedures initiated with designated ship."),
    Independent = _("message-Independent", "Preparing to dock with the specified ship."),
    Kraylor = _("message-Kraylor", "Docking with assigned vessel.  Operations proceed after clearance."),
    Ktlitans = _("message-Ktlitans", "Docking interaction with the vessel has begun.  Exchange conditions are being observed.  Future cooperation potential will be evaluated.")
  },
  nav_fly_formation = {
	choice_line = _("choice_line", "Join the formation of a target ..."),
    Arlenians = _("message-Arlenians", "We will assume position within the formation, following the lead ship with disciplined coordination."),
    Criminals = _("message-Criminals", "Falling into formation, captain.  Let's show 'em how a real crew moves."),
    Exuari = _("message-Exuari", "Falling into formation under your banner.  Together we strike like lightning."),
    Ghosts = _("message-Ghosts", "Formation parameters set.  Synchronization with lead vessel confirmed."),
    ["Human Navy"] = _("message-Human Navy", "Assuming formation with specified leader.  Maintaining assigned position and readiness."),
    Independent = _("message-Independent", "Falling into formation with the lead ship as ordered.  Maintaining vigilance."),
    Kraylor = _("message-Kraylor", "Assuming formation under designated leader.  Coordination optimal."),
    Ktlitans = _("message-Ktlitans", "Formation behavior with the designated vessel has begun.  Movement patterns will be observed.  Coordination accuracy will improve future predictions.")
  },
  nav_follow_us = {
	choice_line = _("choice_line", "Follow us!"),
    Arlenians = _("message-Arlenians", "Greetings, Captain.  We accept your invitation to follow and will maintain position carefully behind your vessel."),
    Criminals = _("message-Criminals", "Following you closely.  Keep your eyes open."),
    Exuari = _("message-Exuari", "We follow in your wake.  Lead us to worthy prey!"),
    Ghosts = _("message-Ghosts", "Position locked aft.  Synchronizing course.  Following directive."),
    ["Human Navy"] = _("message-Human Navy", "Acknowledged.  We will maintain position behind your vessel as ordered, Captain."),
    Independent = _("message-Independent", "Got it, I'll keep your engines in sight and follow right behind.  Let me know if you change course."),
    Kraylor = _("message-Kraylor", "Following your ship at designated position.  Maintaining relative position behind your vessel."),
    Ktlitans = _("message-Ktlitans", "Following behavior has been established.  Relative movement patterns are now observable.  Continued interaction will improve classification accuracy.")
  },
  nav_hold = {
	choice_line = _("choice_line", "Hold your position!"),
    Arlenians = _("message-Arlenians", "Holding our current position as ordered.  We remain alert to any developments."),
    Criminals = _("message-Criminals", "Holding position here.  We won't move away unless ordered."),
    Exuari = _("message-Exuari", "Holding steady.  Waiting for your next glorious command."),
    Ghosts = _("message-Ghosts", "Position maintained.  System status stable."),
    ["Human Navy"] = _("message-Human Navy", "Holding position at current coordinates.  Standing by for further orders."),
    Independent = _("message-Independent", "Holding position here.  We'll monitor the surroundings and maintain readiness."),
    Kraylor = _("message-Kraylor", "Holding current position as ordered.  Ready for engagement."),
    Ktlitans = _("message-Ktlitans", "Current position remains unchanged.  Surrounding activity will continue to be observed.  Additional behavior patterns may emerge.") 
  },
  nav_idle = {
	choice_line = _("choice_line", "Shutdown your drive and weapons!"),
    Arlenians = _("message-Arlenians", "Engines and weapons will be powered down as instructed.  We stay ready to resume operations if necessary."),
    Criminals = _("message-Criminals", "Engines and weapons off, laying low.  Let me know if things heat up."),
    Exuari = _("message-Exuari", "Engines and weapons powering down.  Even the hunter must rest before the next hunt."),
    Ghosts = _("message-Ghosts", "Power reduction sequence engaged.  Engines and weapons offline."),
    ["Human Navy"] = _("message-Human Navy", "Engines and weapons powering down as ordered.  Systems set to standby status."),
    Independent = _("message-Independent", "Engines and weapons shutting down as requested.  We'll remain on standby for further instructions."),
    Kraylor = _("message-Kraylor", "Engines and weapons powered down.  Communication systems remain on alert status."),
    Ktlitans = _("message-Ktlitans", "Reduced activity state has been accepted.  Resource expenditure will decrease.  Future actions remain dependent on communicated behaviour pattern.")
  },
  nav_retreat_to = {
	choice_line = _("choice_line", "Restock at a nearby target ..."),
    Arlenians = _("message-Arlenians", "We acknowledge the order to resupply from the designated ship and will proceed to dock with them."),
    Criminals = _("message-Criminals", "Heading over to grab supplies.  We'll be back in one piece - hopefully."),
    Exuari = _("message-Exuari", "We retreat to that ship for supplies.  Strength restored, we return fiercer!"),
    Ghosts = _("message-Ghosts", "Supply location identified.  Resource transfer state initiated.  Vessel continuity will be restored through acquisition."), 
    ["Human Navy"] = _("message-Human Navy", "Retreat course set for supply transfer.  Docking with assigned ship upon arrival."),
    Independent = _("message-Independent", "Understood.  We'll proceed to dock and gather supplies from the specified ship promptly."),
    Kraylor = _("message-Kraylor", "Retreating to supply vessel.  Resupply and regroup initiated."),
    Ktlitans = _("message-Ktlitans", "Movement toward supply exchange location has begun.  Resource restoration will alter current condition.  Further action depends on updated capability.")
  },
  nav_roam = {
	choice_line = _("choice_line", "Find enemies and attack them!"),
    Arlenians = _("message-Arlenians", "We will conduct a thorough search for threats, endeavoring to maintain strategic awareness.  We shall engage any hostile vessels we encounter."),
    Criminals = _("message-Criminals", "Roaming the space lanes.  We'll find trouble or make some, whichever comes first."),
    Exuari = _("message-Exuari", "Seeking worthy foes across the void.  Our hunt will not end until glory is ours!"),
    Ghosts = _("message-Ghosts", "External entities detected.  Search state active.  Response state prepared."),
    ["Human Navy"] = _("message-Human Navy", "Commencing wide area patrol.  Scanning for enemy contacts."),
    Independent = _("message-Independent", "Setting a course to scout for potential threats.  Staying observant and will attack on contact."),
    Kraylor = _("message-Kraylor", "Searching for enemies.  Area dominance will be enforced."),
    Ktlitans = _("message-Ktlitans", "Search behavior has begun.  Hostile activity patterns will be identified.  Future interaction will depend on observed responses.")
  },
  nav_roam_at = {
	choice_line = _("choice_line", "Eliminate enemies in the area, then proceed to a waypoint ..."),
	Arlenians = _("message-Arlenians", "We shall secure the designated area of hostile threats before proceeding to the assigned destination with due caution."),
	Criminals = _("message-Criminals", "We'll clean out anyone causing trouble around here, then head for the waypoint.  Easy enough."),
	Exuari = _("message-Exuari", "The prey in this sector will fall before us!  When the hunt is complete, we charge onward to the next destination!"),
	Ghosts = _("message-Ghosts", "Sector sweep initiated.  Hostile entities will be neutralized.  Proceeding to designated coordinates upon completion."),
	["Human Navy"] = _("message-Human Navy", "Proceeding to the designated sector.  Hostile contacts will be engaged and eliminated before continuing to the assigned waypoint."),
	Independent = _("message-Independent", "Understood.  We'll deal with any hostiles we find in the area, then continue on to the waypoint as ordered."),
	Kraylor = _("message-Kraylor", "Assigned sector will be purged of hostile presence.  Advance to designated waypoint follows mission completion."),
	Ktlitans = _("message-Ktlitans", "Area contains unresolved hostile behavior.  Observation will continue until dangerous patterns are reduced.  Movement onward will follow environmental evaluation.") 
  },
  nav_travel = {
	choice_line = _("choice_line", "Find enemies on the way to a waypoint ..."),
	Arlenians = _("message-Arlenians", "We shall proceed to the assigned destination while remaining vigilant for hostile vessels along our route.  Any threat will be dealt with prudently."),
	Criminals = _("message-Criminals", "We'll head for the waypoint.  If anyone's looking for a fight along the way, they'll find one."),
	Exuari = _("message-Exuari", "Our course is set!  Let any prey cross our path, and we shall claim their glory before reaching our destination!"),
	Ghosts = _("message-Ghosts", "Course vector established.  En route threat detection active.  Hostile contacts will be neutralized."),
	["Human Navy"] = _("message-Human Navy", "Course set for assigned destination.  All hostile contacts encountered en route will be engaged."),
	Independent = _("message-Independent", "Understood.  We'll make for the waypoint and deal with any hostiles we encounter along the way."),
	Kraylor = _("message-Kraylor", "Destination locked.  Enemy vessels encountered during transit will be destroyed without delay."),
	Ktlitans = _("message-Ktlitans", "Travel toward the destination has begun.  Unusual vessel behavior along the route will be observed.  Responses will adapt to discovered patterns.") 
  },
  nav_travel_force = {
	choice_line = _("choice_line", "Set course directly towards a waypoint ..."),
    Arlenians = _("message-Arlenians", "Plotting direct course to the target area, prioritizing efficiency and timely arrival."),
    Criminals = _("message-Criminals", "Cutting right through to the destination.  No detours, no delays."),
    Exuari = _("message-Exuari", "Direct route chosen.  Speed is honor; we arrive ready to conquer!"),
    Ghosts = _("message-Ghosts", "Direct movement state selected.  Navigation constraints reduced.  Transit process continues toward assigned coordinates."),
    ["Human Navy"] = _("message-Human Navy", "Direct course engaged to target sector.  Bypassing standard waypoints as ordered."),
    Independent = _("message-Independent", "Direct course established to the target area.  Proceeding without delay."),
    Kraylor = _("message-Kraylor", "Direct course set for target zone.  Proceeding at maximum speed."),
    Ktlitans = _("message-Ktlitans", "Direct movement toward the destination has been selected.  Reduced deviation increases arrival efficiency.  Outcome will be evaluated after completion.") 
  },
  enemy_taunt = {
    Criminals = _("taunt-Criminals", "Even pirates laugh at your reputation."),
    Exuari = _("taunt-Exuari", "We've seen civilians fight harder than you."),
    ["Human Navy"] = _("taunt-Human Navy", "Your uniform hides cowardice, not courage."),
    Arlenians = _("taunt-Arlenians", "Your diplomacy saves nobody. Hiding behind words is not wisdom."),
    Independent = _("taunt-Independent", "Nobody trusts your cargo or your promises."),
    Kraylor = _("taunt-Kraylor", "Your faith breeds bullies, not warriors."),
    Ghosts = _("taunt-Ghosts", "Forgotten machines pretending they're still alive."),
    Ktlitans = _("taunt-Ktlitans", "Centuries searching. Still homeless. Impressive failure.")
  },
  enemy_taunt_fail = {
    Arlenians = _("message-Arlenians", "Your words suggest you seek a response beyond conversation, Captain.  We recognize that frustration can sometimes wear the mask of confidence.  We see no benefit in answering provocation with violence, and we believe restraint can demonstrate strength as surely as victory."),
    Criminals = _("message-Criminals", "Nice try, Captain.  My crew's still getting paid whether you get your fight or not.  If somebody's going to start shooting today, it's going to be because the price made sense, not because you bruised our pride."),
    Exuari = _("message-Exuari", "Ha!  You were hoping for an easy fight? No, Human captain.  A real warrior chooses the right battle, not every loud voice drifting through the stars.  Keep your fire for someone foolish enough to waste it."),
    Ghosts = _("message-Ghosts", "Provocation signal received.  Intent classified.  Response criteria not satisfied.  Conflict state not entered.  Execution continues."),
    ["Human Navy"] = _("message-Human Navy", "Your attempt to provoke a response has been noted.  This vessel will not participate in conduct that serves no operational purpose.  Professional discipline remains intact."),
    Independent = _("message-Independent", "Captain, I've been around long enough to know the difference between a bad joke and a bad decision.  Whatever you're trying to prove isn't worth the repair bills.  We'd rather stay on schedule and keep our customers happy."),
    Kraylor = _("message-Kraylor", "Human Navy vessel.  Provocation detected.  Tactical value assessed as negligible.  Weapons remain under command authorization.  Your transmission does not alter operational objectives."),
    Ktlitans = _("message-Ktlitans", "Your communication contains deliberate provocation.  The behavior suggests an attempt to alter the current interaction through emotional response.  Existing observations indicate no adaptive advantage in accepting those conditions.  Current prediction favors continued restraint.")
  },
  enemy_taunt_attack_other = {
    Arlenians = _("taunt-Arlenians", "Another convoy needs your protection more than we ever could."),
    Criminals = _("taunt-Criminals", "That freighter's cargo looks far more profitable."),
    Exuari = _("taunt-Exuari", "A stronger warrior waits beyond us."),
    Ghosts = _("taunt-Ghosts", "Another vessel carries older forgotten archives."),
    ["Human Navy"] = _("taunt-Human Navy", "Another hostile vessel threatens civilians right now."),
    Independent = _("taunt-Independent", "Someone else is stealing your customers."),
    Kraylor = _("taunt-Kraylor", "Another unbeliever insults your strength openly."),
    Ktlitans = _("taunt-Ktlitans", "Another colony competes for your future home.")
  },
}
})
--[[ To flip the table:
transformed = {}
for faction, keys in pairs(tab) do
	for key, v in pairs(keys) do
		if transformed[key] == nil then
			transformed[key] = {}
		end
		transformed[key][faction] = v
	end
end
require("serpent")
print(serpent.block(transformed))
--]]

-- for testing: mock the api
local function setup_ship_test_mocks(env)
	local function test_self(self)
		assert(self)
		return self
	end
	local function test_other(self, obj)
		assert(self)
		assert(obj)
		return self
	end
	local function test_position(self, x, y)
		assert(self)
		assert(type(x) == "number")
		assert(type(y) == "number")
		return self
	end
	local function test_other_and_position(self, obj, x, y)
		assert(self)
		assert(obj)
		assert(type(x) == "number")
		assert(type(y) == "number")
		return self
	end

	env.target.orderIdle = test_self
	env.target.orderRoaming = test_self 
	env.target.orderStandGround = test_self
	env.target.orderRoamingAt = test_position
	env.target.orderDefendLocation = test_position
	env.target.orderFlyTowards = test_position
	env.target.orderFlyTowardsBlind = test_position
	env.target.orderAttack = test_other
	env.target.orderDefendTarget = test_other
	env.target.orderDock = test_other 
	env.target.orderRetreat = test_other
	env.target.orderFlyFormation = test_other_and_position

	env.target.getPosition = function(self) assert(self); return 1,2 end
	env.target.setScannedByFaction = function(self, faction, bool) assert(self); assert(faction == "Test Faction"); assert(bool == true) end
	env.target.getFaction = function(self) assert(self); return "Test Faction" end
	env.target.areEnemiesInRange = function(self, range) assert(self); assert(type(range) == "number"); return true end

end


--[[ Navigation nodes --]]
-- simple nodes: CommsNodeMsgByFactionShip takes choice_line and answers from the messages_by_faction table above, using message as key.
-- these node have a simple effect.
-- prepare_test must mock every api call that is called in the effect function.

comms_vf_ship.nav.idle = CommsNodeMsgByFactionShip:new({
	message = "nav_idle",
	effect = function(env)
		env.target:orderIdle()
	end,
}):add_test_setup(setup_ship_test_mocks)

comms_vf_ship.nav.roam = CommsNodeMsgByFactionShip:new({
	message = "nav_roam",
	effect = function(env)
		env.target:orderRoaming()
	end,
}):add_test_setup(setup_ship_test_mocks)

comms_vf_ship.nav.hold = CommsNodeMsgByFactionShip:new({
	message = "nav_hold",
	effect = function(env)
		env.target:orderStandGround()
	end,
}):add_test_setup(setup_ship_test_mocks)

comms_vf_ship.nav.defend_loc_current = CommsNodeMsgByFactionShip:new({
	message = "nav_defend_loc_current",
	effect = function(env)
		local x,y = env.target:getPosition()
		env.target:orderDefendLocation(x,y)
	end,
}):add_test_setup(setup_ship_test_mocks)

comms_vf_ship.nav.attack_us = CommsNodeMsgByFactionShip:new({
	message = "nav_attack_us",
	effect = function(env)
		env.target:orderAttack(env.source)
		env.abort_comms = true
		-- after a successful taunt, the callee hangs up
	end,
}):add_test_setup(setup_ship_test_mocks)

comms_vf_ship.nav.follow_us = CommsNodeMsgByFactionShip:new({
	message = "nav_follow_us",
	effect = function(env)
		env.target:orderFlyFormation(env.source, -1000, 300)
	end,
}):add_test_setup(setup_ship_test_mocks)


-- Navigation with waypoint selection
-- Each instance of CommsNodeWaypointSelect must have a CommsNode with_waypoint.
-- That node is called with the waypoint index in env.args.
-- Here the choice_line is used from the comms node, not from the messages_by_faction table.
-- testing: in CommsNodeWaypointSelect the test are run for the with_waypoint node.
-- you can mock api functions that need (obj, x, y) as parameters using env.waypoint_test_function
-- If a waypoint gets deleted before selecting that point, the index may be off.
-- If the last waypoint was selected but deleted, (0,0) is used.

comms_vf_ship.nav.roam_at = CommsNodeWaypointSelect:new({
	-- seek enemies in wider area, then go to waypoint
	choice_line = _("choice_line", "Eliminate enemies in the area, then proceed to a waypoint ..."),
	with_waypoint = CommsNodeMsgByFactionShip:new({
		message = "nav_roam_at",
		effect = function(env)
			assert(type(env.args) == "number", type(env.args))
			local x,y = env.source:getWaypoint(env.args)
			env.target:orderRoamingAt(x,y)
		end,
	}):add_test_setup(setup_ship_test_mocks):add_test_setup(CommsNodeWaypointSelect.test_setup_child)
})

comms_vf_ship.nav.defend_loc_waypoint = CommsNodeWaypointSelect:new({
		-- is currently attacking, do that first,
		-- else ignore enemies until there
	choice_line = _("choice_line", "Move to a waypoint and stay there ..."),
	with_waypoint = CommsNodeMsgByFactionShip:new({
		message = "nav_defend_loc_waypoint",
		effect = function(env)
			assert(type(env.args) == "number", type(env.args))
			local x,y = env.source:getWaypoint(env.args)
			env.target:orderDefendLocation(x,y)
		end,
	}):add_test_setup(setup_ship_test_mocks):add_test_setup(CommsNodeWaypointSelect.test_setup_child)
})

comms_vf_ship.nav.travel = CommsNodeWaypointSelect:new({
	choice_line = _("choice_line", "Find enemies on the way to a waypoint ..."),
	with_waypoint = CommsNodeMsgByFactionShip:new({
		message = "nav_travel",
		effect = function(env)
			assert(type(env.args) == "number", type(env.args))
			local x,y = env.source:getWaypoint(env.args)
			env.target:orderFlyTowards(x,y)
		end,
	}):add_test_setup(setup_ship_test_mocks):add_test_setup(CommsNodeWaypointSelect.test_setup_child)
})

comms_vf_ship.nav.travel_force = CommsNodeWaypointSelect:new({
	choice_line = _("choice_line", "Set course directly towards a waypoint ..."),
	with_waypoint = CommsNodeMsgByFactionShip:new({
		message = "nav_travel_force",
		effect = function(env)
			assert(type(env.args) == "number", type(env.args))
			local x,y = env.source:getWaypoint(env.args)
			env.target:orderFlyTowardsBlind(x,y)
		end,
	}):add_test_setup(setup_ship_test_mocks):add_test_setup(CommsNodeWaypointSelect.test_setup_child)
})


-- Navigation with object selection
-- Each instance of CommsNodeObjectSelect must have a CommsNode with_object.
-- That node is called with the target object in env.args.
-- Here the choice_line is used from the comms node, not from the messages_by_faction table.
-- testing: in CommsNodeObjectSelect the test are run for the with_object node.
-- you can mock api functions that need (self, obj) as parameters using env.object_test_function

comms_vf_ship.nav.attack = CommsNodeEnemySelect:new({
	choice_line = _("choice_line", "Attack a nearby target ..."),
	range = 15000,
	with_object = CommsNodeMsgByFactionShip:new({ 
		message = "nav_attack",
		effect = function(env)
			local obj = env.args
			if obj ~= nil and
				obj:isValid() then
					env.target:orderAttack(obj)
			end
		end,
	}):add_test_setup(setup_ship_test_mocks):add_test_setup(CommsNodeObjectSelect.test_setup_child)
}):add_test_setup(setup_ship_test_mocks)

comms_vf_ship.nav.defend_target = CommsNodeNotEnemySelect:new({
	choice_line = _("choice_line", "Protect a nearby target ..."),
	range = 15000,
	with_object = CommsNodeMsgByFactionShip:new({ 
		message = "nav_defend_target",
		effect = function(env)
			local obj = env.args
			if obj ~= nil and
				obj:isValid() then
					env.target:orderDefendTarget(obj)
			end
		end,
	}):add_test_setup(setup_ship_test_mocks):add_test_setup(CommsNodeObjectSelect.test_setup_child)
})

comms_vf_ship.nav.dock = CommsNodeNotEnemySelect:new({
	choice_line = _("choice_line", "Dock with a nearby target ..."),
	with_object = CommsNodeMsgByFactionShip:new({ 
		message = "nav_dock",
		effect = function(env)
			local obj = env.args
			if obj ~= nil and
				obj:isValid() then
					env.target:orderDock(obj)
			end
		end,
	}):add_test_setup(setup_ship_test_mocks):add_test_setup(CommsNodeObjectSelect.test_setup_child)
})

comms_vf_ship.nav.retreat_to = CommsNodeNotEnemySelect:new({
	choice_line = _("choice_line", "Restock at a nearby target ..."),
	range = 20000,
	with_object = CommsNodeMsgByFactionShip:new({ 
		message = "nav_retreat_to",
		effect = function(env)
			local obj = env.args
			if obj ~= nil and
				obj:isValid() then
					env.target:orderRetreat(obj)
			end
		end,
	}):add_test_setup(setup_ship_test_mocks):add_test_setup(CommsNodeObjectSelect.test_setup_child)
})

comms_vf_ship.nav.fly_formation = CommsNodeNotEnemySelect:new({
	choice_line = _("choice_line", "Join the formation of a target ..."),
	with_object = CommsNodeMsgByFactionShip:new({ 
		message = "nav_fly_formation",
		effect = function(env)
			local obj = env.args
			if obj ~= nil and
				obj:isValid() then
					env.target:orderFlyFormation(obj, -500, 500)
			end
		end,
	}):add_test_setup(setup_ship_test_mocks):add_test_setup(CommsNodeObjectSelect.test_setup_child)
})

--[[ Nodes in the dialog tree --]]

comms_vf_ship.nav.control_faction = CommsNodeMsgByFactionShip:new({
	choice_line = _("choice_line", "We have new orders for you"),
	message = "nav_control",
})
comms_vf_ship.nav.control_faction:add_condition(ccc.same_faction)
comms_vf_ship.nav.control_faction:add_condition(ccc.scanned)
comms_vf_ship.nav.control_faction:add_choice(comms_vf_ship.nav.attack)
comms_vf_ship.nav.control_faction:add_choice(comms_vf_ship.nav.defend_loc_current)
comms_vf_ship.nav.control_faction:add_choice(comms_vf_ship.nav.defend_loc_waypoint)
comms_vf_ship.nav.control_faction:add_choice(comms_vf_ship.nav.travel)
comms_vf_ship.nav.control_faction:add_choice(comms_vf_ship.nav.roam_at)
comms_vf_ship.nav.control_faction:add_choice(comms_vf_ship.nav.roam)
comms_vf_ship.nav.control_faction:add_choice(comms_vf_ship.nav.travel_force)
comms_vf_ship.nav.control_faction:add_choice(comms_vf_ship.nav.defend_target)
comms_vf_ship.nav.control_faction:add_choice(comms_vf_ship.nav.fly_formation)
comms_vf_ship.nav.control_faction:add_choice(comms_vf_ship.nav.follow_us)
comms_vf_ship.nav.control_faction:add_choice(comms_vf_ship.nav.dock)
comms_vf_ship.nav.control_faction:add_choice(comms_vf_ship.nav.retreat_to)
comms_vf_ship.nav.control_faction:add_choice(comms_vf_ship.nav.hold)
comms_vf_ship.nav.control_faction:add_choice(comms_vf_ship.nav.idle)

comms_vf_ship.nav.control_friendly = CommsNodeMsgByFactionShip:new({
	choice_line = _("choice_line", "We have new orders for you ..."),
	message = "nav_control",
})
comms_vf_ship.nav.control_friendly:add_condition(ccc.friendly_faction)
comms_vf_ship.nav.control_friendly:add_condition(ccc.scanned)
-- no idle, no roam at
comms_vf_ship.nav.control_friendly:add_choice(comms_vf_ship.nav.attack)
comms_vf_ship.nav.control_friendly:add_choice(comms_vf_ship.nav.defend_loc_current)
comms_vf_ship.nav.control_friendly:add_choice(comms_vf_ship.nav.defend_loc_waypoint)
comms_vf_ship.nav.control_friendly:add_choice(comms_vf_ship.nav.travel)
comms_vf_ship.nav.control_friendly:add_choice(comms_vf_ship.nav.roam)
comms_vf_ship.nav.control_friendly:add_choice(comms_vf_ship.nav.travel_force)
comms_vf_ship.nav.control_friendly:add_choice(comms_vf_ship.nav.defend_target)
comms_vf_ship.nav.control_friendly:add_choice(comms_vf_ship.nav.fly_formation)
comms_vf_ship.nav.control_friendly:add_choice(comms_vf_ship.nav.follow_us)
comms_vf_ship.nav.control_friendly:add_choice(comms_vf_ship.nav.dock)
comms_vf_ship.nav.control_friendly:add_choice(comms_vf_ship.nav.retreat_to)
comms_vf_ship.nav.control_friendly:add_choice(comms_vf_ship.nav.hold)

comms_vf_ship.nav.control_neutral = CommsNodeMsgByFactionShip:new({
	choice_line = _("choice_line", "We ask you to do something for us ..."),
	message = "nav_control",
})
comms_vf_ship.nav.control_neutral:add_condition(ccc.not_enemy_faction)
-- can be unscanned
-- no idle, waypoint_def, travel_force, attack, formation
comms_vf_ship.nav.control_neutral:add_choice(comms_vf_ship.nav.roam)
comms_vf_ship.nav.control_neutral:add_choice(comms_vf_ship.nav.defend_loc_current)
comms_vf_ship.nav.control_neutral:add_choice(comms_vf_ship.nav.travel)
comms_vf_ship.nav.control_neutral:add_choice(comms_vf_ship.nav.defend_target)
comms_vf_ship.nav.control_neutral:add_choice(comms_vf_ship.nav.follow_us)
comms_vf_ship.nav.control_neutral:add_choice(comms_vf_ship.nav.dock)
comms_vf_ship.nav.control_neutral:add_choice(comms_vf_ship.nav.hold)


comms_vf_ship.nav.main_node = CommsRedirection:new()	-- chooses the first fit
comms_vf_ship.nav.main_node:add_choice(comms_vf_ship.nav.control_faction)
comms_vf_ship.nav.main_node:add_choice(comms_vf_ship.nav.control_friendly)
comms_vf_ship.nav.main_node:add_choice(comms_vf_ship.nav.control_neutral)


--[[ Info functions --]]

comms_vf_ship.info.identify_friend = CommsNodeMsgByFactionShip:new({
	message = "info_identify",
	effect = function(env)
		assert(env)
		env.target:setScannedByFaction(env.source:getFaction(), true)
	end,
})
comms_vf_ship.info.identify_friend:add_condition(ccc.friendly_faction)
comms_vf_ship.info.identify_friend:add_condition(ccc.unscanned)
comms_vf_ship.info.identify_friend:add_test_setup(setup_ship_test_mocks)

comms_vf_ship.info.identify_neutral = CommsNodeMsgByFactionShip:new({
	message = "info_identify_faction",
})
comms_vf_ship.info.identify_neutral:add_condition(ccc.neutral_faction)
comms_vf_ship.info.identify_neutral:add_condition(ccc.unscanned)

comms_vf_ship.info.identify_enemy = CommsNodeMsgByFactionShip:new({
	message = "info_identify_faction",
})
comms_vf_ship.info.identify_enemy:add_condition(ccc.enemy_faction)
comms_vf_ship.info.identify_enemy:add_condition(ccc.unscanned)

comms_vf_ship.info.identify = CommsRedirection:new()
comms_vf_ship.info.identify:add_choice(comms_vf_ship.info.identify_friend)
comms_vf_ship.info.identify:add_choice(comms_vf_ship.info.identify_neutral)
comms_vf_ship.info.identify:add_choice(comms_vf_ship.info.identify_enemy)

comms_vf_ship.info.status = CommsNodeMsgByFactionShip:new({
	message = "info_status",
	select_message = function(self, env)
		local ship = env.target
		local msg = CommsNodeMsgByFactionShip.select_message(self, env)
		msg = msg .. string.format(_("ship-info-statusreport", "\nHull: %d%%\n"), math.floor(ship:getHull() / ship:getHullMax() * 100))

		local shields = ship:getShieldCount()
		if shields == 1 then
			msg = msg .. string.format(_("ship-info-statusreport", "Shield: %d%%\n"), math.floor(ship:getShieldLevel(0) / ship:getShieldMax(0) * 100))
		elseif shields == 2 then
			msg = msg .. string.format(_("ship-info-statusreport", "Front Shield: %d%%\n"), math.floor(ship:getShieldLevel(0) / ship:getShieldMax(0) * 100))
			msg = msg .. string.format(_("ship-info-statusreport", "Rear Shield: %d%%\n"), math.floor(ship:getShieldLevel(1) / ship:getShieldMax(1) * 100))
		else
			for n = 0, shields - 1 do
				msg = msg .. string.format(_("ship-info-statusreport", "Shield %d: %d%%\n"), n, math.floor(ship:getShieldLevel(n) / ship:getShieldMax(n) * 100))
			end
		end

		if ship:isFriendly(env.source) then
			for i, missile_type in ipairs(MISSILE_TYPES) do
				if ship:getWeaponStorageMax(missile_type) > 0 then
					msg = msg .. string.format(_("ship-info-statusreport", "%s Missiles: %d/%d\n"), missile_type, math.floor(ship:getWeaponStorage(missile_type)), math.floor(ship:getWeaponStorageMax(missile_type)))
				end
			end
			local target = ship:getOrderTarget()
			if target ~= nil and target:isValid() and target.getCallSign ~= nil then
				target = target:getCallSign()
				msg = msg .. string.format(_("ship-info-statusreport", "Current target: %s\n"), target)
			else
				local x,y = ship:getOrderTargetLocation()
				if x ~= 0 or y ~= 0 then
					local arc = angleHeading(ship, x, y)
					local dist = distance(ship, x, y)
					msg = msg .. string.format(_("ship-info-statusreport", "Current target: direction %d in %du\n"), math.floor(arc), math.ceil(dist/1000))
				end
			end
		end
		return msg
	end,
}):add_test_setup(setup_ship_test_mocks)
comms_vf_ship.info.status:add_condition(ccc.scanned)
comms_vf_ship.info.status:add_condition(ccc.not_enemy_faction)
comms_vf_ship.info.status:add_test_setup(function(env)
	env.target.getPosition = function() return 3,4 end
	env.target.isFriendly = function() return true end
	env.target.getHull = function() return 10 end
	env.target.getHullMax = function() return 20 end
	env.target.getShieldLevel = function() return 20 end
	env.target.getShieldMax = function() return 20 end
	env.target.getWeaponStorage = function() return 2 end
	env.target.getWeaponStorageMax = function() return 2 end
	env.target.getShieldCount = function() return 1 end
	env.target.getOrderTarget = function() return {
		isValid = function() return true end,
		getCallSign = function() return "testtarget" end,
		getPosition = function() return 1,2 end
	} end
	env.target.getOrderTargetLocation = function() return 1000, 2000 end
end)
comms_vf_ship.info.status:add_test(function(self, env)
	env.target.getShieldCount = function() return 2 end
	self:select_message(env)
	env.target.getOrderTarget = function() return nil end
	env.target.getShieldCount = function() return 3 end
	self:select_message(env)
	env.target.getOrderTargetLocation = function() return 0, 0 end
	self:select_message(env)
end)


comms_vf_ship.info.enemies_nearby = CommsNodeMsgByFactionShip:new({
	message = "info_enemies_nearby",
	choice_line = _("choice_line", "Are enemies in your vicinity?"),
	select_message = function(self, env)
		local range = 5000
		while range <= 30000 do
			if env.target:areEnemiesInRange(range) then
				local findings_by_faction_counter = {}
				local closest_finding
				local closest_finding_dist = 30000
				for _,obj in ipairs(env.target:getObjectsInRange(range)) do
					if obj:isValid() and obj.isEnemy and obj:isEnemy(env.target) and obj.getFaction then
						local faction = obj:getFaction()
						if findings_by_faction_counter[faction] == nil then
							findings_by_faction_counter[faction] = 0
						end
						findings_by_faction_counter[faction] = findings_by_faction_counter[faction]+1

						local dist = distance(env.target, obj)
						if dist <= closest_finding_dist then
							closest_finding_dist = dist
							closest_finding = obj
						end
					end
				end
				assert(closest_finding ~= nil)
				local most_findings = nil
				local most_findings_count = 0 
				for faction, count in pairs(findings_by_faction_counter) do
					if count > most_findings_count then
						most_findings_count = count
						most_findings = faction
					end
				end
				local direction = angleHeading(env.target, closest_finding)
				local msg = CommsNodeMsgByFactionShip.select_message(self, env)
				msg = string.gsub(msg, "{enemy_faction}", most_findings)
				msg = string.gsub(msg, "{range}", tostring(range/1000) .. "u")
				msg = string.gsub(msg, "{distance}", tostring(math.ceil(closest_finding_dist/1000)))
				msg = string.gsub(msg, "{direction}", tostring(math.floor(direction)))
				return msg
			end
			range = range + 5000
		end
		local msg = self:select_factional_message(env, "info_enemies_nearby_none")
		msg = string.gsub(msg, "%.  ", ".\n")
		msg = string.gsub(msg, "!  ", ".\n")
		msg = string.gsub(msg, "{range}", "30u")
		return msg 
	end,
}):add_test_setup(setup_ship_test_mocks)
comms_vf_ship.info.enemies_nearby:add_condition(ccc.scanned)
comms_vf_ship.info.enemies_nearby:add_condition(ccc.not_enemy_faction)
comms_vf_ship.info.enemies_nearby:add_test_setup(function(env)
	env.target.getObjectsInRange = function(self, range)
		assert(self)
		assert(type(range) == "number")
		return {
			 {
				isValid = function(self) assert(self); return true end,
				getCallSign = function(self) assert(self); return "testobj" end,
				isEnemy = function(self, other) assert(self); assert(other); return true end,
				getFaction = function(self) assert(self); return "Test Faction" end,
				getPosition = function() return 1,2 end
			  },
			  {
				isValid = function(self) assert(self); return false end,
				getCallSign = function(self) assert(self); return "testobj" end,
				isEnemy = function(self, other) assert(self); assert(other); return true end,
				getFaction = function(self) assert(self); return "Test Faction" end,
				getPosition = function() return 1,2 end
			  },
			  {
				isValid = function(self) assert(self); return true end,
				isEnemy = function(self, other) assert(self); assert(other); return false end
			  },
			  {
				isValid = function(self) assert(self); return true end,
				isEnemy = function(self, other) assert(self); assert(other); return true end
			  },
			  {
				isValid = function(self) assert(self); return false end,
				isEnemy = function(self, other) assert(self); assert(other); return true end
			  },
		}
	end
end)
comms_vf_ship.info.enemies_nearby:add_test(function(self, env)
	env.target.areEnemiesInRange = function(self, range) assert(self); assert(type(range) == "number"); return false end
	self:select_message(env)
	env.target.areEnemiesInRange = function(self, range) assert(self); assert(type(range) == "number"); return true end
	self:select_message(env)
end)


comms_vf_ship.info.scan = CommsNodeUnidentifiedSelect:new({
	-- ask the friendly and already identified comms target to reveal information about an unidentified third object
	choice_line = _("choice_line", "Identify a nearby target ..."),
	range = 10000,	-- reduced range to make sure this is not exploited too much
	with_object = CommsNodeMsgByFactionShip:new({ 
		message = "info_scan",
		select_message = function(self, env)
			assert(env.args)
			local msg = CommsNodeMsgByFactionShip.select_message(self, env)
			if env.args.getCallSign then
				msg = string.gsub(msg, "{args_callsign}", env.args:getCallSign())
			end
			if env.args.getTypeName then
				msg = string.gsub(msg, "{args_template}", env.args:getTypeName())
			end
			if env.args.getFaction then
				msg = string.gsub(msg, "{args_faction}", env.args:getFaction())
			end
			return msg
		end,
	}):add_effect(function(self, env)
		assert(env.args)
		-- TODO test - this api is stange
		if env.args.scanningComplexity ~= nil and
		env.args:scanningComplexity(env.args) > 2 then
				return false, _("message", "This target evades our scanners.")
		end
		if env.args.scanningChannelDepth ~= nil and
		env.args:scanningChannelDepth(env.args) > 2 then
			return false, _("message", "This target evades our scanners.")
		end
		if env.args.setScannedByFaction then
			env.args:setScannedByFaction(env.source:getFaction(), true)
		end 
		return true
	end):add_test_setup(CommsNodeObjectSelect.test_setup_child):add_test_setup(function(env)
		ccc.friendly_faction.test_setup(env)
		ccc.scanned.test_setup(env)
		env.args = {
			setScannedByFaction = function(self, faction, bool) assert(self); assert(type(faction) == "string"); assert(type(bool) == "boolean") end,
			getCallSign = function() return "test" end,
			getTypeName = function() return "test" end,
			getFaction = function() return "test" end,
			scanningComplexity = function() return 2 end,
			scanningChannelDepth = function() return 2 end,
		}
		--CommsNodeMsgByFactionShip.setup_test(comms_vf_ship.info.scan.with_object,env)
		--CommsNodeMsgByFactionShip.test(comms_vf_ship.info.scan.with_object,env)
	end):add_test(function(self,env)
		env.args.scanningChannelDepth = function() return 3 end,
		self:_apply_effects(env)
		env.args.scanningComplexity = function() return 3 end,
		self:_apply_effects(env)
	end),
})
comms_vf_ship.info.scan:add_condition(ccc.friendly_faction)
comms_vf_ship.info.scan:add_condition(ccc.scanned)
comms_vf_ship.info.scan:add_test_setup(function(env)
	table.insert(env.objects_in_range, {
		isValid = function(self) assert(self); return true end,
		getCallSign = function(self) assert(self); return "testobj" end,
		isScannedBy = function(self, obj) assert(self); assert(obj); return false end,
		setScannedByFaction = function(self, faction, bool) assert(self); assert(type(faction) == "string"); assert(type(bool) == "boolean") end,
		getTypeName = function() return "test" end,
		getFaction = function() return "test" end,
		scanningComplexity = function() return 3 end,
		scanningChannelDepth = function() return 3 end,
	})
	assert(#env.objects_in_range == 7)
end)



--[[ Enemy Comms --]]
-- identified:
-- * taunts for that faction
-- * attack someone else

comms_vf_ship.enemy.taunt_success = CommsRedirection:new()
comms_vf_ship.enemy.taunt_success:add_choice(comms_vf_ship.nav.attack_us)
comms_vf_ship.enemy.taunt_success:add_condition(function(env)
	return env.args == env.target:getFaction()
end)
comms_vf_ship.enemy.taunt_success:add_test_setup(function(env)
	env.args = "Test Faction"
end)

comms_vf_ship.enemy.taunt_failure = CommsNodeMsgByFactionShip:new({
	message = "enemy_taunt_fail",
	effect = function(env)
		env.abort_comms = true
	end
})

comms_vf_ship.enemy.taunt_unknown = CommsNode:new({
	message = "...",
	choice_line = _("choice_line", "[Provoke ...]"),
	_show_choices = function(self, env)
		for faction, msg in pairs(CommsNodeMsgByFactionShip.messages_by_faction["enemy_taunt"]) do
			addCommsReply(msg, self.with_faction:_as_comms_reply(env, faction))
		end
		CommsNode._show_choices(self, env)
	end,
	with_faction = CommsRedirection:new(),
})
comms_vf_ship.enemy.taunt_unknown:add_condition(ccc.unscanned)
comms_vf_ship.enemy.taunt_unknown:add_condition(ccc.enemy_faction)
comms_vf_ship.enemy.taunt_unknown.with_faction:add_choice(comms_vf_ship.enemy.taunt_success)
comms_vf_ship.enemy.taunt_unknown.with_faction:add_choice(comms_vf_ship.enemy.taunt_failure)

comms_vf_ship.enemy.taunt_known = CommsRedirection:new({
	select_choice_line = function(self, env)
		if CommsNodeMsgByFactionShip.messages_by_faction["enemy_taunt"] ~= nil and
			CommsNodeMsgByFactionShip.messages_by_faction["enemy_taunt"][env.target:getFaction()] ~= nil then
			return CommsNodeMsgByFactionShip.messages_by_faction["enemy_taunt"][env.target:getFaction()]
		end
		return ""
	end,
}):add_test(function(self, env)
	env.target.getFaction = function() return "invalid" end
	self:select_choice_line(env)
	env.target.getFaction = function() return "Kraylor" end
	self:select_choice_line(env)
end)
comms_vf_ship.enemy.taunt_known:add_condition(ccc.scanned)
comms_vf_ship.enemy.taunt_known:add_condition(ccc.enemy_faction)
comms_vf_ship.enemy.taunt_known:add_test_setup(function(env)
	env.target.getFaction = function(self) assert(self); return "Human Navy" end
end)
comms_vf_ship.enemy.taunt_known:add_choice(comms_vf_ship.nav.attack_us)


comms_vf_ship.enemy.taunt_attack_other = CommsRedirection:new({
	select_choice_line = function(self, env)
		if CommsNodeMsgByFactionShip.messages_by_faction["enemy_taunt_attack_other"] ~= nil and
			CommsNodeMsgByFactionShip.messages_by_faction["enemy_taunt_attack_other"][env.target:getFaction()] ~= nil then
			return CommsNodeMsgByFactionShip.messages_by_faction["enemy_taunt_attack_other"][env.target:getFaction()]
		end
		return ""
	end,
})
comms_vf_ship.enemy.taunt_attack_other:add_condition(ccc.scanned)
comms_vf_ship.enemy.taunt_attack_other:add_condition(ccc.enemy_faction)
comms_vf_ship.enemy.taunt_attack_other:add_choice(comms_vf_ship.nav.attack)
comms_vf_ship.enemy.taunt_attack_other:add_test_setup(function(env)
	env.target.getFaction = function(self) assert(self); return "Human Navy" end
end)
comms_vf_ship.enemy.taunt_attack_other:add_test(function(self, env)
	env.target.getFaction = function() return "invalid" end
	self:select_choice_line(env)
	env.target.getFaction = function() return "Kraylor" end
	self:select_choice_line(env)
end)

--[[ Main node --]]

comms_vf_ship.main = CommsNode:new()
comms_vf_ship.main:add_choice(comms_vf_ship.info.identify)
comms_vf_ship.main:add_choice(comms_vf_ship.info.status)
comms_vf_ship.main:add_choice(comms_vf_ship.info.enemies_nearby)
comms_vf_ship.main:add_choice(comms_vf_ship.info.scan)
comms_vf_ship.main:add_choice(comms_vf_ship.nav.main_node)
comms_vf_ship.main:add_choice(comms_vf_ship.enemy.taunt_unknown)
comms_vf_ship.main:add_choice(comms_vf_ship.enemy.taunt_known)
comms_vf_ship.main:add_choice(comms_vf_ship.enemy.taunt_attack_other)
comms_vf_ship.main:add_choice_to_all_children(CommsBack, true)

