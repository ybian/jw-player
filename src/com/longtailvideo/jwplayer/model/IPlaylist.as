package com.longtailvideo.jwplayer.model {
	import com.longtailvideo.jwplayer.events.IGlobalEventDispatcher;
	
	
	
	/**
	 * Interface for JW Flash Media Player playlist
	 *
	 * @author Zachary Ozer
	 */
	public interface IPlaylist extends IGlobalEventDispatcher {
		/**
		 * Replaces all playlist items
		 *
		 * @param newPlaylist May be an Array of PlaylistItems or structured Objects, a PlaylistItem, or another Playlist
		 */
		function load(newPlaylist:Object):void;
		/**
		 * Gets a the PlaylistItem at the specified index.
		 *
		 * @param idx The index of the PlaylistItem to retrieve
		 * @return If a PlaylistItem is found at position <code>idx</code>, it is returned.  Otherwise, returns <code>null</code>
		 */
		function getItemAt(idx:Number):PlaylistItem;
		/**
		 * Inserts a PlaylistItem
		 *
		 * @param itm
		 * @param idx The position in which to place a playlist
		 *
		 */
		function insertItem(itm:PlaylistItem, idx:Number = -1):void;
		/**
		 * Removes an item at the requested index
		 *
		 * @param idx The index from which to remove the item
		 */
		function removeItemAt(idx:Number):void;
		function get currentIndex():Number;
		function set currentIndex(idx:Number):void;
		function get currentItem():PlaylistItem;
		function get length():Number;
	}
}