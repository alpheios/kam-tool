module namespace _ = "sanofi/glossar";
import module namespace common  = "sanofi/common" at "common.xqm";
import module namespace alert="influx/ui/alert";

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
   <element name="begriff" type="text">
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

(: wird nur gebraucht, damit anstelle des "name" "begriff" angezeigt wird. :)

declare %plugin:provide("schema/render/modal/form")
function _:render-modal-form(
  $Item as element()?, 
  $Schema as element(schema), 
  $ContextMap as map(*)
) as element(xhtml:div) {
  let $context-title := 
      if ($ContextMap?context-item and ($ContextMap?context-item/@id != $Item/@id)) 
      then $ContextMap?context-item/name/string()
      else $Item/begriff/string()
  let $modal-title := $context-title || ": " || $Schema/*:modal/*:title/string()
  let $form-id := "id-"||random:uuid()
  let $context-item := $ContextMap?context-item
  let $ContextMap := map:put($ContextMap,"form-id",$form-id)
  let $ContextMap := $ContextMap => map:put("modal",$ContextMap?modal)
  return
  <div xmlns="http://www.w3.org/1999/xhtml" class="modal-content">
     <div class="modal-header">
       <button type="button" class="btn btn-sm btn-white pull-right" data-dismiss="modal"><i class="fa fa-times"></i></button>
       <h2 class="modal-title" data-i18n="new-item-title">{$modal-title}</h2>

      {plugin:provider-lookup($ContextMap?provider,"schema/render/modal/debug/item",$ContextMap?context)!.($Item,$Schema,$ContextMap)}
     </div>
    <div class="modal-body clearfix">
        {plugin:provider-lookup($ContextMap?provider,"schema/render/form",$ContextMap?context)!.($Item,$Schema,$ContextMap)}
    </div>
    {
      if ($ContextMap?mode="view")
      then ()
      else 
        <div class="modal-footer">
          {plugin:provider-lookup($ContextMap?provider,"schema/render/modal/form/buttons",$ContextMap?context)($Item, $Schema, $ContextMap)}
        </div>
    }
    {
    for $element in $Schema/element[@type] return plugin:provider-lookup($ContextMap?provider,"schema/render/form/field/upload",$ContextMap?context)!.($Item,$element,$ContextMap)
    }
 </div>
};
