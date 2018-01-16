module namespace _ = "sanofi/kk-history-mitglieder";

(: import repo modules :)
import module namespace global	= "influx/global";
import module namespace plugin	= "influx/plugin";
import module namespace db	    = "influx/db";
import module namespace ui =" influx/ui2";

declare namespace xhtml="http://www.w3.org/1999/xhtml";


declare %plugin:provide("schema/render/page/debug/itemXXX") function _:debug-kk ($Item,$Schema,$Context){
<pre>{serialize($Item)}</pre>
};

declare %plugin:provide("schema/process/table/items")
function _:schema-render-table-prepare-rows-jf($Items as element()*, $Schema as element(schema),$Context as map(*))
{
for $item in $Items order by $item/name return $item
};

declare %plugin:provide("schema/set/elements")
function _:schema-column-filter($Item as element()*, $Schema as element(schema), $Context as map(*)){
    let $columns := ("datum","anzahl","marktanteil")
    let $schema := $Schema update delete node ./*:element
    let $elements-in-order := for $name in $columns return $Schema/element[@name=$name]
    let $schema := $schema update insert node $elements-in-order as last into .
    return $schema
};

declare %plugin:provide("schema") function _:schema()
as element(schema){
<schema xmlns="" name="kk-history-mitglieder" domain="sanofi" provider="sanofi/kk-history-mitglieder">
    <modal>
        <title>KK Versicherte</title>
        <button>
            <add>hinzufügen</add>
            <cancel>abbrechen</cancel>
            <modify>ändern</modify>
            <delete>löschen</delete>
        </button>
    </modal>
    <element name="datum" type="date">
        <label>Datum</label>
    </element>
    <element name="anzahl" type="number">
        <label>Mitglieder Anzahl</label>
    </element>
    <element name="marktanteil" type="number">
        <label>Mitglieder Marktanteil</label>
    </element>
    <element name="kk" type="foreign-key" required="">
            <provider>sanofi/kk</provider>
            <key>@id</key>
            <display-name>name/string()</display-name>
            <label>KK-Vertragspartner</label>
            <class>col-md-6</class>
    </element>
  </schema>
};

declare %plugin:provide("schema/render/form/field/foreign-key","kk")
function _:sanofi-kk-history-mitglieder-input($Item as element(), $Element as element(element), $Context as map(*))
as element()?
{
    if ($Context("kk"))
        then
            <input xmlns="http://www.w3.org/1999/xhtml" name="kk" value="{$Context("kk")}" type="hidden"/>
        else ()(:plugin:provider-lookup("influx/schema","schema/render/form/field/foreign-key")!.($Item,$Element,$Context):)
};
declare %plugin:provide("schema/render/form/field/label","kk")
function _:sanofi-kk-history-mitglieder-input-label($Item as element(), $Element as element(element), $Context as map(*))
as element()?
{
    if ($Context("kk"))
        then ()
        else ()(:plugin:provider-lookup("influx/schema","schema/render/form/field/label")!.($Item,$Element,$Context):)
};

declare %plugin:provide("schema/render/button/modal/edit/link")
function _:kk-mitglieder-render-button-page-edit-link($Item as element(), $Schema as element(schema), $Context as map(*))
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
function _:sanofi-kk-mitglieder-content-view($Item as element(), $Schema as element(schema), $Context as map(*))
as element(xhtml:div)
{
let $id := $Item/@id/string()
let $kk := $Context("item")/@id/string()
let $provider := "kk-history-mitglieder"
let $context := map{"context":"kk-history-mitglieder"}
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
                    <select id="content-view-select" class="form-control" onchange="Influx.restxq('{$global:servlet-prefix}/sanofi/kk/mitglieder/chart/'+$(this).val())">
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

declare %plugin:provide("sanofi/kk/mitglieder/chart") function _:ibox-radar-chart($Item,$Schema,$Context){
let $id := $Item/@id/string()
let $kk := $Context("item")/@id/string()
let $provider := "kk-history-mitglieder"
let $context := map{"context":"kk-history-mitglieder"}
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
<div class="ibox-content" id="kk-mitglieder-chart" data-replace="#kk-mitglieder-chart">
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
};