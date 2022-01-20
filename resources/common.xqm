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
      <a href="{$global:servlet-prefix}/schema/list/items?context={$schema/*:nav-item/@context}&amp;provider={$schema/@provider/string()}&amp;contextType=page"><i class="fa fa-{$schema/*:nav-item/@icon}"></i> <span class="nav-label">{$schema/*:nav-item/@title/string()}</span></a>
  </li>
};

declare function _:schema-ui-page($html,$Item, $Schema, $ContextMap as map(*)){
  <div xmlns="http://www.w3.org/1999/xhtml">
  <div class="ibox float-e-margins">
    <div class="ibox-title">
      <h3>{$Item/*:name/string()}</h3>
      {
        if ($ContextMap?context-item and ($ContextMap?item/@id != $Item/@id)) 
        then <h5>{$ContextMap?context-item/*:name/string()}</h5>
      }
    </div>
    <div class="ibox-content">
      <div class="sk-spinner sk-spinner-wave">
          <div class="sk-rect1"></div>
          <div class="sk-rect2"></div>
          <div class="sk-rect3"></div>
          <div class="sk-rect4"></div>
          <div class="sk-rect5"></div>
      </div>
      {$html}
</div>
</div>
</div>
};

declare function _:ui-page-content($ContextMap as map(*))
as element(xhtml:div)*
{
  if ($ContextMap?item) 
  then plugin:provider-lookup($ContextMap?provider,"schema/ui/page/content",$ContextMap?context)!.($ContextMap?item,$ContextMap?schema,$ContextMap)
  else plugin:provider-lookup($ContextMap?provider,"schema/ibox/table/div",$ContextMap?context)!.($ContextMap?items,$ContextMap?schema,$ContextMap)
};

declare function _:ui-page-heading($ContextMap as map(*)) as element(xhtml:div){
<div xmlns="http://www.w3.org/1999/xhtml" class="row wrapper border-bottom white-bg page-heading" data-replace="div.page-heading">
{
  if ($ContextMap?item) then
      <div class="col-lg-9">
        <h2>{$ContextMap?schema/*:modal/*:title/node()}</h2>
        <ol class="breadcrumb">
          <li>
            <a href="/schema/list/items?provider={$ContextMap?schema/@provider}&amp;context={$ContextMap?context}">Liste</a>
          </li>
          <li class="active">
            <a href="/schema/form/page/{$ContextMap?item/@id}?context={$ContextMap?context}&amp;mode={$ContextMap?mode}&amp;contextType={$ContextMap?contextType}&amp;provider={$ContextMap?schema/@provider}&amp;context-provider={$ContextMap?context-provider}&amp;context-item-id={$ContextMap?context-item-id}">
            <strong>{$ContextMap?item/*:name/string()}</strong></a>
          </li>
        </ol>
      </div>
  else 
      <div class="col-lg-9">
        <h2>{$ContextMap?schema/*:modal/*:title/node()}</h2>
        <ol class="breadcrumb">
          <li>
            <a href="/schema/list/items?context={$ContextMap?context}&amp;provider={$ContextMap?schema/@provider}"><strong>Liste</strong></a>
          </li>
        </ol>
      </div>
  }
</div>
};