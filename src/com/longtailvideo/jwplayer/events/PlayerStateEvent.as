package com.longtailvideo.jwplayer.events {

	public class PlayerStateEvent extends PlayerEvent {
		public static var JWPLAYER_PLAYER_STATE:String = "jwplayerPlayerState";
		
		public var newstate:String = "";
		public var oldstate:String = "";

		public function PlayerStateEvent(type:String, newState:String, oldState:String) {
			super(type);
			this.newstate = newState;
			this.oldstate = oldState;
		}
	}
}