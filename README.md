# km_press_to_rss

Generiert einen RSS feed aus den Pressemitteilungen des Landkreis Meissen (http://www.kreis-meissen.org/61.html).

Feed Beispiel: https://kokolor.es/extern_rss/km_pressemitteilungen.xml

## Installation

### Abhängigkeiten

* [Lua](https://lua.org) (>= 5.1)
* [luasocket](https://github.com/diegonehab/luasocket)
* [lua-htmlparser](https://github.com/msva/lua-htmlparser)
* [etlua](https://github.com/leafo/etlua)
* [date](https://github.com/Tieske/date)

### Mit Luarocks

* Lua installieren - entweder aus dem [Quellcode](https://www.lua.org/download.html) selbst bauen oder über den Paketmanager eures Betriebssystems installieren
* [Luarocks installieren](https://github.com/luarocks/luarocks/wiki/Installation-instructions-for-Unix)
* Skript mit luarocks installieren:
```
luarocks install https://codeberg.org/imo/km_press_to_rss/raw/branch/main/km_press_to_rss-dev-1.rockspec
```

### Manuell

Erst einmal cloned man dieses Repository. Für Lua und LuaSocket gibt es in vielen Distributionen Pakete, die man einfach über den Paketmanager installieren kann. Die restlichen 3 Module sind pure Lua Module ohne weitere Abhängigkeiten, welche einfach in den Ordner, in welchem das Skript liegt, heruntergeladen werden können.

## Benutzen

Wurde das Skript mit Luarocks installiert, kann man auf der Konsole folgendes eingeben:
```
km_press_to_rss
```
Denn luarocks installiert das Skript in der Regel in einen Ordner, der sich in der Variable `$PATH` befindet.

---

Wurde das Skript manuell installiert, führt man es direkt aus dem Ordner aus:
```
km_press_to_rss.lua
```

---

Führt man das Skript ohne Argumente aus, geht es davon aus die `template.xml` im derzeitigen Verzeichnis zu finden und schreibt auch das Ergebnis, sowie die Logdatei in dieses. Dem Skript können aber drei Argumente übergeben werden um dieses Verhalten zu ändern:
```
km_press_to_rss.lua template.xml output.rss log.log
```

**Hinweis**: Das Skript parsed keine Argumente. Sieht es argument 1, setzt es dieses, egal was es ist, was dann natürlich dazu führt das das Skript fehlschlägt.
Bsp.:
```
km_press_to_rss.lua log.log
```
Würde dazu führen das das Skript versucht eine Datei `log.log` als Template für den RSS Feed zu laden. Wenn man Argumente angibt sollte man also besser alle angeben.
