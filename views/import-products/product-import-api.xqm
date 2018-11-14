module namespace _="sanofi/api/product-import";

import module namespace plugin='influx/plugin';
import module namespace rest = "http://exquery.org/ns/restxq";
import module namespace global ='influx/global';
import module namespace ui='influx/ui2';
import module namespace db='influx/db';

declare namespace xhtml = "http://www.w3.org/1999/xhtml";
declare namespace mod="http://influx.adesso.de/module";

declare variable $_:meta := doc("../../module.xml")/mod:module;
declare variable $_:module-static := $global:module-path||"/"||$_:meta/mod:install-path||"/static";

declare %rest:path("/api/sanofi/import-products")
        %rest:POST
        %rest:form-param("file", "{$Files}")
function _:upload-app-req(
    $Files as map(xs:string, xs:base64Binary)
) {

  if (count(map:keys($Files)) > 1)
  then
    ui:error(<span data-i18n="to-many-files-uploaded">You uploaded to many files.</span>)
  else
    let $productsString := 
      for $fileName in map:keys($Files)
      return convert:binary-to-string($Files($fileName))

    let $tempFilePath := file:base-dir()||"temp-products.csv"
    let $tempFile := file:write-text($tempFilePath, $productsString)

    let $products := csv:parse($productsString, map {
        'separator': ';',
        'encoding': 'cp1252',
        'header': true()
    })/*:csv/*:record

    let $header := $products[1]/*/name()

    return _:render-products(
      $products,
      $header
    )
};

declare %rest:path("/api/sanofi/import-products/import")
        %rest:GET
function _:api-import-products() {
  let $tempFilePath := file:base-dir()||"temp-products.csv"
  let $products := 
    if(file:exists($tempFilePath))
    then 
      let $productsFromCsv := csv:parse(file:read-text($tempFilePath), map {
        'separator': ';',
        'encoding': 'cp1252',
        'header': true()
      })/*:csv/*:record
      let $deleteTempFile := file:delete($tempFilePath)
      return $productsFromCsv
    else ()

  return
    if ($products)
    then
      let $importProducts := _:import-products($products)
      return
        if ($importProducts)
        then (
          ui:info(<span data-i18n="import-products-success">Products successfully imported.</span>),
          <div data-remove="#products-list" data-animation="fadeOutRight"></div>
        )
        else ui:error(<span data-i18n="import-products-failed-during-db-operation">Import of products failed due to database operations.</span>)
    else
      ui:error(<span data-i18n="import-products-failed-no-products">No products to import.</span>)
};

declare function _:import-products(
  $Products as element(record)*
) as xs:boolean {
  let $provider := "sanofi/produkt"
  let $schema := plugin:provider-lookup($provider,"schema")!.()
  let $prods :=
    for $product in $Products
    let $id := $product/id/string()
    let $name := $product/name/string()
    let $wirkstoff := $product/wirkstoff/string()
    let $herstellername := $product/herstellername/string()
    let $indikation := $product/indikation/string()
    return map {
      '@id': $id,
      'name': $name,
      'wirkstoff': $wirkstoff,
      'herstellername': $herstellername,
      'indikation': $indikation
    }
  let $schemaProds :=
    for $product in $prods
    return plugin:lookup('schema/instance/new/from/form')!.($schema, $product) update replace value of node ./@last-modified-date with current-dateTime()

  let $elementName := $schema/@name/string()
  let $dbPaths := $schemaProds ! $elementName

  let $dbName := plugin:provider-lookup($provider,"datastore/name")!.($schema, map {})
  let $dbQuery := "
    let $dropDb :=
      if (db:exists('"||$dbName||"'))
      then
        db:drop('"||$dbName||"')
      else ()

    return db:create('"||$dbName||"', $products, $paths)
  "

  let $dbVariables := map {
    'products': $schemaProds,
    'paths': $dbPaths
  }

  let $execQuery := db:eval($dbQuery, $dbVariables)

  return true()
};

declare function _:render-products(
  $Products as element(record)*,
  $Header as xs:string*
) {
  <div id="products-list" data-replace="#products-list" data-animation="fadeInLeft" class="clearfix">
    <h2>Produkte</h2>
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
        for $product in subsequence($Products, 1, 5)
        return _:render-product-row($product)
      }
      <tr>
        <td>...</td>
      </tr>
      </tbody>
    </table>
    <h4><strong>Insgesamt: </strong>{count($Products)}</h4>
    <a href="{$global:servlet-prefix}/api/sanofi/import-products/import" class="ajax pull-right btn btn-primary">Produkte importieren</a>
  </div>
};

declare function _:render-product-row(
  $Product as element(record)
) {
  <tr>
    {
      for $column in $Product/*
      return <td>{$column/string()}</td>
    }
  </tr>
};
