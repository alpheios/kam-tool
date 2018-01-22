module namespace _ = "sanofi/summary";

(: import repo modules :)
import module namespace global	= "influx/global";
import module namespace plugin	= "influx/plugin";
import module namespace db	    = "influx/db";
import module namespace ui =" influx/ui2";

declare namespace xhtml="http://www.w3.org/1999/xhtml";

declare %plugin:provide('side-navigationX')
  function _:nav-item-stammdaten-summary()
  as element(xhtml:li) {
  <li xmlns="http://www.w3.org/1999/xhtml" data-parent="/sanofi/stammdaten" data-sortkey="ZZZ">
      <a href="{$global:servlet-prefix}/sanofi/stammdaten/summary"><i class="fa fa-users"></i> <span class="nav-label">KAM Summary</span></a>
  </li>
};

declare %plugin:provide("ui/page/content","stammdaten/summary")
function _:stammdaten-summary($map)
as element(xhtml:div)
{
<div xmlns="http://www.w3.org/1999/xhtml" class="content-with-sidebar row">
  <div class="row">
      <div class="col-lg-12">
            {plugin:lookup("schema/ibox/table")!.("sanofi/summary","stammdaten/summary")}
      </div>
  </div>
</div>
};


(: provide sorting for items :)
declare %plugin:provide("schema/process/table/items")
function _:schema-render-table-prepare-rows($Items as element()*, $Schema as element(schema),$Context as map(*)){for $item in $Items order by $item/name, $item/priority return $item};

declare %plugin:provide("schema/set/elements")
function _:schema-render-table-prepare-rows-only-name($Items as element()*, $Schema as element(schema),$Context as map(*)){
    let $columns := ("name","datum")
    let $schema := $Schema update delete node ./*:element
    let $elements-in-order := for $name in $columns return $Schema/element[@name=$name]
    let $schema := $schema update insert node $elements-in-order as last into .
    return $schema};






declare %plugin:provide("schema") function _:schema-customer()
as element(schema){
<schema xmlns="" name="summary" domain="sanofi" provider="sanofi/summary">
    <modal>
        <title>KAM Management Zusammenfassung</title>
        <button>
            <add>hinzufügen</add>
            <cancel>abbrechen</cancel>
            <modify>ändern</modify>
            <delete>löschen</delete>
        </button>
    </modal>
    <element name="name" type="text">
        <label>Titel</label>
    </element>
    <element name="datum" type="text">
        <label>Datum</label>
    </element>

    <element name="news1" type="text">
        <label>1. News</label>
    </element>
    <element name="news2" type="text">
            <label>2. News</label>
    </element>
    <element name="news3" type="text">
        <label>3. News</label>
    </element>
    <element name="news4" type="text">
        <label>4. News</label>
    </element>

    <element name="overview1" type="text">
        <label>1. Auf einen Blick</label>
    </element>
    <element name="overview2" type="text">
            <label>2. Auf einen Blick</label>
    </element>
    <element name="overview3" type="text">
        <label>3. Auf einen Blick</label>
    </element>
    <element name="overview4" type="text">
        <label>4. Auf einen Blick</label>
    </element>

    <element name="goal1" type="text">
        <label>1. Top Ziel</label>
    </element>
    <element name="goal2" type="text">
            <label>2. Top Ziel</label>
    </element>
    <element name="goal3" type="text">
        <label>3. Top Ziel</label>
    </element>
    <element name="goal4" type="text">
        <label>4. Top Ziel</label>
    </element>

    <element name="good1" type="text">
        <label>1. Was läuft gut?</label>
    </element>
    <element name="good2" type="text">
            <label>2. Was läuft gut?</label>
    </element>
    <element name="good3" type="text">
        <label>3. Was läuft gut?</label>
    </element>
    <element name="good4" type="text">
        <label>4. Was läuft gut?</label>
    </element>

    <element name="critical1" type="text">
        <label>1. Kritischer Punkt</label>
    </element>
    <element name="critical2" type="text">
            <label>2. Kritischer Punkt</label>
    </element>
    <element name="critical3" type="text">
        <label>3. Kritischer Punkt</label>
    </element>
    <element name="critical4" type="text">
        <label>4. Kritischer Punkt</label>
    </element>


   <element name="kv" type="foreign-key" required="">
              <provider>sanofi/kv</provider>
              <key>@id</key>
              <display-name>name/string()</display-name>
              <label>KV</label>
              <class>col-md-6</class>
   </element>

   <element name="kk" type="foreign-key" required="">
              <provider>sanofi/kk</provider>
              <key>@id</key>
              <display-name>name/string()</display-name>
              <label>KK</label>
              <class>col-md-6</class>
   </element>

   <element name="produkt" type="foreign-key" required="">
              <provider>sanofi/produkt</provider>
              <key>@id</key>
              <display-name>name/string()</display-name>
              <label>Produkt</label>
              <class>col-md-6</class>
   </element>

    <element name="notizen" type="text">
         <label>Notizen</label>
     </element>
 </schema>
};

declare %plugin:provide("content/view/context","kk")
function _:content-view($Item as element(kk-kam-top-4)?, $Schema as element(schema), $Context as map(*)){
let $id := $Item/@id/string()
let $kk-id := if ($Context("context-id")) then $Context("context-id") else $Context("kk")
let $context := $Context("context")
let $provider := "sanofi/kk-kam-top-4"
let $schema := plugin:provider-lookup($provider,"schema")!.()
let $items := plugin:provider-lookup($provider,"datastore/dataobject/all",$context)!.($schema,$Context)[kk=$kk-id]
let $name := $Item/name/string()
let $kk-history-provider := "sanofi/kk-history-mitglieder"
let $kk-history-schema := plugin:provider-lookup($kk-history-provider,"schema")!.()
let $kk-history-items := plugin:provider-lookup($kk-history-provider,"datastore/dataobject/all",$context)!.($kk-history-schema,$Context)
let $edit-button := try {plugin:provider-lookup($provider,"schema/render/button/modal/edit")!.($Item,$schema,$Context)} catch * {}
let $add-button := ui:modal-button('schema/form/modal?context='||$context||'&amp;provider='||$provider||"&amp;kk="||$kk-id,<a xmlns="http://www.w3.org/1999/xhtml" shape="rect" class="btn btn-sm btn-outline"><span class="fa fa-plus"/></a>)
return
<div xmlns="http://www.w3.org/1999/xhtml" id="kk-top-4" data-replace="#kk-top-4">
    <script src="{$global:inspinia-path}/js/plugins/chartJs/Chart.min.js"></script>
<div class="row">
      <div class="col-lg-12 col-md-12">
          <div class="ibox float-e-margins">
              <div class="ibox-title">
                  <div class="col-xs-9">{$edit-button} Werte bearbeiten</div>
                  <div class="col-xs-1"><label class="form-label pull-right">{$add-button}</label></div>
                  <div class="col-xs-2">
                    <select id="content-view-select"
                        class="form-control"
                        onchange="Influx.restxq('{$global:servlet-prefix}/content/view/context/'+$(this).val()+'/{$kk-id}','get',{{'kk':'{$kk-id}','context':'{$context}','provider':'{$provider}'}})">
                    {$items ! <option value="{./@id/string()}">{if ($id=./@id) then attribute selected {} else ()}{./*:name/string()}</option>}
                    </select>
                  </div>
              </div>
              <div class="ibox-content">

             </div>
          </div>
      </div>
    </div>
              <div class="row">
                <div class="col-lg-6">
                    <div class="ibox float-e-margins">
                        <div class="ibox-title">
                            <h5>Marktanteil</h5>
                        </div>
                        <div class="ibox-content">
                            <div>
                                <iframe class="chartjs-hidden-iframe" style="width: 100%; display: block; border: 0px; height: 0px; margin: 0px; position: absolute; left: 0px; right: 0px; top: 0px; bottom: 0px;"></iframe>
                                <canvas id="doughnutChart2" height="602" width="1294" style="display: block; width: 647px; height: 301px;"></canvas>
                            </div>
                             <script>//<![CDATA[
                                      var doughnutData = {
                                          labels: []]>{'"Anteil KK","Andere KKen"'} <![CDATA[],
                                          datasets: [{
                                              data: []]>{'33,67'} <![CDATA[],
                                              backgroundColor: []]>{'"rgba(26,179,148,1)","rgba(26,179,148,0.5)"'} <![CDATA[]
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
                                            labels: []]>{string-join(($kk-history-items/*:name/string()!('"'||.||'"')),',')}<![CDATA[],
                                            datasets: [

                                                {
                                                    label: "Entwicklung des Marktanteils",
                                                    backgroundColor: 'rgba(26,179,148,0.5)',
                                                    borderColor: "rgba(26,179,148,0.7)",
                                                    pointBackgroundColor: "rgba(26,179,148,1)",
                                                    pointBorderColor: "#fff",
                                                    data: []]>{string-join(($kk-history-items/*:marktanteil/string()!('"'||.||'"')),',')}<![CDATA[]
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
              {
                plugin:provider-lookup($kk-history-provider,"schema/render/table/page","kk")!.($kk-history-items,$kk-history-schema,map{'context':"kk",'kk':$kk-id})
              }
            </div>
};