package com.longtailvideo.jwplayer.controller {
	import flash.events.EventDispatcher;

	/**
	 * Sent when the plugin loader has loaded all valid plugins.
	 *
	 * @eventType flash.events.Event.COMPLETE
	 */
	[Event(name="complete", type = "flash.events.Event")]

	/**
	 * Sent when an error occured during plugin loading.
	 *
	 * @eventType flash.events.ErrorEvent.ERROR
	 */
	[Event(name="error", type = "flash.events.ErrorEvent")]

	/**
	 * This class loads external MediaProvider swfs.  
	 */
	public class MediaProviderLoader extends EventDispatcher {

		/**
		 * Loads a list of URLs to swf files containing MediaProvider elements.
		 * @param sources An array of URLs, pointing to 
		 */
		public function loadSources(sources:Array):void {
			
		}

	}
}