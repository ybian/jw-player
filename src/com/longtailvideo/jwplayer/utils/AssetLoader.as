package com.longtailvideo.jwplayer.utils {
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.system.Security;

	/**
	 * Sent when the loader has completed loading.  AssetLoader's <code>loadedObject</code> now contains the loaded content.
	 *
	 * @eventType flash.events.Event.COMPLETE
	 */
	[Event(name="complete", type = "flash.events.Event")]

	/**
	 * Sent when an error occurred loading or casting the content
	 *
	 * @eventType flash.events.ErrorEvent.ERROR
	 */
	[Event(name="error", type = "flash.events.ErrorEvent")]

	public class AssetLoader extends EventDispatcher {
		private var loader:Loader;
		private var urlLoader:URLLoader;

		private var LoadedClass:Class;
		public var loadedObject:*;

		protected var loaderExtensions:Array = ["swf", "png", "gif", "jpg", "jpeg"];
		protected var urlLoaderExtensions:Array = ["zip", "xml", "txt"];

		public function load(location:String, expectedClass:Class=null):void {
			LoadedClass = expectedClass;

			var ext:String = location.substring(location.lastIndexOf(".")+1, location.length);

			if (loaderExtensions.indexOf(ext.toLowerCase()) >= 0) {
				useLoader(location);
			} else if (urlLoaderExtensions.indexOf(ext.toLowerCase()) >= 0) {
				useURLLoader(location);
			}
		}
		
		protected function useLoader(location:String):void {
			loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadComplete);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, loadError);
			if (RootReference.stage.loaderInfo.url.indexOf('http') == 0) {
				
			}
			
			loader.load(new URLRequest(location));
		}
		
		protected function loadComplete(evt:Event):void {
			try {
				if (LoadedClass) {
					loadedObject = (evt.target as LoaderInfo).content as LoadedClass; 
				} else {
					loadedObject = (evt.target as LoaderInfo).content 				
				}
				dispatchEvent(new Event(Event.COMPLETE));
			} catch(e:Error) {
				dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false, e.message));
			}
		}
		
		protected function loadError(evt:ErrorEvent):void {
			dispatchEvent(evt);
		}
		
		protected function useURLLoader(location:String):void {
			urlLoader = new URLLoader();
			urlLoader.addEventListener(Event.COMPLETE, urlLoadComplete);
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR, loadError);
			urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, loadError);
			loader.load(new URLRequest(location));
		}
		
		protected function urlLoadComplete(evt:Event):void {
			try {
				if (LoadedClass) {
					loadedObject = LoadedClass((evt.target as URLLoader).data);
				} else {
					loadedObject = (evt.target as URLLoader).data;
				}
				dispatchEvent(new Event(Event.COMPLETE));
			} catch(e:Error) {
				dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false, e.message));
			}
		}
		
		
	}
	
}