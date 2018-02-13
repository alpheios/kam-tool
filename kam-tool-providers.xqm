module namespace _="sanofi/providers";

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
  <li xmlns="http://www.w3.org/1999/xhtml" data-parent="/" data-children="/schema/list/items" data-sortkey="AAA3">
      <a href="{$global:servlet-prefix}/schema/list/items"><i class="fa fa-book"></i> <span class="nav-label">Stammdaten</span><span class="fa arrow"></span></a>
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
                if ($key-accounter/username = plugin:lookup("username")!.() or plugin:lookup("is-admin")())
                then true()
                else false()
            else true()
};




declare %plugin:provide("ui/page/custom-css","profile")
function _:page-custom-css($map){
    <link xmlns="http://www.w3.org/1999/xhtml" href="{$global:inspinia-path}/css/plugins/select2/select2.min.css" rel="stylesheet"/>
};


declare %plugin:page("schema","list/items/{$arg1}") function _:test($req as map(*),$arg1){$arg1,$req("parameter")=>map:keys()};