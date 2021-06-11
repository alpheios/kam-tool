module namespace _ = "sanofi/kv-arztzahlen";

(: import repo modules :)
import module namespace global	= "influx/global";
import module namespace plugin	= "influx/plugin";
import module namespace db	    = "influx/db";
import module namespace ui =   "influx/ui";
import module namespace date-util ="influx/utils/date-utils";

declare namespace xhtml="http://www.w3.org/1999/xhtml";

declare variable $_:fachrichtungen := plugin:lookup("plato/schema/enums/get")!.("Fachrichtungen KV Kennzahlen");

declare %plugin:provide("schema/render/page/debug/itemXXX") function _:debug-kk ($Item,$Schema,$Context){
<pre>{serialize($Item)}</pre>
};

declare %plugin:provide("datastore/name")
function _:datastore-name(
    $Schema as element(schema),
    $Context as map(*)
) as xs:string {
    'datastore-sanofi-kv-arztzahlen'
};

declare %plugin:provide("schema/process/table/items")
function _:schema-render-table-prepare-rows-jf(
    $Items as element()*, 
    $Schema as element(schema),
    $Context as map(*)
) {
    for $item in $Items 
    order by $item/datum 
    return $item
};

declare %plugin:provide("schema/set/elements")
function _:schema-column-filter($Item as element()*, $Schema as element(schema), $Context as map(*)){
    let $schema-fachrichtung-elements :=
        for $fachrichtung in $_:fachrichtungen
        return "zahl-"||lower-case(translate($fachrichtung, " /:;", "--"))
    let $columns := (("name","datum"), $schema-fachrichtung-elements)
    let $schema := $Schema update delete node ./*:element
    let $elements-in-order := for $name in $columns return $Schema/element[@name=$name]
    let $schema := $schema update insert node $elements-in-order as last into .
    return $schema
};


declare %plugin:provide("schema") function _:schema()
as element(schema){
<schema xmlns="" name="kv-arztzahlen" domain="sanofi" provider="sanofi/kv-arztzahlen">
    <modal>
        <title>KV Arztzahlen</title>
    </modal>
    <element name="name" type="text">
        <label>Name</label>
    </element>
    <element name="datum" type="date" default="{date-util:current-date-to-html5-input-date()}">
        <label>Datum</label>
    </element>
    {
        for $fachrichtung in $_:fachrichtungen
        let $element-name := "zahl-"||lower-case(translate($fachrichtung, " ", "-"))
        return
            <element name="{$element-name}" type="number">
                <label>{$fachrichtung}</label>
            </element>
    }
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


