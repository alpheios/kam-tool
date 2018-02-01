module namespace _="sales-management/providers";

import module namespace i18n = 'influx/i18n';
import module namespace global ='influx/global';
import module namespace db = "influx/db";
import module namespace ui='influx/ui2';
import module namespace plugin='influx/plugin';
import module namespace rest = "http://exquery.org/ns/restxq";
import module namespace request = "http://exquery.org/ns/request";

declare namespace xhtml = "http://www.w3.org/1999/xhtml";
declare namespace mod="http://influx.adesso.de/module";

declare %plugin:provide('side-navigation')
  function _:nav-item-stammdaten()
  as element(xhtml:li) {
  <li xmlns="http://www.w3.org/1999/xhtml" data-parent="/" data-children="/schema/list/items" data-sortkey="AA3">
      <a href="{$global:servlet-prefix}/schema/list/items"><i class="fa fa-gears"></i> <span class="nav-label">Stammdaten</span><span class="fa arrow"></span></a>
  </li>
};

declare %plugin:provide('i18n/translations')
function _:translations(){doc('translations.xml')};







