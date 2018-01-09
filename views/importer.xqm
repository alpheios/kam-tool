module namespace _="sanofi/views/importer";

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
  <li xmlns="http://www.w3.org/1999/xhtml" data-parent="/" data-sortkey="AA1">
      <a href="{$global:servlet-prefix}/sanofi/importer"><i class="fa fa-area-chart"></i> <span class="nav-label">Importer</span></a>
  </li>
};

declare %plugin:provide("ui/page/content","sanofi/importer")
function _:sanofi-importer($map as map(*))
as element(xhtml:div)
{
let $title := $map => map:get("title")
let $benutzer-csv := file:read-text('webapp/influx_app/modules/kam-tool/static/kam-benutzer.csv')
return
<div xmlns="http://www.w3.org/1999/xhtml" class="content-with-sidebar row">
  <div class="row">
      <div class="col-lg-12 col-md-12">
          <div class="ibox float-e-margins">
              <div class="ibox-title">
                  <h5>Benutzer importieren</h5>
              </div>
              <div class="ibox-content">
              <pre>
                {
                 for $line in csv:parse($benutzer-csv, map { 'separator': ';' })/*:csv/*:record
                 let $vorname := $line/*:entry[1]
                 let $nachname := $line/*:entry[2]
                 let $username := $line/*:entry[3]
                 return <div class="col-md-4">{$username}</div>
                }
                </pre>
              </div>
          </div>
      </div>
    </div>
</div>
};





