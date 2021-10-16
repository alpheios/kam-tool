module namespace _="sanofi/api/user-import";

import module namespace plugin='influx/plugin';
import module namespace rest = "http://exquery.org/ns/restxq";
import module namespace alert='influx/ui/alert';
import module namespace import="influx/modules";

declare namespace xhtml = "http://www.w3.org/1999/xhtml";
declare namespace mod="http://influx.adesso.de/module";

declare %rest:path("/api/sanofi/import-users")
        %rest:POST
        %rest:form-param("file", "{$Files}")
function _:upload-app-req(
    $Files as map(xs:string, xs:base64Binary)
) {

  if (count(map:keys($Files)) > 1)
  then
    alert:error(<span data-i18n="to-many-files-uploaded">You uploaded to many files.</span>)
  else
    let $usersString := 
      for $fileName in map:keys($Files)
      return convert:binary-to-string($Files($fileName))

    let $tempFilePath := file:base-dir()||"temp-users.csv"
    let $tempFile := file:write-text($tempFilePath, $usersString)

    let $users := csv:parse($usersString, map {
        'separator': ';',
        'header': true()
    })/*:csv/*:record

    let $header := $users[1]/*/name()

    return _:render-users(
      $users,
      $header
    )
};

declare %rest:path("/api/sanofi/import-users/import")
        %rest:GET
function _:api-import-users() {
  let $tempFilePath := file:base-dir()||"temp-users.csv"
  let $users := 
    if(file:exists($tempFilePath))
    then 
      let $usersFromCsv := csv:parse(file:read-text($tempFilePath), map {
        'separator': ';',
        'header': true()
      })/*:csv/*:record
      let $deleteTempFile := file:delete($tempFilePath)
      return $usersFromCsv
    else ()

  return
    if ($users)
    then
      let $importUsersFailed := _:import-users($users)
      return
        if (not($importUsersFailed))
        then (
          alert:info(<span data-i18n="import-users-success">users successfully imported.</span>),
          <div data-remove="#users-list" data-animation="fadeOutRight"></div>
        )
        else alert:error(<span data-i18n="import-users-failed-during-db-operation">Import of users failed due to database operations.</span>)
    else
      alert:error(<span data-i18n="import-users-failed-no-users">No users to import.</span>)
};

declare function _:extract-username($entry as element()) {
    if (exists($entry/username))
    then $entry/username
    else 
        lower-case(substring($entry/Vorname/string(), 1, 1)||$entry/Name/string())
};

declare function _:extract-userrole($entry as element()) {
    if (lower-case($entry/Rolle/string()) = "admin")
    then "admin"
    else "user"
};

declare function _:import-users(
  $users as element(record)*
) as xs:boolean {
  let $provider := "sanofi/key-accounter"
  let $schema := plugin:provider-lookup($provider,"schema")!.()
  let $userMaps :=
    for $user in $users
    let $username := _:extract-username($user)
    let $firstname := $user/Vorname/string()
    let $lastname := $user/Name/string()
    let $role := _:extract-userrole($user)
    return map {
      'name': $username,
      'username': $username,
      'vorname': $firstname,
      'nachname': $lastname,
      'role': $role
    }
  let $schemaUsers :=
    for $user in $userMaps
    return plugin:lookup('schema/instance/new/from/form')!.($schema, $user) update replace value of node ./@last-modified-date with current-dateTime()

  let $importUsers :=
    for $user in $schemaUsers
    return plugin:lookup('datastore/dataobject/put')!.($user, $schema, map {})

  return $importUsers = false()
};

declare function _:render-users(
  $users as element(record)*,
  $Header as xs:string*
) {
  <div id="users-list" data-replace="#users-list" data-animation="fadeInLeft" class="clearfix">
    <h2>Benutzer</h2>
    <table style="margin-top:15px" class="table table-hover table-striped table-borderless">
      <thead>
      <tr>
      {
        for $columnTitle in ("Username", "Vorname", "Nachname", "Rolle")
        return <th><div><span>{$columnTitle}</span></div></th>
      }
      </tr>
      </thead>
      <tbody>
      {
        for $user in $users
          let $username := _:extract-username($user)
          let $firstname := $user/Vorname/string()
          let $lastname := $user/Name/string()
          let $role := _:extract-userrole($user)
          return _:render-user-row($username, $firstname, $lastname, $role)
      }
      </tbody>
    </table>
    <h4><strong>Insgesamt: </strong>{count($users)}</h4>
    <a href="{rest:base-uri()}/api/sanofi/import-users/import" class="ajax pull-right btn btn-primary">Benutzer importieren</a>
  </div>
};

declare function _:render-user-row(
  $username as xs:string, 
  $firstname as xs:string, 
  $lastname as xs:string,
  $role as xs:string
) {
  <tr>
    <td>{$username}</td>
    <td>{$firstname}</td>
    <td>{$lastname}</td>
    <td>{$role}</td>
  </tr>
};
