module namespace _ = "sanofi/kk-history-mitglieder";

(: import repo modules :)
import module namespace global	= "influx/global";
import module namespace plugin	= "influx/plugin";
import module namespace db	    = "influx/db";
import module namespace ui =   "influx/ui2";
import module namespace util ="influx/utils/date-utils";

declare namespace xhtml="http://www.w3.org/1999/xhtml";


declare %plugin:provide("schema/render/page/debug/itemXXX") function _:debug-kk ($Item,$Schema,$Context){
<pre>{serialize($Item)}</pre>
};

declare %plugin:provide("schema/process/table/items","kk-history")
function _:schema-render-table-prepare-rows-jf($Items as element()*, $Schema as element(schema),$Context as map(*))
{
for $item in $Items order by $item/datum return $item
};

declare %plugin:provide("schema/set/elements","kk-history")
function _:schema-column-filter($Item as element()*, $Schema as element(schema), $Context as map(*)){
    let $columns := ("name","datum","anzahl","marktanteil")
    let $schema := $Schema update delete node ./*:element
    let $elements-in-order := for $name in $columns return $Schema/element[@name=$name]
    let $schema := $schema update insert node $elements-in-order as last into .
    return $schema
};

declare %plugin:provide("schema/render/form/field/date","datum") (: Achtung: "kk" ist hier nicht der Kontext, sondern der Feldname! :)
function _:sanofi-kk-history-mitglieder-kk-input-datum($Item as element(kk-history-mitglieder), $Element as element(element), $Context as map(*))
as element()?
{
    let $datum := if ($Item/datum/string()) then $Item/datum/string() else util:current-date-to-html5-input-date()

    return <input xmlns="http://www.w3.org/1999/xhtml" class="form-control" name="datum" value="{$datum}" type="date"/>
};

declare %plugin:provide("schema") function _:schema()
as element(schema){
<schema xmlns="" name="kk-history-mitglieder" domain="sanofi" provider="sanofi/kk-history-mitglieder">
    <modal>
        <title>KK Versicherte</title>
        <button>
            <add>hinzufügen</add>
            <cancel>abbrechen</cancel>
            <modify>ändern</modify>
            <delete>löschen</delete>
        </button>
    </modal>
    <element name="name" type="text">
        <label>Name</label>
    </element>
    <element name="datum" type="date">
        <label>Datum</label>
    </element>
    <element name="anzahl" type="number">
        <label>Mitglieder Anzahl</label>
    </element>
    <element name="marktanteil" type="number">
        <label>Mitglieder Marktanteil</label>
    </element>
    <element name="kk" type="foreign-key" render="context-item" required="">
        <provider>sanofi/kk</provider>
        <key>@id</key>
    </element>
  </schema>
};


