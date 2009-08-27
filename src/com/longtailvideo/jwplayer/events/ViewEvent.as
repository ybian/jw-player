package com.longtailvideo.jwplayer.events {

	public class ViewEvent extends PlayerEvent {
		
		/**
		 * The ViewEvent.JWPLAYER_VIEW_PLAY constant defines the value of the
		 * <code>type</code> property of the event object
		 * for a <code>jwplayerReady</code> event.
		 *
		 * @eventType jwPlayerViewPlay
		 */
		public static var JWPLAYER_VIEW_PLAY:String = "jwPlayerViewPlay";
		
		/**
		 * The ViewEvent.JWPLAYER_VIEW_PAUSE constant defines the value of the
		 * <code>type</code> property of the event object
		 * for a <code>jwplayerReady</code> event.
		 *
		 * @eventType jwPlayerViewPause
		 */
		public static var JWPLAYER_VIEW_PAUSE:String = "jwPlayerViewPause";
		
		/**
		 * The ViewEvent.JWPLAYER_VIEW_STOP constant defines the value of the
		 * <code>type</code> property of the event object
		 * for a <code>jwplayerReady</code> event.
		 *
		 * @eventType jwPlayerViewStop
		 */
		public static var JWPLAYER_VIEW_STOP:String = "jwPlayerViewStop";
		
		/**
		 * The ViewEvent.JWPLAYER_VIEW_NEXT constant defines the value of the
		 * <code>type</code> property of the event object
		 * for a <code>jwplayerReady</code> event.
		 *
		 * @eventType jwPlayerViewNext
		 */
		public static var JWPLAYER_VIEW_NEXT:String = "jwPlayerViewNext";
		
		/**
		 * The ViewEvent.JWPLAYER_VIEW_PREV constant defines the value of the
		 * <code>type</code> property of the event object
		 * for a <code>jwplayerReady</code> event.
		 *
		 * @eventType jwPlayerViewPrev
		 */
		public static var JWPLAYER_VIEW_PREV:String = "jwPlayerViewPrev";
		
		/**
		 * The ViewEvent.JWPLAYER_VIEW_LINK constant defines the value of the
		 * <code>type</code> property of the event object
		 * for a <code>jwplayerReady</code> event.
		 *
		 * @eventType jwPlayerViewLink
		 */
		public static var JWPLAYER_VIEW_LINK:String = "jwPlayerViewLink";
		
		/**
		 * The ViewEvent.JWPLAYER_VIEW_MUTE constant defines the value of the
		 * <code>type</code> property of the event object
		 * for a <code>jwplayerReady</code> event.
		 *
		 * @eventType jwPlayerViewMute
		 */
		public static var JWPLAYER_VIEW_MUTE:String = "jwPlayerViewMute";
		
		/**
		 * The ViewEvent.JWPLAYER_VIEW_FULLSCREEN constant defines the value of the
		 * <code>type</code> property of the event object
		 * for a <code>jwplayerReady</code> event.
		 *
		 * @eventType jwPlayerViewFullscreen
		 */
		public static var JWPLAYER_VIEW_FULLSCREEN:String = "jwPlayerViewFullscreen";

		/**
		 * The ViewEvent.JWPLAYER_VIEW_ITEM constant defines the value of the
		 * <code>type</code> property of the event object
		 * for a <code>jwplayerReady</code> event.
		 *
		 * @eventType jwPlayerViewItem
		 */
		public static var JWPLAYER_VIEW_ITEM:String = "jwPlayerViewItem";
		
		/**
		 * The ViewEvent.JWPLAYER_VIEW_VOLUME constant defines the value of the
		 * <code>type</code> property of the event object
		 * for a <code>jwplayerReady</code> event.
		 *
		 * @eventType jwPlayerViewVolume
		 */
		public static var JWPLAYER_VIEW_VOLUME:String = "jwPlayerViewVolume";
		
		/**
		 * The ViewEvent.JWPLAYER_VIEW_LOAD constant defines the value of the
		 * <code>type</code> property of the event object
		 * for a <code>jwplayerReady</code> event.
		 *
		 * @eventType jwPlayerViewLoad
		 */
		public static var JWPLAYER_VIEW_LOAD:String = "jwPlayerViewLoad";
		
		/**
		 * The ViewEvent.JWPLAYER_VIEW_REDRAW constant defines the value of the
		 * <code>type</code> property of the event object
		 * for a <code>jwplayerReady</code> event.
		 *
		 * @eventType jwPlayerViewRedraw
		 */
		public static var JWPLAYER_VIEW_REDRAW:String = "jwPlayerViewRedraw";

		/**
		 * The ViewEvent.JWPLAYER_VIEW_SEEK constant defines the value of the
		 * <code>type</code> property of the event object
		 * for a <code>jwplayerReady</code> event.
		 *
		 * @eventType jwPlayerViewSeek
		 */
		public static var JWPLAYER_VIEW_SEEK:String = "jwPlayerViewSeek";

		/** Sent along with REQUEST Event types. **/
		public var data:*;
		
		public function ViewEvent(type:String, data:*=null) {
			super(type);
			
			this.data = data;
		}
		
	}
}