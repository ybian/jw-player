package com.longtailvideo.jwplayer.view {
	import com.longtailvideo.jwplayer.events.GlobalEventDispatcher;
	import com.longtailvideo.jwplayer.plugins.IPlugin;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.ErrorEvent;

	

	public class View extends GlobalEventDispatcher {
		private var _skin:ISkin; 
		private var _components:PlayerComponents;
		private var _fullscreen:Boolean = false;
		
		private var _plugins:Sprite;

		public function View() {
			_plugins = new Sprite();
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
		
		public function addPlugin(name:String, plugin:IPlugin):void {
			try {
				var plugDO:DisplayObject = plugin as DisplayObject;
			
				if (_plugins.getChildByName(name) == null && plugDO != null) {
					plugDO.name = name;
					_plugins.addChild(plugDO);
					_plugins[name] = plugDO;					
				}
			} catch(e:Error) {
				dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false, e.message));
			}
		}

		public function getPlugin(name:String):IPlugin {
			return _plugins.getChildByName(name) as IPlugin;
		}

	}
}