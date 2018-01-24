module namespace _="sales-management/requests";

import module namespace i18n = 'influx/i18n';
import module namespace global ='influx/global';
import module namespace ui='influx/ui2';
import module namespace plugin='influx/plugin';
import module namespace rest = "http://exquery.org/ns/restxq";
import module namespace request = "http://exquery.org/ns/request";

import module namespace db = "influx/db";

declare namespace xhtml = "http://www.w3.org/1999/xhtml";
declare namespace mod="http://influx.adesso.de/module";

(: declare local variables :)
declare variable $_:module := doc("module.xml")/mod:module;
declare variable $_:module-static := $global:module-path||"/"||$_:module/mod:install-path||"/static";


declare variable $_:status := ("angeboten","beauftragt","offen","abgelehnt");

declare  
  %rest:path("sanofi/blauer-ozean")
  %rest:GET
  %output:method("html")
  %output:version("5.0")
function _:page1() {
  ui:page(map{"id":request:parameter("id"),
    "title": "Blauer Ozean"
    },"sanofi/blauer-ozean")
};

declare
  %rest:path("sanofi/blauer-ozean/radar-chart/{$Id}")
  %rest:GET
  %output:method("html")
  %output:version("5.0")
function _:page-radar-chart($Id) {
    let $provider := "sanofi/blauer-ozean"
    let $request-parameter := map:merge(request:parameter-names() ! map{. : request:parameter(.)})
    let $context := $request-parameter => map:get("context")
    let $schema  := plugin:provider-lookup($provider,"schema")!.()
    let $item    := plugin:provider-lookup($provider,"datastore/dataobject",$context)!.($Id, $schema, $request-parameter)
    return
    plugin:provider-lookup("sanofi/blauer-ozean","content/view","kk")($item,$schema,$request-parameter)
};

declare
  %rest:path("admin/sanofi/import-products")
  %rest:GET
  %output:method("html")
  %output:version("5.0")
function _:page-product-importer() {
  ui:page(map{
    "title": "Produkte Importieren"
    },"sanofi/import-products")
};

declare
  %rest:path("admin/sanofi/import-users")
  %rest:GET
  %output:method("html")
  %output:version("5.0")
function _:page-user-importer() {
  ui:page(map{
    "title": "Benutzer Importieren"
    },"sanofi/import-users")
};

declare
  %rest:path("sanofi/projekt")
  %rest:GET
  %output:method("html")
  %output:version("5.0")
function _:page100() {
  ui:page(map{"id":request:parameter("id"),
    "title": "Projekte - Gantt"
    },"sanofi/projekt")
};

declare
  %rest:path("sanofi/kam-top-4-kk")
  %rest:GET
  %output:method("html")
  %output:version("5.0")
function _:page-top-4-kk() {
  ui:page(map{
    "title": "KAM Top 4 KK"
    },"sanofi/kam-top-4-kk")
};

declare
  %rest:path("sanofi/kam-top-4-kv")
  %rest:GET
  %output:method("html")
  %output:version("5.0")
function _:page-top-4-kv() {
  ui:page(map{
    "title": "KAM Top 4 KV"
    },"sanofi/kam-top-4-kv")
};

declare
  %rest:path("sanofi/stammdaten/summary")
  %rest:GET
  %output:method("html")
  %output:version("5.0")
function _:page-kam-summary() {
  ui:page(map{
    "title": "Key Account Summary"
    },"stammdaten/summary")
};

declare
  %rest:path("sanofi/stammdaten/lav")
  %rest:GET
  %output:method("html")
  %output:version("5.0")
function _:page-lav() {
  ui:page(map{
    "title": "Stammdaten Landes Apothekenverbände/Vereine"
    },"stammdaten/lav")
};

declare
    %rest:path("sanofi/stammdaten/key-accounter")
    %rest:GET
    %output:method("html")
    %output:version("5.0")
  function _:page-stammdaten-key-accounter() {
    ui:page(map{
      "title": "Stammdaten Key-Accounter"
      },"stammdaten/key-accounter")
  };

  declare
      %rest:path("sanofi/stammdaten/blauer-ozean")
      %rest:GET
      %output:method("html")
      %output:version("5.0")
    function _:page-stammdaten-blauer-ozean() {
      ui:page(map{
        "title": "Foliendaten Blauer Ozean"
        },"stammdaten/blauer-ozean")
    };

declare
    %rest:path("sanofi/stammdaten/stakeholder")
    %rest:GET
    %output:method("html")
    %output:version("5.0")
  function _:page-stammdaten-stakeholder() {
    ui:page(map{
      "title": "Stammdaten Stakeholder"
      },"stammdaten/stakeholder")
  };

declare
    %rest:path("sanofi/stammdaten/ansprechpartner")
    %rest:GET
    %output:method("html")
    %output:version("5.0")
  function _:page-stammdaten-ansprechpartner() {
    ui:page(map{
      "title": "Stammdaten Ansprechpartner"
      },"stammdaten/ansprechpartner")
  };

declare
    %rest:path("sanofi/stammdaten/produkt")
    %rest:GET
    %output:method("html")
    %output:version("5.0")
  function _:page-stammdaten-produkte() {
    ui:page(map{
      "title": "Stammdaten Produkte"
      },"stammdaten/produkt")
  };

declare
    %rest:path("sanofi/stammdaten/projekt")
    %rest:GET
    %output:method("html")
    %output:version("5.0")
  function _:page-stammdaten-projekt() {
    ui:page(map{
      "title": "Stammdaten Projekte"
      },"stammdaten/projekt")
  };

declare
    %rest:path("sanofi/stammdaten/kv")
    %rest:GET
    %output:method("html")
    %output:version("5.0")
  function _:page-stammdaten-kv() {
    ui:page(map{
      "title": "Stammdaten Kassenärztliche Vereinigungen"
      },"stammdaten/kv")
  };

declare
    %rest:path("sanofi/stammdaten/kk")
    %rest:GET
    %output:method("html")
    %output:version("5.0")
  function _:page-stammdaten-kk() {
    ui:page(map{
      "title": "Stammdaten Krankenkassen"
      },"stammdaten/kk")
  };

declare
    %rest:path("sanofi/stammdaten/wirkstoff")
    %rest:GET
    %output:method("html")
    %output:version("5.0")
  function _:page-stammdaten-wirkstoff() {
    ui:page(map{
      "title": "Stammdaten Wirkstoffe"
      },"stammdaten/wirkstoff")
  };
declare
    %rest:path("sanofi/stammdaten/indikation")
    %rest:GET
    %output:method("html")
    %output:version("5.0")
  function _:page-stammdaten-indikation() {
    ui:page(map{
      "title": "Stammdaten Indikationen"
      },"stammdaten/indikation")
  };

declare
        %rest:path("sanofi/stammdaten/vertrag")
        %rest:GET
        %output:method("html")
        %output:version("5.0")
      function _:page-stammdaten-vertrag() {
        ui:page(map{
          "title": "Stammdaten Verträge"
          },"stammdaten/vertrag")
      };
