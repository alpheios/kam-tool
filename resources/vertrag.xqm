module namespace _ = "sanofi/vertrag";

(: import repo modules :)
import module namespace global	= "influx/global";
import module namespace plugin	= "influx/plugin";
import module namespace db	    = "influx/db";
import module namespace ui =" influx/ui2";
import module namespace date-util ="influx/utils/date-utils";


declare namespace xhtml="http://www.w3.org/1999/xhtml";
declare namespace functx = "http://www.functx.com";

declare variable $_:vertragsarten := plugin:lookup("plato/schema/enums/get")!.("Vertragsarten");
declare variable $_:service-partner := plugin:lookup("plato/schema/enums/get")!.("Service Partner");


(: ------------------------------- STAMMDATEN ANFANG -------------------------------------------- :)

(:

 Menü-Eintrag in der side-navigation für "vertrag"

:)
declare %plugin:provide('side-navigation')
  function _:nav-item-stammdaten-contracts()
  as element(xhtml:li) {
  <li xmlns="http://www.w3.org/1999/xhtml" data-parent="/schema/list/items" data-sortkey="ZZZ">
      <a href="{$global:servlet-prefix}/schema/list/items?context=stammdaten/vertrag&amp;provider=sanofi/vertrag"><i class="fa fa-balance-scale"></i> <span class="nav-label">Verträge</span></a>
  </li>
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
    let $context := map {}
    let $schema := plugin:provider-lookup("sanofi/vertrag","schema")!.()
    let $items  := plugin:provider-lookup("sanofi/vertrag","datastore/dataobject/all", "profile")!.($schema,$context)
    (:let $items  := $items[*:verantwortlich=$Profile/@id/string()]:)
    let $items := subsequence(for $item in $items order by $item/vertragsbeginn descending return $item, 1, 15)
    return
        plugin:lookup("schema/render/table/page", "profile")!.($items,$schema,$context)
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
    <element name="produkt" type="foreign-key" multiple="" async="" required="">
        <provider>sanofi/produkt</provider>
        <key>@id</key>
        <display-name>string-join((name/string(), " - (", herstellername/string(), ")"))</display-name>
        <label>Produkt</label>
        <class>col-md-6</class>
    </element>
    <element name="indikation" type="text">
            <label>Indikation</label>
    </element>
    <element name="service-partner" type="enum">
      {$_:service-partner ! <enum key="{.}">{.}</enum>}
      <label>Service Partner</label>
    </element>
    <element name="kk" type="foreign-key" multiple="">
            <provider>sanofi/kk</provider>
            <key>@id</key>
            <display-name>name/string()</display-name>
            <label>KK-Vertragspartner</label>
            <class>col-md-6</class>
    </element>
    <element name="kv" type="foreign-key" multiple="">
            <provider>sanofi/kv</provider>
            <key>@id</key>
            <display-name>name/string()</display-name>
            <label>KV-Bezirke</label>
            <class>col-md-6</class>
    </element>
    <element name="lav" type="foreign-key" multiple="">
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
    <element name="notizen" type="html">
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

declare
    %plugin:provide("schema/render/new","kk")
    %plugin:provide("schema/render/update","kk")
    %plugin:provide("schema/render/delete","kk")
function _:kk-vertrag-render-new($Item as element(vertrag), $Schema as element(schema), $Context as map(*))
as element(xhtml:div)
{
    let $provider := "sanofi/vertrag"
    let $context := "kk"
    let $schema := plugin:provider-lookup($provider,"schema",$context)!.()
    let $items :=
        for $item in plugin:provider-lookup($provider,"datastore/dataobject/all")!.($schema,$Context)
        let $date := $item/@last-modified-date
        order by $date descending
        return $item
    return
    plugin:provider-lookup($provider,"content/view/context",$context)!.($items,$schema,$Context)

};


declare %plugin:provide("content/view/context","kk")
function _:render-page-table($Items as element(vertrag)*, $Schema as element(schema), $Context)
{
let $provider := $Schema/@provider/string()
let $context := $Context("context")
let $kk-id := $Context("context-item")/@id/string()
let $vertrag-130-140 := for $vertrag in $Items[kk//string()=$kk-id] where $vertrag/vertragsart/string()=("130a","130b","130c","140a") return $vertrag
let $vertrag-sonstige := for $vertrag in $Items[kk//string()=$kk-id] where $vertrag/vertragsart/string()=("73","speziell") return $vertrag
let $add-button := plugin:provider-lookup($provider,"schema/render/button/modal/new")!.($Schema,$Context)
return
<div xmlns="http://www.w3.org/1999/xhtml" id="kk-vertrag" data-replace="#kk-vertrag">
  <div class="ibox float-e-margins">
      <div class="ibox-title">
              <div class="col-md-12"><label class="form-label pull-right">Vertrag hinzufügen {$add-button}</label></div>
      </div>
      <div class="ibox-content">
      </div>

    </div>
    <div class="col-md-6">
        <div class="ibox float-e-margins">
            <div class="ibox-title">
                <h5>Verträge: §§130a-c und §140</h5>
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
