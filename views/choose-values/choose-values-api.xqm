module namespace _="sanofi/api/choose-values";

import module namespace i18n = 'influx/i18n';
import module namespace global ='influx/global';
import module namespace ui='influx/ui2';
import module namespace plugin='influx/plugin';

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
  let $file := plugin:lookup("plato/schema/enums/get/filecontent")!.($Field)
  let $paramMap := trace(map {
    "id": $Field||"-editor",
    "filename": $Field,
    "modifier": "sanofi/auswahlwerte"
  }, "Param Map: ")

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

declare %plugin:provide("editor/code/save/content", "sanofi/auswahlwerte")
function _:save-enum-file(
  $Id as xs:string,
  $Filename as xs:string,
  $Content as xs:string
) {
  let $content := replace(functx:trim($Content), "(\n\r)", "")
  let $saveFile := plugin:lookup("plato/schema/enums/set/filecontent")!.($Filename, $content)
  return
    ui:info('Werte für das Feld "'||translate($Filename, "-", " ")||'" sind erfolgreich gespeichert worden.')
};

declare %plugin:provide("editor/code/custom/js", "sanofi/auswahlwerte")
function _:adjust-editor-height(
  $Content as xs:string,
  $Config as map(*)
) as xs:string {
  let $numberOfLines := count(tokenize($Content, "\n")) + 5
  let $numberOfLines :=
    if ($numberOfLines < 40)
    then 40
    else $numberOfLines

  return "
    editor.setOptions({maxLines: "||$numberOfLines||"});
    editor.focus();
  "
};