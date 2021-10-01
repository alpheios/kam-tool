module namespace _="sales-management";

import module namespace providers               = "sanofi/providers" at "kam-tool-providers.xqm";
import module namespace requests                = "sanofi/requests" at "kam-tool-requests.xqm";

import module namespace kv                      = "sanofi/kv" at "resources/kv.xqm";
import module namespace ansprechpartner         = "sanofi/ansprechpartner" at "resources/ansprechpartner.xqm";
import module namespace ansprechpartner-einfluss= "sanofi/ansprechpartner/einfluss" at "resources/ansprechpartner-einfluss.xqm";
import module namespace kk                      = "sanofi/kk" at "resources/kk.xqm";
import module namespace lav                     = "sanofi/lav" at "resources/lav.xqm";
import module namespace produkt                 = "sanofi/produkt" at "resources/produkt.xqm";
import module namespace projekt                 = "sanofi/projekt" at "resources/projekt.xqm";
import module namespace vertrag                 = "sanofi/vertrag" at "resources/vertrag.xqm";
import module namespace regelung                = "sanofi/regelung" at "resources/regelung.xqm";
import module namespace ka                      = "sanofi/key-accounter" at "resources/key-accounter.xqm";
import module namespace blauer-ozean-resource   = "sanofi/blauer-ozean" at "resources/blauer-ozean.xqm";
import module namespace management-summary      = "sanofi/management-summary" at "resources/management-summary.xqm";
import module namespace news                    = "sanofi/news" at "resources/news.xqm";
import module namespace tracking                = "sanofi/tracking" at "resources/tracking.xqm";
(: REGELUNGEN Quote + Glossar -- 18.12.2020 :)
import module namespace quote                   = "sanofi/quote" at "resources/quote.xqm";
import module namespace glossar                 = "sanofi/glossar" at "resources/glossar.xqm";

import module namespace kk-top-4                = "sanofi/kk-top-4" at "resources/kk-top-4.xqm";
import module namespace kv-top-4                = "sanofi/kv-top-4" at "resources/kv-top-4.xqm";
import module namespace kv-arztzahlen           = "sanofi/kv-arztzahlen" at "resources/kv-arztzahlen.xqm";

import module namespace product-importer        = "sanofi/views/product-import" at "views/import-products/product-import.xqm";
import module namespace product-importer-api    = "sanofi/api/product-import" at "views/import-products/product-import-api.xqm";
import module namespace user-importer           = "sanofi/views/user-import" at "views/import-users/user-import.xqm";
import module namespace user-importer-api       = "sanofi/api/user-import" at "views/import-users/user-import-api.xqm";
import module namespace kenngroessen-importer        = "sanofi/views/kenngroessen-import" at "views/import-kk-kenngroessen/kenngroessen-import.xqm";
import module namespace kenngroessen-importer-api    = "sanofi/api/kenngroessen-import" at "views/import-kk-kenngroessen/kenngroessen-import-api.xqm";
(: REGELUNGEN IMPORTER -- 14.12.2020 :)
import module namespace regelungen-importer        = "sanofi/views/regelungen-import" at "views/import-regelungen/regelungen-import.xqm";
import module namespace regelungenssen-importer-api    = "sanofi/api/regelungen-import" at "views/import-regelungen/regelungen-import-api.xqm";


import module namespace choose-values           = "sanofi/views/choose-values" at "views/choose-values/choose-values.xqm";
import module namespace choose-values-provider  = "sanofi/provider/choose-values" at "views/choose-values/choose-values-provider.xqm";
import module namespace choose-values-api       = "sanofi/api/choose-values" at "views/choose-values/choose-values-api.xqm";

import module namespace choose-columns          = "sanofi/views/choose-columns" at "views/choose-columns/choose-column.xqm";
import module namespace choose-columns-provider = "sanofi/provider/choose-columns" at "views/choose-columns/choose-column-provider.xqm";
import module namespace choose-columns-api      = "sanofi/api/choose-columns" at "views/choose-columns/choose-column-api.xqm";
