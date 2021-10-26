  module namespace _ = "sanofi/tracking";
  
  (: import repo modules :)
  import module namespace global	= "influx/global";
  import module namespace plugin	= "influx/plugin";
  import module namespace db	    = "influx/db";
  import module namespace ui =" influx/ui";
  import module namespace date-util ="influx/utils/date-utils";
  import module namespace common="sanofi/common" at "common.xqm";

  
  declare namespace xhtml="http://www.w3.org/1999/xhtml";
  declare namespace functx = "http://www.functx.com";
  declare variable $_:ns := namespace-uri(<_:ns/>);
  
  (: hier werden die Auswahlwerte für die ab Version 1.1 verwendeten neuen Tracking - Kamapagne deklariert :)
  declare variable $_:tracking_kampange := plugin:lookup("plato/schema/enums/get")!.("Tracking Kampagne");


declare %plugin:provide('ui/page/title') function _:heading($m){_:schema-default()//*:title/string()};
declare %plugin:provide("ui/page/content") function _:ui-page-content($m){common:ui-page-content($m)};
declare %plugin:provide('ui/page/heading/breadcrumb') function _:breadcrumb($m){common:breadcrumb($m)};


  (: ------------------------------- STAMMDATEN ANFANG -------------------------------------------- :)
  
  (:

 Menü-Eintrag in der side-navigation für "tracking"
ACHTUNG Benennung:  Tracking ist durch Betriebsrat problematisch und wurde daher nachträglich in Kampagne geändert!
:)
declare %plugin:provide('side-navigation-item')
  function _:nav-item-stammdaten-contracts()
  as element(xhtml:li) {
  <li xmlns="http://www.w3.org/1999/xhtml" data-parent="/schema/list/items" data-sortkey="ZZZ">
      <a href="{$global:servlet-prefix}/schema/list/items?context=g&amp;provider={$_:ns}"><i class="fa fa-cubes"></i> <span class="nav-label">KAIPangne</span></a>
  </li>
};

(: ------------------------------- STAMMDATEN ENDE -------------------------------------------- :)


(:
  Provider für die Profilseiten Widgets
:)

declare %plugin:provide("profile/dashboard/widget")
function _:profile-dashboard-widget-tracking($Profile as element())
{
<div class="col-md-6">
  {
    let $context := map {}
    let $schema := plugin:provider-lookup($_:ns,"schema")!.()
    let $items  := plugin:provider-lookup($_:ns,"datastore/dataobject/all")!.($schema,$context)
        
    return
        plugin:lookup("schema/render/table/page", "profile")!.($items,$schema,$context)
  }
</div>
};


(:
   Sortierung und Filterung für die Stammdaten
:)


declare %plugin:provide("schema") function _:schema-default()
as element(schema){
<schema xmlns="" name="tracking" domain="sanofi" provider="{$_:ns}">
    <modal>
        <title>KAIPAGNE</title>
    </modal>
   
    <element name="Kampagne" type="enum">
      {$_:tracking_kampange ! <enum key="{.}">{.}</enum>}
      <label>Tracking für</label>
    </element>  
    <element name="kk" type="foreign-key" multiple="">
            <provider>sanofi/kk</provider>
            <key>@id</key>
            <display-name>name/string()</display-name>
            <label>KK-Vertragspartner</label>
            <class>col-md-6</class>
    </element>
    <element name="kv" type="foreign-key">
            <provider>sanofi/kv</provider>
            <key>@id</key>
            <display-name>name/string()</display-name>
            <label>KV-Bezirke</label>
            <class>col-md-6</class>
    </element>
    <element name="lav" type="foreign-key">
            <provider>sanofi/lav</provider>
            <key>@id</key>
            <display-name>name/string()</display-name>
            <label>LAV-Vertragspartner</label>
            <class>col-md-6</class>
    </element>
    <element name="Eingabedatum" type="date">
        <label>(1) Gesprächsdatum</label>
    </element>               
       <element name="gesprächsergebnis" type="textarea">
        <label>(2) Gesprächsergebnis</label>
    </element>
        <element name="KAM_INTERN" type="textarea"> 
        <label>(3) Kommentar (NUR INTERN!!!)</label>
    </element>  
     <element name="Aussendung" type="textarea">
        <label>(4) Aktivität des Kunden</label>
    </element>
      <element name="Freitext1" type="textarea">
        <label>(5) Freitext (nach Vorgabe)</label>
    </element>
      <element name="Freitext2" type="textarea">
        <label>(6) Freitext (nach Vorgabe)</label>
    </element>
      <element name="Freitext3" type="textarea">
        <label>(7) Freitext (nach Vorgabe)</label>
    </element>
      <element name="Freitext4" type="textarea">
        <label>(8) Freitext (nach Vorgabe)</label>
    </element>
     <element name="kundenbewertung" type="enum">
      <label>(9) Kundenbewertung</label>
      <enum key="1">+1 - positve Auswirkungen auf das Produkt</enum>
      <enum key="0">0  - neutral</enum>
      <enum key="-1">-1 - negative Auswirkungen auf das Produkt</enum>
    </element>
     <element name="kurzbeschreibung" type="text" maxlength="120">
      <label>(10) Kundenbewertung Kommentar</label>
    </element>
    <element name="notizen" type="textarea">
         <label>(11) Link</label>
     </element>
     <element name="sharepoint-link" type="text">
        <label>(12) Dokument in Sharepoint</label>
     </element>
      
 </schema>
 };
 
