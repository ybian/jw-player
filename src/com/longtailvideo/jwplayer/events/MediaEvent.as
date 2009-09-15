package com.longtailvideo.jwplayer.events {

	/**
	 * The MediaEvent class represents events related to media playback.
	 *  
	 * @see com.longtailvideo.media.MediaSource 
	 */
	public class MediaEvent extends PlayerEvent {

		/**
	     *  The <code>MediaEvent.JWPLAYER_MEDIA_BUFFER</code> constant defines the value of the 
     	 *  <code>type</code> property of the event object for a <code>jwplayerMediaBuffer</code> event.
     	 * 
		 * <p>The properties of the event object have the following values:</p>
	     * <table class="innertable">
     	 *		<tr><th>Property</th><th>Value</th></tr>
	     *		<tr><td><code>id</code></td><td>ID of the player in the HTML DOM. Used by javascript to reference the player.</td></tr>
	     *		<tr><td><code>client</code></td><td>A string representing the client the player runs in (e.g. FLASH WIN 9,0,115,0).</td></tr>
  	     * 		<tr><td><code>version</code></td><td>A string representing the major version, minor version and revision number of the player (e.g. 5.0.395).</td></tr>
	     *		<tr><td><code>buffer</code></td><td>The percent of the media buffered into memory</td></tr>
	     *  </table>
	     *
	     *  @eventType jwplayerMediaBuffer
		 */
		public static var JWPLAYER_MEDIA_BUFFER:String = "jwplayerMediaBuffer";

		/**
	     *  The <code>MediaEvent.JWPLAYER_MEDIA_ERROR</code> constant defines the value of the 
     	 *  <code>type</code> property of the event object for a <code>jwplayerMediaError</code> event.
     	 * 
		 * <p>The properties of the event object have the following values:</p>
	     * <table class="innertable">
     	 *		<tr><th>Property</th><th>Value</th></tr>
	     *		<tr><td><code>id</code></td><td>ID of the player in the HTML DOM. Used by javascript to reference the player.</td></tr>
	     *		<tr><td><code>client</code></td><td>A string representing the client the player runs in (e.g. FLASH WIN 9,0,115,0).</td></tr>
  	     * 		<tr><td><code>version</code></td><td>A string representing the major version, minor version and revision number of the player (e.g. 5.0.395).</td></tr>
	     *		<tr><td><code>message</code></td><td>Message explaining the error.</td></tr>
	     *  </table>
	     *
	     *  @eventType jwplayerMediaError
		 */
		public static var JWPLAYER_MEDIA_ERROR:String = "jwplayerMediaError";

		/**
	     *  The <code>MediaEvent.JWPLAYER_MEDIA_LOADED</code> constant defines the value of the 
     	 *  <code>type</code> property of the event object for a <code>jwplayerMediaLoaded</code> event.
     	 * 
		 * <p>The properties of the event object have the following values:</p>
	     * <table class="innertable">
     	 *		<tr><th>Property</th><th>Value</th></tr>
	     *		<tr><td><code>id</code></td><td>ID of the player in the HTML DOM. Used by javascript to reference the player.</td></tr>
	     *		<tr><td><code>client</code></td><td>A string representing the client the player runs in (e.g. FLASH WIN 9,0,115,0).</td></tr>
  	     * 		<tr><td><code>version</code></td><td>A string representing the major version, minor version and revision number of the player (e.g. 5.0.395).</td></tr>
	     *  </table>
	     *
	     *  @eventType jwplayerMediaLoaded
		 */
		public static var JWPLAYER_MEDIA_LOADED:String = "jwplayerMediaLoaded";

		/**
	     *  The <code>MediaEvent.JWPLAYER_MEDIA_TIME</code> constant defines the value of the 
     	 *  <code>type</code> property of the event object for a <code>jwplayerMediaTime</code> event.
     	 * 
		 * <p>The properties of the event object have the following values:</p>
	     * <table class="innertable">
     	 *		<tr><th>Property</th><th>Value</th></tr>
	     *		<tr><td><code>id</code></td><td>ID of the player in the HTML DOM. Used by javascript to reference the player.</td></tr>
	     *		<tr><td><code>client</code></td><td>A string representing the client the player runs in (e.g. FLASH WIN 9,0,115,0).</td></tr>
  	     * 		<tr><td><code>version</code></td><td>A string representing the major version, minor version and revision number of the player (e.g. 5.0.395).</td></tr>
  	     * 		<tr><td><code>position</code></td><td>Number of seconds elapsed since the start of the media playback.</td></tr>
  	     * 		<tr><td><code>duration</code></td><td>Total number of seconds in the currently loaded media.</td></tr>
  	     *  </table>
	     *
	     *  @eventType jwplayerMediaTime
		 */
		public static var JWPLAYER_MEDIA_TIME:String = "jwplayerMediaTime";

		/**
	     *  The <code>MediaEvent.JWPLAYER_MEDIA_VOLUME</code> constant defines the value of the 
     	 *  <code>type</code> property of the event object for a <code>jwplayerMediaVolume</code> event.
     	 * 
		 * <p>The properties of the event object have the following values:</p>
	     * <table class="innertable">
     	 *		<tr><th>Property</th><th>Value</th></tr>
	     *		<tr><td><code>id</code></td><td>ID of the player in the HTML DOM. Used by javascript to reference the player.</td></tr>
	     *		<tr><td><code>client</code></td><td>A string representing the client the player runs in (e.g. FLASH WIN 9,0,115,0).</td></tr>
  	     * 		<tr><td><code>version</code></td><td>A string representing the major version, minor version and revision number of the player (e.g. 5.0.395).</td></tr>
  	     * 		<tr><td><code>duration</code></td><td>The current playback volume, between 0 and 100.</td></tr>
  	     *  </table>
	     *
	     *  @eventType jwplayerMediaVolume
		 */
		public static var JWPLAYER_MEDIA_VOLUME:String = "jwplayerMediaVolume";
		
		public var bufferPercent:Number 	= -1;
		public var duration:Number 			= -1;
		public var metadata:Object 			= {};
		public var position:Number 			= -1;
		public var volume:Number 			= -1;
	
		public function MediaEvent(type:String) {
			super(type);
		}
	}
}