javascript:(function(){window._clipper={u:"http://{{ m.site.hostname }}{% url imageclipper_go %}",c:"{_ Click images to import them in _} {{ m.site.title }}.",b:"{_ Upload _}"};function%20b(g){var%20e=window;if(e.ZotonicImageClipper){e.ZotonicImageClipper.run()}else{var%20f=g.createElement("script");f.src="http://{{ m.site.hostname }}/lib/js/clipper.js?"+Math.floor((new%20Date()).getTime()/86400000);g.body.appendChild(f)}}b(document);for(var%20a=0;a<frames.length;++a){var%20d=frames[a];if(d.frameElement.tagName=="IFRAME"){continue}if(d.innerWidth<400||d.innerHeight<400){continue}b(d.document)}})();

