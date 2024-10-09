EmptyEpsilon-Konzepte:
---
* Spieler können Stationen oder Schiffe über Comms kontaktieren.
* Das kontaktierende Spieler-Schiff wird üblicherweise als *player* oder *comms\_source* bezeichnet. Hier wird es einfach **Spieler** genannt. Die kontaktierte Station bzw. das kontaktierte Schiff wird üblicherweise als *target* bzw. **Objekt** bezeichnet.
* Ein Dialog-Menü wird auf der Comms-Konsole des Spieler angezeigt. Dort ist immer eine *Seite* zu sehen:
    * Pro Seite wird immer eine **Nachricht** (*commsMessage*) angezeigt und die Spieler können aus **Optionen** (*commsReply*) wählen.
    * Es kann beliebig viele Optionen (oder auch keine) geben.
    * Gibt es keine Option, sind die Spieler gezwungen den Dialog zu beenden.
    * Enthält die Nachricht mehr als sieben Zeilen, wird eine Scroll-Leiste bei der Nachricht angezeigt.
    * Gibt es mehr als 5 Optionen, wird eine Scroll-Leiste bei den Optionen angezeigt.
    * In Nachrichten werden automatisch Zeilenumbrüche eingefügt. Zeilenumbrüche können auch manuell mit `\n` eingefügt werden.
    * In Optionen gibt es keine Zeilenumbrüche. Eine Optionen kann nur eine Zeile lang sein. Ist die Option länger als eine Zeile, sind Anfang und Ende abgeschnitten.
* Die Spieler können einen offenen Dialog jederzeit über den Schließen-Button beenden.
* Wird während des Dialogs einer der Kommunikationsteilnehmer zerstört, endet die Kommunikation.
* Eine Station oder ein Schiff können den Kommunikationsaufbau ablehnen. Den Spielern wird dann *No Reply* angezeigt.
* Konventionen bei bestehenden Dialogen:
    * Bei Stationen wird üblicherweise unterschieden, ob die Spieler angedockt sind.
    * Bei Stationen und Schiffen wird außerdem üblicherweise unterschieden, wie deren Fraktion zur Fraktion der Spieler steht (freundlich, feindlich, neutral).
    * Viele Entscheidungen in Dialogen ändern die Reputation der Spieler-Fraktion.
    * Einige bestehende Dialogoptionen hängen vom *friendlyness*-Wert der Station ab. Dies ist ein Zufallswert zwischen 0 und 100, der beim ersten Kontakt mit der Station festgelegt wird.

DSL-Konzepte:
---
* Ziele:
    * Schreiben von Dialogen auf mehrere Personen verteilbar machen.
    * Effekte von Dialogen müssen automatisiert getestet werden können.
* Methode:
    * Eigene Sprache für Dialoge, die zu lua-Skripten übersetzt werden kann.
    * Beschränkung der möglichen Effekte auf wenige Elemente.
* Struktur:
    * Höchste logische Einheit: **Plotstrang** - jeder Plotstrang ist einer Person zugeordnet, die den Plotstrang schreibt bzw. für ihn verantwortlich ist.
    * Darunter sind **Dialoge** angelegt. Jeder Dialog wird einem **Objekt** (Station oder Schiff) zugewiesen. Ein Plotstrang kann sich also über mehrere Dialoge an mehreren Stationen oder Schiffen erstrecken.
    * Ein Objekt kann mehrere Dialoge enthalten - auch aus unterschiedlichen Plotsträngen.
    * Dialoge bestehen aus **Optionen**, und **Seiten**.
    * **Seiten** bestehen aus einer **Nachricht**, die den Spielern als Text der Seite angezeigt wird und beliebig vielen **Effekten** und **Optionen**
    * Eine **Option** besteht aus einem Optionstext, der den Spielern im Dialog als Auswahlmöglichkeit angezeigt wird. Eine Option führt auf eine **Seite**
    * Jeder Dialog beginnt mit einer Option.
    * Optionen können an eine **Bedingung** geknüpft sein. Nur wenn die Bedingung erfüllt ist, steht die Option den Spielern zur Auswahl.
    * **Effekte** manipulieren **Ressourcen** der Spieler oder des Objekts.
    * **Ressourcen** sind Variablen, die durch Effekte manipuliert werden können. Sie gehören entweder zu einem Spieler oder einem Objekt. Eine Ressource hat einen Namen, über den sie adressiert wird und einen Wert, der manipuliert und abgefragt werden kann.
    * **Bedingungen** vergleicht ob eine Ressource mit einem Wert oder dem Wert einer anderen Ressource.
* Umsetzung
    * Pro Plotstrang gibt es eine Python-Datei (.py). Bei sehr umfassenden Plotsträngen, die mehr Strukturierung brauchen kann auch ein Verzeichnis mit mehreren Dateien verwendet werden.
    * In den Python-Dateien können Dialoge über dafür gemachte Python-Klassen erstellt und Objekten zugewiesen werden.
    * Über ein Python-Skript können die Dateien mit Plotsträngen in Lua-Skripte übersetzt werden. Diese Lua-Skripte können von EmptyEpsilon Skripten eingebunden und verwendet werden.
