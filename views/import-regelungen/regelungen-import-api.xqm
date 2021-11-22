module namespace _="sanofi/api/regelungen-import";

import module namespace plugin='influx/plugin';
import module namespace rest = "http://exquery.org/ns/restxq";
import module namespace global ='influx/global';
import module namespace ui='influx/ui';
import module namespace db='influx/db';
import module namespace date-util ="influx/utils/date-utils";

declare namespace functx = "http://www.functx.com";

declare namespace xhtml = "http://www.w3.org/1999/xhtml";
declare namespace mod="http://influx.adesso.de/module";

declare variable $_:meta := doc("../../module.xml")/mod:module;
declare variable $_:module-static := $global:module-path||"/"||$_:meta/mod:install-path||"/static";

declare %rest:path("/api/sanofi/import-regelungen")
        %rest:POST
        %rest:form-param("file", "{$Files}")
function _:upload-app-req(
    $Files as map(xs:string, xs:base64Binary)
) {

  if (count(map:keys($Files)) > 1)
  then
    ui:error(<span data-i18n="to-many-files-uploaded">You uploaded to many files.</span>)
  else
    let $regelungenString := 
      for $fileName in map:keys($Files)
      return convert:binary-to-string($Files($fileName), "iso-8859-1")

    let $tempFilePath := file:base-dir()||"temp-regelungen.csv"
    let $tempFile := file:write-text($tempFilePath, $regelungenString)

    let $regelungen := csv:parse($regelungenString, map {
        'separator': 'tab',
        'header': true()
    })/*:csv/*:record
    
    let $header := $regelungen[1]/*/name()

    return _:render-regelungen(
      $regelungen,
      $header
    )
};

declare %rest:path("/api/sanofi/import-regelungen/import")
        %rest:GET
function _:api-import-regelungen() {
  let $tempFilePath := file:base-dir()||"temp-regelungen.csv"
  let $regelungen := 
    if(file:exists($tempFilePath))
    then 
      let $regelungenFromCsv := csv:parse(file:read-text($tempFilePath), map {
        'separator': 'tab',
        'header': true()
      })/*:csv/*:record
      let $deleteTempFile := file:delete($tempFilePath)
      return $regelungenFromCsv
    else ()

  let $importregelungen := _:import-regelungen($regelungen)
  return
        if ($importregelungen)
        then (
            ui:info(<span data-i18n="import-regelungen-success">regelungen successfully imported.</span>),
            <div data-remove="#regelungen-list" data-animation="fadeOutRight"></div>
          )
        else ui:error(<span data-i18n="import-regelungen-failed-during-db-operation">Import of regelungen failed.</span>)
};

declare function _:import-regelungen(
  $records as element(record)*
) as xs:boolean {

  let $provider := "sanofi/regelung"
  let $schema := plugin:provider-lookup($provider,"schema")!.()
  
  let $side-effects :=
  for $record in $records
  return 

    let $regelung-map := map:merge(
      for $field in $record/element()
      return map{$field/name() : $field/string()}
    )
    let $regelung-map := $regelung-map ! map:put(.,"@id",.?id)
    let $regelung-item := plugin:lookup('schema/instance/new/from/form')!.($schema, $regelung-map) update replace value of node ./@last-modified-date with current-dateTime()
    return plugin:lookup("datastore/dataobject/put")!.($regelung-item,$schema,map {})
    return every $x in $side-effects satisfies $x=true()
};

declare function _:extract-datum-from-quartal-string(
  $Datum as xs:string
) as xs:string {
  let $parts := tokenize($Datum, "/")
  let $quartal := upper-case($parts[1])
  let $year :=
    if (string-length($parts[2]) = 2)
    then "20"||$parts[2]
    else $parts[2]
  let $day-month :=
    switch ($quartal)
    case "Q1" return "01.01."
    case "Q2" return "01.04."
    case "Q3" return "01.07."
    case "Q4" return "01.10."
    default return "01.01."
  return $day-month||$year
};

declare function _:check-if-data-for-date-allready-exist(
  $KK as xs:string,
  $Date as xs:string
) as xs:boolean {
  let $history-provider := "sanofi/kk-top-4"
  let $context := "regelungen-import"
  let $context-map := map {
    "context": $context
  }
  let $schema := plugin:provider-lookup($history-provider, "schema")!.()
  let $history-data := plugin:lookup("datastore/dataobject/field", $context)!.("kk", $KK, $schema, $context-map)
  return $history-data/datum/string() = $Date
};

declare function _:get-kv-id-by-name(
  $Name as xs:string
) as xs:string? {
  let $kk-provider := "sanofi/kv"
  let $context := "regelungen-import"
  let $context-map := map {
    "context": $context
  }
  let $schema := plugin:provider-lookup($kk-provider, "schema")!.()
  let $kk := plugin:lookup("datastore/dataobject/field", $context)!.("name", $Name, $schema, $context-map)
  return $kk/@id/string()
};

declare function _:check-foreign-key(
  $Id as xs:string
  ,$Provider
) as xs:boolean {
  let $context := "regelungen-import"
  let $context-map := map {
    "context": $context
  }
  let $schema := plugin:provider-lookup($Provider, "schema")!.()
  let $kv := plugin:lookup("datastore/dataobject", $context)!.($Id, $schema, $context-map)
  return if ($kv) then true() else false()
};

declare function _:render-regelungen(
  $regelungen as element(record)*,
  $Header as xs:string*
) {
  let $schema := plugin:provider-lookup("sanofi/regelung","schema")!.()
  return
  <div id="regelungen-list" data-replace="#regelungen-list" data-animation="fadeInLeft" class="clearfix">
    <h2>Spalten mit IDs: grün=wird überschrieben, NEU=wird neu angelegt, rot=nicht gefundene Referenz</h2>
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
        for $kenngroesse in $regelungen
        return _:render-kenngroesse-row($kenngroesse,$schema)
      }
      <tr>
        <td>...</td>
      </tr>
      </tbody>
    </table>
    <h4><strong>Insgesamt: </strong>{count($regelungen)}</h4>
    <a href="{$global:servlet-prefix}/api/sanofi/import-regelungen/import" class="ajax pull-right btn btn-primary">Regelungen importieren</a>
  </div>
};

declare function _:render-kenngroesse-row(
  $Kenngroesse as element(record)
  ,$schema
) {
  <tr>
    {
      for $column in $Kenngroesse/*
      let $schema-element := $schema/element[@name=name($column)]
      let $color := 
        if (name($column)="id") then 
          if ($column!="") then 
            if (_:check-foreign-key($column,"sanofi/regelung")) then ('green') 
            else 'red' 
          else 'NEU'
        else 
          if ($schema-element[@type='foreign-key'][not(@render='table')]) then 
            if (_:check-foreign-key($column,$schema-element/provider)) then 'green' 
            else 'red' 
          else ''
      return <td style="color:{$color}">{if ($color="NEU") then "NEU" else ""}{$column/string()}</td>
    }
  </tr>
};
