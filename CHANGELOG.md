# Changes
## Version 2.3.1 [20.01.2022]
* Fehlermeldungen wegen falscher Rückgabewerte (mehrere statt einer)
Bug-Fixes

## Version 2.3 [14.12.2021]
* Benutzer bekommen jetzt eine ordentliche Rückmeldung, wenn neue Items (alle) angelegt werdenn.

## Version 2.2 [21.11.2021] Refactoring, Performance Optimierungen, multimodale Dialoge
* das Refactoring betrifft die Änderungen an influx -> insb. Abschaffung schema-ui-adapter
* Performance Optimierungen -> Tabellen haben für bestimmte Einträge jeweils teure Abfragen gemacht, diese werden jetzt nur noch einmal gemacht
** Request-Parameter
* contextType = page | modal werden jetzt konsistenter behandelt
* modal = zeigt die Tiefe der modalen Dialoge an
* schema/list/items kann jetzt was schema/items/search kann -> daher wurde das ersetzt
* regelungen waren so langsam, dass sie ihre eigene spezialisierte Tabelle bekommen haben. Die Abfrage z.B. von Produkten und die Aufbereitung für die Tabelle werden jetzt in einem db:eval() Aufruf erledigt statt in tausenden
* in den stammdaten Bereichen werden jetzt aus der Basis-Liste direkt modale Dialoge aufgerufen, dann müssen die listen nicht mehr aktualisiert werden. Leider können die Basislisten nicht aktualisiert werden (TODO?)
* Auslagern von gemeinsamen Code in "common.xqm"
* ACHTUNG: CSV Import und Export verwenden nun Tabulatoren an Stelle von ";"
* ui/page/logo hinzugefügt
* schema/process/table/items wird jetzt konsistenter genutzt um die Elemente einer Tabelle zu filtern
* minimumInputLength wird verwendet für async dropdowns
* 

## Version 2.1 [01.11.2021] Update auf BaseX 9.6.3
refactoring: Code wurde zusammengelegt
diese Version funktioniert nur mit der aktuellen influx Version
* ui/page und ui/provider-page wurden endlich zusammengelegt
* influx/schema/ui-adapter wurde durch provider logik ergänzt

Migration für Produkte Felder:
Am besten über einen neuerlichen Import müssen die IDs durch "produktname" + " - " + "herstellername" ersetzt werden
Vorteil: 
die Anzeige der Liste, in denen Produkte angezeigt werden lädt schneller
die Auswahl von Produkten ist um ein vielfaches schneller

## Version 2.0 [01.10.2021] BugFixes
Update auf 9.6.1

## Version 2.0b [17.09.2021] Update auf BaseX 9.6
fixed: kk-management-summary / kk-top-4: Datum wird jetzt korrekt als z.B. 2021/Q1 angezeigt in den Kenngrößen bei KK
Update auf BaseX 9.6

TODO: refresh einzelner Forms

## Version 1.4 [18.12.2020] Regelungen haben eine zusätzliche Beziehung zu einem neuen Schema sanofi/quote
added: resources/quote.xqm
added: feld quote in resource/regelung.xqm

added: Regelungen können jetzt kopiert werden. Dazu kann ein copy button (fa-copy) in der Stammdaten Liste verwendet werden. Nach dem kopieren bekommt das Original-Item das Attribut "readonly". Die Buttons sind nur für Regelungen so angepasst, dass readonly Items mit einer Schneeflocke statt den Edit-Buttons angezeigt werden. 


## Version 1.3 [14.12.2020] Regelungen können über Admin-Menü importiert werden.

added: views/import-regelungen/
added: views/import-regelungen/regelungen-import-api.xqm
added: views/import-regelungen/regelungen-import.xqm
added: static/js/configureDropzoneForRegelungenCSV.js

kam-tool-import.xqm: added imports for "import-regelungen/*.xqm"
kam-tool-providers.xqm: added navigation-item - damit der neue Importer auch in der Navigation angezeigt wird.

Wenn Regelungen (CSV) ohne ID importiert werden, dann wird für jede Zeile ohne ID eine neue Regelung angelegt. 
Gibt es für die ID schon eine Regelung, dann wird diese überschrieben. 
In der Voransicht werden leerlaufende Referenzen auf Produkte und KVen rot markiert. Grün markierte Referenzen wurden gefunden. 

## Version 1.2 [25.11.2020]
*c: Regelungen SSB, Merkmale Regelungen hidden, neu QuotenTypen und Fachrichtung auf deie die Regelungen wirken. Neu KAM HC Fazit. Umbennung Ampel in Wetter
*c: Allg zur Prüfmeth / PBS auf KV Ebene
## Version 1.1.00 [2019-12-16]
*c: Icon KK (Line 18 u.27) und LAV (Line 17)
*New: Tracking.xqm, Eintrag in KAM-Tool-Import.xqm, Line 19
*CR: Datenexport in Stammdaten Sichbarkeit für alle
*c: Ansprechpartner - Einfluss -> Produkt mulitble Auswahl "ansprechpartner-einfluss.xqm" Zeile 32
## Version 1.0.12 [2019-09-05]
*c: Ansprechpartner - Einfluss -> Produkt mulitble Auswahl "ansprechpartner-einfluss.xqm" Zeile 32

## Version 1.0.11 [2019-07-25]
* c: Regelungen: Zeile ~200; Max Länge der Ampelbeschreibung auf 120 hoch gesetzt

## Version 1.0.10 [2019-07-85]
* cr: bug fix elemente können nicht gefundne werden: Lösung Element Tracking & Ampel Type-> hidden

## Version 1.0.9 [2019-07-05]
* c: Regelungen: Ampelsystem durch Effekt ersetzt
* c: Regelungen:Datum ab jetz wird das Quelldatum AMV, SSB, & PBS im entsprechennen Datumsfeld eiingetragen, das Datum letzte Änderung zeigt die aktualität der Gesamteintragung
* c: Regelungen: Merkmale der AMV hinzugefügt
* c: Regelungen: Element impact auf max 0 gestellt; Felher beim speichern der aufgerufenen Regelung, sodass hoffentlich die Ampel gepfelgt wird
* c: Regelungen: Hilfe erstellt

## Version 1.0.8 [2019-06-27]
* c: Try catch abfang des Fehlers für Kassen ohne Top4 - Import Werte managamentsummary Zeile 138ff

## Version 1.0.7 [2019-06-05]
* C: Farben Blauer Ozean Soll=blau, Zeile 260 & 186 verändert
* C: KV Regerlungen EDIT als Modal (eigenes Fenster), nicht mehr als eigene Seite -> auto.aktualisierung; KV.xqm Zeile 25ff
* C: Vertragseigenschaften KK ersetzt ServicePartner; Leider ist ServicePartner noch als Label bei AuswahlWerte festgelegt ->Vertrag.xqm Zeile 153ff 
* C: Regelungen mit Quoten für Fachrichungen erweitert Regelungen Zeile 163ff
* C: Hilfe möglich - Bsp siehe ganz unten in Regelungen

## Version 1.0.6 [2019-06-04]
* CR: Impactwert neues Element erstellt, Werte 0 bis 4 als  "enum"

## Version 1.0.5 [2018-11-15]
* CR: removed admin constraint from add button for schema type "Regelung"


## Version 1.0.4 [2018-11-14]
* FIXED: Use cp1252 encoding for product import (three more places)

## Version 1.0.3 [2018-11-14]
* FIXED: Use cp1252 encoding for product import

## Version 1.0.2 [2018-10-28]
* Management-Summary view:
    * CR: Marktanteil nur mit einer Nachkommastelle
    * CR: Arzneimittel Marktanteil nur mit einer Nachkommastelle
    * CR: Mitgliederanzahl in thousands

## Version 1.0.1 [2018-10-28]
* CR: Numbers can now use german locale, but will need schema app version 1.0 to display correctly
* Arzneimittelausgaben in thousands
* CR: "management-summary": numbers in y-axis use german locale
* CR: "management-summary": numbers in tables will use number-format and number-locale to display german style number i.e.: 1.000.000,00 instead of 1,000,000.00


## Version 1.0 [2018-10-26]
* CR: "Regelungen" - added extra field "tracking"
* CR: "kk-top-4" - "Versicherten Anzahl" additionally reads "in tausend" values are divided by 1000
* CR: "kk-top-4" - "Arzneimittelausgaben" additionally reads "in tausend", values are divided by 1000
* CR: "kk-top-4" - all dates are displayed in "DD. MM. YYYY" picture
* removed trace()
* fixed error in comment
* dependency: schema 1.0
* dependency: schema-exporter 1.0.1


## Version 0.3.4
* fixed: Blauer Ozean enum values would not change, when edited in admin module "Auswahlwerte festlegen"
* fixed: renamed "Blauer Ozean Files" for enums
* changed: Version info 0.3.4 in modules.xml

## Version 0.3.0 - 0.3.3
* fixed: Enum values with "slashes" -> stack dump
* removed: several traces
* CR: all "Notizen" fields in all schemas renamed to "Link" upon customer request

