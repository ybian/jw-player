package com.longtailvideo.jwplayer.utils {
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;

	/**
	 * Sent when the configuration block has been successfully retrieved
	 *
	 * @eventType flash.events.Event.COMPLETE
	 */
	[Event(name="complete", type = "flash.events.Event")]

	/**
	 * Sent when an error in the config has
	 *
	 * @eventType flash.events.ErrorEvent.ERROR
	 */
	[Event(name="error", type = "flash.events.ErrorEvent")]

	public class Configger extends EventDispatcher {
		private var _config:Object;

		/** The loaded config object; can an XML object or a hash map. **/
		public function get config():Object {
			return _config;
		}

		/**
		 * @return
		 * @throws Error if something bad happens.
		 */
		public function getFlashvars():void {
			if (this.xmlConfig) {
				loadXML(this.xmlConfig);
			} else {
				loadFlashvars(RootReference.root.loaderInfo.parameters);
			}
		}

		/** Whether the "config" flashvar is set **/
		public function get xmlConfig():String {
			return RootReference.root.loaderInfo.parameters['config'];
		}

		/**
		 * Loads a config block from an XML file
		 * @param url The location of the config file.  Can be absolute URL or path relative to the player SWF.
		 */
		public function loadXML(url:String):void {
			var xmlLoader:URLLoader = new URLLoader();
			xmlLoader.addEventListener(IOErrorEvent.IO_ERROR, xmlFail);
			xmlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, xmlFail);
			xmlLoader.addEventListener(Event.COMPLETE, loadComplete);
			xmlLoader.load(new URLRequest(url));

		}

		/**
		 * Loads configuration flashvars
		 * @param params Hash map containing key/value pairs
		 */
		public function loadFlashvars(params:Object):void {
			var configBlock:Object = {};
			try {
				for (var param:String in params) {
					if (!configBlock.hasOwnProperty(param)) {
						configBlock[param.toLowerCase()] = params[param];
					}
				}
				_config = configBlock;
				dispatchEvent(new Event(Event.COMPLETE));
			} catch (e:Error) {
				dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false, e.message));

			}
		}

		private function loadComplete(evt:Event):void {
			var loadedXML:XML = XML((evt.target as URLLoader).data);
			if (loadedXML.name().toString().toLowerCase() == "config" && loadedXML.children().length() > 0) {
				_config = loadedXML;
				dispatchEvent(new Event(Event.COMPLETE));
			} else {
				dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false, "Config was empty"));
			}
		}

		private function xmlFail(evt:ErrorEvent):void {
			dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false, evt.text));
		}

	}
}