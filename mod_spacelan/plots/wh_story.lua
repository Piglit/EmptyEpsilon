--[[
Adds environmental story to the scenario via collectable artifacts. There are about 40 artifacts.
Depends on artifacts
--]]

wh_story = {}

function wh_story:init()
-- captured artifacts are popped from the end to the beginning of the table!
--	wh_artifacts:addGenericInfo("Logbook -", "Last log entry of the Human Navy '':\n''")

--	wh_artifacts:addGenericInfo("", "")

	wh_artifacts:addGenericInfo("Kraylor Supply Vehice", "This destroyed Kraylor vehicle contains supplies for a station, so that the station can supply a small fleet of Kraylor ships.")
	wh_artifacts:addGenericInfo("Exuari Comms Manual", "This manual instructs: \nAlways start a message with the ship type of your ship followed by your callsign. When referring to another ship always use the type name before the callsign, followed by their sector coordinates.")
	wh_artifacts:addGenericInfo("Kraylor Captains Guide", "This guide contains instructions for Kraylor dreadnought captains:\n'Your target is an Arlenian station. Conquer it as quick as possible. If something attacks you on your way, use your drones to distract the enemy. If you fail to conquer the station, it is well-defended and we must respect the enemies strength - so every station shall be only attacked once.'")
	wh_artifacts:addGenericInfo("Logbook M-1122", "Last log entry of the defiled Kraylor dreadnought 'Helluva':\n'After a great battle against the Ktlitans we are about to be defeated. The sector is lost for the empire for now. The Ktlitans will convert the system to a breeding ground making space travel impossible. After they hatch, the empire will likely challenge their offspring and conquer the remaining infrastructure.'")
	wh_artifacts:addGenericInfo("Exuari Code Book", "The Exuari code book suggests using a known key to encode messages by adding the letters of the key to the letters of the message. To decipher the message, one would have to subtract the letters of the key from each letter of the message. Unfortunately no key is used in that code book.")
	wh_artifacts:addGenericInfo("Kraylor Wormhole Beacon", "This beacon was used as a target for one of the Kraylor wormhole drives. With that, the Kraylor could transfer a small fleet over vast distances to this position. However the beacon appears to be quite power hungry, when used.")
	wh_artifacts:addGenericInfo("Logbook R-3147", "Last log entry of broken the Human Navy strike ship 'Roadkill':\n'Those independent stations around here must have some secret to be spared of the locust's aggression. They belonged to the Kraylor Empire some time ago - maybe the Ktlitans liberated them?'")
	wh_artifacts:addGenericInfo("Codebreaker Device", "This device was used to decipher encrypted communications. Only the part that detects encrypted ship callsigns in messages seems to be intact. It counted the amount of letters of a known callsign and found words in the encrypted text that matched that amount of letters.")
	wh_artifacts:addGenericInfo("Logbook B-8563", "Last log entry of the impaired Human Navy battlecruiser 'Battlecow Muhlactica':\n'Entered Wormhole space. We were ready to fight the Kraylor, but there are Ktlitan locusts everywhere. Our EMPs can not harm them. We are getting swarmed!'")
	wh_artifacts:addGenericInfo("Subspace Tap Device", "A device that taps into a subspace communication frequency used by the Exuari. However, the received Exuari communication seems to be encrypted somehow.")
	wh_artifacts:addGenericInfo("Logbook Y-6871", "Last log entry of the forsaken cultist shuttle 'Ybb Tstrll':\n'No queen or other ships of the Ktlitan hive hierarchy. Only locusts. Crews in hibernation? Awake whenever a ship approaches. Can we wake them all and become their queen?'")
	wh_artifacts:addGenericInfo("Kraylor Commander Guide", "This guide contains instructions for Kraylor cruiser commanders:\n'Your battle squadron will consist of one dreadnought and a few cruisers. The cruisers are to follow the dreadnought, even if the dreadnought uses a jump drive. If the dreadnought is destroyed, you are to attack the nearest target and capture as many stations as you can.'")
	wh_artifacts:addGenericInfo("Demolished Space-Taxi", "There must have been more Space-Taxis around, before the locust infestation. There are probably some passengers waiting on the stations in this system, waiting for their transport.")
	wh_artifacts:addGenericInfo("Wreck of a Freighter", "An Arlenian freighter was transporting mineral goods to some station. Probably some of the stations systems are offline, because they are still waiting for their delivery.")
	wh_artifacts:addGenericInfo("Logbook A-3871", "Last log entry of the deserted independent light cruiser 'Ambition':\n'We have never seen locusts in the Ktlitan reservoirs. They must have built them during or after the great battle with the Kraylor.'")
	wh_artifacts:addGenericInfo("Xenobiologist Handbook", "From the handbook of Manny the xenobiologist:\n'Ktlitans use movement patterns to communicate. That applies also to their ships - we once circled a Ktlitan drone until it docked with us and moved our ship through space. However, we were not able to reproduce that behaviour.'")
	wh_artifacts:addGenericInfo("Logbook W-3314", "Last log entry of the demolished Human Navy cruiser 'Wolverine':\n'Tactical analysis of locust movement pattern: Rotation occurs only when no target is within 3U of them. Persistent lateral movement should allow to avoid them at all.'")
	wh_artifacts:addGenericInfo("Comms Buoy", "The Arlenian communications buoy still has a message in it's buffer:\n'To all ships: Due to the locust infestation, space travel is prohibited in this system. All ships are to retreat to the nearest station and stay there until the infestation is over.'")
	wh_artifacts:addGenericInfo("Logbook D-6188", "Last log entry of the abandoned independent science vessel 'Determinist':\n'The hive has come to a rest. The battle ships have left the system after defeating the Kraylor. Only locusts were left behind. We do not yet know their purpose.'")
	wh_artifacts:addGenericInfo("Broken Transporter", "A tansport ship of Arlenian design got eaten by Ktlitan beam fire. The cargo is mostly intact, it looks like the fire was concentrated on the drive.")
	wh_artifacts:addGenericInfo("Logbook L-1632", "Last log entry of the wrecked independent scout 'Little Rascal':\n'Ktlitan ships communicate via their 'dance pattern' movements. The key to understanding them is to study their movement behaviour. We could confirm, that a frontal approach is seen as a provocation.'")
	wh_artifacts:addGenericInfo("Ruined Beacon", "A decoy beacon of Arlenian design was ruined by Ktlitan beam weapons.")
	wh_artifacts:addGenericInfo("Logbook I-1678", "Last log entry of the ruined Human Navy light cruiser 'Indiskretion':\n'Those Ktlitan locusts look like drones. They're very fast. Individually, they should be easy to handle. As a group, they could be a problem.'")
	wh_artifacts:addGenericInfo("Derelict Shuttle", "A derelict shuttle of Arlenian design shows signs of damage by Ktlitan beam weapons.")
	wh_artifacts:addGenericInfo("Logbook N-9733", "Last log entry of the derelict Human Navy scout 'Nudelsuppe':\n'Our sensors have picked up approximately one hundred and fifty Ktlitan ships. The computer calls them locusts. We will approach one.'")
end

--[[ during campaign the following artifacts could be captured:
"Espionage Device", "This Exuari-made device transmitted a signal, whenever a ship entered this sector."
"Pirate Beacon", "A beacon transmitted a signal, that attracted a group of pirate mercenaries. The beacon appears to be Exuari-made."
"Exuari Warp Drive", "This warp drive was fitted in an Exuari ship. The drive was powering up when the ship was destroyed, which would have escaped if it weren't destroyed in time. Exuari sometimes use warp drives to ambush their enemies or to escape quickly with valuable cargo."
"Broken Exuari Bomber", "A derelict Exuari ship of the 'Ranger' class. One missile of it's arsenal of small nuclar warheads is still stuck in the torpedo tube together with an Exuari technician burned to death by the missiles exhaust plume."
"Kraylor Jump Drive", "A powerfull jump drive, that creates short lived ship-sized wormholes a Kraylor dreadnought can travel through. The calculations where the target wormhole appears are complicated and erratic, so the hightest save jump distance is limited to about 15U."
"Escape Pod", "An escape pod from a destroyed Human Navy station. The station crew managed to evacuate the station just in time and so they could be rescued when a brave Human Navy ship finally arrived."
"Black Hole Orbiter", "A bunch of space debris, trapped near the event horizon of a black hole. It was in range of the gravitational pull of the black hole, but it's speed was sufficient to keep it in a stable orbit."
"Valuable Minerals", "A patch of valuable minerals from one of our mining posts, that some Kraylor pirates were after."
--]]
