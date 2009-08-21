package com.longtailvideo.jwplayer.utils {
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;

	public class Configger {
		private var reference:DisplayObject;
		private var xmlSuccessCallback:Function = null;
		private var xmlFailureCallback:Function = null;
		
	
		public function Configger(ref:DisplayObject):void {
			reference = ref;
		}
	
		/**
		 * @return 
		 * @throws Error if something bad happens. 
		 */
		public function getFlashvars():Object {
			if (this.xmlConfig) {
				loadXML(this.xmlConfig);
			} 
			return null; 
		}
		
		public function loadXML(url:String, onSuccess:Function=null, onFailure:Function=null):void {
			xmlSuccessCallback = onSuccess;
			xmlFailureCallback = onFailure;
			
			var xmlLoader:URLLoader = new URLLoader();
			xmlLoader.addEventListener(HTTPStatusEvent.HTTP_STATUS, xmlFail);
			xmlLoader.addEventListener(IOErrorEvent.IO_ERROR, xmlFail);
			xmlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, xmlFail);
			xmlLoader.addEventListener(Event.COMPLETE, loadComplete);
			xmlLoader.load(new URLRequest(url));
				
		}

		private function loadComplete(evt:Event):void {
			var loadedXML:XML = XML((evt.target as URLLoader).data);
		}

		private function xmlSuccess():void {
			if (xmlSuccessCallback != null) {
				xmlSuccessCallback();
			}
		}
		
		private function xmlFail(evt:Event):void {
			if (xmlFailureCallback != null) {
				xmlFailureCallback(evt.toString());
			}
		}

		/**
		 * Whether the "config" flashvar is set 
		 */
		public function get xmlConfig():String {
			return reference.root.loaderInfo.parameters['config'];
		}
		

	}
}