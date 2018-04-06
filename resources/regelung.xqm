module namespace _ = "sanofi/regelung";

(: import repo modules :)
import module namespace global  = "influx/global";
import module namespace plugin  = "influx/plugin";
import module namespace db      = "influx/db";
import module namespace ui =" influx/ui2";
import module namespace date-util ="influx/utils/date-utils";

declare namespace xhtml="http://www.w3.org/1999/xhtml";

(: ------------------------------- STAMMDATEN ANFANG -------------------------------------------- :)

(:

 Menü-Eintrag in der side-navigation für "vertrag"

:)
declare %plugin:provide('side-navigation')
  function _:nav-item-stammdaten-regelungen()
  as element(xhtml:li) {
  <li xmlns="http://www.w3.org/1999/xhtml" data-parent="/schema/list/items" data-sortkey="ZZZ">
      <a href="{$global:servlet-prefix}/schema/list/items?context=stammdaten/regelung&amp;provider=sanofi/regelung"><i class="fa fa-clipboard"></i> <span class="nav-label">Regelungen</span></a>
  </li>
};

(: ------------------------------- STAMMDATEN ENDE -------------------------------------------- :)




(:
    Debug ein/aus Schalter
:)
declare %plugin:provide("schema/render/page/debug/itemX") function _:debug-kk ($Item,$Schema,$Context){
<pre>{serialize($Item)}</pre>
};




(:
  Provider für die Profilseiten Widgets
:)

declare %plugin:provide("profile/dashboard/widget")
function _:profile-dashboard-widget-regelungen($Profile as element())
{
<div class="col-md-6">
  {
    let $context := map { }
    let $schema := plugin:provider-lookup("sanofi/regelung","schema")!.()
    let $kv-schema := plugin:provider-lookup("sanofi/kv", "schema")!.()
    let $kvs := plugin:provider-lookup("sanofi/kv","datastore/dataobject/all")!.($kv-schema,$context)
    let $items  := plugin:provider-lookup("sanofi/regelung","datastore/dataobject/all")!.($schema,$context)
    let $items  := 
      for $item in $items 
      for $kv in $kvs
      where $kv/*:verantwortlich/string() = $Profile/@id/string() and $item/*:kv/string() = $kv/@id/string()
      return $item
    return
        plugin:lookup("schema/render/table/page")!.($items,$schema,$context)
  }
</div>
};


(:
   Sortierung und Filterung für die Stammdaten
:)

(: provide sorting for items :)
declare %plugin:provide("schema/process/table/items")
function _:schema-render-table-prepare-rows(
  $Items as element()*, 
  $Schema as element(schema),
  $Context as map(*)
) {
  for $item in $Items 
  order by $item/regelungsbeginn, $item/priority 
  return $item
};

declare %plugin:provide("schema/set/elements")
function _:schema-render-table-prepare-rows-only-name(
  $Items as element()*, 
  $Schema as element(schema),
  $Context as map(*)
) {
    let $columns := plugin:lookup("plato/schema/columns/get")!.("regelung")
    let $schema := $Schema update delete node ./*:element
    let $elements-in-order := for $name in $columns return $Schema/element[@name=$name]
    let $schema := $schema update insert node $elements-in-order as last into .
    return $schema
};


declare %plugin:provide("schema/datastore/dataobject/put/pre-hook")
function _:combine-regelung-name(
	$Item as element(),
	$Schema as element(schema),
	$Context as map(*)
) {
    let $context := $Context?context
    let $foreign-provider := $Schema/element[@name/string() = "kv"]/provider/string()
    let $foreign-schema := plugin:provider-lookup($foreign-provider, "schema", $context)!.()
    let $kv-key := $Schema/element[@name/string() = "kv"]/key/string()
    let $kv-fk := $Item/kv/string()
	let $kv := plugin:provider-lookup($foreign-provider,"datastore/dataobject/field",$context)!.($kv-key, $kv-fk, $foreign-schema, $Context)/name/string()

    let $product-provider := $Schema/element[@name/string() = "produkt"]/provider/string()
    let $product-key := $Schema/element[@name/string() = "produkt"]/key/string()
    let $product-schema := plugin:provider-lookup($product-provider, "schema", $context)!.()
    let $productNames :=
        for $product in $Item/produkt/key/string()
        let $p := plugin:provider-lookup($foreign-provider,"datastore/dataobject/field",$context)!.($product-key, $product, $product-schema, $Context)/name/string()
        return normalize-space($p)
	let $products := string-join($productNames, "_")

	return
        $Item update replace value of node ./name with string-join(($products, $kv), "_")
};

declare %plugin:provide("schema") function _:schema-customer()
as element(schema){
<schema xmlns="" name="regelung" domain="sanofi" provider="sanofi/regelung">
    <modal>
        <title>Regelung</title>
    </modal>
    <element name="name" type="hidden">
    </element>
    <element name="kv" type="foreign-key" required="">
            <provider>sanofi/kv</provider>
            <key>@id</key>
            <display-name>name/string()</display-name>
            <label>KV</label>
            <class>col-md-6</class>
    </element>

    <element name="produkt" type="foreign-key" render="dropdown" multiple="" async="" minimumInputLength="1" required="">
        <provider>sanofi/produkt</provider>
        <key>@id</key>
        <display-name>string-join((name/string(), " - (", herstellername/string(), ")"))</display-name>
        <label>Produkt</label>
        <class>col-md-6</class>
    </element>

    <element name="amr-beschreibung" type="html">
      <label>AMR/Ziele Beschreibung</label>
    </element>
    <element name="amr-stand" type="date">
        <label>AMR Stand</label>
    </element>
    <element name="amr-quelle" type="text">
        <label>AMR Quelle</label>
    </element>

    <element name="pbs-beschreibung" type="html">
      <label>PBS Beschreibung</label>
    </element>
    <element name="pbs-stand" type="date">
        <label>PBS Stand</label>
    </element>
    <element name="pbs-quelle" type="text">
        <label>PBS Quelle</label>
    </element>

    <element name="ssp-beschreibung" type="html">
      <label>SSP/OVB Beschreibung</label>
    </element>
    <element name="ssp-stand" type="date">
        <label>SSP Stand</label>
    </element>
    <element name="ssp-quelle" type="text">
        <label>SSP Quelle</label>
    </element>

    <element name="mapt" type="text">
      <label>MAPT</label>
    </element>

    <element name="impact" type="number" min="0" max="20">
      <label>Impactwert</label>
    </element>
    
    <element name="notizen" type="html">
         <label>Notizen</label>
     </element>
 </schema>
};

