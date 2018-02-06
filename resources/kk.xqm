module namespace _ = "sanofi/kk";

(: import repo modules :)
import module namespace global	= "influx/global";
import module namespace plugin	= "influx/plugin";
import module namespace date-util ="influx/utils/date-utils";

declare namespace xhtml="http://www.w3.org/1999/xhtml";

declare variable $_:land := plugin:lookup("plato/schema/enums/get")!.("Bundesländer");
declare variable $_:kv-bezirke := plugin:lookup("plato/schema/enums/get")!.("KV-Bezirke");
declare variable $_:kk := plugin:lookup("plato/schema/enums/get")!.("Krankenkassen");

declare %plugin:provide('side-navigation')
  function _:nav-item-stammdaten-kk()
  as element(xhtml:li) {
  <li xmlns="http://www.w3.org/1999/xhtml" data-parent="/schema/list/items" data-sortkey="ZZZ">
      <a href="{$global:servlet-prefix}/schema/list/items?context=stammdaten/kk&amp;provider=sanofi/kk"><i class="fa fa-users"></i> <span class="nav-label">Krankenkassen</span></a>
  </li>
};

declare %plugin:provide("schema/render/page/debug/itemX") function _:debug-kk (
  $Item as element(),
  $Schema as element(schema),
  $Context as map(*)
) as element(pre) {
  <pre>{serialize($Item)}</pre>
};

declare %plugin:provide("ui/page/content","stammdaten/kk")
function _:stammdaten-kk($map)
as element(xhtml:div)
{
<div xmlns="http://www.w3.org/1999/xhtml" class="content-with-sidebar row">
  <div class="row">
      <div class="col-lg-12">
            {plugin:lookup("schema/ibox/table")!.("sanofi/kk", "stammdaten/kk") (: ACHTUNG: manueller Switch auf "kk" Kontext! :)}
      </div>
  </div>
</div>
};

declare %plugin:provide("schema/process/table/items")
function _:schema-render-table-prepare-rows-jf($Items as element()*, $Schema as element(schema),$Context as map(*))
{
for $item in $Items order by $item/name return $item
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
        <button>
            <add>hinzufügen</add>
            <cancel>abbrechen</cancel>
            <modify>ändern</modify>
            <delete>löschen</delete>
        </button>
    </modal>
    <element name="name" type="enum">
    <label>Name</label>
    {
      $_:kk ! <enum key="{.}">{.}</enum>
    }
    </element>
    <element name="kv-bezirk" type="enum" multiple="">
      <label>KV Bezirke</label>
      {$_:kv-bezirke ! <enum key="{.}">{.}</enum>}
    </element>
    <element name="verantwortlich" type="foreign-key" required="">
      <provider>sanofi/key-accounter</provider>
      <key>@id/string()</key>
      <display-name>name/string()</display-name>
      <label>Verantwortlich</label>
      <class>col-md-6</class>
    </element>
    <element name="ansprechpartner" type="foreign-key" render="table" required="">
      <provider>sanofi/ansprechpartner</provider>
      <key>kk</key>
      <label>Ansprechpartner</label>
      <display-name>string-join((vorname/string(), " ",name/string()))</display-name>
    </element>
    <element name="zusammenfassung" type="foreign-key" render="table">
      <provider>sanofi/kk-summary</provider>
      <key>kk</key>
      <label>Zusammenfassung</label>
      <display-name>name/string()</display-name>
    </element>
  </schema>
};

declare %plugin:provide("schema", "kk-history")
function _:schema-history-kk() {
<schema xmlns="" name="kk" domain="sanofi" provider="sanofi/kk">

    <modal>
        <title>KK Versicherte</title>
        <button>
            <add>hinzufügen</add>
            <cancel>abbrechen</cancel>
            <modify>ändern</modify>
            <delete>löschen</delete>
        </button>
    </modal>
   <element name="kk-versicherte" render="table" type="foreign-key" required="">
      <provider>sanofi/kk-history-mitglieder</provider>
      <key>kk</key>
      <label>KK Versicherte</label>
      <display-name>string-join((datum/string(), ": ", anzahl/string(), " (", marktanteil/string(), ")"))</display-name>
   </element>
 </schema>
};

declare %plugin:provide("schema", "kk-top-4")
function _:schema-top-4-kk() {
<schema xmlns="" name="kk" domain="sanofi" provider="sanofi/kk">

    <modal>
        <title>KK Top 4</title>
        <button>
            <add>hinzufügen</add>
            <cancel>abbrechen</cancel>
            <modify>ändern</modify>
            <delete>löschen</delete>
        </button>
    </modal>
   <element name="kk-versicherte" render="table" type="foreign-key" required="">
      <provider>sanofi/kk-kam-top-4</provider>
      <key>kk</key>
      <label>KK Top 4</label>
      <display-name>string-join((name/string(), " (", datum/string(), ")"))</display-name>
   </element>
 </schema>
};

declare %plugin:provide("schema/render/page/form/buttons", "kk-history")
        %plugin:provide("schema/render/page/form/buttons", "kk-top-4")
function _:render-no-form-buttons($Item as element(), $Schema as element(schema), $Context as map(*), $Form-id) {
()
};


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
  let $kks := plugin:lookup("datastore/dataobject/all")!.($schema,map{})[@id!=$Item/@id]
  let $assigned-names := $kks/name/string()
  let $names := $_:kk[not(.=$assigned-names)]
  return
    $names ! <enum key="{.}">{.}</enum>
};


declare %plugin:provide("profile/dashboard/widget")
function _:profile-dashboard-widget-kk($Profile as element())
{

    let $context := map{}
    let $schema := plugin:provider-lookup("sanofi/kk","schema")!.()
    let $items  := plugin:provider-lookup("sanofi/kk","datastore/dataobject/all")!.($schema,$context)
    let $items  := $items[*:verantwortlich=$Profile/@id/string()]
    return
        if (count($items)>0) then
        <div class="col-md-6">
         {plugin:provider-lookup("sanofi/kk","schema/render/table/page")!.($items,$schema,$context)}
        </div>
        else ()

};

declare %plugin:provide("schema/render/button/page/edit/link", "stammdaten/kk")
function _:schema-render-button-page-edit-link($Item as element()?, $Schema as element(schema), $Context as map(*))
as xs:string
{
let $provider := $Schema/@provider/string()
return
"schema/form/page/"||$Item/@id||"?provider="||$provider||"&amp;context=kk"||"&amp;context-item-id="||$Item/@id||"&amp;context-provider="||$provider
};

declare %plugin:provide("schema/ui/page/content","kk")
function _:render-page-form($Item as element()?, $Schema as element(schema), $Context)
{
let $form-id := "id-"||random:uuid()
let $title := $Schema/*:modal/*:title/string()
let $provider := $Schema/@provider
let $context := $Context("context")
let $Context := map:remove($Context,"context")
let $Context := map:put($Context,"context",$context)
let $Context := if (map:contains($Context,"kk")) then $Context else map:put($Context,"kk",$Item/@id/string())
return
<div xmlns="http://www.w3.org/1999/xhtml" class="content-with-sidebar sanofi-kk-page" data-replace=".sanofi-kk-page">
  <div class="ibox float-e-margins">
      <div class="tabs-container">
          <ul class="nav nav-tabs">
              <li class="active"><a data-toggle="tab" href="#tab-1">Formular</a></li>
              <li class=""><a data-toggle="tab" href="#tab-2">TOP 4</a></li>
              <li class=""><a data-toggle="tab" href="#tab-3">Blauer Ozean</a></li>
              <li class=""><a data-toggle="tab" href="#tab-4">Projekte</a></li>
              <li class=""><a data-toggle="tab" href="#tab-5">Verträge</a></li>
          </ul>
          <div class="tab-content">
              <div id="tab-1" class="tab-pane active">
                  <div class="panel-body">
                     {plugin:provider-lookup($provider,"schema/render/page/form", $context)!.($Item,$Schema,$Context)}
                  </div>
              </div>
              <div id="tab-2" class="tab-pane">
                  <div class="panel-body">
                  {
                      let $provider := "sanofi/kk-kam-top-4"
                      let $schema := plugin:provider-lookup($provider,"schema")!.()
                      let $items :=
                          for $item in plugin:provider-lookup($provider,"datastore/dataobject/all",$context)!.($schema,$Context)
                          let $date := $item/@last-modified-date
                          order by $date descending
                          return $item
                      let $item-latest := $items[1]
                      return
                          plugin:provider-lookup($provider,"content/view/context",$context)!.($item-latest,$schema,$Context)
                  }
                  </div>
              </div>
              <div id="tab-3" class="tab-pane">
                  <div class="panel-body">
                    {
                    let $provider := "sanofi/blauer-ozean"
                    let $schema := plugin:provider-lookup($provider,"schema",$context)!.()
                    let $blauer-ozean-items :=
                        for $item in plugin:provider-lookup($provider,"datastore/dataobject/all",$context)!.($schema,$Context)
                        let $date := $item/@last-modified-date
                        order by $date descending
                        return $item
                    let $blauer-ozean-item-latest := $blauer-ozean-items[1]
                    return
                        plugin:provider-lookup($provider,"content/view/context",$context)!.($blauer-ozean-item-latest,$schema,$Context)
                    }
                  </div>
              </div>
              <div id="tab-4" class="tab-pane">
                  <div class="panel-body">
                    {
                        let $provider := "sanofi/projekt"
                        let $context := "kk"
                        let $schema := plugin:provider-lookup($provider,"schema",$context)!.()
                        let $items :=
                            for $item in plugin:provider-lookup($provider,"datastore/dataobject/all")!.($schema,$Context)
                            let $date := $item/@last-modified-date
                            order by $date descending
                            return $item
                        let $item-latest := $items[1]
                        return
                        plugin:provider-lookup($provider,"content/view/context",$context)!.($item-latest,$schema,$Context)
                    }
                  </div>
              </div>
              <div id="tab-5" class="tab-pane">
                  <div class="panel-body">
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
                    }
                  </div>
              </div>
          </div>
      </div>
  </div>
 </div>
 };