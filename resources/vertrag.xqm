module namespace _ = "sanofi/vertrag";

(: import repo modules :)
import module namespace global	= "influx/global";
import module namespace plugin	= "influx/plugin";
import module namespace db	    = "influx/db";
import module namespace ui =" influx/ui";
import module namespace date-util ="influx/utils/date-utils";
import module namespace common="sanofi/common" at "common.xqm";


declare namespace xhtml="http://www.w3.org/1999/xhtml";
declare namespace functx = "http://www.functx.com";

declare variable $_:vertragsarten := plugin:lookup("plato/schema/enums/get")!.("Vertragsarten");
declare variable $_:vertragseigenschaften := plugin:lookup("plato/schema/enums/get")!.("Vertragseigenschaften");
declare variable $_:ns := namespace-uri(<_:ns/>);

declare %plugin:provide('ui/page/title') function _:heading($m){_:schema-default()//*:title/string()};
declare %plugin:provide("ui/page/content") function _:ui-page-content($m){common:ui-page-content($m)};
declare %plugin:provide("ui/page/heading") function _:ui-page-heading($m){common:ui-page-heading($m)};


(: ------------------------------- STAMMDATEN ANFANG -------------------------------------------- :)

(:

 Menü-Eintrag in der side-navigation für "vertrag"

:)
declare %plugin:provide('side-navigation-item')
  function _:nav-item-stammdaten-contracts()
  as element(xhtml:li) {
  <li xmlns="http://www.w3.org/1999/xhtml" data-parent="/schema/list/items" data-sortkey="ZZZ">
      <a class="ajax" href="{$global:servlet-prefix}/schema/list/items?context=stammdaten/vertrag&amp;provider=sanofi/vertrag"><i class="fa fa-balance-scale"></i> <span class="nav-label">Verträge</span></a>
  </li>
};

declare %plugin:provide('side-navigation-item')
  function _:nav-item-stammdaten-contracts-fusioniert()
  as element(xhtml:li) {
  <li xmlns="http://www.w3.org/1999/xhtml" data-parent="/schema/list/items/fusioniert" data-sortkey="ZZZ">
      <a class="ajax" href="{$global:servlet-prefix}/schema/list/items?context=fusioniert/vertrag&amp;provider=sanofi/vertrag"><i class="fa fa-balance-scale"></i> <span class="nav-label">Verträge</span></a>
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
declare %plugin:provide("schema/process/table/items","kk")
function _:schema-process-table-items-kk(
  $Items as element()*,
  $Schema as element(schema),
  $Context as map(*)
) {
  let $context := $Context("context")
  let $kk-provider := "sanofi/kk"
  let $refresh-id := $Context?refresh-id
  let $kk-schema := plugin:provider-lookup($kk-provider, "schema", $context)!.()
  let $kks := db:eval("collection('datastore-sanofi-kk')/kk")
  let $sanofi-produkte := db:eval("collection('datastore-sanofi-produkt')/produkt[herstellername => starts-with('Sanofi')]")
  let $produkte := db:eval("collection('datastore-sanofi-produkt')/produkt[not(herstellername => starts-with('Sanofi'))]")
  let $all :=
    for $item in $Items[kk/key=$Context?context-item-id]
    let $kks := $kks[@id=$item/kk/key/string()]
    let $containsKKsWhichAreNotFusioniert := 
      some $kk in $kks
      satisfies $kk/fusioniert/string() = ""
    order by $item/vertragsbeginn
    where $containsKKsWhichAreNotFusioniert or not($kks)
    return $item
  return 
    if ($refresh-id="sanofi-verträge")
    then $all[produkt/key = $sanofi-produkte/@id or produkt/key = $sanofi-produkte/(string-join((name,herstellername)," - ")=>normalize-space())]
    else 
      if ($refresh-id="sonstige-verträge") 
      then $all[produkt/key = $produkte/@id or produkt/key = $produkte/(string-join((name,herstellername)," - ")=>normalize-space())]
      else error(QName('influx.de','ERROR:no-refresh-id'),"Keine passende refresh-id übergeben.")
};



declare %plugin:provide("schema/process/table/items", "fusioniert/vertrag")
function _:schema-process-table-items-fusioniert(
    $Items as element()*, 
    $Schema as element(schema),
    $Context as map(*)
) {
  let $context := $Context("context")
  let $kk-provider := "sanofi/kk"
  let $kk-schema := plugin:provider-lookup($kk-provider, "schema", $context)!.()
  return
    for $item in $Items
    let $kk := 
      for $key in $item/kk/key/string()
      return plugin:lookup("datastore/dataobject")!.($key, $kk-schema, $Context)
    order by $item/vertragsbeginn
    where $kk/fusioniert/string() = "true"
    return $item
};

declare %plugin:provide("schema/process/table/items","kv")
function _:schema-process-table-items-kv(
  $Items as element()*,
  $Schema as element(schema),
  $Context as map(*)
) {
  let $context := $Context("context")
  let $kv-provider := "sanofi/kv"
  let $refresh-id := $Context?refresh-id
  let $kv-schema := plugin:provider-lookup($kv-provider, "schema", $context)!.()
  let $sanofi-produkte := db:eval("collection('datastore-sanofi-produkt')/produkt[herstellername => starts-with('Sanofi')]")
  let $produkte := db:eval("collection('datastore-sanofi-produkt')/produkt[not(herstellername => starts-with('Sanofi'))]")
  let $Items := $Items[kv/key=$Context?context-item-id]
  return 
    if ($refresh-id="sanofi-verträge")
    then $Items[produkt/key = $sanofi-produkte/@id or produkt/key = $sanofi-produkte/(string-join((name,herstellername)," - ")=>normalize-space())]
    else 
      if ($refresh-id="sonstige-verträge") 
      then $Items[produkt/key = $produkte/@id or produkt/key = $produkte/(string-join((name,herstellername)," - ")=>normalize-space())]
      else error(QName('influx.de','ERROR:no-refresh-id'),"Keine passende refresh-id übergeben.")
};

declare %plugin:provide("schema/process/table/items","lav")
function _:schema-process-table-items-lav(
  $Items as element()*,
  $Schema as element(schema),
  $Context as map(*)
) {
  let $context := $Context("context")
  let $lav-provider := "sanofi/lav"
  let $refresh-id := $Context?refresh-id
  let $lav-schema := plugin:provider-lookup($lav-provider, "schema", $context)!.()
  let $alle-produkte := db:eval("collection('datastore-sanofi-produkt')/produkt")
  let $sanofi-produkte := $alle-produkte[herstellername => starts-with('Sanofi')]
  let $produkte := $alle-produkte[not(herstellername => starts-with('Sanofi'))]
  let $Items := $Items[lav/key=$Context?context-item-id]
  return 
    if ($refresh-id="sanofi-verträge")
    then $Items[produkt/key = $sanofi-produkte/@id or produkt/key = $sanofi-produkte/(string-join((name,herstellername)," - ")=>normalize-space())]
    else 
      if ($refresh-id="sonstige-verträge") 
      then $Items[produkt/key = $produkte/@id or produkt/key = $produkte/(string-join((name,herstellername)," - ")=>normalize-space())]
      else $Items};

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
    <element name="produkt" type="foreign-key" multiple="" async="" required="" minimumInputLength="2">
        <provider>sanofi/produkt</provider>
        <key>@id</key>
        <display-name>string-join((name/string(), " - (", herstellername/string(), ")"))</display-name>
        <label>Produkt</label>
        <class>col-md-6</class>
        <query><![CDATA[let $produkte := collection('datastore-sanofi-produkt')/produkt
let $context-item := collection('datastore-sanofi-vertrag')/vertrag[@id=$context-item-id]
let $linked-products := $context-item/produkt/key/string()
let $selected := $produkte[@id=$linked-products]
let $search := $produkte[lower-case(string-join(.//text(),' ')) => contains(lower-case($term))][not(@id=$linked-products)]
return (
  $selected ! <element id="{./@id/string()}" selected="true">{string-join((normalize-space(./name),./herstellername)," - ")}</element> 
 ,$search   ! <element id="{./@id/string()}" selected="false">{string-join((normalize-space(./name),./herstellername)," - ")}</element>
)]]></query>
    </element>
    <!--element name="produkt" type="datalist" multiple="" required="">
        <provider>sanofi/produkt</provider>
        <key>@id</key>
        <display-name>string-join((name/string(), " - (", herstellername/string(), ")"))</display-name>
        <label>Produkt</label>
        <class>col-md-6</class>
    </element-->
    <element name="indikation" type="text">
            <label>Indikation</label>
    </element>
   <element name="Vertragseigenschaften" type="enum" multiple="">
      {$_:vertragseigenschaften ! <enum key="{.}">{.}</enum>}
      <label>Vertragseigenschaften</label>
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
    <element name="notizen" type="textarea">
         <label>Link</label>
     </element>
     <element name="sharepoint-link" type="text">
        <label>Dokument in Sharepoint</label>
     </element>
     <element name="service-partner" type="hidden">
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

declare %plugin:provide("schema", "kv")
function _:schema-stammdaten-kv() {
  _:schema-default() update (
    insert node attribute render {"context-item"} into ./element[@name="kv"]
    ,delete node ./element[@name="kv"]/label
  )
};

declare %plugin:provide("schema", "lav")
function _:schema-stammdaten-lav() {
  _:schema-default() update (
    insert node attribute render {"context-item"} into ./element[@name="lav"]
    ,delete node ./element[@name="lav"]/label
  )
};

declare %plugin:provide("schema/render/form/field/datalist")
function _:schema-form-field-enum-datasource($Item as element()?,
    $Element as element(element),
    $Context as map(*)
) as item()* {
  let $inp :=     
    <div class="input-group">
        <input name="produkt" list="produkt" class="form-control"/>
        <span class="input-group-btn">
            <a class="btn btn-warning" onclick="this.closest('div.input-group').remove()"><i class="fa fa-trash"/></a>
        </span>
    </div>
  let $datalist :=   
   <datalist id="produkt">
      {
        for $p in db:eval('collection("datastore-sanofi-produkt")/produkt')
        order by $p/name 
        return <option>{string-join(($p/name/string(),$p/herstellername),' - ')=>normalize-space()}</option>
      }
    </datalist>

return
<fieldset id="prodlist">
  {$datalist}
  <div class="input-group">
    <input name="produkt" list="produkt" class="form-control"/>
    <span class="input-group-btn">
    <a class="btn btn-primary" onclick="this.closest('fieldset').append(document.importNode(document.querySelector('#new_produkt_t').content, true))">      <i class="fa fa-plus"/>
    </a>
    </span>
  </div>
 {
  for $k in $Item/produkt/key/text()
  let $option := $datalist/option[.=normalize-space($k)]
  where $option
  return $inp update insert node attribute value {$option} into .//input[@name="produkt"]
  }
  <template id="new_produkt_t">
   {$inp}
  </template>
</fieldset>
};

declare %plugin:provide("schema/render/table/tbody/tr/td/datalist")
function _:schema-render-table-tbody-tr-td-enum(
  $Item as element(), 
  $Schema as element(schema), 
  $ContextMap as map(*)
) as element(xhtml:td) {
    <td xmlns="http://www.w3.org/1999/xhtml">{string-join($Item/*:key/string(),", ")}</td>
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

declare %plugin:provide("content/view/context")
function _:render-page-lav-table($Items as element(vertrag)*, $Schema as element(schema), $Context)
{
  let $provider:= $Context?provider
  let $context := $Context?context
  let $Context := $Context => map:put("contextType","form")
  return
    <div xmlns="http://www.w3.org/1999/xhtml">
    <div class="row">
      <div class="col-md-6 form-group">
        <h5 class="form-label">Verträge mit Sanofi</h5>
        {
            let $Context := $Context => map:put("refresh-id","sanofi-verträge")
            return
            plugin:provider-lookup($provider,"schema/render/table/embed",$context)!.($Items,$Schema,$Context)
        }
      </div>
      <div class="col-md-6 form-group">
        <h5 class="form-label">Verträge anderer Hersteller</h5>
        {
            let $Context := $Context => map:put("refresh-id","sonstige-verträge")
            return
            plugin:provider-lookup($provider,"schema/render/table/embed",$context)!.($Items,$Schema,$Context) 
        }
      </div>
      </div>
   </div>
 };

(:
Use modal buttons in table views in context "kk" instead of page buttons.
:)
declare %plugin:provide("schema/render/button/page/edit","kk")
%plugin:provide("schema/render/button/page/edit","lav")
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
declare %plugin:provide("schema/help") 
function _:help ($Items as element()*, $Schema as element(schema), $Context as map(*)){
<div xmlns="http://www.w3.org/1999/xhtml" class="col-md-12">
   <div class="ibox float-e-margins">
          <div class="ibox-title">
             <h2><p align="center"><font color="#4C5CB0">HILFETEXT</font></p></h2>
          </div>
          <div class="ibox-content">
          <h3><p align="center"><font color="#4C5CB0"> {$Schema/*:modal/*:title/data()}</font></p></h3>
         ><p align="left"><font color="#BDBD0">
        In Sanofi gelbgrün: Für das Schema "{$Schema/*:modal/*:title/data()}" gibt die folgenden Felder: <br/>
          {$Schema/*:element/@name/string() ! <li>{.}</li>}
          </font></p>
          
          <div>
          <p align="center"><font color="D5B078">Dies ist ein sanofi-braun Text, der mittig zentriert ist.</font></p>
          </div>
          </div>
        <img class = "col-md-12" src="https://spirit.sanofi.com/cs/KAMHCProjekte/KAM%20uebergreifend/Projekte/KAIMAN/Hilfedatei/th.jpg"/>
      </div>
      
</div>
};

