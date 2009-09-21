package com.longtailvideo.jwplayer.view {
	import flash.events.Event;
	import flash.display.DisplayObject;
	
		/**
	 * Sent when the user interface requests that the player play the currently loaded media
	 *
	 * @eventType com.longtailvideo.jwplayer.events.ViewEvent.JWPLAYER_VIEW_PLAY
	 */
	[Event(name="jwPlayerViewPlay", type = "com.longtailvideo.jwplayer.events.ViewEvent")]

	/**
	 * Sent when the user interface requests that the player pause the currently playing media
	 *
	 * @eventType com.longtailvideo.jwplayer.events.ViewEvent.JWPLAYER_VIEW_PAUSE
	 */
	[Event(name="jwPlayerViewPause", type = "com.longtailvideo.jwplayer.events.ViewEvent")]

	/**
	 * Sent when the user interface requests that the player stop the currently playing media
	 *
	 * @eventType com.longtailvideo.jwplayer.events.ViewEvent.JWPLAYER_VIEW_STOP
	 */
	[Event(name="jwPlayerViewStop", type = "com.longtailvideo.jwplayer.events.ViewEvent")]

	/**
	 * Sent when the user interface requests that the player play the next item in its playlist
	 *
	 * @eventType com.longtailvideo.jwplayer.events.ViewEvent.JWPLAYER_VIEW_NEXT
	 */
	[Event(name="jwPlayerViewNext", type = "com.longtailvideo.jwplayer.events.ViewEvent")]

	/**
	 * Sent when the user interface requests that the player play the previous item in its playlist
	 *
	 * @eventType com.longtailvideo.jwplayer.events.ViewEvent.JWPLAYER_VIEW_PREV
	 */
	[Event(name="jwPlayerViewPrev", type = "com.longtailvideo.jwplayer.events.ViewEvent")]

	/**
	 * Sent when the user interface requests that the player navigate to the playlist item's <code>link</code> property
	 *
	 * @eventType com.longtailvideo.jwplayer.events.ViewEvent.JWPLAYER_VIEW_LINK
	 */
	[Event(name="jwPlayerViewLink", type = "com.longtailvideo.jwplayer.events.ViewEvent")]

	/**
	 *
	 *
	 * @eventType com.longtailvideo.jwplayer.events.ViewEvent.JWPLAYER_VIEW_MUTE
	 */
	[Event(name="jwPlayerViewMute", type = "com.longtailvideo.jwplayer.events.ViewEvent")]

	/**
	 *
	 *
	 * @eventType com.longtailvideo.jwplayer.events.ViewEvent.JWPLAYER_VIEW_FULLSCREEN
	 */
	[Event(name="jwPlayerViewFullscreen", type = "com.longtailvideo.jwplayer.events.ViewEvent")]

	/**
	 *
	 *
	 * @eventType com.longtailvideo.jwplayer.events.ViewEvent.JWPLAYER_VIEW_VOLUME
	 */
	[Event(name="jwPlayerViewVolume", type = "com.longtailvideo.jwplayer.events.ViewEvent")]

	/**
	 *
	 *
	 * @eventType com.longtailvideo.jwplayer.events.ViewEvent.JWPLAYER_VIEW_SEEK
	 */
	[Event(name="jwPlayerViewSeek", type = "com.longtailvideo.jwplayer.events.ViewEvent")]
	
	
	public class ControlBarComponent extends CoreComponent implements IControlbarComponent {
		public function ControlBarComponent() {
			//TODO: implement function
			super();
		}
		
		
		public function addButton(name:String, icon:DisplayObject, clickHandler:Function):void {
			//TODO: implement function
		}
		
		
		public function removeButton(name:String):void {
			//TODO: implement function
		}
	}
}