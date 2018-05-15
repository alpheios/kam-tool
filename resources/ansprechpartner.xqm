module namespace _ = "sanofi/ansprechpartner";

(: import repo modules :)
import module namespace global	= "influx/global";
import module namespace plugin	= "influx/plugin";
import module namespace db	    = "influx/db";
import module namespace ui =" influx/ui2";

declare namespace xhtml="http://www.w3.org/1999/xhtml";

declare variable $_:gremien := plugin:lookup("plato/schema/enums/get")!.("Gremien");
declare variable $_:ausbildung := plugin:lookup("plato/schema/enums/get")!.("Ausbildungen");
declare variable $_:position := plugin:lookup("plato/schema/enums/get")!.("Positionen");

declare %plugin:provide('side-navigation')
  function _:nav-item-stammdaten-contacs()
  as element(xhtml:li) {
  <li xmlns="http://www.w3.org/1999/xhtml" data-parent="/schema/list/items" data-sortkey="ZZZ">
      <a href="{$global:servlet-prefix}/schema/list/items?context=stammdaten/ansprechpartner&amp;provider=sanofi/ansprechpartner"><i class="fa fa-address-book"></i> <span class="nav-label">Ansprechpartner</span></a>
  </li>
};

declare %plugin:provide('side-navigation')
  function _:nav-item-stammdaten-contacs-fusioniert()
  as element(xhtml:li) {
  <li xmlns="http://www.w3.org/1999/xhtml" data-parent="/schema/list/items/fusioniert" data-sortkey="ZZZ">
      <a href="{$global:servlet-prefix}/schema/list/items?context=fusioniert/ansprechpartner&amp;provider=sanofi/ansprechpartner"><i class="fa fa-address-book"></i> <span class="nav-label">Ansprechpartner</span></a>
  </li>
};

(: provide sorting for items :)
declare %plugin:provide("schema/process/table/items")
function _:schema-render-table-prepare-rows(
    $Items as element()*, 
    $Schema as element(schema),
    $Context as map(*)
) {
  let $context := $Context("context")
  let $kk-provider := "sanofi/kk"
  let $kk-schema := plugin:provider-lookup($kk-provider, "schema", $context)!.()
  return
    for $item in $Items
    let $kk := 
      if ($item/kk/string())
      then plugin:lookup("datastore/dataobject")!.($item/kk/string(), $kk-schema, $Context)
      else ()
    order by $item/name
    where not($kk/fusioniert/string() = "true")
    return $item
};

declare %plugin:provide("schema/process/table/items", "fusioniert/ansprechpartner")
function _:schema-render-table-prepare-rows-fusioniert(
    $Items as element()*, 
    $Schema as element(schema),
    $Context as map(*)
) {
  let $context := $Context("context")
  let $kk-provider := "sanofi/kk"
  let $kk-schema := plugin:provider-lookup($kk-provider, "schema", $context)!.()
  return
    for $item in $Items
    let $kk := 
      if ($item/kk/string())
      then plugin:lookup("datastore/dataobject")!.($item/kk/string(), $kk-schema, $Context)
      else ()
    order by $item/name
    where $kk/fusioniert/string() = "true"
    return $item
};

declare %plugin:provide("schema/set/elements")
function _:schema-render-table-prepare-rows-only-name($Items as element()*, $Schema as element(schema),$Context as map(*)){
    let $columns := plugin:lookup("plato/schema/columns/get")!.("ansprechpartner")
    let $schema := $Schema update delete node ./*:element
    let $elements-in-order := for $name in $columns return $Schema/element[@name=$name]
    let $schema := $schema update insert node $elements-in-order as last into .
    return $schema};

declare %plugin:provide("schema") function _:schema-default()
as element(schema){
<schema xmlns="" name="ansprechpartner" domain="sanofi" provider="sanofi/ansprechpartner">
    <modal>
        <title>Ansprechpartner</title>
    </modal>
    <element name="titel" type="text">
        <label>Titel</label>
    </element>
    <element name="vorname" type="text" required="">
        <label>Vorname</label>
    </element>
    <element name="name" type="text" required="">
        <label>Name</label>
    </element>
    <element name="gremien" type="enum" multiple="">
        {$_:gremien ! <enum key="{.}">{.}</enum>}
        <label>Vertreten in den folgenden Gremien</label>
    </element>
    <element name="abteilung" type="text">
        <label>Abteilung</label>
    </element>
    <element name="position" type="enum">
        {$_:position ! <enum key="{.}">{.}</enum>}
        <label>Position</label>
    </element>
    <element name="kontaktintensitaet" type="enum">
        {('kein Kontakt','selten','regelmäßig','intensiv')!<enum key="{.}">{.}</enum>}
        <label>Kontaktintensität</label>
    </element>
    <element name="kv" type="foreign-key" render="dropdown">
              <provider>sanofi/kv</provider>
              <key>@id</key>
              <display-name>name/string()</display-name>
              <label>KV</label>
              <class>col-md-6</class>
    </element>
    <element name="kk" type="foreign-key" render="dropdown">
              <provider>sanofi/kk</provider>
              <key>@id</key>
              <display-name>name/string()</display-name>
              <label>KK</label>
              <class>col-md-6</class>
    </element>
    <element name="lav" type="foreign-key" render="dropdown">
      <provider>sanofi/lav</provider>
      <key>@id</key>
      <display-name>name/string()</display-name>
      <label>LAV</label>
      <class>col-md-6</class>
    </element>
    <element name="ausbildung" type="enum">
        {$_:ausbildung ! <enum key="{.}">{.}</enum>}
        <label>Ausbildung</label>
    </element>
    <element name="einfluss" type="foreign-key" render="table">
        <provider>sanofi/ansprechpartner/einfluss</provider>
        <key>ansprechpartner</key>
        <label>Einfluss</label>
        <display-name>rolle/string()</display-name>
    </element>
 </schema>
};

declare %plugin:provide("schema", "kk")
function _:schema-kk() {  
  _:schema-default() update (
    replace value of node ./element[@name="kk"]/@render with "context-item"
    ,delete node ./element[@name="kk"]/label
    ,delete node ./element[@name="kv"]
    ,delete node ./element[@name="lav"]
  )
};

declare %plugin:provide("schema", "kv")
function _:schema-kv() {  
  _:schema-default() update (
    replace value of node ./element[@name="kv"]/@render with "context-item"
    ,delete node ./element[@name="kv"]/label
    ,delete node ./element[@name="kk"]
    ,delete node ./element[@name="lav"]
  )
};

declare %plugin:provide("schema", "lav")
function _:schema-lav() {
  _:schema-default() update (
    replace value of node ./element[@name="lav"]/@render with "context-item"
    ,delete node ./element[@name="lav"]/label
    ,delete node ./element[@name="kk"]
    ,delete node ./element[@name="kv"]
  )
};

declare %plugin:provide("datastore/dataobject/delete", "kk")
function _:clear-connection-to-kk(
  $Item-Id as xs:string,
  $Schema as element(schema),
  $Context as map(*)
) {
  let $item := plugin:lookup("datastore/dataobject")!.($Item-Id, $Schema, $Context)
  let $item := $item update replace value of node ./kk with ()
  let $updateItem := plugin:lookup("datastore/dataobject/put")!.($item, $Schema, $Context)
  return <tr data-remove="#item-{$Item-Id}" data-animation="fadeOutRight"></tr>
};

declare %plugin:provide("datastore/dataobject/delete", "kv")
function _:clear-connection-to-kv(
  $Item-Id as xs:string,
  $Schema as element(schema),
  $Context as map(*)
) {
  let $item := plugin:lookup("datastore/dataobject")!.($Item-Id, $Schema, $Context)
  let $item := $item update replace value of node ./kk with ()
  let $updateItem := plugin:lookup("datastore/dataobject/put")!.($item, $Schema, $Context)
  return <tr data-remove="#item-{$Item-Id}" data-animation="fadeOutRight"></tr>
};

declare %plugin:provide("datastore/dataobject/delete", "lav")
function _:clear-connection-to-lav(
  $Item-Id as xs:string,
  $Schema as element(schema),
  $Context as map(*)
) {
  let $item := plugin:lookup("datastore/dataobject")!.($Item-Id, $Schema, $Context)
  let $item := $item update replace value of node ./lav with ()
  let $updateItem := plugin:lookup("datastore/dataobject/put")!.($item, $Schema, $Context)
  return <tr data-remove="#item-{$Item-Id}" data-animation="fadeOutRight"></tr>
};

declare %plugin:provide("content/view/context","kk")
function _:sanofi-ansprechpartner-kk(
  $Items as element(ansprechpartner)*,
  $Schema as element(schema),
  $Context as map(*)
) as element(xhtml:div) {
  let $kk-id := $Context("context-item")/@id/string()
  let $ap-items := $Items[./kk = $kk-id]
  return
    _:render-unternehmensstruktur($ap-items, $Items[1]/@id/string(), "kk")
};

declare %plugin:provide("content/view/context","kv")
function _:sanofi-ansprechpartner-kv(
  $Items as element(ansprechpartner)*,
  $Schema as element(schema),
  $Context as map(*)
) as element(xhtml:div) {
  let $kv-id := $Context("context-item")/@id/string()
  let $ap-items := $Items[./kv = $kv-id]
  return
    _:render-unternehmensstruktur($ap-items, $Items[1]/@id/string(), "kv")
};

declare function _:render-unternehmensstruktur(
  $Ansprechpartner as element(ansprechpartner)*,
  $Context-Item-Id as xs:string,
  $Context as xs:string
) as element(xhtml:div) {
  <div xmlns="http://www.w3.org/1999/xhtml" data-replace="#kk-ansprechpartner" id="kk-ansprechpartner">
      <div data-replace="#kk-ansprechpartner" id="kk-ansprechpartner">
        <div class="ibox float-e-margins ">
          <div class="ibox-title">
            <h5>Ansprechpartner</h5>
          </div>
          <div class="ibox-content">
            <div class="slimScrollDiv" style="position: relative; overflow: hidden; width: auto; height: 100%;">
              <div class="full-height-scroll" style="overflow: hidden; width: auto; height: 100%;">
                <div class="table-responsive">
                  <table class="table table-hover schema-ansprechpartner-table">
                    <thead>
                      <tr>
                        <th></th>
                        <th>Name</th>
                        <th>Produkt</th>
                        <th>Thema</th>
                        <th>Einfluss</th>
                      </tr>
                    </thead>
                    <tbody>
                    {
                        let $einfluss-schema := plugin:provider-lookup("sanofi/ansprechpartner/einfluss","schema")!.()
                        let $produkt-schema  := plugin:provider-lookup("sanofi/produkt","schema")!.()
                        return
                            for $item in $Ansprechpartner
                            let $id := $item/@id/string()
                            let $name := $item/*:name/string()
                            let $einfluss-id := $item/*:einfluss/string()
                            let $einfluesse := plugin:lookup("datastore/dataobject/field")!.("ansprechpartner",$id,$einfluss-schema,map{})
                            return
                                for $einfluss in $einfluesse
                                let $produkt-id := $einfluss/*:produkt/string()
                                let $produkt := if ($produkt-id!="") then plugin:lookup("datastore/dataobject")!.($produkt-id,$produkt-schema,map{}) else ()
                                return
                                  <tr id="item-{$id}">
                                    <td>
                                      <a class="btn btn-sm btn-error" href="/influx/schema/form/page/{$id}?provider=sanofi/ansprechpartner&amp;context={$Context}&amp;context-item-id={$Context-Item-Id}&amp;context-provider=sanofi/ansprechpartner">
                                        <span class="fa fa-edit"></span>
                                      </a>
                                    </td>
                                    <td>{$name}</td>
                                    <td>{$produkt/*:name/string()}</td>
                                    <td>{$einfluss/*:thema/string()}</td>
                                    <td>{$einfluss/*:rolle/string()}</td>
                                  </tr>
                    }
                    </tbody>
                  </table>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
};