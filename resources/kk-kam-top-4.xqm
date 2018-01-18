module namespace _ = "sanofi/kk-kam-top-4";

(: import repo modules :)
import module namespace global	= "influx/global";
import module namespace plugin	= "influx/plugin";
import module namespace db	    = "influx/db";
import module namespace ui =" influx/ui2";

declare namespace xhtml="http://www.w3.org/1999/xhtml";

declare %plugin:provide('side-navigationXXX')
  function _:nav-item-stammdaten-kk-kam-top-4()
  as element(xhtml:li) {
  <li xmlns="http://www.w3.org/1999/xhtml" data-parent="/sanofi/stammdaten" data-sortkey="ZZZ">
      <a href="{$global:servlet-prefix}/sanofi/stammdaten/kk-kam-top-4"><i class="fa fa-users"></i> <span class="nav-label">Blauer Ozean</span></a>
  </li>
};

declare %plugin:provide("schema/render/modal/debug/itemX") function _:debug-kk-kam-top-4 ($Item as element(kk-kam-top-4),$Schema as element(schema),$Context){
<pre>{serialize($Item)}
<ul>{for $key in map:keys($Context)
return <li>{$key} : {$Context($key)}</li>
}</ul>
</pre>
};

declare %plugin:provide("ui/page/content","stammdaten/kk-kam-top-4")
function _:stammdaten-kk-kam-top-4($map)
as element(xhtml:div)
{
let $items := $map("items")
let $provider := $map("provider")
let $id := $map("id")
let $modal-button := ui:modal-button('schema/form/modal?provider='||$provider||"&amp;context=page",<a xmlns="http://www.w3.org/1999/xhtml" shape="rect" class="btn btn-sm btn-outline"><span class="fa fa-plus"/></a>)
return
<div xmlns="http://www.w3.org/1999/xhtml" class="content-with-sidebar row">
  <div class="row">
      <div class="col-lg-12">
          <div class="ibox float-e-margins">
              <div class="ibox-title">
                  <h5>{$modal-button} Der Blaue Ozean</h5>
                  <select class="chosen pull-right" onchange="window.location='/influx/sanofi/kk-kam-top-4?id='+$(this).val()">
                    <option>{if (not($id)) then attribute selected {} else ()}Bitte auswählen</option>
                    {$items ! <option value="{./@id/string()}">{if ($id=./@id) then attribute selected {} else ()}{./*:name/string()}</option>}
                  </select>
              </div>
              <div class="ibox-content">
                {plugin:lookup("schema/ibox/table")!.("sanofi/kk-kam-top-4","stammdaten/kk-kam-top-4")}
              </div>
          </div>
      </div>
  </div>
</div>
};


(: provide sorting for items :)
declare %plugin:provide("schema/process/table/items")
function _:schema-render-table-prepare-rows($Items as element()*, $Schema as element(schema),$Context as map(*)){for $item in $Items order by $item/name, $item/priority return $item};

declare %plugin:provide("schema/set/elements")
function _:schema-render-table-prepare-rows-only-name($Items as element()*, $Schema as element(schema),$Context as map(*)){
    let $columns := ("name","kk","kv","datum")
    let $schema := $Schema update delete node ./*:element
    let $elements-in-order := for $name in $columns return $Schema/element[@name=$name]
    let $schema := $schema update insert node $elements-in-order as last into .
    return $schema};

declare %plugin:provide("schema") function _:schema-()
as element(schema){
<schema xmlns="" name="kk-kam-top-4" domain="sanofi" provider="sanofi/kk-kam-top-4">
    <modal>
        <title>Der Blaue Ozean</title>
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

    <element name="datum" type="date">
        <label>Datum</label>
    </element>

    <element name="ein-blick" type="text">
        <label>Unser Geschäft auf einen Blick</label>
    </element>

    <element name="top-ziele" type="text">
        <label>TOP Ziel beim Kunden</label>
    </element>

    <element name="gute" type="text">
        <label>Was läuft gut</label>
    </element>
    <element name="kritisch" type="text">
        <label>Kritische Punkte</label>
    </element>
    <element name="position" type="html">
        <label>Wie positioniert sich der Kunde?</label>
    </element>

   <element name="kk" type="foreign-key" required="">
              <provider>sanofi/kk</provider>
              <key>@id</key>
              <display-name>name/string()</display-name>
              <label>KK</label>
              <class>col-md-6</class>
   </element>
    <element name="notizen" type="text">
         <label>Notizen</label>
     </element>
 </schema>
};


(:

 Item im Kontext einer "KK" anzeigen/bearbeiten   #####################################

:)
declare %plugin:provide("schema/render/form/field/foreign-key","kk") (: Achtung: "kk" ist hier nicht der Kontext, sondern der Feldname! :)
function _:sanofi-kk-kam-top-4-kk-input($Item as element(kk-kam-top-4), $Element as element(element), $Context as map(*))
as element()?
{
    let $kk-id := $Context("kk")
    return <input xmlns="http://www.w3.org/1999/xhtml" name="kk" value="{$kk-id}" type="hidden"/>
};

declare %plugin:provide("schema/render/form/field/label","kk") (: Achtung: "kk" ist hier nicht der Kontext, sondern der Feldname! :)
function _:sanofi-kk-kam-top-4-kk-input-label($Item as element(kk-kam-top-4), $Element as element(element), $Context as map(*))
as element()?
{
    (: Label für Feld "kk" löschen :)
};

declare %plugin:provide("schema/render/modal/form/buttons","kk") function _:kk-kk-kam-top-4-render-form-buttons($Item, $Schema, $Context, $Form-id){
    let $provider := $Schema/@provider/string()
    let $modify-button := $Schema/modal/button/modify/node()
    let $add-button := $Schema/modal/button/add/node()
    let $delete-button :=$Schema/modal/button/delete/node()
    let $cancel-button :=$Schema/modal/button/cancel/node()
    let $item-id := $Item/@id/string()
    let $context := $Context("context")
    let $new := $Item/@last-modified-date=""
    let $button-text := if ($new) then <span data-i18n="modify-item">{$add-button}</span> else <span data-i18n="add-item">{$modify-button}</span>
    return
        <div xmlns="http://www.w3.org/1999/xhtml">
         {if (not($new)) then <a href="{$global:servlet-prefix}/datastore/dataobject/delete/{$item-id}?provider={$provider}&amp;context={$context}&amp;kk={$Item/@id}" data-method="DELETE" type="button" class="btn btn-outline btn-sm btn-warning ajax" data-dismiss="modal"><span class="fa fa-times"/><span data-i18n="close">{$delete-button}</span></a> else ()}
         <button type="button" class="btn btn-white btn-sm" data-dismiss="modal"><span class="fa fa-times"/><span data-i18n="cancel">{$cancel-button}</span></button>
         <button type="submit" onClick="$('#{$Form-id}').submit();" class="btn btn-primary btn-sm ajax" data-dismiss="modal"><span class="fa fa-plus"/>{$button-text}</button>
        </div>/*
};

declare %plugin:provide("schema/render/form/action","kk") function _:schema-render-form-action($Item as element(kk-kam-top-4), $Schema as element(schema), $Context as map(*))
as xs:string{
let $provider := $Schema/@provider/string()
let $context := $Context("context")
let $kk-id := $Context("kk")
return
string($global:servlet-prefix||"/datastore/dataobject/put/"||$Item/@id||"?provider="||$provider||"&amp;context="||$context)
};


declare %plugin:provide("schema/render/button/modal/edit/link","kk")
function _:schema-render-button-page-modal-link($Item as element(), $Schema as element(schema), $Context as map(*))
as xs:string
{
let $context := $Context("context")
let $kk-id := $Context("kk")
return
"schema/form/modal/"||$Item/@id||"?provider="||$Schema/@provider||"&amp;context="||$context||"&amp;kk="||$kk-id
};

declare %plugin:provide("schema/render/table/tbody/tr/actions","kk")
function _:schema-render-table-tbody-tr-td-actions($Item as element(), $Schema as element(schema), $Context as map(*))
as element(xhtml:td)
{
let $context := $Context => map:get("context")
let $provider := $Schema/@provider/string()
return
(:edit-button:) <td xmlns="http://www.w3.org/1999/xhtml">{plugin:provider-lookup($provider,"schema/render/button/modal/edit","kk")!.($Item,$Schema,$Context)}</td>
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
let $kk-history-items := plugin:provider-lookup($kk-history-provider,"datastore/dataobject/all",$context)!.($schema,$Context)/kk-history-mitglieder[kk=$kk-id]
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

(: Beware, this is the context switch. We are in "no" Context and switch to "kk" context :)
declare %plugin:provide("schema/render/button/modal/edit/link")
function _:kk-kam-top-4-render-button-page-edit-link($Item as element(), $Schema as element(schema), $Context as map(*))
as xs:string
{
let $context := $Context => map:get("context")
let $kk-id := $Context("kk")
return
    if ($kk-id)
        then "schema/form/modal/"||$Item/@id||"?provider="||$Schema/@provider/string()||"&amp;context="||$context||"&amp;kk="||$kk-id
        else "schema/form/modal/"||$Item/@id||"?provider="||$Schema/@provider/string()||"&amp;context="||$context
};

