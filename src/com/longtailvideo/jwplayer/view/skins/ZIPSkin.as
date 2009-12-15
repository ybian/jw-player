package com.longtailvideo.jwplayer.view.skins {
	import com.longtailvideo.jwplayer.utils.AssetLoader;
	import com.longtailvideo.jwplayer.utils.Strings;
	import com.nochump.util.zip.ZipEntry;
	import com.nochump.util.zip.ZipFile;
	
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequest;
	import flash.net.URLStream;


	public class ZIPSkin extends PNGSkin {
		private var _zipFile:ZipFile;


		public function ZIPSkin() {
			super();
		}


		public override function load(url:String=null):void {
			if (Strings.extension(url) == "zip") {
				_urlPrefix = url.substring(url.lastIndexOf('/') + 1, url.lastIndexOf('.'));

				var urlStream:URLStream = new URLStream();
				urlStream.addEventListener(Event.COMPLETE, loadComplete);
				urlStream.addEventListener(IOErrorEvent.IO_ERROR, loadError);
				urlStream.addEventListener(SecurityErrorEvent.SECURITY_ERROR, loadError);
				urlStream.load(new URLRequest(url));
			} else if (_skin.numChildren == 0) {
				sendError("ZIP skin descriptor file must have a .zip extension");
			}
		}


		protected override function loadComplete(evt:Event):void {
			var data:URLStream = URLStream(evt.target);
			_zipFile = new ZipFile(data);
			try {
				var zipEntry:ZipEntry = _zipFile.getEntry(_urlPrefix + '.xml');
				if (!zipEntry) {
					zipEntry =  _zipFile.getEntry(_urlPrefix+'/'+_urlPrefix + '.xml');
				} else {
					_urlPrefix = null;
				}
				_skinXML = XML(String(_zipFile.getInput(zipEntry)));
				parseSkin();
			} catch (e:Error) {
				sendError(e.message);
			}
		}


		protected override function loadElements(component:String, elements:XMLList):void {
			if (!component)
				return;

			for each (var element:XML in elements) {
				var file:String = component + '/' + element.@src.toString();
				if (_urlPrefix){
					file = _urlPrefix +'/'+file;
				}
				var zipEntry:ZipEntry = _zipFile.getEntry(file);
				
				if (zipEntry) {
					try {
						var newLoader:AssetLoader = new AssetLoader();
						_loaders[newLoader] = {componentName: component, elementName: element.@name.toString()};
						newLoader.addEventListener(Event.COMPLETE, elementHandler);
						newLoader.addEventListener(ErrorEvent.ERROR, elementError);
						newLoader.loadBytes(_zipFile.getInput(zipEntry));
					} catch (err:Error) {
						sendError("Error loading ZIP skin "+component+"'s "+element.toString()+": "+err.message);
					}
				}
			}
		}
	}
}