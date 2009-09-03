package com.longtailvideo.jwplayer.model {
	import com.longtailvideo.jwplayer.events.PlaylistEvent;
	
	import flash.events.ErrorEvent;
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

	/**
	 * Sent when an error ocurred when loading or parsing the playlist 
	 *
	 * @eventType flash.events.ErrorEvent.ERROR
	 */
	[Event(name="error", type = "flash.events.ErrorEvent")]

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
		 * Replaces all playlist items
		 *  
		 * @param newPlaylist May be an Array of PlaylistItems or structured Objects, or another Playlist 
		 * 
		 */
		public function load(newPlaylist:Object):void {
			var newList:Array = [];
			if (newPlaylist is Array) {
				for (var i:Number = 0; i < (newPlaylist as Array).length; i++) {
					if (!(newPlaylist[i] is PlaylistItem)) {
						var newItem:PlaylistItem = new PlaylistItem(newPlaylist[i]);
						newPlaylist[i] = newItem;
					}
					try {
						if ((newPlaylist[i] as PlaylistItem).file) {
							newList.push(newPlaylist[i] as PlaylistItem);
						}
					} catch (e:Error) {}
				}
			} else if (newPlaylist is Playlist) {
				for (i = 0; i < (newPlaylist as Playlist).length; i++) {
					newList.push((newPlaylist as Playlist).getItemAt(i));
				}
			} else {
				dispatchEvent(new ErrorEvent("Playlist could not be loaded: incorrect type"));
				return;
			}

			list = newList;
			index = newList.length > 0 ? 0 : -1;

			dispatchEvent(new PlaylistEvent(PlaylistEvent.JWPLAYER_PLAYLIST_LOADED));
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
			if (idx >= 0 && idx < list.length) {
				list.splice(idx, 0, itm);
			} else {
				list.push(itm);
			}
			
			dispatchEvent(new PlaylistEvent(PlaylistEvent.JWPLAYER_PLAYLIST_UPDATED));
			
			if (index < 0) {
				currentIndex = list.length - 1;
			} 
		}

		/**
		 * Removes an item at the requested index
		 *  
		 * @param idx The index from which to remove the item
		 */
		public function removeItemAt(idx:Number):void {
			if (idx >= 0 && idx < list.length && list.length > 0) {
				list.splice(idx, 1);
				dispatchEvent(new PlaylistEvent(PlaylistEvent.JWPLAYER_PLAYLIST_UPDATED));
			}
			
			if (index >= list.length) {
				currentIndex = list.length - 1;
			}
		}
		
		public function get currentIndex():Number {
			return index;
		}		
		
		public function set currentIndex(idx:Number):void {
			if (idx != index && idx < list.length) {
				if (idx >= 0) {
					index = idx;
					dispatchEvent(new PlaylistEvent(PlaylistEvent.JWPLAYER_PLAYLIST_ITEM));
				} else {
					index = -1;
				}
			}
		} 
		
		public function get currentItem():PlaylistItem {
			return getItemAt(index);
		}
		
		public function get length():Number {
			return list.length;
		}

	}
}