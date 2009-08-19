package com.longtailvideo.jwplayer.model {
	import com.longtailvideo.jwplayer.events.GlobalEventDispatcher;
	
	/**
	 * 
	 * @author Pablo Schklowsky
	 * 
	 */
	public class Model extends GlobalEventDispatcher {
		private var _config:PlayerConfig;
		private var _playlist:Playlist;

		private var _state:String;
		private var _fullscreen:Boolean = false;
		private var _mute:Boolean = false;
		
		/** Constructor **/
		public function Model() {
			_playlist = new Playlist();
			_config = new PlayerConfig(this);
		}
		
		/** The player config object **/ 
		public function get config():PlayerConfig {
			return _config;
		}
		
		/**
		 * The current player state 
		 */
		public function get state():String {
			return _state;
		}

		private function set state(st:String):void {
			_state = st;
		}
		
		/**
		 * The loaded playlist 
		 */
		public function get playlist():Playlist {
			return _playlist;
		}

		/** The current fullscreen state of the player **/
		public function get fullscreen():Boolean {
			return _fullscreen;
		}
		public function set fullscreen(b:Boolean):void {
			_fullscreen = b;
		}

		/** The current fullscreen state of the player **/
		public function get mute():Boolean {
			return _mute;
		}
		public function set mute(b:Boolean):void {
			_mute = b;
		}

	}
}