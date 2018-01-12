module namespace _="sanofi/api/product-import";

import module namespace plugin='influx/plugin';
import module namespace rest = "http://exquery.org/ns/restxq";
import module namespace global ='influx/global';
import module namespace ui='influx/ui2';

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
        then ui:info(<span data-i18n="import-products-success">Products successfully imported.</span>)
        else ui:error(<span data-i18n="import-products-failed-during-db-operation">Import of products failed due to database operations.</span>)
    else
      ui:error(<span data-i18n="import-products-failed-no-products">No products to import.</span>)
};

declare function _:import-products(
  $Products as element(record)*
) as xs:boolean {
  true()
};

declare function _:render-products(
  $Products as element(record)*,
  $Header as xs:string*
) {
  <div id="products-list" data-replace="#products-list" class="clearfix">
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
