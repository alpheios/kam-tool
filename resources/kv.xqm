module namespace _ = "sanofi/kv";

(: import repo modules :)
import module namespace global	= "influx/global";
import module namespace plugin	= "influx/plugin";
import module namespace db	    = "influx/db";
import module namespace ui =" influx/ui2";
import module namespace date-util ="influx/utils/date-utils";


declare namespace xhtml="http://www.w3.org/1999/xhtml";

declare variable $_:kv-bezirke := plugin:lookup("plato/schema/enums/get")!.("KV-Bezirke");

declare %plugin:provide('side-navigation')
  function _:nav-item-stammdaten-kv()
  as element(xhtml:li) {
  <li xmlns="http://www.w3.org/1999/xhtml" data-parent="/" data-sortkey="AAA">
      <a href="{$global:servlet-prefix}/schema/list/items?context=kv&amp;provider=sanofi/kv"><i class="fa fa-user-md"></i> <span class="nav-label">Kassenärztliche Vereinigungen</span></a>
  </li>
};

declare %plugin:provide("schema/render/modal/debug/itemXXX") function _:debug-kv ($Item,$Schema,$Context){
<pre>{serialize($Item)}</pre>
};


declare %plugin:provide("ui/page/content","stammdaten/kv")
function _:stammdaten-kv($map)
as element(xhtml:div)
{
<div xmlns="http://www.w3.org/1999/xhtml" class="content-with-sidebar row">
  <div class="row">
      <div class="col-lg-12">
            {plugin:lookup("schema/ibox/table")!.("sanofi/kv","stammdaten/kv")}
      </div>
  </div>
</div>
};

declare %plugin:provide("schema/process/table/items","stammdaten/kv")
function _:schema-render-table-prepare-rows-jf($Items as element()*, $Schema as element(schema),$Context as map(*))
{
for $item in $Items order by $item/land return $item
};

declare %plugin:provide("schema/set/elements","stammdaten/kv")
function _:schema-column-filter($Item as element()*, $Schema as element(schema), $Context as map(*)){
    let $columns := plugin:lookup("plato/schema/columns/get")!.("kv")
    let $schema := $Schema update delete node ./*:element
    let $elements-in-order := for $name in $columns return $Schema/element[@name=$name]
    let $schema := $schema update insert node $elements-in-order as last into .
    return $schema
};

declare %plugin:provide("schema") function _:schema2()
as element(schema){
<schema xmlns="" name="kv" domain="sanofi" provider="sanofi/kv">
    <modal>
        <title>Kassenärztliche Vereinigung</title>
    </modal>
    <element name="name" type="enum">
        {$_:kv-bezirke ! <enum key="{.}">{.}</enum>}
        <label>Name</label>
    </element>
    <element name="verantwortlich" type="foreign-key" required="">
                <provider>sanofi/key-accounter</provider>
                <key>@id/string()</key>
                <display-name>name/string()</display-name>
                <label>Zuständig</label>
                <class>col-md-6</class>
    </element>
    <element name="ansprechpartner" type="foreign-key" render="table" required="">
            <provider>sanofi/ansprechpartner</provider>
            <key>kv</key>
            <label>Ansprechpartner</label>
            <display-name>string-join((vorname/string(), " ",name/string()))</display-name>
    </element>
    <element name="notizen" type="html">
        <label>Notizen</label>
    </element>
</schema>
};

declare %plugin:provide("profile/dashboard/widget")
function _:profile-dashboard-widget-kv($Profile as element())
{

    let $context := map{}
    let $schema := plugin:provider-lookup("sanofi/kv","schema")!.()
    let $items  := plugin:provider-lookup("sanofi/kv","datastore/dataobject/all")!.($schema,$context)
    let $items  := $items[*:verantwortlich=$Profile/@id/string()]
    return
        if (count($items)>0) then
        <div class="col-md-6">
         {plugin:lookup("schema/render/table/page")!.($items,$schema,$context)}
        </div>
        else ()
};

declare %plugin:provide("schema/ui/page/content","kv")
function _:render-page-form($Item as element()?, $Schema as element(schema), $Context)
{
let $form-id := "id-"||random:uuid()
let $title := $Schema/*:modal/*:title/string()
let $provider := $Schema/@provider
let $context:=$Context("context")
let $context-item-id:=$Context("context-item")/@id
return
<div xmlns="http://www.w3.org/1999/xhtml" class="content-with-sidebar row">
  <div class="ibox float-e-margins">
      <div class="tabs-container">
          <ul class="nav nav-tabs">
              <li class="active"><a data-toggle="tab" href="#tab-1">Formular</a></li>
              <li class=""><a data-toggle="tab" href="#tab-2">TOP 4</a></li>
              <li class=""><a data-toggle="tab" href="#tab-3">Blauer Ozean</a></li>
          </ul>
          <div class="tab-content">
              <div id="tab-1" class="tab-pane active">
                  <div class="panel-body">
                     {plugin:provider-lookup($provider,"schema/render/page/form")!.($Item,$Schema,$Context)}
                  </div>
              </div>
              <div id="tab-2" class="tab-pane">
                  <div class="panel-body">
                    {plugin:provider-lookup("sanofi/views/kam-top-4-kv","content/view")!.($Item,$Schema,$Context)}
                  </div>
              </div>
              <div id="tab-3" class="tab-pane">
                  <div class="panel-body">
                    {
                    let $provider := "sanofi/blauer-ozean"
                    let $schema := plugin:provider-lookup($provider,"schema",$context)!.()
                    let $blauer-ozean-items :=
                        for $item in plugin:provider-lookup($provider,"datastore/dataobject/field",$context)!.("kv",$context-item-id,$schema,$Context)
                        let $date := $item/@last-modified-date
                        order by $date descending
                        return $item
                    let $blauer-ozean-item-latest := $blauer-ozean-items[1]
                    return
                        plugin:provider-lookup($provider,"content/view/context",$context)!.($blauer-ozean-item-latest,$schema,$Context)
                    }
                  </div>
              </div>
          </div>
      </div>
  </div>
 </div>
 };