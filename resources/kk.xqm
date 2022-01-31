module namespace _ = "sanofi/kk";

(: import repo modules :)
import module namespace global	= "influx/global";
import module namespace plugin	= "influx/plugin";
import module namespace date-util ="influx/utils/date-utils";
import module namespace ui      = "influx/ui";
import module namespace user    = "influx/user";
import module namespace db			= "influx/db";
import module namespace common  = "sanofi/common" at "common.xqm";
import module namespace import = "influx/modules";
import module namespace alert="influx/ui/alert";

declare namespace xhtml="http://www.w3.org/1999/xhtml";

declare variable $_:land := plugin:lookup("plato/schema/enums/get")!.("Bundesländer");
declare variable $_:kv-bezirke := plugin:lookup("plato/schema/enums/get")!.("KV-Bezirke");
declare variable $_:kk := plugin:lookup("plato/schema/enums/get")!.("Krankenkassen");
declare variable $_:kk-items := db:eval("collection('datastore-sanofi-kk')/kk");
declare variable $_:ns := namespace-uri(<_:ns/>);


declare %plugin:provide('side-navigation-item')
  function _:nav-item-stammdaten-kk-fusioniert()
  as element(xhtml:li) {
  <li xmlns="http://www.w3.org/1999/xhtml" data-parent="/schema/list/items/fusioniert" data-sortkey="AAA">
      <a href="{$global:servlet-prefix}/schema/list/items?context=fusioniert/kk&amp;provider=sanofi/kk&amp;contextType=page"><i class="fa fa-bank"></i> <span class="nav-label">Krankenkassen</span></a>
  </li>
};

declare %plugin:provide('side-navigation-item') function _:nav-item(){
    common:nav-item(_:schema-default())
};
declare %plugin:provide('ui/page/title') function _:heading($m){_:schema-default()//*:title/string()};
declare %plugin:provide("ui/page/content") function _:ui-page-content($m){common:ui-page-content($m)};
declare %plugin:provide("ui/page/heading") function _:ui-page-heading($m){common:ui-page-heading($m)};


declare %plugin:provide("schema/process/table/items")
function _:schema-render-table-prepare-rows-jf($Items as element()*, $Schema as element(schema),$Context as map(*))
{
  for $item in $Items 
  order by $item/name 
  where $item/fusioniert/string() = ""
  return $item
};

declare %plugin:provide("schema/process/table/items", "fusioniert/kk")
function _:schema-render-table-prepare-rows-fusioniert($Items as element()*, $Schema as element(schema),$Context as map(*))
{
  for $item in $Items 
  order by $item/name 
  where $item/fusioniert/string() = "true"
  return $item
};

declare %plugin:provide("schema/set/elements")
function _:schema-column-filter($Item as element()*, $Schema as element(schema), $Context as map(*)){
    let $columns := plugin:lookup("plato/schema/columns/get")!.("kk")
    let $schema := $Schema update delete node ./*:element
    let $elements-in-order := for $name in $columns return $Schema/element[@name=$name]
    let $schema := $schema update insert node $elements-in-order as last into .
    return $schema
};

declare %plugin:provide("schema") function _:schema-default()
as element(schema){
<schema xmlns="" name="kk" domain="sanofi" provider="sanofi/kk">
    <modal>
        <title>Gesetzliche Krankenkasse</title>
    </modal>
    <nav-item sortkey="KK" context="kk" title="Gesetzliche Krankenkassen" icon="bank"/>
    <element name="name" type="enum">
    <label>Name</label>
    {
      $_:kk ! <enum key="{.}">{.}</enum>
    }
    </element>
    <element name="verantwortlich" type="foreign-key" render="dropdown" required="">
      <provider>sanofi/key-accounter</provider>
      <key>@id/string()</key>
      <display-name>name/string()</display-name>
      <label>Zuständig</label>
      <class>col-md-6 hidden-sm hidden-xs</class>
    </element>
    <element name="ansprechpartner" type="foreign-key" render="table" required="">
      <provider>sanofi/ansprechpartner</provider>
      <key>kk</key>
      <label>Ansprechpartner</label>
      <display-name>string-join((vorname/string(), " ",name/string()))</display-name>
    </element>
    <!--<element name="zusammenfassung" type="foreign-key" render="table">
      <provider>sanofi/kk-summary</provider>
      <key>kk</key>
      <label>Zusammenfassung</label>
      <display-name>name/string()</display-name>
    </element>-->
    <element name="fusioniert" type="hidden"></element>
    <element name="fusionsdatum" type="date">
      <label>Wurde fusioniert am</label>
    </element>
    <element name="kv-bezirk" type="enum" multiple="">
      <label>KV Bezirke</label>
      {$_:kv-bezirke ! <enum key="{.}">{.}</enum>}
    </element>
    <element name="notizen" type="link">
        <label>Link</label>
    </element>

  </schema>
};


declare %plugin:provide("schema/render/form/field/enum/datasource/filter")
function _:filter-enum-datasource(
    $Item as element(),
    $Element as element(element),
    $Context as map(*)
) as element(enum)* {
  if ($Element/@name/string() = "name")
  then
    let $provider := "sanofi/kk"
    let $context := $Context("context")
    let $schema := plugin:provider-lookup($provider, "schema", $context)!.()
    let $kks := plugin:lookup("datastore/dataobject/all")!.($schema, $Context)
    let $enums :=
      for $enum in $Element/enum
      let $kk := $kks[./name/string() = $enum/string()]
      where not($kk)
      return $enum
    return $enums
  else $Element/enum
};

declare %plugin:provide("schema/render/form/field/foreign-key/datasource/filter")
function _:filter-foreign-key-datasource(
    $Item as element()?,
    $Element as element(element),
    $Context as map(*)
) as element(kk)? {
  if ($Item/fusioniert/string() = "true")
  then $Item update replace value of node ./name with "[↯] "||./name/string()
  else $Item
};

declare %plugin:provide("schema", "kk-history")
function _:schema-history-kk() {
<schema xmlns="" name="kk" domain="sanofi" provider="sanofi/kk">

    <modal>
        <title>KK Kenngrößen</title>
    </modal>
   <element name="kk-kenngroessen" render="table" type="foreign-key" required="">
      <provider>sanofi/kk-top-4</provider>
      <key>kk</key>
      <label>KK Kenngrößen</label>
      <display-name>string-join((datum/string(), ": ", anzahl/string(), " (", marktanteil/string(), ")"))</display-name>
   </element>
 </schema>
};

declare %plugin:provide("schema", "kk-top-4")
function _:schema-top-4-kk() {
<schema xmlns="" name="kk" domain="sanofi" provider="sanofi/kk">

    <modal>
        <title>Management Zusammenfassung</title>
    </modal>
   <element name="management-summary" render="table" type="foreign-key" required="">
      <provider>sanofi/management-summary</provider>
      <key>kk</key>
      <label>Management Zusammenfassung</label>
      <display-name>string-join((name/string(), " (", datum/string(), ")"))</display-name>
   </element>
 </schema>
};

declare %plugin:provide("schema", "profile")
function _:schema-kk-profile() {
  _:schema-default() update (
    replace value of node ./element[@name="verantwortlich"]/@render with "context-item"
    ,delete node ./element[@name="verantwortlich"]/label
  )};

declare %plugin:provide("schema/render/page/form/buttons", "kk-history")
        %plugin:provide("schema/render/page/form/buttons", "kk-top-4")
function _:render-no-form-buttons($Item as element(), $Schema as element(schema), $Context as map(*)) {
()
};

(: 
  Wenn der Name in der Details Ansicht einer KK nicht bearbeitet werden können soll, dann muss 
  das wieder rein. Dann muss aber auch der Kontext im Link in der Sidenavigation geändert werden
  und der Kontextswitch im Edit Link eingebaut werden, sonst kann beim neu anlegen einer KK kein Name
  für die KK ausgewählt werden.
:)

declare %plugin:provide("schema", "kk")
function _:schema-kk() {  
  _:schema-default() update (
    replace value of node ./element[@name="name"]/@type with "hidden"
    ,delete node ./element[@name="name"]/label
  )
};

declare %plugin:provide("schema/render/form/field/enum/datasource/filter", "name") 
function _:filter-kk-names(
  $Item as element(),
  $Element as element(element),
  $Context as map(*)
) as element(enum)* {
  let $schema := $Element/ancestor::schema
  (:let $kks := plugin:lookup("datastore/dataobject/all")!.($schema,map{})[@id!=$Item/@id]:)
  let $assigned-names := $_:kk-items[@id!=$Item/@id]/name/string()
  let $names := $_:kk[not(.=$assigned-names)]
  return
    $names ! <enum key="{.}">{.}</enum>
};

declare %plugin:provide("schema/datastore/dataobject/put/check") 
function _:check-for-fusionsdatum(
  $Item as element(),
  $Schema as element(schema),
  $Context as map(*)
) as xs:boolean {
  if ($Item/fusionsdatum/string())
  then 
    if (xs:date($Item/fusionsdatum/string()) <= current-date())
    then true()
    else false()
  else true()
};

declare %plugin:provide("schema/datastore/dataobject/put/check/fail/message")
function _:custom-dataobject-validation-fail-message(
  $Item as element(), 
  $Schema as element(schema), 
  $Context as map(*)
) as element(xhtml:div) {
  let $checkFusionsdatum := _:check-for-fusionsdatum($Item, $Schema, $Context)
  return
    if ($checkFusionsdatum)
    then
      ui:error(<span data-i18n="custom-validation-fail-message">You tried to save invalid data.</span>)
    else
      ui:error(<span data-i18n="insert-future-fusionsdatum">The Fusionsdatum has to be in the past.</span>)
};

declare %plugin:provide("schema/datastore/dataobject/put/pre-hook")
function _:insert-fusion-if-neccessary(
  $Item as element(), 
  $Schema as element(schema), 
  $Context as map(*)
) as element(*) {
  if ($Item/fusionsdatum/string())
    then
      $Item update replace value of node ./fusioniert with true()
    else
      $Item update replace value of node ./fusioniert with ()
};

declare %plugin:provide("profile/dashboard/widget")
function _:profile-dashboard-widget-kk($Profile as element())
{
    let $schema := plugin:provider-lookup("sanofi/key-accounter", "schema")!.()
    let $key-accounter := plugin:lookup("datastore/dataobject/field")!.("username", user:current(), $schema, map {})

    let $Context := map{
      "context":"profile",
      "context-item": $key-accounter,
      "provider": "sanofi/kk"
    }
    
    let $context := "kk"
    let $schema := plugin:provider-lookup("sanofi/kk","schema",$context)!.()
    let $items  := plugin:provider-lookup("sanofi/kk","datastore/dataobject/all")!.($schema,$Context)
    let $items  := $items[*:verantwortlich=$Profile/@id/string()]
    return
        if (count($items)>0) then
        <div class="col-md-6">
         {plugin:provider-lookup("sanofi/kk","schema/render/table/page",$context)!.($items,$schema,$Context)}
        </div>
        else ()

};

declare %plugin:provide("schema/ui/page/content")
function _:render-page-form($Item as element()?, $Schema as element(schema), $Context)
{
let $form-id := "id-"||random:uuid()
let $title := $Schema/*:modal/*:title/string()
let $provider := $Schema/@provider
let $context := "kk"
let $Context := $Context=>map:put("kk",$Item/@id/string())
                        =>map:put("provider",$_:ns)
                        =>map:put("context-item",$Item)
return
      <div xmlns="http://www.w3.org/1999/xhtml" class="tabs-container">
          <ul class="nav nav-tabs">
              <li class="active"><a data-toggle="tab" href="#tab-1">Stammdaten</a></li>
              <li class=""><a data-toggle="tab" href="#tab-2">Kenngrößen</a></li>
              <li class=""><a data-toggle="tab" href="#tab-4">Projekte</a></li>
              <li class=""><a data-toggle="tab" href="#tab-5">Verträge</a></li>
          </ul>
          <div class="tab-content">
              <div id="tab-1" class="tab-pane active">
                  <div class="panel-body">
                     {                        
                       plugin:provider-lookup($provider,"schema/render/page/form", $context)!.($Item,$Schema,$Context=>map:put("context-provider",$_:ns))
                     }
                  </div>
              </div>
              <div id="tab-2" class="tab-pane">
                  <div class="panel-body">
                  {
                      let $provider := "sanofi/management-summary"
                      let $schema := plugin:provider-lookup($provider,"schema", "kk-top-4")!.()
                      let $Context := $Context =>map:put("provider",$provider)
                                         =>map:put("context-provider",$_:ns)
                                         =>map:put("context-item", $Item)
                                         =>map:put("schema",$schema)
                                         =>map:put("context-schema",$Schema)
                      let $items :=
                            for $item in plugin:provider-lookup($provider,"datastore/dataobject/search",$Context?context)!.("kk",$Item/@id,$schema,$Context)
                          let $date := $item/@last-modified-date
                          order by $date descending
                          return $item
                      return
                          plugin:provider-lookup($provider,"content/view/context",$context)!.($items,$schema,$Context)
                  }
                  </div>
              </div>
              <div id="tab-4" class="tab-pane">
                  <div class="panel-body">
                    {
                        let $provider := "sanofi/projekt"
                        let $context := "kk"
                        let $schema := plugin:provider-lookup($provider,"schema",$context)!.()
                        let $Context := $Context =>map:put("provider",$provider)
                                         =>map:put("context-provider",$_:ns)
                                         =>map:put("context-item", $Item)
                                         =>map:put("schema",$schema)
                                         =>map:put("context-schema",$Schema)
                        let $items :=
                            for $item in plugin:provider-lookup($provider,"datastore/dataobject/search",$Context?context)!.("kk",$Item/@id,$schema,$Context)
                            let $date := $item/@last-modified-date
                            order by $date descending
                            return $item
                        return
                        plugin:provider-lookup($provider,"content/view/context",$context)!.($items,$schema,$Context)
                    }
                  </div>
              </div>
              <div id="tab-5" class="tab-pane">
                  <div class="panel-body">
                    {
                        let $provider := "sanofi/vertrag"
                        let $context := "kk"
                        let $schema := plugin:provider-lookup($provider,"schema",$context)!.()
                        let $Context := $Context =>map:put("provider",$provider)
                                         =>map:put("context-provider",$_:ns)
                                         =>map:put("context-item", $Item)
                                         =>map:put("schema",$schema)
                                         =>map:put("context-schema",$Schema)
                        let $items :=
                            for $item in plugin:provider-lookup($provider,"datastore/dataobject/search")!.("kk",$Item/@id,$schema,$Context)
                            let $date := $item/@last-modified-date
                            order by $date descending
                            return $item
                        return
                        plugin:provider-lookup($provider,"content/view/context",$context)!.($items,$schema,$Context)
                    }
                  </div>
              </div>
          </div>
      </div> 
 };