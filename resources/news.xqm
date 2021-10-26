module namespace _ = "sanofi/news";

import module namespace plugin  = "influx/plugin";
declare variable $_:ns := namespace-uri(<_:ns/>);

declare %plugin:provide("schema/set/elements")
function _:schema-render-table-prepare-rows-only-name(
  $Items as element()*, 
  $Schema as element(schema),
  $Context as map(*)
) {
    let $columns := ("kam", "produkt", "thema")
    let $schema := $Schema update delete node ./*:element
    let $elements-in-order := for $name in $columns return $Schema/element[@name=$name]
    let $schema := $schema update insert node $elements-in-order as last into .
    return $schema
};

(:
  Provider für die Profilseiten Widgets
:)


declare %plugin:provide("schema") 
function _:schema-customer-influence()
as element(schema){
<schema xmlns="" name="news" domain="sanofi" provider="sanofi/news">
    <modal>
        <title>Neuigkeiten und Gesprächsthemen</title>
    </modal>
    <element name="kam" type="foreign-key" render="dropdown" multiple="" default="{_:get-current-key-accounter-id()}">
      <provider>sanofi/key-accounter</provider>
      <key>@id/string()</key>
      <display-name>name/string()</display-name>
      <label>Key Accounter</label>
      <class>col-md-6</class>
    </element>
    <element name="produkt" type="foreign-key" async="" minimumInputLength="2" render="dropdown">
      <provider>sanofi/produkt</provider>
      <key>@id</key>
      <display-name>string-join((name/string(), " - (", herstellername/string(), ")"))</display-name>
      <label>Produkt</label>
    </element>
    <element name="thema" type="textarea">
      <label>Thema</label>
    </element>
    <element name="notizen" type="textarea">
        <label>Link</label>
    </element>
 </schema>
};




declare %plugin:provide("profile/dashboard/widget")
function _:profile-dashboard-widget-regelungen($Profile as element())
{
<div class="col-md-12">
  {
    let $context := map {}
    let $schema := plugin:provider-lookup("sanofi/news","schema")!.()
    let $items  := plugin:provider-lookup("sanofi/news","datastore/dataobject/all")!.($schema,$context)
    return
        plugin:lookup("schema/render/table/page")!.($items,$schema,$context)
  }
</div>
};

declare %plugin:provide("schema/render/form/field/layout/colums")
function _:set-number-of-columns-in-layout(
  $Item,
  $Element,
  $Context
) as xs:integer {
  1
};

declare function _:get-current-key-accounter-id() {
    let $current-username := plugin:lookup("username")!.()
    let $key-accounter-provider := "sanofi/key-accounter"
    let $key-accounter-schema := plugin:provider-lookup($key-accounter-provider, "schema")!.()
    let $context := map {}
    let $key-accounter-id := plugin:provider-lookup("sanofi/key-accounter", "datastore/dataobject/field")!.("username", $current-username, $key-accounter-schema, $context)/@id/string()
    return $key-accounter-id
};



