package com.longtailvideo.jwplayer.events {
	import flash.events.Event;

	/**
	 * Event class thrown by the Playlist
	 * 
	 * @see com.longtailvideo.jwplayer.model.Playlist
	 * @author Pablo Schklowsky
	 */
	public class PlaylistEvent extends Event {
		
		/**
		 * The PlaylistEvent.JWPLAYER_PLAYLIST_LOADED constant defines the value of the
		 * <code>type</code> property of the event object
		 * for a <code>jwplayerPlaylistLoaded</code> event.
		 *
		 * @see com.longtailvideo.jwplayer.player.Player
		 * @eventType jwplayerPlaylistLoaded
		 */
		public static var JWPLAYER_PLAYLIST_LOADED:String = "jwplayerPlaylistLoaded";

		public function PlaylistEvent(type:String) {
			super(type, false, false);
		}
		
	}
}