module namespace _ = "sanofi/kk-top-4";

(: import repo modules :)
import module namespace global	= "influx/global";
import module namespace plugin	= "influx/plugin";
import module namespace db	    = "influx/db";
import module namespace ui =   "influx/ui";
import module namespace date-util ="influx/utils/date-utils";

declare namespace xhtml="http://www.w3.org/1999/xhtml";
declare variable $_:ns := namespace-uri(<_:ns/>);


declare %plugin:provide("schema/render/page/debug/itemXXX") function _:debug-kk ($Item,$Schema,$Context){
<pre>{serialize($Item)}</pre>
};

declare %plugin:provide("datastore/name")
function _:datastore-name(
    $Schema as element(schema),
    $Context as map(*)
) as xs:string {
    'datastore-sanofi-kk-kenngroessen'
};

declare %plugin:provide("schema/process/table/items","kk-history")
function _:schema-render-table-prepare-rows-jf($Items as element()*, $Schema as element(schema),$ContextMap as map(*))
{
for $item in $Items order by $item/datum 
let $fixed-date-item := try {$item update replace value of node ./datum with fn:format-date(./datum, "[YYYY]/[DD]" )}catch * {$item}
let $fixed-date-item := 
  try {
      $fixed-date-item update replace value of node ./datum with 
        ((./datum=>substring-before("/"))||"/"||(
              switch (./datum=>substring-after('/')) 
              case '1' return "Q1" 
              case '10' return "Q4"
              case '4' return "Q2"
              case '7' return "Q3"
              default return "Q1"))}
  catch * {$fixed-date-item} 

return $fixed-date-item[kk=$ContextMap?context-item-id]
};

declare %plugin:provide("schema/set/elements","kk-history")
function _:schema-column-filter($Item as element()*, $Schema as element(schema), $Context as map(*)){
    let $columns := ("name","datum","anzahl","marktanteil", "arzneimittelausgaben", "arzneimittelausgaben_marktanteil")
    let $schema := $Schema update delete node ./*:element
    let $elements-in-order := for $name in $columns return $Schema/element[@name=$name]
    let $schema := $schema update insert node $elements-in-order as last into .
    (: :)
    let $schema := $schema update replace value of node ./element[@name='datum']/@type with "text"
    return $schema
};


declare %plugin:provide("schema") function _:schema()
as element(schema){
<schema xmlns="" name="kk-top-4" domain="sanofi" provider="sanofi/kk-top-4">
    <modal>
        <title>KK Versicherte</title>
    </modal>
    <element name="name" type="text">
        <label>Name</label>
    </element>
    <element name="datum" type="date" default="{date-util:current-date-to-html5-input-date()}">
        <label>Datum</label>
    </element>
    <element name="anzahl" type="number" number-format="#.###" number-locale="de">
        <label>Mitglieder Anzahl</label>
    </element>
    <element name="marktanteil" type="number" number-format="#.###,0" number-locale="de" max="100">
        <label>Mitglieder Marktanteil (%)</label>
    </element>
    <element name="arzneimittelausgaben" type="number" number-format="#.###" number-locale="de">
        <label>Arzneimittelausgaben (€)</label>
    </element>
    <element name="arzneimittelausgaben_marktanteil" type="number" number-format="#.###,0" number-locale="de" max="100">
        <label>Marktanteil Arzneimittelausgaben (%)</label>
    </element>
    <element name="kk" type="foreign-key" render="context-item" required="">
        <provider>sanofi/kk</provider>
        <key>@id</key>
        <display-name>name</display-name>
    </element>
    <element name="notizen" type="textarea">
        <label>Link</label>
    </element>
  </schema>
};


