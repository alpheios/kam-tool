module namespace _="sales-management";

import module namespace providers               = "sanofi/providers" at "kam-tool-providers.xqm";
import module namespace requests                = "sanofi/requests" at "kam-tool-requests.xqm";

import module namespace kv                      = "sanofi/kv" at "resources/kv.xqm";
import module namespace ansprechpartner         = "sanofi/ansprechpartner" at "resources/ansprechpartner.xqm";
import module namespace ansprechpartner-einfluss= "sanofi/ansprechpartner/einfluss" at "resources/ansprechpartner-einfluss.xqm";
import module namespace kk                      = "sanofi/kk" at "resources/kk.xqm";
import module namespace kk-summary              = "sanofi/kk-summary" at "resources/kk-summary.xqm";
import module namespace lav                     = "sanofi/lav" at "resources/lav.xqm";
import module namespace produkt                 = "sanofi/produkt" at "resources/produkt.xqm";
import module namespace projekt                 = "sanofi/projekt" at "resources/projekt.xqm";
import module namespace wirkstoff               = "sanofi/wirkstoff" at "resources/wirkstoff.xqm";
import module namespace indikation              = "sanofi/indikation" at "resources/indikation.xqm";
import module namespace vertrag                 = "sanofi/vertrag" at "resources/vertrag.xqm";
import module namespace regelung                = "sanofi/regelung" at "resources/regelung.xqm";
import module namespace ka                      = "sanofi/key-accounter" at "resources/key-accounter.xqm";
import module namespace blauer-ozean-resource   = "sanofi/blauer-ozean" at "resources/blauer-ozean.xqm";
import module namespace kk-top-4-resource       = "sanofi/kk-kam-top-4" at "resources/kk-kam-top-4.xqm";

import module namespace kk-history-mitglieder   = "sanofi/kk-history-mitglieder" at "resources/kk-history-mitglieder.xqm";


import module namespace blauer-ozean            = "sanofi/views/blauer-ozean" at "views/blauer-ozean.xqm";
import module namespace kam-top-4-kk            = "sanofi/views/kam-top-4-kk" at "views/kam-top-4-kk.xqm";
import module namespace kam-top-4-kv            = "sanofi/views/kam-top-4-kv" at "views/kam-top-4-kv.xqm";
import module namespace projekte-gantt          = "sanofi/views/projekte" at "views/projekte-gantt.xqm";


import module namespace product-importer        = "sanofi/views/product-import" at "views/import-products/product-import.xqm";
import module namespace product-importer-api    = "sanofi/api/product-import" at "views/import-products/product-import-api.xqm";
import module namespace user-importer           = "sanofi/views/user-import" at "views/import-users/user-import.xqm";
import module namespace user-importer-api       = "sanofi/api/user-import" at "views/import-users/user-import-api.xqm";

import module namespace choose-values           = "sanofi/views/choose-values" at "views/choose-values/choose-values.xqm";
import module namespace choose-values-provider  = "sanofi/provider/choose-values" at "views/choose-values/choose-values-provider.xqm";
import module namespace choose-values-api       = "sanofi/api/choose-values" at "views/choose-values/choose-values-api.xqm";

import module namespace choose-columns          = "sanofi/views/choose-columns" at "views/choose-columns/choose-column.xqm";
import module namespace choose-columns-provider = "sanofi/provider/choose-columns" at "views/choose-columns/choose-column-provider.xqm";
import module namespace choose-columns-api      = "sanofi/api/choose-columns" at "views/choose-columns/choose-column-api.xqm";