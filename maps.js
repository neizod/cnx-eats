
(function(){var CustomOverlay,heatmaps,icon,info_window,map,overlays,show_search_result;map=null;info_window=new google.maps.InfoWindow();google.maps.Polygon.prototype.getPosition=function(){var bounds;bounds=new google.maps.LatLngBounds();this.getPath().forEach(function(points,_){return bounds.extend(points);});return bounds.getCenter();};icon=function(star){if(star==null){star=null;}
return'https://chart.googleapis.com/chart?'+(star!=null?'chst=d_map_xpin_icon&chld=pin_star|restaurant|0ff|ff0':'chst=d_map_pin_icon&chld=restaurant|4d0');};CustomOverlay=(function(){function CustomOverlay(get_data,color,neg_color,star_icon){this.get_data=get_data;this.color=color;this.neg_color=neg_color;this.star_icon=star_icon;this.features=[];}
CustomOverlay.prototype.add=function(obj){var ll,marker;if(obj.type==='Point'){marker=new google.maps.Marker({gid:obj.gid,title:obj.name,url:(obj!=null?obj.fsq_id:void 0)?"http://foursquare.com/v/"+obj.fsq_id:void 0,chkins:obj!=null?obj.chkins:void 0,position:(function(func,args,ctor){ctor.prototype=func.prototype;var child=new ctor,result=func.apply(child,args);return Object(result)===result?result:child;})(google.maps.LatLng,obj.coords,function(){}),icon:icon(this.star_icon),zIndex:this.star_icon!=null?2:1});}else if(obj.type==='Polygon'){marker=new google.maps.Polygon({gid:obj.gid,title:(obj!=null?obj.name:void 0)?obj.name:"Block #"+obj.gid,paths:[(function(){var _i,_len,_ref,_results;_ref=obj.coords[0];_results=[];for(_i=0,_len=_ref.length;_i<_len;_i++){ll=_ref[_i];_results.push((function(func,args,ctor){ctor.prototype=func.prototype;var child=new ctor,result=func.apply(child,args);return Object(result)===result?result:child;})(google.maps.LatLng,ll,function(){}));}
return _results;})()],people:obj!=null?obj.people:void 0,weight:obj!=null?obj.weight:void 0,strokeColor:+(obj!=null?obj.weight:void 0)<0?this.neg_color:this.color,fillColor:+(obj!=null?obj.weight:void 0)<0?this.neg_color:this.color,strokeOpacity:obj.weight!=null?0.1:void 0,fillOpacity:obj.weight!=null?Math.abs(obj.weight/1.1):void 0,zIndex:(obj!=null?obj.weight:void 0)?1:2});}
this.features.push(marker);return google.maps.event.addListener(marker,'click',function(){info_window.setContent($('<div>').html([$('<h3>').html(marker.title),marker.weight!=null?$('<p>').html("weight: "+marker.weight):void 0,marker.chkins!=null?$('<p>').html("check-ins: "+marker.chkins):void 0,marker.people!=null?$('<p>').html("students: "+marker.people):void 0]).html());return info_window.open(map,marker);});};CustomOverlay.prototype.load=function(just_load,after){var self;if(just_load==null){just_load=null;}
if(after==null){after=null;}
if(this.get_data==null){return;}
self=this;return $.getJSON("static/"+this.get_data.t+".json",function(json_data,_,meta_data){var obj,_i,_len;if(meta_data.status!==200){return;}
for(_i=0,_len=json_data.length;_i<_len;_i++){obj=json_data[_i];self.add(obj);}
if(just_load==null){self.show();}
return typeof after==="function"?after():void 0;});};CustomOverlay.prototype.reload=function(get_data,after){this.get_data=get_data!=null?get_data:this.get_data;if(after==null){after=null;}
this.empty();return this.load(null,after);};CustomOverlay.prototype.empty=function(){this.hide();return this.features=[];};CustomOverlay.prototype.show=function(){var feature,_i,_len,_ref,_results;_ref=this.features;_results=[];for(_i=0,_len=_ref.length;_i<_len;_i++){feature=_ref[_i];_results.push(feature.setMap(map));}
return _results;};CustomOverlay.prototype.hide=function(){var feature,_i,_len,_ref,_results;_ref=this.features;_results=[];for(_i=0,_len=_ref.length;_i<_len;_i++){feature=_ref[_i];_results.push(feature.setMap(null));}
return _results;};CustomOverlay.prototype.toggle=function(bool){if(bool){return this.show();}else{return this.hide();}};return CustomOverlay;})();overlays={restaurants:new CustomOverlay({t:'restaurants'}),obstacles:new CustomOverlay({t:'obstacles'},'#333'),universities:new CustomOverlay({t:'universities'},'#009'),search:new CustomOverlay(null,'#7E07A9','#ECFC00',true)};heatmaps={land_rates:new CustomOverlay({t:'land_rates'},'#04819E','#FF7F00'),rest_density:new CustomOverlay({t:'rest_density'},'#0ACF00'),univ_density:new CustomOverlay({t:'univ_density'},'#1826B0')};google.maps.event.addDomListener(window,'load',function(){var heatmap,key,overlay,_results;map=new google.maps.Map(document.getElementById('map-canvas'),{center:new google.maps.LatLng(18.7896457,98.9939156),zoom:13,minZoom:12,maxZoom:17,mapTypeId:google.maps.MapTypeId.ROADMAP});for(key in overlays){overlay=overlays[key];overlay.load();}
_results=[];for(key in heatmaps){heatmap=heatmaps[key];_results.push(heatmap.load(key.match(/.*_density/)));}
return _results;});show_search_result=function(){var feature,lat,lng,search_item_title,_i,_len,_ref;$('#search-result ol').empty();_ref=overlays.search.features;for(_i=0,_len=_ref.length;_i<_len;_i++){feature=_ref[_i];lat=feature.getPosition().lat();lng=feature.getPosition().lng();search_item_title=feature.title;if(feature!=null?feature.weight:void 0){search_item_title+=", weight "+feature.weight;}
$('#search-result ol').append($('<li>').html([$('<a>').attr('href',feature!=null?feature.url:void 0).attr('target','_blank').html($('<b>').html(search_item_title)),$('<br>'),$('<span>').addClass('unimportant').addClass('find-me').data('latlng',[lat,lng]).html("@ "+(lat.toFixed(8))+", "+(lng.toFixed(8)))]));}
$('.find-me').click(function(){map.panTo((function(func,args,ctor){ctor.prototype=func.prototype;var child=new ctor,result=func.apply(child,args);return Object(result)===result?result:child;})(google.maps.LatLng,$(this).data('latlng'),function(){}));return map.setZoom(17);});return $('#search-dialog').show();};$(document).keydown(function(event){if(event.which===27){if($('#search-box:focus').length){return $('#search-box').blur();}else{return info_window.close();}}});$(document).keypress(function(event){if(!$('#search-box:focus').length){if(event.which===47){$('#search-box').focus();return event.preventDefault();}}});$(document).ready(function(){$('.prehide').hide();$('#search-box').focus();$('#search-box').keydown(function(event){if(event.keyCode===13){return $('#search').click();}});$('#search').click(function(){var get_data;return alert('Sorry, search unavailable when hosted on github. :(');get_data={t:'restaurants',namelike:$('#search-box').val()};return overlays.search.reload(get_data,show_search_result);});$('#advance').click(function(){return $('#advance-search').toggle();});$('#density-search').click(function(){var get_data,heatmap,_;return alert('Sorry, search unavailable when hosted on github. :(');get_data={t:$('input:radio[name=density-type]:checked').val(),lower:$('#density-lower').val(),upper:$('#density-upper').val()};$('#layer-selector input:radio[value=none]').click();for(_ in heatmaps){heatmap=heatmaps[_];heatmap.hide();}
return overlays.search.reload(get_data,show_search_result);});$('#layers').click(function(){return $('#layer-selector').toggle();});$('#layer-selector input:checkbox').click(function(){return overlays[this.value].toggle(this.checked);});$('#layer-selector input:radio').click(function(){var heatmap,_,_ref;for(_ in heatmaps){heatmap=heatmaps[_];heatmap.hide();}
return(_ref=heatmaps[$('input:radio[name=heatmap]:checked').val()])!=null?_ref.show():void 0;});$('.close').click(function(){return $(this).parent().hide();});return $('#search-dialog .close').click(function(){return overlays.search.hide();});});}).call(this);
