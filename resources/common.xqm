module namespace _ = "sanofi/common";

(: import repo modules :)
import module namespace global	= "influx/global";
import module namespace plugin	= "influx/plugin";
import module namespace db	    = "influx/db";
import module namespace ui =" influx/ui";
import module namespace date-util ="influx/utils/date-utils";


declare namespace xhtml="http://www.w3.org/1999/xhtml";


declare function _:nav-item($schema as element(schema)) as element(xhtml:li)* {
  <li xmlns="http://www.w3.org/1999/xhtml" data-parent="/" data-sortkey="{$schema/*:nav-item/@sortkey}">
      <a href="{$global:servlet-prefix}/schema/list/items?context={$schema/*:nav-item/@context}&amp;provider={$schema/@provider/string()}"><i class="fa fa-{$schema/*:nav-item/@icon}"></i> <span class="nav-label">{$schema/*:nav-item/@title/string()}</span></a>
  </li>
};

declare function _:ui-page-content($Map as map(*))
as element(xhtml:div)
{
<div xmlns="http://www.w3.org/1999/xhtml" class="content-with-sidebar row">
  <div class="row">
      <div class="col-lg-12">
            {plugin:lookup("schema/ibox/table")!.($Map?provider,"")}
      </div>
  </div>
</div>
};

declare function _:breadcrumb($Context as map(*)) as element(xhtml:ol){
 <ol xmlns="http://www.w3.org/1999/xhtml" class="breadcrumb">
      <li>
        <a href="{request:header('referer')}">Zurück</a>
      </li>
      <li class="active">
        <a href="{rest:base-uri()}/schema/list/items?provider={$Context?provider}&amp;context={$Context?context}">Übersicht</a>
      </li>
    </ol>
};
