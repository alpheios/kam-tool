module namespace _="sanofi/views/choose-columns";

import module namespace i18n = 'influx/i18n';
import module namespace global ='influx/global';
import module namespace ui='influx/ui';
import module namespace plugin='influx/plugin';

declare namespace xhtml = "http://www.w3.org/1999/xhtml";
declare namespace mod="http://influx.adesso.de/module";

declare variable $_:meta := doc("../../module.xml")/mod:module;
declare variable $_:module-static := $global:module-path||"/"||$_:meta/mod:install-path||"/static";
declare variable $_:entities-path := file:base-dir()||"/entities/entities.csv";

declare %plugin:provide('side-navigation-item')
        %plugin:allow("admin")
  function _:nav-item-kam()
  as element(xhtml:li) {
  <li xmlns="http://www.w3.org/1999/xhtml" data-parent="/admin" data-sortkey="M">
      <a href="{$global:servlet-prefix}/admin/sanofi/choose-columns"><i class="fa fa-list-alt"></i> <span data-i18n="side-navigation-choose-columns" class="nav-label">Spalten festlegen</span></a>
  </li>
};

declare %plugin:provide("ui/page/custom-js","sanofi/choose-columns")
function _:page-custom-js($map){  
  <script type="text/javascript" src="{$_:module-static}/js/choose-columns.js"></script>
};

declare function _:read-entities() {
  let $entities := csv:parse(file:read-text($_:entities-path), map {
      'separator': ';',
      'header': true()
    })/*:csv/*:record

  return $entities
};

declare %plugin:provide("ui/page/content","sanofi/choose-columns")
function _:sanofi-choose-columns(
  $map as map(*)
) as element(xhtml:div) {

  <div xmlns="http://www.w3.org/1999/xhtml" class="content-with-sidebar row">
    <div class="row">
        <div class="col-lg-12 col-md-12">
            <div class="ibox float-e-margins">
                <div class="ibox-title">
                    <h5>Spalten für Listendarstellungen festlegen</h5>
                </div>
                <div class="ibox-content">
                    <div class="m-b">
                      <label for="felder">Entitäten:</label>
                      <select class="form-control" id="felder" onchange="replaceValueEditor('{$global:servlet-prefix}', this)">
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
                    <div class="m-b" id="editor-area">
                    </div>
                </div>
            </div>
        </div>
      </div>
  </div>
};