"""This file contains campaign specific infos"""
import core
import models.crew
import models.scenario
import outbound.stationsComms
import json

# load scenarios, that should be available in the campaign.
# use the complete filename without the folder.
models.scenario.loadScenarios([
	"scenario_20_training1.lua",
	"scenario_00_basic.lua",	# TODO time limit 30; adjustable difficulty -> rep bonus; art for diffic. 
	"scenario_03_waves.lua",	# TODO Faction: ghosts? reputation for waves
	"scenario_21_training2.lua",
	# special missions:
	"scenario_05_beacon.lua",
	"scenario_06_edgeofspace.lua",
	"scenario_07_gftp.lua",		# TODO test
	"scenario_08_atlantis.lua",	# TODO test

	"scenario_99_wormhole_expedition.lua",
])

# best progress [0,100] of a played scenario times this factor results in the multiplayer rep bonus.
# uses scriptId
SCENARIO_REPUTATION_FACTOR = {
	"20_training1":	0.25,
	"00_basic":		0.5,
}

FLEET_COMMAND_NAME = "Ball"

briefing = """Willkommen, Crew der {crew_name}.

Dies ist euer Missionsauswahlbildschirm. Hier werden alle für euch verfügbaren Missionen angezeigt werden. Momentan steht euch nur eine einzelne Trainingsmission zur Verfügung, die dazu da ist, damit ihr euch ein wenig auf einander einspielen können.

Wenn ihr eine Mission abschließt (oder auch nur größtenteils abschließt), werden weitere Missionen für euch bereitgestellt.
"""
models.crew.setCrewTemplate(["20_training1", "basic"], ["Phobos M3P"], briefing)

def scenario_event(scenario: models.scenario.Scenario, crew: models.crew.Crew, event_topic: str, details=str):
	s = scenario.scriptId 
	
	# update score and get progress
	progress = None
	rep_factor = SCENARIO_REPUTATION_FACTOR.get(s, 1.0)
	if event_topic == "score":
		details = json.loads(details)
		if "progress" in details:
			progress = details["progress"]
			details["reputation"] = progress * rep_factor
		crew.updateScore(s, details)
	elif event_topic == "progress":
		assert isinstance(details, dict)
		progress = details["progress"]
		crew.updateScore(s, {"progress": progress, "reputation": progress*rep_factor})
	elif event_topic == "victory":
		progress = 100
		crew.updateScore(s, {"progress": progress, "reputation": progress*rep_factor})

	# for all scenarios
	if event_topic == "started":
		crew.setBriefing("")
	elif event_topic == "artifact":
		artifact_name = details
		crew.addArtifact(artifact_name)

	# scenario specific
	if s == "20_training1":
		if progress is not None and progress >= 75:
			crew.unlockScenarios(["00_basic", "21_training2"])
			crew.setBriefing("""Glückwunsch, {crew_name}.
Euch stehen weitere Missionen zur Auswahl:
In 'Basic Battle'

Ihr könnt euch nun euren Punklestand bei der gerade abgeschlossenen Missionen ansehen.
""")
	if s == "21_training2":
		if event_topic == "unlockShip":
			ship = details["ship"]
			if not crew.hasShip(ship):
				crew.unlockShip(ship)
				crew.setBriefing("""Glückwunsch, {crew_name}.
Die in dieser Mission von euch verwendeten Schiffstypen stehen euch nun auch in den kampfbasierten Missionen zur Verfügung.
""")

	if s == "00_basic":
		if progress is not None and progress >= 75:
			crew.unlockScenario("03_waves")
			crew.setBriefing("""Glückwunsch, {crew_name}.

""")
	
	if event_topic == "fleetcommand-spawned":
		outbound.stationsComms.subscribe_comms_log(crew.instance_name, details)
	if event_topic == "fleetcommand-deleted":
		outbound.stationsComms.unsubscribe_comms_log()


core.subscribe("scenario_event", scenario_event)
