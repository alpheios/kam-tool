module namespace _ = "sanofi/management-summary";

(: import repo modules :)
import module namespace plugin	= "influx/plugin";
import module namespace global  = "influx/global";
import module namespace date-util ="influx/utils/date-utils";
import module namespace db 		 = "influx/db";
import module namespace common="sanofi/common" at "common.xqm";

declare namespace xhtml="http://www.w3.org/1999/xhtml";
declare variable $_:ns := namespace-uri(<_:ns/>);

declare %plugin:provide('ui/page/title') function _:heading($m){_:schema-default()//*:title/string()};
declare %plugin:provide("ui/page/content") function _:ui-page-content($m){common:ui-page-content($m)};
declare %plugin:provide('ui/page/heading/breadcrumb') function _:breadcrumb($m){common:breadcrumb($m)};


declare
    %plugin:provide("schema/render/new","kk")
    %plugin:provide("schema/render/update","kk")
    %plugin:provide("schema/render/delete","kk")
    %plugin:provide("schema/render/new","kv")
    %plugin:provide("schema/render/update","kv")
    %plugin:provide("schema/render/delete","kv")
function _:management-summary-render-new(
  $Item as element(management-summary), 
  $Schema as element(schema), 
  $Context as map(*)
) as element(xhtml:div) {
    let $provider := $Context("provider")
    let $context := $Context("context")
    let $schema := plugin:provider-lookup($provider,"schema",$context)!.()
    return
    plugin:provider-lookup($provider,"content/view/context",$context)!.($Item,$schema,$Context)
};


(: provide sorting for items :)
declare %plugin:provide("schema/process/table/items")
function _:schema-render-table-prepare-rows(
  $Items as element()*, 
  $Schema as element(schema),
  $Context as map(*)
) {
  for $item in $Items 
  order by $item/datum 
  return $item
};

(: provide for columns :)
declare %plugin:provide("schema/set/elements")
function _:schema-render-table-prepare-rows-only-name($Items as element()*, $Schema as element(schema),$Context as map(*)){
    let $columns := ("datum", "ein-blick", "top-ziele", "gute", "kritisch", "")
    let $schema := $Schema update delete node ./*:element
    let $elements-in-order := for $name in $columns return $Schema/element[@name=$name]
    let $schema := $schema update insert node $elements-in-order as last into .
    return $schema
};

declare %plugin:provide("schema") function _:schema-default()
as element(schema){
<schema xmlns="" name="management-summary" domain="sanofi" provider="sanofi/management-summary">
    <modal>
        <title>Management Zusammenfassung</title>
    </modal>
    <element name="name" type="text">
        <label>Titel</label>
    </element>

    <element name="datum" type="date" default="{date-util:current-date-to-html5-input-date()}">
        <label>Datum</label>
    </element>

    <element name="ein-blick" type="textarea">
        <label>Unser Geschäft auf einen Blick</label>
    </element>

    <element name="top-ziele" type="textarea">
        <label>TOP Ziel beim Kunden</label>
    </element>

    <element name="gute" type="textarea">
        <label>Was läuft gut</label>
    </element>
    <element name="kritisch" type="textarea">
        <label>Kritische Punkte</label>
    </element>
    <element name="position" type="textarea">
        <label>Wie positioniert sich der Kunde?</label>
    </element>
    <element name="notizen" type="textarea">
         <label>Link</label>
     </element>
 </schema>
};

declare %plugin:provide("schema", "kk-top-4")
function _:schema-kk-top-4() as element(schema) {
  let $schema := _:schema-default()
  return $schema update insert node (
    <element name="kk" type="foreign-key" render="context-item" required="">
      <provider>sanofi/kk</provider>
      <key>@id</key>
      <display-name>name/string()</display-name>
    </element>,
    <element name="kv" type="hidden" />
    ) into .
};

declare %plugin:provide("schema", "kv-top-4")
function _:schema-kv-top-4() as element(schema) {
  let $schema := _:schema-default()
  return $schema update insert node (
    <element name="kv" type="foreign-key" render="context-item" required="">
      <provider>sanofi/kv</provider>
      <key>@id</key>
      <display-name>name/string()</display-name>
    </element>,
    <element name="kk" type="hidden" />
    ) into .
};
declare %plugin:provide("schema/render/page/form/buttons","kk")
function _:no-form-buttons($Item as element(management-summary)?, $Schema as element(schema), $Context as map(*)){
  };
  
declare %plugin:provide("content/view/context","kk")
function _:content-view($Item as element(management-summary)?, $Schema as element(schema), $Context as map(*)){
let $id := $Item/@id/string()
let $name := $Item/name/string()
let $kk := $Context("context-item")
let $kk-id := $kk/@id/string()
let $kk-name := $kk/name/string()
let $context := $Context("context")
let $context-provider := $Context("context-provider")
let $provider := "sanofi/management-summary"
let $schema := plugin:provider-lookup($provider,"schema",$context)!.()
let $items := plugin:provider-lookup($provider,"datastore/dataobject/all",$context)!.($schema,$Context)[kk=$kk-id]
let $kk-history-provider := "sanofi/kk-top-4"
let $kk-history-schema := plugin:provider-lookup($kk-history-provider,"schema")!.()
let $kk-history-items := plugin:provider-lookup($kk-history-provider,"datastore/dataobject/field",$context)!.("kk", $kk-id, $kk-history-schema, $Context)
let $kk-history-years :=
    for $item in $kk-history-items
    let $datum := $item/datum/string()
    order by $datum
    return fn:format-date(xs:date($datum), "[D]/[Y]" )
let $edit-button := plugin:provider-lookup($provider,"schema/render/button/modal/edit")!.($Item,$schema,$Context)
let $add-button := plugin:provider-lookup($provider,"schema/render/button/modal/new")!.($schema,$Context)
let $marktanteil-names := (for $i in $kk-history-items order by $i/datum return $i/datum/string()!('"'||fn:format-date(xs:date(.), "[D]/[Y]" )||'"'))
                          =>string-join(',')
let $marktanteil-values := string-join((for $i in $kk-history-items order by $i/datum return $i/marktanteil/string()!('"'||.||'"')),',')
let $arzneimittelausgaben-values := string-join((for $i in $kk-history-items order by $i/datum return (
  try {
    xs:integer($i/arzneimittelausgaben) div 1000
  } catch * {0}) !('"'||.||'"')),',')
let $arzneimittelausgaben-anteil-values := string-join((for $i in $kk-history-items order by $i/datum return $i/arzneimittelausgaben_marktanteil/string()!('"'||.||'"')),',')
let $mitglieder-values := string-join((for $i in $kk-history-items order by $i/datum return (
  try {
    xs:decimal($i/anzahl) div 1000
  } catch * {0})!('"'||.||'"')),',')
let $latest-marktanteil := (for $i in $kk-history-items order by $i/datum descending return $i/marktanteil/string())[1]
let $rest-marktanteil := try {100 - xs:decimal($latest-marktanteil)} catch * {0}
return
<div xmlns="http://www.w3.org/1999/xhtml" id="kk-top-4" data-replace="#kk-top-4">
    <script src="{$global:inspinia-path}/js/plugins/chartJs/Chart.min.js"></script>
    <script>//<![CDATA[
var lineOptions = {
    responsive: true,
    scales: {
        yAxes: [{
            ticks: {
                callback: function (value) {return value.toLocaleString()}
            }
        }]
    }
};]]></script>
          <div class="row">
              <div class="col-lg-12 col-md-12">
                  <div class="float-e-margins">
                      {
                        let $kk-top-4 := plugin:provider-lookup("sanofi/kk", "schema", "kk-top-4")!.()
                        let $Context := map:put($Context, "context", "kk-top-4")
                        return
                          plugin:provider-lookup($kk-history-provider,"schema/render/form",$context)!.($kk,$kk-top-4,$Context)
                      }
                  </div>
              </div>
          </div>                
          <div class="row">
            <div class="col-lg-6">
              <div class="ibox float-e-margins">
                <div class="ibox-title">
                  <h5>Entwicklung der Versichertenanzahl im Zeitraum: {$kk-history-years[1]} - {$kk-history-years[last()]} Versicherte in tausend</h5>
                </div>
                <div class="ibox-content">
                  <div>
                    <iframe class="chartjs-hidden-iframe" style="width: 100%; display: block; border: 0px; height: 0px; margin: 0px; position: absolute; left: 0px; right: 0px; top: 0px; bottom: 0px;">  
                    </iframe>
                    <canvas id="lineChart2" height="602" width="1294" style="display: block; width: 647px; height: 301px;">
                    </canvas>
                  </div>
                  <script>//<![CDATA[
                    var lineData = {
                            labels: []]>{$marktanteil-names}<![CDATA[],
                            datasets: [

                                {
                                    label: "Entwicklung der Versichertenzahl in tausend Mitglieder",
                                    backgroundColor: 'rgba(26,179,148,0.5)',
                                    borderColor: "rgba(26,179,148,0.7)",
                                    pointBackgroundColor: "rgba(26,179,148,1)",
                                    pointBorderColor: "#fff",
                                    data: []]>{$mitglieder-values}<![CDATA[]
                                }
                            ]
                        };
                        var ctx = document.getElementById("lineChart2").getContext("2d");
                        new Chart(ctx, {type: 'line', data: lineData, options:lineOptions});
                    //]]></script>
                </div>
              </div>
            </div>
            <div class="col-lg-6">
              <div class="ibox float-e-margins">
                <div class="ibox-title">
                  <h5>Entwicklung des Marktanteils im Zeitraum: {$kk-history-years[1]} - {$kk-history-years[last()]}</h5>
                </div>
                <div class="ibox-content">
                  <div>
                    <iframe class="chartjs-hidden-iframe" style="width: 100%; display: block; border: 0px; height: 0px; margin: 0px; position: absolute; left: 0px; right: 0px; top: 0px; bottom: 0px;"></iframe>
                    <canvas id="lineChart" height="602" width="1294" style="display: block; width: 647px; height: 301px;"></canvas>
                  </div>
                  <script>//<![CDATA[
                    var lineData = {
                            labels: []]>{$marktanteil-names}<![CDATA[],
                            datasets: [

                                {
                                    label: "Entwicklung des Marktanteils",
                                    backgroundColor: 'rgba(26,179,148,0.5)',
                                    borderColor: "rgba(26,179,148,0.7)",
                                    pointBackgroundColor: "rgba(26,179,148,1)",
                                    pointBorderColor: "#fff",
                                    data: []]>{$marktanteil-values}<![CDATA[]
                                }
                            ]
                        };
                        var ctx = document.getElementById("lineChart").getContext("2d");
                        new Chart(ctx, {type: 'line', data: lineData, options:lineOptions});
                    //]]></script>
              </div>
            </div>
          </div></div>
          <div class="row">
            <div class="col-lg-6">
              <div class="ibox float-e-margins">
                <div class="ibox-title">
                  <h5>Entwicklung der Arzneimittelausgaben im Zeitraum: {$kk-history-years[1]} - {$kk-history-years[last()]} in tausend €</h5>
                </div>
                <div class="ibox-content">
                  <div>
                    <iframe class="chartjs-hidden-iframe" style="width: 100%; display: block; border: 0px; height: 0px; margin: 0px; position: absolute; left: 0px; right: 0px; top: 0px; bottom: 0px;"></iframe>
                    <canvas id="lineChart3" height="602" width="1294" style="display: block; width: 647px; height: 301px;"></canvas>
                  </div>
                  <script>//<![CDATA[
                    var lineData = {
                            labels: []]>{$marktanteil-names}<![CDATA[],
                            datasets: [

                                {
                                    label: "Entwicklung der Arzneimittelausgaben in tausend €",
                                    backgroundColor: 'rgba(26,179,148,0.5)',
                                    borderColor: "rgba(26,179,148,0.7)",
                                    pointBackgroundColor: "rgba(26,179,148,1)",
                                    pointBorderColor: "#fff",
                                    data: []]>{$arzneimittelausgaben-values}<![CDATA[]
                                }
                            ]
                        };
                        var ctx = document.getElementById("lineChart3").getContext("2d");
                        new Chart(ctx, {type: 'line', data: lineData, options:lineOptions});
                    //]]></script>
                </div>
              </div>
            </div>
            <div class="col-lg-6">
              <div class="ibox float-e-margins">
                <div class="ibox-title">
                  <h5>Entwicklung des Marktanteils der Arzneimittelausgaben im Zeitraum: {$kk-history-years[1]} - {$kk-history-years[last()]}</h5>
                </div>
                <div class="ibox-content">
                  <div>
                    <iframe class="chartjs-hidden-iframe" style="width: 100%; display: block; border: 0px; height: 0px; margin: 0px; position: absolute; left: 0px; right: 0px; top: 0px; bottom: 0px;"></iframe>
                    <canvas id="lineChart4" height="602" width="1294" style="display: block; width: 647px; height: 301px;"></canvas>
                  </div>
                  <script>//<![CDATA[
                    var lineData = {
                            labels: []]>{$marktanteil-names}<![CDATA[],
                            datasets: [

                                {
                                    label: "Entwicklung des Marktanteils der Arzneimittelausgaben",
                                    backgroundColor: 'rgba(26,179,148,0.5)',
                                    borderColor: "rgba(26,179,148,0.7)",
                                    pointBackgroundColor: "rgba(26,179,148,1)",
                                    pointBorderColor: "#fff",
                                    data: []]>{$arzneimittelausgaben-anteil-values}<![CDATA[]
                                }
                            ]
                        };
                        var ctx = document.getElementById("lineChart4").getContext("2d");
                        new Chart(ctx, {type: 'line', data: lineData, options:lineOptions});

                    //]]></script>
                </div>
              </div>
            </div>
          </div>
          <div>
              {
                let $kk-history := plugin:provider-lookup("sanofi/kk", "schema", "kk-history")!.()
                let $Context := map:put($Context, "context", "kk-history")
                return
                  plugin:provider-lookup($kk-history-provider,"schema/render/form",$context)!.($kk,$kk-history,$Context)
              }
          </div></div>
};

declare %plugin:provide("content/view/context","kv")
function _:content-view-for-kv(
  $Item as element(management-summary)?, 
  $Schema as element(schema), 
  $Context as map(*)
) {
  let $context := "kv"
  let $kv := $Context("context-item")
  let $kv-top4-provider := "sanofi/kv-top-4"
  let $kv-arztzahlen-provider := "sanofi/kv-arztzahlen"
  return
    <div xmlns="http://www.w3.org/1999/xhtml" id="kv-top-4" data-replace="#kv-top-4">
      <script src="{$global:inspinia-path}/js/plugins/chartJs/Chart.min.js"></script>
      <div class="row">
        <div class="col-lg-12 col-md-12">
          {
            let $kv-top-4 := plugin:provider-lookup("sanofi/kv", "schema", "kv-top-4")!.()
            let $Context := map:put($Context, "context", "kv-top-4")
            return
              plugin:provider-lookup($kv-top4-provider,"schema/render/form",$context)!.($kv,$kv-top-4,$Context)
          }
        </div>
      </div>
      <div class="row">
        <div class="col-lg-12 col-md-12">
          {
            let $ap-schema := plugin:provider-lookup("sanofi/ansprechpartner", "schema")!.()
            let $kv-ap := db:eval("collection('datastore-sanofi-ansprechpartner')/ansprechpartner[kv=$id][position='Vorstand']",map{"id":$kv/@id/string()})
            (:trace(plugin:lookup("datastore/dataobject/field")!.("kv", $kv/@id/string(), $ap-schema, $Context)):)
            let $Context := map:put($Context, "context", "kv-top-4")
            let $vorstaende := $kv-ap[*:position = "Vorstand"]
            return if (count($vorstaende)>0) then
              <div>
                <label class="control-label">Vorstände</label>
                <ul>
                  {
                    for $vorstand in $vorstaende
                    return <li><a href="{$global:servlet-prefix}/schema/form/page/{$vorstand/@id/string()}?provider=sanofi/ansprechpartner&amp;context=stammdaten/ansprechpartner&amp;context-item-id={$kv/@id/string()}&amp;context-provider=sanofi/kv">{$vorstand/*:vorname/string()|| " " || $vorstand/*:name/string()}</a></li>
                  }
                </ul>
              </div>
          }
        </div>
      </div>
      <div class="row">
        <div class="col-lg-12 col-md-12">
          {
            let $kv-arztzahlen := plugin:provider-lookup("sanofi/kv", "schema", "kv-arztzahlen")!.()
            let $Context := map:put($Context, "context", "kv-arztzahlen")
            return
              plugin:provider-lookup($kv-arztzahlen-provider,"schema/render/form",$context)!.($kv,$kv-arztzahlen,$Context)
          }
        </div>
      </div>               
      <div>
      {
        let $kv-history := plugin:provider-lookup("sanofi/kv", "schema", "kv-history")!.()
        let $Context := map:put($Context, "context", "kv-history")
        return
          plugin:provider-lookup($kv-top4-provider,"schema/render/form",$context)!.($kv,$kv-history,$Context)
      }
      </div>
    </div>
};


