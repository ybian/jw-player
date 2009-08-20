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

		/**
		 * The PlaylistEvent.JWPLAYER_PLAYLIST_UPDATED constant defines the value of the
		 * <code>type</code> property of the event object
		 * for a <code>jwplayerPlaylistUpdated</code> event.
		 *
		 * @see com.longtailvideo.jwplayer.player.Player
		 * @eventType jwplayerPlaylistUpdated
		 */
		public static var JWPLAYER_PLAYLIST_UPDATED:String = "jwplayerPlaylistUpdated";

		/**
		 * The PlaylistEvent.JWPLAYER_PLAYLIST_ITEM constant defines the value of the
		 * <code>type</code> property of the event object
		 * for a <code>jwplayerPlaylistItem</code> event.
		 *
		 * @see com.longtailvideo.jwplayer.player.Player
		 * @eventType jwplayerPlaylistItem
		 */
		public static var JWPLAYER_PLAYLIST_ITEM:String = "jwplayerPlaylistItem";

		public function PlaylistEvent(type:String) {
			super(type, false, false);
		}
		
	}
}