module namespace _ = "sanofi/common/view";

(: import repo modules :)
import module namespace global	= "influx/global";
import module namespace plugin	= "influx/plugin";
import module namespace db	    = "influx/db";
import module namespace ui =" influx/ui";
import module namespace date-util ="influx/utils/date-utils";


declare namespace xhtml="http://www.w3.org/1999/xhtml";



declare function _:ui-page($html,$title){
  <div class="ibox float-e-margins" xmlns="http://www.w3.org/1999/xhtml">
    <div class="ibox-title"><h2>{$title}</h2></div>
    <div class="ibox-content">
      {$html}
</div>
</div>
};

declare function _:ui-page-heading($ContextMap as map(*)) as element(xhtml:div){
<div xmlns="http://www.w3.org/1999/xhtml" class="row wrapper border-bottom white-bg page-heading" data-replace="div.page-heading">
  <div class="col-lg-12">
    <h2>KAIMAN - Wartungsbereich</h2>
    <ol class="breadcrumb">
        <li>
      <a href="{$global:servlet-prefix}/admin/api/page?provider=sanofi/views/user-import"><i class="fa fa-upload"></i> <span data-i18n="side-navigation-import-users" class="nav-label">Benutzerimport</span></a>
  </li>
    <li>
      <a href="{$global:servlet-prefix}/admin/api/page?provider=sanofi/views/regelungen-import"><i class="fa fa-upload"></i> <span data-i18n="side-navigation-import-regelungen" class="nav-label">Regelungen Import</span></a>
  </li>
    <li>
      <a href="{$global:servlet-prefix}/admin/api/page?provider=sanofi/views/kenngroessen-import"><i class="fa fa-upload"></i> <span data-i18n="side-navigation-import-kenngroessen" class="nav-label">Kenngrößen Import</span></a>
  </li>
    <li>
      <a href="{$global:servlet-prefix}/admin/api/page?provider=sanofi/views/product-import"><i class="fa fa-upload"></i> <span data-i18n="side-navigation-import-products" class="nav-label">Produktimport</span></a>
  </li>
  <li>
      <a href="{$global:servlet-prefix}/admin/api/page?provider=sanofi/choose-columns/provider"><i class="fa fa-list-alt"></i> <span data-i18n="side-navigation-choose-columns" class="nav-label">Spalten festlegen</span></a>
  </li>
   <li>
      <a href="{$global:servlet-prefix}/admin/api/page?provider=sanofi/choose-values/provider"><i class="fa fa-list-alt"></i> <span data-i18n="side-navigation-choose-values" class="nav-label">Auswahlwerte festlegen</span></a>
  </li>
    </ol>
  </div>
</div>
};