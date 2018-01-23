module namespace _ = "sanofi/key-accounter";

(: import repo modules :)
import module namespace global	= "influx/global";
import module namespace plugin	= "influx/plugin";
import module namespace db	    = "influx/db";
import module namespace ui =" influx/ui2";

declare namespace xhtml="http://www.w3.org/1999/xhtml";


declare %plugin:provide('side-navigation')
  function _:nav-item-stammdaten-key-accounter()
  as element(xhtml:li) {
  <li xmlns="http://www.w3.org/1999/xhtml" data-parent="/sanofi/stammdaten" data-sortkey="ZZZ">
      <a href="{$global:servlet-prefix}/sanofi/stammdaten/key-accounter"><i class="fa fa-users"></i> <span class="nav-label">Key Accounter</span></a>
  </li>
};

declare %plugin:provide("ui/page/content","stammdaten/key-accounter")
function _:stammdaten-key-accounter($map)
as element(xhtml:div)
{
<div xmlns="http://www.w3.org/1999/xhtml" class="content-with-sidebar row">
  <div class="row">
      <div class="col-lg-12">
            {plugin:lookup("schema/ibox/table")!.("sanofi/key-accounter","stammdaten/key-accounter")}
      </div>
  </div>
</div>
};

declare %plugin:provide("schema/render/modal/debug/itemXXX") function _:debug-kv ($Item,$Schema,$Context){
<pre>{serialize($Item)}</pre>
};

declare %plugin:provide("datastore/name")
function _:set-datastore-name(
  $Schema as element(schema),
  $Context as map(*)
) as xs:string {
  'datastore-sanofi-key-accounter'
};

(:
 If there is no user-id but a username, that means: no user has been created so far
:)
declare %plugin:provide("schema/datastore/dataobject/put/pre-hook")
        %plugin:provide("datastore/dataobject/put/pre-hook")
function _:schema-datastore-dataobject-put-pre-hook($Item as element(),$Schema as element(schema), $Context as map(*)){
let $username := $Item/username/string()
let $firstname := $Item/vorname/string()
let $lastname := $Item/nachname/string()
let $role := $Item/role/string()
let $email := $Item/email/string()
let $userid := $Item/userid/string()
return
    if ($userid="" and $username!="")
        then
            let $userid := try {
              plugin:lookup("api/user-manager/users/create")!.(map {
                'username':$username,
                'firstName':$firstname,
                'lastName':$lastname,
                'email':$email,
                'enabled':'true',
                'requiredActions':
                'UPDATE_PASSWORD',
                'realmRoles':$role
              })
            } catch Q{http://influx.adesso.de/error}IN0002 {
              if (contains($err:description, "User exists with same username"))
              then ()
              else global:error(IN0002, $err:description)
            }
            return
              if ($userid)
              then $Item update replace value of node ./userid with $userid
              else ()
        else 
          let $keycloakUser := plugin:lookup('api/user-manager/users/id')!.($userid)
          let $userMap := map {
            'username': $username,
            'firstName': $firstname,
            'lastName': $lastname,
            'email': $email
          }
          let $updatedKeycloakUserItem := $keycloakUser update {
              for $node in map:keys($userMap)
              return replace value of node ./element()[name() = $node] with $userMap($node)
            }

          let $updateUserInKeycloak := plugin:lookup('api/user-manager/users/put/json')!.($updatedKeycloakUserItem)
          let $deleteOldRealmRole := plugin:lookup('api/user-manager/users/delete/realm-role')!.($userid)
          let $updateRealmRoleOfKeycloakUser := plugin:lookup('api/user-manager/users/add/realm-role')!.($userid, $role)
          return $Item
};

(: provide sorting for items :)
declare %plugin:provide("schema/process/table/items")
function _:schema-render-table-prepare-rows($Items as element()*, $Schema as element(schema),$Context as map(*)){for $item in $Items order by $item/name, $item/priority return $item};

declare %plugin:provide("schema/set/elements")
function _:schema-render-table-prepare-rows-only-name($Items as element()*, $Schema as element(schema),$Context as map(*)){
    let $columns := ("name","interessen")
    let $schema := $Schema update delete node ./*:element
    let $elements-in-order := for $name in $columns return $Schema/element[@name=$name]
    let $schema := $schema update insert node $elements-in-order as last into .
    return $schema};

declare %plugin:provide("schema") function _:schema-customer()
as element(schema){
<schema xmlns="" name="key-accounter" domain="sanofi" provider="sanofi/key-accounter">
    <modal>
        <title>Key-Accounter</title>
        <button>
            <add>hinzufügen</add>
            <cancel>abbrechen</cancel>
            <modify>ändern</modify>
            <delete>löschen</delete>
        </button>
    </modal>
    <element name="interessen" type="enum">
        {("Neue Verträge","Personalien","Neue Richtlinien","Neue Gesetze","Produktänderungen") ! <enum key="{.}">{.}</enum>}
        <label>Interessen/Alerts</label>
    </element>
    <element name="name" type="text">
        <label>Anzeigename</label>
    </element>
    <element name="vorname" type="text">
        <label>Vorname</label>
    </element>
    <element name="nachname" type="text">
        <label>Nachname</label>
    </element>
    <element name="notizen" type="text">
         <label>Notizen</label>
     </element>
     <element name="username" type="text">
          <label>Username</label>
      </element>
     <element name="role" type="enum">
          <label>Rolle</label>
        {("admin","user") ! <enum key="{.}">{.}</enum>}
      </element>
     <element name="email" type="text">
          <label>E-Mail</label>
      </element>
      <element name="userid" type="hidden">
      </element>
 </schema>
};

declare %plugin:provide("schema/render/form/field/username")
 function _:schema-render-field-username-key-accounter(
     $Item as element()?,
     $Element as element(element),
     $Context)
     as element(xhtml:select)
{
     let $schema := $Element/ancestor::schema
     let $assigned-username := $Item/username/string()
     let $key-accounters := plugin:lookup("datastore/dataobject/all")!.($schema,map{})[@id!=$Item/@id]
     let $assigned-usernames := $key-accounters/username/string()
     let $type := $Element/@type
     let $name := $Element/@name
     let $usernames := (plugin:lookup("usernames")!.())[not(.=$assigned-usernames)]
     let $enums := $usernames!<enum key="{.}">{.}</enum>
     let $class := $Element/class/string()
     let $required := $Element/@required
     let $value := $Item/node()[name()=$name]
     return
     <select xmlns="http://www.w3.org/1999/xhtml" name="{$name}" class="form-control chosen-select">{$required}
     <option value="">Nicht zugewiesen</option>
     {
       for $enum in $enums
       return <option value="{$enum/@key}">
                    {if ($enum/@key=$value) then attribute selected {} else ()}
                    {$enum/string()}
              </option>
     }
     </select>
};