EmptyEpsilon Campaign Server
---
Verwaltung und Management mehrerer EESrv und konsistenter Schiffe.


Begriffe:
---
EECS - EmptyEpsilon Campaign Server
EESrv - EmptyEpsilon Game Server - kann eine Scenario-Instanz hosten oder im Proxy-Modus sein. Kann gleicheitig ein EEClient sein.
EEProxy - EmptyEpsilon Game Server Proxy - erscheint auf der Server-Liste der Clients, ist aber ein Proxy für zu einem anderen Server. Kann gleicheitig ein EEClient sein
EEClient - EmptyEpsilon Game Client - verbindet sich zu genau einem EESrv/EEProxy. Gehört zu genau einem Schiff.
Scenario-Instanz - Scenario, das von einem EESrv ausgeführt wird. Mehrere Schiffe können in einer Scenario-Instanz sein.
Scenario - Datei mit dem Code des Scenarios. Enthält als Info-Metadaten auch Name, Typ, Variationen, etc?
Schiff - PlayerSpaceship in einer Scenario-Instanz auf einen EESrv


Module:
---
Crew-ID:
    * Schiffsname (änderbar)
    * ein EESrv (fällt später weg) bzw. Proxy
    * ein Schiff
    * Scores
Pro EESrv:
    * Missionsauswahl/verfügbare Missionen
    * Status
    * FC-Chat/Anweisungen
Pro Schiff:
    * Reputation-Bonus
    * verfügbare Schiffe
    * Spawn-Code (Schiffs-Modifikationen)
Rundentimer (f. Coop-Mission)
Log


Fleet-Command-Interfaces:
---
**Ansichten: Commodore, Werftleitung, Kartograph**
Commodore: Infos aus EESrv: Schiffsname, verfügbare Missionen, Status, Scores, Chat
Werftleitung: Infos aus Schiff: Schiffsname, verfügbare Schiffe, Rep-Bonus, Upgrades(Spawn-Code)
Kartograph: Log, Timer
GM: alles
