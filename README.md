# lkm-press-feed-generator

Generiert einen RSS feed aus den Pressemitteilungen des Landkreis Meissen (https://www.kreis-meissen.de/Aktuelles/Pressemitteilungen).

Es gibt zwar ein paar Webservices die einen genau das machen lassen was im Grunde dieses Skript hier tut, allerdings funktionierten die freien Varianten davon meist nicht so wie ich es wollte oder mein Feedreader wollte nicht so richtig mit dem Ergebnis klar kommen. ~~Außerdem hat man bei diesen Pressemitteilungen das Problem das diese außer dem Datum im Titel keinen anderen Zeitstempel haben und diese Webservices keine Möglichkeit boten diesen zu parsen.~~

Also entstand dieses Skript. Vielleicht findet es irgendwer hilfreich.

Schöner wäre es natürlich nenn RSS Feed auf der Seite zu haben. Falls das also hier jemand von der Pressestelle des Landsratamtes Meißen liest, bitte gebt uns einen RSS Feed! <3

### Update zum Status eines RSS Feed's auf der Seite selbst
Nachdem die Seite Ende 2022 modernisiert wurde, habe ich Kontakt mit der Pressestelle aufgenommen, um zu erfahren ob es nun einen RSS/Atom Feed gibt, welcher einfach nicht verlinkt ist oder ob sie planen noch einen bereit zu stellen. Die Antwort sah wie folgt aus:
```
vielen Dank für Ihre Nachricht und Ihrem Interesse an unseren Pressemitteilungen. Leider muss ich Ihnen
mitteilen, dass wir uns auch bei der neuen Website gegen einen RSS Feed entschieden haben. Wir gehen
davon aus, dass der Gebrauch von RSS Feeds durch die sozialen Medien mittlerweile überholt ist. Wir
versuchen immer die wichtigsten Meldungen über unsere Social Media Kanäle zu veröffentlichen, durch das
Folgen dieser sind Sie meist auf dem aktuellen Stand. Auch unangemeldet können Sie die Posts einsehen.
```
Meine Antwort, in welcher ich unter anderem die Vorteile von RSS erklärte (sowohl vom Datenschutz her, als auch von der Usability), als auch auch über alternative soziale Medien aufklärte, blieb leider bis heute unbeantwortet. D.h. einen RSS Feed wird es sobald nicht geben. Man kann nur hoffen das die sächsische Datenschutzbeauftrage die [Abschaltung der behördlichen Facebook-Auftritte](https://www.mdr.de/nachrichten/sachsen/politik/staedte-facebook-seiten-abschaltung-datenschutz-behoerde-100.html) durch bekommt und dann womöglich ein Umdenken stattfindet. Natürlich erst nachdem sie, vom Weinkrampf geschüttelt, den Datenschutz dafür verantwortlich machen das Bürger sich jetzt angeblich nicht mehr informieren können, nur um davon abzulenken das sie mindestens ein Jahrzehnt lang schlichtweg Alternativen ignoriert haben.

Feed Beispiel: https://kokolor.es/extern_rss/km_pressemitteilungen.xml

## Installation

### Abhängigkeiten

* [Lua](https://lua.org) (>= 5.1) und/oder [Fennel](https://fennel-lang.org/) (>= 1.3.0)
* [luasocket](https://github.com/diegonehab/luasocket)
* [luasec](https://github.com/brunoos/luasec)
* [lua-htmlparser](https://github.com/msva/lua-htmlparser)
* [htmlEntities](https://github.com/TiagoDanin/htmlEntities-for-lua)
* [etlua](https://github.com/leafo/etlua)
* [date](https://github.com/Tieske/date)

### Mit Luarocks

* Lua und/oder Fennel installieren
   * Lua: Entweder aus dem [Quellcode](https://www.lua.org/download.html) selbst bauen oder über den Paketmanager eures Betriebssystems installieren
   * Fennel: Es gibt verschiedene Arten [Fennel zu installieren](https://fennel-lang.org/setup#downloading-fennel)
* [Luarocks installieren](https://github.com/luarocks/luarocks/wiki/Installation-instructions-for-Unix)
* Skript mit luarocks installieren:
```
luarocks install https://codeberg.org/imo/lkm-press-feed-generator/raw/branch/main/lkm-press-feed-generator-dev-1.rockspec
```

### Manuell

Erst einmal cloned man dieses Repository. Für Lua und LuaSocket gibt es in vielen Distributionen Pakete, die man einfach über den Paketmanager installieren kann. Die restlichen 3 Module sind pure Lua Module ohne weitere Abhängigkeiten, welche einfach in den Ordner, in welchem das Skript liegt, heruntergeladen werden können.

## Benutzen

Wurde das Skript mit Luarocks installiert, kann man auf der Konsole folgendes eingeben:
```
lkm-press-feed-generator
```
Denn luarocks installiert das Skript in der Regel in einen Ordner, der sich in der Variable `$PATH` befindet.

---

Wurde das Skript manuell installiert, führt man es direkt aus dem Ordner aus:
```
lua lkm-press-feed-generator.lua
```
oder
```
fennel lkm-press-feed-generator.fnl
```

---

Führt man das Skript ohne Argumente aus, geht es davon aus die `template.xml` im derzeitigen Verzeichnis zu finden und schreibt auch das Ergebnis, sowie die Logdatei in dieses. Dem Skript können aber drei Argumente übergeben werden um dieses Verhalten zu ändern:
```
fennel lkm-press-feed-generator.fnl -t template.xml -o output.rss -l log.log
```