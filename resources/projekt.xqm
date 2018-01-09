module namespace _ = "sanofi/projekt";

(: import repo modules :)
import module namespace global	= "influx/global";
import module namespace plugin	= "influx/plugin";
import module namespace db	    = "influx/db";
import module namespace ui =" influx/ui2";

declare namespace xhtml="http://www.w3.org/1999/xhtml";



declare %plugin:provide('side-navigation')
  function _:nav-item-stammdaten-products()
  as element(xhtml:li) {
  <li xmlns="http://www.w3.org/1999/xhtml" data-parent="/sanofi/stammdaten" data-sortkey="ZZZ">
      <a href="{$global:servlet-prefix}/sanofi/stammdaten/projekt"><i class="fa fa-cubes"></i> <span class="nav-label">Projekte</span></a>
  </li>
};


declare %plugin:provide("ui/page/content","stammdaten/projekt")
function _:stammdaten-projekt($map)
as element(xhtml:div)
{
<div xmlns="http://www.w3.org/1999/xhtml" class="content-with-sidebar row">
  <div class="row">
      <div class="col-lg-12">
            {plugin:lookup("schema/ibox/table")!.("sanofi/projekt","stammdaten/projekt")}
      </div>
  </div>
</div>
};


(: provide sorting for items :)
declare %plugin:provide("schema/process/table/items")
function _:schema-render-table-prepare-rows($Items as element()*, $Schema as element(schema),$Context as map(*)){for $item in $Items order by $item/name, $item/priority return $item};

declare %plugin:provide("schema/set/elements")
function _:schema-render-table-prepare-rows-only-name($Items as element()*, $Schema as element(schema),$Context as map(*)){
    let $columns := ("name","beginn")
    let $schema := $Schema update delete node ./*:element
    let $elements-in-order := for $name in $columns return $Schema/element[@name=$name]
    let $schema := $schema update insert node $elements-in-order as last into .
    return $schema};

declare %plugin:provide("schema") function _:schema-customer()
as element(schema){
<schema xmlns="" name="projekt" domain="sanofi" provider="sanofi/projekt">
    <modal>
        <title>Projekt</title>
        <button>
            <add>hinzufügen</add>
            <cancel>abbrechen</cancel>
            <modify>ändern</modify>
            <delete>löschen</delete>
        </button>
    </modal>
    <element name="name" type="text">
        <label>Projektname</label>
    </element>
    <element name="kk" type="foreign-key" required="">
                    <provider>sanofi/kk</provider>
                    <key>@id</key>
                    <display-name>name/string()</display-name>
                    <label>KK-Vertragspartner</label>
                    <class>col-md-6</class>
    </element>
    <element name="kv" type="foreign-key" required="">
                    <provider>sanofi/kv</provider>
                    <key>@id</key>
                    <display-name>name/string()</display-name>
                    <label>KV-Vertragspartner</label>
                    <class>col-md-6</class>
    </element>
    <element name="beginn" type="date">
        <label>Beginn</label>
    </element>
    <element name="ende" type="date">
        <label>Ende</label>
    </element>
    <element name="notizen" type="text">
         <label>Notizen</label>
     </element>
 </schema>
};

