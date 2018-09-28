module namespace _ = "sanofi/ansprechpartner/einfluss";

import module namespace plugin  = "influx/plugin";

declare variable $_:rollen := plugin:lookup("plato/schema/enums/get")!.("Rollen");

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
    <element name="produkt" type="foreign-key" async="" minimumInputLength="2" render="dropdown">
      <provider>sanofi/produkt</provider>
      <key>@id</key>
      <display-name>string-join((name/string(), " - (", herstellername/string(), ")"))</display-name>
      <label>Produkt</label>
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