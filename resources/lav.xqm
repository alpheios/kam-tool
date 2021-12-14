module namespace _ = "sanofi/lav";

(: import repo modules :)
import module namespace global	= "influx/global";
import module namespace plugin	= "influx/plugin";
import module namespace db	    = "influx/db";
import module namespace ui =" influx/ui";
import module namespace common  = "sanofi/common" at "common.xqm";
import module namespace import = "influx/modules";
import module namespace alert="influx/ui/alert";


declare namespace xhtml="http://www.w3.org/1999/xhtml";

declare variable $_:kv-bezirk := plugin:lookup("plato/schema/enums/get")!.("KV-Bezirke");
declare variable $_:ns := namespace-uri(<_:ns/>);

declare %plugin:provide('side-navigation-item')
  function _:nav-item-stammdaten-lav()
  as element(xhtml:li) {
  <li xmlns="http://www.w3.org/1999/xhtml" data-parent="/" data-sortkey="AAA">
      <a href="{$global:servlet-prefix}/schema/list/items?context=lav&amp;provider=sanofi/lav&amp;contextType=page"><i class="fa fa-eyedropper"></i> <span class="nav-label">Landes-Apotheker-Vereine/Verbände</span></a>
  </li>
};


declare %plugin:provide('ui/page/title') function _:heading($m){_:schema-default()//*:title/string()};
declare %plugin:provide("ui/page/content") function _:ui-page-content($m){common:ui-page-content($m)};
declare %plugin:provide("ui/page/heading") function _:ui-page-heading($m){common:ui-page-heading($m)};

declare
    %plugin:provide("schema/render/new")
    %plugin:provide("schema/render/new","lav")
function _:management-summary-render-new(
  $Item as element(lav), 
  $Schema as element(schema), 
  $Context as map(*)
) {
    (
        alert:info("Neue LAV angelegt.")
        ,plugin:default("schema/render/new")!.($Item,$Schema,$Context)
    )
};

declare %plugin:provide("schema/process/table/items","lav")
function _:schema-render-table-prepare-rows-jf($Items as element()*, $Schema as element(schema),$Context as map(*))
{
for $item in $Items order by $item/land return $item
};

declare %plugin:provide("schema/set/elements","lav")
function _:schema-column-filter($Item as element()*, $Schema as element(schema), $Context as map(*)){
    let $columns := plugin:lookup("plato/schema/columns/get")!.("lav")
    let $schema := $Schema update delete node ./*:element
    let $elements-in-order := for $name in $columns return $Schema/element[@name=$name]
    let $schema := $schema update insert node $elements-in-order as last into .
    return $schema
};

declare %plugin:provide("schema") function _:schema-default()
as element(schema){
<schema xmlns="" name="lav" domain="sanofi" provider="sanofi/lav">
    <modal>
        <title>Landes-Apotheker Vereinigung/Vereine</title>
    </modal>
    <element name="name" type="text">
        <label>Name:</label>
    </element>
    <element name="verantwortlich" type="foreign-key" required="" async="" minimumInputLength="0">
                <provider>sanofi/key-accounter</provider>
                <key>@id</key>
                <display-name>name/string()</display-name>
                <label>Zuständig</label>
                <class>col-md-6</class>
                <query><![CDATA[let $lav := collection('datastore-sanofi-lav')/lav[@id=$context-item-id]
                  let $key-accounter := collection('datastore-sanofi-key-accounter')/key-accounter
                  let $selected := $key-accounter[@id=$lav/key-accounter/key]
return (
  $selected ! <element id="{./@id/string()}" selected="true">{string-join((./name,./vorname)," - ")}</element> 
  ,$key-accounter ! <element id="{./@id/string()}" selected="true">{string-join((./name,./vorname)," - ")}</element> 
)]]></query>
    </element>
    <element name="kv-bezirk" type="enum" required="">
            {$_:kv-bezirk ! <enum key="{.}">{.}</enum>}
            <label>KV Bezirk</label>
        </element>
    <element name="ansprechpartner" type="foreign-key" render="table" required="">
            <provider>sanofi/ansprechpartner</provider>
            <key>lav</key>
            <label>Ansprechpartner</label>
            <display-name>string-join((vorname/string(), " ",name/string()))</display-name>
    </element>
    <element name="notizen" type="html">
        <label>Link</label>
    </element>
</schema>
};

declare %plugin:provide("schema/ui/page/content")
function _:render-page-form($Item as element()?, $Schema as element(schema), $Context)
{
let $form-id := "id-"||random:uuid()
let $title := $Schema/*:modal/*:title/string()
let $provider := $Schema/@provider
let $context := "lav"
let $Context := $Context=>map:put("lav",$Item/@id/string())
                        =>map:put("provider",$provider)

return

       <div xmlns="http://www.w3.org/1999/xhtml" class="tabs-container">
          <ul class="nav nav-tabs">
              <li class="active"><a data-toggle="tab" href="#tab-1">Stammdaten</a></li>
              <li class=""><a data-toggle="tab" href="#tab-5">Verträge</a></li>
          </ul>
          <div class="tab-content">
              <div id="tab-1" class="tab-pane active">
                  <div class="panel-body">
                     {plugin:provider-lookup($provider,"schema/render/page/form", $context)!.($Item,$Schema,$Context)}
                  </div>
              </div>
              <div id="tab-5" class="tab-pane">
                  <div class="panel-body">
                    {
                        let $provider := "sanofi/vertrag"
                        let $context := "lav"
                        let $schema := plugin:provider-lookup($provider,"schema",$context)!.()
                        let $Context := $Context =>map:put("provider",$provider)
                                                 =>map:put("context-provider",$_:ns)
                                                 =>map:put("context-item", $Item)
                                                 =>map:put("schema",$schema)
                                                 =>map:put("context-schema",$Schema)
                        let $items := db:eval("collection('datastore-sanofi-vertrag')/vertrag")
                        return
                        plugin:provider-lookup($provider,"content/view/context",$context)!.($items,$schema,$Context)
                    }
                  </div>
              </div>
          </div>
      </div>

 };