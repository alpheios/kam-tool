module namespace _ = "sanofi/lav";

(: import repo modules :)
import module namespace global	= "influx/global";
import module namespace plugin	= "influx/plugin";
import module namespace db	    = "influx/db";
import module namespace ui =" influx/ui2";

declare namespace xhtml="http://www.w3.org/1999/xhtml";

declare variable $_:kv-bezirk := plugin:lookup("plato/schema/enums/get")!.("KV-Bezirke");

declare %plugin:provide('side-navigation')
  function _:nav-item-stammdaten-lav()
  as element(xhtml:li) {
  <li xmlns="http://www.w3.org/1999/xhtml" data-parent="/schema/list/items" data-sortkey="ZZZ">
      <a href="{$global:servlet-prefix}/schema/list/items?context=stammdaten/lav&amp;provider=sanofi/lav"><i class="fa fa-users"></i> <span class="nav-label">Landes-Apotheker-Vereine/Verbände</span></a>
  </li>
};

declare %plugin:provide("ui/page/content","stammdaten/lav")
function _:stammdaten-lav($map)
as element(xhtml:div)
{
<div xmlns="http://www.w3.org/1999/xhtml" class="content-with-sidebar row">
  <div class="row">
      <div class="col-lg-12">
            {plugin:lookup("schema/ibox/table")!.("sanofi/lav","stammdaten/lav")}
      </div>
  </div>
</div>
};

declare %plugin:provide("schema/process/table/items","stammdaten/lav")
function _:schema-render-table-prepare-rows-jf($Items as element()*, $Schema as element(schema),$Context as map(*))
{
for $item in $Items order by $item/land return $item
};

declare %plugin:provide("schema/set/elements","stammdaten/lav")
function _:schema-column-filter($Item as element()*, $Schema as element(schema), $Context as map(*)){
    let $columns := plugin:lookup("plato/schema/columns/get")!.("lav")
    let $schema := $Schema update delete node ./*:element
    let $elements-in-order := for $name in $columns return $Schema/element[@name=$name]
    let $schema := $schema update insert node $elements-in-order as last into .
    return $schema
};

declare %plugin:provide("schema") function _:schema2()
as element(schema){
<schema xmlns="" name="lav" domain="sanofi" provider="sanofi/lav">
    <modal>
        <title>Landes-Apotheker Vereinigung/Vereine</title>
        <button>
            <add>hinzufügen</add>
            <cancel>abbrechen</cancel>
            <modify>ändern</modify>
            <delete>löschen</delete>
        </button>
    </modal>
    <element name="name" type="text">
        <label>Name:</label>
    </element>
    <element name="verantwortlich" type="foreign-key" required="">
                <provider>sanofi/key-accounter</provider>
                <key>@id</key>
                <display-name>name/string()</display-name>
                <label>Zuständig</label>
                <class>col-md-6</class>
    </element>
    <element name="kv-bezirk" type="enum" required="">
            {$_:kv-bezirk ! <enum key="{.}">{.}</enum>}
            <label>KV Bezirk</label>
        </element>
    <element name="ansprechpartner" type="foreign-key" required="">
            <provider>sanofi/ansprechpartner</provider>
            <key>@id</key>
            <display-name>name/string()</display-name>
            <label>Ansprechpartner</label>
            <class>col-md-6</class>
    </element>

</schema>
};
