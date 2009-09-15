package com.longtailvideo.jwplayer.media {
	import com.longtailvideo.jwplayer.model.PlaylistItem;
	import flash.display.DisplayObject;
	
	
	public interface IMediaSource {
		/**
		 * Load a new playlist item
		 * @param itm The playlistItem to load
		 **/
		function load(itm:PlaylistItem):void;
		
		
		/** Pause playback of the item. **/
		function pause():void;
		
		
		/** Resume playback of the item. **/
		function play():void;
		
		
		/**
		 * Seek to a certain position in the item.
		 *
		 * @param pos	The position in seconds.
		 **/
		function seek(pos:Number):void;
		
		
		/** Stop playing and loading the item. **/
		function stop():void;
		
		
		/**
		 * Change the playback volume of the item.
		 *
		 * @param vol	The new volume (0 to 100).
		 **/
		function setVolume(vol:Number):void;
		
		
		/** Graphical representation of media **/
		function display():DisplayObject;
		
		
		/**
		 * Current state of the MediaSource.
		 * @see MediaStates
		 */
		function get state():String;
		
		
		/** Currently playing PlaylistItem **/
		function get item():PlaylistItem;
		
		
		/** Current position, in seconds **/
		function get position():Number;
		
		
		/**
		 * The current volume of the playing media
		 * <p>Range: 0-100</p>
		 */
		function get volume():Number;
	}
}
