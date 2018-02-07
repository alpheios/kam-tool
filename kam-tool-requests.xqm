module namespace _="sanofi/requests";

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
    let $schema  := plugin:provider-lookup($provider,"schema",$context)!.()
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
  %rest:path("admin/sanofi/choose-values")
  %rest:GET
  %output:method("html")
  %output:version("5.0")
function _:page-choose-values() {
  ui:page(map{
    "title": "Auswahlwerte für Auswahlfelder festlegen"
    },"sanofi/choose-values")
};

declare
  %rest:path("admin/sanofi/choose-columns")
  %rest:GET
  %output:method("html")
  %output:version("5.0")
function _:page-choose-columns() {
  ui:page(map{
    "title": "Spalten für Entitäten festlegen"
    },"sanofi/choose-columns")
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

