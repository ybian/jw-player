package com.longtailvideo.jwplayer.events {

	public class MediaStateEvent extends MediaEvent {
		public static var JWPLAYER_MEDIA_STATE:String = "jwplayerMediaState";
		
		public var newstate:String = "";
		public var oldstate:String = "";

		public function MediaStateEvent(type:String, newState:String, oldState:String) {
			super(type);
			this.newstate = newState;
			this.oldstate = oldState;
		}
	}
}