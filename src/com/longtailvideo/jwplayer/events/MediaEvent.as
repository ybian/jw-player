package com.longtailvideo.jwplayer.events {
	
	
	

	public class MediaEvent extends PlayerEvent {

		public static var JWPLAYER_MEDIA_LOADED:String = "jwplayerMediaLoaded";

		public static var JWPLAYER_MEDIA_BUFFER:String = "jwplayerMediaBuffer";

		public static var JWPLAYER_MEDIA_TIME:String = "jwplayerMediaTime";

		public static var JWPLAYER_MEDIA_ERROR:String = "jwplayerMediaError";

		public static var JWPLAYER_MEDIA_VOLUME:String = "jwplayerMediaVolume";
		
		public var bufferPercent:Number 	= -1;
		public var duration:Number 			= -1;
		public var message:String 			= "";
		public var metadata:Object 			= {};
		public var position:Number 			= -1;
		public var volume:Number 			= -1;
	
		public function MediaEvent(type:String) {
			super(type);
		}
	}
}