module namespace _ = "sanofi/ansprechpartner";

(: import repo modules :)
import module namespace global	= "influx/global";
import module namespace plugin	= "influx/plugin";
import module namespace db	    = "influx/db";
import module namespace ui =" influx/ui2";

declare namespace xhtml="http://www.w3.org/1999/xhtml";

declare variable $_:gremien := plugin:lookup("plato/schema/enums/get")!.("Gremien");

declare %plugin:provide('side-navigation')
  function _:nav-item-stammdaten-contacs()
  as element(xhtml:li) {
  <li xmlns="http://www.w3.org/1999/xhtml" data-parent="/schema/list/items" data-sortkey="ZZZ">
      <a href="{$global:servlet-prefix}/schema/list/items?context=stammdaten/ansprechpartner&amp;provider=sanofi/ansprechpartner"><i class="fa fa-users"></i> <span class="nav-label">Ansprechpartner</span></a>
  </li>
};

declare %plugin:provide("ui/page/content","stammdaten/ansprechpartner")
function _:stammdaten-ansprechpartner($map)
as element(xhtml:div)
{
<div xmlns="http://www.w3.org/1999/xhtml" class="content-with-sidebar row">
  <div class="row">
      <div class="col-lg-12">
            {plugin:lookup("schema/ibox/table")!.("sanofi/ansprechpartner","stammdaten/ansprechpartner")}
      </div>
  </div>
</div>
};


(: provide sorting for items :)
declare %plugin:provide("schema/process/table/items")
function _:schema-render-table-prepare-rows(
    $Items as element()*, 
    $Schema as element(schema),
    $Context as map(*)
) {
    for $item in $Items 
    order by $item/name, $item/priority 
    return $item
};

declare %plugin:provide("schema/set/elements")
function _:schema-render-table-prepare-rows-only-name($Items as element()*, $Schema as element(schema),$Context as map(*)){
    let $columns := plugin:lookup("plato/schema/columns/get")!.("ansprechpartner")
    let $schema := $Schema update delete node ./*:element
    let $elements-in-order := for $name in $columns return $Schema/element[@name=$name]
    let $schema := $schema update insert node $elements-in-order as last into .
    return $schema};

declare %plugin:provide("schema") function _:schema-customer()
as element(schema){
<schema xmlns="" name="ansprechpartner" domain="sanofi" provider="sanofi/ansprechpartner">
    <modal>
        <title>Ansprechpartner</title>
        <button>
            <add>hinzufügen</add>
            <cancel>abbrechen</cancel>
            <modify>ändern</modify>
            <delete>löschen</delete>
        </button>
    </modal>
    <element name="vorname" type="text">
        <label>Vorname</label>
    </element>
    <element name="name" type="text">
        <label>Name</label>
    </element>
    <element name="gremien" type="enum">
        {$_:gremien ! <enum key="{.}">{.}</enum>}
        <label>Vertreten in den folgenden Gremien</label>
    </element>
    <element name="abteilung" type="text">
        <label>Abteilung</label>
    </element>
    <element name="position" type="text">
        <label>Position</label>
    </element>
    <element name="kontaktintensitaet" type="text">
        <label>Kontaktintensität</label>
    </element>
    <element name="kv" type="foreign-key" render="dropdown" required="">
              <provider>sanofi/kv</provider>
              <key>@id</key>
              <display-name>name/string()</display-name>
              <label>KV</label>
              <class>col-md-6</class>
    </element>
    <element name="kk" type="foreign-key" render="dropdown" required="">
              <provider>sanofi/kk</provider>
              <key>@id</key>
              <display-name>name/string()</display-name>
              <label>KK</label>
              <class>col-md-6</class>
    </element>
    <element name="lav" type="foreign-key" render="dropdown" required="">
      <provider>sanofi/lav</provider>
      <key>@id</key>
      <display-name>name/string()</display-name>
      <label>LAV</label>
      <class>col-md-6</class>
    </element>
    <element name="fachrichtung" type="text">
        <label>Fachrichtung</label>
    </element>
    <element name="notizen" type="text">
        <label>Notizen</label>
    </element>
    <element name="einfluss" type="foreign-key" render="table">
        <provider>sanofi/ansprechpartner/einfluss</provider>
        <key>@id</key>
        <label>Einfluss</label>
    </element>
 </schema>
};

