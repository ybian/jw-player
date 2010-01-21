package com.longtailvideo.jwplayer.model {

	/**
	 * Playlist item data.  The class is dynamic; any items parsed from the jwplayer XML namespace are added to the item.
	 *  
	 * @author Pablo Schklowsky
	 */
	public dynamic class PlaylistItem {
		public var author:String		= "";
		public var date:String			= "";
		public var description:String	= "";
		public var duration:Number		= -1;
		public var image:String			= "";
		public var link:String			= "";
		public var mediaid:String		= "";
		public var start:Number			= 0;
		public var streamer:String		= "";
		public var tags:String			= "";
		public var title:String			= "";
		public var provider:String		= "";
		
		protected var _file:String			= "";
		protected var _currentLevel:Number 	= -1;
		protected var _levels:Array			= [];
		
		public function PlaylistItem(obj:Object = null) {
			for (var itm:String in obj) {
				if (this[itm] && typeof(this[itm]) == typeof(0)) {
					this[itm] = Number(obj[itm]);
				} else if (itm == "levels" && obj[itm] is Array) {
					var levels:Array = obj[itm] as Array;
					for each (var level:Object in levels) {
						if (level['file'] && level['bitrate'] && level['width']) {
							addLevel(new PlaylistItemLevel(level['file'], level['bitrate'], level['width']));
						}
					}
				} else {
					this[itm] = obj[itm];
				}
			}
		}

		/** File property is now a getter, to take levels into account **/
		public function get file():String {
			if (_levels.length > 0 && _currentLevel > -1 && _currentLevel < _levels.length) {
				return (_levels[_currentLevel] as PlaylistItemLevel).file;
			} else {
				return _file;
			}
		}
		
		/** File setter.  Note, if levels are defined, this will be ignored. **/
		public function set file(f:String):void {
			_file = f;
		}
		
		/** The quality levels associated with this playlist item **/
		public function get levels():Array {
			return _levels;
		}
		
		/** Insert an additional bitrate level, keeping the array sorted from highest to lowest. **/
		public function addLevel(newLevel:PlaylistItemLevel):void {
			if (_currentLevel < 0) _currentLevel = 0;
			for (var i:Number = 0; i < _levels.length; i++) {
				var level:PlaylistItemLevel = _levels[i] as PlaylistItemLevel;
				if (newLevel.bitrate > level.bitrate) {
					_levels.splice(i, 0, newLevel);
					return;
				} else if (newLevel.bitrate == level.bitrate && newLevel.width > level.width) {
					_levels.splice(i, 0, newLevel);
					return;
				}
			}
			
			_levels.push(newLevel);
		}

		public function get currentLevel():Number {
			return _currentLevel;
		}
		
		public function getLevel(bitrate:Number, width:Number):Number {
			for (var i:Number=0; i < _levels.length; i++) {
				var level:PlaylistItemLevel = _levels[i] as PlaylistItemLevel;
				if (bitrate >= level.bitrate && width >= level.width * 0.9) {
					return i;
				}
			}
			return _levels.length - 1;
		}
		
		/** Set this PlaylistItem's level to match the given bitrate and height. **/
		public function setLevel(newLevel:Number):void {
			if (newLevel >= 0 && newLevel < _levels.length) {
				_currentLevel = newLevel;
			} else {
				throw(new Error("Level index out of bounds"));
			}
		}
		
		// For backwards compatibility
		public function get type():String { return provider; }
		public function set type(t:String):void { provider = t; }
		
	}
}