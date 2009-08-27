package com.longtailvideo.jwplayer.view {

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
	 * Sent when the user interface requests that the player navigate to the playlist item's <code>link</code> property
	 *
	 * @eventType com.longtailvideo.jwplayer.events.ViewEvent.JWPLAYER_VIEW_LINK
	 */
	[Event(name="jwPlayerViewLink", type = "com.longtailvideo.jwplayer.events.ViewEvent")]

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

	public interface IDisplayComponent {

		function hide(state:Boolean):void;

	}
}