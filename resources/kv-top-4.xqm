module namespace _ = "sanofi/kv-top-4";

(: import repo modules :)
import module namespace global	= "influx/global";
import module namespace plugin	= "influx/plugin";
import module namespace db	    = "influx/db";
import module namespace ui =   "influx/ui";
import module namespace date-util ="influx/utils/date-utils";
import module namespace alert="influx/ui/alert";

declare namespace xhtml="http://www.w3.org/1999/xhtml";
declare variable $_:ns := namespace-uri(<_:ns/>);

declare %plugin:provide("datastore/name")
function _:datastore-name(
    $Schema as element(schema),
    $Context as map(*)
) as xs:string {
    'datastore-sanofi-kv-kenngroessen'
};


(: provide sorting for items :)
declare %plugin:provide("schema/process/table/items")
function _:schema-render-table-prepare-rows(
    $Items as element()*, 
    $Schema as element(schema),
    $Context as map(*)
) {
  if ($Context?context-item-id) 
  then $Items[kv=$Context?context-item-id]
  else for $x in $Items order by $x/datum return $x
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
        <label>Link</label>
    </element>
  </schema>
};


