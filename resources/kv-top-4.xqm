module namespace _ = "sanofi/kv-top-4";

(: import repo modules :)
import module namespace global	= "influx/global";
import module namespace plugin	= "influx/plugin";
import module namespace db	    = "influx/db";
import module namespace ui =   "influx/ui2";
import module namespace date-util ="influx/utils/date-utils";

declare namespace xhtml="http://www.w3.org/1999/xhtml";


declare %plugin:provide("schema/render/page/debug/itemXXX") function _:debug-kk ($Item,$Schema,$Context){
<pre>{serialize($Item)}</pre>
};

declare %plugin:provide("datastore/name")
function _:datastore-name(
    $Schema as element(schema),
    $Context as map(*)
) as xs:string {
    'datastore-sanofi-kv-kenngroessen'
};

declare %plugin:provide("schema/process/table/items","kv-history")
function _:schema-render-table-prepare-rows-jf($Items as element()*, $Schema as element(schema),$Context as map(*))
{
for $item in $Items order by $item/datum return $item
};

declare %plugin:provide("schema/set/elements","kv-history")
function _:schema-column-filter($Item as element()*, $Schema as element(schema), $Context as map(*)){
    let $columns := ("name","datum","besonderheiten","verbindungen")
    let $schema := $Schema update delete node ./*:element
    let $elements-in-order := for $name in $columns return $Schema/element[@name=$name]
    let $schema := $schema update insert node $elements-in-order as last into .
    return $schema
};


declare %plugin:provide("schema") function _:schema()
as element(schema){
<schema xmlns="" name="kv-top-4" domain="sanofi" provider="sanofi/kv-top-4">
    <modal>
        <title>KV Kenngrößen</title>
    </modal>
    <element name="name" type="text">
        <label>Name</label>
    </element>
    <element name="datum" type="date" default="{date-util:current-date-to-html5-input-date()}">
        <label>Datum</label>
    </element>
    <element name="besonderheiten" type="textarea">
        <label>Besonderheiten</label>
    </element>
    <element name="verbindungen" type="textarea">
        <label>Verbund/Verbindungen</label>
    </element>
    <element name="kv" type="foreign-key" render="context-item" required="">
        <provider>sanofi/kv</provider>
        <key>@id</key>
        <display-name>name</display-name>
    </element>
    <element name="notizen" type="textarea">
        <label>Notizen</label>
    </element>
  </schema>
};

