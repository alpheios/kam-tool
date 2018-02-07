module namespace _ = "sanofi/projekt";

(: import repo modules :)
import module namespace global	= "influx/global";
import module namespace plugin	= "influx/plugin";
import module namespace db	    = "influx/db";
import module namespace ui =" influx/ui2";
import module namespace date-util ="influx/utils/date-utils";

declare namespace xhtml="http://www.w3.org/1999/xhtml";



declare %plugin:provide('side-navigation')
  function _:nav-item-stammdaten-products()
  as element(xhtml:li) {
  <li xmlns="http://www.w3.org/1999/xhtml" data-parent="/schema/list/items" data-sortkey="ZZZ">
      <a href="{$global:servlet-prefix}/schema/list/items?context=stammdaten/projekt&amp;provider=sanofi/projekt"><i class="fa fa-archive"></i> <span class="nav-label">Projekte</span></a>
  </li>
};

declare %plugin:provide("schema/render/page/debug/itemX") function _:debug-kk ($Item,$Schema,$Context){
<pre>{serialize($Item)}</pre>
};

declare %plugin:provide("ui/page/content","stammdaten/projekt")
function _:stammdaten-projekt($map)
as element(xhtml:div)
{
<div xmlns="http://www.w3.org/1999/xhtml" class="content-with-sidebar row">
  <div class="row">
      <div class="col-lg-12">
            {plugin:lookup("schema/ibox/table")!.("sanofi/projekt","stammdaten/projekt")}
      </div>
  </div>
</div>
};

declare %plugin:provide("schema/render/form/field/foreign-key","kk")
function _:sanofi-projekte-kk-input($Item as element(), $Element as element(element), $Context as map(*))
as element()?
{
    if ($Context("context-item")/@id/string())
        then
            <input xmlns="http://www.w3.org/1999/xhtml" name="kk" value="{$Context("context-item")/@id/string()}" type="hidden"/>
        else ()(:plugin:provider-lookup("influx/schema","schema/render/form/field/foreign-key")!.($Item,$Element,$Context):)
};
declare %plugin:provide("schema/render/form/field/label","kk")
function _:sanofi-projekte-kk-input-label($Item as element(), $Element as element(element), $Context as map(*))
as element()?
{
    if ($Context("context-item")/@id/string())
        then ()
        else ()(:plugin:provider-lookup("influx/schema","schema/render/form/field/label")!.($Item,$Element,$Context):)
};

declare %plugin:provide("schema/render/form/field/foreign-key","kv")
function _:sanofi-projekte-kv-input($Item as element(), $Element as element(element), $Context as map(*))
as element()?
{
    if ($Context("context-item"))
        then
            <input xmlns="http://www.w3.org/1999/xhtml" name="kv" value="{$Context("context-item")/@id/string()}" type="hidden"/>
        else ()(:plugin:provider-lookup("influx/schema","schema/render/form/field/foreign-key")!.($Item,$Element,$Context):)
};
declare %plugin:provide("schema/render/form/field/label","kv")
function _:sanofi-projekte-kv-input-label($Item as element(), $Element as element(element), $Context as map(*))
as element()?
{
    if ($Context("context-item"))
        then ()
        else ()(:plugin:provider-lookup("influx/schema","schema/render/form/field/label")!.($Item,$Element,$Context):)
};


(: provide sorting for items :)
declare %plugin:provide("schema/process/table/items")
function _:schema-render-table-prepare-rows($Items as element()*, $Schema as element(schema),$Context as map(*)){for $item in $Items order by $item/name, $item/priority return $item};

declare %plugin:provide("schema/set/elements")
function _:schema-render-table-prepare-rows-only-name($Items as element()*, $Schema as element(schema),$Context as map(*)){
    let $columns := ("name","beginn", "ende", "kk", "kv")
    let $schema := $Schema update delete node ./*:element
    let $elements-in-order := for $name in $columns return $Schema/element[@name=$name]
    let $schema := $schema update insert node $elements-in-order as last into .
    return $schema};

declare %plugin:provide("schema") function _:schema-customer()
as element(schema){
<schema xmlns="" name="projekt" domain="sanofi" provider="sanofi/projekt">
    <modal>
        <title>Projekt</title>
    </modal>
    <element name="name" type="text">
        <label>Projektname</label>
    </element>
    <element name="kk" type="foreign-key" required="">
                    <provider>sanofi/kk</provider>
                    <key>@id</key>
                    <display-name>name/string()</display-name>
                    <label>KK-Vertragspartner</label>
                    <class>col-md-6</class>
    </element>
    <element name="kv" type="foreign-key" required="">
                    <provider>sanofi/kv</provider>
                    <key>@id</key>
                    <display-name>name/string()</display-name>
                    <label>KV-Vertragspartner</label>
                    <class>col-md-6</class>
    </element>
    <element name="beginn" type="date">
        <class></class>
        <label>Beginn</label>
    </element>
    <element name="ende" type="date">
        <label>Ende</label>
    </element>
    <element name="fertigstellung" type="number" min="0" max="100" default="100">
        <label>Fertigstellung in %</label>
    </element>

    <element name="notizen" type="text">
         <label>Notizen</label>
     </element>
 </schema>
};


declare
    %plugin:provide("schema/render/new","kk")
    %plugin:provide("schema/render/update","kk")
    %plugin:provide("schema/render/delete","kk")
function _:kk-projekt-render-new($Item as element(projekt), $Schema as element(schema), $Context as map(*))
as element(xhtml:div)
{
    plugin:provider-lookup("sanofi/projekt","content/view/context","kk")!.($Item,$Schema,$Context)
};

declare %plugin:provide("content/view/context","kk")
function _:sanofi-projekte($Item as element(projekt)? ,$Schema as element(schema), $Context)
as element(xhtml:div)
{
  let $kk-id := $Context("item")/@id/string()
  let $provider := "sanofi/projekt"
  let $context := map{"context":"sanofi/projekt"}
  let $projekt-schema := plugin:provider-lookup("sanofi/projekt","schema")!.()
  let $kk-schema := plugin:provider-lookup("sanofi/kk","schema")!.()
  let $kks := plugin:provider-lookup("sanofi/kk","datastore/dataobject/all")!.($kk-schema,$context)
  let $kk := $Context("item") (:plugin:provider-lookup("sanofi/projekt","datastore/dataobject")!.($kk-id,$kk-schema,$context):)
  let $projekte := plugin:provider-lookup("sanofi/projekt","datastore/dataobject/all")!.($projekt-schema,$context)[kk=$kk-id]
  let $edit-button :=plugin:provider-lookup($provider,"schema/render/button/modal/edit")!.($Item,$Schema,$Context)
  let $add-button := plugin:provider-lookup($provider,"schema/render/button/modal/new")!.($Item,$Schema,$Context)

  return
    <div xmlns="http://www.w3.org/1999/xhtml" data-replace="#kk-projekte" id="kk-projekte">
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
          { if ($projekte) then <div>
          <script class="rxq-js-eval" type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>
            <script class="rxq-js-eval" type="text/javascript">//<![CDATA[
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
                    string-join($projekte!('["'||./@id/string()||'","'||./*:name/string()||'","'||$kk/*:name/string()||'",new Date('||translate(./*:beginn,'-',',')||'),new Date('||translate(./*:ende,'-',',')||'), null, '||./*:fertigstellung||', null]'),",")
                }<![CDATA[

                ]);


                var options = {
                    fontName : "open sans"
                    ,height : 640
                    ,width : 420
                };

                var chart = new google.visualization.Gantt(document.getElementById('chart_div'));

                chart.draw(data, options);
              }
            ]]></script>
            </div> else ()}
        </div>
    </div>  
};
