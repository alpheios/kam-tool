module namespace _="sanofi/api/choose-values";

import module namespace plugin='influx/plugin';
import module namespace import="influx/modules";
import module namespace ctrl="sanofi/provider/choose-values" at "controller.xqm";
import module namespace view="sanofi/views/choose-values" at "view.xqm";

declare namespace xhtml = "http://www.w3.org/1999/xhtml";
declare namespace mod="http://influx.adesso.de/module";
declare namespace functx = "http://www.functx.com";

declare variable $_:meta := doc("../../module.xml")/mod:module;
declare variable $_:enum-path := file:base-dir()||"/enums/";

declare %rest:path("/api/sanofi/choose-values/{$Field}")
        %rest:GET
        %output:method("html")
        %output:version("5.0")
function _:replace-editor-field(
  $Field as xs:string
) {
  let $file := ctrl:get-enums-file($Field)
  let $paramMap := map {
    "id": $Field||"-editor",
    "filename": $Field,
    "modifier": "sanofi/auswahlwerte"
  }

  return 
    <div id="editor-area" class="clearfix" data-replace="#editor-area">
      <div>
      {
        plugin:lookup("editor/code")!.($file, $paramMap)
      }
      </div>
      <div class="pull-right m-t-sm">
      {
        plugin:lookup("editor/code/save/button")!.($paramMap)
      }
      </div>
    </div>
};

