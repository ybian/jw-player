package com.longtailvideo.jwplayer.model {
	import com.longtailvideo.jwplayer.plugins.PluginConfig;
	import com.longtailvideo.jwplayer.utils.TypeChecker;
	
	import flash.events.EventDispatcher;

	/**
	 * Configuration data for the player
	 *
	 * @author Pablo Schklowsky
	 */
	public dynamic class PlayerConfig extends EventDispatcher {
		/** Internal playlist reference **/
		private var _list:Playlist;

		private var _autostart:Boolean 		= false; 
		private var _bufferlength:Number 	= 1; 
		private var _displayclick:String 	= "play"; 
		private var _displaytitle:Boolean 	= true; 
		private var _fullscreen:Boolean 	= false;
		private var _item:Number			= 0;
		private var _linktarget:String 		= "_blank";
		private var _mute:Boolean 			= false;
		private var _repeat:String 			= "none"; 
		private var _shuffle:Boolean 		= false; 
		private var _smoothing:Boolean 		= false; 
		private var _stretching:String 		= "uniform"; 
		private var _volume:Number 			= 90;

		private var _backcolor:uint			= 0x000000;
		private var _frontcolor:uint		= 0xFFFFFF;
		private var _lightcolor:uint		= 0xFFFFFF;
		private var _screencolor:uint		= 0x000000;
		
		private var _controlbar:String 		= "none";
		private var _dock:Boolean 			= false;
		private var _height:Number 			= 400;
		private var _icons:Boolean 			= true;
		private var _logo:String 			= null;
		private var _playlist:String 		= null;
		private var _playlistsize:Number 	= 180;
		private var _skin:String 			= null;
		private var _width:Number 			= 280;
		
		private var _plugins:String 		= null
		private var _pluginConfig:Object 	= {};
		
		public function PlayerConfig(playlist:Playlist):void {
			getCookiedParams();
			setPlaylist(playlist);
		}
		
		public function setPlaylist(list:Playlist):void {
			_list = list;
		}
		
		public function setConfig(config:Object):void {
			var newItem:PlaylistItem = new PlaylistItem();
			var playlistItems:Boolean = false;
			for (var item:String in config) {
				if (newItem.hasOwnProperty(item)) {
					if (_list.length > 0) {
						_list.currentItem[item] = config[item];
					} else {
						newItem[item] = config[item];
						playlistItems = true;
					}
				} else if (item.indexOf(".") > 0) {
					setPluginProperty(item, config[item]);
				} else if (config[item]) {
					setProperty(item, config[item]);
				}
			}
			if (playlistItems && _list.length == 0) {
				_list.insertItem(newItem, 0);
			}
		}
		
		private function setProperty(name:String, value:String):void {
			if (hasOwnProperty(name)) {
				try {
					this[name] = TypeChecker.fromString(value, TypeChecker.getType(this, name));
				} catch (e:Error) {
					// 'name' was a read-only property
				}
			} else {
				this[name] = value;
			}
		}

		/**
		 * Sets the value of a plugin config property 
		 * @param name The parameter name in the form "pluginname.propertyname"
		 * @param value The value to set.
		 */
		private function setPluginProperty(name:String, value:String):void {
			var pluginName:String = name.substring(0, name.indexOf(".")).toLowerCase();
			var pluginProperty:String = name.substring(name.indexOf(".") + 1, name.length).toLowerCase();

			if (pluginName && pluginProperty && value) {
				if (!_pluginConfig.hasOwnProperty(pluginName)) {
					_pluginConfig[pluginName] = new PluginConfig(pluginName);
				}
				_pluginConfig[pluginName][pluginProperty] = TypeChecker.fromString(value);
			}
		}

		/**
		 * Loads cookied values and overwrites default properties.
		 */
		private function getCookiedParams():void {
			// TODO: Implement flash cookies
			return;
		}

		/**
		 * Returns a string representation of the playlist's current PlaylistItem property.
		 * @param key The requested PlaylistItem property
		 */
		private function playlistItem(key:String):String {
			try {
				return _list.currentItem[key].toString();
			} catch (e:Error) {
			}

			return "";
		}

		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// PLAYLIST PROPERTIES
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

		/** Author of the video, shown in the display or playlist. **/
		public function get author():String { return playlistItem('author'); }

		/** Publish date of the media file. **/
		public function get date():String { return playlistItem('date'); }

		/** Text description of the file. **/
		public function get description():String { return playlistItem('description'); }

		/** Duration of the file in seconds. **/
		public function get duration():String { return playlistItem('duration'); }

		/** Location of the mediafile or playlist to play. **/
		public function get file():String { return playlistItem('file'); }

		/** Location of a preview image; shown in display and playlist. **/
		public function get image():String { return playlistItem('image'); }
		
		/** URL to an external page the display, controlbar and playlist can link to. **/
		public function get link():String { return playlistItem('link'); }

		/** Unique identifier. **/		public function get mediaid():String {			return playlistItem('mediaid');		}		/** Position in seconds where playback has to start. Won't work for regular (progressive) videos, but only for streaming (HTTP / RTMP). **/
		public function get start():String { return playlistItem('start'); }
		
		/** Location of an rtmp/http server instance to use for streaming. Can be an RTMP application or external PHP/ASP file. **/
		public function get streamer():String { return playlistItem('streamer'); }
		
		/** Keywords associated with the media file. **/
		public function get tags():String { return playlistItem('tags'); }

		/** Title of the video, shown in the display or playlist. **/
		public function get title():String { return playlistItem('title'); }

		/**
		 * By default, the type is detected by the player based upon the file extension. If there's no suitable
		 * extension or the player detects the type wrong, it can be manually set. The following default types are
		 * supported:
		 * <ul>
		 * <li>video: progressively downloaded FLV / MP4 video, but also AAC audio.</li>
		 * <li>sound: progressively downloaded MP3 files.</li>
		 * <li>image: JPG/GIF/PNG images.</li>
		 * <li>youtube: videos from Youtube.</li>
		 * <li>http: FLV/MP4 videos played as http speudo-streaming.</li>
		 * <li>rtmp: FLV/MP4/MP3 files played from an RTMP server.</li>
		 * </ul>
		 **/
		public function get provider():String { return playlistItem('provider'); }

		/** Deprecated.  Use "provider" flashvar. **/
		public function get type():String { return playlistItem('provider'); }

		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// LAYOUT PROPERTIES
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

		/** Background color of the controlbar and playlist. This is white with the default skin. **/
		public function get backcolor():uint { return _backcolor; }
		public function set backcolor(x:uint):void { _backcolor = x; }
		
		/** Color of all icons and texts in the controlbar and playlist. **/
		public function get frontcolor():uint { return _frontcolor; }
		public function set frontcolor(x:uint):void { _frontcolor = x; }

		/** Color of an icon or text when you rollover it with the mouse. **/
		public function get lightcolor():uint { return _lightcolor; }
		public function set lightcolor(x:uint):void { _lightcolor = x; }

		/** Background color of the display. **/
		public function get screencolor():uint { return _screencolor; }
		public function set screencolor(x:uint):void { _screencolor= x; }

		/** Position of the controlbar. Can be set to top, bottom, over and none.  @default bottom **/
		public function get controlbar():String { return _controlbar; }
		public function set controlbar(x:String):void { _controlbar= x; }

		/** Set this to true to show the dock with large buttons in the top right of the player. Available since 4.5.  @default true **/
		public function get dock():Boolean { return _dock; }
		public function set dock(x:Boolean):void { _dock = x; }

		/** Height of the display in pixels. @default 280 **/
		public function get height():Number { return _height; }
		public function set height(x:Number):void { _height = x; }

		/** Set this to false to hide the play button and buffering icon in the middle of the video. Available since 4.2.  @default true **/
		public function get icons():Boolean { return _icons; }
		public function set icons(x:Boolean):void { _icons = x; }

		/** Location of an external jpg, png or gif image to show in a corner of the display. With the default skin, this is top-right, but every skin can freely place the logo. **/
		public function get logo():String { return _logo; }
		public function set logo(x:String):void { _logo = x; }

		/** Position of the playlist. Can be set to bottom, over, right or none. @default none **/
		public function get playlist():String { return _playlist; }
		public function set playlist(x:String):void { _playlist = x; }

		/** When below this refers to the height, when right this refers to the width of the playlist. @default 180 **/
		public function get playlistsize():Number { return _playlistsize; }
		public function set playlistsize(x:Number):void { _playlistsize = x; }

		/** 
		 * Location of a SWF or ZIP file with the player graphics. The player skinning documentation gives more info on this.  
		 * SVN contains a couple of example skins. 
		 **/
		public function get skin():String { return _skin; }
		public function set skin(x:String):void { _skin = x; }

		/** Width of the display in pixels. @default 400 **/
		public function get width():Number { return _width; }
		public function set width(x:Number):void { _width = x; }

		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// BEHAVIOR PROPERTIES
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

		/** Automatically start the player on load. @default false **/
		public function get autostart():Boolean { return _autostart; }
		public function set autostart(x:Boolean):void { _autostart = x; }

		/** 
		 * Number of seconds of the file that has to be loaded before starting. Set this to a low value to enable instant-start and to a 
		 * high value to get less mid-stream buffering. 
		 * @default 1
		 **/
		public function get bufferlength():Number { return _bufferlength; }
		public function set bufferlength(x:Number):void { _bufferlength = x; }

		/** 
		 * What to do when one clicks the display. Can be play, link, fullscreen, none, mute, next. When set to none, the handcursor is 
		 * also not shown. @default play 
		 **/
		public function get displayclick():String { return _displayclick; }
		public function set displayclick(x:String):void { _displayclick = x; }

		/** Set this to true to print the title of a video in the display. @default true **/
		public function get displaytitle():Boolean { return _displaytitle; }
		public function set displaytitle(x:Boolean):void { _displaytitle = x; }

		/** Current fullscreen state **/		
		public function get fullscreen():Boolean { return _fullscreen; }
		public function set fullscreen(x:Boolean):void { _fullscreen = x; }		
		
		/** PlaylistItem that should start to play. Use this to set a specific start-item. @default 0 **/
		public function get item():Number { return _item; }
		public function set item(x:Number):void { _item = x; }

		/** Browserframe where link from the display are opened in. Some possibilities are '_self' (same frame) or '_blank' (new browserwindow). @default _blank **/
		public function get linktarget():String { return _linktarget; }
		public function set linktarget(x:String):void { _linktarget = x; }
		
		/** Mute all sounds on startup. This value is set in a user cookie, and is retrieved the next time the player loads. **/
		public function get mute():Boolean { return _mute; }
		public function set mute(x:Boolean):void { _mute = x; }

		/** Set to list to play the entire playlist once, to always to continously play the song/video/playlist and to single to continue repeating the selected file in a playlist. @default none **/
		public function get repeat():String { return _repeat; }
		public function set repeat(x:String):void { _repeat = x; }

		/** Shuffle playback of playlist items. @default false **/
		public function get shuffle():Boolean { return _shuffle; }
		public function set shuffle(x:Boolean):void { _shuffle = x; }

		/** this sets the smoothing of videos, so you won't see blocks when a video is upscaled. Set this to false to get performance improvements with old computers / big files. Available since 4.4. @default false **/
		public function get smoothing():Boolean { return _smoothing; }
		public function set smoothing(x:Boolean):void { _smoothing = x; }

		/** Defines how to resize images in the display. Can be none (no stretching), exactfit (disproportionate), uniform (stretch with black borders) or fill (uniform, but completely fill the display). @default uniform **/
		public function get stretching():String{ return _stretching; }
		public function set stretching(x:String):void { _stretching = x; }

		/** Startup volume of the player. Can be 0 to 100. Is saved in a cookie. @default 90 **/
		public function get volume():Number { return _volume; }
		public function set volume(x:Number):void { _volume = x; }

		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// PLUGINS
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

		/** Which plugins to load **/		
		public function get plugins():String { return _plugins; }
		public function set plugins(x:String):void { _plugins = x; }
		
		/**
		 * Returns a PluginConfig containing plugin configuration information
		 * 
		 * @param pluginName Name of the plugin whose config to return.
		 */
		public function pluginConfig(pluginName:String):PluginConfig {
			if (_pluginConfig.hasOwnProperty(pluginName)) {
				return _pluginConfig[pluginName] as PluginConfig;
			}
			
			return new PluginConfig(pluginName);
		}

	}
}
