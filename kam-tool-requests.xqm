module namespace _="sanofi/requests";

import module namespace i18n = 'influx/i18n';
import module namespace global ='influx/global';
import module namespace ui='influx/ui';
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

(: 14.12.2020: REGELUNGEN hinzugefügt :)
declare
  %rest:path("admin/sanofi/import-regelungen")
  %rest:GET
  %output:method("html")
  %output:version("5.0")
function _:page-regelungen-importer() {
  ui:page(map{
    "title": "Regelungen Importieren"
    },"sanofi/import-regelungen")
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
  %rest:path("sanofi/regelung/copy/{$Id}")
  %rest:GET
  %output:method("html")
  %output:version("5.0")
function _:copy-regelung($Id as xs:string) {
  let $Context := map{}
  let $provider           := "sanofi/regelung"
  let $schema     := plugin:provider-lookup($provider,"schema","")()
  let $item       := plugin:provider-lookup($provider,"datastore/dataobject")!.($Id, $schema,$Context)
  let $old-item        := $item update insert node attribute readonly {''} into .
  let $side-effect := plugin:provider-lookup($provider,"datastore/dataobject/put")!.($old-item, $schema, $Context)
  let $item := $item update replace value of node ./@id with random:uuid()
  let $item := $item update replace value of node ./letzte-aenderung with ""
  let $side-effect := plugin:provider-lookup($provider,"datastore/dataobject/put")!.($item, $schema, $Context)
  return (<script class="rxq-js-eval" type="text/javascript">window.location=window.location</script>,ui:info("Regelung kopiert."))
};
