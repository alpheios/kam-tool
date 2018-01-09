module namespace _="sales-management";

import module namespace providers               = "sales-management/providers" at "sales-cockpit-providers.xqm";
import module namespace requests                = "sales-management/requests" at "sales-cockpit-requests.xqm";

import module namespace kv                      = "sanofi/kv" at "resources/kv.xqm";
import module namespace ansprechpartner         = "sanofi/ansprechpartner" at "resources/ansprechpartner.xqm";
import module namespace kk                      = "sanofi/kk" at "resources/kk.xqm";
import module namespace lav                     = "sanofi/lav" at "resources/lav.xqm";
import module namespace produkt                 = "sanofi/produkt" at "resources/produkt.xqm";
import module namespace projekt                 = "sanofi/projekt" at "resources/projekt.xqm";
import module namespace wirkstoff               = "sanofi/wirkstoff" at "resources/wirkstoff.xqm";
import module namespace indikation              = "sanofi/indikation" at "resources/indikation.xqm";
import module namespace vertrag                 = "sanofi/vertrag" at "resources/vertrag.xqm";
import module namespace stakeholder             = "sanofi/stakeholder" at "resources/stakeholder.xqm";
import module namespace ka                      = "sanofi/key-accounter" at "resources/key-accounter.xqm";
import module namespace summary                 = "sanofi/summary" at "resources/summary.xqm";
import module namespace blauer-ozean-resource   = "sanofi/blauer-ozean" at "resources/blauer-ozean.xqm";


import module namespace blauer-ozean            = "sanofi/views/blauer-ozean" at "views/blauer-ozean.xqm";
import module namespace kam-top-4-kk            = "sanofi/views/kam-top-4-kk" at "views/kam-top-4-kk.xqm";
import module namespace kam-top-4-kv            = "sanofi/views/kam-top-4-kv" at "views/kam-top-4-kv.xqm";
import module namespace projekte-gantt          = "sanofi/views/projekte" at "views/projekte-gantt.xqm";


import module namespace blauer-ozean-task       = "sanofi/task/blauer-ozean/edit/reusable" at "tasks/blauer-ozean-edit-reusable.xqm";
