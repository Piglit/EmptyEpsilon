
MISSIONS = {
	"basic":		{"scenario":"scenario_00_basic.lua", "shipType": "Atlantis", "unlocks":[]},
	"training1":	{"scenario":"scenario_00_training1.lua", "shipType": "Phobos", "unlocks":["training2", "training3", "training4", "quick basic"]},
	"training2":	{"scenario":"scenario_00_training2.lua", "shipType": "Hathcock", "unlocks":["outpost"]},
	"training3":	{"scenario":"scenario_00_training3.lua", "shipType": "Piranha", "unlocks":["training3 boss", "surrounded"]},
	"training3 boss":	{"scenario":"scenario_00_training3.lua", "variation": "Boss", "name": "Training: Missile Cruiser - Boss", "shipType": "Piranha", "unlocks":[]},
	"training4":	{"scenario":"scenario_00_training4.lua", "shipType": "Nautilus", "unlocks":["gaps"]},
	"basic waves":	{"scenario":"scenario_01a_waves.lua", "shipType": "", "unlocks":[]},
	"kraylor waves":{"scenario":"scenario_01d_waves.lua", "shipType": "", "unlocks":[]},
	"exuari waves":	{"scenario":"scenario_01e_waves.lua", "shipType": "", "unlocks":[]},
	"beacon":		{"scenario":"scenario_02_beacon.lua", "shipType": "Atlantis", "unlocks":[]},
	"edgeofspace":	{"scenario":"scenario_03_edgeofspace.lua", "shipType": "Phobos", "unlocks":[]},
	"gftp":			{"scenario":"scenario_04_gftp.lua", "shipType": "Phobos", "unlocks":[]},
	"surrounded":	{"scenario":"scenario_05_surrounded.lua", "shipType": "Piranha", "unlocks":[]},
	"battlefield":	{"scenario":"scenario_06_battlefield.lua", "shipType": "", "unlocks":[]},
	"quick basic":	{"scenario":"scenario_07_quick_basic.lua", "shipType": "Phobos", "unlocks":["quick basic advanced"]},
	"quick basic advanced":	{"scenario":"scenario_07_quick_basic.lua", "variation": "Advanced", "name": "Quick Basic - Advanced", "shipType": "Atlantis", "unlocks":[]},
	"atlantis":		{"scenario":"scenario_08_atlantis.lua", "shipType": "Atlantis", "unlocks":[]},
	"outpost":		{"scenario":"scenario_09_outpost.lua", "shipType": "Hathcock", "unlocks":[]},
	"gaps":			{"scenario":"scenario_50_gaps.lua", "shipType": "Nautilus", "unlocks":[]},
	"ambassador":	{"scenario":"scenario_51_deliverAmbassador.lua", "shipType": "Flavia", "unlocks":[]},
	"escape":		{"scenario":"scenario_53_escape.lua", "shipType": "", "unlocks":[]},
	"dHunter":		{"scenario":"scenario_55_defenderHunter.lua", "shipType": "", "unlocks":[]},
	"shoreline":	{"scenario":"scenario_57_shoreline.lua", "shipType": "", "unlocks":[]},
}

for key in MISSIONS:
	path = "../scripts/"+MISSIONS[key]["scenario"]
	with open(path,"r") as file:
		state = None
		for line in file:
			if state == "brief":
				if not line.startswith("---"):
					state = None
				else:
					MISSIONS[key]["briefing"].append(line[3:].strip())
					continue
			if not line.startswith("--"):
				break
			line = line[2:].strip()
			if line.startswith("Name:") and "name" not in MISSIONS[key]:
				MISSIONS[key]["name"] = line.split(":",maxsplit=1)[1].strip()
			if line.startswith("Type:"):
				MISSIONS[key]["type"] = line.split(":",maxsplit=1)[1].strip()
			if line.startswith("Description:"):
				MISSIONS[key]["briefing"] = [line.split(":",maxsplit=1)[1].strip()]
				state = "brief"
			if line.startswith("Variation["):
				var, descr = line.split("[", maxsplit=1)[1].split("]", maxsplit=1)
				if var == MISSIONS[key].get("variation"):
					MISSIONS[key]["variation brief"] = descr.strip()
					
