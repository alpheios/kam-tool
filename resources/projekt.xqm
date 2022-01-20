module namespace _ = "sanofi/projekt";

(: import repo modules :)
import module namespace global	= "influx/global";
import module namespace plugin	= "influx/plugin";
import module namespace db	    = "influx/db";
import module namespace ui =" influx/ui";
import module namespace date-util ="influx/utils/date-utils";
import module namespace common="sanofi/common" at "common.xqm";
import module namespace alert="influx/ui/alert";

declare namespace xhtml="http://www.w3.org/1999/xhtml";

declare variable $_:ns := namespace-uri(<_:ns/>);
declare %plugin:provide('ui/page/title') function _:heading($m){_:schema-projekt()//*:title/string()};
declare %plugin:provide("ui/page/content") function _:ui-page-content($m){common:ui-page-content($m)};
declare %plugin:provide("ui/page/heading") function _:ui-page-heading($m){common:ui-page-heading($m)};


declare %plugin:provide('side-navigation-item')
  function _:nav-item-stammdaten-products()
  as element(xhtml:li) {
  <li xmlns="http://www.w3.org/1999/xhtml" data-parent="/schema/list/items" data-sortkey="ZZZ">
      <a class="ajax" href="{$global:servlet-prefix}/schema/list/items?context=stammdaten/projekt&amp;provider=sanofi/projekt"><i class="fa fa-archive"></i> <span class="nav-label">Projekte</span></a>
  </li>
};

declare %plugin:provide('side-navigation-item')
  function _:nav-item-stammdaten-products-fusioniert()
  as element(xhtml:li) {
  <li xmlns="http://www.w3.org/1999/xhtml" data-parent="/schema/list/items/fusioniert" data-sortkey="ZZZ">
      <a class="ajax" href="{$global:servlet-prefix}/schema/list/items?context=fusioniert/projekt&amp;provider=sanofi/projekt"><i class="fa fa-archive"></i> <span class="nav-label">Projekte</span></a>
  </li>
};

(: buttons open modal instead of page :)
declare %plugin:provide("schema/render/button/page/edit")
function _:schema-render-button-page-edit($Item as element(), $Schema as element(schema), $Context as map(*))
as element()
{
    plugin:lookup("schema/render/button/modal/edit")!.($Item,$Schema,$Context)
};


(: provide sorting for items :)
declare %plugin:provide("schema/process/table/items", "kk")
function _:schema-render-table-prepare-rows-kk(
  $Items as element()*, 
  $Schema as element(schema),
  $Context as map(*)
) {
  for $item in $Items[kk=$Context?context-item-id]
  order by $item/name
  where not($Context?context-item/fusioniert/string() = "true")
  return $item
};

declare %plugin:provide("schema/process/table/items", "kv")
function _:schema-render-table-prepare-rows-kv(
  $Items as element()*, 
  $Schema as element(schema),
  $Context as map(*)
) {
  for $item in $Items[kv=$Context?context-item-id]
  order by $item/name
  return $item
};

declare %plugin:provide("schema/process/table/items", "fusioniert/projekt")
function _:schema-render-table-prepare-rows-fusioniert(
    $Items as element()*, 
    $Schema as element(schema),
    $Context as map(*)
) {
  let $context := $Context("context")
  let $kk-provider := "sanofi/kk"
  let $kk-schema := plugin:provider-lookup($kk-provider, "schema", $context)!.()
  return
    for $item in $Items
    let $kk := 
      if ($item/kk/string())
      then plugin:lookup("datastore/dataobject")!.($item/kk/string(), $kk-schema, $Context)
      else ()
    order by $item/name
    where $kk/fusioniert/string() = "true"
    return $item
};

declare %plugin:provide("schema/set/elements")
function _:schema-render-table-prepare-rows-only-name($Items as element()*, $Schema as element(schema),$Context as map(*)){
    let $columns := ("name","beginn", "ende")
    let $schema := $Schema update delete node ./*:element
    let $elements-in-order := for $name in $columns return $Schema/element[@name=$name]
    let $schema := $schema update insert node $elements-in-order as last into .
    return $schema};

declare %plugin:provide("schema") function _:schema-projekt()
as element(schema){
<schema xmlns="" name="projekt" domain="sanofi" provider="sanofi/projekt">
    <modal>
        <title>Projekt</title>
    </modal>
    <element name="name" type="text">
        <label>Projektname</label>
    </element>
    <element name="kk" type="foreign-key" render="dropdown">
                    <provider>sanofi/kk</provider>
                    <key>@id</key>
                    <display-name>name/string()</display-name>
                    <label>KK-Vertragspartner</label>
                    <class>col-md-6</class>
    </element>
    <element name="kv" type="foreign-key" render="dropdown">
                    <provider>sanofi/kv</provider>
                    <key>@id</key>
                    <display-name>name/string()</display-name>
                    <label>KV-Vertragspartner</label>
                    <class>col-md-6</class>
    </element>
    <element name="beginn" type="date" required="">
        <class></class>
        <label>Beginn</label>
    </element>
    <element name="ende" type="date" required="">
        <label>Ende</label>
    </element>
    <element name="fertigstellung" type="number" min="0" max="100" default="100">
        <label>Fertigstellung in %</label>
    </element>

    <element name="notizen" type="textarea">
         <label>Link</label>
     </element>
 </schema>
};

declare %plugin:provide("schema", "kk")
function _:schema-kk() {  
  _:schema-projekt() update (
    replace value of node ./element[@name="kk"]/@render with "context-item"
    ,delete node ./element[@name="kk"]/label
    ,delete node ./element[@name="kv"]
  )
};

declare %plugin:provide("schema", "kv")
function _:schema-kv() {  
  _:schema-projekt() update (
    replace value of node ./element[@name="kv"]/@render with "context-item"
    ,delete node ./element[@name="kv"]/label
    ,delete node ./element[@name="kk"]
  )
};


(: Anzeige der Projekte im Kontext der KK, KV oder LAV :)
declare %plugin:provide("content/view/context")
function _:sanofi-projekte($Items as element(projekt)* ,$Schema as element(schema), $Context)
{
  let $add-button := plugin:provider-lookup($_:ns,"schema/render/button/modal/new",$Context?context)!.($Schema,$Context)
  return
  <div xmlns="http://www.w3.org/1999/xhtml" data-replace="#projekte-tab" id="projekte-tab">
      <div class="row">
          <div class="col-lg-12">
              <div class="ibox float-e-margins">
                  <div class="ibox-title">
                          <div class="col-md-12"><label class="form-label pull-right">Projekt hinzufügen {$add-button}</label></div>
                  </div>
                  <div class="ibox-content">
                      <div class="gantt-container" style="overflow: scroll;">
                        <div id="chart_div"></div>
                      </div>
                  </div>
              </div>
          </div>
          { if ($Items) then <div>
          <script class="rxq-js-eval" type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>
            <script class="rxq-js-eval" type="text/javascript">//<![CDATA[
              google.charts.load('current', {'packages':['gantt'], callback: init});

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
                    string-join($Items!('["'||./@id/string()||'","'||./*:name/string()||'","'||$Context?context-item/*:name/string()||'",new Date("'||./*:beginn/string()||'"),new Date("'||./*:ende/string()||'"), null, '||./*:fertigstellung||', null]'),",")
                }<![CDATA[

                ]);

                var options = {
                    fontName : "open sans",
                    height: ]]>{count($Items)*55 + 25}<![CDATA[
                };

                var chart = new google.visualization.Gantt(document.getElementById('chart_div'));

                chart.draw(data, options);
              }

              function init() {
                if ($('#tab-4').hasClass('active')) {
                    drawChart();
                }
                else {
                    $("a[href='#tab-4']").one('shown.bs.tab', drawChart);
                }
              }
            ]]></script>
            </div> else ()}
        </div>
    </div>  
    ,plugin:provider-lookup($_:ns,"schema/render/table/embed")!.($Items, $Schema, $Context)
};
