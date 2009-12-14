package com.longtailvideo.jwplayer.model {
	import com.longtailvideo.jwplayer.events.GlobalEventDispatcher;
	import com.longtailvideo.jwplayer.events.PlayerEvent;
	import com.longtailvideo.jwplayer.events.PlaylistEvent;
	import com.longtailvideo.jwplayer.parsers.IPlaylistParser;
	import com.longtailvideo.jwplayer.parsers.JWParser;
	import com.longtailvideo.jwplayer.parsers.ParserFactory;
	import com.longtailvideo.jwplayer.utils.AssetLoader;
	
	import flash.events.ErrorEvent;
	import flash.events.Event;
	
	
	/**
	 * Sent when a playlist has been loaded.
	 *
	 * @eventType com.longtailvideo.jwplayer.events.PlaylistEvent.JWPLAYER_PLAYLIST_LOADED
	 */
	[Event(name="jwplayerPlaylistLoaded", type="com.longtailvideo.jwplayer.events.PlaylistEvent")]
	
	
	/**
	 * Sent when the playlist has been updated.
	 *
	 * @eventType com.longtailvideo.jwplayer.events.PlaylistEvent.JWPLAYER_PLAYLIST_UPDATED
	 */
	[Event(name="jwplayerPlaylistUpdated", type="com.longtailvideo.jwplayer.events.PlaylistEvent")]
	
	
	/**
	 * Sent when the playlist's current item has changed.
	 *
	 * @eventType com.longtailvideo.jwplayer.events.PlaylistEvent.JWPLAYER_PLAYLIST_ITEM
	 */
	[Event(name="jwplayerPlaylistItem", type="com.longtailvideo.jwplayer.events.PlaylistEvent")]
	
	
	/**
	 * Sent when an error ocurred when loading or parsing the playlist
	 *
	 * @eventType com.longtailvideo.jwplayer.events.PlayerEvent.JWPLAYER_ERROR
	 */
	[Event(name="jwplayerError", type = "com.longtailvideo.jwplayer.events.PlayerEvent")]
	
	
	public class Playlist extends GlobalEventDispatcher implements IPlaylist {
		/** An array holding all of the PlaylistItem objects **/
		private var list:Array;
		/** The current playlist index **/
		private var index:Number;
		/** Keep track of the last playlistItem, so we can send a PLAYLIST_ITEM event at the correct time **/
		private var lastItem:PlaylistItem = null;
		
		/**
		 * Constructor
		 */
		public function Playlist() {
			list = [];
			index = -1;
		}
		
		
		/**
		 * @inheritDoc
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
					} catch (e:Error) {
					}
				}
			} else if (newPlaylist is PlaylistItem) {
				var pli:PlaylistItem = newPlaylist as PlaylistItem;
				JWParser.updateProvider(pli);
				if (pli.provider) {
					newList.push(pli);
				} else {
					load(pli.file);
					return;
				}
			} else if (newPlaylist is Playlist) {
				for (i = 0; i < (newPlaylist as Playlist).length; i++) {
					newList.push((newPlaylist as Playlist).getItemAt(i));
				}
			} else if (newPlaylist is String && newPlaylist != "") {
				var playlistLoader:AssetLoader = new AssetLoader();
				playlistLoader.addEventListener(Event.COMPLETE, playlistLoaded);
				playlistLoader.addEventListener(ErrorEvent.ERROR, playlistLoadError);
				playlistLoader.load(String(newPlaylist), XML);
				return;
			} else {
				playlistError("Incorrect playlist type");
				return;
			}
			if (newList.length > 0) {
				list = newList;
				index = 0;
				dispatchEvent(new PlaylistEvent(PlaylistEvent.JWPLAYER_PLAYLIST_LOADED, this));
				currentIndex = 0;
			} else {
				dispatchEvent(new PlayerEvent(PlayerEvent.JWPLAYER_ERROR, "Loaded playlist is empty"));
			}
			return;
		}
		
		
		protected function playlistLoaded(evt:Event):void {
			var loader:AssetLoader = evt.target as AssetLoader;
			var loadedXML:XML = loader.loadedObject as XML;
			var parser:IPlaylistParser = ParserFactory.getParser(loadedXML);
			if (parser) {
				var playlistItems:Array = parser.parse(loadedXML);
				if (playlistItems.length > 0) {
					load(playlistItems);
				} else {
					playlistError("XML could not be parsed or playlist was empty");
				}
			} else {
				playlistError("Playlist file did not contain a valid playlist");
			}
		}
		
		
		protected function playlistLoadError(evt:ErrorEvent):void {
			playlistError(evt.text);
		}
		
		
		protected function playlistError(message:String):void {
			dispatchEvent(new PlayerEvent(PlayerEvent.JWPLAYER_ERROR, "Playlist could not be loaded: " + message));
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function getItemAt(idx:Number):PlaylistItem {
			try {
				return list[idx];
			} catch (e:Error) {
			}
			return null;
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function insertItem(itm:PlaylistItem, idx:Number = -1):void {
			if (idx >= 0 && idx < list.length) {
				list.splice(idx, 0, itm);
			} else {
				list.push(itm);
			}
			dispatchEvent(new PlaylistEvent(PlaylistEvent.JWPLAYER_PLAYLIST_UPDATED, this));
			if (index < 0) {
				currentIndex = list.length - 1;
			}
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function removeItemAt(idx:Number):void {
			if (idx >= 0 && idx < list.length && list.length > 0) {
				list.splice(idx, 1);
				dispatchEvent(new PlaylistEvent(PlaylistEvent.JWPLAYER_PLAYLIST_UPDATED, this));
			}
			if (index >= list.length) {
				currentIndex = list.length - 1;
			}
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function get currentIndex():Number {
			return index;
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function set currentIndex(idx:Number):void {
			if (getItemAt(idx) != lastItem) {
				if (idx >= 0) {
					index = idx;
					lastItem = currentItem;
					dispatchEvent(new PlaylistEvent(PlaylistEvent.JWPLAYER_PLAYLIST_ITEM, this));
				} else {
					lastItem = null;
					index = -1;
				}
			}
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function get currentItem():PlaylistItem {
			return index >= 0 ? getItemAt(index) : null;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get length():Number {
			return list.length;
		}
		
		/**
		 * @inheritDoc
		 **/
		public function contains(item:PlaylistItem):Boolean {
			for (var i:Number=0; i < length; i++) {
				if (getItemAt(i) == item) return true;
			}
			return false;
		}
	}
}