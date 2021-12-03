module namespace _="sanofi/choose-columns/api";

import module namespace i18n = 'influx/i18n';
import module namespace global ='influx/global';
import module namespace ui='influx/ui';
import module namespace plugin='influx/plugin';
import module namespace import="influx/modules";

declare namespace xhtml = "http://www.w3.org/1999/xhtml";
declare namespace mod="http://influx.adesso.de/module";
declare namespace functx = "http://www.functx.com";

declare variable $_:meta := doc("../../module.xml")/mod:module;
declare variable $_:enum-path := file:base-dir()||"/enums/";
declare variable $_:ns := "sanofi/choose-columns/provider";

declare %rest:path("/api/sanofi/choose-columns")
        %rest:GET
        %rest:query-param("Field", "{$Field}")
        %output:method("html")
        %output:version("5.0")
function _:replace-editor-field(
  $Field as xs:string
) {
  let $filename := substring-after($Field, "/")
  let $schema := plugin:provider-lookup($Field, "schema")!.()
  let $possibleValues := $schema/*:element/@name/string()
  let $file := plugin:provider-lookup($_:ns,"plato/schema/columns/get/filecontent")!.($filename)
  let $paramMap := map {
    "id": $filename||"-editor",
    "height": "700px",
    "filename": $filename,
    "modifier": $_:ns
  }

  return 
    <div id="editor-area" class="clearfix" data-replace="#editor-area">
      <div class="panel panel-info">
          <div class="panel-heading">
              <i class="fa fa-info-circle"></i> Mögliche Felder sind hier aufgelistet. Bitte die Schreibweise beachten.
          </div>
          <div class="panel-body">
              <ul>
              {
                for $val in $possibleValues
                return
                  <li>{$val}</li>
              }
              </ul>
          </div>

      </div>
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

