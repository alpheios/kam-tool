module namespace _ = "sanofi/stakeholder";

(: import repo modules :)
import module namespace global	= "influx/global";
import module namespace plugin	= "influx/plugin";
import module namespace db	    = "influx/db";
import module namespace ui =" influx/ui2";

declare namespace xhtml="http://www.w3.org/1999/xhtml";


declare %plugin:provide('side-navigation')
  function _:nav-item-stammdaten-stakeholdere()
  as element(xhtml:li) {
  <li xmlns="http://www.w3.org/1999/xhtml" data-parent="/sanofi/stammdaten" data-sortkey="ZZZ">
      <a href="{$global:servlet-prefix}/sanofi/stammdaten/stakeholder"><i class="fa fa-cubes"></i> <span class="nav-label">Stakeholder</span></a>
  </li>
};

declare %plugin:provide("ui/page/content","stammdaten/stakeholder")
function _:stammdaten($map)
as element(xhtml:div)
{
<div xmlns="http://www.w3.org/1999/xhtml" class="content-with-sidebar row">
  <div class="row">
      <div class="col-lg-12">
            {plugin:lookup("schema/ibox/table")!.("sanofi/stakeholder","stammdaten/stakeholder")}
      </div>
  </div>
</div>
};


(: provide sorting for items :)
declare %plugin:provide("schema/process/table/items")
function _:schema-render-table-prepare-rows($Items as element()*, $Schema as element(schema),$Context as map(*)){for $item in $Items order by $item/name, $item/priority return $item};

declare %plugin:provide("schema/set/elements")
function _:schema-render-table-prepare-rows-only-name($Items as element()*, $Schema as element(schema),$Context as map(*)){
    let $columns := ("ansprechpartner","produkt","einfluss")
    let $schema := $Schema update delete node ./*:element
    let $elements-in-order := for $name in $columns return $Schema/element[@name=$name]
    let $schema := $schema update insert node $elements-in-order as last into .
    return $schema};

declare %plugin:provide("schema") function _:schema-customer()
as element(schema){
<schema xmlns="" name="stakeholder" domain="sanofi" provider="sanofi/stakeholder">
    <modal>
        <title>Stakeholder</title>
        <button>
            <add>hinzufügen</add>
            <cancel>abbrechen</cancel>
            <modify>ändern</modify>
            <delete>löschen</delete>
        </button>
    </modal>
    <element name="name" type="text">
        <label>Name/Position</label>
    </element>
    <element name="ansprechpartner" type="foreign-key" required="">
            <provider>sanofi/ansprechpartner</provider>
            <key>@id</key>
            <display-name>name/string()</display-name>
            <label>Ansprechpartner</label>
            <class>col-md-6</class>
        </element>
      <element name="kv" type="foreign-key" required="">
                 <provider>sanofi/kv</provider>
                 <key>@id</key>
                 <display-name>name/string()</display-name>
                 <label>KV</label>
                 <class>col-md-6</class>
      </element>
       <element name="produkt" type="foreign-key" required="">
                  <provider>sanofi/produkt</provider>
                  <key>@id</key>
                  <display-name>name/string()</display-name>
                  <label>Produkt</label>
                  <class>col-md-6</class>
       </element>
     <element name="einfluss" type="text">
         <label>Einfluss</label>
     </element>
 </schema>
};

declare %plugin:provide("content/view")
function _:sanofi-stakeholder($Item as element()*,$Schema as element(schema), $Context)
as element(xhtml:div)
{
let $id := $Item/@id/string()
let $provider := "sanofi/stakeholder"
let $context := map{"context":"sanofi/stakeholder"}
let $projekt-schema := plugin:provider-lookup("sanofi/projekt","schema")!.()
let $kk-schema := plugin:provider-lookup("sanofi/kk","schema")!.()
let $kks := plugin:provider-lookup("sanofi/kk","datastore/dataobject/all")!.($kk-schema,$context)
let $kk := plugin:provider-lookup("sanofi/projekt","datastore/dataobject")!.($id,$kk-schema,$context)
let $projekte := plugin:provider-lookup("sanofi/projekt","datastore/dataobject/all")!.($projekt-schema,$context)[kk=$id]
let $edit-button := try {plugin:provider-lookup($provider,"schema/render/button/modal/edit")!.($Item,$Schema,$Context)} catch * {}
let $add-button := ui:modal-button('schema/form/modal?provider='||$provider||"&amp;context=modal&amp;kk="||$id,<a xmlns="http://www.w3.org/1999/xhtml" shape="rect" class="btn btn-sm btn-outline"><span class="fa fa-plus"/></a>)
return
<div xmlns="http://www.w3.org/1999/xhtml">
    {plugin:provider-lookup($provider,"schema/ibox/table")!.($provider,"")}
</div>
};
