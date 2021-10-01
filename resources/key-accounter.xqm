module namespace _ = "sanofi/key-accounter";

(: import repo modules :)
import module namespace global	= "influx/global";
import module namespace plugin	= "influx/plugin";
import module namespace ui =" influx/ui";
import module namespace user="influx/user";


declare namespace xhtml="http://www.w3.org/1999/xhtml";

declare variable $_:interessen := plugin:lookup("plato/schema/enums/get")!.("Interessen");

declare %plugin:provide('side-navigation-item')
  function _:nav-item-stammdaten-key-accounter()
  as element(xhtml:li) {
  <li xmlns="http://www.w3.org/1999/xhtml" data-parent="/schema/list/items" data-sortkey="ZZZ">
      <a href="{$global:servlet-prefix}/schema/list/items?context=stammdaten/key-accounter&amp;provider=sanofi/key-accounter"><i class="fa fa-male"></i> <span class="nav-label">Key Accounter</span></a>
  </li>
};

(: adapter for ui:page to schema title :)
declare %plugin:provide("ui/page/title")
function _:page-title($map as map(*))
as xs:string{
 _:schema()/modal/title/string()
};

declare %plugin:provide("ui/page/heading/breadcrumb")
function _:page-breadcrumb($Context as map(*))
as element(xhtml:ol){
let $context := $Context("context")
let $provider := $Context("provider")
return
  <ol xmlns="http://www.w3.org/1999/xhtml" class="breadcrumb">
      <li>
        <a href="javascript:window.history.back()">Zurück</a>
      </li>
      <li class="active">
        <a href="{rest:base-uri()}/schema/list/items?provider={$provider}&amp;context={$context}">Übersicht</a>
      </li>
    </ol>
};

declare %plugin:provide("schema/render/modal/debug/itemXXX") function _:debug-kv ($Item,$Schema,$Context){
<pre>{serialize($Item)}</pre>
};

(: provide sorting for items :)
declare %plugin:provide("schema/process/table/items")
function _:schema-render-table-prepare-rows(
  $Items as element()*, 
  $Schema as element(schema),
  $Context as map(*)
) {
  for $item in $Items order by $item/name, $item/priority return $item
};

declare %plugin:provide("schema/set/elements")
function _:schema-render-table-prepare-rows-only-name($Items as element()*, $Schema as element(schema),$Context as map(*)){
    let $columns := plugin:lookup("plato/schema/columns/get")!.("key-accounter")
    let $schema := $Schema update delete node ./*:element
    let $elements-in-order := for $name in $columns return $Schema/element[@name=$name]
    let $schema := $schema update insert node $elements-in-order as last into .
    return $schema};

declare %plugin:provide("schema") function _:schema()
as element(schema){
<schema xmlns="" name="key-accounter" domain="sanofi" provider="sanofi/key-accounter">
    <modal>
        <title>Key-Accounter</title>
    </modal>
    <element name="interessen" type="enum">
        {$_:interessen ! <enum key="{.}">{.}</enum>}
        <label>Interessen/Alerts</label>
    </element>
    <element name="name" type="text">
        <label>Anzeigename</label>
    </element>
    <element name="vorname" type="text">
        <label>Vorname</label>
    </element>
    <element name="nachname" type="text">
        <label>Nachname</label>
    </element>
    <element name="notizen" type="textarea">
         <label>Link</label>
     </element>
     <element name="role" type="enum">
        <label>Rolle</label>
        {("admin","user") ! <enum key="{.}">{.}</enum>}
      </element>
      <element name="username" type="enum">
        <label>User</label>
        {user:list()! <enum key="{.}">{.}</enum>}
      </element>
 </schema>
};


(: Security :)
declare %plugin:provide("schema/security")
function _:schema-security($Item as element()*, $Schema as element(schema)*, $Context as map(*))
as xs:boolean
{
  user:is-admin()
};

declare %plugin:provide("schema/render/button/modal/new")
function _:schema-render-button-modal-new($Schema as element(schema), $Context as map(*))
as element()*
{
let $context := $Context("context")
let $provider := $Schema/@provider/string()
let $link := plugin:provider-lookup($provider,"schema/render/button/modal/new/link",$context)!.($Schema,$Context)
return
    if (user:is-admin())
    then ui:modal-button(<a class="btn btn-sm"><span class="fa fa-plus"/></a>,$link)
};

(::: Remove Buttons from modal if key-accounter details are opened from table-view :::)
declare %plugin:provide("schema/render/modal/form/buttons", "stammdaten/kk")
        %plugin:provide("schema/render/modal/form/buttons", "kv") (: Gucken ob der Kontext hier wirklich kv bleibt oder sich das noch ändert:)
        %plugin:provide("schema/render/modal/form/buttons", "stammdaten/lav")
function _:remove-buttons-from-modal(
  $Item as element(), 
  $Schema as element(schema), 
  $Context as map(*)
) {
  ()
};

(:
ui:modal-button('schema/form/modal?provider='||$provider||"&amp;context="||$context||"&amp;context-item-id="||$context-item-id||"&amp;context-provider="||$context-provider,<a xmlns="http://www.w3.org/1999/xhtml" shape="rect" class="btn btn-sm btn-outline"><span class="fa fa-plus"/></a>)
:)