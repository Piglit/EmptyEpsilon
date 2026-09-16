--[[
Was passiert -> welche Info
start -> systemtest, Aufklärungsnews kommen hier
first_mission_started -> get ready, Missionen verteilen
first_mission_finished -> rep-Bonus
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
		init = 
[[Systemcheck abgeschlossen.
Empfang von Aufklärungsberichten und strategische Informationen funktional.
Alle eingehenden Meldungen sind für das Flottenkommando bestimmt.
Jede Meldung wird nur einmal ausgegeben.]],
		first_mission_started = 
[[Aufklärungsbericht
------------------
Die {callsign} hat um {time} als erstes Schiff die Mission '{mission}' begonnen.

Ziel
----
Alle Schiffe der Flotte müssen startklar gemacht werden.

Strategische Informationen über Missionen
-----------------------------------------
Das Flottenkommando kann festlegen, welchen Schiffen welche Missionen zur Verfügung stehen. Sollte eine Crew besonders schnell sein, kann ihnen eine Mission gegeben werden, die mehr Zeit benötigt.]],
		first_mission_finished =
[[Aufklärungsbericht
------------------
Die {callsign} hat um {time} als erstes Schiff erfolgreich die erste Mission '{mission}' beendet.

Ziel
----
Die Schiffe der Flotte sollen im Zeitraum einer Stunde an Trainingsmissionen teilnehmen.

Strategische Informationen über den Reputations-Bonus
-----------------------------------------------------
Schiffe erhalten einen Reputations-Bonus durch Missionen. Die Höhe des Bonus hängt vom Missionsfortschritt und dem Schwierigkeitsgrad der Mission ab. Bei mehrfachem bestreiten einer Mission durch die gleiche Crew gilt der höchste erlangte Bonus.]],
		first_artifact_gathered =
[[Aufklärungsbericht
------------------
Die {callsign} hat um {time} als erstes Schiff ein Artefakt erfolgreich geborgen.

Ziel
----
Die Schiffe der Flotte sollen möglichst viele Artefakte finden, scannen und bergen.

Strategische Informationen über Artefakte
-----------------------------------------
In jeder Mission gibt es mindestens ein Artefakt zu finden. Wurde ein Artefakt erfolgreich geborgen, braucht es in zukünftigen Durchläufen der gleichen Mission nicht noch einmal geborgen werden (auch nicht von einer anderen Crew).]],
		first_artifact_destroyed =
[[Aufklärungsbericht
------------------
Ein Artefakt wurde durch unsachgemäße Bergungsversuche zerstört.

Ziel
----
Die Schiffe der Flotte sind zu instruieren, wie Artefakte zu bergen sind.

Strategische Informationen über die Bergung von Artefakten
----------------------------------------------------------
Um ein Artefakt zu bergen, muss es zuerst gescannt werden, um die Einfangfrequenz ermittelt werden. Dann müssen die Schilde des Schiffs auf diese Frequenz kalibriert werden. Danach kann das Artefakt mit aktivierten Schilden eingesammelt werden.
Im Kommunikations-Log des bergenden Schiffs kann nachvollzogen werden, warum eine Bergung missglückt ist.]],
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

Strategische Informationen über Aufmerksamkeit
----------------------------------------------
Immer wenn ein Schiff der Human Navy in unbekanntes Gebiet vordringt, riskiert es die Aufmerksamkeit von Feinden zu erregen, die daraufhin die Human Navy als ganzes angreifen könnten.
Langsames koordiniertes Vordringen ist also weniger riskant, als die Flucht mit Vollgas ins Unbekannte.]],
		docked_with_fc =
[[Aufklärungsbericht
------------------
Die {callsign} hat erfolgreich an der Station des Flottenkommandos angedockt.
Sie haben {artifacts} Artefakte dabei.
Artefakte können über die Maschinenraumkonsolen zwischen dem Schiff und der Station ausgetauscht werden.

Ziel
----
Primäres Ziel der Human Navy ist nun die Aufklärung benachbarter Gebiete.
Wenn dabei Artefakte gefunden werden, sind diese sicher zu bergen und dem Flottenkommando zu übergeben.

Strategische Informationen über Artefakte
-----------------------------------------
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

Strategische Informationen über die Arlenier
--------------------------------------------
Die Arlenier sind pazifistische Verbündete der Human Navy.
Auch wenn sie uns keine Waffen verkaufen, sind sie uns technologisch überlegen und oft bereit Technologien mit uns zu teilen.
Ein Besuch lohnt sich deshalb fast immer.]],
		arlenian_escort_complete = 
[[Aufklärungsbericht
------------------
Unsere Sensoren zeigen eine Energiespitze, die spezifisch für die Vereinigung zweier arlenischer Lebensformen ist. Kurz darauf konnten wie die Ankunft weiterer arlenischer Schiffe in Sektor {sector} beobachten.
Die Arlenier der Station {callsign_station} signalisieren uns erhöhte Bereitschaft ihre Technologien mit uns zu teilen.

Ziele
-----
Entsendet Schiffe zu bekannten arlenischen Stationen und überprüft, ob diese ebenfalls bereit sind, sich mit {callsign_station} zu vereinen.
Nutzt die Schiffe der Arlenier, die sie nicht mehr zur Verteidigung brauchen an anderen Orten.

Strategische Informationen über arlenische Stationen
----------------------------------------------------
Die meisten arlenische Raumstationen können an andere Orte reisen oder an einer größeren Raumstation andocken. Wenn wir sie dabei unterstützen, werden sie ihre Technologien daraufhin all unseren Schiffen zur Verfügung stellen, statt sie nur an einzelne ausgewählte Schiffe zu verteilen.
]],
		independent_station_found = 
[[Aufklärungsbericht
------------------
Wir haben ein Kontakt-Signal von der unabhängigen Station {callsign} in {sector} erhalten.
Die Station gehört zwar nicht zur Human Navy, aber sie sind bereit mit uns zu handeln.
Das könnte unsere prekäre Versorgungslage entspannen.

Ziel
----
Ein Schiff in der Nähe sollte an der Station docken und evaluieren, ob die Station für uns von strategischem Nutzen ist. Ein Besuch beim Stations-Management wäre ebenfalls angebracht.

Strategische Informationen über Raumstationen
---------------------------------------------
Immer wenn eines unserer Schiffe an einer Station dockt, werden die Einträge in unseren Datenbanken zu dieser Station aktualisiert.
Dadurch stehen aktualisierte Informationen allen zur Verfügung.
]],
		gained_favor = 
[[Aufklärungsbericht
------------------
Die Crew der {callsign_ship} konnte an Einfluss bei der Station {callsign_station} im Sektor {sector} gewinnen.

Ziel
----
Die Human Navy muss ihren Einfluss bei unabhängigen Stationen systematisch erhöhen.

Strategische Informationen über unabhängige Stationen
-----------------------------------------------------
Unabhängige Stationen sind anfangs oft zurückhaltend, was den Handel mit Waffen oder andere Unterstützung angeht.
Wenn wir unseren Einfluss im Gebiet ausweiten wollen, sollten wir oft mit den Managern von solchen unabhängigen Stationen kommunizieren.]],
	},
		turned_independent_friendly = 
[[Aufklärungsbericht
------------------
Die Station {callsign_station} hat sich der Human Navy angeschlossen.
Dadurch können wir diese Station als Flottenstützpunkt nutzen.

Ziel
----
Wir brauchen mehr solcher Stationen, um unser Territorium zu vergrößern.

Strategische Informationen über befreundete Stationen
-----------------------------------------------------
Stationen, die zur Human Navy gehören verfügen oft über erweiterte Dienste.
Wir können von ihnen Verstärkung anfordern oder im Fall eines Angriffs eine Verteidigungsflotte aktivieren. Zudem verkaufen sie unseren Schiffen ihre Waffen zu den günstigsten Konditionen.
]],
		convertable_station = 
[[Aufklärungsbericht
------------------
Die Station {callsign_station} in Sektor {sector} ist dafür prädestiniert von uns erobert zu werden.

Ziel
----
Ein nahes Schiff soll Kontakt mit der Station aufnehmen und sie zur Kapitulation zwingen.

Strategische Informationen über feindliche Stationen
----------------------------------------------------
Einige Stationen, die von Feinden besetzt sind, können eingeschüchtert werden.
Dazu müssen wir ihre Umgebung von feindlichen bewaffneten Schiffen befreien und unsere eigenen Kriegsschiffe um die Station positionieren. Manchmal hilft auch ein Warnschuss. Spätestens, wenn die Schilde der Station durchbrochen sind, sollten sie über eine Kapitulation nachdenken.
Nicht jede feindliche Fraktion ist bereit, sich uns zu ergeben.]],
		turned_enemy_independent = 
[[Aufklärungsbericht
------------------
Die {callsign_ship} konnte die feindliche Station {callsign_station} in Sektor {sector} zur Kapitulation zwingen. Die Station wird es unseren Schiffen gestatten zu docken und unsere Vorräte aufzufüllen. Es scheint eine große Menge an Waffen an Bord zu sein.

Ziel
----
Erobert weitere Stationen, um unser Territorium zu vergrößern.]],
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

