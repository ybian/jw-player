package com.longtailvideo.jwplayer.events {
	import flash.events.Event;

	/**
	 * Event class thrown by the Player
	 * 
	 * @see com.longtailvideo.jwplayer.player.Player
	 * @author Pablo Schklowsky
	 */
	public class PlayerEvent extends Event {
		
		/**
		 * The PlayerEvent.JWPLAYER_READY constant defines the value of the
		 * <code>type</code> property of the event object
		 * for a <code>jwplayerReady</code> event.
		 *
		 * @see com.longtailvideo.jwplayer.player.Player
		 * @eventType ltasAdComponentsLoaded
		 */
		public static var JWPLAYER_READY:String = "jwplayerReady";

		public function PlayerEvent(type:String) {
			super(type, false, false);
		}
		
	}
}