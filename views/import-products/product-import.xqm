module namespace _="sanofi/views/product-import";

import module namespace i18n = 'influx/i18n';
import module namespace global ='influx/global';
import module namespace ui='influx/ui';
import module namespace plugin='influx/plugin';
import module namespace common="sanofi/common/view" at "../common.xqm";

declare namespace xhtml = "http://www.w3.org/1999/xhtml";
declare namespace mod="http://influx.adesso.de/module";

declare variable $_:meta := doc("../../module.xml")/mod:module;
declare variable $_:module-static := $global:module-path||"/"||$_:meta/mod:install-path||"/static";
declare variable $_:ns:=namespace-uri(<_:ns/>);
declare %plugin:provide("ui/page/heading") function _:ui-page-heading($m){common:ui-page-heading($m)};

declare %plugin:provide('side-navigation-item')
        %plugin:allow("admin")
  function _:nav-item-kam()
  as element(xhtml:li) {
  <li xmlns="http://www.w3.org/1999/xhtml" data-parent="/admin" data-sortkey="M">
      <a href="{$global:servlet-prefix}/admin/api/page?provider={$_:ns}"><i class="fa fa-upload"></i> <span data-i18n="side-navigation-import-products" class="nav-label">Produktimport</span></a>
  </li>
};

declare %plugin:provide("ui/page/content")
function _:sanofi-product-importer(
  $map as map(*)
) as element(xhtml:div) {
<div class="ibox float-e-margins" xmlns="http://www.w3.org/1999/xhtml">
    <div class="ibox-title">
        <h2>Produkte importieren</h2>
    </div>
    <div class="ibox-content">
        <div class="m-b">
          {
            _:render-products-dropzone()
          }
        </div>
      <div id="products-list"></div>
    </div>
</div>
};

declare %plugin:provide("ui/page/custom-js")
function _:page-custom-js($map){  
  <script type="text/javascript" src="{$global:inspinia-path}/js/plugins/dropzone/dropzone.js"></script>,
  <script type="text/javascript" src="{$_:module-static}/js/configureDropzoneForProductCSV.js"></script>
};

declare %plugin:provide("ui/page/footer") 
function _:page-footer-app-manager(
    $Params as map(*)
) as element() {
  <div mlns="http://www.w3.org/1999/xhtml" id="preview-template" style="display: none;">
    <div class="dz-details btn" style="margin-bottom: 30px;"></div>
    <div class="dz-image" style=""></div>
    <div class="dz-progress" style="display:none;"></div>
    <div class="dz-error-message" style="display:none;"></div>
    <div class="dz-success-mark" style="display:none;"></div>
    <div class="dz-error-mark" style="display:none;"></div>
  </div>
};

declare function _:render-products-dropzone() as element(xhtml:form) {
  <form action="{$global:servlet-prefix}/api/sanofi/import-products" 
        method="post" 
        enctype="multipart/form-data" 
        class="dropzone ajax dz-clickable" 
        id="uploadProducts" 
        style="display:flex; align-items:center; flex-flow:column; min-height:100px">
        
    <div class="dz-message col-md-12" >
      <div class="manage-icon text-center clear" style="margin-left:0px;float:none;padding-top:40px">
           <i class="fa fa-upload clear" style="margin-bottom:10px;"/>
           <h3 class="text-center clear" data-i18n="drop-products-csv-here">Upload Products CSV</h3>
      </div>
      <div class="progress progress-bar-default" style="visibility: hidden;" id="progressbar">
          <div style="width:0%; " aria-valuemax="100" aria-valuemin="0" aria-valuenow="0" role="progressbar"  class="progress-bar" data-dz-uploadprogress="true"></div>
      </div>
    </div>
  </form>
};

