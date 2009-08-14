package com.longtailvideo.jwplayer.model {
	import flash.events.EventDispatcher;

	/**
	 * Sent when a playlist has been loaded. 
	 *
	 * @eventType com.longtailvideo.jwplayer.evets.PlaylistEvent.JWPLAYER_PLAYLIST_LOADED
	 */
	[Event(name="jwplayerPlaylistLoaded", type = "com.longtailvideo.jwplayer.evets.PlaylistEvent")]

	/**
	 * Sent when the playlist has been updated. 
	 *
	 * @eventType com.longtailvideo.jwplayer.evets.PlaylistEvent.JWPLAYER_PLAYLIST_UPDATED
	 */
	[Event(name="jwplayerPlaylistUpdated", type = "com.longtailvideo.jwplayer.evets.PlaylistEvent")]

	/**
	 * Sent when the playlist's current item has changed. 
	 *
	 * @eventType com.longtailvideo.jwplayer.evets.PlaylistEvent.JWPLAYER_PLAYLIST_ITEM
	 */
	[Event(name="jwplayerPlaylistItem", type = "com.longtailvideo.jwplayer.evets.PlaylistEvent")]

	public class Playlist extends EventDispatcher {
		
		/** **/
		private var list:Array;
		
		/** **/
		private var index:Number;

		/**
		 * Constructor 
		 */
		public function Playlist() {
			list = [];
			index = -1;
		}

		/**
		 * Loads a new playlist
		 *  
		 * @param newPlaylist May be a String (in which case it loads playlist URL), an Array of PlaylistItems or structured Objects, or another Playlist 
		 * 
		 */
		public function load(newPlaylist:Object):void {
			return; 
		}

		/**
		 * Gets a the PlaylistItem at the specified index.
		 * 
		 * @param idx The index of the PlaylistItem to retrieve
		 * @return If a PlaylistItem is found at position <code>idx</code>, it is returned.  Otherwise, returns <code>null</code>
		 */
		public function getItemAt(idx:Number):PlaylistItem {
			try {
				return list[idx];	
			} catch(e:Error) {}
			
			return null;
			
		}
		
		/**
		 * Inserts a PlaylistItem
		 *  
		 * @param itm
		 * @param idx The position in which to place a playlist
		 * 
		 */
		public function insertItem(itm:PlaylistItem, idx:Number=-1):void {
			if (idx >= 0) {
				list.splice(idx, 0, itm);
			} else {
				list.push(itm);
			}
		}

		/**
		 * Removes an item at the requested index
		 *  
		 * @param idx
		 */
		public function removeItemAt(idx:Number):void {
			if (idx >= 0 && idx < list.length && list.length > 0) {
				list.splice(idx, 1);
			}
		}
		
		public function get currentIndex():Number {
			return index;
		}		
		
		public function set currentIndex(idx:Number):void {
			index = idx;
		} 
		
		public function get currentItem():PlaylistItem {
			return getItemAt(index);
		}
		
		public function get length():Number {
			return list.length;
		}

	}
}