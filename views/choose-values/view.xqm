module namespace _="sanofi/views/choose-values";

import module namespace global ='influx/global';
import module namespace plugin='influx/plugin';
import module namespace alert="influx/ui/alert";
import module namespace common="sanofi/common/view" at "../common.xqm";
import module namespace import="influx/modules";

declare namespace xhtml = "http://www.w3.org/1999/xhtml";
declare namespace mod="http://influx.adesso.de/module";
declare namespace functx = "http://www.functx.com";


declare variable $_:meta := doc("../../module.xml")/mod:module;
declare variable $_:module-static := $global:module-path||"/"||$_:meta/mod:install-path||"/static";
declare variable $_:ns := namespace-uri(<_:ns/>);
declare variable $_:title := "Auswahlwerte für Auswahlfelder festlegen";

declare %plugin:provide('side-navigation-item')
        %plugin:allow("admin")
  function _:nav-item-kam()
  as element(xhtml:li) {
  <li xmlns="http://www.w3.org/1999/xhtml" data-parent="/admin" data-sortkey="M">
      <a href="{$global:servlet-prefix}/admin/api/page?provider={$_:ns}"><i class="fa fa-list-alt"></i> <span data-i18n="side-navigation-choose-values" class="nav-label">Auswahlwerte festlegen</span></a>
  </li>
};

declare %plugin:provide('ui/page/title') function _:heading($m){$_:title};
declare %plugin:provide("ui/page/heading") function _:ui-page-heading($m){common:ui-page-heading($m)};


declare %plugin:provide-default("editor/code")
function _:default-code-editor(
  $Content as xs:string,
  $ParamMap as map(*)
) {
  <h4 class="text-danger">No Code Editor Installed</h4>
};

declare %plugin:provide("ui/page/custom-js")
function _:page-custom-js($map){  
plugin:provider-lookup(plugin:lookup("editor/code")=>plugin:provider(),"ui/page/custom-js")!.($map)
,

  <script type="text/javascript" src="{$_:module-static}/js/choose-values.js"></script>
};



declare %plugin:provide("ui/page/content")
function _:sanofi-choose-values(
  $map as map(*)
) as element(xhtml:div) {
<div xmlns="http://www.w3.org/1999/xhtml">
  <div class="form-body">
    <label class="form-label" for="felder">Felder:</label>
    <select class="form-control select2" id="felder" onchange="replaceValueEditor('{$global:servlet-prefix}', this)">
    <option disabled="" selected="">Wähle ein Auswahlfeld</option>
    {
      let $felder := plugin:lookup("plato/schema/enums/get")!.("Felder")
      return
        for $feld in $felder
        return <option>{$feld}</option>
    }
    </select>
  </div>
  <script>$(".select2").select2()</script>
  <br/>
  <div class="m-b" id="editor-area"></div>
</div> => common:ui-page($_:title)
};

declare %plugin:provide("editor/code/save/content")
function _:save-enum-file(
  $Id as xs:string,
  $Filename as xs:string,
  $Content as xs:string
) {
  let $content := replace(functx:trim($Content), "(\n\r)", "")
  let $saveFile := plugin:lookup("plato/schema/enums/set/filecontent")!.($Filename, $content)
  return
    alert:info('Werte für das Feld "'||translate($Filename, "-", " ")||'" sind erfolgreich gespeichert worden.')
};

declare %plugin:provide("editor/code/custom/js")
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