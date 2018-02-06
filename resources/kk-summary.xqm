module namespace _ = "sanofi/kk-summary";

import module namespace plugin  = "influx/plugin";
import module namespace date-util ="influx/utils/date-utils";

declare %plugin:provide("schema/process/table/items")
function _:schema-render-table-prepare-rows($Items as element()*, $Schema as element(schema),$Context as map(*)){for $item in $Items order by $item/datum return $item};

declare %plugin:provide("schema/set/elements")
function _:schema-render-table-prepare-rows-only-name(
  $Items as element()*, 
  $Schema as element(schema),
  $Context as map(*)
) {
    let $columns := ("datum", "ziele", "strategien", "meilensteine", "anforderungen")
    let $schema := $Schema update delete node ./*:element
    let $elements-in-order := for $name in $columns return $Schema/element[@name=$name]
    let $schema := $schema update insert node $elements-in-order as last into .
    return $schema
};

declare %plugin:provide("schema") 
function _:schema()
as element(schema){
<schema xmlns="" name="kk-summary" domain="sanofi" provider="sanofi/kk-summary">
    <modal>
        <title>Zusammenfassung</title>
        <button>
            <add>hinzufügen</add>
            <cancel>abbrechen</cancel>
            <modify>ändern</modify>
            <delete>löschen</delete>
        </button>
    </modal>
    <element name="name" type="text">
      <label>Titel</label>
    </element>
    <element name="datum" type="date" default="{date-util:current-date-to-html5-input-date()}">
      <label>Datum</label>
    </element>
    <element name="kk" type="foreign-key" required="" render="context-item">
      <provider>sanofi/kk</provider>
      <key>@id/string()</key>
      <display-name>name/string()</display-name>
    </element>
    <element name="ziele" type="html">
        <label>Ziele</label>
    </element>
    <element name="strategien" type="html">
        <label>Strategien</label>
    </element>
    <element name="meilensteine" type="html">
        <label>Meilensteine/Schlüsselaktionen</label>
    </element>
    <element name="anforderungen" type="html">
        <label>Anforderungen</label>
    </element>
  </schema>
};

