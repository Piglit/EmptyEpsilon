--[[
Was passiert -> welche Info
start -> systemtest, Aufklärungsnews kommen hier
first_mission_started
first_mission_finished
first_artifact_gathered -> Nutzen v. Arts
first_artifact_destroyed -> Bergen v. Arts

first_ship_arrived -> Versorgungslage, Ziel
first_cta -> Aufmerksamkeit
docked_with_fc -> Transfer Arts, Ziel: Aufklärung
bought_fc_upgrade -> Wo Arts?
ship_destroyed -> Respawn
independent_station_found -> Ind stations
gained_favor -> favor, Ziel: Expand
trade_network -> Versorgung verbessert -> Exploit
changed_faction -> Militärisch nurzbare Stationen -> Exploit
arlenian_station_found -> Arl stations
gained_upgrade -> upgrades
arlenian_request -> Ziel: Arl quest
conquered_station -> Ziel: Expand
]]
vf_bescheid = {
	sent = {},
	messages = {
		-- from campaign
		first_mission_started = [[]],
		first_mission_finished = [[]],
		first_artifact_gathered = [[]],
		first_artifact_destroyed = [[]],
		-- from this scenario
		first_ship_arrived =
[[Aufklärungsbericht
------------------
Das erste Schiff, die {callsign}, ist im Gebiet angekommen.
Weitere Schiffe werden folgen.
Unsere Versorgungslage ist prekär: die Station des Flottenkommandos verfügt noch über keine Möglichkeiten die Vorräte von Schiffen aufzufüllen.

Ziel
----
Das primäres Ziel aller neu angekommenen Schiffe ist es, sich zur Station des Flottenkommandos durchzuschlagen, ohne dabei zu viel Aufmerksamkeit zu erregen.
Dies muss an neu angekommene Schiffe kommuniziert werden.

Strategische Information über Aufmerksamkeit
--------------------------------------------
Immer wenn ein Schiff der Human Navy in unbekanntes Gebiet vordringt, riskiert es die Aufmerksamkeit von Feinden zu erregen, die daraufhin die Human Navy als ganzes angreifen könnten.
Langsames koordiniertes Vordringen ist also weniger riskant, als die Flucht mit Vollgas ins Unbekannte.]],
		docked_with_fc =
[[Aufklärungsbericht
------------------
Die {callsign} hat erfolgreich an der Station des Flottenkommandos angedockt.
Sie haben {artifacts} Artefakte dabei.
Artefakte können über die Maschinenraumkonsolen Artefakte zwischen dem Schiff und der Station ausgetauscht werden.

Ziel
----
Primäres Ziel der Human Navy ist nun die Aufklärung benachbarter Gebiete.
Wenn dabei Artefakte gefunden werden, sind diese sicher zu bergen und dem Flottenkommando zu übergeben.

Strategische Information über Artefakte
---------------------------------------
Um ein Artefakt einzusammeln, muss die Einfangfrequenz ermittelt werden, und die Schilde des Schiffs auf diese Frequenz kalibriert werden. Dann kann das Artefakt mit aktivierten Schilden eingesammelt werden. Ist die Frequenz falsch, oder die Schilde deaktiviert, wird das Artefakt beim Einsammeln zerstört und hinterlässt Schaden am Schiff.

Artefakte können verwendet werden, um die Station des Flottenkommandos auszubauen.]],
		ship_destroyed = 
[[Aufklärungsbericht
------------------
Die {callsign} hat wurde in Sektor {sector} zerstört.
{artifacts_lost}]],
		arlenian_station_found = 
[[Aufklärungsbericht
------------------
Wir haben ein Kontakt-Signal von der arlenischen Station {callsign} in {sector} erhalten.

Ziel
----
Ein Schiff in der Nähe sollte an der Station docken und Kontakt mit der Besatzung aufnehmen.
Falls es dort etwas gibt, das sich zu holen lohnt, muss dies an die Flotte kommuniziert werden.

Strategische Information über die Arlenier
------------------------------------------
Die Arlenier sind pazifistische Verbündete der Human Navy.
Auch wenn sie uns keine Waffen verkaufen, sind sie uns technologisch überlegen und oft bereit Technologien mit uns zu teilen.
Ein Besuch lohnt sich deshalb fast immer.]],
		independent_station_found = 
[[Aufklärungsbericht
------------------
Wir haben ein Kontakt-Signal von der unabhängigen Station {callsign} in {sector} erhalten.
Die Station gehört zwar nicht zur Human Navy, aber sie sind bereit mit uns zu handeln.
Das könnte unsere prekäre Versorgungslage entspannen.

Ziel
----
Ein Schiff in der Nähe sollte an der Station docken und evaluieren, ob die Station für uns von strategischem Nutzen ist. Ein Besuch beim Stations-Management wäre ebenfalls angebracht.

Strategische Information über unabhängige Stationen
---------------------------------------------------
Immer wenn eines unserer Schiffe an einer Station dockt, werden die Einträge in unseren Datenbanken zu dieser Station aktualisiert.
Dadurch stehen aktualisierte Informationen allen zur Verfügung.
Unabhängige Stationen sind anfangs oft zurückhaltend, was den Handel mit Waffen angeht.

Wenn wir unseren Einfluss im Gebiet ausweiten wollen, sollten wir oft mit den Managern von solchen unabhängigen Stationen kommunizieren.]],
		gained_favor = 
[[Aufklärungsbericht
------------------
Soeben konnte die Crew der {callsign_ship} etwas an Einfluss bei der Station {callsign_station} im Sektor {sector} gewinnen.

Ziel
----
Die Human Navy muss ihren Einfluss bei unabhängigen Stationen systematisch erhöhen.
TODO why?
]],
	},
}

function vf_bescheid:woas_scho(about)
	return self.sent[about]
end

function vf_bescheid:sag_bescheid(about, details, always)
	if self:woas_scho(about) and not always then
		return
	end
	local msg = self.messages[about]
	if not msg then
		log("bescheid: about nicht gefunden", about)
		return
	end
	for key, val in pairs(details) do
		msg = string.gsub(msg, "{"..key.."}", val)
	end
	log("Bescheid:", msg)
	sendMessageToCampaignServer("fernschreiber", msg)
	self.sent[about] = true
end

