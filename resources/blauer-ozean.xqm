module namespace _ = "sanofi/blauer-ozean";

(: import repo modules :)
import module namespace global	= "influx/global";
import module namespace plugin	= "influx/plugin";
import module namespace db	    = "influx/db";
import module namespace ui =" influx/ui2";

declare namespace xhtml="http://www.w3.org/1999/xhtml";

declare %plugin:provide('side-navigation')
  function _:nav-item-stammdaten-blauer-ozean()
  as element(xhtml:li) {
  <li xmlns="http://www.w3.org/1999/xhtml" data-parent="/sanofi/stammdaten" data-sortkey="ZZZ">
      <a href="{$global:servlet-prefix}/sanofi/stammdaten/blauer-ozean"><i class="fa fa-users"></i> <span class="nav-label">Blauer Ozean</span></a>
  </li>
};

declare %plugin:provide("ui/page/content","stammdaten/blauer-ozean")
function _:stammdaten-blauer-ozean($map)
as element(xhtml:div)
{
<div xmlns="http://www.w3.org/1999/xhtml" class="content-with-sidebar row">
  <div class="row">
      <div class="col-lg-12">
            {plugin:lookup("schema/ibox/table")!.("sanofi/blauer-ozean","stammdaten/blauer-ozean")}
      </div>
  </div>
</div>
};


(: provide sorting for items :)
declare %plugin:provide("schema/process/table/items")
function _:schema-render-table-prepare-rows($Items as element()*, $Schema as element(schema),$Context as map(*)){for $item in $Items order by $item/name, $item/priority return $item};

declare %plugin:provide("schema/set/elements")
function _:schema-render-table-prepare-rows-only-name($Items as element()*, $Schema as element(schema),$Context as map(*)){
    let $columns := ("name","kk","kv","datum")
    let $schema := $Schema update delete node ./*:element
    let $elements-in-order := for $name in $columns return $Schema/element[@name=$name]
    let $schema := $schema update insert node $elements-in-order as last into .
    return $schema};

declare %plugin:provide("schema") function _:schema-()
as element(schema){
<schema xmlns="" name="blauer-ozean" domain="sanofi" provider="sanofi/blauer-ozean">
    <modal>
        <title>Der Blaue Ozean</title>
        <button>
            <add>hinzufügen</add>
            <cancel>abbrechen</cancel>
            <modify>ändern</modify>
            <delete>löschen</delete>
        </button>
    </modal>
    <element name="name" type="text">
        <label>Titel</label>
    </element>
    <element name="datum" type="text">
        <label>Datum</label>
    </element>

    <element name="lieferfähigkeit-ist" type="number">
        <label>Lieferfähigkeit IST</label>
    </element>

    <element name="lieferfähigkeit-soll" type="number">
        <label>Lieferfähigkeit SOLL</label>
    </element>

 <element name="vertragsqualität-ist" type="number">
   <label>Vertragsqualität IST</label>
 </element>
 <element name="vertragsqualität-soll" type="number">
   <label>Vertragsqualität SOLL</label>
 </element>
 <element name="ökonomie-ist" type="number">
   <label>Ökonomie IST</label>
 </element>
 <element name="ökonomie-soll" type="number">
   <label>Ökonomie SOLL</label>
 </element>
 <element name="informationsweitergabe-ist" type="number">
   <label>Informationsweitergabe IST</label>
 </element>
 <element name="informationsweitergabe-soll" type="number">
   <label>Informationsweitergabe SOLL</label>
 </element>
 <element name="gesprächsangebot-ist" type="number">
   <label>Gesprächsangebot IST</label>
 </element>
 <element name="gesprächsangebot-soll" type="number">
   <label>Gesprächsangebot SOLL</label>
 </element>
 <element name="one-face-to-the-customoer-ist" type="number">
   <label>One-Face-to-The-Customer IST</label>
 </element>
 <element name="one-face-to-the-customoer-soll" type="number">
   <label>One-Face-to-The-Customer SOLL</label>
 </element>

   <element name="kv" type="foreign-key" required="">
              <provider>sanofi/kv</provider>
              <key>@id</key>
              <display-name>name/string()</display-name>
              <label>KV</label>
              <class>col-md-6</class>
   </element>

   <element name="kk" type="foreign-key" required="">
              <provider>sanofi/kk</provider>
              <key>@id</key>
              <display-name>name/string()</display-name>
              <label>KK</label>
              <class>col-md-6</class>
   </element>

   <element name="produkt" type="foreign-key" required="">
              <provider>sanofi/produkt</provider>
              <key>@id</key>
              <display-name>name/string()</display-name>
              <label>Produkt</label>
              <class>col-md-6</class>
   </element>

    <element name="notizen" type="text">
         <label>Notizen</label>
     </element>
 </schema>
};

