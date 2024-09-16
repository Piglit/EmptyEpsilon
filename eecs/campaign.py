"""This file contains campaign specific infos"""
import core
import models.crew
import models.scenario
import outbound.stationsComms
import outbound.pyroMessage
from interfaces import storage
import json
import string
from datetime import datetime, timedelta
from threading import Timer

# load scenarios, that should be available in the campaign.
# use the complete filename without the folder.
models.scenario.loadScenarios([
	"scenario_20_training1.lua",
	"scenario_00_basic.lua",
	"scenario_21_training2.lua",
	"scenario_03_waves.lua",
	# special missions:
	"scenario_01_outpost.lua",		# easier than surrounded
	"scenario_02_surrounded.lua",
	"scenario_05_beacon.lua",		# unlocks exuari waves if progress<100%
	"scenario_06_edgeofspace.lua",	# unlocks kraylor waves if progress<100%
	"scenario_07_gftp.lua",			# if not artifact: unlock ghost wave
	"scenario_08_atlantis.lua",

	"scenario_99_wormhole_expedition.lua",
])

# best progress [0,100] of a played scenario times this factor results in the multiplayer rep bonus.
# uses scriptId
SCENARIO_REPUTATION_FACTOR = {
	"20_training1":	0.25,
	"00_basic":		0.5,
	"03_waves":		10,	# 10 per wave per difficulty
}

fleetcommand_name = storage.loadInfo("fleetcommand_name") # or None if not found

briefing = """Willkommen, Crew der {crew_name}.

Dies ist euer Missionsauswahlbildschirm. Hier werden alle für euch verfügbaren Missionen angezeigt werden. Momentan steht euch nur eine einzelne Trainingsmission zur Verfügung, die dazu da ist, damit ihr euch ein wenig auf einander einspielen können.

Wenn ihr eine Mission abschließt (oder auch nur größtenteils abschließt), werden weitere Missionen für euch bereitgestellt.
"""
models.crew.setCrewTemplate(["20_training1"], ["Phobos M3P"], briefing)

def cypher(text, key):
	result = ""
	key = key.lower()
	for index,char in enumerate(text):
		key_index = index % len(key)
		key_char = key[key_index]
		key_ord = ord(key_char) - ord("a")
		if char in string.ascii_lowercase:
			char = ord(char) + key_ord
			if char > ord("z"):
				char -= 26
			char = chr(char)
		elif char in string.ascii_uppercase:
			char = ord(char) + key_ord
			if char > ord("Z"):
				char -= 26
			char = chr(char)
		elif char in string.digits:
			char = ord(char) + key_ord
			while char > ord("9"):
				char -= 10
			char = chr(char)
		result += char
	return result


def unlockAtlantis(crew):
	crew.unlockShip("Atlantis")
	crew.unlockScenario("21_training2", settings={"Ships": ["Corvettes"]})

def scenario_event(scenario: models.scenario.Scenario, crew: models.crew.Crew, event_topic: str, details=str):
	global fleetcommand_name
	s = scenario.scriptId 
	
	# update score and get progress
	progress = None
	rep_factor = SCENARIO_REPUTATION_FACTOR.get(s, 1.0)
	difficulty = crew.getScoreRaw("current").get("difficulty",1)	# current can be empty
	if event_topic == "score":
		details = json.loads(details)
		if "progress" in details:
			progress = details["progress"]
			difficulty = details.get("difficulty",difficulty)
			details["reputation"] = progress * rep_factor * difficulty
		crew.updateScore(s, details)
	elif event_topic == "progress":
		assert isinstance(details, dict)
		progress = details["progress"]
		crew.updateScore(s, {"progress": progress, "reputation": progress * rep_factor * difficulty})

	# for all scenarios
	elif event_topic == "started":
		crew.setBriefing("")
		crew.clearCurrentScore()
	elif event_topic == "artifact":
		artifact = json.loads(details)
		if not crew.hasArtifact(details):
			# append to current briefing. This gets overwritten by other setBriefing calls.
			crew.setBriefing(crew.getBriefingRaw() + f"""
Ihr habt in dieser Mission das Artefakt '{artifact['name']}' eingesammelt. 
Gesammelte Artefakte können in einer späteren Mission auf der Raumstation des Flottenkommandos """ +
				(json.dumps(fleetcommand_name) if fleetcommand_name else "\b") + """ abgegeben werden, um das Flottenkommando mit strategischen Informationen und Upgrades zu versorgen.
Jedes Szenario enthält ein Szenario-spezifisches Artefakt. Das gleiche Artefakt mehrfach einzusammeln bringt keine Vorteile; jedes Artefakt kann nur einmal beim Flottenkommando abgegeben werden.
""")
		crew.addArtifact(artifact["name"], artifact["description"])

	# requests
	elif event_topic == "request_reputation":
		if details:
			models.crew.getCrewByCallsign(details).sendReputation(server="localhost", reduce=True)	# XXX server is hacky
		else:
			crew.sendReputation()
	elif event_topic == "request_artifacts":
		assert isinstance(details, str)
		models.crew.getCrewByCallsign(details).sendArtifacts(server="localhost") # XXX server is hacky

	# scenario specific
	if s == "20_training1":
		if progress is not None and progress >= 75:
			crew.unlockScenario("00_basic", settings={"Time": ["30min"], "Enemies": ["Normal"]})
			crew.unlockScenario("21_training2", settings={"Ships": ["Frigates"]})
			crew.setBriefing("""Glückwunsch, {crew_name}.
Euch stehen weitere Missionen zur Auswahl:
In 'Skirmish' könnt ihr euer Können gegen angreifende Gegner testen.
In 'Frigates Testing Ground' könnt ihr andere (spezialisierte) Schiffe ausprobieren.

Ihr könnt euch nun euren Punktestand bei der gerade abgeschlossenen Missionen ansehen.
""")
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

	if s == "00_basic":
		if progress is not None and progress > 0:
			crew.unlockScenario("00_basic", settings={"Enemies": ["Easy", "Normal", "Hard", "Extreme"]})
			if "Schwierigkeitsgrad" not in crew.getBriefingRaw():
				crew.setBriefing("""Willkommen zurück, {crew_name}.

Die aktuelle Mission 'Skirmish' kann auf verschiedenen Schwierigkeitsgraden wiederholt werden.
Ein höherer Schwierigkeitsgrad sorgt für einen höheren Reputations-Bonus: Ihr werdet alle künftigen Missionen mit diesem Bonus auf eure Reputation beginnen. 

Der Reputations-Bonus ergibt sich aus dem gewählten Schwierigkeitsgrad und dem dabei erreichten Missionsfortschritt. Wird ein Szenario häufiger gespielt, gilt der höchste erreichte Reputations-Bonus. Diesen könnt ihr in der Punkteübersicht einsehen.
""")

	if s == "03_waves":
		if progress is not None and progress > 5:
			crew.unlockScenario("03_waves", settings={"Enemies": ["Easy", "Normal", "Hard"]})
			crew.setBriefing("""Willkommen zurück, {crew_name}.

Die aktuelle Mission 'Siege' kann auf verschiedenen Schwierigkeitsgraden wiederholt werden.
Ein höherer Schwierigkeitsgrad sorgt für einen höheren Reputations-Bonus: Ihr werdet alle künftigen Missionen mit diesem Bonus auf eure Reputation beginnen. 

Der Reputations-Bonus ergibt sich aus dem gewählten Schwierigkeitsgrad und dem dabei erreichten Missionsfortschritt. Wird ein Szenario häufiger gespielt, gilt der höchste erreichte Reputations-Bonus. Diesen könnt ihr in der Punkteübersicht einsehen.
""")

	if s == "06_edgeofspace":
		if progress is not None and progress > 50:
			# wartime
			crew.lockScenario("06_edgeofspace")
			crew.unlockScenario("03_waves", settings={"Enemy Faction": ["Kraylor"], "Enemies": ["Easy", "Normal"]})
			if progress == 100:
				crew.lockScenario("03_waves")
				crew.setBriefing(brief = """Großartige Leistung {crew_name}!
Nach diesem Gefecht sollten die Kraylor erheblichen Respekt vor uns zeigen.

Ihr solltet nun mit dem Flottenkommando in Kontakt treten, um gemeinsam euer weiteres Vorgehen zu planen.""")
			else:
				brief = ""
				if progess > 75:
					brief = """Willkommen zurück, {crew_name}.
Nach diesem Grenzkonflikt machten sich die übrigen Kraylor-Streitkräfte auf den Weg, um ihren Angriff auf unsere Systeme fortzuführen."""
				else:
					brief = """Warnung: die Waffenruhe mit den Kraylor hat ein Ende gefunden.
Ermutigt durch ihren Sieg machen weitere Kraylor Streitkräfte mobil und nähern sich unseren Systemen!"""
				brief += """

Die Mission 'Siege' ist nur für euch verfügbar, {crew_name}.
Bevor ihr jedoch eine weitere Mission beginnt, solltet ihr mit dem Flottenkommando in Kontakt treten, um das weitere Vorgehen zu planen."""
				crew.setBriefing(brief)
	
	if s == "05_beacon":
		if progress is not None and progress >= 75:
			unlockAtlantis(crew)
			crew.lockScenario("05_beacon")
			crew.unlockScenario("03_waves", settings={"Enemy Faction": ["Exuari"], "Enemies": ["Easy", "Normal"]})
			if progress == 100:
				crew.lockScenario("03_waves")
				crew.setBriefing("""Großartige Leistung {crew_name}!
Nach der Zerstörung dieses Exuari-Trägerschiffs sollten wir die Oberhand über die Exuari in nahen Sektoren behalten.

Der gerade verwendete Schiffstyp 'Atlantis' ist in kampfbasierten Missionen für euch verfügbar. Desweiteren könnt ihr im 'Frigates Testing Ground' nun weitere schwere Schiffstypen testen.

Ihr solltet nun mit dem Flottenkommando in Kontakt treten, um gemeinsam euer weiteres Vorgehen zu planen.""")
			else:
				crew.setBriefing("""Willkommen zurück, {crew_name}.
Nach der Entdeckung des Exuari-Trägerschiffs hat sich dieses aus dem Sektor zurückgezogen.
Wir vermuten, dass es bald ein anderes unserer Systeme angreifen wird.

Der gerade verwendete Schiffstyp 'Atlantis' ist in kampfbasierten Missionen für euch verfügbar. Desweiteren könnt ihr im 'Frigates Testing Ground' nun weitere schwere Schiffstypen testen.

Die Mission 'Siege' ist nur für euch verfügbar, {crew_name}.
Bevor ihr jedoch eine weitere Mission beginnt, solltet ihr mit dem Flottenkommando in Kontakt treten, um das weitere Vorgehen zu planen.""")

	if s == "07_gftp":	# TODO test this
		if progress is not None and progress >= 90:
			unlockAtlantis(crew)
			crew.lockScenario("07_gftp")
			crew.unlockScenario("03_waves", settings={"Enemy Faction": ["Ghosts"], "Enemies": ["Easy", "Normal"]})
			if progress == 100:
				crew.lockScenario("03_waves")
				crew.setBriefing("""Großartige Leistung {crew_name}!
Mit diesem Sieg sollten wir bis auf weiteres sicher sein.

Der gerade verwendete Schiffstyp 'Atlantis' ist in kampfbasierten Missionen für euch verfügbar. Desweiteren könnt ihr im 'Frigates Testing Ground' nun weitere schwere Schiffstypen testen.

Ihr solltet nun mit dem Flottenkommando in Kontakt treten, um gemeinsam euer weiteres Vorgehen zu planen.""")
			else:
				crew.setBriefing("""Willkommen zurück {crew_name}!
Nach der Entdeckung einer abtrünigen KI entsendet sie nun die von ihr übernommenen Schiffe unserer Flotte gegen unsere eigenen Systeme!

Der gerade verwendete Schiffstyp 'Atlantis' ist in kampfbasierten Missionen für euch verfügbar. Desweiteren könnt ihr im 'Frigates Testing Ground' nun weitere schwere Schiffstypen testen.

Die Mission 'Siege' ist nur für euch verfügbar, {crew_name}.
Bevor ihr jedoch eine weitere Mission beginnt, solltet ihr mit dem Flottenkommando in Kontakt treten, um das weitere Vorgehen zu planen.""")

	if s == "08_atlantis":	# TODO test this
		if progress is not None and progress >= 45:
			unlockAtlantis(crew)
			crew.lockScenario("08_atlantis")
			crew.unlockScenario("03_waves", settings={"Enemy Faction": ["Kraylor"], "Enemies": ["Easy", "Normal"]})
			if progress == 110:
				crew.lockScenario("03_waves")
				crew.setBriefing("""Großartige Leistung {crew_name}!
Nach diesem Gefecht sollten die Kraylor erheblichen Respekt vor uns zeigen.

Der gerade verwendete Schiffstyp 'Atlantis' ist in kampfbasierten Missionen für euch verfügbar. Desweiteren könnt ihr im 'Frigates Testing Ground' nun weitere schwere Schiffstypen testen.

Ihr solltet nun mit dem Flottenkommando in Kontakt treten, um gemeinsam euer weiteres Vorgehen zu planen.""")
			else:
				crew.setBriefing("""Willkommen zurück {crew_name}!

Der gerade verwendete Schiffstyp 'Atlantis' ist in kampfbasierten Missionen für euch verfügbar. Desweiteren könnt ihr im 'Frigates Testing Ground' nun weitere schwere Schiffstypen testen.

Die Mission 'Siege' ist nur für euch verfügbar, {crew_name}.
Bevor ihr jedoch eine weitere Mission beginnt, solltet ihr mit dem Flottenkommando in Kontakt treten, um das weitere Vorgehen zu planen.""")

	if event_topic == "fleetcommand-spawned":
		fleetcommand_name = details
		storage.storeInfo(details, "fleetcommand_name")
		outbound.stationsComms.subscribe_comms_log(crew.instance_name, details)
	elif event_topic == "fleetcommand-deleted":
		outbound.stationsComms.unsubscribe_comms_log()
	elif event_topic == "exuari-comms":
		msg = details
		chiffre = cypher(msg, "exuari")
		msg = "Wir haben eine Subraum-Übertragung aufgefangen:\n\n"+chiffre
		outbound.pyroMessage.send("Fernschreiber", msg)
	elif event_topic == "kraylor-comms":
		msg = details
		msg = "Wir haben eine Subraum-Übertragung aufgefangen:\n\n"+msg
		outbound.pyroMessage.send("Fernschreiber", msg)
	elif event_topic == "turn":
		duration = details
		until = datetime.now() + timedelta(seconds=duration)
		until_human = until.strftime("%H:%M:%S")
		outbound.stationsComms.turntime(f"Nächste Flottenbesprechung um {until_human}")
		Timer(duration-5*60, outbound.stationsComms.turnwarning).start()
	elif event_topic == "pause":
		duration = details
		until = datetime.now() + timedelta(seconds=duration)
		until_human = until.strftime("%H:%M:%S")
		outbound.stationsComms.turntime(f"Flottenbesprechung bis {until_human}")


core.subscribe("scenario_event", scenario_event)
