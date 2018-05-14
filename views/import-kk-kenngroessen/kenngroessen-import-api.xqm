module namespace _="sanofi/api/kenngroessen-import";

import module namespace plugin='influx/plugin';
import module namespace rest = "http://exquery.org/ns/restxq";
import module namespace global ='influx/global';
import module namespace ui='influx/ui2';
import module namespace db='influx/db';
import module namespace date-util ="influx/utils/date-utils";

declare namespace functx = "http://www.functx.com";

declare namespace xhtml = "http://www.w3.org/1999/xhtml";
declare namespace mod="http://influx.adesso.de/module";

declare variable $_:meta := doc("../../module.xml")/mod:module;
declare variable $_:module-static := $global:module-path||"/"||$_:meta/mod:install-path||"/static";

declare %rest:path("/api/sanofi/import-kenngroessen")
        %rest:POST
        %rest:form-param("file", "{$Files}")
function _:upload-app-req(
    $Files as map(xs:string, xs:base64Binary)
) {

  if (count(map:keys($Files)) > 1)
  then
    ui:error(<span data-i18n="to-many-files-uploaded">You uploaded to many files.</span>)
  else
    let $kenngroessenString := 
      for $fileName in map:keys($Files)
      return convert:binary-to-string($Files($fileName))

    let $tempFilePath := file:base-dir()||"temp-kenngroessen.csv"
    let $tempFile := file:write-text($tempFilePath, $kenngroessenString)

    let $kenngroessen := csv:parse($kenngroessenString, map {
        'separator': ';',
        'header': true()
    })/*:csv/*:record
    
    let $header := $kenngroessen[1]/*/name()

    return _:render-kenngroessen(
      $kenngroessen,
      $header
    )
};

declare %rest:path("/api/sanofi/import-kenngroessen/import")
        %rest:GET
function _:api-import-kenngroessen() {
  let $tempFilePath := file:base-dir()||"temp-kenngroessen.csv"
  let $kenngroessen := 
    if(file:exists($tempFilePath))
    then 
      let $kenngroessenFromCsv := csv:parse(file:read-text($tempFilePath), map {
        'separator': ';',
        'header': true()
      })/*:csv/*:record
      let $deleteTempFile := file:delete($tempFilePath)
      return $kenngroessenFromCsv
    else ()

  let $missingKKs :=
    for $kenngroesse in $kenngroessen
    let $kkid := _:get-kk-id-by-name($kenngroesse/Name/string())
    return
      if ($kkid)
      then ()
      else $kenngroesse/Name/string()

  return
    if ($kenngroessen)
    then
      let $importkenngroessen := _:import-kenngroessen($kenngroessen)
      return
        if ($importkenngroessen)
        then 
          if ($missingKKs)
          then (
            ui:warn(<span><span data-i18n="import-kenngroessen-missing-kks">kenngroessen successfully imported, but some KK are missing: </span>{
              for $missing in $missingKKs
              return $missing||","
            }</span>),
            <div data-remove="#kenngroessen-list" data-animation="fadeOutRight"></div>
          )
          else (
            ui:info(<span data-i18n="import-kenngroessen-success">kenngroessen successfully imported.</span>),
            <div data-remove="#kenngroessen-list" data-animation="fadeOutRight"></div>
          )
        else ui:error(<span data-i18n="import-kenngroessen-failed-during-db-operation">Import of kenngroessen failed due to database operations.</span>)
    else
      ui:error(<span data-i18n="import-kenngroessen-failed-no-kenngroessen">No kenngroessen to import.</span>)
};

declare function _:import-kenngroessen(
  $Kenngroessen as element(record)*
) as xs:boolean {
  let $provider := "sanofi/kk-top-4"
  let $schema := plugin:provider-lookup($provider,"schema")!.()
  let $kenngroessen :=
    for $kenngroesse in $Kenngroessen
    let $id := $kenngroesse/id/string()
    let $name := 'import-'||date-util:current-date-to-html5-input-date()
    let $kkId := _:get-kk-id-by-name($kenngroesse/Name/string())
    return
      if ($kkId)
      then
        let $datum := functx:mmddyyyy-to-date($kenngroesse/Datum/string())
        let $datumString := xs:string($datum)
        return
          if (_:check-if-data-for-date-allready-exist($kkId, $datumString))
          then ()
          else 
            let $versicherte := $kenngroesse/Versicherte/string()
            let $versicherte_marktanteil := translate($kenngroesse/Marktanteil/string(),",%", ".")
            let $arzneimittelausgaben := translate($kenngroesse/Arzneimittel_Ausgaben_Gesamt/string(), ".€", "")
            let $arzneimittelausgaben_marktanteil := translate($kenngroesse/Marktanteil_Arzneimittelausgaben/string(), ",%",".")
            return map {
              '@id': $id,
              'kk': $kkId,
              'name': $name,
              'datum': $datum,
              'anzahl': $versicherte,
              'marktanteil': $versicherte_marktanteil,
              'arzneimittelausgaben': $arzneimittelausgaben,
              'arzneimittelausgaben_marktanteil': $arzneimittelausgaben_marktanteil
            }
      else ()
  let $schemaKenngroessen :=
    for $kenngroesse in $kenngroessen
    return plugin:lookup('schema/instance/new/from/form')!.($schema, $kenngroesse) update replace value of node ./@last-modified-date with current-dateTime()

  let $saveValues :=
    for $kenngroesse in $schemaKenngroessen
    return plugin:lookup("datastore/dataobject/put")!.($kenngroesse,$schema,map {})

  return true()
};

declare function _:check-if-data-for-date-allready-exist(
  $KK as xs:string,
  $Date as xs:string
) as xs:boolean {
  let $history-provider := "sanofi/kk-top-4"
  let $context := "kenngroessen-import"
  let $context-map := map {
    "context": $context
  }
  let $schema := plugin:provider-lookup($history-provider, "schema")!.()
  let $history-data := plugin:lookup("datastore/dataobject/field", $context)!.("kk", $KK, $schema, $context-map)
  return $history-data/datum/string() = $Date
};

declare function _:get-kk-id-by-name(
  $Name as xs:string
) as xs:string? {
  let $kk-provider := "sanofi/kk"
  let $context := "kenngroessen-import"
  let $context-map := map {
    "context": $context
  }
  let $schema := plugin:provider-lookup($kk-provider, "schema")!.()
  let $kk := plugin:lookup("datastore/dataobject/field", $context)!.("name", $Name, $schema, $context-map)
  return $kk/@id/string()
};

declare function _:render-kenngroessen(
  $Kenngroessen as element(record)*,
  $Header as xs:string*
) {
  <div id="kenngroessen-list" data-replace="#kenngroessen-list" data-animation="fadeInLeft" class="clearfix">
    <h2>Kenngrößen</h2>
    <table style="margin-top:15px" class="table table-hover table-striped table-borderless">
      <thead>
      <tr>
      {
        for $columnTitle in $Header
        return <th><div><span>{$columnTitle}</span></div></th>
      }
      </tr>
      </thead>
      <tbody>
      {
        for $kenngroesse in subsequence($Kenngroessen, 1, 5)
        return _:render-kenngroesse-row($kenngroesse)
      }
      <tr>
        <td>...</td>
      </tr>
      </tbody>
    </table>
    <h4><strong>Insgesamt: </strong>{count($Kenngroessen)}</h4>
    <a href="{$global:servlet-prefix}/api/sanofi/import-kenngroessen/import" class="ajax pull-right btn btn-primary">Kenngrößen importieren</a>
  </div>
};

declare function _:render-kenngroesse-row(
  $Kenngroesse as element(record)
) {
  <tr>
    {
      for $column in $Kenngroesse/*
      return <td>{$column/string()}</td>
    }
  </tr>
};
