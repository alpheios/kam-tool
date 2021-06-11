module namespace _ = "sanofi/quote";

(: import repo modules :)
import module namespace global	= "influx/global";
import module namespace plugin	= "influx/plugin";
import module namespace db	    = "influx/db";
import module namespace ui =   "influx/ui";
import module namespace date-util ="influx/utils/date-utils";

declare namespace xhtml="http://www.w3.org/1999/xhtml";

(:
  Quote von Ärzten nach Fachrichtung je Regelung
:)

declare variable $_:fachrichtungen-regelungen := plugin:lookup("plato/schema/enums/get")!.("Fachrichtungen Regelungen");
declare variable $_:merkmale-quote := plugin:lookup("plato/schema/enums/get")!.("Merkmale Quote");


declare %plugin:provide("schema/render/page/debug/itemXXX") function _:debug-kk ($Item,$Schema,$Context){
<pre>{serialize($Item)}</pre>
};

declare %plugin:provide("datastore/name")
function _:datastore-name(
    $Schema as element(schema),
    $Context as map(*)
) as xs:string {
    'datastore-sanofi-quote'
};


declare %plugin:provide("schema/set/elements","stammdaten/regelung")
function _:schema-column-filter($Item as element()*, $Schema as element(schema), $Context as map(*)){
    let $columns := ("fachrichtung","datum","quotentyp","quotenwert")
    let $schema := $Schema update delete node ./*:element
    let $elements-in-order := for $name in $columns return $Schema/element[@name=$name]
    let $schema := $schema update insert node $elements-in-order as last into .
    return $schema
};

declare %plugin:provide("schema/set/elements","kv")
function _:schema-column-filter-kv($Item as element()*, $Schema as element(schema), $Context as map(*)){
    let $columns := ("fachrichtung","datum","quotentyp","quotenwert")
    let $schema := $Schema update delete node ./*:element
    let $elements-in-order := for $name in $columns return $Schema/element[@name=$name]
    let $schema := $schema update insert node $elements-in-order as last into .
    return $schema
};


declare %plugin:provide("schema") function _:schema()
as element(schema){
<schema xmlns="" name="quote" domain="sanofi" provider="sanofi/quote">
    <modal>
        <title>Quote</title>
    </modal>
   <element name="quotentyp" type="enum">
      {$_:merkmale-quote ! <enum key="{.}">{.}</enum>}
      <label>Quotentyp</label>
    </element> 
    <element name="quotenwert" type="number" max="100" min="0">
        <label>Quotenwert</label>
    </element>
    <element name="regelung" type="foreign-key" render="context-item" required="">
        <provider>sanofi/regelung</provider>
        <key>@id</key>
        <display-name>name</display-name>
    </element>
    <element name="fachrichtung" type="enum">
        <label>Fachrichtung</label>
        {$_:fachrichtungen-regelungen ! <enum key="{.}">{.}</enum>}
    </element>
  </schema>
};


