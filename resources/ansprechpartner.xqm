module namespace _ = "sanofi/ansprechpartner";

(: import repo modules :)
import module namespace global	= "influx/global";
import module namespace plugin	= "influx/plugin";
import module namespace db	    = "influx/db";
import module namespace ui =" influx/ui2";

declare namespace xhtml="http://www.w3.org/1999/xhtml";


declare %plugin:provide('side-navigation')
  function _:nav-item-stammdaten-contacs()
  as element(xhtml:li) {
  <li xmlns="http://www.w3.org/1999/xhtml" data-parent="/sanofi/stammdaten" data-sortkey="ZZZ">
      <a href="{$global:servlet-prefix}/sanofi/stammdaten/ansprechpartner"><i class="fa fa-users"></i> <span class="nav-label">Ansprechpartner</span></a>
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
function _:schema-render-table-prepare-rows($Items as element()*, $Schema as element(schema),$Context as map(*)){for $item in $Items order by $item/name, $item/priority return $item};

declare %plugin:provide("schema/set/elements")
function _:schema-render-table-prepare-rows-only-name($Items as element()*, $Schema as element(schema),$Context as map(*)){
    let $columns := ("name","position","fachrichtung")
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
    <element name="name" type="text">
        <label>Name</label>
    </element>
     <element name="gremien" type="enum">
         {("Gremium1","Gremium2","Gremium3","Gremium4","Gremium5") ! <enum key="{.}">{.}</enum>}
         <label>Vertreten in den folgenden Gremien</label>
     </element>
   <element name="rolle" type="text">
        <label>Rolle</label>
    </element>
    <element name="abteilung" type="text">
        <label>Abteilung</label>
    </element>
    <element name="position" type="text">
        <label>Position</label>
    </element>
     <element name="einfluss" type="text">
         <label>Einfluss</label>
     </element>
     <element name="institutionen" type="text">
         <label>Institutionen</label>
     </element>
     <element name="fachrichtung" type="text">
         <label>Fachrichtung</label>
     </element>
     <element name="notizen" type="text">
         <label>Notizen</label>
     </element>
 </schema>
};

