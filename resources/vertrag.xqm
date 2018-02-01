module namespace _ = "sanofi/vertrag";

(: import repo modules :)
import module namespace global	= "influx/global";
import module namespace plugin	= "influx/plugin";
import module namespace db	    = "influx/db";
import module namespace ui =" influx/ui2";

declare namespace xhtml="http://www.w3.org/1999/xhtml";

declare variable $_:vertragsarten := plugin:lookup("plato/schema/enums/get")!.("Vertragsarten");


(: ------------------------------- STAMMDATEN ANFANG -------------------------------------------- :)

(:

 Menü-Eintrag in der side-navigation für "vertrag"

:)
declare %plugin:provide('side-navigation')
  function _:nav-item-stammdaten-contracts()
  as element(xhtml:li) {
  <li xmlns="http://www.w3.org/1999/xhtml" data-parent="/schema/list/items" data-sortkey="ZZZ">
      <a href="{$global:servlet-prefix}/schema/list/items?context=stammdaten/vertrag&amp;provider=sanofi/vertrag"><i class="fa fa-cubes"></i> <span class="nav-label">Verträge</span></a>
  </li>
};

(:
  Provider für die Stammdaten Seite
:)
declare %plugin:provide("ui/page/content","stammdaten/vertrag")
function _:stammdaten-vertrag($map)
as element(xhtml:div)
{
<div xmlns="http://www.w3.org/1999/xhtml" class="content-with-sidebar row">
  <div class="row">
      <div class="col-lg-12">
            {plugin:lookup("schema/ibox/table")!.("sanofi/vertrag","stammdaten/vertrag")}
      </div>
  </div>
</div>
};


(: ------------------------------- STAMMDATEN ENDE -------------------------------------------- :)


(:
  Provider für die Profilseiten Widgets
:)

declare %plugin:provide("profile/dashboard/widget")
function _:profile-dashboard-widget-vertraege($Profile as element())
{
<div class="col-md-6">
  {
    let $context := map{}
    let $schema := plugin:provider-lookup("sanofi/vertrag","schema")!.()
    let $items  := plugin:provider-lookup("sanofi/vertrag","datastore/dataobject/all")!.($schema,$context)
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
function _:schema-render-table-prepare-rows($Items as element()*, $Schema as element(schema),$Context as map(*)){for $item in $Items order by $item/vertragsbeginn return $item};

declare %plugin:provide("schema/set/elements")
function _:schema-render-table-prepare-rows-only-name($Items as element()*, $Schema as element(schema),$Context as map(*))
{
    let $columns := plugin:lookup("plato/schema/columns/get")!.("vertrag")
    let $schema := $Schema update delete node ./*:element
    let $elements-in-order := for $name in $columns return $Schema/element[@name=$name]
    let $schema := $schema update insert node $elements-in-order as last into .
    return $schema
};


declare %plugin:provide("schema") function _:schema-default()
as element(schema){
<schema xmlns="" name="vertrag" domain="sanofi" provider="sanofi/vertrag">
    <modal>
        <title>Vertrag</title>
        <button>
            <add>hinzufügen</add>
            <cancel>abbrechen</cancel>
            <modify>ändern</modify>
            <delete>löschen</delete>
        </button>
    </modal>
    <element name="verantwortlich" type="foreign-key" required="">
                 <provider>sanofi/key-accounter</provider>
                 <key>@id/string()</key>
                 <display-name>name/string()</display-name>
                 <label>Verantwortlich</label>
                 <class>col-md-6</class>
     </element>
    <element name="name" type="text">
        <label>Bezeichnung</label>
    </element>
    <element name="vertragsart" type="enum">
        {$_:vertragsarten ! <enum key="{.}">{.}</enum>}
        <label>Vertragsart</label>
    </element>
    <element name="produkt" type="foreign-key" async="" required="">
        <provider>sanofi/produkt</provider>
        <key>@id</key>
        <display-name>string-join((name/string(), " - (", herstellername/string(), ")"))</display-name>
        <label>Produkt</label>
        <class>col-md-6</class>
    </element>
    <element name="indikation" type="text">
            <label>Indikation</label>
    </element>
    <element name="kk" type="foreign-key" required="">
            <provider>sanofi/kk</provider>
            <key>@id</key>
            <display-name>name/string()</display-name>
            <label>KK-Vertragspartner</label>
            <class>col-md-6</class>
    </element>

    <element name="lav" type="foreign-key" required="">
            <provider>sanofi/lav</provider>
            <key>@id</key>
            <display-name>name/string()</display-name>
            <label>LAV-Vertragspartner</label>
            <class>col-md-6</class>
    </element>
    <element name="vertragspartner" type="text">
        <label>Sonstige Vertragspartner</label>
    </element>
    <element name="vertragsbeginn" type="date">
        <label>Beginn</label>
    </element>
    <element name="vertragsende" type="date">
        <label>Ende</label>
    </element>
    <element name="notizen" type="text">
         <label>Notizen</label>
     </element>
     <element name="sharepoint-link" type="text">
        <label>Dokument in Sharepoint</label>
     </element>
 </schema>
};

declare %plugin:provide("schema", "kk")
function _:schema-stammdaten-kk() {
  _:schema-default() update (
    insert node attribute render {"context-item"} into ./element[@name="kk"]
    ,delete node ./element[@name="kk"]/label
  )
};

declare %plugin:provide("content/view/context","kk")
function _:render-page-table($Items as element(vertrag)*, $Schema as element(schema), $Context)
{
let $provider := $Schema/@provider/string()
let $context := $Context("context")
let $kk-id := $Context("context-item")/@id/string()
let $vertrag-130-140 := for $vertrag in $Items[kk=$kk-id] where trace($vertrag/vertragsart)=("130a","130b","130c","140a") return $vertrag
let $vertrag-sonstige := for $vertrag in $Items[kk=$kk-id] where $vertrag/vertragsart=("73") return $vertrag
let $add-button := plugin:provider-lookup($provider,"schema/render/button/modal/new")!.($Items[1],$Schema,$Context)
return
<div xmlns="http://www.w3.org/1999/xhtml" class="row">
    <div class="col-md-6">
        <div class="ibox float-e-margins">
            <div class="ibox-title">
                <h5>Verträge: §§130a-c und §140</h5>
                <div class="ibox-tools">{$add-button}</div>
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
                <div class="ibox-tools">{$add-button}</div>
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

(:
Use modal buttons in table views in context "kk" instead of page buttons.
:)
declare %plugin:provide("schema/render/button/page/edit","kk")
function _:schema-render-button-page-edit($Item as element(), $Schema as element(schema), $Context as map(*))
as element()
{
    plugin:lookup("schema/render/button/modal/edit")!.($Item,$Schema,$Context)
};

(:

:)
declare %plugin:provide("schema/render/table/tbody/tr/td/text","kk")
function _:schema-render-table-tbody-tr-td-text($Item as element(), $Schema as element(schema), $Context as map(*))
as element(xhtml:td)
{
let $link := $Item/../sharepoint-link/text()
return
if ($Item/name()='sharepoint-link' and $link)
    then <td xmlns="http://www.w3.org/1999/xhtml"><a target="window" href="{$link}">{$Item/text()}</a></td>
    else <td xmlns="http://www.w3.org/1999/xhtml">{$Item/text()}</td>
};
