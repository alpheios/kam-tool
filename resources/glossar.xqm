module namespace _ = "sanofi/glossar";
import module namespace import ="influx/modules";

(: import repo modules :)
declare namespace plugin	= "influx/plugin";

declare namespace xhtml="http://www.w3.org/1999/xhtml";
import module namespace common  = "sanofi/common" at "common.xqm";

(:
  Quote von Ärzten nach Fachrichtung je Regelung
:)

declare %plugin:provide('side-navigation-item')
  function _:nav-item-stammdaten-kk-fusioniert()
  as element(xhtml:li) {
  <li xmlns="http://www.w3.org/1999/xhtml" data-parent="/schema/list/items" data-sortkey="AAA">
      <a href="{rest:base-uri()}/schema/list/items?context=&amp;provider=sanofi/glossar"><i class="fa fa-book"></i> <span class="nav-label">Glossar</span></a>
  </li>
};

declare %plugin:provide("schema/render/page/debug/itemXXX") function _:debug-kk ($Item,$Schema,$Context){
<pre>{serialize($Item)}</pre>
};

declare %plugin:provide("datastore/name")
function _:datastore-name(
    $Schema as element(schema),
    $Context as map(*)
) as xs:string {
    'datastore-sanofi-glossar'
};

declare %plugin:provide('ui/page/title') function _:heading($m){_:schema()//*:title/string()};
declare %plugin:provide("ui/page/content") function _:ui-page-content($m){common:ui-page-content($m)};
declare %plugin:provide('ui/page/heading/breadcrumb') function _:breadcrumb($m){common:breadcrumb($m)};


declare %plugin:provide("schema") function _:schema()
as element(schema){
<schema xmlns="" name="glossar" domain="sanofi" provider="sanofi/glossar">
    <modal>
        <title>Glossar</title>
    </modal>
   <element name="begriff" type="text">
      <label>Begriff</label>
    </element> 
    <element name="beschreibung" type="html">
        <label>Beschreibung</label>
    </element>
    <element name="datum" type="date">
        <label>Datum</label>
    </element>
    <element name="link" type="textarea" default="https://">
         <label>Link (https://) </label>
    </element>
  </schema>
};


