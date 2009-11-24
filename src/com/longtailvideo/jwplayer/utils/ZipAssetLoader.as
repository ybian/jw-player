package com.longtailvideo.jwplayer.utils {
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
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

	public class ZipAssetLoader extends EventDispatcher {
		private var _loader:Loader;
		public var loadedObject:*;

		public function ZipAssetLoader(target:IEventDispatcher=null) {
			super(target);
			_loader = new Loader();
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadComplete);
			_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, loadError);
		}
		
		
		public function load(byteArray:ByteArray):void {
			_loader.loadBytes(byteArray);
		}
		
		
		protected function loadComplete(evt:Event):void {
			try {
				loadedObject = (evt.target as LoaderInfo).content
				dispatchEvent(new Event(Event.COMPLETE));
			} catch(e:Error) {
				dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false, e.message));
			}
		}
		
		protected function loadError(evt:ErrorEvent):void {
			dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false, evt.text));
		}
	}
}