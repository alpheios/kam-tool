module namespace _ = "sanofi/views/kam-top-4-kv";

(: import repo modules :)
import module namespace global	= "influx/global";
import module namespace plugin	= "influx/plugin";
import module namespace db	    = "influx/db";
import module namespace ui =" influx/ui2";
import module namespace kv = "sanofi/kv" at "../resources/kv.xqm";

declare namespace xhtml="http://www.w3.org/1999/xhtml";


declare %plugin:provide('side-navigation')
  function _:nav-item-kam2()
  as element(xhtml:li) {
  <li xmlns="http://www.w3.org/1999/xhtml" data-parent="/" data-sortkey="AA2">
      <a href="{$global:servlet-prefix}/sanofi/kam-top-4-kv"><i class="fa fa-area-chart"></i> <span class="nav-label">KAM Top 4 - KV</span></a>
  </li>
};

declare %plugin:provide("ui/page/content","sanofi/kam-top-4-kv")
function _:sanofi-kam-top-4($map)
as element(xhtml:div)
{
let $context := map{"context":"sanofi/kam-top-4-kv"}
let $schema := plugin:provider-lookup("sanofi/kv","schema")!.()
let $kven := plugin:provider-lookup("sanofi/kv","datastore/dataobject/all")!.($schema,$context)
return
<div xmlns="http://www.w3.org/1999/xhtml" class="content-with-sidebar row">
        <script src="{$global:inspinia-path}/js/plugins/chartJs/Chart.min.js"></script>

  <div class="row">
      <div class="col-lg-12">
          <div class="ibox float-e-margins">
              <div class="ibox-title">
                  <h5>Krankenkassen TOP 4 Überblick</h5>
                  <select class="chosen pull-right btn">
                    {for $kv in $kven return <option>{$kv/*:name/string()}</option>}
                  </select>
              </div>
              <div class="ibox-content">
              <div class="row">
                <div class="col-lg-6">
                    <div class="ibox float-e-margins">
                        <div class="ibox-title">
                            <h5>Arztzahl 2017, Verteilung auf Bundesländer</h5>
                        </div>
                        <div class="ibox-content">
                            <div>
                                <iframe class="chartjs-hidden-iframe" style="width: 100%; display: block; border: 0px; height: 0px; margin: 0px; position: absolute; left: 0px; right: 0px; top: 0px; bottom: 0px;"></iframe>
                                <canvas id="doughnutChart" height="602" width="1294" style="display: block; width: 647px; height: 301px;"></canvas>
                            </div>
                             <script>//<![CDATA[
                                      var doughnutData = {
                                          labels: []]>{string-join($kv:land ! ('"'||.||'"'),",")} <![CDATA[],
                                          datasets: [{
                                              data: []]>{string-join($kv:land ! (random:integer(25)),",")} <![CDATA[],
                                              backgroundColor: []]>{string-join(for $i in 2 to count($kv:land) return ('"rgb('||$i*6||','||$i*9||','||$i*12||')"'),',')} <![CDATA[]
                                          }]
                                      } ;


                                      var doughnutOptions = {
                                          responsive: true
                                      };


                                      var ctx4 = document.getElementById("doughnutChart").getContext("2d");
                                      new Chart(ctx4, {type: 'doughnut', data: doughnutData, options:doughnutOptions});


                                      //]]></script>
                        </div>
                    </div>
                </div>
                <div class="col-lg-6">
                    <div class="ibox float-e-margins">
                        <div class="ibox-title">
                            <h5>Vorstand 2017</h5>
                        </div>
                        <div class="ibox-content">
                            <div>
                                <iframe class="chartjs-hidden-iframe" style="width: 100%; display: block; border: 0px; height: 0px; margin: 0px; position: absolute; left: 0px; right: 0px; top: 0px; bottom: 0px;"></iframe>
                                <canvas id="doughnutChart2" height="602" width="1294" style="display: block; width: 647px; height: 301px;"></canvas>
                            </div>
                             <script>//<![CDATA[
                                      var doughnutData = {
                                          labels: []]>{string-join($kven/*:name/string() ! ('"'||.||'"'),",")} <![CDATA[],
                                          datasets: [{
                                              data: []]>{string-join($kven ! (random:integer(25)),",")} <![CDATA[],
                                              backgroundColor: []]>{string-join(for $i in 6 to count($kv:land)*10 return ('"rgb('||$i*10||','||$i*12||','||$i*13||')"'),',')} <![CDATA[]
                                          }]
                                      } ;


                                      var doughnutOptions = {
                                          responsive: true
                                      };


                                      var ctx4 = document.getElementById("doughnutChart2").getContext("2d");
                                      new Chart(ctx4, {type: 'doughnut', data: doughnutData, options:doughnutOptions});


                                      //]]></script>
                        </div>
                    </div>
                </div>
              </div>
              <div class="row">
                <div class="col-lg-6">
                  <div class="ibox float-e-margins">
                      <div class="ibox-title">
                          <h5>Verbund mit anderen KVen</h5>
                      </div>
                      <div class="ibox-content">
                          <ul>
                            <li>KV-Baden Württemberg</li>
                          </ul>
                      </div>
                  </div>
              </div>
                <div class="col-lg-6">
                  <div class="ibox float-e-margins">
                      <div class="ibox-title">
                          <h5>Besonderheiten</h5>
                      </div>
                      <div class="ibox-content">
                          <div>Keine</div>
                      </div>
                  </div>
              </div>
              </div>
            </div>
          </div>
      </div>
  </div>

</div>

};