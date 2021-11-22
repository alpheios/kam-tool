module namespace _="sanofi/views/choose-columns";

import module namespace i18n = 'influx/i18n';
import module namespace global ='influx/global';
import module namespace ui='influx/ui';
import module namespace plugin='influx/plugin';
import module namespace common="sanofi/common/view" at "../common.xqm";
import module namespace import="influx/modules";

declare namespace xhtml = "http://www.w3.org/1999/xhtml";
declare namespace mod="http://influx.adesso.de/module";

declare variable $_:meta := doc("../../module.xml")/mod:module;
declare variable $_:module-static := $global:module-path||"/"||$_:meta/mod:install-path||"/static";
declare variable $_:entities-path := file:base-dir()||"/entities/entities.csv";
declare variable $_:ns := namespace-uri(<_:ns/>);
declare %plugin:provide("ui/page/heading") function _:ui-page-heading($m){common:ui-page-heading($m)};

declare %plugin:provide('side-navigation-item')
        %plugin:allow("admin")
  function _:nav-item-kam()
  as element(xhtml:li) {
  <li xmlns="http://www.w3.org/1999/xhtml" data-parent="/admin" data-sortkey="M">
      <a href="{$global:servlet-prefix}/admin/api/page?provider={$_:ns}"><i class="fa fa-list-alt"></i> <span data-i18n="side-navigation-choose-columns" class="nav-label">Spalten festlegen</span></a>
  </li>
};

 
declare %plugin:provide("ui/page/custom-js")
function _:page-custom-js($map){  
plugin:provider-lookup(plugin:lookup("editor/code")=>plugin:provider(),"ui/page/custom-js")!.($map)
,
<script type="text/javascript" src="{$_:module-static}/js/choose-columns.js"></script>
};
  

declare function _:read-entities() {
  let $entities := csv:parse(file:read-text($_:entities-path), map {
      'separator': ';',
      'header': true()
    })/*:csv/*:record

  return $entities
};

declare %plugin:provide("ui/page/content")
function _:sanofi-choose-columns(
  $map as map(*)
) as element(xhtml:div) {
<div class="ibox float-e-margins" xmlns="http://www.w3.org/1999/xhtml">
    <div class="ibox-title">
        <h2>Spalten für Listendarstellungen festlegen</h2>
    </div>
    <div class="ibox-content">
        <div class="m-b">
          <label for="felder">Entitäten:</label>
          <select class="form-control select2" id="felder" onchange="replaceValueEditor('{$global:servlet-prefix}', this)">
          <option disabled="" selected="">Wähle ein Auswahlfeld</option>
          {
            let $eintraege := _:read-entities()
            return
              for $eintrag in $eintraege
              order by $eintrag/*:label/string()
              return <option value="{$eintrag/*:provider/string()}">{$eintrag/*:label/string()}</option>
          }
          </select>
        </div>
        <script>$(".select2").select2()</script>
        <div class="m-b" id="editor-area">
        </div>
    </div>
</div>
};