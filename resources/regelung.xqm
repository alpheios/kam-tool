module namespace _ = "sanofi/regelung";

(: import repo modules :)
import module namespace global  	= "influx/global";
import module namespace plugin  	= "influx/plugin";
import module namespace db      	= "influx/db";
import module namespace ui 		 	="influx/ui";
import module namespace modal	 	="influx/ui/modal";
import module namespace date-util ="influx/utils/date-utils";
import module namespace common		="sanofi/common" at "common.xqm";




declare namespace xhtml="http://www.w3.org/1999/xhtml";
(: hier werden die Auswahlwerte für die ab Version 1.07 verwendeten neuen Regeleungswerte deklariert :)
declare variable $_:fachrichtungen-regelungen := plugin:lookup("plato/schema/enums/get")!.("Fachrichtungen Regelungen");
declare variable $_:merkmale-regelungen := plugin:lookup("plato/schema/enums/get")!.("Merkmale Regelungen");
declare variable $_:PBS-Typ := plugin:lookup("plato/schema/enums/get")!.("PBS-Typ");
declare variable $_:merkmale-quote := plugin:lookup("plato/schema/enums/get")!.("Merkmale Quote");
declare variable $_:ns := namespace-uri(<_:ns/>);

(: ------------------------------- STAMMDATEN ANFANG -------------------------------------------- :)

(: 

 Menü-Eintrag in der side-navigation für "regelung"
 2020-12-18: mit copy button

:)
declare %plugin:provide('side-navigation-item')
  function _:nav-item-stammdaten-regelungen()
  as element(xhtml:li) {
  <li xmlns="http://www.w3.org/1999/xhtml" data-parent="/schema/list/items" data-sortkey="ZZZ">
      <a href="{$global:servlet-prefix}/schema/list/items?context=stammdaten/regelung&amp;provider=sanofi/regelung&amp;contextType=page"><i class="fa fa-clipboard"></i> <span class="nav-label">Regelungen</span></a>
  </li>
};

(: 
  2020-12-18: Variante ohne "readonly" und ohne kopieren :)
declare %plugin:provide('side-navigation-item')
  function _:nav-item-stammdaten-regelungen-admin()
  as element(xhtml:li) {
  <li xmlns="http://www.w3.org/1999/xhtml" data-parent="/admin" data-sortkey="ZZZ">
      <a href="{$global:servlet-prefix}/schema/list/items?context=admin&amp;provider=sanofi/regelung"><i class="fa fa-clipboard"></i> <span class="nav-label">Regelungen (admin)</span></a>
  </li>
};

(: ------------------------------- STAMMDATEN ENDE -------------------------------------------- :)

declare %plugin:provide("schema/render/button/page/edit","kv") function _:swap-button-to-modal-edit ($Item,$Schema,$Context){
plugin:provider-lookup("default","schema/render/button/modal/edit")($Item,$Schema,$Context)
};


(: adapter for ui:page to schema title :)
declare %plugin:provide('ui/page/title') function _:heading($m){_:schema()//*:title/string()};
declare %plugin:provide("ui/page/content") function _:ui-page-content($m){common:ui-page-content($m)};
declare %plugin:provide('ui/page/heading') function _:ui-page-heading($m){common:ui-page-heading($m)};


(:
    Debug ein/aus Schalter
:)
declare %plugin:provide("schema/render/page/debug/itemX") function _:debug-kk ($Item,$Schema,$Context){
<pre>{serialize($Item)}</pre>
};


declare %plugin:provide("schema/render/button/modal/new")
function _:schema-render-button-modal-new(
  $Schema as element(schema), 
  $Context as map(*)
) as element()? {

    let $context := $Context("context")
    let $provider := $Schema/@provider/string()
    let $link := plugin:provider-lookup($provider,"schema/render/button/modal/new/link",$context)!.($Schema,$Context)
    return
      ui:modal-button(<a class="btn btn-sm"><span class="fa fa-plus"/></a>,$link)
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
declare %plugin:provide("schema/process/table/items","kv")
 %plugin:provide("schema/process/table/items","kk")
  %plugin:provide("schema/process/table/items")
function _:schema-render-table-prepare-rows(
  $Items as element()*, 
  $Schema as element(schema),
  $Context as map(*)
) {
  let $items := if ($Context?context) then $Items[*[name()=$Context?context][.=$Context?context-item-id]]
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

declare %plugin:provide("schema") function _:schema()
as element(schema){
<schema xmlns="" name="regelung" domain="sanofi" provider="sanofi/regelung">
    <modal>
        <title>Regelung</title>
    </modal>
    <list>
      <query><![CDATA[
declare variable $ContextMap external := map{};
declare variable $start := $ContextMap?page-start ?: 1;
declare variable $size  := $ContextMap?page-size ?: 20;
declare variable $search := $ContextMap?search;
declare variable $field := $ContextMap?field;
declare variable $order-by := $ContextMap?order-by?:'name';

let $produkte := collection('datastore-sanofi-produkt')/produkt
let $kv := collection('datastore-sanofi-kv')/kv[@id=$ContextMap?context-item-id]
let $regelungen := 
  for $item in collection('datastore-sanofi-regelung')/regelung
  order by $item/*[name()=$order-by] ascending
  return 
  <regelung>
    {$item/@id}
    {$item/name}
    <kv>
    {
      for $kv in $kv[@id=$item/kv]
      return <key>{$kv/@id}{$kv/name/string()}</key>
        }
    </kv>
    <produkt>{
      (
        for $p in $produkte[contains($item/(name,wirkstoffname),normalize-space(./name))] 
        return <key>{$p/@id}{string-join(($p/name/string(),$p/herstellername/string()),' - ')}</key> 
      , for $p in $produkte[@id=$item/produkt/key] 
        return <key>{$p/@id}{string-join(($p/name/string(),$p/herstellername/string()),' - ')}</key>
    )
      }
    </produkt>
    {$item/mapt}
    {$item/impact2}
    {$item/amr-beschreibung}
    {$item/bps-beschreibung}
  </regelung>
let $search-result := 
  if ($search and $field) then $regelungen[*[name()=$field] contains text {$search}]
  else if ($search) then $regelungen[node() contains text {$search}]
  else $regelungen
let $page := <page count="{count($search-result)}">{$search-result => subsequence($start,$size)}</page>
return $page
          ]]>
      </query>
    </list>
    <element name="name" type="hidden">
    </element>
    <element name="kv" type="foreign-key" required="">
            <provider>sanofi/kv</provider>
            <key>kv</key>
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
        <query><![CDATA[let $produkte := collection('datastore-sanofi-produkt')/produkt
let $context-item := collection('datastore-sanofi-regelung')/regelung[@id=$context-item-id]
let $linked-products := $context-item/produkt/key/string()
let $selected := $produkte[@id=$linked-products]
let $search := $produkte[lower-case(string-join(.//text(),' ')) => contains(lower-case($term))][not(@id=$linked-products)]
return (
  $selected ! <element id="{./@id/string()}" selected="true">{string-join((normalize-space(./name),./herstellername)," - ")}</element> 
 ,$search   ! <element id="{./@id/string()}" selected="false">{string-join((normalize-space(./name),./herstellername)," - ")}</element>
)]]></query>
    </element>    
     <element name="letzte-aenderung" type="date">
        <label>Letzte Änderung am</label>
    </element>
    
   <element name="merkmale-quote" type="enum" multiple="">
      {$_:merkmale-quote ! <enum key="{.}">{.}</enum>}
      <label> Quoten Typen + Wirkung</label>
    </element>  
    
   <element name="fachrichtungX" type="enum" multiple="">
      {$_:fachrichtungen-regelungen ! <enum key="{.}">{.}</enum>} 
      <label>Von Quoten betroffene Fachrichung(en)</label>  
    </element>   
    
  (: neu!!! :)     
    <element name="amr-Quoten_Fachgruppen" type="link">
      <label>Auflistung Quote(n) + Fachgruppen </label>
      <class>col-md-6</class>
    </element>   
      
    <element name="amr-beschreibung" type="summernote">
      <label>AMV/Ziele Beschreibung, weitere Ergänzungen</label>
    </element>
    
    <element name="amr-stand" type="date">
        <label>AMV Stand</label>
    </element>
    
    <element name="amr-quelle" type="text">
        <label>AMV Quelle</label>
    </element>

    <element name="pbs-typ" type="enum" multiple="">
      {$_:PBS-Typ ! <enum key="{.}">{.}</enum>}
      <label>Typ(en) der Praxisbesonderheit</label>
     </element>
     
    <element name="pbs-beschreibung" type="summernote">
      <label>PBS Beschreibung</label>
    </element>
    <element name="pbs-stand" type="date">
        <label>PBS Stand</label>
    </element>
    <element name="pbs-quelle" type="text">
        <label>PBS Quelle</label>
    </element>
    <element name="ssp-beschreibung" type="hidden">
    </element>
    <element name="ssp-stand" type="hidden">
    </element>
    <element name="ssp-quelle" type="hidden">
    </element>
    <element name="mapt" type="text" maxlength="160">
      <label>Kurz - Wetterbericht</label>
    </element>
        
    <element name="impact2" type="enum">
      <label>Produktwetter</label>
      <enum key="1">1 - sonnig - keine bzw. kleine negative Auswirkungen auf das Produkt</enum>
      <enum key="2">2 - bewölkt - mittlere negative Auswirkungen auf das Produkt</enum>
      <enum key="3">3 - regnerisch - große negative Auswirkungen auf das Produkt</enum>
    </element>
    
     <element name="kamhc_fazit" type="summernote">
      <label>KAM HC Fazit</label>
    </element>   
    <element name="notizen" type="summernote" default="https://">
         <label>Link (https://) </label>
    </element>
   <element name="regelung-quote" render="table" type="foreign-key" required="">
      <provider>sanofi/quote</provider>
      <key>regelung</key>
      <label>Quoten</label>
      <display-name>name/string()</display-name>
   </element>
 </schema>
};

declare %plugin:provide("schema", "kv")
function _:schema-kv-kontext() as element(schema) {
  _:schema() update (
       insert node attribute render {"context-item"} into ./element[@name="kv"]
       (:,
      delete node ./element[@name="kv"]/label:)
      (: Label wird weiter angezeigt, damit das layout nicht zerschossen wird. :)
  )
};


declare %plugin:provide("schema", "schema-exporter")
function _:schema-export-kontext() as element(schema) {
  _:schema() update (
    insert node <element name="hallo" type="text"/> into .  )
};





(:~
This is more or less copy and paste code from the
schema app but added some "kind of validation".
For now I used the copy and paste method because
we don't have a working validation concept.

@author Jan Meischner
@deprecated

Neuer Autor, ab Version 1.06 Martin Waechter
:)
declare %plugin:provide("schema/datastore/dataobject/put")
function _:schema-datastore-dataobject-put(
  $Schema as element(schema), 
  $Id as xs:string, 
  $Context as map(*)
) as element()* {
  let $provider           := $Context("provider")
  let $context            := $Context("context")
  let $context-provider   := $Context("context-provider")
  let $context-item-id    := $Context("context-item-id")
  let $context-schema     := if ($context-provider) then plugin:provider-lookup($context-provider,"schema",$context)!.() else ()
  let $context-item       := if ($context-schema) then plugin:provider-lookup($context-provider,"datastore/dataobject",$context)!.($context-item-id, $context-schema, $Context) else ()

  let $schema := plugin:provider-lookup($provider,"schema",$context)!.()
  let $old-item := plugin:provider-lookup($provider,"datastore/dataobject",$context)!.($Id, $schema, $Context)
  let $new-item := plugin:provider-lookup($provider,"schema/instance/new/from/form",$context)!.($schema,$Context)

  let $changed-date :=
    if (
      $new-item/amr-stand/string() = $old-item/amr-stand/string() and
      $new-item/pbs-stand/string() = $old-item/pbs-stand/string() and
      $new-item/ssp-stand/string() = $old-item/ssp-stand/string() and
      $new-item/letzte-aenderung/string() = $old-item/letzte-aenderung/string()
    )
    then
      ui:warn(<span data-i18n="no-regelungen-data-changed"></span>)
    else ()

  let $item :=
    if ($old-item)
        then plugin:provider-lookup($provider,"schema/update/instance",$context)!.($new-item,$old-item, $schema, $Context)
        else $new-item

  let $item := plugin:provider-lookup($provider,"schema/datastore/dataobject/put/pre-hook",$context)!.($item, $Schema, $Context)

  let $item := if ($item/@last-modified-date)
                then $item update replace value of node ./@last-modified-date with current-dateTime()
                else $item update insert node attribute last-modified-date {current-dateTime()} into .

  let $putItem := plugin:provider-lookup($provider,"datastore/dataobject/put",$context)!.($item, $schema, $Context)
  let $Context := map:merge(($Context, map{"context-item":$context-item,"context-provider":$context-provider,"context-item-id":$context-item-id}), map {
                        "duplicates": "use-first"
                    })
  return
      (    
        $changed-date,
        plugin:provider-lookup($provider,"datastore/dataobject/put/post-hook",$context)!.($item, $schema, $Context)
        ,if (count($old-item)=0)
          then plugin:provider-lookup($provider,"schema/render/new",$context)!.($item, $schema, $Context)
          else plugin:provider-lookup($provider,"schema/render/update",$context)!.($item, $schema, $Context)
   )
 };
 (: _____________________ab hier kommt die Hilfe_______________________ :)
 
declare %plugin:provide("schema/help") 
function _:help ($Items as element()*, $Schema as element(schema), $Context as map(*)){
<div xmlns="http://www.w3.org/1999/xhtml" class="col-md-60">
   <div class="ibox float-e-margins">
          <div class="ibox-title">
          <h2><p align="center"><font color="#4C5CB0">HILFETEXT</font></p></h2>
          </div>
          
          <div class="ibox-content">
          <h3><p align="center"><font color="#4C5CB0"> {$Schema/*:modal/*:title/data()}</font></p></h3>      
          </div>
          
          <div>
          <p align="center"><font color="D5B078">KV-Regelungen Übersicht:</font></p>
          </div>
          <div>  <p align="center">Bild vergößern mit strg + </p></div>
          <div>
          <img class = "col-md-12" src="https://spirit.sanofi.com/cs/KAMHCProjekte/KAM%20uebergreifend/Projekte/KAIMAN/Hilfedatei/Help Reg1.png"/>
          </div>
          <div>
          <li>A: Volltextsuche nach einzelnen Zeichen und Kombinationen im kompletten Text ALLER Regelungen</li>
           </div> <div>
          <li>B: Regelung bearbeiten</li>
          </div> <div>
          <li>C: sortieren</li>
          </div> <div>
          <li>D: links beginnen mit http</li>
          </div> <div>
          <li>E: Hilfe aufrufen</li>
          </div> <div>
          <li>F: Datendownload </li>
          </div> <div>
          <li>G: neue Regelung anlegen</li>
          </div> <div>
          <li>H: Nächste bzw. vorherige Seite</li>
          </div> <div>
          <p align="center">********************************************************</p>
          </div>
          <div>
          <p align="center"><font color="D5B078">KV-Regelung bearbeiten:</font></p>
          </div>
          
           <div>
          <img class = "col-md-12" src="https://spirit.sanofi.com/cs/KAMHCProjekte/KAM%20uebergreifend/Projekte/KAIMAN/Hilfedatei/Help Reg2.png"/>
          </div>
          <div>
          <li> 1: Produktsuche (mind. 3 Zeichen) nach Name, Wirkstoff und Hersteller - MEHRFACHAUSWAHL möglich </li>
          </div> <div>
          <li> 2: Spezielle Quoten für Fachrichtungen (- MEHRFACHAUSWAHL möglich) auswählen. Wert in % </li>
          </div> <div>
          <li> 3: Merkmale der Regelung zb.: Medikationskatalog - MEHRFACHAUSWAHL möglich </li>
          </div> <div>
          <li> 4: Letzter Stand der Eintragungen, zeigt die Aktualität der Gesamtdaten zur Regelung </li>
          </div> <div>
          <li> 5: AMR, Ziele, SSB, PBS mit Quelle (! keine Link) und Datum des Inkrafttreten </li>
          </div> <div>
          <li> 6: Ampel von 1 bis 3 - Bezug auf die Negativwirkung der Regelungen. Die Kurzbeschreibung max. 50 Zeichen!, Impactwert ist noch vorübergehend, Wert bitte auf NULL setzen! </li>
          </div> <div>
          <li> 7: Linkliste, mehrere Links möglich </li>
          </div> <div>
          <li> Speichern: Die Daten werden gespeichert sofern Pflichtfelder ausgefüllt wurden, eine Meldung erscheint wenn nicht wenigstens ein Datumsfeld verändert wurde. </li>
          </div>
   </div>     
</div>
};

declare %plugin:provide("schema/render/table/tbody/tr/actions")
function _:schema-render-table-tbody-tr-td-action-edit(
  $Item as element(), 
  $Schema as element(schema), 
  $Context as map(*)
) as element(xhtml:td) {
  let $context := $Context => map:get("context")
  let $provider := $Schema/@provider/string()
  let $contextType := $Context => map:get("contextType")
  let $editButtonProvider :=
    if ($contextType = "form")
    then "schema/render/button/modal/edit"
    else "schema/render/button/page/edit"
  return
    <td xmlns="http://www.w3.org/1999/xhtml">{if ($Item/@readonly) then (<i class="fa fa-snowflake-o"/>) else (plugin:provider-lookup($provider,$editButtonProvider,$context)!.($Item,$Schema,$Context))}</td>
};


declare %plugin:provide("schema/render/table/tbody/tr/actions")
function _:schema-render-table-tbody-tr-td-action-copy(
  $Item as element(), 
  $Schema as element(schema), 
  $Context as map(*)
) as element(xhtml:td) {
  let $context := $Context => map:get("context")
  let $provider := $Schema/@provider/string()
  let $contextType := $Context => map:get("contextType")
  let $editButtonProvider :=
    if ($contextType = "form")
    then "schema/render/button/modal/edit"
    else "schema/render/button/page/edit"
  return
    <td xmlns="http://www.w3.org/1999/xhtml">{if ($Item/@readonly) then () else <a class="ajax fa fa-copy" href="{$global:servlet-prefix}/sanofi/regelung/copy/{$Item/@id}"/>}</td>
};


declare %plugin:provide("schema/render/table/tbody/tr/actions","admin")
function _:schema-render-table-tbody-tr-td-actions-admin-2(
  $Item as element(), 
  $Schema as element(schema), 
  $Context as map(*)
) as element(xhtml:td) {
  let $context := $Context => map:get("context")
  let $provider := $Schema/@provider/string()
  let $contextType := $Context => map:get("contextType")
  let $editButtonProvider :=
    if ($contextType = "form")
    then "schema/render/button/modal/edit"
    else "schema/render/button/page/edit"
  return
    <td xmlns="http://www.w3.org/1999/xhtml">{plugin:provider-lookup($provider,$editButtonProvider,$context)!.($Item,$Schema,$Context)}</td>
};

declare %plugin:provide("schema/render/table/tbody/tr/actions","admin")
function _:schema-render-table-tbody-tr-td-actions-admin-1(
  $Item as element(), 
  $Schema as element(schema), 
  $Context as map(*)
) as element(xhtml:td) {
  let $context := $Context => map:get("context")
  let $provider := $Schema/@provider/string()
  let $contextType := $Context => map:get("contextType")
  let $editButtonProvider :=
    if ($contextType = "form")
    then "schema/render/button/modal/edit"
    else "schema/render/button/page/edit"
  return
    <td xmlns="http://www.w3.org/1999/xhtml">{if ($Item/@readonly) then (<i class="fa fa-snowflake-o"/>) else ()}</td>
};

declare %plugin:provide("schema/render/table/thead/tr/actions")
function _:schema-render-table-thead-tr-td-actions(
  $Item as element()*, 
  $Schema as element(schema), 
  $Context as map(*)
) as element(xhtml:th) {
  <th xmlns="http://www.w3.org/1999/xhtml" data-sort-ignore="true"></th>
};

declare %plugin:provide("content/view/context","kv")
function _:render-page-table($Items as element(vertrag)*, $Schema as element(schema), $Context)
{
  plugin:provider-lookup($_:ns,"schema/render/table")!.($Items, $Schema, $Context)
};


declare 
%plugin:provide("schema/ui/page/content")
function _:render-page-table-stammdaten2($Items as element(regelung)*, $Schema as element(schema), $Context)
{
  if ($Context?items) then
  plugin:provider-lookup($_:ns,"schema/render/table")!.($Items, $Schema, $Context)
  else if ($Context?item) then
  plugin:provider-lookup($_:ns,"schema/render/page/form")!.($Items, $Schema, $Context)
};



declare %plugin:provide("schema/render/table")
function _:schema-render-table(
  $Items as element()*, 
  $Schema as element(schema), 
  $ContextMap as map(*)
) as element(xhtml:div) {
  let $context :=$ContextMap => map:get('context')
  let $provider := $Schema/@provider/string()
  let $uuid := random:uuid()
  let $table-class := "schema-"||$Schema/@name||"-table"
  (: select, sort, filter and process items :)
  let $page  := xquery:eval($Schema/list/query/text(),map{"ContextMap":$ContextMap})
  let $count := $page/@count?:0 => xs:integer()
  let $items := $page/element()
  (: next line fixes: page-size must not be greater than the total count :)
  (:let $ContextMap := if ($ContextMap?page-size > $count) then $ContextMap=>map:put("page-size",$count) else $ContextMap:)
  (: prepare schema to only contain fields ("elements"), that were created in the items :)
  let $schema := $Schema update delete node ./element
  let $schema := $schema update for $element in subsequence($items,1,1)/element() return insert node $Schema/element[@name=$element/name()] into .
  return
  
<div xmlns="http://www.w3.org/1999/xhtml" 
     class="slimScrollDiv bg-gray" style="position: relative; overflow: hidden; width: auto; height: 100%;">
	<div class="full-height-scroll" style="overflow: hidden; width: auto; height: 100%;">
    {plugin:provider-lookup($provider,"schema/render/table/debug")!.($items,$schema,$ContextMap)}
			<form method="GET" action="/schema/list/items" class="ajax">
      
 		<div class="row col-md-12">
        <div class="row col-md-6">
			<div class="input-group">
				<input id="filter-{$uuid}" type="text" class="form-control" placeholder="Search" data-i18n="search-table" name="search" value="{$ContextMap?search}"/>
				<span class="input-group-btn">
					<button type="submit" onclick="document.querySelector(&quot;input[name='page-start']&quot;).value=1" class="btn btn-primary">Go!</button>
				</span>
        </div>
			</div>
        <div class="col-md-2">
				<div class="input-group">
					<input type="number" min="1" max="100" value="{$ContextMap?page-size?:15}" name="page-size" class="form-control" size="4"/>
					<span class="input-group-btn">
						<button type="submit" class="btn btn-primary">set</button>
					</span>
          </div>
       </div>
       </div>
     <div class="form-group">
         {
            for $name in ('provider','context-provider','context','field','page-start','order-by')
            return <input type="hidden" name="{$name}" value="{$ContextMap=>map:get($name)}"/>
          }
          {
            let $page-count := ($count div $ContextMap?page-size) => floor() => xs:integer()
            let $page-size := $ContextMap?page-size
            let $page-start := if ($ContextMap?page-start=1) then $page-size else $ContextMap?page-start
            for $i in 1 to $page-count
            let $page-oversize := if ($i = $page-count) then $page-size - ($count mod $page-size) else 0
            let $class := attribute class {if ($page-start div $page-size = $i) then "btn btn-primary" else "btn btn-outline"}
            return <button onclick="document.querySelector(&quot;input[name='page-start']&quot;).value={$i*$ContextMap?page-size}">
                      {$class}
                      {($i*$page-size)-$page-size + 1} - {$i*$page-size - $page-oversize}
                   </button>
          }
       </div>
			</form>
      {plugin:default("schema/render/table")!.($items,$schema,$ContextMap)//xhtml:div[contains(@class,"ibox-content")]}
	</div>
</div>
};

declare %plugin:provide("schema/render/table/tbody/tr/td/foreign-key")
function _:schema-render-table-tbody-tr-td-foreign-key(
  $Item as element(), 
  $Schema as element(schema), 
  $ContextMap as map(*)
) as element(xhtml:td) {
  let $mode := if ($ContextMap?contextType='page') then "" else "-2"
  return 
    <td xmlns="http://www.w3.org/1999/xhtml">
      { if ($Item/*:key) then
        for $key in $Item/*:key 
        return
        modal:button("influx-modal-dialog"||$mode,
          "/schema/form/modal/"||$key/@id||"?provider="||$Schema/*:element[@name=$Item/name()]/*:provider||"&amp;context=&amp;context-provider="||$Schema/@provider||"&amp;context-item-id="||$key/../../@id||"&amp;mode=view",
          <a>{$key/node()}</a>
        )
        else $Item/node()}
    </td>
};

(: Stammdaten/Regelung :)

declare %plugin:provide("schema/render/table/tbody/tr/actions","stammdaten/regelung")
function _:schema-render-table-tbody-tr-td-actions(
  $Item as element(), 
  $Schema as element(schema), 
  $ContextMap as map(*)
) as element(xhtml:td) {
    <td xmlns="http://www.w3.org/1999/xhtml">{plugin:provider-lookup($_:ns,"schema/render/button/modal/edit","stammdaten/regelung")!.($Item,$Schema,$ContextMap)}</td>
};


declare 
%plugin:provide("content/view/context","stammdaten/regelung")
function _:render-page-table-stammdaten($Items as element(vertrag)*, $Schema as element(schema), $Context)
{
  if ($Context?items) then
  plugin:provider-lookup($_:ns,"schema/render/table")!.($Items, $Schema, $Context)
  else if ($Context?item) then
  plugin:provider-lookup($_:ns,"schema/render/page/form")!.($Items, $Schema, $Context)
};



(: helper functions :)
(: Funktione für deutsches, aktuelles Datum :)
declare function _:current-date-to-html5-input-date-de() 
as xs:string? {
    format-dateTime(current-dateTime(), "[D01].[M01].[Y0001]", "de", (), ())
};
