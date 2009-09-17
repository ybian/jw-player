package com.longtailvideo.jwplayer.view {
	import com.longtailvideo.jwplayer.utils.AssetLoader;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.utils.Dictionary;

	/**
	 * Send when the skin is ready
	 *
	 * @eventType flash.events.Event.COMPLETE
	 */
	[Event(name="complete", type = "flash.events.Event")]

	/**
	 * Send when an error occurred loading the skin
	 *
	 * @eventType flash.events.ErrorEvent.ERROR
	 */
	[Event(name="error", type = "flash.events.ErrorEvent")]

	public class PNGSkin extends SkinBase implements ISkin {
		
		protected var urlPrefix:String;
		protected var skinXML:XML;
		protected var props:SkinProperties = new SkinProperties();
		protected var loaders:Dictionary = new Dictionary();
		
		private var errorState:Boolean = false;

		public override function load(url:String=null):void {
			if (url.substr(url.length-4,4).toLowerCase() == ".xml" ) {
				urlPrefix = url.substring(0, url.lastIndexOf('/')+1);

				var loader:AssetLoader = new AssetLoader();
				loader.addEventListener(Event.COMPLETE, loadComplete);
				loader.addEventListener(ErrorEvent.ERROR, loadError);
				loader.load(url);
			} else if (_skin.numChildren == 0) {
				sendError("PNG skin descriptor file must have a .xml extension");
			}
		}

		protected function loadError(evt:ErrorEvent):void {
			sendError(evt.text);
		}

		protected function loadComplete(evt:Event):void {
			var loader:AssetLoader = AssetLoader(evt.target);
			try {
				skinXML = XML(loader.loadedObject);
				parseSkin();
			} catch (e:Error) {
				sendError(e.message);
			}
		}

		protected function parseSkin():void {
			if (skinXML.localName() != "skin") {
				sendError("PNG skin descriptor file not correctly formatted");
				return;
			}
			
			parseConfig(skinXML.config);
			
			for each (var comp:XML in skinXML.components.component) {
				parseConfig(comp.config, comp.@name.toString());
				loadElements(comp.@name.toString(), comp..element);
			}
			
		}

		protected function parseConfig(config:XMLList, component:String=""):void {
			for each(var i:XML in config) {
				props[(component ? component + "." : "") + i.localName()] = i.toString();
			}
		}
		
		protected function loadElements(component:String, elements:XMLList):void {
			if (!component) return;
			
			for each (var element:XML in elements) {
				var newLoader:AssetLoader = new AssetLoader();
				loaders[newLoader] = {componentName:component, elementName:element.@name.toString()};
				newLoader.addEventListener(Event.COMPLETE, elementHandler);
				newLoader.addEventListener(ErrorEvent.ERROR, elementError);
				newLoader.load(urlPrefix + component + '/' + element.@src.toString(), Bitmap);  
			}
		}
		
		protected function elementHandler(evt:Event):void {
			try {
				var elementInfo:Object = loaders[evt.target];
				var bitmap:Bitmap = (evt.target as AssetLoader).loadedObject as Bitmap;
				var sprite:Sprite = new Sprite();
				sprite.addChild(bitmap);
				addSkinElement(elementInfo['componentName'], sprite, elementInfo['elementName']);
				delete loaders[evt.target];
			} catch (e:Error) {
				if (loaders.hasOwnProperty(evt.target)) {
					delete loaders[evt.target];
				}
			} 
			checkComplete();
		}
		
		protected function elementError(evt:ErrorEvent):void {
			if (loaders.hasOwnProperty(evt.target)) {
				delete loaders[evt.target];
				checkComplete();
			} else {
				errorState = true;
				sendError(evt.text);
			}
		}
		
		protected function checkComplete():void {
			if (errorState) return;

			var numElements:Number = 0;
			for each (var i:Object in loaders) {
				// Not complete yet
				numElements ++;
			}
			
			if (numElements > 0) {
				return;
			}
			
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		
		
		public override function getSkinProperties():SkinProperties {
			return props; 
		}

	}
}