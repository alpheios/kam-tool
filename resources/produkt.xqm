module namespace _ = "sanofi/produkt";

(: import repo modules :)
import module namespace global	= "influx/global";
import module namespace plugin	= "influx/plugin";
import module namespace db	    = "influx/db";
import module namespace ui =" influx/ui2";

declare namespace xhtml="http://www.w3.org/1999/xhtml";



declare %plugin:provide('side-navigation')
  function _:nav-item-stammdaten-products()
  as element(xhtml:li) {
  <li xmlns="http://www.w3.org/1999/xhtml" data-parent="/sanofi/stammdaten" data-sortkey="ZZZ">
      <a href="{$global:servlet-prefix}/sanofi/stammdaten/produkt"><i class="fa fa-cubes"></i> <span class="nav-label">Produkte</span></a>
  </li>
};


declare %plugin:provide("ui/page/content","stammdaten/produkt")
function _:stammdaten-produkt($map)
as element(xhtml:div)
{
<div xmlns="http://www.w3.org/1999/xhtml" class="content-with-sidebar row">
  <div class="row">
      <div class="col-lg-12">
            {plugin:lookup("schema/ibox/table")!.("sanofi/produkt","stammdaten/produkt")}
      </div>
  </div>
</div>
};


(: provide sorting for items :)
declare %plugin:provide("schema/process/table/items")
function _:schema-render-table-prepare-rows($Items as element()*, $Schema as element(schema),$Context as map(*)){for $item in $Items order by $item/name, $item/priority return $item};

declare %plugin:provide("datastore/name")
function _:set-datastore-name(
  $Schema as element(schema),
  $Context as map(*)
) as xs:string {
  'datastore-sanofi-products'
};

declare %plugin:provide("schema/set/elements")
function _:schema-render-table-prepare-rows-only-name($Items as element()*, $Schema as element(schema),$Context as map(*)){
    let $columns := ("name","indikationen")
    let $schema := $Schema update delete node ./*:element
    let $elements-in-order := for $name in $columns return $Schema/element[@name=$name]
    let $schema := $schema update insert node $elements-in-order as last into .
    return $schema};

declare %plugin:provide("schema") function _:schema-customer()
as element(schema){
<schema xmlns="" name="produkt" domain="sanofi" provider="sanofi/produkt">
    <modal>
        <title>Produkt</title>
        <button>
            <add>hinzufügen</add>
            <cancel>abbrechen</cancel>
            <modify>ändern</modify>
            <delete>löschen</delete>
        </button>
    </modal>
    <element name="name" type="text">
        <label>Produktname</label>
    </element>
    <element name="wirkstoff" type="text">
        <label>Wirkstoff</label>
    </element>
    <element name="herstellername" type="text">
        <label>Herstellername</label>
    </element>
    <element name="indikation" type="text">
        <label>Indikation</label>
    </element>
    <element name="atc-c" type="text">
        <label>Indikation</label>
    </element>
    <element name="atc-4-steller" type="text">
        <label>Indikation</label>
    </element>
    <element name="stoffklasse" type="text">
        <label>Indikation</label>
    </element>
    <element name="notizen" type="text">
        <label>Notizen</label>
     </element>
 </schema>
};

