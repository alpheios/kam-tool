module namespace _="sanofi/views/projekte";

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

declare variable $_:static := $global:module-path||"/"||doc("../module.xml")/*:module/*:install-path||"/static";


declare %plugin:provide('side-navigation')
  function _:nav-item-kam()
  as element(xhtml:li) {
  <li xmlns="http://www.w3.org/1999/xhtml" data-parent="/" data-sortkey="AA1">
      <a href="{$global:servlet-prefix}/sanofi/projekt"><i class="fa fa-area-chart"></i> <span class="nav-label">Projekte Gantt    </span></a>
  </li>
};

declare %plugin:provide("ui/page/content","sanofi/projekt")
function _:sanofi-projekte($map as map(*))
as element(xhtml:div)
{
let $id := $map => map:get("id")
let $id := if (not($id)) then "1234" else $id
let $context := map{"context":"sanofi/projekt"}
let $projekt-schema := plugin:provider-lookup("sanofi/projekt","schema")!.()
let $kk-schema := plugin:provider-lookup("sanofi/kk","schema")!.()
let $kks := plugin:provider-lookup("sanofi/kk","datastore/dataobject/all")!.($kk-schema,$context)
let $projekte := plugin:provider-lookup("sanofi/projekt","datastore/dataobject/all")!.($projekt-schema,$context)
let $kk := plugin:provider-lookup("sanofi/projekt","datastore/dataobject")!.($id,$kk-schema,$context)
return
<div xmlns="http://www.w3.org/1999/xhtml" class="content-with-sidebar row">
  <div class="row">
      <div class="col-lg-12">
          <div class="ibox float-e-margins">
              <div class="ibox-title">
                  <h5>Gantt Test</h5>
                  <select class="chosen pull-right" onchange="window.location='/influx/sanofi/projekt?id='+$(this).val()">
                    <option>{if (not($id)) then attribute selected {} else ()}Bitte auswählen</option>
                    {$kks ! <option value="{./@id/string()}">{if ($id=./@id) then attribute selected {} else ()}{./*:name/string()}</option>}
                  </select>
              </div>
              <div class="ibox-content">
                  <div class="gantt-container" style="overflow: scroll">
                  	<div id="chart_div"></div>
                  </div>
              </div>
          </div>
      </div>
      <script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>
        <script type="text/javascript">//<![CDATA[
          google.charts.load('current', {'packages':['gantt']});
          google.charts.setOnLoadCallback(drawChart);

          function drawChart() {

            var data = new google.visualization.DataTable();
]]>
            {(:
                for $element in $projekt-schema/*:element
                let $type:= if ($element/@type="text") then "string" else if ($element/@type="date") then "date" else "string"
                return "data.addColumn('"||$type||"', '"||$element/*:label/string()||"');&#x0a;"
            :)}
            <![CDATA[
            data.addColumn('string', 'Task ID');
            data.addColumn('string', 'Task Name');
            data.addColumn('string', 'Resource');
            data.addColumn('date', 'Start Date');
            data.addColumn('date', 'End Date');
            data.addColumn('number', 'Duration');
            data.addColumn('number', 'Percent Complete');
            data.addColumn('string', 'Dependencies');

            data.addRows([
            ]]>{
            let $projekt-list := $projekte[*:kk=$kk/@id]
            return string-join($projekt-list!('["'||random:uuid()||'","'||./*:name/string()||'","'||$kk/*:name/string()||'",new Date('||translate(./*:beginn,'-',',')||'),new Date('||translate(./*:ende,'-',',')||'), null, 100, null]'),",")
            }<![CDATA[

            ]);

$.ajax({
    url: 'myXML.xml',
    dataType: 'xml',
    success: function (xml) {
        var data = new google.visualization.DataTable();
        data.addColumn('string', 'Name');
        data.addColumn('number', 'Value');

        $('row', xml).each(function () {
            var name = $('name', this).text();
            var value = parseInt($('value', this).text());
            data.addRow([name, value]);
        });

        var chart = new google.visualization.LineChart(document.querySelector('#chart_div'));
        chart.draw(data, {
            height: 400,
            width: 600
        });
    }
});

            var options = {
                fontName : "open sans"
            };

            var chart = new google.visualization.Gantt(document.getElementById('chart_div'));

            chart.draw(data, options);
          }
        ]]></script>
    </div>
</div>
};




