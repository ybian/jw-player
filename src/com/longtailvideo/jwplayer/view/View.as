package com.longtailvideo.jwplayer.view {
	import com.longtailvideo.jwplayer.events.GlobalEventDispatcher;
	import com.longtailvideo.jwplayer.plugins.IPlugin;
	import com.longtailvideo.jwplayer.utils.RootReference;
	
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.events.ErrorEvent;

	

	public class View extends GlobalEventDispatcher {
		private var _skin:ISkin; 
		private var _components:PlayerComponents;
		private var _fullscreen:Boolean = false;
		
		private var _plugins:MovieClip;
		
		private var stage:Stage;

		public function View() {
			stage = RootReference.stage;
			_plugins = new MovieClip();
			_plugins.name = "plugins";
			stage.addChild(stage);
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

		public function loadedPlugins():String {
			var list:Array = [];
			for each (var plugin:DisplayObject in _plugins) {
				if (plugin is IPlugin) {
					list.push(plugin.name);
				}
			}
			return list.join(",");
		}

		public function getPlugin(name:String):IPlugin {
			return _plugins.getChildByName(name) as IPlugin;
		}

	}
}