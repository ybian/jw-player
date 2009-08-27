package com.longtailvideo.jwplayer.view {
	import com.longtailvideo.jwplayer.events.GlobalEventDispatcher;

	

	public class View extends GlobalEventDispatcher {
		private var _skin:ISkin; 
		private var _components:PlayerComponents;
		private var _fullscreen:Boolean = false;

		public function View() {
		}
		
		public function set skin(skn:ISkin):void {
			_skin = skn;
			if (!_components) {
				_components = new PlayerComponents(skn);
			}
		}
		
		public function get skin():ISkin {
			return _skin;
		}
		
		public function fullscreen(mode:Boolean=true):void {
		}

		public function redraw():void {
		}
		
		public function get components():PlayerComponents {
			return _components;
		}
		
		public function overrideComponent(newComponent:*):void {
			if (newComponent is IControlbarComponent) {
				// Replace controlbar
			} else if (newComponent is IDisplayComponent) {
				// Replace display
			} else if (newComponent is IDockComponent) {
				// Replace dock
			} else if (newComponent is IPlaylistComponent) {
				// Replace playlist
			} else {
				throw(new Error("Component must implement a component interface"));
			}
		}

	}
}