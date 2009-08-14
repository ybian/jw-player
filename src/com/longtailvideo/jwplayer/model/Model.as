package com.longtailvideo.jwplayer.model {
	import com.longtailvideo.jwplayer.events.GlobalEventDispatcher;
	
	/**
	 * 
	 * @author Pablo Schklowsky
	 * 
	 */
	public class Model extends GlobalEventDispatcher {
		private var _config:PlayerConfig;
		private var _state:String;
		private var _playlist:Playlist;
		
		/** Constructor **/
		public function Model() {
			_config = new PlayerConfig({});
			_playlist = new Playlist();
		}
		
		/**
		 * The player config object 
		 */
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

	}
}