module namespace _ = "sanofi/blauer-ozean";

(: import repo modules :)
import module namespace global	= "influx/global";
import module namespace plugin	= "influx/plugin";
import module namespace db	    = "influx/db";
import module namespace ui =" influx/ui2";

declare namespace xhtml="http://www.w3.org/1999/xhtml";

declare %plugin:provide('side-navigation')
  function _:nav-item-stammdaten-blauer-ozean()
  as element(xhtml:li) {
  <li xmlns="http://www.w3.org/1999/xhtml" data-parent="/sanofi/stammdaten" data-sortkey="ZZZ">
      <a href="{$global:servlet-prefix}/sanofi/stammdaten/blauer-ozean"><i class="fa fa-users"></i> <span class="nav-label">Blauer Ozean</span></a>
  </li>
};

declare %plugin:provide("ui/page/content","stammdaten/blauer-ozean")
function _:stammdaten-blauer-ozean($map)
as element(xhtml:div)
{
let $items := $map("items")
let $provider := $map("provider")
let $id := $map("id")
let $modal-button := ui:modal-button('schema/form/modal?provider='||$provider||"&amp;context=page",<a xmlns="http://www.w3.org/1999/xhtml" shape="rect" class="btn btn-sm btn-outline"><span class="fa fa-plus"/></a>)
return
<div xmlns="http://www.w3.org/1999/xhtml" class="content-with-sidebar row">
  <div class="row">
      <div class="col-lg-12">
          <div class="ibox float-e-margins">
              <div class="ibox-title">
                  <h5>{$modal-button} Der Blaue Ozean (SWAT Alternative) als Radar Chart</h5>
                  <select class="chosen pull-right" onchange="window.location='/influx/sanofi/blauer-ozean?id='+$(this).val()">
                    <option>{if (not($id)) then attribute selected {} else ()}Bitte auswählen</option>
                    {$items ! <option value="{./@id/string()}">{if ($id=./@id) then attribute selected {} else ()}{./*:name/string()}</option>}
                  </select>
              </div>
              <div class="ibox-content">
                {plugin:lookup("schema/ibox/table")!.("sanofi/blauer-ozean","stammdaten/blauer-ozean")}
              </div>
          </div>
      </div>
  </div>
</div>
};


(: provide sorting for items :)
declare %plugin:provide("schema/process/table/items")
function _:schema-render-table-prepare-rows($Items as element()*, $Schema as element(schema),$Context as map(*)){for $item in $Items order by $item/name, $item/priority return $item};

declare %plugin:provide("schema/set/elements")
function _:schema-render-table-prepare-rows-only-name($Items as element()*, $Schema as element(schema),$Context as map(*)){
    let $columns := ("name","kk","kv","datum")
    let $schema := $Schema update delete node ./*:element
    let $elements-in-order := for $name in $columns return $Schema/element[@name=$name]
    let $schema := $schema update insert node $elements-in-order as last into .
    return $schema};

declare %plugin:provide("schema") function _:schema-()
as element(schema){
<schema xmlns="" name="blauer-ozean" domain="sanofi" provider="sanofi/blauer-ozean">
    <modal>
        <title>Der Blaue Ozean</title>
        <button>
            <add>hinzufügen</add>
            <cancel>abbrechen</cancel>
            <modify>ändern</modify>
            <delete>löschen</delete>
        </button>
    </modal>
    <element name="name" type="text">
        <label>Titel</label>
    </element>
    <element name="datum" type="text">
        <label>Datum</label>
    </element>

    <element name="lieferfähigkeit-ist" type="number">
        <label>Lieferfähigkeit IST</label>
    </element>

    <element name="lieferfähigkeit-soll" type="number">
        <label>Lieferfähigkeit SOLL</label>
    </element>

 <element name="vertragsqualität-ist" type="number">
   <label>Vertragsqualität IST</label>
 </element>
 <element name="vertragsqualität-soll" type="number">
   <label>Vertragsqualität SOLL</label>
 </element>
 <element name="ökonomie-ist" type="number">
   <label>Ökonomie IST</label>
 </element>
 <element name="ökonomie-soll" type="number">
   <label>Ökonomie SOLL</label>
 </element>
 <element name="informationsweitergabe-ist" type="number">
   <label>Informationsweitergabe IST</label>
 </element>
 <element name="informationsweitergabe-soll" type="number">
   <label>Informationsweitergabe SOLL</label>
 </element>
 <element name="gesprächsangebot-ist" type="number">
   <label>Gesprächsangebot IST</label>
 </element>
 <element name="gesprächsangebot-soll" type="number">
   <label>Gesprächsangebot SOLL</label>
 </element>
 <element name="one-face-to-the-customoer-ist" type="number">
   <label>One-Face-to-The-Customer IST</label>
 </element>
 <element name="one-face-to-the-customoer-soll" type="number">
   <label>One-Face-to-The-Customer SOLL</label>
 </element>

   <element name="kv" type="foreign-key" required="">
              <provider>sanofi/kv</provider>
              <key>@id</key>
              <display-name>name/string()</display-name>
              <label>KV</label>
              <class>col-md-6</class>
   </element>

   <element name="kk" type="foreign-key" required="">
              <provider>sanofi/kk</provider>
              <key>@id</key>
              <display-name>name/string()</display-name>
              <label>KK</label>
              <class>col-md-6</class>
   </element>

    <element name="notizen" type="text">
         <label>Notizen</label>
     </element>
 </schema>
};

declare %plugin:provide("schema/render/form/field/foreign-key","kk")
function _:sanofi-blauer-ozean-kk-input($Item as element(blauer-ozean), $Element as element(element), $Context as map(*))
as element()?
{
    if ($Context("kk"))
        then
            <input xmlns="http://www.w3.org/1999/xhtml" name="kk" value="{$Context("kk")}" type="hidden"/>
        else ()(:plugin:provider-lookup("influx/schema","schema/render/form/field/foreign-key")!.($Item,$Element,$Context):)
};
declare %plugin:provide("schema/render/form/field/label","kk")
function _:sanofi-blauer-ozean-kk-input-label($Item as element(blauer-ozean), $Element as element(element), $Context as map(*))
as element()?
{
    if ($Context("kk"))
        then ()
        else ()(:plugin:provider-lookup("influx/schema","schema/render/form/field/label")!.($Item,$Element,$Context):)
};

declare %plugin:provide("schema/render/form/field/foreign-key","kv")
function _:sanofi-blauer-ozean-kv-input($Item as element(blauer-ozean), $Element as element(element), $Context as map(*))
as element()?
{
    if ($Context("kv"))
        then
            <input xmlns="http://www.w3.org/1999/xhtml" name="kk" value="{$Context("kv")}" type="hidden"/>
        else ()(:plugin:provider-lookup("influx/schema","schema/render/form/field/foreign-key")!.($Item,$Element,$Context):)
};
declare %plugin:provide("schema/render/form/field/label","kv")
function _:sanofi-blauer-ozean-kv-input-label($Item as element(blauer-ozean), $Element as element(element), $Context as map(*))
as element()?
{
    if ($Context("kv"))
        then ()
        else ()(:plugin:provider-lookup("influx/schema","schema/render/form/field/label")!.($Item,$Element,$Context):)
};

declare %plugin:provide("schema/render/button/modal/edit/link")
function _:blauer-ozean-render-button-page-edit-link($Item as element(), $Schema as element(schema), $Context as map(*))
as xs:string
{
let $context := $Context => map:get("context")
let $kk := $Context("item")
return
    if ($kk)
        then "schema/form/modal/"||$Item/@id||"?provider="||$Schema/@provider||"&amp;context="||$context||"&amp;kk="||$kk/@id/string()
        else "schema/form/modal/"||$Item/@id||"?provider="||$Schema/@provider||"&amp;context="||$context
};

declare %plugin:provide("content/view")
function _:sanofi-blauer-ozean-content-view($Item as element(blauer-ozean), $Schema as element(schema), $Context as map(*))
as element(xhtml:div)
{
let $id := $Item/@id/string()
let $kk := $Context("item")/@id/string()
let $provider := "sanofi/blauer-ozean"
let $context := map{"context":"sanofi/blauer-ozean"}
let $schema := plugin:provider-lookup($provider,"schema")!.()
let $items := plugin:provider-lookup($provider,"datastore/dataobject/all")!.($schema,$context)[kk=$kk]
let $item := $Item
let $name := $item/name/string()
let $ist-names := $schema/element[ends-with(@name,"-ist")]/@name/string()
let $soll-names := $schema/element[ends-with(@name,"-soll")]/@name/string()
let $andere-names := $schema/element[ends-with(@name,"-andere")]/@name/string()
let $ist := string-join(for $x in $ist-names return $item/element()[name()=$x]/string(),",")
let $soll := string-join(for $x in $soll-names return $item/element()[name()=$x]/string(),",")
let $labels := '"'||string-join($schema/element[ends-with(@name,"-ist")]/label/substring-before(string()," IST"),'","')||'"'
let $edit-button := try {plugin:provider-lookup($provider,"schema/render/button/modal/edit")!.($Item,$schema,$Context)} catch * {}
let $add-button := ui:modal-button('schema/form/modal?provider='||$provider||"&amp;kk="||$kk,<a xmlns="http://www.w3.org/1999/xhtml" shape="rect" class="btn btn-sm btn-outline"><span class="fa fa-plus"/></a>)
return
<div xmlns="http://www.w3.org/1999/xhtml">
  <div class="row">
      <div class="col-lg-12 col-md-12">
          <div class="ibox float-e-margins">
              <div class="ibox-title">
                  <div class="col-md-9">{$edit-button} Werte bearbeiten</div>
                  <div class="col-md-1"><label class="form-label pull-right">{$add-button}</label></div>
                  <div class="col-md-2">
                    <select id="content-view-select" class="form-control" onchange="Influx.restxq('{$global:servlet-prefix}/sanofi/blauer-ozean/radar-chart/'+$(this).val())">
                    {$items ! <option value="{./@id/string()}">{if ($id=./@id) then attribute selected {} else ()}{./*:name/string()}</option>}
                    </select>
                  </div>
              </div>
              {_:ibox-radar-chart($Item,$Schema,$Context)}
          </div>
      </div>
    </div>
</div>
};

declare %plugin:provide("sanofi/blauer-ozean/radar-chart") function _:ibox-radar-chart($Item,$Schema,$Context){
let $id := $Item/@id/string()
let $kk := $Context("item")/@id/string()
let $provider := "sanofi/blauer-ozean"
let $context := map{"context":"sanofi/blauer-ozean"}
let $schema := plugin:provider-lookup($provider,"schema")!.()
let $items := plugin:provider-lookup($provider,"datastore/dataobject/all")!.($schema,$context)[kk=$kk]
let $item := $Item
let $name := $item/name/string()
let $ist-names := $schema/element[ends-with(@name,"-ist")]/@name/string()
let $soll-names := $schema/element[ends-with(@name,"-soll")]/@name/string()
let $andere-names := $schema/element[ends-with(@name,"-andere")]/@name/string()
let $ist := string-join(for $x in $ist-names return $item/element()[name()=$x]/string(),",")
let $soll := string-join(for $x in $soll-names return $item/element()[name()=$x]/string(),",")
let $labels := '"'||string-join($schema/element[ends-with(@name,"-ist")]/label/substring-before(string()," IST"),'","')||'"'
let $edit-button := try {plugin:provider-lookup($provider,"schema/render/button/modal/edit")!.($Item,$schema,$Context)} catch * {}
let $add-button := ui:modal-button('schema/form/modal?provider='||$provider||"&amp;kk="||$kk,<a xmlns="http://www.w3.org/1999/xhtml" shape="rect" class="btn btn-sm btn-outline"><span class="fa fa-plus"/></a>)
return
<div class="ibox-content" id="blauer-ozean-kk-view-chart" data-replace="#blauer-ozean-kk-view-chart">
   <canvas id="radarChart" width="730" height="720"></canvas>
       { if ($item) then <div>
      <script src="{$global:inspinia-path}/js/plugins/chartJs/Chart.min.js"></script>
      <script>//<![CDATA[
      var radarData = {
              labels: []]>{$labels}<![CDATA[],
              datasets: [
                  {
                      label: "IST",
                      backgroundColor: "rgba(220,220,220,0.2)",
                      borderColor: "rgba(120,155,120,1)",
                      data: []]>{$ist}<![CDATA[]
                  },
                  {
                      label: "SOLL",
                      backgroundColor: "rgba(220,220,220,0.2)",
                      borderColor: "rgba(155,120,120,1)",
                      data: []]>{$soll}<![CDATA[]
                  }
              ]
          };

          var radarOptions = {
              responsive: false,
                  maintainAspectRatio: true,
              scale: {
                         ticks: {
                             beginAtZero: true,
                             max: 5
                         }
              }
          };

          var ctx5 = document.getElementById("radarChart").getContext("2d");
          new Chart(ctx5, {type: 'radar', data: radarData, options:radarOptions});
          //]]></script>
          </div> else ()
          }
    <script>$("select").select2();</script>
    </div>
};