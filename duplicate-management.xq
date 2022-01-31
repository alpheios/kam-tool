import module namespace dbx = "influx/db";

let $show-duplicate-ids := "let $items := collection($db)/* for $id in $items/@id => distinct-values() let $duplicates := $items[@id=$id] where count($duplicates) > 1 return $duplicates[1]"

let $show-duplicate-items := "let $items := collection($db)/* for $id in $items/@id => distinct-values() let $duplicates := $items[@id=$id] where count($duplicates) > 1 return $duplicates[1]"

let $delete-duplicates := "let $items := collection($db)/* for $id in $items/@id => distinct-values() let $duplicates := $items[@id=$id] where count($duplicates) > 1 return delete node $duplicates[1]"


return

(
for $db in db:list() 
where $db => starts-with("datastore-sanofi-")
return dbx:eval($show-duplicate-ids,map{"db":$db})

,for $db in db:list() 
where $db => starts-with("datastore-sanofi-")
return dbx:eval($show-duplicate-items,map{"db":$db})
)