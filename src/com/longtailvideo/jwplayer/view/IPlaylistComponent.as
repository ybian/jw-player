package com.longtailvideo.jwplayer.view {

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
	 * Sent when the user requests the player skip to the given playlist index
	 *
	 * @eventType com.longtailvideo.jwplayer.events.ViewEvent.JWPLAYER_VIEW_ITEM
	 */
	[Event(name="jwPlayerViewItem", type = "com.longtailvideo.jwplayer.events.ViewEvent")]

	public interface IPlaylistComponent {		
	}
}