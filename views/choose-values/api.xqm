module namespace _="sanofi/choose-values/api";

import module namespace plugin='influx/plugin';
import module namespace import="influx/modules";

declare namespace xhtml = "http://www.w3.org/1999/xhtml";

declare variable $_:enum-path := file:base-dir()||"/enums/";
declare variable $_:ns := "sanofi/choose-values/provider";


declare %rest:path("/api/sanofi/choose-values/{$Field}")
        %rest:GET
        %output:method("html")
        %output:version("5.0")
function _:replace-editor-field(
  $Field as xs:string
) {
  let $file := plugin:provider-lookup($_:ns,"plato/schema/enums/get/filecontent")!.($Field)
  let $paramMap := map {
    "id": $Field||"-editor",
    "filename": $Field,
    "modifier": $_:ns
  }

  return 
    <div id="editor-area" class="clearfix" data-replace="#editor-area" xmlns="http://www.w3.org/1999/xhtml">
      <div>
      {
        plugin:provider-lookup($_:ns,"editor/code")!.($file, $paramMap)
      }
      </div>
      <div class="pull-right m-t-sm">
      {
        plugin:provider-lookup($_:ns,"editor/code/save/button")!.($paramMap)
      }
      </div>
    </div>
};

