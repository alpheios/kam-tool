module namespace _ = "sanofi/ansprechpartner/einfluss";

import module namespace plugin  = "influx/plugin";
import module namespace import = "influx/modules";
import module namespace alert ="influx/ui/alert";
declare namespace xhtml="http://www.w3.org/1999/xhtml";


declare variable $_:rollen := plugin:lookup("plato/schema/enums/get")!.("Rollen");
declare variable $_:ns := namespace-uri(<_:ns/>);

declare %plugin:provide("schema/set/elements")
function _:schema-render-table-prepare-rows-only-name(
  $Items as element()*, 
  $Schema as element(schema),
  $Context as map(*)
) {
    let $columns := ("produkt", "thema", "rolle")
    let $schema := $Schema update delete node ./*:element
    let $elements-in-order := for $name in $columns return $Schema/element[@name=$name]
    let $schema := $schema update insert node $elements-in-order as last into .
    return $schema
};

declare %plugin:provide("schema/process/table/items")
function _:schema-process-table-items(
    $Items as element()*, 
    $Schema as element(schema),
    $Context as map(*)
) {
  $Items[ansprechpartner=$Context?context-item-id]
};

declare
    %plugin:provide("schema/render/new")
function _:management-summary-render-new(
  $Item as element(), 
  $Schema as element(schema), 
  $Context as map(*)
) {
    (
        alert:info("Neue Ansprechpartner-Einfluss angelegt.")
        ,plugin:default("schema/render/new")!.($Item,$Schema,$Context)
    )
};


declare %plugin:provide("schema") 
function _:schema-customer-influence()
as element(schema){
<schema xmlns="" name="einfluss" domain="sanofi" provider="sanofi/ansprechpartner/einfluss">
    <modal>
        <title>Einfluss</title>
    </modal>
    <element name="ansprechpartner" type="foreign-key" render="context-item">
      <key>@id</key>
      <provider>sanofi/ansprechpartner</provider>
      <display-name>name/string()</display-name>
    </element>
     <element name="produkt" type="foreign-key" render="dropdown" multiple="" async="" minimumInputLength="3" delay="250" required="">
        <provider>sanofi/produkt</provider>
        <key>@id</key>
        <display-name>string-join((name/string(), " - (", herstellername/string(), ")"))</display-name>
        <label>Produkt</label>
        <query><![CDATA[let $produkte := collection('datastore-sanofi-produkt')/produkt
let $context-item := collection('datastore-sanofi-ansprechpartner-einfluss')/ansprechpartner-einfluss[@id=$context-item-id]
let $linked-products := $context-item/produkt/key/string()
let $selected := $produkte[@id=$linked-products]
let $search := $produkte[lower-case(string-join(.//text(),' ')) => contains(lower-case($term))][not(@id=$linked-products)]
return (
  $selected ! <element id="{./@id/string()}" selected="true">{string-join((normalize-space(./name),./herstellername)," - ")}</element> 
 ,$search   ! <element id="{./@id/string()}" selected="false">{string-join((normalize-space(./name),./herstellername)," - ")}</element>
)]]></query>
        <class>col-md-6</class>
    </element>
    <element name="thema" type="text">
      <label>Thema</label>
    </element>
    <element name="rolle" type="enum" required="">
      {$_:rollen ! <enum key="{.}">{.}</enum>}
      <label>Rolle</label>
    </element>
    <element name="notizen" type="textarea">
        <label>Link</label>
    </element>
 </schema>
};