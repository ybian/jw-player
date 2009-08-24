package com.longtailvideo.jwplayer.view {
	import com.longtailvideo.jwplayer.events.GlobalEventDispatcher;

	public class View extends GlobalEventDispatcher {
		private var _skin:ISkin; 
		private var _fullscreen:Boolean = false;

		public function View() {
		}
		
		public function set skin(skn:ISkin):void {
			_skin = skn;
		}
		
		public function get skin():ISkin {
			return _skin;
		}
		
		public function goFullscreen(mode:Boolean=true):void {
			
		}

	}
}