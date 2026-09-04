"""This file contains campaign specific infos"""
import core
import models.crew
import models.scenario
import models.campaign
import outbound.stationsComms
import outbound.pyroMessage
from utils import lua
from interfaces import storage
import json
import string
from datetime import datetime, timedelta
from threading import Timer



# load scenarios, that should be available in the campaign.
# use the complete filename without the folder.
scenarios = [
	"scenario_20_training1.lua",
	"scenario_00_basic.lua",
	"scenario_21_training2.lua",
	"scenario_26_specialist_training.lua",
	"scenario_03_waves.lua",
	# special missions:
	"scenario_01_outpost.lua",		# easier than surrounded
	"scenario_02_surrounded.lua",
	"scenario_05_beacon.lua",		# unlocks exuari waves if progress<100%
	"scenario_06_edgeofspace.lua",	# unlocks kraylor waves if progress<100%
	"scenario_07_gftp.lua",			# if not artifact: unlock ghost wave
	"scenario_08_atlantis.lua",
	"scenario_99_vf.lua",
]

campaign = models.campaign.Campaign(scenarios) 

def bescheid(what, callsign=None, mission=None):
	now = datetime.datetime.now()
	time = f"{now.hour}:{now.minute}"
	details = '{' + f'time = "{time}",'
	if callsign:
		details += f' callsign = "{lua.sanitize_lua_string(callsign)}",'
	if mission:
		details += f' callsign = "{lua.sanitize_lua_string(mission)}",'
	details += '}'
	script = f"""return getScriptStorage().vf_bescheid:sag_bescheid("{what}", {details})"""
	print(script)
	lua.exec(lua.sanitize_lua_string(script), server="192.168.2.4:8080")


# best progress [0,100] of a played scenario times this factor results in the multiplayer rep bonus.
# uses scriptId
campaign.setReputationFactor("20_training1", 0.25)
campaign.setReputationFactor("00_basic", 0.5)
campaign.setReputationFactor("03_waves", 10) # 10 per wave per difficulty


fleetcommand_name = storage.loadInfo("fleetcommand_name") # or None if not found

briefing = """Willkommen, Crew der {crew_name}.

Dies ist euer Missionsauswahlbildschirm. Hier werden alle für euch verfügbaren Missionen angezeigt werden. Momentan steht euch nur eine einzelne Trainingsmission zur Verfügung, die dazu da ist, damit ihr euch ein wenig auf einander einspielen können.

Weitere Missionen könnt ihr vom Flottenkommando bekommen.
"""
#Wenn ihr eine Mission abschließt (oder auch nur größtenteils abschließt), werden weitere Missionen für euch verfügbar.
campaign.setDefaultCrewTemplate(["20_training1"], ["Phobos M3P"], briefing)

#def cypher(text, key):
#	result = ""
#	key = key.lower()
#	for index,char in enumerate(text):
#		key_index = index % len(key)
#		key_char = key[key_index]
#		key_ord = ord(key_char) - ord("a")
#		if char in string.ascii_lowercase:
#			char = ord(char) + key_ord
#			if char > ord("z"):
#				char -= 26
#			char = chr(char)
#		elif char in string.ascii_uppercase:
#			char = ord(char) + key_ord
#			if char > ord("Z"):
#				char -= 26
#			char = chr(char)
#		elif char in string.digits:
#			char = ord(char) + key_ord
#			while char > ord("9"):
#				char -= 10
#			char = chr(char)
#		result += char
#	return result


#def unlockAtlantis(crew):
#	crew.unlockShip("Atlantis")
#	crew.unlockScenario("21_training2", settings={"Ships": ["Corvettes"]})

def scenario_event(scenario: models.scenario.Scenario, crew: models.crew.Crew, event_topic: str, details=str):
	global fleetcommand_name

	# for all scenarios
	if event_topic == "artifact":
		artifact = json.loads(details)
		if not crew.hasArtifact(details):
			# append to current briefing. This gets overwritten by other setBriefing calls.
			crew.setBriefing(crew.getBriefingRaw() + f"""
Ihr habt in dieser Mission das Artefakt '{artifact['name']}' eingesammelt. 
Gesammelte Artefakte können in einer späteren Mission an Raumstationen eingesetzt werden, um diese Stationen mit Upgrades zu versorgen.
Jede Mission enthält ein Missions-spezifisches Artefakt. Das gleiche Artefakt mehrfach einzusammeln bringt keine Vorteile; jedes Artefakt kann nur einmal eingesetzt werden.
""")
		if artifact['collected'] == True:
			bescheid("first_artifact_gathered", callsign=crew.name)
		elif artifact['collected'] == False:
			bescheid("first_artifact_destroyed")

	progress = campaign.scenario_event(scenario, crew, event_topic, details)
	# progress can be None, if the event was not progress-related

	s = scenario.scriptId

	# scenario specific
	if s == "20_training1":
		if progress is not None and progress >= 75 and not crew.isScenarioUnlocked("00_basic"):
			if crew.profile == "beginner":
				difficulties_available = ["Easy"]
			elif crew.profile == "veteran":
				difficulties_available = ["Hard"]
			else:
				difficulties_available = ["Normal"]
			crew.unlockScenario("00_basic", settings={"Time": ["30min"], "Enemies": difficulties_available})
			crew.setBriefing("""Glückwunsch, {crew_name}.

Euch steht eine neue Mission zur Auswahl:
In 'Skirmish' könnt ihr euer Können gegen angreifende Gegner testen.
Falls ihr euch anders auf die Stationen eures Schiffs verteilen wollt, könnt ihr auch die gerade absolvierte Trainingsmission wiederholen.

Ihr könnt jederzeit weitere Missionen vom Flottenkommando anfragen.
""")

	if s == "00_basic":
		if progress is not None and progress > 0:
			crew.unlockScenario("00_basic", settings={"Enemies": ["Easy", "Normal", "Hard", "Extreme"]})
			if "Schwierigkeitsgrad" not in crew.getBriefingRaw():
				crew.setBriefing("""Willkommen zurück, {crew_name}.

Die aktuelle Mission 'Skirmish' kann auf verschiedenen Schwierigkeitsgraden wiederholt werden.
Ein höherer Schwierigkeitsgrad sorgt für einen höheren Reputations-Bonus: Ihr werdet alle künftigen Missionen mit diesem Bonus auf eure Reputation beginnen. 

Der Reputations-Bonus ergibt sich aus dem gewählten Schwierigkeitsgrad und dem dabei erreichten Missionsfortschritt. Wird ein Szenario häufiger gespielt, gilt der höchste erreichte Reputations-Bonus. Diesen könnt ihr in der Punkteübersicht einsehen.
""")
#			if progress >= 75:
#				if crew.profile == "beginner":
#					if not crew.isScenarioUnlocked("06_edgeofspace"):
#						crew.unlockScenario("06_edgeofspace", settings={"Chapter": ["Beginning"]})
#						crew.setBriefing(crew.getBriefingRaw() + """
#Euch steht nun eine weitere Mission zur Verfügung.""")
#				elif crew.profile == "veteran":
#					if not crew.isScenarioUnlocked("07_gftp"):
#						crew.unlockScenario("21_training2")
#						crew.unlockScenario("07_gftp")#, settings={"Chapter": ["Beginning"]})
#						crew.setBriefing(crew.getBriefingRaw() + """
#Euch stehen nun weitere Missionen zur Verfügung:
#In 'Frigates Testing Ground' könnt ihr andere (spezialisierte) Schiffe ausprobieren.
#In 'Ghosts from the past' lies some challenge.
#""")
#				else:
#					if not crew.isScenarioUnlocked("21_training2"):
#						crew.unlockScenario("21_training2", settings={"Ships": ["Frigates"]})
#						crew.unlockScenario("08_atlantis", settings={"Chapter": ["Beginning"]})
#						crew.setBriefing(crew.getBriefingRaw() + """
#Euch stehen nun weitere Missionen zur Verfügung:
#In 'Frigates Testing Ground' könnt ihr andere (leichte und spezialisierte) Schiffe ausprobieren.
#In 'Birth of Atlantis' erhaltet ihr den Prototyp eines schweren Kreuzers.
#""")

	if s == "21_training2":
		if event_topic == "started":
			crew.setBriefing("""Willkommen zurück, {crew_name}.\n""")
		if event_topic == "unlockShip":
			ship = details
			if not crew.hasShip(ship):
				crew.unlockShip(ship)
				if "{ships}" not in crew.getBriefingRaw():
					crew.setBriefing(crew.getBriefingRaw() + """
Die in dieser Mission erfolgreich von euch verwendeten Schiffstypen stehen euch nun auch im 'Skirmish'-Szenario zur Verfügung. Dort habt ihr nun die Auswahl zwischen den folgenden Schiffstypen:
{ships}.
""")

	if s == "03_waves":
		if progress is not None and progress > 5:
			crew.unlockScenario("03_waves", settings={"Enemies": ["Easy", "Normal", "Hard"]})
			crew.setBriefing("""Willkommen zurück, {crew_name}.

Die aktuelle Mission 'Siege' kann auf verschiedenen Schwierigkeitsgraden wiederholt werden.
Ein höherer Schwierigkeitsgrad sorgt für einen höheren Reputations-Bonus: Ihr werdet alle künftigen Missionen mit diesem Bonus auf eure Reputation beginnen. 

Der Reputations-Bonus ergibt sich aus dem gewählten Schwierigkeitsgrad und dem dabei erreichten Missionsfortschritt. Wird ein Szenario häufiger gespielt, gilt der höchste erreichte Reputations-Bonus. Diesen könnt ihr in der Punkteübersicht einsehen.
""")

#	if s == "06_edgeofspace":
#		if progress is not None and progress > 50:
#			# wartime
#			crew.lockScenario("06_edgeofspace")
#			crew.unlockScenario("03_waves", settings={"Enemy Faction": ["Kraylor"], "Enemies": ["Easy", "Normal"]})
#			if progress == 100:
#				crew.lockScenario("03_waves")
#				crew.setBriefing("""Großartige Leistung {crew_name}!
#Nach diesem Gefecht sollten die Kraylor erheblichen Respekt vor uns zeigen.
#
#Ihr solltet nun mit dem Flottenkommando in Kontakt treten, um gemeinsam euer weiteres Vorgehen zu planen.""")
#			else:
#				brief = ""
#				if progress > 75:
#					brief = """Willkommen zurück, {crew_name}.
#Nach diesem Grenzkonflikt machten sich die übrigen Kraylor-Streitkräfte auf den Weg, um ihren Angriff auf unsere Systeme fortzuführen."""
#				else:
#					brief = """Warnung: die Waffenruhe mit den Kraylor hat ein Ende gefunden.
#Ermutigt durch ihren Sieg machen weitere Kraylor Streitkräfte mobil und nähern sich unseren Systemen!"""
#				brief += """
#
#Die Mission 'Siege' ist nur für euch verfügbar, {crew_name}.
#Bevor ihr jedoch eine weitere Mission beginnt, solltet ihr mit dem Flottenkommando in Kontakt treten, um das weitere Vorgehen zu planen."""
#				crew.setBriefing(brief)
#	
#	if s == "05_beacon":
#		if progress is not None and progress >= 75:
#			#unlockAtlantis(crew)
#			crew.lockScenario("05_beacon")
#			crew.unlockScenario("03_waves", settings={"Enemy Faction": ["Exuari"], "Enemies": ["Easy", "Normal"]})
#			if progress == 100:
#				crew.lockScenario("03_waves")
#				crew.setBriefing("""Großartige Leistung {crew_name}!
#Nach der Zerstörung dieses Exuari-Trägerschiffs sollten wir die Oberhand über die Exuari in nahen Sektoren behalten.
#
#Der gerade verwendete Schiffstyp 'Atlantis' ist in kampfbasierten Missionen für euch verfügbar. Desweiteren könnt ihr im 'Frigates Testing Ground' nun weitere schwere Schiffstypen testen.
#
#Ihr solltet nun mit dem Flottenkommando in Kontakt treten, um gemeinsam euer weiteres Vorgehen zu planen.""")
#			else:
#				crew.setBriefing("""Willkommen zurück, {crew_name}.
#Nach der Entdeckung des Exuari-Trägerschiffs hat sich dieses aus dem Sektor zurückgezogen.
#Wir vermuten, dass es bald ein anderes unserer Systeme angreifen wird.
#
#Der gerade verwendete Schiffstyp 'Atlantis' ist in kampfbasierten Missionen für euch verfügbar. Desweiteren könnt ihr im 'Frigates Testing Ground' nun weitere schwere Schiffstypen testen.
#
#Die Mission 'Siege' ist nur für euch verfügbar, {crew_name}.
#Bevor ihr jedoch eine weitere Mission beginnt, solltet ihr mit dem Flottenkommando in Kontakt treten, um das weitere Vorgehen zu planen.""")
#
#	if s == "07_gftp":	# TODO test this
#		if progress is not None and progress >= 90:
#			#unlockAtlantis(crew)
#			crew.lockScenario("07_gftp")
#			crew.unlockScenario("03_waves", settings={"Enemy Faction": ["Ghosts"], "Enemies": ["Easy", "Normal"]})
#			if progress == 100:
#				crew.lockScenario("03_waves")
#				crew.setBriefing("""Großartige Leistung {crew_name}!
#Mit diesem Sieg sollten wir bis auf weiteres sicher sein.
#
#Der gerade verwendete Schiffstyp 'Atlantis' ist in kampfbasierten Missionen für euch verfügbar. Desweiteren könnt ihr im 'Frigates Testing Ground' nun weitere schwere Schiffstypen testen.
#
#Ihr solltet nun mit dem Flottenkommando in Kontakt treten, um gemeinsam euer weiteres Vorgehen zu planen.""")
#			else:
#				crew.setBriefing("""Willkommen zurück {crew_name}!
#Nach der Entdeckung einer abtrünigen KI entsendet sie nun die von ihr übernommenen Schiffe unserer Flotte gegen unsere eigenen Systeme!
#
#Der gerade verwendete Schiffstyp 'Atlantis' ist in kampfbasierten Missionen für euch verfügbar. Desweiteren könnt ihr im 'Frigates Testing Ground' nun weitere schwere Schiffstypen testen.
#
#Die Mission 'Siege' ist nur für euch verfügbar, {crew_name}.
#Bevor ihr jedoch eine weitere Mission beginnt, solltet ihr mit dem Flottenkommando in Kontakt treten, um das weitere Vorgehen zu planen.""")
#
#	if s == "08_atlantis":	# TODO test this
#		if progress is not None and progress >= 45:
#			#unlockAtlantis(crew)
#			crew.lockScenario("08_atlantis")
#			crew.unlockScenario("03_waves", settings={"Enemy Faction": ["Kraylor"], "Enemies": ["Easy", "Normal"]})
#			if progress == 110:
#				crew.lockScenario("03_waves")
#				crew.setBriefing("""Großartige Leistung {crew_name}!
#Nach diesem Gefecht sollten die Kraylor erheblichen Respekt vor uns zeigen.
#
#Der gerade verwendete Schiffstyp 'Atlantis' ist in kampfbasierten Missionen für euch verfügbar. Desweiteren könnt ihr im 'Frigates Testing Ground' nun weitere schwere Schiffstypen testen.
#
#Ihr solltet nun mit dem Flottenkommando in Kontakt treten, um gemeinsam euer weiteres Vorgehen zu planen.""")
#			else:
#				crew.setBriefing("""Willkommen zurück {crew_name}!
#
#Der gerade verwendete Schiffstyp 'Atlantis' ist in kampfbasierten Missionen für euch verfügbar. Desweiteren könnt ihr im 'Frigates Testing Ground' nun weitere schwere Schiffstypen testen.
#
#Die Mission 'Siege' ist nur für euch verfügbar, {crew_name}.
#Bevor ihr jedoch eine weitere Mission beginnt, solltet ihr mit dem Flottenkommando in Kontakt treten, um das weitere Vorgehen zu planen.""")
#
	if event_topic == "fleetcommand-spawned":
		fleetcommand_name = details
		storage.storeInfo(details, "fleetcommand_name")
		outbound.stationsComms.subscribe_comms_log(crew.instance_name, details)
	elif event_topic == "fleetcommand-deleted":
		outbound.stationsComms.unsubscribe_comms_log()
	elif event_topic == "fernschreiber":
		outbound.pyroMessage.send("Fernschreiber", details)
#	elif event_topic == "exuari-comms":
#		msg = details
#		chiffre = cypher(msg, "exuari")
#		msg = "Aufgefangene Subraum-Übertragung:\n\n"+chiffre
#		outbound.pyroMessage.send("Fernschreiber", msg)
#	elif event_topic == "kraylor-comms":
#		msg = details
#		msg = "Aufgefangene Subraum-Übertragung:\n\n"+msg
#		outbound.pyroMessage.send("Fernschreiber", msg)
#	elif event_topic == "turn":
#		duration = int(details)
#		until = datetime.now() + timedelta(seconds=duration)
#		until_human = until.strftime("%H:%M:%S")
#		outbound.stationsComms.turntime(f"Nächste Flottenbesprechung um {until_human}")
#		Timer(duration-5*60, outbound.stationsComms.turnwarning).start()
#	elif event_topic == "pause":
#		duration = int(details)
#		until = datetime.now() + timedelta(seconds=duration)
#		until_human = until.strftime("%H:%M:%S")
#		outbound.stationsComms.turntime(f"Flottenbesprechung bis {until_human}")
	elif event_topic == "reinforcenemts":
		details = json.loads(details)
		crew.setProxyOpen(details["allow"])
	
	if event_topic in ["started", "quit", "victory", "defeat", "end", "joined"]:
		crew.setProxyOpen(False)

	if event_topic == "started":
		bescheid("first_mission_started", callsign=crew.name, mission=scenario.name)

	if event_topic == "victory":
		bescheid("first_mission_finished", callsign=crew.name, mission=scenario.name)

core.subscribe("scenario_event", scenario_event)


#campaign.test_run()



# Crews 2026:
# Spacy 6, beginner, Light Cruiser
# Honeybadger 6, experienced, Mine-Layer

# Regenbogenpony 6, veteran, ? -> Atlantis?
# Miris Schiff 5+, experienced ? -> Maverick?

# Brassheart 5, experiences, ? Hathcock
# Melonidas 5, veteran, Crucible?? / Piranha
# Kraken 5, experienced, ? Piranha
# Trancerapid 5, experienced -> Hathcock

# Kestrel 4, beginner, Kestrel / Scout?

# Scenarios:
# invade: pairings: Heavy + Light:
# Maverick + Piranha
# Crucible + Hathcock
# Atlantis + Adder
# Mine-Layer, Kestrel, Phobos(warp) ? 
