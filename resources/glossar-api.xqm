module namespace _="sanofi/glossar/api";

import module namespace rest   = "http://exquery.org/ns/restxq";
import module namespace request = "http://exquery.org/ns/request";
import module namespace datastore="influx/schema/datastore";
import module namespace glossar = "sanofi/glossar" at "glossar.xqm";
import module namespace page ="xhtml/page";

declare namespace xhtml = "http://www.w3.org/1999/xhtml";
declare namespace mod="http://influx.adesso.de/module";

import module namespace schema    = "influx/schema";


(:
    open a resource by id and load it into a form
:)



declare
    %rest:path("sanofi/glossar")
    %rest:GET
    %output:method("html")
    %output:version("5.0")
    %rest:query-param("context","{$Context}")
  function _:schema-list-items($Context as xs:string?) {
    let $request-parameters := map:merge(request:parameter-names() ! map{. : request:parameter(.)})
    let $contextMap := _:createContextMap($request-parameters)
    let $items := if ($contextMap?schema) then datastore:list($contextMap?schema,$contextMap)
    let $contextMap := map:put($contextMap, "items", $items)
    return
      page:new()
};

declare function _:createContextMap($request-parameters as map(*)) as map(*){
    let $item-id 	     	  := $request-parameters("item-id")
    let $provider					 := "sanofi/glossar"
    let $context            := $request-parameters("context")
    let $isModal            := if (string($request-parameters("modal"))="true") then true() else false() 
    let $schema             := glossar:schema()
    return 
      map{
         "id"       : $item-id
        ,"provider" : $provider
        ,"context"  : $context
        ,"item"     : if ($item-id and $schema) then (datastore:get($item-id, $schema, $request-parameters))
        ,"schema"   : $schema
        ,"contextType"   : $request-parameters("contextType")
        ,"modal"	  : $isModal
        ,"request-parameters":$request-parameters
        
  }
};