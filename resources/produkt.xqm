module namespace _ = "sanofi/produkt";

(: import repo modules :)
import module namespace global	= "influx/global";
import module namespace plugin	= "influx/plugin";
import module namespace db	    = "influx/db";
import module namespace ui =" influx/ui";
import module namespace date-util ="influx/utils/date-utils";
import module namespace common="sanofi/common" at "common.xqm";

declare namespace functx = "http://www.functx.com";

declare namespace xhtml="http://www.w3.org/1999/xhtml";

declare variable $_:ns := namespace-uri(<_:ns/>);


declare %plugin:provide('side-navigationX')
  function _:nav-item-stammdaten-products()
  as element(xhtml:li) {
  <li xmlns="http://www.w3.org/1999/xhtml" data-parent="/schema/list/items" data-sortkey="ZZZ">
      <a href="{$global:servlet-prefix}/schema/list/items?context=stammdaten/produkt&amp;provider=sanofi/produkt"><i class="fa fa-cubes"></i> <span class="nav-label">Produkte</span></a>
  </li>
};
declare %plugin:provide('ui/page/title') function _:heading($m){_:schema()//*:title/string()};
declare %plugin:provide("ui/page/content") function _:ui-page-content($m){common:ui-page-content($m)};
declare %plugin:provide('ui/page/heading') function _:breadcrumb($m){common:ui-page-heading($m)};

(: provide sorting for items :)
declare %plugin:provide("schema/process/table/items")
function _:schema-render-table-prepare-rows($Items as element()*, $Schema as element(schema),$Context as map(*)){for $item in $Items order by $item/name, $item/priority return $item};

declare %plugin:provide("schema/render/form/field/foreign-key/datasource/search")
%plugin:provide("schema/render/form/field/foreign-key/datasource/search","produkt")
function _:search-through-all-fields(
  $Item as element()?,
  $DisplayName as xs:string,
  $Context as map(*),
  $Search as xs:string?
) as xs:boolean {
  let $name := $Item/name/string()
  let $wirkstoff := $Item/wirkstoff/string()
  let $hersteller := $Item/herstellername/string()
  let $indikation := $Item/indikation/string()

  return functx:contains-case-insensitive(concat($name, $wirkstoff, $hersteller, $indikation), $Search)
};

declare %plugin:provide("schema/set/elements")
function _:schema-render-table-prepare-rows-only-name($Items as element()*, $Schema as element(schema),$Context as map(*)){
    let $columns := ("name","indikationen")
    let $schema := $Schema update delete node ./*:element
    let $elements-in-order := for $name in $columns return $Schema/element[@name=$name]
    let $schema := $schema update insert node $elements-in-order as last into .
    return $schema
};


declare %plugin:provide("schema") 

function _:schema()
as element(schema){
<schema xmlns="" name="produkt" domain="sanofi" provider="sanofi/produkt">
    <modal>
        <title>Produkt</title>
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
    <element name="notizen" type="textarea">
        <label>Link</label>
     </element>
 </schema>
};

