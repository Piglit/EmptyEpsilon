Project Architecture
---
Pub-Sub Model

**core** contains the publish and subscribe functions.
Each module registers itself upon import

**crew** alle Änderungen an den Crews sind persistent - sie werden bei Änderungen geschreiben und bei Neustart (oder reload-Befehl) neu geladen.
Crew-Objekte können über Pyro manipuliert werden. Sie enthalten nur primitive Datentypen.

**campaign** Eine Kampagne; alle Logik, die Szenarios und Crews verknüpft findet hier statt.
Der Kampagnenstatus ist persistent - er wird bei Änderungen geschrieben und bei Neustart (oder reload-Befehl) neu geladen.

Alle anderen Module halten keine veränderlichen Daten.
