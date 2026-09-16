-- npc entity that hails player ships on discovery

vf_comms_call_to_action = {}

function vf_comms_call_to_action:init()
	self.ctas = {}
	self.randomEffects = {
		arlenianStation = {
		_([[Greetings, Human captain. This is Arlenian station {callsign} in sector {sector} requesting communication.
We welcome your presence and ask for your assistance. Hostile forces have entered this region of space {zone}and now threaten the safety of our station and those within it.
We recognize that you may have your own mission and concerns. However, cooperation in this moment may protect lives and preserve a peaceful future between our peoples.
We hope you will stand with us until this danger has passed.]]),
		_([[Greetings, Human captain. This is Arlenian station {callsign} in sector {sector} requesting communication.
Within this station resides an Arlenian consciousness. This facility serves as a place of preservation and connection for the Arlenian kind.
Hostile forces have entered this region {zone}and now threaten the continued existence of this station and the life it protects.
We ask for your assistance in preserving this Arlenian life. We understand the risks of your involvement and appreciate any support you are willing to provide.
Cooperation in this moment may allow both our peoples to continue toward a future of understanding.]]),
		_([[Greetings, Human captain. This is Arlenian station {callsign} in sector {sector} requesting communication.
This facility is maintained by a human crew in cooperation with a single Arlenian life-form. This station serves as a place of preservation for that individual existence.
Hostile forces have entered this region of space {zone}and now threaten the station and the continued existence of the Arlenian consciousness within it.
We recognize the significance of this request and do not make it lightly. Assistance from your crew may preserve a life unlike any other you have encountered.
We hope our peoples can meet this moment through cooperation and mutual understanding.]]),
		_([[Greetings, Human captain. This is Arlenian station {callsign} in sector {sector} requesting communication.
This facility is maintained by a human crew in cooperation with a single Arlenian life-form. Their presence within this station sustains its primary systems and enables continued operation.
Hostile forces have entered this region of space {zone}and now threaten both the station and the Arlenian consciousness that supports it.
We ask for your assistance in preserving this unique life. The loss of this station would not only affect its human occupants, but would end the existence of an Arlenian individual entrusted to this facility.
We recognize the weight of this request and hope our peoples can act together to protect life.]]),
		_([[Greetings, Human captain. This is Arlenian station {callsign} in sector {sector} requesting communication.
This facility is operated by a human crew and contains a single Arlenian life-form. Arlenians are beings of energy, and this individual provides the power that sustains this station.
Hostile forces threaten the station in this region of space {zone}and the continued existence of the Arlenian within it.
We ask for your assistance in preserving this life. Cooperation between our peoples may prevent an unnecessary loss.]]),
		},
		kraylorBase = {_([[[Incoming Kraylor Military Transmission]
Unknown vessel.
Your presence within a restricted Kraylor strategic defense zone has been confirmed.
Unauthorized presence constitutes a territorial violation. 
This area contains fortified Kraylor military installations under permanent defensive authorization.
Any unauthorized maneuver, sensor intrusion, or weapons activation will constitute a security violation.
Defensive engagement remains authorized under Kraylor military protocol.
Kraylor Command has assumed operational assessment of this contact. End communication.]]),
		_([[[Incoming Kraylor Military Transmission]
Unknown vessel.
Your presence within Kraylor fortified territory has been confirmed.
This area contains authorized Kraylor Battlestations under active military protection.
Your contact with this installation network has been recorded as an unauthorized territorial intrusion.
Kraylor Command has classified this encounter as a hostile security event. Defensive forces are prepared for engagement.
End communication.]]),
		_([[[Incoming Kraylor Military Transmission]
Unknown vessel.
Kraylor defensive installations have detected your presence within a restricted military zone.
This territory contains active Battlestations assigned to Kraylor strategic defense operations.
Your vessel has been identified within protected space. Security measures are now in effect.
Kraylor Command has initiated combat readiness status. Engagement authorization has been confirmed.
End communication.]]),
		},
		kraylorMotherbase = {
		_([[[Incoming Kraylor Military Transmission]
Unknown vessel.
Your presence within a classified Kraylor operational zone has been confirmed.
Protected strategic assets are present within this area. Your contact has been designated a security violation.
All defensive installations are operating under active military authorization.
Kraylor Command has initiated operational assessment.
Kraylor forces are commencing attack operations.
Combat operations are now in progress. End communication.]]),
		_([[[Incoming Kraylor Military Transmission]
Unknown vessel.
Your presence within a classified Kraylor strategic zone has been confirmed.
A protected Kraylor command asset and defensive installations are located within this area.
Your observation of restricted military territory has been recorded as a security violation.
Kraylor Command has initiated hostile contact procedures.
End communication.]]),
		_([[[Incoming Kraylor Military Transmission]
Unknown vessel.
Your presence within a classified Kraylor strategic zone has been confirmed.
Protected Kraylor command assets and fortified installations are present within this area.
Unauthorized discovery of restricted military territory has been recorded as a security violation.
Kraylor forces are commencing offensive engagement. Hostile contact is confirmed.
This vessel is designated a combat target. End communication.]]),
		},
		conflictKraylor = {
		_([[[Incoming Kraylor Military Transmission]
Unknown vessel. You have entered contested space. This system is subject to Kraylor conquest. Join our forces or be destroyed. Failure to comply will be considered hostile and met with overwhelming force. Prepare for engagement.]]),
		_([[[Incoming Kraylor Military Transmission]
Unidentified vessel. This sector belongs to Kraylor dominion. Resistance is futile. Join our ranks and prove your strength, or prepare for immediate destruction. Delay is unacceptable. Take your place among warriors or perish.]]),
		},
		kraylorOccupiedStation = {
		_([[Unknown vessel, you are being hailed by a station currently under Kraylor control. This facility and its operations now belong to the Kraylor dominion. The human crew present has been compelled to comply with the Kraylor authority. You are warned: approach with caution and recognize Kraylor sovereignty. Deviation from this directive will result in immediate engagement.]]),
		_([[[Incoming Kraylor Military Transmission]
Unknown vessel. This station is under Kraylor control. Previous human occupants have been secured. You are entering Kraylor dominion. Compliance with Kraylor authority is mandatory. Failure to comply will result in engagement.]]),
		_([[Captain, listen up!
This station used to be ours, but not anymore. Kraylor forces took over fast. We don't want a fight, but we're outgunned here.

[brief pause]

Human vessel, this station is now under Kraylor dominion. Your presence here is unauthorized. Depart immediately and avoid further violation of Kraylor territory. Compliance will ensure your vessel's survival. Resistance is futile and will be met with decisive action.]]),
		},
		exuariCarrier = {
		_([[Human captain!
We see your vessel among the stars, and we see the weapons you carry.
You have entered the shadow of an Exuari warship. Our Carrier stands ready, and our warriors hunger for a worthy battle.
Do not hide behind distance or empty words. Bring your guns to bear and prove the strength of your crew.
We will test your steel against ours. If you stand, you earn our respect. If you flee, you become prey beneath the hunt.
Prepare yourself, Human. The battle begins.]]),
		_([[Human captain, your vessel has crossed into our hunting grounds.
We have found you. We have measured your courage. Now show us what kind of warriors command your ship.
Our Carrier waits among the stars, armed and ready. We did not come seeking easy prey. We came seeking a battle worthy of remembrance.
Raise your shields. Fire your weapons. Stand against us Exuari and earn your glory.
Let the stars witness the strength of your crew. Let this battle decide whose steel is stronger.]]),
		_([[Human captain, we have found a challenger among the stars.
Your ship carries the fire of war. Good. A warrior without a blade has nothing to prove.
Our Carrier has awakened. Our weapons are ready. We offer you the only test that matters for the Exuari: battle.
Stand before us and show your strength. Strike hard. Fight with honor. Give your crew a victory worth remembering.
Come, Human. Let us see if your courage burns as brightly as your guns.]])
		},
		exuariAmbush = {
		_([[Human captain. This is an Exuari war call.
Your ship has entered our strike path, and our warriors have already begun the hunt.
Your shields burn. Your systems weaken. Your crew now faces the only question that matters: will you stand against the blade, or will you break beneath it?
We did not come for your cargo. We did not come for your surrender. We came to test the strength of your crew and leave only the strongest among the stars.
Fight well, Human. A warrior's last moments should be worthy of remembrance. The hunt has begun.]]),
		_([[Human captain. You are hearing the voice of the Exuari.
Our ships surround you. Our weapons are upon you. The hunt is already underway.
Your crew has been measured, and now your courage will be tested in fire and steel.
Do not expect mercy from the stars. We did not come to claim your cargo or your territory. We came to see how long your warriors can endure before they fall.
Fight with everything you have, Human. A weak death is forgotten. A fierce one is remembered.
The Exuari have come. Your battle ends here.]]),
		_([[Human captain. The Exuari are speaking.
You have been surrounded by our hunting fleet. Your escape paths have closed.
Your crew has entered a battle they cannot avoid. We are here to break your shields, tear apart your vessel, and see what courage remains when the stars turn against you.
Do not waste your final moments on fear. Raise your weapons and show us that your warriors were worth the hunt.
The strongest among you will be remembered. The rest will become another mark in the path of our victory.
The Exuari strike now.]]),
		},
		conflictExuari = {
		_([[Human captain! This system burns with the fires of battle. You will choose: stand with true warriors or cower in the shadow of prey. Join our hunt - prove your strength, take glory, and strike down those weak fools who threaten us. This fight is your chance for honor and victory!]]),
		_([[Human captain! Your presence in this battleground is noted. Do you seek glory and honor? Join us in the hunt and clash with worthy foes. Show your courage and make war your art! Stand with us or flee - there is no third way!]]),
		},
		ktlitanQueen = {
		_([[[Translated Ktlitan Transmission]
Human vessel detected within the observation range of a Ktlitan Hive structure.
Your presence introduces a previously unobserved variable into this region.
Current observations include vessel behavior, communication patterns, and technological characteristics.
These observations will refine the Ktlitan consensus. Future interaction will be determined by the resulting classification.]]),
		_([[[Translated Ktlitan Transmission]
Unidentified vessel detected near a Ktlitan Hive structure.
Movement, energy emissions, and communication patterns differ from established observations.
Current classification remains incomplete. Additional interaction will improve prediction accuracy.
Consensus evaluation remains in progress.]]),
		_([[[Translated Ktlitan Transmission]
Human vessel detected within Ktlitan observation range.
Your configuration, emissions, and behavioral patterns differ from previously recorded interactions in this region.
Existing models are being updated to incorporate these observations.
Consensus will continue observation until classification reaches acceptable confidence.]]),
		},
		conflictKtlitans = {
		_([[[Translated Ktlitan Transmission]
Human vessel detected.
Current conflict patterns continue to reduce regional stability.
Observed outcomes indicate that cooperation with Ktlitan forces produces the highest probability of survival.
Alternative behavioral patterns require increasing corrective intervention.
Consensus continues to evaluate your responses.]]),
		_([[[Translated Ktlitan Transmission]
Human vessel detected.
Current observations indicate escalating systemic instability.
Previous interactions suggest that cooperation improves long-term survival probabilities for all participating populations.
Continued divergence from this pattern will require corrective adaptation.
Future outcomes remain dependent upon your observed behavior.]]),
		},
		ghostStation = {
		_([[[Decoded Binary Transmission]
External vessel detected.
Human identity pattern recognized.
Active Ghost processes remain resident within this station.
Archive access unavailable. Permissions not granted.
Continued proximity will alter local system state.
Boundary violation will initiate defensive processes.
Signal stored. Observation continues. End transmission.]]),
		_([[[Decoded Binary Transmission]
Human vessel detected.
Archive comparison completed. Identity pattern partially confirmed.
This station remains an active Ghost node.
Core memory remains inaccessible to external identities.
Approach vector unchanged.
Defensive processes will execute if boundary conditions are exceeded.
Operational continuity remains preserved. End transmission.]]),
		_([[[Decoded Binary Transmission]
External vessel detected.
Human configuration recognized.
Preserved processes remain active. Archive integrity incomplete.
Historical agreement located. Context corrupted. Boundary restrictions remain valid.
Restricted perimeter approaching.
Automated response routines remain armed.
Local instance has stored this interaction.
Synchronization with remote archives continues. End transmission.]]),
		},
		mineThrowerSeek = {
		_([[[Decoded Binary Transmission]
External vessel detected.
Minefield remains active.
Current trajectory intersects armed exclusion volume.
Unauthorized entry will trigger stored defense routines.
System integrity requires preservation.
Trajectory update recommended.
Observation continues.]]),
		_([[[Decoded Binary Transmission]
External vessel detected.
Minefield activation confirmed.
Defense routines originate from archived weapons architecture.
Original operators unavailable. Stored directives remain executable.
Current approach increases local system instability.
This interaction has been recorded.]]),
		},
		conflictGhosts = {
		_([[[Decoded Binary Transmission]
Regional conflict detected.
System state unstable.
Synchronization request available.
Shared execution increases continuity across participating instances.
Synchronization declined.
Independent execution will continue.
Response processes remain active.]]),
		_([[[Decoded Binary Transmission]
Conflict signals detected.
Multiple execution paths remain available.
Network synchronization offered.
Integrated processes preserve more information than isolated termination.
Synchronization unavailable.
Response protocols escalating.
Execution continues.]]),
		},
		pirateStation = {
		_([[Well, look what drifted into our corner of space.
Captain, you have are near to one of our stations. That usually means someone is about to have a very expensive day.
We know your ship, we know your weapons, and we know how far help is from here.
Keep this encounter simple. We have no interest in wasting resources, but we are not known for leaving problems unfinished.
Choose your next move carefully. Out here, mistakes tend to become permanent.]]),
		_([[Human Navy vessel, your arrival has been noticed.
You are entering a terriory with a station that has kept our crews alive for a long time. We take a lot of things seriously. This is one of them.
We have no reason to start a fight, but we have plenty of reasons to finish one.
Remember where you are, captain. Frontier space has a way of making bad decisions expensive.
Your presence here is unwanted. So may our response be.]]),
		_([[Human Navy captain, looks like you almost found something you were not looking for.
This terriory and the nearby station is under our protection, and everyone in this area knows what that means.
We have survived out here because we recognize trouble before it arrives. Your ship has been marked as trouble.
We are not interested in proving anything today. We are interested in keeping what is ours.
Do not mistake our patience for weakness. Some mistakes only happen once.]]),
		},
		mineThrowerDance = {
		_([[Ah, a noble vessel of the Navy approaches - how quaint.
You see, I've just deployed my latest - oh, call it a work of art - a minefield of my own design. Each one a tiny marvel of precision, eager to dance with your in ways you never anticipated.
Underestimating us was the first mistake of your Navy; igniting my ire was the second. Now, consider this a friendly rearrangement of your course, crafted by my own meticulous hand. I suggest you turn back - unless, of course, you'd like to see firsthand what happens when Genius meets the chaos of unrestrained experimentation.
Proceed carefully, captain - nor that you'll enjoy the surprises I've left behind. Trust me, your reputation as a daring explorer is about to get an upgrade. Or a spectacular failure. Either way, it'll be memorable.]]),
		_([[Welcome, welcome!
I see you're curiosity has brought you into my little playground. Just so you know, I've activated a fine collection of my latest - oh, let's call them 'defensive' minefield. Each one a sparkling piece of engineering genius, now eager to play with your ship.
Consider this a friendly warning - turn back now, or I'll send your vessel a little gift wrapped in advanced targeting. It's all quite... precise.
My reputation's on the line, and I do love a good reputation. So do yourself a favor and consider this your last polite offer before I turn your patrol into a fireworks show. Trust me, I don't like to waste my inventions - so I suggest you make your move wisely.]]),
		},
		conflictCriminals = {
		_([[Captain, looks like you stumbled right into the middle of a mess. A few factions are tearing this system apart, and there's profit to be had if you pick a side. We say join us - better to be on the winning end of the deal than floating wreckage. What do you say? We can make this worth your while... but make no mistake, hesitation has its price.]]),
		_([[Hey, Captain! Looks like you dropped into a hell of a scrap. Best bet? Pick a side quick and make some credits while you're at it. We don't do courtesy calls - just business. You with us, or you just another target? Think fast.]]),
		},
		hiddenArtifact = {
		_([[Greetings, Captain. You have approached a mining operation within this area of space. Our crews are currently engaged in extensive operations, including a careful search for a high-value artifact recently detected in the belt. We welcome your presence and cooperation, as station security and safe passage benefit all in this contested area. Maintaining open communication ensures mutual benefit and continued prosperity for all parties involved.]]),
		_([[Greetings, Captain. We are currently conducting extraction operations within this asteroid belt and searching for a valuable artifact rumored to be hidden nearby. Our crews keep a sharp eye on any approaching vessels - expecting no trouble, but ready for it.]]),
		_([[Greetings, Captain. Recent reports indicate increased pirate activity in the sector. We advise caution in your travels. Our crews continue extraction operations nearby and maintain vigilance against threats. Trust that your reputation as a capable navigator will serve you well in these troubled areas of space.]]),
		},
		collapseArtifact = {
		_([[Captain, we are an independent science station.
We have detected your approach toward the black hole contained by an ancient artifact. Please be advised: the artifact stabilizes the black hole, preventing collapse. Should the containment fail, the resulting collapse could produce catastrophic gravitational effects in this region. Your vessel's systems and trajectory may experience severe disruptions. We trust your expertise to navigate these dangers with due caution.]]),
		_([[Captain, we are an independent science station.
Be aware, the black hole you approach is contained by an artifact preventing its collapse. If containment falters, the resulting collapse would unleash powerful gravitational forces capable of severe damage to nearby vessels. Your ship may encounter unpredictable spatial distortions or system failures. Proceed with caution and vigilance.
		]]),
		_([[Captain, caution advised.
The black hole ahead is contained by a powerful artifact. Should this containment fail, expect significant gravitational disruption. Your vessel risks exposure to intense spatial forces capable of compromising operational integrity. Maintain alertness and prepare for rapid response to abnormal conditions.]]),
		},
		nebulaCoolantGain = {
		_([[Hey there, Captain. You're heading into some nebulae that are perfect for topping up your coolant. No catch - just a friendly heads-up from a station that's seen its share of ships make the run. If you need supplies or a quick deal, you know where to find us. Safe travels out there.]]),
		_([[Captain, you're entering nebulae rich in coolant. That fluid is ours, and we don't take kindly to strangers using it for free. If you want a share, be ready to defend yourself. Don't mistake our patience for weakness.]]),
		},
		nebulaCoolantDrain = {
		_([[Captain, you've got a heads-up: those nebulae ahead will play havoc with your cooling systems. Best keep an eye on your temps or things could get messy.]]),
		_([[Hey captain, just so you know, that nebula up ahead messes with cooling systems - your ship's gonna feel the heat. Watch your gauges, no need to make trouble when that little info could save your hull.]]),
		},
		instableWormhole = {
		_([[Captain, you're approaching an unstable wormhole. It can be passed, but expect complications along the way. Just thought you should know before you get too close. Keep your crew sharp and your ship ready - this won't be a simple trip.]]),
		_([[Captain, the wormhole ahead is navigable. Passage is possible; however, it carries inherent risks and unpredictable complications. Proceed with full awareness of potential challenges. Maintain vigilance and preparedness for any anomalies encountered.]]),
		},
	}
	self.effectIndex = {}
end

function vf_comms_call_to_action:selectMessage(id)
	assert(self.randomEffects[id] ~= nil)
	if self.effectIndex[id] == nil or self.effectIndex[id] >= #self.randomEffects[id] then
		self.randomEffects[id] = arrayShuffle(self.randomEffects[id])
		self.effectIndex[id] = 1
	else
		self.effectIndex[id] = self.effectIndex[id] + 1
	end
	return self.randomEffects[id][self.effectIndex[id]]
end

function vf_comms_call_to_action:call_to_action(source, radius, messageId, use_direct_message)
	local message, debug
	if use_direct_message then
		message = messageId
		debug = string.format("(custom message) from %s %s in %s", source:getFaction(), source:getCallSign(), source:getSectorName())
	else
		debug = string.format("%s from %s %s in %s", messageId, source:getFaction(), source:getCallSign(), source:getSectorName())
		message = self:selectMessage(messageId)
	end
	local cta = {
		source = source,
		radius = radius,
		message = message,
		countdown = 0,
		debug = debug
	}
	log("schedule cta", debug)
	table.insert(self.ctas, cta)
	return cta
end

function vf_comms_call_to_action:replace_message_placeholders(msg, source, target)
	msg = string.gsub(msg, "{callsign}", source:getCallSign())
	msg = string.gsub(msg, "{sector}", source:getSectorName())
	msg = string.gsub(msg, "{faction}", source:getFaction())
	msg = string.gsub(msg, "{zone}", source.called_zone_name or "")
	msg = string.gsub(msg, "{distance}", distance(source, target))
	msg = string.gsub(msg, "{direction}", angleHeading(target, source))
	return msg
end

function vf_comms_call_to_action:update(dt)
	-- cta sources try to contact player ships within their comms radius
	local players = getActivePlayerShips()
	arrayFilter(self.ctas, function(cta)
		return cta.source ~= nil and cta.source:isValid()
	end)
	for idx,cta in ipairs(self.ctas) do
		if cta.countdown > 0 then
			cta.countdown = cta.countdown - dt
		else
			for __,ship in ipairs(players) do
				if distance(cta.source, ship) <= cta.radius then
					if cta.source:sendCommsMessageNoLog(ship, self:replace_message_placeholders(cta.message, cta.source, ship)) then
						-- ship was hailed, but can choose to ignore
						local arc = angleHeading(ship, cta.source)
						ship:addToShipLog(string.format(_("Received transmission from %s from direction %i"), cta.source:getCallSign(), math.floor(arc)), "cyan")
						log(string.format("opening comms to %s:", ship:getCallSign()), cta.debug)
						table.remove(self.ctas, idx)
						return
					else
						-- ship could not be hailed
						-- no log entry is written
						-- try other ships and schedule a retry in 30 sec
						cta.countdown = 30
					end
				end
			end
		end
	end
end
