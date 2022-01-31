module namespace _ = "sanofi/news";

import module namespace plugin  = "influx/plugin";
import module namespace common="sanofi/common" at "common.xqm";
import module namespace global="influx/global";
import module namespace table-view = "influx/schema/table-view";
import module namespace schema = "influx/schema";
import module namespace alert="influx/ui/alert";

declare namespace xhtml="http://www.w3.org/1999/xhtml";
declare variable $_:ns := namespace-uri(<_:ns/>);


declare %plugin:provide('side-navigation-item')
  function _:nav-item-stammdaten-regelungen-admin()
  as element(xhtml:li) {
  <li xmlns="http://www.w3.org/1999/xhtml" data-parent="/admin" data-sortkey="ZZZ">
      <a href="{$global:servlet-prefix}/schema/list/items?context=admin&amp;provider={$_:ns}"><i class="fa fa-clipboard"></i> <span class="nav-label">News (admin)</span></a>
  </li>
};

(: ------------------------------- STAMMDATEN ENDE -------------------------------------------- :)

declare %plugin:provide("schema/render/button/page/edit") function _:swap-button-to-modal-edit ($Item,$Schema,$Context){
plugin:provider-lookup("default","schema/render/button/modal/edit")($Item,$Schema,$Context)
};


(: adapter for ui:page to schema title :)
declare %plugin:provide('ui/page/title') function _:heading($m){_:schema()//*:title/string()};
declare %plugin:provide('ui/page/heading') function _:ui-page-heading($m){common:ui-page-heading($m)};
declare %plugin:provide("ui/page/content","admin") function _:admin-ui-page-content($m){common:ui-page-content($m)};
declare %plugin:provide("ui/page/content") function _:ui-page-content($m){common:ui-page-content($m)};


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

declare %plugin:provide("ui/page/welcome") function _:login-plugin($map){
  web:redirect("/schema/list/items?context=admin&amp;provider="||$_:ns||"&amp;contextType=page&amp;modal=0")
};


(:
  Provider für die Profilseiten Widgets
:)


declare %plugin:provide("schema") 
function _:schema()
as element(schema){
<schema xmlns="" name="news" domain="sanofi" provider="{$_:ns}">
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
    <element name="produkt" type="foreign-key" multiple="" async="" required="" minimumInputLength="2">
      <provider>sanofi/produkt</provider>
      <key>@id</key>
      <display-name>string-join((name/string(), " - (", herstellername/string(), ")"))</display-name>
      <label>Produkt</label>
      <query><![CDATA[let $produkte := collection('datastore-sanofi-produkt')/produkt
let $context-item := collection('datastore-sanofi-news')/news[@id=$context-item-id]
let $linked-products := $context-item/produkt/key/string()
let $selected := $produkte[@id=$linked-products]
let $search := $produkte[lower-case(string-join(.//text(),' ')) => contains(lower-case($term))][not(@id=$linked-products)]
return (
  $selected ! <element id="{./@id/string()}" selected="true">{string-join((normalize-space(./name),./herstellername)," - ")}</element> 
 ,$search   ! <element id="{./@id/string()}" selected="false">{string-join((normalize-space(./name),./herstellername)," - ")}</element>
)]]></query>
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
    let $schema := plugin:provider-lookup($_:ns,"schema")!.()
    let $items  := plugin:provider-lookup($_:ns,"datastore/dataobject/all")!.($schema,$context)
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
