module namespace _ = "sanofi/views/kam-top-4-kk";

(: import repo modules :)
import module namespace global	= "influx/global";
import module namespace plugin	= "influx/plugin";
import module namespace db	    = "influx/db";
import module namespace ui =" influx/ui2";
import module namespace kk = "sanofi/kk" at "../resources/kk.xqm";

declare namespace xhtml="http://www.w3.org/1999/xhtml";


declare %plugin:provide('side-navigation')
  function _:nav-item-kam2()
  as element(xhtml:li) {
  <li xmlns="http://www.w3.org/1999/xhtml" data-parent="/" data-sortkey="AA2">
      <a href="{$global:servlet-prefix}/sanofi/kam-top-4-kk"><i class="fa fa-area-chart"></i> <span class="nav-label">KAM Top 4 - KK</span></a>
  </li>
};

declare %plugin:provide("ui/page/content","sanofi/kam-top-4-kk")
function _:sanofi-kam-top-4($map)
as element(xhtml:div)
{
let $context := map{"context":"sanofi/kam-top-4-kk"}
let $schema := plugin:provider-lookup("sanofi/kk","schema")!.()
let $kven := plugin:provider-lookup("sanofi/kk","datastore/dataobject/all")!.($schema,$context)
return
<div xmlns="http://www.w3.org/1999/xhtml" class="content-with-sidebar row">
        <script src="{$global:inspinia-path}/js/plugins/chartJs/Chart.min.js"></script>

  <div class="row">
      <div class="col-lg-12">
          <div class="ibox float-e-margins">
              <div class="ibox-title">
                  <h5>Krankenkassen TOP 4 Überblick</h5>
                  <select class="chosen pull-right btn">
                    {$kk:kk/*:a ! <option>{.}</option>}
                  </select>
              </div>
              <div class="ibox-content">
              <div class="row">
                <div class="col-lg-6">
                    <div class="ibox float-e-margins">
                        <div class="ibox-title">
                            <h5>Versichertenzahl 2017, Verteilung auf Bundesländer</h5>
                        </div>
                        <div class="ibox-content">
                            <div>
                                <iframe class="chartjs-hidden-iframe" style="width: 100%; display: block; border: 0px; height: 0px; margin: 0px; position: absolute; left: 0px; right: 0px; top: 0px; bottom: 0px;"></iframe>
                                <canvas id="doughnutChart" height="602" width="1294" style="display: block; width: 647px; height: 301px;"></canvas>
                            </div>
                             <script>//<![CDATA[
                                      var doughnutData = {
                                          labels: []]>{string-join($kk:land ! ('"'||.||'"'),",")} <![CDATA[],
                                          datasets: [{
                                              data: []]>{string-join($kk:land ! (random:integer(25)),",")} <![CDATA[],
                                              backgroundColor: []]>{string-join(for $i in 2 to count($kk:land) return ('"rgb('||$i*6||','||$i*9||','||$i*12||')"'),',')} <![CDATA[]
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
                            <h5>Arzneimittelausgaben 2017, Verteilung auf Bundesländer</h5>
                        </div>
                        <div class="ibox-content">
                            <div>
                                <iframe class="chartjs-hidden-iframe" style="width: 100%; display: block; border: 0px; height: 0px; margin: 0px; position: absolute; left: 0px; right: 0px; top: 0px; bottom: 0px;"></iframe>
                                <canvas id="doughnutChart2" height="602" width="1294" style="display: block; width: 647px; height: 301px;"></canvas>
                            </div>
                             <script>//<![CDATA[
                                      var doughnutData = {
                                          labels: []]>{string-join($kk:land ! ('"'||.||'"'),",")} <![CDATA[],
                                          datasets: [{
                                              data: []]>{string-join($kk:land ! (random:integer(25)),",")} <![CDATA[],
                                              backgroundColor: []]>{string-join(for $i in 2 to count($kk:land) return ('"rgb('||$i*6||','||$i*9||','||$i*12||')"'),',')} <![CDATA[]
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
                          <h5>Versicherten-Entwicklung 2007-2017</h5>
                      </div>
                      <div class="ibox-content">
                          <div><iframe class="chartjs-hidden-iframe" style="width: 100%; display: block; border: 0px; height: 0px; margin: 0px; position: absolute; left: 0px; right: 0px; top: 0px; bottom: 0px;"></iframe>
                                                          <canvas id="lineChart" height="602" width="1294" style="display: block; width: 647px; height: 301px;"></canvas>
                                                      </div>
                           <script>//<![CDATA[
                                    var lineData = {
                                            labels: ["2007", "2008", "2009", "2010", "2011", "2012", "2013","2014","2015","2016"],
                                            datasets: [

                                                {
                                                    label: "2007-2016",
                                                    backgroundColor: 'rgba(26,179,148,0.5)',
                                                    borderColor: "rgba(26,179,148,0.7)",
                                                    pointBackgroundColor: "rgba(26,179,148,1)",
                                                    pointBorderColor: "#fff",
                                                    data: [280000, 290000, 320000, 280000, 270000, 300000, 330000,360000,350000]
                                                }
                                            ]
                                        };

                                        var lineOptions = {
                                            responsive: true
                                        };


                                        var ctx = document.getElementById("lineChart").getContext("2d");
                                        new Chart(ctx, {type: 'line', data: lineData, options:lineOptions});


                                    //]]></script>
                      </div>
                  </div>
              </div>
                <div class="col-lg-6">
                  <div class="ibox float-e-margins">
                      <div class="ibox-title">
                          <h5>Marktanteil Entwicklung 2007-2017</h5>
                      </div>
                      <div class="ibox-content">
                          <div><iframe class="chartjs-hidden-iframe" style="width: 100%; display: block; border: 0px; height: 0px; margin: 0px; position: absolute; left: 0px; right: 0px; top: 0px; bottom: 0px;"></iframe>
                                                          <canvas id="lineChart2" height="602" width="1294" style="display: block; width: 647px; height: 301px;"></canvas>
                                                      </div>
                           <script>//<![CDATA[
                                    var lineData = {
                                            labels: ["2007", "2008", "2009", "2010", "2011", "2012", "2013","2014","2015","2016"],
                                            datasets: [

                                                {
                                                    label: "2007-2016",
                                                    backgroundColor: 'rgba(26,179,148,0.5)',
                                                    borderColor: "rgba(26,179,148,0.7)",
                                                    pointBackgroundColor: "rgba(26,179,148,1)",
                                                    pointBorderColor: "#fff",
                                                    data: [10, 12, 14, 11, 9, 12, 14,16,17]
                                                }
                                            ]
                                        };

                                        var lineOptions = {
                                            responsive: true
                                        };


                                        var ctx = document.getElementById("lineChart2").getContext("2d");
                                        new Chart(ctx, {type: 'line', data: lineData, options:lineOptions});


                                    //]]></script>
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