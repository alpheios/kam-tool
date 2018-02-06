module namespace _ = "sanofi/kk-history-zusatzbeitrag";

(: import repo modules :)
import module namespace global	= "influx/global";
import module namespace plugin	= "influx/plugin";
import module namespace db	    = "influx/db";
import module namespace ui =" influx/ui2";

declare namespace xhtml="http://www.w3.org/1999/xhtml";


declare %plugin:provide("schema/render/page/debug/itemXXX") function _:debug-kk ($Item,$Schema,$Context){
<pre>{serialize($Item)}</pre>
};

declare %plugin:provide("schema/process/table/items","kk")
function _:schema-render-table-prepare-rows-jf($Items as element()*, $Schema as element(schema),$Context as map(*))
{
for $item in $Items order by $item/date return $item
};

declare %plugin:provide("schema/set/elements","kk")
function _:schema-column-filter($Item as element()*, $Schema as element(schema), $Context as map(*)){
    let $columns := ("name","datum","zusatzbeitrag")
    let $schema := $Schema update delete node ./*:element
    let $elements-in-order := for $name in $columns return $Schema/element[@name=$name]
    let $schema := $schema update insert node $elements-in-order as last into .
    return $schema
};

declare %plugin:provide("schema/render/form/field/foreign-key","kk") (: Achtung: "kk" ist hier nicht der Kontext, sondern der Feldname! :)
function _:sanofi-kk-history-zusatzbeitrag-kk-input($Item as element(kk-history-zusatzbeitrag), $Element as element(element), $Context as map(*))
as element()?
{
    let $kk-id := $Context("item")/@id/string()
    return <input xmlns="http://www.w3.org/1999/xhtml" name="kk" value="{$kk-id}" type="hidden"/>
};

declare %plugin:provide("schema/render/form/field/label","kk") (: Achtung: "kk" ist hier nicht der Kontext, sondern der Feldname! :)
function _:sanofi-kk-history-zusatzbeitrag-kk-input-label($Item as element(kk-history-zusatzbeitrag), $Element as element(element), $Context as map(*))
as element()?
{
    (: Label für Feld "kk" löschen :)
};



declare %plugin:provide("schema/render/form/action","kk") function _:schema-render-form-action($Item as element(), $Schema as element(schema), $Context as map(*))
as xs:string{
let $provider := $Schema/@provider/string()
let $context := $Context("context")
let $kk-id := $Context("item")/@id/string()
return
string($global:servlet-prefix||"/datastore/dataobject/put/"||$Item/@id||"?provider="||$provider||"&amp;context="||$context||"&amp;context-item-id="||$kk-id)
};

declare %plugin:provide("schema/render/table/tbody/tr/actions","kk")
function _:schema-render-table-tbody-tr-td-actions($Item as element(), $Schema as element(schema), $Context as map(*))
as element(xhtml:td)
{
let $context := $Context => map:get("context")
let $provider := $Schema/@provider/string()
return
(:edit-button:) <td xmlns="http://www.w3.org/1999/xhtml">{plugin:provider-lookup($provider,"schema/render/button/modal/edit")!.($Item,$Schema,$Context)
}</td>
};

declare %plugin:provide("schema/render/table/page","kk")
function _:render-page-table($Items as element()*, $Schema as element(schema), $Context)
{
let $form-id := "id-"||random:uuid()
let $title := $Schema/*:modal/*:title/string()
let $provider := $Schema/@provider/string()
let $context := $Context("context")
let $kk := $Context("item")/@id/string()
let $modal-button := ui:modal-button('schema/form/modal?provider='||$provider||"&amp;context="||$context||"&amp;context-item-id="||$kk,<a xmlns="http://www.w3.org/1999/xhtml" shape="rect" class="btn btn-sm btn-outline"><span class="fa fa-plus"/></a>)
let $title := $Schema/modal/title/string()
return
<div xmlns="http://www.w3.org/1999/xhtml" class="ibox float-e-margins">
    <div class="ibox-title">
        <h5>{$title}</h5>
        <div class="ibox-tools">
        {$modal-button}
        </div>
    </div>
    <div class="ibox-content">
    {
        plugin:provider-lookup($provider,"schema/render/table",$context)!.($Items,$Schema,$Context)
     }
    </div>
</div>
 };


declare %plugin:provide("schema") function _:schema()
as element(schema){
<schema xmlns="" name="kk-history-zusatzbeitrag" domain="sanofi" provider="sanofi/kk-history-zusatzbeitrag">
    <modal>
        <title>KK Versicherte</title>
        <button>
            <add>hinzufügen</add>
            <cancel>abbrechen</cancel>
            <modify>ändern</modify>
            <delete>löschen</delete>
        </button>
    </modal>
    <element name="name" type="text">
        <label>Name</label>
    </element>
    <element name="datum" type="date" default="{date-util:current-date-to-html5-input-date()}">
        <label>Datum</label>
    </element>
    <element name="zusatzbeitrag" type="number">
        <label>Mitglieder Anzahl</label>
    </element>
    <element name="kk" type="foreign-key" required="">
            <provider>sanofi/kk</provider>
            <key>@id</key>
            <display-name>name/string()</display-name>
            <label>KK</label>
            <class>col-md-6</class>
    </element>
  </schema>
};


