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
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.system.SecurityDomain;
	import flash.utils.ByteArray;


	/**
	 * Sent when the loader has completed loading.  AssetLoader's <code>loadedObject</code> now contains the loaded content.
	 *
	 * @eventType flash.events.Event.COMPLETE
	 */
	[Event(name="complete", type="flash.events.Event")]

	/**
	 * Sent when an error occurred loading or casting the content
	 *
	 * @eventType flash.events.ErrorEvent.ERROR
	 */
	[Event(name="error", type="flash.events.ErrorEvent")]

	public class AssetLoader extends EventDispatcher {
		private var _loaderExtensions:Array = ["swf", "png", "gif", "jpg", "jpeg"];
		private var _loader:Loader;
		private var _urlLoader:URLLoader;
		private var LoadedClass:Class;
		public var loadedObject:*;


		public function load(location:String, expectedClass:Class=null):void {
			LoadedClass = expectedClass;

			var ext:String = location.substring(location.lastIndexOf(".") + 1, location.length);

			if (_loaderExtensions.indexOf(ext.toLowerCase()) >= 0) {
				useLoader(location);
			} else {
				useURLLoader(location);
			}
		}
		
		
		public function loadBytes(byteArray:ByteArray):void {
			loader.loadBytes(byteArray);
		}


		protected function useLoader(location:String):void {
			if (RootReference.root.loaderInfo.url.indexOf('http') == 0) {
				var context:LoaderContext = new LoaderContext(true, ApplicationDomain.currentDomain, SecurityDomain.currentDomain);
				loader.load(new URLRequest(location), context);
			} else {
				loader.load(new URLRequest(location));
			}
		}


		protected function loadComplete(evt:Event):void {
			try {
				if (LoadedClass) {
					loadedObject = (evt.target as LoaderInfo).content as LoadedClass;
				} else {
					loadedObject = (evt.target as LoaderInfo).content;
				}
				dispatchEvent(new Event(Event.COMPLETE));
			} catch (e:Error) {
				dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false, e.message));
			}
		}


		protected function loadError(evt:ErrorEvent):void {
			dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false, evt.text));
		}


		protected function get loader():Loader {
			if (!_loader) {
				_loader = new Loader();
				_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadComplete);
				_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, loadError);
				_loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, loadError);
			}
			return _loader;
		}


		protected function useURLLoader(location:String):void {
			urlLoader.load(new URLRequest(location));
		}


		protected function urlLoadComplete(evt:Event):void {
			try {
				if (LoadedClass) {
					loadedObject = LoadedClass((evt.target as URLLoader).data);
				} else {
					loadedObject = (evt.target as URLLoader).data;
				}
				dispatchEvent(new Event(Event.COMPLETE));
			} catch (e:Error) {
				dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false, e.message));
			}
		}


		protected function get urlLoader():URLLoader {
			if (!_urlLoader) {
				_urlLoader = new URLLoader();
				_urlLoader.addEventListener(Event.COMPLETE, urlLoadComplete);
				_urlLoader.addEventListener(IOErrorEvent.IO_ERROR, loadError);
				_urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, loadError);
			}
			return _urlLoader;
		}
	}
}