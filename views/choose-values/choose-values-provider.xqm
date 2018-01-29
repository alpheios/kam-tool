module namespace _="sanofi/provider/choose-values";

import module namespace i18n = 'influx/i18n';
import module namespace global ='influx/global';
import module namespace ui='influx/ui2';
import module namespace plugin='influx/plugin';

declare namespace xhtml = "http://www.w3.org/1999/xhtml";
declare namespace mod="http://influx.adesso.de/module";

declare variable $_:meta := doc("../../module.xml")/mod:module;
declare variable $_:enum-path := file:base-dir()||"/enums/";

declare %plugin:provide("plato/schema/enums/get")
function _:get-enums(
  $Name as xs:string
) as xs:string* {
  let $filepath := $_:enum-path||translate($Name, " ", "-")||"-enum.txt"

  return
    if (file:exists($filepath))
    then file:read-text-lines($filepath)
    else ""
};

declare %plugin:provide("plato/schema/enums/get/filecontent")
function _:get-enums-file(
  $Name as xs:string
) as xs:string {
  let $filepath := $_:enum-path||translate($Name, " ", "-")||"-enum.txt"

  return
    if (file:exists($filepath))
    then file:read-text($filepath)
    else ""
};

declare %plugin:provide("plato/schema/enums/set/filecontent")
function _:write-enum-file(
  $Name as xs:string,
  $Content as xs:string
) {
  let $filepath := $_:enum-path||translate($Name, " ", "-")||"-enum.txt"

  return file:write-text($filepath, $Content)
};

declare %plugin:provide("plato/schema/enums/set")
function _:write-enum(
  $Name as xs:string,
  $Content as xs:string*
) {
  let $filepath := $_:enum-path||translate($Name, " ", "-")||"-enum.txt"

  return file:write-text-lines($filepath, $Content)
};
