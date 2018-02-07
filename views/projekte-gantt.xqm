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
let $kk := plugin:provider-lookup("sanofi/projekt","datastore/dataobject")!.($id,$kk-schema,$context)
let $projekte := plugin:provider-lookup("sanofi/projekt","datastore/dataobject/all")!.($projekt-schema,$context)[kk=$kk/@id]
return
<div xmlns="http://www.w3.org/1999/xhtml" class="content-with-sidebar row">
  <div class="row">
      <div class="col-lg-12">
          <div class="ibox float-e-margins">
              <div class="ibox-title">
                  <h5>Projekte einer Krankenkasse im Überblick</h5>
                  <select class="chosen pull-right" onchange="window.location='/influx/sanofi/projekt?id='+$(this).val()">
                    <option>{if (not($id)) then attribute selected {} else ()}Bitte auswählen</option>
                    {$kks ! <option value="{./@id/string()}">{if ($id=./@id) then attribute selected {} else ()}{./*:name/string()}</option>}
                  </select>
              </div>
              <div class="ibox-content">
                  <div class="gantt-container" style="overflow: scroll; width:1080; height:1000">
                  	<div id="chart_div"></div>
                  </div>
                  	<div id="table_div"></div>
              </div>
          </div>
      </div>
      { if ($projekte) then <div>
      <script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>
      <script type="text/javascript">
          google.charts.load('current', {{packages: ['charteditor']}});
        </script>
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
            data.addColumn('string', 'Projekt ID');
            data.addColumn('string', 'Projekt');
            data.addColumn('string', 'Krankenkasse');
            data.addColumn('date', 'Start Datum');
            data.addColumn('date', 'Ende Datum');
            data.addColumn('number', 'Dauer');
            data.addColumn('number', 'Fertigstellung in %');
            data.addColumn('string', 'Dependencies');

            data.addRows([
            ]]>{
                string-join($projekte!('["'||./@id/string()||'","'||./*:name/string()||'","'||$kk/*:name/string()||'",new Date('||translate(./*:beginn,'-',',')||'),new Date('||translate(./*:ende,'-',',')||'), null, '||./*:fertigstellung/string()||', null]'),",")
            }<![CDATA[

            ]);

                var options = {
                    fontName : "open sans",
                    allowHtml : true
                };
            var chart = new google.visualization.Gantt(document.getElementById('chart_div'));

            chart.draw(data, options);

            var table = new google.visualization.Table(document.getElementById('table_div'));

            var formatter = new google.visualization.PatternFormat('<a data-remote="false" data-target="#influx-modal-dialog" data-toggle="modal" href="/influx/schema/form/modal/{0}?provider=sanofi/projekt&amp;context=kk&amp;context-item-id=]]>{$id}<![CDATA[&amp;context-provider=sanofi/kk&amp;random=]]>{random:uuid()}<![CDATA[" class="btn btn-sm"><span class="fa fa-edit"></span></a>')
            // Apply formatter and set the formatted value of the first column.
            formatter.format(data, [0]);

            var view = new google.visualization.DataView(data);
            view.setColumns([0,1,3,4]); // Create a view with the first column only.

            table.draw(view, {allowHtml: true, showRowNumber: false, width: '100%', height: '100%'});
          }
        ]]></script>
        </div> else ()}
    </div>
</div>
};




