module namespace _="sanofi/providers";

import module namespace i18n = 'influx/i18n';
import module namespace global ='influx/global';
import module namespace db = "influx/db";
import module namespace plugin='influx/plugin';
import module namespace rest = "http://exquery.org/ns/restxq";
import module namespace request = "http://exquery.org/ns/request";
import module namespace user="influx/user";

declare namespace xhtml = "http://www.w3.org/1999/xhtml";
declare namespace mod="http://influx.adesso.de/module";


declare %plugin:provide-default('ui/page/logo') function _:page-logo(
    $Params as map(*)
) as element(xhtml:img)* {
<img src="/influx_app/modules/kam-tool/static/Sanofi_2011_logo.svg.png" xmlns="http://www.w3.org/1999/xhtml" width="60%" style="position:absolute;left:35px"/>
};

declare %plugin:provide('should/have/navbar/sidenav')
  function _:use-side-nav($map){true()};
declare %plugin:provide('should/have/navbar/topnav')
  function _:use-top-nav($map){false()};
  
declare %plugin:provide('side-navigation-item')
  function _:nav-item-kv()
  as element(xhtml:li)* {
    if (plugin:lookup('should/have/navbar/topnav')!.(map{})) then
  <li xmlns="http://www.w3.org/1999/xhtml" data-parent="/" data-children="/kaiman" data-sortkey="   A">
      <a href="{$global:servlet-prefix}/kaiman"><i class="fa fa-book"></i> <span class="nav-label">Kaiman</span></a>
  </li>
};

declare %plugin:provide('side-navigation-item')
  function _:nav-items()
  as element(xhtml:li)+ {
    for $i in ("kv","kk") return
  <li xmlns="http://www.w3.org/1999/xhtml" data-parent="/kaiman" data-sortkey="AAA{$i}">
      <a href="{rest:base-uri()}/schema/list/items?provider=sanofi/{$i}&amp;context={$i}"><i class="fa fa-book"></i> <span class="nav-label">{$i}</span></a>
  </li>
};


declare %plugin:provide('side-navigation-item')
  function _:nav-item-stammdaten()
  as element(xhtml:li) {
  <li xmlns="http://www.w3.org/1999/xhtml" data-parent="/" data-children="/schema/list/items" data-sortkey="AAA4">
      <a href="{$global:servlet-prefix}/schema/list/items"><i class="fa fa-book"></i> <span class="nav-label">Stammdaten</span></a>
  </li>
};

declare %plugin:provide('side-navigation-item')
  function _:nav-item-stammdaten-fusioniert()
  as element(xhtml:li) {
  <li xmlns="http://www.w3.org/1999/xhtml" data-parent="/" data-children="/schema/list/items/fusioniert" data-sortkey="ZZZ3">
      <a href="{$global:servlet-prefix}/schema/list/items"><i class="fa fa-compress"></i> <span class="nav-label">Fusionierte Kassen</span></a>
  </li>
};

declare %plugin:provide('i18n/translations')
function _:translations(){doc('translations.xml')};


declare %plugin:provide-default("schema/security")
function _:schema-security($Item as element()*, $Schema as element(schema)*, $Context as map(*))
as xs:boolean
{
    let $context := $Context("context")
    let $verantwortlich := $Item/verantwortlich
    return
        if ($verantwortlich)
            then
                let $key-accounter-schema := plugin:provider-lookup("sanofi/key-accounter","schema",$context)!.()
                let $key-accounter := plugin:provider-lookup("sanofi/key-accounter","datastore/dataobject",$context)!.($verantwortlich,$key-accounter-schema,$Context)
                return
                if ($key-accounter/username = user:current() or user:is-admin())
                then true()
                else false()
            else true()
};

declare %plugin:page("schema","list/items/{$arg1}") function _:test($req as map(*),$arg1){$arg1,$req("parameter")=>map:keys()};