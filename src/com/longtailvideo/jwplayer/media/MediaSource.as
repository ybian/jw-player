package com.longtailvideo.jwplayer.media {
	import com.longtailvideo.jwplayer.model.PlaylistItem;
	
	import flash.display.DisplayObject;
	import flash.events.EventDispatcher;

	public class MediaSource extends EventDispatcher {
		/** Reference to the currently active playlistitem. **/
		protected var item:PlaylistItem;
		/** The current position inside the file. **/
		protected var position:Number;
		/** Graphical representation of the currently playing media **/
		protected var media:DisplayObject;
		
		/**
		 * Load a playlist item
		 * @param itm	The currently active playlistitem.
		 **/
		public function load(itm:PlaylistItem):void {
			// Dispatch MediaEvent.LOADED event
		}

		/** Pause playback of the item. **/
		public function pause():void {
			// Dispatch MediaEvent.PAUSE event
		}

		/** Resume playback of the item. **/
		public function play():void {
			// Dispatch MediaEvent.PLAY event
		}

		/**
		 * Seek to a certain position in the item.
		 *
		 * @param pos	The position in seconds.
		 **/
		public function seek(pos:Number):void {
			// Dispatch MediaEvent.SEEK event
			position = pos;
		}

		/** Stop playing and loading the item. **/
		public function stop():void {
			// Dispatch MediaEvent.STOP event
		}

		/**
		 * Change the playback volume of the item.
		 *
		 * @param vol	The new volume (0 to 100).
		 **/
		public function volume(vol:Number):void {
			// Dispatch MediaEvent.VOLUME event
		}
		
		public function display():DisplayObject {
			return media;
		}

	}
}