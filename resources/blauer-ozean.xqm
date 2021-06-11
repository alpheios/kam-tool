module namespace _ = "sanofi/blauer-ozean";

(: import repo modules :)
import module namespace global	= "influx/global";
import module namespace plugin	= "influx/plugin";
import module namespace db	    = "influx/db";
import module namespace ui =" influx/ui";

declare namespace xhtml="http://www.w3.org/1999/xhtml";

declare variable $_:aspekte-kk := plugin:lookup("plato/schema/enums/get")!.("Blauer Ozean Aspekte - KK");
declare variable $_:aspekte-kv := plugin:lookup("plato/schema/enums/get")!.("Blauer Ozean Aspekte - KV");


declare %plugin:provide("schema/render/modal/debug/itemX") function _:debug-blauer-ozean ($Item as element(blauer-ozean),$Schema as element(schema),$Context){
<pre>{serialize($Item)}
<ul>{for $key in map:keys($Context)
return <li>{$key} : {$Context($key)}</li>
}</ul>
</pre>
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


declare %plugin:provide("schema","kk") function _:schema-kk()
as element(schema){
<schema xmlns="" name="blauer-ozean" domain="sanofi" provider="sanofi/blauer-ozean">
    <modal>
        <title>Der Blaue Ozean</title>
    </modal>
    <element name="name" type="text">
        <label>Titel</label>
    </element>
    <element name="datum" type="date">
        <label>Datum</label>
    </element>
    {
      for $aspekt in $_:aspekte-kk
      let $aspekt-name := translate(lower-case($aspekt), " ", "-")
      return (
        <element name="{$aspekt-name}-ist" type="number" min="1" max="5" default="3">
          <label>{$aspekt} IST</label>
        </element>,
        <element name="{$aspekt-name}-soll" type="number" min="1" max="5" default="3">
          <label>{$aspekt} SOLL</label>
        </element>
      )
    }
   <element name="kk" type="foreign-key" required="">
              <provider>sanofi/kk</provider>
              <key>@id</key>
              <display-name>name/string()</display-name>
              <label>KK</label>
              <class>col-md-6</class>
   </element>
    <element name="notizen" type="textarea">
         <label>Link</label>
     </element>
 </schema>
};

declare %plugin:provide("schema","kv") function _:schema-kv()
as element(schema){
<schema xmlns="" name="blauer-ozean" domain="sanofi" provider="sanofi/blauer-ozean">
    <modal>
        <title>Der Blaue Ozean</title>
    </modal>
    <element name="name" type="text" required="">
        <label>Titel</label>
    </element>
    <element name="datum" type="text">
        <label>Datum</label>
    </element>
    {
      for $aspekt in $_:aspekte-kv
      let $aspekt-name := translate(lower-case($aspekt), " ", "-")
      return (
        <element name="{$aspekt-name}-ist" type="number" min="1" max="5" default="3">
          <label>{$aspekt} IST</label>
        </element>,
        <element name="{$aspekt-name}-soll" type="number" min="1" max="5" default="3">
          <label>{$aspekt} SOLL</label>
        </element>
      )
    }
   <element name="kv" type="foreign-key" required="" render="context-item">
              <provider>sanofi/kv</provider>
              <key>@id</key>
              <display-name>name/string()</display-name>
   </element>
    <element name="notizen" type="textarea">
         <label>Link</label>
     </element>
 </schema>
};
(:

 Item im Kontext einer "KK" anzeigen/bearbeiten   #####################################

:)
declare %plugin:provide("schema/render/form/field/foreign-key","kk") (: Achtung: "kk" ist hier nicht der Kontext, sondern der Feldname! :)
function _:sanofi-blauer-ozean-kk-input($Item as element(blauer-ozean), $Element as element(element), $Context as map(*))
as element()?
{
    let $kk-id := $Context("context-item")/@id/string()
    return <input xmlns="http://www.w3.org/1999/xhtml" name="kk" value="{$kk-id}" type="hidden"/>
};

declare %plugin:provide("schema/render/form/field/label","kk") (: Achtung: "kk" ist hier nicht der Kontext, sondern der Feldname! :)
function _:sanofi-blauer-ozean-kk-input-label($Item as element(blauer-ozean), $Element as element(element), $Context as map(*))
as element()?
{
    (: Label für Feld "kk" löschen :)
};

declare
    %plugin:provide("schema/render/new","kk")
    %plugin:provide("schema/render/update","kk")
    %plugin:provide("schema/render/delete","kk")
    %plugin:provide("schema/render/new","kv")
    %plugin:provide("schema/render/update","kv")
    %plugin:provide("schema/render/delete","kv")
function _:kk-blauer-ozean-render-new($Item as element(blauer-ozean), $Schema as element(schema), $Context as map(*))
as element(xhtml:div)
{
    plugin:provider-lookup("sanofi/blauer-ozean","content/view/context",$Context("context"))!.($Item,$Schema,$Context)
};


declare %plugin:provide("content/view/context","kk")

function _:sanofi-blauer-ozean-content-view($Item as element(blauer-ozean)?, $Schema as element(schema), $Context as map(*))
as element(xhtml:div)
{
let $id := $Item/@id/string()
let $kk-id := $Context("context-item")/@id/string()
let $provider := "sanofi/blauer-ozean"
let $context := $Context("context")
let $schema := plugin:provider-lookup($provider,"schema",$context)!.()
let $items := plugin:provider-lookup($provider,"datastore/dataobject/all",$context)!.($schema,$Context)[kk=$kk-id]
let $item := $Item
let $edit-button := plugin:provider-lookup($provider,"schema/render/button/modal/edit")!.($Item,$schema,$Context)
let $add-button := plugin:provider-lookup($provider,"schema/render/button/modal/new")!.($schema,$Context)
let $ist-names := $schema/element[ends-with(@name,"-ist")]/@name/string()
let $soll-names := $schema/element[ends-with(@name,"-soll")]/@name/string()
let $andere-names := $schema/element[ends-with(@name,"-andere")]/@name/string()
let $ist := string-join(for $x in $ist-names return $item/element()[name()=$x]/string(),",")
let $soll := string-join(for $x in $soll-names return $item/element()[name()=$x]/string(),",")
let $labels := '"'||string-join($schema/element[ends-with(@name,"-ist")]/label/substring-before(string()," IST"),'","')||'"'
return
<div xmlns="http://www.w3.org/1999/xhtml" id="kk-blauer-ozean" data-replace="#kk-blauer-ozean">
  <div class="row">
      <div class="col-lg-12 col-md-12">
          <div class="ibox float-e-margins">
              <div class="ibox-title">
                  <div class="col-xs-9">{$edit-button} {plugin:provider-lookup($provider,"schema/content/view/selector",$context)!.($items,$Item,$Schema,$Context) update delete node .//@class}</div>
                  <div class="col-md-3"><label class="form-label pull-right">Blauen Ozean hinzufügen {$add-button}</label></div>
              </div>
              <div class="ibox-content" id="blauer-ozean-kk-view-chart" data-replace="#blauer-ozean-kk-view-chart">
                 <canvas id="radarChart" width="640" height="720"></canvas>
                     { if ($item) then <div>
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
                                    borderColor: "rgba(0,0,250,1)",
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
                  </div>
          </div>
      </div>
    </div>
</div>
};

declare %plugin:provide("content/view/context","kv")

function _:sanofi-blauer-ozean-content--kv-view($Item as element(blauer-ozean)?, $Schema as element(schema), $Context as map(*))
as element(xhtml:div)
{
let $id := $Item/@id/string()
let $kk-id := $Context("context-item")/@id/string()
let $provider := "sanofi/blauer-ozean"
let $context := $Context("context")
let $schema := plugin:provider-lookup($provider,"schema",$context)!.()
let $items := plugin:provider-lookup($provider,"datastore/dataobject/all",$context)!.($schema,$Context)[kv=$kk-id]
let $item := $Item
let $edit-button := plugin:provider-lookup($provider,"schema/render/button/modal/edit")!.($Item,$schema,$Context)
let $add-button := plugin:provider-lookup($provider,"schema/render/button/modal/new")!.($schema,$Context)
let $ist-names := $schema/element[ends-with(@name,"-ist")]/@name/string()
let $soll-names := $schema/element[ends-with(@name,"-soll")]/@name/string()
let $andere-names := $schema/element[ends-with(@name,"-andere")]/@name/string()
let $ist := string-join(for $x in $ist-names return $item/element()[name()=$x]/string(),",")
let $soll := string-join(for $x in $soll-names return $item/element()[name()=$x]/string(),",")
let $labels := '"'||string-join($schema/element[ends-with(@name,"-ist")]/label/substring-before(string()," IST"),'","')||'"'
return
<div xmlns="http://www.w3.org/1999/xhtml" id="kv-blauer-ozean" data-replace="#kv-blauer-ozean">
  <div class="row">
      <div class="col-lg-12 col-md-12">
          <div class="ibox float-e-margins">
              <div class="ibox-title">
                  <div class="col-xs-9">{$edit-button} {plugin:provider-lookup($provider,"schema/content/view/selector",$context)!.($items,$Item,$Schema,$Context) update delete node .//@class}</div>
                  <div class="col-md-3"><label class="form-label pull-right">Blauen Ozean hinzufügen {$add-button}</label></div>
              </div>
              <div class="ibox-content" id="blauer-ozean-kv-view-chart" data-replace="#blauer-ozean-kv-view-chart">
                 <canvas id="radarChart" width="640" height="720"></canvas>
                     { if ($item) then <div>
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
                                    borderColor: "rgba(0,0,250,1)",
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
                  </div>
          </div>
      </div>
    </div>
</div>
};