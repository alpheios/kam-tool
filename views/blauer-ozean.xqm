module namespace _="sanofi/views/blauer-ozean";

import module namespace i18n = 'influx/i18n';
import module namespace global ='influx/global';
import module namespace db = "influx/db";
import module namespace ui='influx/ui2';
import module namespace plugin='influx/plugin';
import module namespace rest = "http://exquery.org/ns/restxq";
import module namespace request = "http://exquery.org/ns/request";
import module namespace kk = "sanofi/kk" at "../resources/kk.xqm";

declare namespace xhtml = "http://www.w3.org/1999/xhtml";
declare namespace mod="http://influx.adesso.de/module";


declare %plugin:provide('side-navigation')
  function _:nav-item-kam()
  as element(xhtml:li) {
  <li xmlns="http://www.w3.org/1999/xhtml" data-parent="/" data-sortkey="AA2">
      <a href="{$global:servlet-prefix}/sanofi/blauer-ozean"><i class="fa fa-area-chart"></i> <span class="nav-label">Blauer Ozean</span></a>
  </li>
};

declare %plugin:provide("ui/page/content","sanofi/blauer-ozean")
function _:sanofi-blauer-ozean($map as map(*))
as element(xhtml:div)
{
let $id := $map => map:get("id")
let $id := if (not($id)) then "1234" else $id
let $context := map{"context":"sanofi/blauer-ozean"}
let $schema := plugin:provider-lookup("sanofi/blauer-ozean","schema")!.()
let $items := plugin:provider-lookup("sanofi/blauer-ozean","datastore/dataobject/all")!.($schema,$context)
let $item := plugin:provider-lookup("sanofi/blauer-ozean","datastore/dataobject")!.($id,$schema,$context)
let $ist-names := $schema/element[ends-with(@name,"-ist")]/@name/string()
let $soll-names := $schema/element[ends-with(@name,"-soll")]/@name/string()
let $andere-names := $schema/element[ends-with(@name,"-andere")]/@name/string()
let $ist := string-join(for $x in $ist-names return $item/element()[name()=$x]/string(),",")
let $soll := string-join(for $x in $soll-names return $item/element()[name()=$x]/string(),",")
let $labels := '"'||string-join($schema/element[ends-with(@name,"-ist")]/label/substring-before(string()," IST"),'","')||'"'
let $edit-button := try {plugin:provider-lookup("sanofi/blauer-ozean","schema/render/button/modal/edit")!.($item,$schema,$map)} catch * {}
return
<div xmlns="http://www.w3.org/1999/xhtml" class="content-with-sidebar row">
  <div class="row">
      <div class="col-lg-12 col-md-12">
          <div class="ibox float-e-margins">
              <div class="ibox-title">
                  <h5>{$edit-button} Der Blaue Ozean (SWAT Alternative) als Radar Chart</h5>
                  <select class="chosen pull-right" onchange="window.location='/influx/sanofi/blauer-ozean?id='+$(this).val()">
                    <option>{if (not($id)) then attribute selected {} else ()}Bitte auswählen</option>
                    {$items ! <option value="{./@id/string()}">{if ($id=./@id) then attribute selected {} else ()}{./*:name/string()}</option>}
                  </select>
              </div>
              <div class="ibox-content">
                <canvas id="radarChart" width="720" height="720"></canvas>
              </div>
          </div>
      </div>
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
          </div> else ()}
    </div>
</div>
};

