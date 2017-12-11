module namespace _ = "sanofi/summary";

(: import repo modules :)
import module namespace global	= "influx/global";
import module namespace plugin	= "influx/plugin";
import module namespace db	    = "influx/db";
import module namespace ui =" influx/ui2";

declare namespace xhtml="http://www.w3.org/1999/xhtml";

declare %plugin:provide('side-navigation')
  function _:nav-item-stammdaten-summary()
  as element(xhtml:li) {
  <li xmlns="http://www.w3.org/1999/xhtml" data-parent="/sanofi/stammdaten" data-sortkey="ZZZ">
      <a href="{$global:servlet-prefix}/sanofi/stammdaten/summary"><i class="fa fa-users"></i> <span class="nav-label">KAM Summary</span></a>
  </li>
};

declare %plugin:provide("ui/page/content","stammdaten/summary")
function _:stammdaten-summary($map)
as element(xhtml:div)
{
<div xmlns="http://www.w3.org/1999/xhtml" class="content-with-sidebar row">
  <div class="row">
      <div class="col-lg-12">
            {plugin:lookup("schema/ibox/table")!.("sanofi/summary","stammdaten/summary")}
      </div>
  </div>
</div>
};


(: provide sorting for items :)
declare %plugin:provide("schema/process/table/items")
function _:schema-render-table-prepare-rows($Items as element()*, $Schema as element(schema),$Context as map(*)){for $item in $Items order by $item/name, $item/priority return $item};

declare %plugin:provide("schema/set/elements")
function _:schema-render-table-prepare-rows-only-name($Items as element()*, $Schema as element(schema),$Context as map(*)){
    let $columns := ("name","datum")
    let $schema := $Schema update delete node ./*:element
    let $elements-in-order := for $name in $columns return $Schema/element[@name=$name]
    let $schema := $schema update insert node $elements-in-order as last into .
    return $schema};






declare %plugin:provide("schema") function _:schema-customer()
as element(schema){
<schema xmlns="" name="summary" domain="sanofi" provider="sanofi/summary">
    <modal>
        <title>KAM Management Zusammenfassung</title>
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

    <element name="news1" type="text">
        <label>1. News</label>
    </element>
    <element name="news2" type="text">
            <label>2. News</label>
    </element>
    <element name="news3" type="text">
        <label>3. News</label>
    </element>
    <element name="news4" type="text">
        <label>4. News</label>
    </element>

    <element name="overview1" type="text">
        <label>1. Auf einen Blick</label>
    </element>
    <element name="overview2" type="text">
            <label>2. Auf einen Blick</label>
    </element>
    <element name="overview3" type="text">
        <label>3. Auf einen Blick</label>
    </element>
    <element name="overview4" type="text">
        <label>4. Auf einen Blick</label>
    </element>

    <element name="goal1" type="text">
        <label>1. Top Ziel</label>
    </element>
    <element name="goal2" type="text">
            <label>2. Top Ziel</label>
    </element>
    <element name="goal3" type="text">
        <label>3. Top Ziel</label>
    </element>
    <element name="goal4" type="text">
        <label>4. Top Ziel</label>
    </element>

    <element name="good1" type="text">
        <label>1. Was läuft gut?</label>
    </element>
    <element name="good2" type="text">
            <label>2. Was läuft gut?</label>
    </element>
    <element name="good3" type="text">
        <label>3. Was läuft gut?</label>
    </element>
    <element name="good4" type="text">
        <label>4. Was läuft gut?</label>
    </element>

    <element name="critical1" type="text">
        <label>1. Kritischer Punkt</label>
    </element>
    <element name="critical2" type="text">
            <label>2. Kritischer Punkt</label>
    </element>
    <element name="critical3" type="text">
        <label>3. Kritischer Punkt</label>
    </element>
    <element name="critical4" type="text">
        <label>4. Kritischer Punkt</label>
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

