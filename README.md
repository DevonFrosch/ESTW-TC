###### ESTW-TC

Ein elektronisches Stellwerk für den Minecraft-Mod [ComputerCraft](https://www.computercraft.info/).

#### Aufbau Config-Datei

Die Projektierung des Stellwerks (Konfiguration der Anzeige, Ein-/Ausgänge etc.) erfolgt über eine Config-Datei im Lua-Format.

### Stellwerks-Config

Folgende Konstanten sollten am Anfang der Config-Datei definiert werden:
``` lua
local SIGNAL_HP = "hp"
local SIGNAL_SH = "sh"
local SIGNAL_ERS = "ers"
local SIGNAL_ZA = "za"
local WEICHE_GERADE = 0
local WEICHE_ABZW = 1
```

Bei Eingängen gibt es zwei Aktionen:
- `Wenn an` Aktion wird einmalig ausgeführt, wenn ein Redstone-Signal angelegt wird
- `Solange an` Aktion wird dauerhaft ausgeführt, solange ein Redstone-Signal anliegt

Datentyp "Eingang": Table mit folgenden Werten:
- `pc`
	Zahl oder String: Bezeichnung des Clients
- `au`
	String: Seite des Clients, einer aus {"top", "bottom", "left", "right", "front", "back"}
- `fb`
	Zahl: Farbe im Bundled Cable, siehe [ComputerCraft-Wiki](http://www.computercraft.info/wiki/Colors_(API)#Colors)

Datentyp "Position":
- `x` Zahl: Position des Signals im Gleisbild auf der X-Achse, linkeste Spalte ist 1
- `y` Zahl: Position des Signals im Gleisbild auf der Y-Achse, oberste Zeile ist 1

Die Reihenfolge der benannten Schlüssel kann beliebig geändert werden.

- `signale`
	Signale werden zum Anzeigen von Signalbegriffen sowie zum Einstellen von Fahrstraßen verwendet.
	
	Ein Klick schreibt den Namen des Signals in das Feld EIN und stellt ggf. eine Fahrstraße ein.
	
	Hat ein Signal entweder die Eigenschaft "hp" oder "stelle_hp", wird es als Hauptsignal angezeigt.
	Hat ein Signal entweder die Eigenschaft "stelle_za" oder "za", ist das Signal eine Zustimmungsabgabe an ein anderes Stellwerk, ohne ein Signal vor Ort zu stellen.
	In allen anderen Fällen wird ein Sperrsignal angezeigt.
	
	"hp" und "stelle_hp" sollten nicht gleichezeitig verwendet werden, genauso wie "sh" und "stelle_sh" sowie "za" und "stelle_za".
	- Name des Signals
		- Position: Positionierung auf dem Gleisbild
		- `richtung`
		String: Ausrichtung des Signals, einer aus {"l", "r"}
		- `hp`
		Eingang: Solange an wird das Signal als grün (Fahrtbegriff) angezeigt
		- `sh`
		Eingang: Solange an wird das Signal als weiß (Rangierfahrtbegriff) angezeigt
		- `za`
		Eingang: Solange an wird das Signal als orange (Zustimmungsabgabe) angezeigt
		- `stelle_hp`
		Ausgang: Ist an, wenn das Signal einen Fahrtbegriff zeigen soll
		- `stelle_sh`
		Ausgang: Ist an, wenn das Signal einen Rangierfahrtbegriff zeigen soll
		- `stelle_ers`
		Ausgang: Ist an, wenn das Signal einen Ersatzsignalbegriff zeigen soll
		- `stelle_za`
		Ausgang: Ist an, wenn das Signal eine Zustimmungsabgabe ist
		- `haltAbschnitte`
		Liste von Strings: Namen von Haltabschnitten oder Gleisen. Beim Belegen einer der Abschnitte wird das Signal auf Halt gestellt
		- `halt`
		Ausgang: Impuls, wenn das Signal im ESTW auf Halt gestellt wird
- `fsZiele`
	Verhält sich für das Einstellen von Fahrstraßen wie ein Signal.
	Ein Klick schreibt den Namen des Fahrstraßenziels in das Feld EIN und stellt ggf. eine Fahrstraße ein.
	
	- Name des Fahrstraßenziels
		- Position: Positionierung auf dem Gleisbild
		- `length`
		Zahl: Anzahl der Zeichen, die auf Klick reagieren sollen
- `fsAufloeser`
	- Name des FS-Auflösers
		- Eingang: Wenn an, werden alle Fahrstraßen, die den Namen des FS-Auflösers in "aufloeseAbschn" definiert haben, aufgelöst
- `bahnuebergaenge`
	- Name des Bahnübergangs
		- Eingang: Solange an, wird der Bahnübergang als gesichert angezeigt
		- Position: Positionierung auf dem Gleisbild
		- `hoehe`
			Zahl: Anzahl Zeilen, über die der Bahnübergang gezeichnet werden soll
- `gleise`
	- Name des Gleises
		- Eingang:
			- Solange an, wird das Gleis als Besetzt angezeigt.
			- Wenn an, werden Signale, die den Namen des Gleises in "haltAbschnitte" enthalten, auf Halt gestellt
			- Wenn an, werden Signale der Fahrstraßen, die den Namen des Gleises in "haltAbschnitte" enthalten, auf Halt gestellt
		- Position: Positionierung auf dem Gleisbild
		- `text`
			String: anzuzeigender Text (wird gefärbt)
		- `weiche` Table mit folgenden 2 Werten:
			- String: Name der Weiche
			- Zahl: Eine von {WEICHE_GERADE, WEICHE_ABZW}
- `weichen`
	- Name der Weiche
		- Ausgang: Ist an, wenn die Weiche abzweigend gestellt sein soll
- `fahrstrassenteile`
	Gleise können ebenfalls als FS-Teile verwendet werden und müssen bei gleichem Namen nicht zusätzlich hier definiert werden.
	
	Hinweis zur Benennung: Ist in der Fahrstraße das FS-Teil "A" definiert, werden davon die FS-Teile "A", "A/1", "A/2" und "A/3" angesprochen. Dies ist z.B. bei Kurven sinnvoll, wenn zusammengehörige Teile in verschiedenen Zeilen sind. Diese Regel gilt analog für Gleise.
	- Name des Fahrstraßenteils
		- Position: Positionierung auf dem Gleisbild
		- `text`
			String: anzuzeigender Text (wird gefärbt)
- `fahrstrassen`
	- Name der Fahrstraße: "Start.Ziel" für eine Zugstraße von Start nach Ziel, "Start-Ziel" für eine Rangierstraße von Start nach Ziel. Beispiel: "A.N1" für Signale A und N1 sowie "N1.XAP" für Signal A nach Fahrstraßenziel XAP
		- `fsTeile`
			Liste von Strings: Namen von Fahrstraßenteilen oder Gleisen, die gefärbt werden sollen, wenn die Fahrstraße eingestellt ist
		- `melder`
			Eingang: Solange an, wird die Fahrstraße als eingestellt angezeigt
		- `ausloeser`
			Eingang: Impuls, wenn die Fahrstraße eingestellt werden soll
		- `steller`
			Ausgang: Impuls, wenn die Fahrstraße eingestellt werden soll
		- `aufloeser`
			Ausgang: Impuls, wenn die Fahrstraße (manuell) augelöst werden soll
		- `gleise`
			Liste von Strings: Namen von Gleisen, die nicht belegt sein dürfen, wenn die Fahrstraße eingestellt werden soll
		- `signale`
			Signale, die einen Signalbegriff anzeigen sollen, wenn die Fahrstraße eingestellt ist. Wird die Fahrstraße aufgelöst, werden alle Signale der Fahrstraße auf Halt gestellt.
			- Name des Signals:
				String, einer aus {SIGNAL_HP, SIGNAL_SH, SIGNAL_ERS, SIGNAL_ZA}
		- `haltAbschnitte`
			Liste von Strings: Namen von Gleisen, wenn diese belegt werden, werden alle Signale der Fahrstraße auf Halt gestellt
		- `aufloeseAbschn`
			String: Name des Auflöseabschnitts, wenn dieser belegt wird, wird die Fahrstraße aufgelöst
		- `weichen`
			Liste von Strings: Namen von Weichen, die auf abzweigende Lage gebracht werden sollen
		- `rangieren`
			Boolean: Ob die Fahrstraße eine Rangierstraße (blau statt grün) ist, einer von {true, false}, default ist false
- `gleisbildDatei`
	String, erforderlich: Name der Datei mit dem Hintergrundtext für das Gleisbild
- `stellwerkName`
	String, erforderlich: Name des Stellwerks für die Kommunikation mit den Clients
- `bildschirm`
	String, erforderlich: Seite des Bildschirms, einer aus {"top", "bottom", "left", "right", "front", "back"}
- `modem`
	String, erforderlich: Seite des Modems, einer aus {"top", "bottom", "left", "right", "front", "back"}
- `speichereFahrstrassen`
	Boolean: Ob Fahrstraßen über einen Reboot des Stellwerks hinweg gespeichert werden sollen, einer von {true, false}, default ist false

### Client-Config

Die Config für Client-Rechner heißt dort ebenfalls `config.lua` und ist ungleich simpler:

- `stellwerkName`
	String, erforderlich: Name des Stellwerks für die Kommunikation mit dem Server
- `modem`
	String, erforderlich: Seite des Modems, einer aus {"top", "bottom", "left", "right", "front", "back"}
- `role`
	String, erforderlich: Name des Clients, wird in der Server-Config als `pc` referenziert
- `side`
	Liste mit Keys aus {"top", "bottom", "left", "right", "front", "back"} und Wert `true`

Im Beispiel unter stellwerke/Montabau liegt unter client.config.lua ein Beispiel, diese müsste aber in config.lua umbenannt werden.
