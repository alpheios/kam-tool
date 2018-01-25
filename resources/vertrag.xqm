module namespace _ = "sanofi/vertrag";

(: import repo modules :)
import module namespace global	= "influx/global";
import module namespace plugin	= "influx/plugin";
import module namespace db	    = "influx/db";
import module namespace ui =" influx/ui2";

declare namespace xhtml="http://www.w3.org/1999/xhtml";

declare variable $_:vertragsarten := plugin:lookup("plato/schema/enums/get")!.("Vertragsarten");

declare %plugin:provide('side-navigation')
  function _:nav-item-stammdaten-contracts()
  as element(xhtml:li) {
  <li xmlns="http://www.w3.org/1999/xhtml" data-parent="/sanofi/stammdaten" data-sortkey="ZZZ">
      <a href="{$global:servlet-prefix}/sanofi/stammdaten/vertrag"><i class="fa fa-cubes"></i> <span class="nav-label">Verträge</span></a>
  </li>
};


declare %plugin:provide('ui/page/custom-css',"stammdaten/vertrag") function _:page-custom-css(
    $Params as map(*)
) as element(xhtml:link)* {
    <link xmlns="http://www.w3.org/1999/xhtml" href="{$global:inspinia-path}/css/plugins/select2/select2.min.css" rel="stylesheet"/>

};

declare %plugin:provide('ui/page/custom-js') function _:page-custom-js(
    $Params as map(*)
) as element(xhtml:link)* {
    <script src="{$global:inspinia-path}/js/plugins/select2/select2.full.min.js"></script>

};

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

declare %plugin:provide("schema/render/page/debug/itemX") function _:debug-kk ($Item,$Schema,$Context){
<pre>{serialize($Item)}</pre>
};

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


(: provide sorting for items :)
declare %plugin:provide("schema/process/table/items")
function _:schema-render-table-prepare-rows($Items as element()*, $Schema as element(schema),$Context as map(*)){for $item in $Items order by $item/name, $item/priority return $item};

declare %plugin:provide("schema/set/elements")
function _:schema-render-table-prepare-rows-only-name($Items as element()*, $Schema as element(schema),$Context as map(*)){
    let $columns := ("name","indikationen","kk","kv","produkt")
    let $schema := $Schema update delete node ./*:element
    let $elements-in-order := for $name in $columns return $Schema/element[@name=$name]
    let $schema := $schema update insert node $elements-in-order as last into .
    return $schema
};


declare %plugin:provide("schema") function _:schema-customer()
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
    <element name="produkt" type="foreign-key" required="">
        <provider>sanofi/produkt</provider>
        <key>@id</key>
        <display-name>name/string()</display-name>
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

declare %plugin:provide("schema/render/form/field/foreign-key","kk") (: Achtung: "kk" ist hier nicht der Kontext, sondern der Feldname! :)
function _:sanofi-stakeholder-kk-input($Item as element(vertrag), $Element as element(element), $Context as map(*))
as element()?
{
    let $kk-id := $Context("kk")
    return <input xmlns="http://www.w3.org/1999/xhtml" name="kk" value="{$kk-id}" type="hidden"/>
};

declare %plugin:provide("schema/render/form/field/label","kk") (: Achtung: "kk" ist hier nicht der Kontext, sondern der Feldname! :)
function _:sanofi-stakeholder-kk-input-label($Item as element(vertrag), $Element as element(element), $Context as map(*))
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
let $kk := $Context("kk")
let $modal-button := ui:modal-button('schema/form/modal?provider='||$provider||"&amp;context="||$context||"&amp;kk="||$kk,<a xmlns="http://www.w3.org/1999/xhtml" shape="rect" class="btn btn-sm btn-outline"><span class="fa fa-plus"/></a>)
let $title := $Schema/modal/title/string()
return
<div xmlns="http://www.w3.org/1999/xhtml" class="ibox float-e-margins">
    <div class="ibox-title">
        <h5>{$title}</h5>
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
