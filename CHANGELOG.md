#Changes

##Version 1.0.2 [2018-10-28]
* Management-Summary view:
    * CR: Marktanteil nur mit einer Nachkommastelle
    * CR: Arzneimittel Marktanteil nur mit einer Nachkommastelle
    * CR: Mitgliederanzahl in thousands

##Version 1.0.1 [2018-10-28]
* CR: Numbers can now use german locale, but will need schema app version 1.0 to display correctly
* Arzneimittelausgaben in thousands
* CR: "management-summary": numbers in y-axis use german locale
* CR: "management-summary": numbers in tables will use number-format and number-locale to display german style number i.e.: 1.000.000,00 instead of 1,000,000.00


##Version 1.0 [2018-10-26]
* CR: "Regelungen" - added extra field "tracking"
* CR: "kk-top-4" - "Versicherten Anzahl" additionally reads "in tausend" values are divided by 1000
* CR: "kk-top-4" - "Arzneimittelausgaben" additionally reads "in tausend", values are divided by 1000
* CR: "kk-top-4" - all dates are displayed in "DD. MM. YYYY" picture
* removed trace()
* fixed error in comment
* dependency: schema 1.0
* dependency: schema-exporter 1.0.1


##Version 0.3.4
* fixed: Blauer Ozean enum values would not change, when edited in admin module "Auswahlwerte festlegen"
* fixed: renamed "Blauer Ozean Files" for enums
* changed: Version info 0.3.4 in modules.xml

##Version 0.3.0 - 0.3.3
* fixed: Enum values with "slashes" -> stack dump
* removed: several traces
* CR: all "Notizen" fields in all schemas renamed to "Link" upon customer request

