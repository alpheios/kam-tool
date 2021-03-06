module namespace _ = "sanofi/kv";

(: import repo modules :)
import module namespace global	= "influx/global";
import module namespace plugin	= "influx/plugin";
import module namespace db	    = "influx/db";
import module namespace ui =" influx/ui";
import module namespace date-util ="influx/utils/date-utils";
import module namespace common = "sanofi/common" at "common.xqm";
import module namespace import = "influx/modules";
import module namespace alert="influx/ui/alert";


declare namespace xhtml="http://www.w3.org/1999/xhtml";
declare variable $_:ns := namespace-uri(<_:ns/>);

(: ----------------- :)

declare %plugin:provide('side-navigation-item') function _:nav-item-kv() as element(xhtml:li) {
  common:nav-item(_:schema())
};

declare %plugin:provide('ui/page/title') function _:heading($m){_:schema()//*:title/string()};
declare %plugin:provide("ui/page/content") function _:ui-page-content($m){common:ui-page-content($m)};
declare %plugin:provide("ui/page/heading") function _:ui-page-heading($m){common:ui-page-heading($m)};

(: ----------------- :)

declare variable $_:kv-bezirke := plugin:lookup("plato/schema/enums/get")!.("KV-Bezirke");
declare variable $_:merkmale-regelungen := plugin:lookup("plato/schema/enums/get")!.("Merkmale Regelungen");

declare %plugin:provide('side-navigation-item')
  function _:nav-item-stammdaten-kv()
  as element(xhtml:li) {
  <li xmlns="http://www.w3.org/1999/xhtml" data-parent="/schema/list/items" data-sortkey="AAA">
      <a href="{$global:servlet-prefix}/schema/list/items?context=kv&amp;provider=sanofi/kv&amp;contextType=page"><i class="fa fa-user-md"></i> <span class="nav-label">Kassenärztliche Vereinigungen</span></a>
  </li>
};

declare %plugin:provide("schema/render/modal/debug/itemXXX") function _:debug-kv ($Item,$Schema,$Context){
<pre>{serialize($Item)}</pre>
};

declare %plugin:provide("schema/set/elements","kv")
function _:schema-column-filter($Item as element()*, $Schema as element(schema), $Context as map(*)){
    let $columns := plugin:lookup("plato/schema/columns/get")!.("kv")
    let $schema := $Schema update delete node ./*:element
    let $elements-in-order := for $name in $columns return $Schema/element[@name=$name]
    let $schema := $schema update insert node $elements-in-order as last into .
    return $schema
};

declare %plugin:provide("schema") function _:schema()
as element(schema){
<schema xmlns="" name="kv" domain="sanofi" provider="sanofi/kv">
    <modal>
        <title>Kassenärztliche Vereinigung</title>
    </modal>
    <nav-item sortkey="KV" context="kv" title="Kassenärztliche Vereinigung" icon="user-md"/>
    <element name="name" type="enum">
        {$_:kv-bezirke ! <enum key="{.}">{.}</enum>}
        <label>Name</label>
    </element>
    <element name="verantwortlich" type="foreign-key" render="dropdown" required="">
                <provider>sanofi/key-accounter</provider>
                <key>@id/string()</key>
                <display-name>name/string()</display-name>
                <label>Zuständig</label>
                <class>col-md-6</class>
    </element>
    <element name="ansprechpartner" type="foreign-key" render="table" required="">
            <provider>sanofi/ansprechpartner</provider>
            <key>kv</key>
            <label>Ansprechpartner</label>
            <display-name>string-join((vorname/string(), " ",name/string()))</display-name>
    </element>
    <element name="pruefmethode" type="textarea">
        <label>Allgemeines zur Prüfmethode</label>
    </element>
        <element name="allgPBS" type="textarea">
        <label>Infomationen zu Praxisbesonderheiten</label>
    </element>
    (: Merkmale Regelung ausbelden, da die Datenbank inhalte trägt, sodass der Wert nicht erneut verwendet werden kann :)
     <element name="merkmale-regelungen" type="enum" multiple="">
      {$_:merkmale-regelungen ! <enum key="{.}">{.}</enum>}
      <label>Merkmale der Regelungen</label>
    </element> 
    (:   :)
    <element name="notizen" type="link">
        <label>Link</label>
    </element>
</schema>
};

declare %plugin:provide("schema", "kv-top-4")
function _:schema-top-4-kv() {
<schema xmlns="" name="kv" domain="sanofi" provider="sanofi/kv">

    <modal>
        <title>Management Zusammenfassung</title>
    </modal>
   <element name="management-summary" render="table" type="foreign-key" required="">
      <provider>sanofi/management-summary</provider>
      <key>kv</key>
      <label>Management Zusammenfassung</label>
      <display-name>string-join((name/string(), " (", datum/string(), ")"))</display-name>
   </element>
 </schema>
};

declare %plugin:provide("schema", "kv-arztzahlen")
function _:schema-arztzahlen-kv() {
<schema xmlns="" name="kv" domain="sanofi" provider="sanofi/kv">

    <modal>
        <title>Arztanzahl</title>
    </modal>
   <element name="arztzahl" render="table" type="foreign-key" required="">
      <provider>sanofi/kv-arztzahlen</provider>
      <key>kv</key>
      <label>Arztanzahl</label>
      <display-name>string-join((name/string(), " (", datum/string(), ")"))</display-name>
   </element>
 </schema>
};


declare %plugin:provide("schema", "kv-history")
function _:schema-history-kk() {
<schema xmlns="" name="kv" domain="sanofi" provider="sanofi/kv">

    <modal>
        <title>KV Kenngrößen</title>
    </modal>
   <element name="kv-kenngroessen" render="table" type="foreign-key" required="">
      <provider>sanofi/kv-top-4</provider>
      <key>kv</key>
      <label>KV Kenngrößen</label>
      <display-name>{(: Todo: Add display name:)}</display-name>
   </element>
 </schema>
};

declare %plugin:provide("profile/dashboard/widget")
function _:profile-dashboard-widget-kv($Profile as element())
{

    let $context := map{}
    let $schema := plugin:provider-lookup("sanofi/kv","schema")!.()
    let $items  := plugin:provider-lookup("sanofi/kv","datastore/dataobject/all")!.($schema,$context)
    let $items  := $items[*:verantwortlich=$Profile/@id/string()]
    return
        if (count($items)>0) then
        <div class="col-md-6">
         {plugin:lookup("schema/render/table/page")!.($items,$schema,$context)}
        </div>
        else ()
};



declare %plugin:provide("schema/render/page/form/buttons", "kv-history")
        %plugin:provide("schema/render/page/form/buttons", "kv-top-4")
        %plugin:provide("schema/render/page/form/buttons", "kv-arztzahlen")
function _:render-no-form-buttons($Item as element(), $Schema as element(schema), $Context as map(*)) {
()
};


declare %plugin:provide("schema/ui/page/content")
function _:render-page-form($Item as element()?, $Schema as element(schema), $Context)
{
let $form-id := "id-"||random:uuid()
let $title := $Schema/*:modal/*:title/string()
let $provider := $Schema/@provider
let $context:=$Context("context")
let $context-item-id:=$Context("context-item")/@id
let $Context := $Context 
                         => map:put("contextTyp","page")
                         => map:put("provider",$provider)
                         => map:put("context-item",$Item)
                         => map:put("context-item-id",$Item/@id/string())
return
<div xmlns="http://www.w3.org/1999/xhtml" class="tabs-container">
  <ul class="nav nav-tabs">
      <li class="active"><a data-toggle="tab" href="#tab-1">Stammdaten</a></li>
      <li class=""><a data-toggle="tab" href="#tab-2">Kenngrößen</a></li>
      <li class=""><a data-toggle="tab" href="#tab-4">Projekte</a></li>
      <li class=""><a data-toggle="tab" href="#tab-5">Verträge</a></li>
      <li class=""><a data-toggle="tab" href="#tab-7">Regelungen</a></li>
  </ul>
  <div class="tab-content">
      <div id="tab-1" class="tab-pane active">
          <div class="panel-body">
             {plugin:provider-lookup($provider,"schema/render/page/form")!.($Item,$Schema,$Context=>map:put("context-provider",$_:ns))}
          </div>
      </div>
      <div id="tab-2" class="tab-pane">
          <div class="panel-body">
          {
              let $provider := "sanofi/management-summary"
              let $schema := plugin:provider-lookup($provider,"schema", "kv-top-4")!.()
              let $context := "kv"
              let $items :=
                  for $item in plugin:provider-lookup($provider,"datastore/dataobject/search",$context)!.("kv",$Item/@id,$schema,$Context)
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
                let $context := "kv"
                let $schema := plugin:provider-lookup($provider,"schema",$context)!.()
                let $Context := $Context =>map:put("provider",$provider)
                                         =>map:put("context-provider",$_:ns)
                                         =>map:put("context-item", $Item)
                                         =>map:put("schema",$schema)
                                         =>map:put("context-schema",$Schema)
                let $items :=
                    for $item in plugin:provider-lookup($provider,"datastore/dataobject/search")!.("kv",$Item/@id,$schema,$Context)
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
                let $context := "kv"
                let $schema := plugin:provider-lookup($provider,"schema",$context)!.()
                let $Context := $Context =>map:put("provider",$provider)
                                         =>map:put("context-provider",$_:ns)
                                         =>map:put("context-item", $Item)
                                         =>map:put("schema",$schema)
                                         =>map:put("context-schema",$Schema)
                let $items :=
                    for $item in plugin:provider-lookup($provider,"datastore/dataobject/search")!.("kv/key",$Item/@id,$schema,$Context)
                    let $date := $item/@last-modified-date
                    order by $date descending
                    return $item
                return
                plugin:provider-lookup($provider,"content/view/context",$context)!.($items,$schema,$Context)
            }
          </div>
      </div>
      <div id="tab-7" class="tab-pane">
          <div class="panel-body">
            {
                let $provider := "sanofi/regelung"
                let $context := "kv"
                let $schema := plugin:provider-lookup($provider,"schema",$context)!.()
                let $Context := $Context =>map:put("provider",$provider)
                                         =>map:put("context-provider",$_:ns)
                                         =>map:put("context-item", $Item)
                                         =>map:put("schema",$schema)
                                         =>map:put("context-schema",$Schema)
                let $items :=db:eval("collection('datastore-sanofi-regelung')/regelung[kv=$ci]",map{"ci":$Item/@id/string()})
                    
                return
                plugin:provider-lookup($provider,"schema/render/table",$context)!.($items,$schema,$Context)
            }
          </div>
      </div>
  </div>
</div> 
};