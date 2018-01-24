module namespace _ = "sanofi/ansprechpartner/einfluss";

import module namespace plugin  = "influx/plugin";




declare %plugin:provide("schema") 
function _:schema-customer-influence()
as element(schema){
<schema xmlns="" name="einfluss" domain="sanofi" provider="sanofi/ansprechpartner/einfluss">
    <modal>
        <title>Einfluss</title>
        <button>
            <add>hinzufügen</add>
            <cancel>abbrechen</cancel>
            <modify>ändern</modify>
            <delete>löschen</delete>
        </button>
    </modal>
    <element name="produkt" type="foreign-key" required="">
              <provider>sanofi/produkt</provider>
              <key>@id</key>
              <display-name>name/string()</display-name>
              <label>Produkt</label>
    </element>
    <element name="rolle" type="enum" required="">
      {("Entscheider", "Beeinflusser", "Nutzer/Anwender", "Gatekeeper") ! <enum key="{.}">{.}</enum>}
      <label>Rolle</label>
    </element>
 </schema>
};

