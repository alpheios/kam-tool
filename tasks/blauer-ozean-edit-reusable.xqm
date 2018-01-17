module namespace _="sanofi/task/blauer-ozean/edit/reusable";

(:~
 : <b>product-info</b>
 :
 : @author   Michael Baumert
 : @version  0.0.1
 :)

import module namespace global      = 'influx/global';
import module namespace plugin      = 'influx/plugin';
import module namespace plugin-bpmn = 'influx/plugin-bpmn';
import module namespace ui          = 'influx/ui2';

import module namespace session = 'http://basex.org/modules/session';
import module namespace functx  = "http://www.functx.com";
import module namespace rest    = "http://exquery.org/ns/restxq";

declare namespace xhtml = "http://www.w3.org/1999/xhtml";
declare namespace mod   ="http://influx.adesso.de/module";
declare namespace meta  = "http://influx.adesso.de/metadata";

declare
        %plugin:provide('task/ui/content/tabs-container/tab', 'Task_1')
function _:render-product-info-reusable-task-tab(
    $ProcessInstance as element(ProcessInstance),
    $Token as element(Token)
) {
  (: write dummy product data into dataObject with the given doId :)
  let $context := map{}
  let $doid := $ProcessInstance/@id||"-DataObjectReference_1ld9vcg"
  let $provider := "sanofi/blauer-ozean"
  let $schema := plugin:provider-lookup($provider,"schema")!.()
  let $item := plugin:provider-lookup($provider,"schema/instance/new")!.($schema,$context)
  let $item := $item update replace value of node ./@id with $doid
  return
 <tab status="active" sortkey="BM">
      <title>Schema erstellen</title>
      <content>{
          plugin:provider-lookup($provider,"schema/render/page/form")!.($item,$schema,$context)
          }
          </content>
  </tab>

};

declare
        %plugin:provide('task/ui/content/tabs-container/tab', 'Task_1xzaus8')
function _:render-product-info-reusable-task-tab-read(
    $ProcessInstance as element(ProcessInstance),
    $Token as element(Token)
) {
  (: write dummy product data into dataObject with the given doId :)
  let $context := map{}
  let $doid := $ProcessInstance/@id||"-DataObjectReference_1ld9vcg"
  let $provider := "sanofi/blauer-ozean"
  let $schema := plugin:provider-lookup($provider,"schema")!.()
  let $item := plugin:provider-lookup($provider,"datastore/dataobject")!.($doid,$schema,map{"id":$doid})
  return
 <tab status="active" sortkey="BM">
      <title>Schema erstellen</title>
      <content>
        <div class="col-md-12">
        {
          plugin:provider-lookup($provider,"schema/render/page/form")!.($item,$schema,$context)
        }
        </div>
      </content>
  </tab>

};
