module namespace _ = "sanofi/glossar";
import module namespace common  = "sanofi/common" at "common.xqm";

(: import repo modules :)
declare namespace plugin	= "influx/plugin";

declare namespace xhtml="http://www.w3.org/1999/xhtml";
declare variable $_:ns := namespace-uri(<_:ns/>);

(:
  Quote von Ärzten nach Fachrichtung je Regelung
:)

declare %plugin:provide('side-navigation-item')
  function _:nav-item-stammdaten-kk-fusioniert()
  as element(xhtml:li) {
  <li xmlns="http://www.w3.org/1999/xhtml" data-parent="/schema/list/items" data-sortkey="AAA">
      <a href="{rest:base-uri()}/schema/list/items?context=&amp;provider=sanofi/glossar&amp;contextType=page"><i class="fa fa-book"></i> <span class="nav-label">Glossar</span></a>
  </li>
};

declare %plugin:provide("datastore/name")
function _:datastore-name(
    $Schema as element(schema),
    $Context as map(*)
) as xs:string {
    'datastore-sanofi-glossar'
};

declare %plugin:provide("schema/ui/page/content")
function _:render-page-form($Item as element()?, $Schema as element(schema), $Context)
{
  plugin:provider-lookup($Context?provider,"schema/render/page/form")!.($Item,$Schema,$Context)  
};

declare %plugin:provide("schema/render/table/tbody/tr/actions")
function _:schema-render-table-tbody-tr-td-actions(
  $Item as element(), 
  $Schema as element(schema), 
  $ContextMap as map(*)
) as element(xhtml:td) {
    <td xmlns="http://www.w3.org/1999/xhtml">{plugin:provider-lookup($_:ns,"schema/render/button/modal/edit")!.($Item,$Schema,$ContextMap)}</td>
};


declare %plugin:provide('ui/page/title') function _:title($m){_:schema()//*:title/string()};
declare %plugin:provide("ui/page/content") function _:ui-page-content($m){common:ui-page-content($m)};
declare %plugin:provide("ui/page/heading") function _:ui-page-heading($m){common:ui-page-heading($m)};


declare %plugin:provide("schema") function _:schema()
as element(schema){
<schema xmlns="" name="glossar" domain="sanofi" provider="sanofi/glossar">
    <modal>
        <title>Glossar</title>
    </modal>
   <element name="name" type="text">
      <label>Begriff</label>
    </element> 
    <element name="beschreibung" type="html">
        <label>Beschreibung</label>
    </element>
    <element name="datum" type="date">
        <label>Datum</label>
    </element>
    <element name="link" type="link" default="https://">
         <label>Link (https://) </label>
    </element>
  </schema>
};


