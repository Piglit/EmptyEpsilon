"""
What is it for?

EE-Srv asks for scenarios
CS answeres with list of scenarios
EE-Srv asks for a scenario-info
CS answeres with scenario infos
EE-Srv starts scenario
CS handles @start events
EE-Srv sends script events
CS handles @script events
EE-Srv sends victory event
CS handles @victory event
EE-Srv sends end event
CS handles @end event

With Proxy:
For now: only privileged can host
Other EE-Srv can not start but join
Other EE-Srv does not call other endpoints

Clever Datastructures:

scenarios are addressed by filename
-> Dict: filename -> scenarioInfos, scenarioCampaignInfos
-> scenarioInfos contain (read from script): Name, Type, Description. But not Variations
-> unusedScenarioCampaignInfos contain: shipType (unused?), all Variations (read from script)
-> scenarioCampaignInfos contain: @event callbacks: @start, @script(msg), @victory(faction), @end
-> callbacks typically contain unlocks (script, variation, multiplayerShipType)

srv-specific file with: scenario ID (filename) + list of unlocked variations

"""
from functools import partial as P
from srvData import servers as S

scenarioInfos = {
	"00_test":				{"@start": P(S.unlockScenario, "01_test2"), "@end": P(S.unlockShip, "Hathcock"), "@victory[Human Navy]": P(S.unlockScenario, "09_outpost")},
	"01_test2":				{},
	"00_basic":				{},
	"01_quick_basic":		{},
	"20_training1":			{"@victory[Human Navy]": [P(S.unlockScenarios, [("21_training2", "*"), ("22_training3", "*"), ("23_training4", "*"), "01_quick_basic"]), P(S.unlockShip, "Phobos")]},
	"21_training2":			{"@victory[Human Navy]": [P(S.unlockScenario, "09_outpost"), P(S.unlockShip, "Hathcock")]},
	"22_training3":			{"@victory[Human Navy]": P(S.unlockShip, "Piranha M5P")},
	"23_training4":			{"@victory[Human Navy]": P(S.unlockShip, "Nautilus")},
	"01a_waves":			{},
	"01d_waves":			{},
	"01e_waves":			{},
	"02_beacon":			{},
	"03_edgeofspace":		{},
	"04_gftp":				{},
	"05_surrounded":		{},
	"06_battlefield":		{},
	"08_atlantis":			{},
	"09_outpost":			{},
	"49_allies":			{},
	"50_gaps":				{},
	"51_deliverAmbassador":	{},
	"53_escape":			{},
	"55_defenderHunter":	{},
	"57_shoreline":			{},
	"59_border":			{"info": {"Proxy": "192.168.2.3"}},
}

for key in scenarioInfos:
	filename = "scenario_"+key+".lua"
	path = "../../scripts-piglit/"+filename
	if "info" not in scenarioInfos[key]:
		scenarioInfos[key]["info"] = {}
	scenarioInfos[key]["variations"] = {}
	assert "@victory" not in scenarioInfos[key], "keyword @victory is not allowed without a faction"
	
	with open(path,"r") as file:
		state = None
		for line in file:
			if state == "brief":
				if not line.startswith("---"):
					state = None
				else:
					scenarioInfos[key]["info"]["Description"] += "\n"+line[3:].strip()
					continue
			if not line.startswith("--"):
				break
			line = line[2:].strip()
			if line.startswith("Name:") and "name" not in scenarioInfos[key]:
				scenarioInfos[key]["info"]["Name"] = line.split(":",maxsplit=1)[1].strip()
			if line.startswith("Type:"):
				scenarioInfos[key]["info"]["Type"] = line.split(":",maxsplit=1)[1].strip()
			if line.startswith("Description:"):
				scenarioInfos[key]["info"]["Description"] = line.split(":",maxsplit=1)[1].strip()
				state = "brief"
			if line.startswith("Variation["):
				var, descr = line.split("[", maxsplit=1)[1].split("]", maxsplit=1)
				descr = descr.removeprefix(":").strip()
				scenarioInfos[key]["variations"][var] = descr

					
scenarioInfos_unused_infos = {
"scenario_00_test.lua":					{"shipType": "Atlantis", "unlocks":["test2"]},
"scenario_01_test2.lua":				{"shipType": "Atlantis", "unlocks":[]},
"scenario_00_basic.lua":				{"shipType": "Atlantis", "unlocks":[]},
"scenario_20_training1.lua":			{"shipType": "Phobos", "unlocks":["training2", "training3", "training4", "quick basic"]},
"scenario_00_training2.lua":			{"shipType": "Hathcock", "unlocks":["outpost"]},
"scenario_00_training3.lua":			{"shipType": "Piranha", "unlocks":["training3 boss", "surrounded"]},
"scenario_00_training3.lua":			{"variation": "Boss", "name": "Training: Missile Cruiser - Boss", "shipType": "Piranha", "unlocks":[]},
"scenario_00_training4.lua":			{"shipType": "Nautilus", "unlocks":["gaps"]},
"scenario_01a_waves.lua":				{"shipType": "", "unlocks":[]},
"scenario_01d_waves.lua":				{"shipType": "", "unlocks":[]},
"scenario_01e_waves.lua":				{"shipType": "", "unlocks":[]},
"scenario_02_beacon.lua":				{"shipType": "Atlantis", "unlocks":[]},
"scenario_03_edgeofspace.lua":			{"shipType": "Phobos", "unlocks":[]},
"scenario_04_gftp.lua":					{"shipType": "Phobos", "unlocks":[]},
"scenario_05_surrounded.lua":			{"shipType": "Piranha", "unlocks":[]},
"scenario_06_battlefield.lua":			{"shipType": "", "unlocks":[]},
"scenario_07_quick_basic.lua":			{"shipType": "Phobos", "unlocks":["quick basic advanced"]},
"scenario_07_quick_basic.lua":			{"variation": "Advanced", "name": "Quick Basic - Advanced", "shipType": "Atlantis", "unlocks":[]},
"scenario_08_atlantis.lua":				{"shipType": "Atlantis", "unlocks":[]},
"scenario_09_outpost.lua":				{"shipType": "Hathcock", "unlocks":[]},
"scenario_50_gaps.lua":					{"shipType": "Nautilus", "unlocks":[]},
"scenario_51_deliverAmbassador.lua":	{"shipType": "Flavia", "unlocks":[]},
"scenario_53_escape.lua":				{"shipType": "", "unlocks":[]},
"scenario_55_defenderHunter.lua":		{"shipType": "", "unlocks":[]},
"scenario_57_shoreline.lua":			{"shipType": "", "unlocks":[]},
}


