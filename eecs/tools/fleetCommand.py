#!/usr/bin/env python3
"""Dialog für das Flottenkommando. Erlaubt es, Schiffen Missionen zuzuweisen."""

import Pyro4
import json
from dialog import Dialog

crews = None
scenarios = None

d = Dialog(autowidgetsize=True)
d.set_background_title("Flottenkommando: Missionsverteilung")

def start():
	while True:
		code, tag = d.menu("Willkommen Flottenkommando", choices=[
			("Aufgaben", "Übersicht über die Abläufe und Aufgaben des Flottenkommandos"),
			("Missionen", "Übersicht über die verfügbaren Missionen"),
			("Mechaniken", "Übersicht über die Spielmechaniken der Kampagne"),
			("Crew: auf Mission schicken", "Lege fest, welche Missionen für welche Crew verfügbar sind."),
			("Crew: Schiff freischalten", "Lege fest, welche Schiffstypen für welche Crew verfügbar sind."),
	#		("", ""),
		])
		if code == d.OK:
			if tag == "Aufgaben":
				helpTasks()
			elif tag == "Missionen":
				helpMissions()
			elif tag == "Mechaniken":
				helpMechanics()
			elif tag == "Crew: auf Mission schicken":
				selectMissions()
			elif tag == "Crew: Schiff freischalten":
				selectShips()
		else:
			return

# Intro:
# Willkommen - Anleitung:
# -> Log Screen für Fortschritt der Crews
# -> Engineer für Upgrades
# -> Teilnehmerliste für Schiffsbelegung, Ränge und Beförderungen
# Hier: Crews Missionen zuweisen
# Continue

# TODO spellcheck

def helpTasks():
	d.msgbox("""Übersicht über die Abläufe und Aufgaben des Flottenkommandos:

1. Crewmitglieder kommen an:
	* Namensschilder verteilen, Crewmitglieder auf ihre Schiffe schicken, Liste abhaken.
	* Bei neuen Crewmitgliedern: Räumlichkeiten erklären (Bad, Küche, Kaffeeküche, Spacebar)
2. Crews machen ihre Schiffe einsatzfähig:
	* Spacebar für Hardwareausgabe muss besetzt sein.
3. Crews sind auf Trainingsmissionen:
	* Fortschritt der einzelnen Crews im Auge behalten.
	* Chatverbindung mit den Crews testen (am besten zwischen einzelnem Missionen).
	* Chat muss für Rückfragen von Crews besetzt sein.
4. Crews sind bereit für Einzelmissionen:
	* Zwei Repräsentanten jeder Crew als Ansprechpartner für das Flottenkommando bestimmen.
	* Essenszeiten absprechen (Einzelmissionen dauern üblicherweise über eine Stunde).
	* Die Crew auf eine Einzelmission schicken:
		* Eine Mission finden, welche die Crew noch nicht kennt.
		* Briefing an die Vertreter der Crew austeilen.
		* Die Mission über dieses Interface für die Crew freischalten.
5. Crews sind bereit für die Wurmloch-Expedition:
	* Repräsentanten der Crew zur nächsten Besprechung des Flottenkommandos einladen.
	* Schiffe der Crew über dieses Interface auf die Wurmloch-Expedition schicken.
	* Regelmäßige Besprechung mit allen Repräsentanten aller Crews, die auf der Wurmloch-Expedition sind.
""")

def helpMissions():
	d.msgbox("""Übersicht über die verfügbaren Missionen:

Trainingsmissionen:
* Basic Training Course: Einstiegsmission für alle Crews. Bei 75% Missionsfortschritt werden die beiden anderen Trainingsmissionen automatisch für diese Crew freigeschaltet.
* Skirmish: Kurze Kampfsimulation. Die Crew kann aus allen für sie freigeschalteten Schiffen wählen. Die Mission hat ein 30 Minuten Zeitlimit. Wird mindestens ein gegnerisches Schiff zerstört, kann die Mission auf unterschiedlichen Schwierigkeitsgraden wiederholt werden.
* Frigates Testing Ground: Verschiedene Schiffstypen können ausprobiert werden. Immer wenn ein gegnerisches Schiff zerstört wird, wird das aktuell von der Crew verwendete Schiff für zukünftige Kampfmissionen (Skirmish, Siege) für diese Crew automatisch freigeschaltet. Falls die Atlantis-Korvette durch eine Einzelmission für die Crew freigeschaltet wurde, können hier auch andere Korvetten getestet werden.
* Waves: Endlos-Kampfmission. Wird nach langen Einzelmissionen automatisch freigeschaltet.

Einzelmissionen (müssen vom Flottenkommando individuell freigeschaltet werden):
* Edge of Space: relativ einfache Mission für Einsteiger-Crews. Dauer > 1h.
* Beacon of Light: die diplomatische Mission für Crews mit etwas Erfahrung. Dauer > 1h. Schaltet Atlantis-Korvette frei.
* Ghosts from the Past: schwierige Mission für Crews mit Erfahrung. Dauer > 1h. Schaltet Atlantis-Korvette frei.
* Birth of Atlantis: einfache Mission für Crews mit etwas Erfahrung. Dauer > 1h. Schaltet Atlantis-Korvette frei.
* Outpost Defense: kurze kampfbasierte Mission für Crews mit etwas Erfahrung. Dauer: 15 min.
* Surrounded: kurze schwierige kampfbasierte Mission für Crews mit Erfahrung. Dauer: 15 min.

Wurmloch-Expedition:
* Das Szenario, in dem sich auch der Ball als Station befindet.
""")

def helpMechanics():
	d.msgbox("""Übersicht über die Spielmechaniken der Kampagne:

Reputation:
* Auf Trainings- und Einzelmissionen hat jede Crew ihr eigenes Reputations-Konto für die entsprechende Mission. Die Reputation zum Ende einer Mission wird nicht in die nächste übernommen.
* Während der Wurmloch-Expedition gibt es ein gemeinsames Reputations-Konto für die gesamte Flotte.

Reputations-Bonus:
* Wenn eine Crew von einer Trainings- oder Einzelmission zurück kehrt, erhält sie einen Reputations-Bonus abhängig vom erreichten Missionsfortschritt und dem gewählten Schwierigkeitsgrad (falls vorhanden).
* Wird eine Mission von der gleichen Crew öfters gespielt, gilt immer der höchste erreichte Reputations-Bonus der Mission.
* Der gesamte Reputations-Bonus einer Crew ergibt sich aus dem Reputations-Bonus aller von dieser Crew gespielten Missionen.
* Zu Beginn jeder Trainings- oder Einzelmission erhält die Crew ihren gesamten Reputations-Bonus als Start-Reputation für diese Mission.
* Stößt eine Crew zur Wurmlock-Expedition dazu, wird bei Ankunft des Schiffs der Reputation-Bonus der Crew zum Reputations-Konto der Flotte hinzugefügt.

Artefakte:
* In jeder Trainings- und Einzelmission ist ein Artefakt versteckt, dass von einer Crew gescannt und eingesammelt werden kann.
* Um ein Artefakt einzusammeln, muss die Einfangfrequenz ermittelt werden, und die Schilde des Schiffs auf diese Frequenz kalibriert werden. Dann kann das Artefakt mit aktivierten Schilden eingesammelt werden. Ist die Frequenz falsch, oder die Schilde deaktiviert, wird das Artefakt beim Einsammeln zerstört und hinterlässt Schaden am Schiff.
* Wird ein Artefakt eingesammelt, sind Details dazu im Schiffs-Log der Relay-Station zu sehen.
* Wurde ein Artefakt einer Mission einmal eingesammelt, bringt ein weiteres Einsammeln des selben Artefakts in einer Wiederholung der Mission keine Vorteile.
* Sobald ein Schiff auf der Wurmloch-Expedition an der Station des Flottenkommandos dockt, werden alle von der Crew gesammelten Artefakte automatisch übergeben.
* Jedes Artefakt, das dem Flottenkommando noch nicht von einer anderen Crew übergeben wurde, kann für Upgrades der Station verwendet werden.
* Jenseits des Wurmlochs in der Wurmloch-Expedition gibt es noch weitere Artefakte zu erbeuten.
""")

def selectCrew():
	global crews
	d.infobox("Lädt Crews...")
	if not crews:
		crews = Pyro4.Proxy("PYRONAME:campaign_crews")
	try:
		crews.ping()
	except:
		d.msgbox("Keine Verbindung zum Server. Versuche es in ein paar Sekunden nochmal.")
		return None
	instances = crews.list()
	if not instances:
		d.msgbox("Es sind noch keine Schiffe aktiv.")
		return None
	#maybe json.dumps(input)?
	menu_items = [(crew["crew_name"], crew['status']) for crew in instances.values()]
	for mi in menu_items:
		assert mi[0].isascii()
		assert mi[1].isascii()
	code, tag = d.menu("Select crew", choices=menu_items)
	if code == d.OK:
		d.infobox("Lädt Crew...")
		crew = crews.getCrewByName(tag)
		if not crew:
			d.msgbox("Konnte Crewdaten nicht aufrufen.")
			return None
		return crew
	return None

def crewDetails(crew):
	attrs = ["crew_name", "status", "scenarios", "ships", "artifacts"]
	msg = ""
	for key in attrs:
		val = crew[key]
		if isinstance(val, list):
			val = ", ".join(val)
		elif isinstance(val, dict):
			val = ", ".join(val)
		if isinstance(val, str):
			msg += f"{key.title():>12}:\t{val}\n"
	return msg

def selectMissions():
	crew = selectCrew()
	if not crew:
		return None
	msg = """{crew_name} {status}""".format(**crew)
	d.infobox("Lädt Missionen...")
	global scenarios
	if not scenarios:
		scenarios = Pyro4.Proxy("PYRONAME:campaign_scenarios")
	try:
		scenarios.ping()
	except:
		d.msgbox("Keine Verbindung zum Server. Versuche es in ein paar Sekunden nochmal.")
		return None
	scenario_dict = scenarios.list()

	msg += """

Links:   nicht verfügbare Missionen
Rechts:  verfügbare Missionen
SPACE:   Mission erlauben/verbieten
TAB:     Fokus zwischen links und rechts wechseln.
ENTER:	 OK
"""
	code, tags = d.buildlist(msg, visit_items=True, items = [(tag, scenario["name"], tag in crew["scenarios"]) for tag, scenario in scenario_dict.items()])
	if code == d.OK:
		diff_add = set()
		diff_rm = set()
		for tag in tags:
			if tag not in crew["scenarios"]:
				diff_add.add(scenario_dict[tag]["name"])
		for tag in crew["scenarios"]:
			if tag not in tags:
				diff_rm.add(scenario_dict[tag]["name"])
		msg = ""
		if diff_add:
			msg += "Folgende Szenarios für {crew_name} freigeschalten:\n\n".format(**crew)
			msg += ", ".join(list(diff_add))
		if diff_rm:
			msg += "\n\nFolgende Szenarios für {crew_name} deaktivieren:\n\n".format(**crew)
			msg += ", ".join(list(diff_rm))
		if diff_add or diff_rm:
			if d.yesno(msg) == "ok":
				crews.setScenarios(crew["instance_name"], tags)
				msg = "Änderung vorgenommen." 
				if diff_add:
					msg += "\n\nSollte die neue Mission am Missionsauswahlbildschirm der Crew noch nicht anzegeigt werden, muss das Missionsauswahlmenü verlassen und wieder geöffnet werden."
				d.msgbox(msg)
		else:
			d.msgbox("Keine Änderungen vorgenommen.")

def selectShips():
	crew = selectCrew()
	if not crew:
		return None
	msg = """{crew_name} {status}""".format(**crew)
	ship_dict = {	# descr not used
		"Adder MK7":	"Scout, sehr schnell und wendig, schwach bewaffnet.",
		"Phobos M3P":	"Leichter Kreuzer, Allrounder, Standardschiff für unerfahrene Crews.",
		"Hathcock":		"Laser-Fregatte, spezialisiert gegen Jäger und leichte Torpedoschiffe.",
		"Piranha M5P":	"Raketen-Fregatte, spezialisiert gegen schwer gepanzerte Ziele.",
		"Nautilus":		"Minen-Fregatte, kann Minen legen.",
		"Atlantis":		"Schwerer Kreuzer, Crew muss gut zusammenarbeiten. Standardschiff für Story-Missionen",
		"Crucible":		"Raketen-Korvette, schweres Schiff für Frontalangriffe.",
		"Maverick":		"Laser-Korvette, schweres Schiff mit Rundumverteidigung.",
	}
	msg += """

Links:   nicht verfügbare Schiffe
Rechts:  verfügbare Schiffe
SPACE:   Schiff erlauben/verbieten
TAB:     Fokus zwischen links und rechts wechseln.
ENTER:	 OK
"""
	code, tags = d.buildlist(msg, visit_items=True, items = [(tag, tag, tag in crew["ships"]) for tag in ship_dict])
	if code == d.OK:
		diff_add = set()
		diff_rm = set()
		for tag in tags:
			if tag not in crew["ships"]:
				diff_add.add(tag)
		for tag in crew["ships"]:
			if tag not in tags:
				diff_rm.add(tag)
		msg = ""
		if diff_add:
			msg += "Folgende Schiffe für {crew_name} freigeschalten:\n\n".format(**crew)
			msg += ", ".join(list(diff_add))
		if diff_rm:
			msg += "\n\nFolgende Schiffe für {crew_name} deaktivieren:\n\n".format(**crew)
			msg += ", ".join(list(diff_rm))
		if diff_add or diff_rm:
			if d.yesno(msg) == "ok":
				crews.setShips(crew["instance_name"], tags)
				msg = "Änderung vorgenommen." 
				if diff_add:
					msg += "\n\nDie Schiffe sind in den kampfbasierten Missionen 'Skirmish' und 'Siege' verfügbar. Zum kurzen Testen eines Schiffs eignet sich 'Skirmish' am besten, während 'Siege' die Crew irgendwann an ihre Grenzen bringen wird."
				d.msgbox(msg)
		else:
			d.msgbox("Keine Änderungen vorgenommen.")

def showCrew(instance):
	while True:
		crew = crews.get(instance)
		msg = ""
		for k,v in crew.items():
			msg += f"{k:>12}:\t{v}\n"
		#d.scrollbox(msg)
		choice_details = {
			"name": ("set crew name", "setCrewName", "crew_name"),
			"status": ("set status", "setStatus", "status"),
			"unlockScenario": ("unlock a scenario", "unlockScenario"),
			"lockScenario": ("lock a scenario", "lockScenario"),
			"unlockShip": ("unlock a ship", "unlockShip"),
			"lockShip": ("lock a ship", "lockShip"),
			"addArtifact": ("add an artifact", "addArtifact"),
			"rmArtifact": ("remove an artifact", "rmArtifact"),
			"setBriefing": ("change the briefing text", "setBriefing", "briefing"),
		}
		code, tag = d.menu(msg, choices=[(k, v[0]) for k,v in choice_details.items()])
		if code == d.OK:
			editCrew(instance, *choice_details[tag])
		else:
			return

def editCrew(instance, descr, function, default_attr=None):
	default = ""
	if default_attr:
		default = crews.get(instance)[default_attr]
	code, entry = d.inputbox(instance + " - " + descr, init=default)
	if code == d.OK:
		crews.__getattr__(function)(instance, entry)


start()

