package com.longtailvideo.jwplayer.view {
	import flash.display.DisplayObject;
	import flash.events.IEventDispatcher;

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
	 * Sent when the user reuquests the player set its mute state to the given value
	 *
	 * @eventType com.longtailvideo.jwplayer.events.ViewEvent.JWPLAYER_VIEW_MUTE
	 */
	[Event(name="jwPlayerViewMute", type = "com.longtailvideo.jwplayer.events.ViewEvent")]

	/**
	 * Sent when the user reuquests the player set its fullscreen state to the given value
	 *
	 * @eventType com.longtailvideo.jwplayer.events.ViewEvent.JWPLAYER_VIEW_FULLSCREEN
	 */
	[Event(name="jwPlayerViewFullscreen", type = "com.longtailvideo.jwplayer.events.ViewEvent")]

	/**
	 * Sent when the user requests the player skip to the given playlist index
	 *
	 * @eventType com.longtailvideo.jwplayer.events.ViewEvent.JWPLAYER_VIEW_ITEM
	 */
	[Event(name="jwPlayerViewItem", type = "com.longtailvideo.jwplayer.events.ViewEvent")]

	/**
	 * Sent when the user requests that the player change the playback volume.
	 *
	 * @eventType com.longtailvideo.jwplayer.events.ViewEvent.JWPLAYER_VIEW_VOLUME
	 */
	[Event(name="jwPlayerViewVolume", type = "com.longtailvideo.jwplayer.events.ViewEvent")]

	/**
	 * User request to seek to the given playback location, in seconds.
	 *
	 * @eventType com.longtailvideo.jwplayer.events.ViewEvent.JWPLAYER_VIEW_SEEK
	 */
	[Event(name="jwPlayerViewSeek", type = "com.longtailvideo.jwplayer.events.ViewEvent")]

	public interface IControlbarComponent {
		function addButton(name:String, icon:DisplayObject, clickHandler:Function):void;
		function removeButton(name:String):void;
	}
}