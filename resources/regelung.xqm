module namespace _ = "sanofi/regelung";

(: import repo modules :)
import module namespace global  = "influx/global";
import module namespace plugin  = "influx/plugin";
import module namespace db      = "influx/db";
import module namespace ui =" influx/ui2";
import module namespace date-util ="influx/utils/date-utils";

declare namespace xhtml="http://www.w3.org/1999/xhtml";

declare variable $_:kv-vertraege := plugin:lookup("plato/schema/enums/get")!.("KV-Verträge");

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

(:
  Provider für die Stammdaten Seite
:)
declare %plugin:provide("ui/page/content","stammdaten/regelung")
function _:stammdaten-regelung($map)
as element(xhtml:div)
{
<div xmlns="http://www.w3.org/1999/xhtml" class="content-with-sidebar row">
  <div class="row">
      <div class="col-lg-12">
            {plugin:lookup("schema/ibox/table")!.("sanofi/regelung","stammdaten/regelung")}
      </div>
  </div>
</div>
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
    let $context := map{}
    let $schema := plugin:provider-lookup("sanofi/regelung","schema")!.()
    let $items  := plugin:provider-lookup("sanofi/regelung","datastore/dataobject/all")!.($schema,$context)
    let $items  := $items[*:verantwortlich=$Profile/@id/string()]
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


declare %plugin:provide("schema") function _:schema-customer()
as element(schema){
<schema xmlns="" name="regelung" domain="sanofi" provider="sanofi/regelung">
    <modal>
        <title>Regelung</title>
        <button>
            <add>hinzufügen</add>
            <cancel>abbrechen</cancel>
            <modify>ändern</modify>
            <delete>löschen</delete>
        </button>
    </modal>
    <element name="name" type="text">
        <label>Bezeichnung</label>
    </element>
    <element name="kv" type="foreign-key" required="">
            <provider>sanofi/kv</provider>
            <key>@id</key>
            <display-name>name/string()</display-name>
            <label>KV-Vertragspartner</label>
            <class>col-md-6</class>
    </element>
    <element name="kv-vertrag" type="enum">
        {$_:kv-vertraege ! <enum key="{.}">{.}</enum>}
        <label>KV Vertrag</label>
    </element>
    <element name="stand" type="date">
        <label>Stand</label>
    </element>
    <element name="quelle" type="text">
        <label>Quelle</label>
    </element>
    <element name="produkt" type="foreign-key" render="dropdown" multiple="" async="" minimumInputLength="1" required="">
        <provider>sanofi/produkt</provider>
        <key>@id</key>
        <display-name>string-join((name/string(), " - (", herstellername/string(), ")"))</display-name>
        <label>Produkt</label>
        <class>col-md-6</class>
    </element>
    <element name="notizen" type="text">
         <label>Notizen</label>
     </element>
 </schema>
};

declare %plugin:provide("schema/render/table/page","stammdaten/regelung")
function _:render-page-table($Items as element()*, $Schema as element(schema), $Context)
{
let $form-id := "id-"||random:uuid()
let $title := $Schema/*:modal/*:title/string()
let $provider := $Schema/@provider/string()
let $context := $Context("context")
let $kk := $Context("item")/@id/string()
let $modal-button := ui:modal-button('schema/form/modal?provider='||$provider||"&amp;context="||$context||"&amp;context-item-id="||$kk,<a xmlns="http://www.w3.org/1999/xhtml" shape="rect" class="btn btn-sm btn-outline"><span class="fa fa-plus"/></a>)
let $title := $Schema/modal/title/string()
return
<div xmlns="http://www.w3.org/1999/xhtml" class="ibox float-e-margins">
    <div class="ibox-title">
        <h5>{$title}Hallo</h5>
        <div class="ibox-tools">
        {$modal-button}
        </div>
    </div>
    <div class="ibox-content">
    {
        plugin:provider-lookup($provider,"schema/render/table",$context)!.($Items,$Schema,$Context)
     }
    </div>
</div>
 };

(:

 Item im Kontext einer "KK" anzeigen/bearbeiten   #####################################

:)

(:
declare %plugin:provide("schema/render/form/field/foreign-key","kk") (: Achtung: "kk" ist hier nicht der Kontext, sondern der Feldname! :)
function _:sanofi-vertrag-kk-input($Item as element(vertrag), $Element as element(element), $Context as map(*))
as element()?
{

    let $kk-id := $Context("item")/@id
    return <input xmlns="http://www.w3.org/1999/xhtml" name="kk" value="{$kk-id}" type="hidden"/>

};

declare %plugin:provide("schema/render/form/field/label","kk") (: Achtung: "kk" ist hier nicht der Kontext, sondern der Feldname! :)
function _:sanofi-vertrag-kk-input-label($Item as element(vertrag), $Element as element(element), $Context as map(*))
as element()?
{
    (: Label für Feld "kk" löschen :)
};
declare %plugin:provide("schema/render/form/action","kk") function _:schema-render-form-action($Item as element(), $Schema as element(schema), $Context as map(*))
as xs:string{
let $provider := $Schema/@provider/string()
let $context := $Context("context")
let $kk-id := $Context("kk")
return
string($global:servlet-prefix||"/datastore/dataobject/put/"||$Item/@id||"?provider="||$provider||"&amp;context="||$context||"&amp;kk="||$kk-id)
};

declare %plugin:provide("schema/render/table/tbody/tr/actions","kk")
function _:schema-render-table-tbody-tr-td-actions($Item as element(), $Schema as element(schema), $Context as map(*))
as element(xhtml:td)
{
let $context := $Context => map:get("context")
let $provider := $Schema/@provider/string()
return
(:edit-button:) <td xmlns="http://www.w3.org/1999/xhtml">{plugin:provider-lookup($provider,"schema/render/button/modal/edit")!.($Item,$Schema,$Context)
}</td>
};

declare %plugin:provide("content/context/view","kk")
function _:render-page-table($Items as element(vertrag)*, $Schema as element(schema), $Context)
{
let $form-id := "id-"||random:uuid()
let $title := $Schema/*:modal/*:title/string()
let $provider := $Schema/@provider/string()
let $context := $Context("context")
let $kk-id := $Context("kk")[1]
let $vertrag-130-140 := $Items[kk=$kk-id][vertragsart=("130a","130b","130c","140a")]
let $vertrag-sonstige := $Items[kk=$kk-id][vertragsart!=("130a","130b","130c","140a")]
let $modal-button := ui:modal-button('schema/form/modal?provider='||$provider||"&amp;context="||$context||"&amp;kk="||$kk-id,<a xmlns="http://www.w3.org/1999/xhtml" shape="rect" class="btn btn-sm btn-outline"><span class="fa fa-plus"/></a>)
let $title := $Schema/modal/title/string()
return
<div xmlns="http://www.w3.org/1999/xhtml" class="row">
    <div class="col-md-6">
        <div class="ibox float-e-margins">
            <div class="ibox-title">
                <h5>Verträge: §§130a-c und §140</h5>
                <div class="ibox-tools">
                {$modal-button}
                </div>
            </div>
            <div class="ibox-content">
            {
                let $items := $vertrag-130-140
                return
                plugin:provider-lookup($provider,"schema/render/table",$context)!.($items,$Schema,$Context)
             }
            </div>
        </div>
    </div>
    <div class="col-md-6">
        <div class="ibox float-e-margins">
            <div class="ibox-title">
                <h5>Verträge: §73,§84 und speziell</h5>
                <div class="ibox-tools">
                {$modal-button}
                </div>
            </div>
            <div class="ibox-content">
            {
                let $items := $vertrag-sonstige
                return
                plugin:provider-lookup($provider,"schema/render/table",$context)!.($items,$Schema,$Context)
             }
            </div>
        </div>
    </div>
 </div>
 };
:)