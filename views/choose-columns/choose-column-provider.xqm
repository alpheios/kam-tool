module namespace _="sanofi/provider/choose-columns";

import module namespace i18n = 'influx/i18n';
import module namespace global ='influx/global';
import module namespace ui='influx/ui2';
import module namespace plugin='influx/plugin';

declare namespace xhtml = "http://www.w3.org/1999/xhtml";
declare namespace mod="http://influx.adesso.de/module";

declare variable $_:meta := doc("../../module.xml")/mod:module;
declare variable $_:entities-path := file:base-dir()||"/entities/";

declare %plugin:provide("plato/schema/columns/get")
function _:get-columns(
  $Name as xs:string
) as xs:string* {
  let $filepath := $_:entities-path||translate($Name, " ", "-")||"-columns.txt"

  return
    if (file:exists($filepath))
    then file:read-text-lines($filepath)
    else ""
};

declare %plugin:provide("plato/schema/columns/get/filecontent")
function _:get-columns-file(
  $Name as xs:string
) as xs:string {
  let $filepath := $_:entities-path||translate($Name, " ", "-")||"-columns.txt"

  return
    if (file:exists($filepath))
    then file:read-text($filepath)
    else ""
};

declare %plugin:provide("plato/schema/columns/set/filecontent")
function _:write-columns-file(
  $Name as xs:string,
  $Content as xs:string
) {
  let $filepath := $_:entities-path||translate($Name, " ", "-")||"-columns.txt"

  return file:write-text($filepath, $Content)
};

declare %plugin:provide("plato/schema/columns/set")
function _:write-columns(
  $Name as xs:string,
  $Content as xs:string*
) {
  let $filepath := $_:entities-path||translate($Name, " ", "-")||"-columns.txt"

  return file:write-text-lines($filepath, $Content)
};
