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
  %rest:path("admin/sanofi/import-kenngroessen")
  %rest:GET
  %output:method("html")
  %output:version("5.0")
function _:page-kenngroessen-importer() {
  ui:page(map{
    "title": "Kenngrößen Importieren"
    },"sanofi/import-kenngroessen")
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
