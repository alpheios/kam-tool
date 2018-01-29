module namespace _ = "sanofi/kk";

(: import repo modules :)
import module namespace global	= "influx/global";
import module namespace plugin	= "influx/plugin";
import module namespace db	    = "influx/db";
import module namespace ui =" influx/ui2";

declare namespace xhtml="http://www.w3.org/1999/xhtml";

declare variable $_:land := ("Nordrhein-Westfalen","Baden-Württemberg","Bayern","Mecklenburg-Vorpommern",
                             "Sachsen","Sachsen-Anhalt", "Thüringen", "Brandenburg", "Berlin", "Hessen", "Niedersachsen",
                             "Bremen","Hamburg","Schleswig-Holstein","Saarland","Rheinland-Pfalz");

declare variable $_:kk := <kk><a href="250-BARMER.html">BARMER</a>
                              <a href="251-DAK-Gesundheit.html">DAK Gesundheit</a>
                              <a href="254-HEK-Hanseatische-Krankenkasse.html">HEK - Hanseatische Krankenkasse</a>
                              <a href="261-hkk-Krankenkasse.html">hkk Krankenkasse</a>
                              <a href="257-KKH-Kaufmännische-Krankenkasse.html">KKH Kaufmännische Krankenkasse</a>
                              <a href="1187-KNAPPSCHAFT.html">KNAPPSCHAFT</a>
                              <a href="258-Techniker-Krankenkasse-TK.html">Techniker Krankenkasse (TK)</a>
                              <a href="262-BIG-direkt-gesund.html">BIG direkt gesund</a>
                              <a href="265-IKK-Brandenburg-und-Berlin.html">IKK Brandenburg und Berlin</a>
                              <a href="283-IKK-classic.html">IKK classic</a>
                              <a href="279-IKK-gesund-plus.html">IKK gesund plus</a>
                              <a href="382-IKK-Nord.html">IKK Nord</a>
                              <a href="277-IKK-Südwest.html">IKK Südwest</a>
                              <a href="234-AOK-Baden-Württemberg.html">AOK Baden-Württemberg</a>
                              <a href="235-AOK-Bayern.html">AOK Bayern</a>
                              <a href="237-AOK-Bremen-Bremerhaven.html">AOK Bremen/Bremerhaven</a>
                              <a href="239-AOK-Hessen.html">AOK Hessen</a>
                              <a href="241-AOK-Niedersachsen.html">AOK Niedersachsen</a>
                              <a href="1209-AOK-Nordost.html">AOK Nordost</a>
                              <a href="249-AOK-Nordwest.html">AOK Nordwest</a>
                              <a href="245-AOK-PLUS.html">AOK PLUS</a>
                              <a href="243-AOK-Rheinland-Pfalz-Saarland.html">AOK Rheinland-Pfalz/Saarland</a>
                              <a href="242-AOK-Rheinland-Hamburg.html">AOK Rheinland/Hamburg</a>
                              <a href="246-AOK-Sachsen-Anhalt.html">AOK Sachsen-Anhalt</a>
                              <a href="23-actimonda-krankenkasse.html">actimonda krankenkasse</a>
                              <a href="379-atlas-BKK-ahlmann.html">atlas BKK ahlmann</a>
                              <a href="4-Audi-BKK.html">Audi BKK</a>
                              <a href="7-BAHN-BKK.html">BAHN-BKK</a>
                              <a href="27-BERGISCHE-Krankenkasse.html">BERGISCHE Krankenkasse</a>
                              <a href="1115-Bertelsmann-BKK.html">Bertelsmann BKK</a>
                              <a href="14-BKK-Achenbach-Buschhütten.html">BKK Achenbach Buschhütten</a>
                              <a href="21-BKK-Akzo-Nobel-Bayern.html">BKK Akzo Nobel Bayern</a>
                              <a href="29-BKK-Diakonie.html">BKK Diakonie</a>
                              <a href="56-BKK-DürkoppAdler.html">BKK DürkoppAdler</a>
                              <a href="20-BKK-EUREGIO.html">BKK EUREGIO</a>
                              <a href="69-BKK-exklusiv.html">BKK exklusiv</a>
                              <a href="70-BKK-Faber-Castell-Partner.html">BKK Faber-Castell &amp; Partner</a>
                              <a href="187-BKK-firmus.html">BKK firmus</a>
                              <a href="119-BKK-Freudenberg.html">BKK Freudenberg</a>
                              <a href="124-BKK-GILDEMEISTER-SEIDENSTICKER.html">BKK GILDEMEISTER SEIDENSTICKER</a>
                              <a href="129-BKK-HENSCHEL-plus.html">BKK HENSCHEL plus</a>
                              <a href="130-BKK-HERKULES.html">BKK HERKULES</a>
                              <a href="385-BKK-HMR.html">BKK HMR</a>
                              <a href="1150-BKK-Linde.html">BKK Linde</a>
                              <a href="202-BKK-Melitta-Plus.html">BKK Melitta Plus</a>
                              <a href="148-BKK-Mobil-Oil.html">BKK Mobil Oil</a>
                              <a href="158-BKK-PFAFF.html">BKK PFAFF</a>
                              <a href="159-BKK-Pfalz.html">BKK Pfalz</a>
                              <a href="383-BKK-ProVita.html">BKK ProVita</a>
                              <a href="162-BKK-Public.html">BKK Public</a>
                              <a href="176-BKK-SBH.html">BKK SBH</a>
                              <a href="394-BKK-Scheufelen.html">BKK Scheufelen</a>
                              <a href="181-BKK-Technoform.html">BKK Technoform</a>
                              <a href="182-BKK-Textilgruppe-Hof.html">BKK Textilgruppe Hof</a>
                              <a href="190-BKK-VBU.html">BKK VBU</a>
                              <a href="189-BKK-VDN.html">BKK VDN</a>
                              <a href="64-BKK-VerbundPlus.html">BKK VerbundPlus</a>
                              <a href="192-BKK-Vital.html">BKK Vital</a>
                              <a href="194-BKK-Werra-Meissner.html">BKK Werra-Meissner</a>
                              <a href="1147-BKK-WIRTSCHAFT-FINANZEN.html">BKK WIRTSCHAFT &amp; FINANZEN</a>
                              <a href="392-BKK-ZF-Partner.html">BKK ZF &amp; Partner</a>
                              <a href="12-BKK.html">BKK24</a>
                              <a href="199-Bosch-BKK.html">Bosch BKK</a>
                              <a href="60-Brandenburgische-BKK.html">Brandenburgische BKK</a>
                              <a href="160-Continentale-BKK.html">Continentale BKK</a>
                              <a href="1119-Debeka-BKK.html">Debeka BKK</a>
                              <a href="1112-energie-BKK.html">energie-BKK</a>
                              <a href="1211-Heimat-Krankenkasse.html">Heimat Krankenkasse</a>
                              <a href="1139-Metzinger-BKK.html">Metzinger BKK</a>
                              <a href="216-mhplus-Krankenkasse.html">mhplus Krankenkasse</a>
                              <a href="219-Novitas-BKK.html">Novitas BKK</a>
                              <a href="1189-pronova-BKK.html">pronova BKK</a>
                              <a href="165-R-V-Betriebskrankenkasse.html">R+V Betriebskrankenkasse</a>
                              <a href="220-Salus-BKK.html">Salus BKK</a>
                              <a href="222-SBK.html">SBK</a>
                              <a href="223-Schwenninger-Krankenkasse.html">Schwenninger Krankenkasse</a>
                              <a href="224-SECURVITA-Krankenkasse.html">SECURVITA Krankenkasse</a>
                              <a href="1116-SIEMAG-BKK.html">SIEMAG BKK</a>
                              <a href="226-SKD-BKK.html">SKD BKK</a>
                              <a href="184-TBK-Thüringer-Betriebskrankenkasse.html">TBK (Thüringer Betriebskrankenkasse)</a>
                              <a href="185-TUI-BKK.html">TUI BKK</a>
                              <a href="193-VIACTIV-Krankenkasse.html">VIACTIV Krankenkasse</a>
                              <a href="232-WMF-BKK.html">WMF BKK</a>
                              <a href="1122-BKK-Aesculap.html">BKK Aesculap</a>
                              <a href="1131-BKK-B-Braun.html">BKK B. Braun</a>
                              <a href="1130-BKK-BPW-Bergische-Achsen-KG.html">BKK BPW Bergische Achsen KG</a>
                              <a href="1146-BKK-evm.html">BKK evm</a>
                              <a href="1137-BKK-EWE.html">BKK EWE</a>
                              <a href="1140-BKK-GRILLO-WERKE-AG.html">BKK GRILLO-WERKE AG</a>
                              <a href="1141-BKK-Groz-Beckert.html">BKK Groz-Beckert</a>
                              <a href="1144-BKK-KARL-MAYER.html">BKK KARL MAYER</a>
                              <a href="1145-BKK-KBA.html">BKK KBA</a>
                              <a href="1151-BKK-MAHLE.html">BKK MAHLE</a>
                              <a href="1152-BKK-Merck.html">BKK Merck</a>
                              <a href="1153-BKK-Miele.html">BKK Miele</a>
                              <a href="1154-BKK-MTU-Friedrichshafen-GmbH.html">BKK MTU Friedrichshafen GmbH</a>
                              <a href="1156-BKK-PwC.html">BKK PwC</a>
                              <a href="1157-BKK-Rieker-Ricosta-Weisser.html">BKK Rieker.Ricosta.Weisser</a>
                              <a href="1158-BKK-RWE.html">BKK RWE</a>
                              <a href="1159-BKK-Salzgitter.html">BKK Salzgitter</a>
                              <a href="1163-BKK-Stadt-Augsburg.html">BKK Stadt Augsburg</a>
                              <a href="1168-BKK-Voralb-HELLER-INDEX-LEUZE.html">BKK Voralb HELLER*INDEX*LEUZE</a>
                              <a href="1173-BKK-Würth.html">BKK Würth</a>
                              <a href="1129-BMW-BKK.html">BMW BKK</a>
                              <a href="1176-Daimler-BKK.html">Daimler BKK</a>
                              <a href="1136-Ernst-Young-BKK.html">Ernst &amp; Young BKK</a>
                              <a href="1148-Krones-BKK.html">Krones BKK</a>
                              <a href="1179-Südzucker-BKK.html">Südzucker-BKK</a>
                              <a href="1172-Wieland-BKK.html">Wieland BKK</a>
                              <a href="5-BKK-advita-jetzt-BKK.html">BKK advita - jetzt: BKK24</a>
                              <a href="1124-BKK-AXEL-SPRINGER-jetzt-DAK-Gesundheit.html">BKK AXEL SPRINGER - jetzt: DAK Gesundheit</a>
                              <a href="1126-BKK-Basell-jetzt-BKK-VBU.html">BKK Basell - jetzt: BKK VBU</a>
                              <a href="1127-BKK-Beiersdorf-AG-jetzt-DAK-Gesundheit.html">BKK Beiersdorf AG - jetzt: DAK Gesundheit</a>
                              <a href="1128-BKK-BJB-jetzt-BKK-Gildemeister-Seidensticker.html">BKK BJB - jetzt: BKK Gildemeister Seidensticker</a>
                              <a href="33-BKK-Braun-Gillette-jetzt-pronova-BKK.html">BKK Braun-Gillette - jetzt: pronova BKK</a>
                              <a href="43-BKK-Demag-Krauss-Maffei-jetzt-BKK-VBU.html">BKK Demag Krauss-Maffei - jetzt: BKK VBU</a>
                              <a href="67-BKK-ESSANELLE-jetzt-BARMER.html">BKK ESSANELLE - jetzt: BARMER</a>
                              <a href="134-BKK-family-jetzt-BKK-ProVita.html">BKK family - jetzt: BKK ProVita</a>
                              <a href="123-BKK-futur-jetzt-BKK-VBU.html">BKK futur - jetzt BKK VBU</a>
                              <a href="227-BKK-Gesundheit-jetzt-DAK-Gesundheit.html">BKK Gesundheit - jetzt: DAK Gesundheit</a>
                              <a href="1142-BKK-Heimbach-jetzt-actimonda.html">BKK Heimbach - jetzt: actimonda</a>
                              <a href="1121-BKK-Kassana-jetzt-BKK-VerbundPlus.html">BKK Kassana - jetzt: BKK VerbundPlus</a>
                              <a href="142-BKK-MAN-und-MTU-jetzt-Audi-BKK.html">BKK MAN und MTU - jetzt: Audi BKK</a>
                              <a href="145-BKK-MEDICUS-jetzt-BKK-VBU.html">BKK MEDICUS - jetzt: BKK VBU</a>
                              <a href="147-BKK-MEM-jetzt-Metzinger-BKK.html">BKK MEM - jetzt Metzinger BKK</a>
                              <a href="161-BKK-PHOENIX-jetzt-Novitas-BKK.html">BKK PHOENIX - jetzt: Novitas BKK</a>
                              <a href="180-BKK-S-H-jetzt-BKK-VBU.html">BKK S-H - jetzt: BKK VBU</a>
                              <a href="1162-BKK-Schwesternschaft-v-BRK-jetzt-BKK-ProVita.html">BKK Schwesternschaft v. BRK - jetzt: BKK ProVita</a>
                              <a href="397-BKK-VICTORIA-D-A-S-jetzt-BIG-direkt-gesund.html">BKK VICTORIA D.A.S. - jetzt: BIG direkt gesund</a>
                              <a href="231-DEUTSCHE-BKK-jetzt-BARMER.html">DEUTSCHE BKK - jetzt: BARMER</a>
                              <a href="1135-E-ON-Betriebskrankenkasse-jetzt-energie-BKK.html">E.ON Betriebskrankenkasse - jetzt: energie-BKK</a>
                              <a href="205-ESSO-BKK-jetzt-Novitas-BKK.html">ESSO BKK - jetzt: Novitas BKK</a>
                              <a href="1177-HEAG-BKK-jetzt-Linde-BKK.html">HEAG BKK - jetzt: Linde BKK</a>
                              <a href="396-Hypovereinsbank-BKK-jetzt-BKK-Mobil-Oil.html">Hypovereinsbank BKK - jetzt: BKK Mobil Oil</a>
                              <a href="1178-SAINT-GOBAIN-BKK.html">SAINT-GOBAIN BKK</a>
                              <a href="1120-Shell-BKK-LIFE-jetzt-DAK-Gesundheit.html">Shell BKK/LIFE - jetzt: DAK Gesundheit</a>
                              <a href="188-Vaillant-BKK-jetzt-pronova-BKK.html">Vaillant BKK - jetzt: pronova BKK</a>
                              <a href="218-Vereinigte-BKK-jetzt-BKK-VBU.html">Vereinigte BKK - jetzt: BKK VBU</a>
                              </kk>;

declare %plugin:provide('side-navigation')
  function _:nav-item-stammdaten-kk()
  as element(xhtml:li) {
  <li xmlns="http://www.w3.org/1999/xhtml" data-parent="/sanofi/stammdaten" data-sortkey="ZZZ">
      <a href="{$global:servlet-prefix}/sanofi/stammdaten/kk"><i class="fa fa-users"></i> <span class="nav-label">Krankenkassen</span></a>
  </li>
};

declare %plugin:provide("schema/render/page/debug/itemX") function _:debug-kk ($Item,$Schema,$Context){
<pre>{serialize($Item)}</pre>
};

declare %plugin:provide("ui/page/content","stammdaten/kk")
function _:stammdaten-kk($map)
as element(xhtml:div)
{
<div xmlns="http://www.w3.org/1999/xhtml" class="content-with-sidebar row">
  <div class="row">
      <div class="col-lg-12">
            {plugin:lookup("schema/ibox/table")!.("sanofi/kk","stammdaten/kk")}
      </div>
  </div>
</div>
};

declare %plugin:provide("schema/process/table/items")
function _:schema-render-table-prepare-rows-jf($Items as element()*, $Schema as element(schema),$Context as map(*))
{
for $item in $Items order by $item/name return $item
};

declare %plugin:provide("schema/set/elements")
function _:schema-column-filter($Item as element()*, $Schema as element(schema), $Context as map(*)){
    let $columns := ("name","verantwortlich","ansprechpartner", "dachverband")
    let $schema := $Schema update delete node ./*:element
    let $elements-in-order := for $name in $columns return $Schema/element[@name=$name]
    let $schema := $schema update insert node $elements-in-order as last into .
    return $schema
};

declare %plugin:provide("schema") function _:schema()
as element(schema){
<schema xmlns="" name="kk" domain="sanofi" provider="sanofi/kk">
    <modal>
        <title>Gesetzliche Krankenkasse</title>
        <button>
            <add>hinzufügen</add>
            <cancel>abbrechen</cancel>
            <modify>ändern</modify>
            <delete>löschen</delete>
        </button>
    </modal>
    <element name="name" type="enum">
    {$_:kk//a ! <enum key="{.}">{.}</enum>}
    <label>Name</label>
    </element>
    <element name="dachverband" type="text">
        <label>Dachverband</label>
    </element>
    <element name="verantwortlich" type="foreign-key" required="">
                <provider>sanofi/key-accounter</provider>
                <key>@id/string()</key>
                <display-name>name/string()</display-name>
                <label>Verantwortlich</label>
                <class>col-md-6</class>
    </element>
    <element name="ansprechpartner" type="foreign-key" required="">
            <provider>sanofi/ansprechpartner</provider>
            <key>@id</key>
            <display-name>name/string()</display-name>
            <label>Ansprechpartner</label>
            <class>col-md-6</class>
    </element>
    <element name="ziele" type="html">
        <label>Ziele</label>
    </element>
    <element name="strategien" type="html">
        <label>Strategien</label>
    </element>
    <element name="meilensteine" type="html">
        <label>Meilensteine/Schlüsselaktionen</label>
    </element>
    <element name="anforderungen" type="html">
        <label>Anforderungen</label>
    </element>
  </schema>
};


declare %plugin:provide("schema/render/form/field/enum","name")
 function _:schema-render-field-kk-name(
     $Item as element()?,
     $Element as element(element),
     $Context)
{
     let $schema := $Element/ancestor::schema
     let $kks := plugin:lookup("datastore/dataobject/all")!.($schema,map{})[@id!=$Item/@id]
     let $assigned-names := $kks/name/string()
     let $type := $Element/@type
     let $name := $Element/@name
     let $names := $_:kk//a/text()[not(.=$assigned-names)]
     let $enums := $names!<enum key="{.}">{.}</enum>
     let $class := $Element/class/string()
     let $required := $Element/@required
     let $value := $Item/node()[name()=$name]
     return
      if ($Item/name!="")
             then (<br/>,$Item/name/string())
             else
     <select xmlns="http://www.w3.org/1999/xhtml" name="{$name}" class="form-control select2">{$required}
     <option value="">Nicht zugewiesen</option>
     {
       for $enum in $enums
       return <option value="{$enum/@key}">
                    {if ($enum/@key=$value) then attribute selected {} else ()}
                    {$enum/string()}
              </option>
     }
     </select>
};


declare %plugin:provide("profile/dashboard/widget")
function _:profile-dashboard-widget-kk($Profile as element())
{

    let $context := map{}
    let $schema := plugin:provider-lookup("sanofi/kk","schema")!.()
    let $items  := plugin:provider-lookup("sanofi/kk","datastore/dataobject/all")!.($schema,$context)
    let $items  := $items[*:verantwortlich=$Profile/@id/string()]
    return
        if (count($items)>0) then
        <div class="col-md-6">
         {plugin:provider-lookup("sanofi/kk","schema/render/table/page")!.($items,$schema,$context)}
        </div>
        else ()

};

declare %plugin:provide("schema/render/form/page")
function _:render-page-form($Item as element()?, $Schema as element(schema), $Context)
{
let $form-id := "id-"||random:uuid()
let $title := $Schema/*:modal/*:title/string()
let $provider := $Schema/@provider
let $context := "kk"
let $Context := map:remove($Context,"context")
let $Context := map:put($Context,"context",$context)
let $Context := if (map:contains($Context,"kk")) then $Context else map:put($Context,"kk",$Item/@id/string())
return
<div xmlns="http://www.w3.org/1999/xhtml" class="content-with-sidebar sanofi-kk-page" data-replace=".sanofi-kk-page">
  <div class="ibox float-e-margins">
      <div class="tabs-container">
          <ul class="nav nav-tabs">
              <li class="active"><a data-toggle="tab" href="#tab-1">Formular</a></li>
              <li class=""><a data-toggle="tab" href="#tab-2">TOP 4</a></li>
              <li class=""><a data-toggle="tab" href="#tab-3">Blauer Ozean</a></li>
              <li class=""><a data-toggle="tab" href="#tab-4">Projekte</a></li>
              <li class=""><a data-toggle="tab" href="#tab-5">Verträge</a></li>
          </ul>
          <div class="tab-content">
              <div id="tab-1" class="tab-pane active">
                  <div class="panel-body">
                     {plugin:provider-lookup($provider,"schema/render/page/form")!.($Item,$Schema,$Context)}
                  </div>
              </div>
              <div id="tab-2" class="tab-pane">
                  <div class="panel-body">
                  {
                      let $provider := "sanofi/kk-kam-top-4"
                      let $schema := plugin:provider-lookup($provider,"schema")!.()
                      let $items :=
                          for $item in plugin:provider-lookup($provider,"datastore/dataobject/all",$context)!.($schema,$Context)
                          let $date := $item/@last-modified-date
                          order by $date descending
                          return $item
                      let $item-latest := $items[1]
                      return
                          plugin:provider-lookup($provider,"content/view/context","kk")!.($item-latest,$schema,$Context)
                  }
                  </div>
              </div>
              <div id="tab-3" class="tab-pane">
                  <div class="panel-body">
                    {
                    let $provider := "sanofi/blauer-ozean"
                    let $schema := plugin:provider-lookup($provider,"schema")!.()
                    let $blauer-ozean-items :=
                        for $item in plugin:provider-lookup($provider,"datastore/dataobject/all",$context)!.($schema,$Context)
                        let $date := $item/@last-modified-date
                        order by $date descending
                        return $item
                    let $blauer-ozean-item-latest := $blauer-ozean-items[1]
                    return
                        plugin:provider-lookup($provider,"content/view","kk")!.($blauer-ozean-item-latest,$schema,$Context)
                    }
                  </div>
              </div>
              <div id="tab-4" class="tab-pane">
                  <div class="panel-body">
                    {
                        let $provider := "sanofi/projekt"
                        let $context := "kk"
                        let $schema := plugin:provider-lookup($provider,"schema")!.()
                        let $items :=
                            for $item in plugin:provider-lookup($provider,"datastore/dataobject/all")!.($schema,$Context)
                            let $date := $item/@last-modified-date
                            order by $date descending
                            return $item
                        let $item-latest := $items[1]
                        return
                        plugin:provider-lookup($provider,"content/context/view",$context)!.($item-latest,$schema,$Context)
                    }
                  </div>
              </div>
              <div id="tab-5" class="tab-pane">
                  <div class="panel-body">
                    {
                        let $provider := "sanofi/vertrag"
                        let $context := "kk"
                        let $schema := plugin:provider-lookup($provider,"schema")!.()
                        let $items :=
                            for $item in plugin:provider-lookup($provider,"datastore/dataobject/all")!.($schema,$Context)
                            let $date := $item/@last-modified-date
                            order by $date descending
                            return $item
                        let $item-latest := trace($items)[1]
                        return
                        plugin:provider-lookup($provider,"content/context/view",$context)!.($item-latest,$schema,$Context)
                    }
                  </div>
              </div>
          </div>
      </div>
  </div>
 </div>
 };