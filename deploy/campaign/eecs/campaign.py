"""This file contains campaign specific infos"""
import core
import models.crew
import models.scenario

# load scenarios, that should be available in the campaign.
# use the complete filename without the folder.
models.scenario.loadScenarios([
	"scenario_20_training1.lua",
	"scenario_00_basic.lua",
	"scenario_21_training2.lua",
])

briefing = """Willkommen, Crew der {crew_name}.

Dies ist euer Missionsauswahlbildschirm. Hier werden alle für euch verfügbaren Missionen angezeigt werden. Momentan steht euch nur eine einzelne Trainingsmission zur Verfügung, die dazu da ist, damit ihr euch ein wenig auf einander einspielen können.

Wenn ihr eine Mission abschließt (oder auch nur größtenteils abschließt), werden weitere Missionen für euch bereitgestellt.
"""
models.crew.setCrewTemplate(["20_training1", "basic"], ["Phobos M3P"], briefing)

def scenario_event(scenario: models.scenario.Scenario, crew: models.crew.Crew, event_topic: str, details={}):
	s = scenario.scriptId 
	progress = details.get("progress")
	# for all missions:
	if event_topic == "started":
		crew.setBriefing("")
	elif event_topic == "victory":
		progress = 100
	elif event_topic == "score":
		crew.updateScore(s, details)

	if s == "20_training1":
		if event_topic in ["progress", "victory"]:
			crew.updateScore(s, {"progress": progress})
			maxProgress = 100*len(crew.getScenarios())
			#&ProgressMeter:{progress}:{maxProgress}&
			if progress >= 75:
				crew.unlockScenarios(["00_basic", "21_training2"])
				crew.setBriefing("""Glückwunsch, {crew_name}.
Euch stehen nun zwei weitere Missionen zur Auswahl.

Ihr könnt euch bei allen von euch bereits abgeschlossenen Missionen eurer bestes Ergebnis ansehen.
""")
	if s == "21_training2":
		if event_topic == "unlockShip":
			ship = details["ship"]
			if not crew.hasShip(ship):
				crew.unlockShip(ship)
				crew.setBriefing("""Glückwunsch, {crew_name}.
Die in dieser Mission von euch verwendeten Schiffstypen stehen euch nun auch in den Kampfbasierten Missionen zur Verfügung.
""")
		

core.subscribe("scenario_event", scenario_event)
