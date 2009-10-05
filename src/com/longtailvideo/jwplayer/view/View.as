package com.longtailvideo.jwplayer.view {
	import com.longtailvideo.jwplayer.events.GlobalEventDispatcher;
	import com.longtailvideo.jwplayer.events.PlaylistEvent;
	import com.longtailvideo.jwplayer.player.Player;
	import com.longtailvideo.jwplayer.plugins.IPlugin;
	import com.longtailvideo.jwplayer.plugins.PluginConfig;
	import com.longtailvideo.jwplayer.utils.RootReference;
	
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	
	
	public class View extends GlobalEventDispatcher {
		private var _player:Player;
		private var _skin:ISkin;
		private var _components:PlayerComponents;
		private var _fullscreen:Boolean = false;
		private var stage:Stage;
		private var _backgroundLayer:MovieClip;
		private var _mediaLayer:MovieClip;
		private var _componentsLayer:MovieClip;
		private var _pluginsLayer:MovieClip;		
		
		public function View(player:Player) {
			_player = player;
			setupLayers();
			RootReference.stage.scaleMode = StageScaleMode.NO_SCALE;
			RootReference.stage.stage.align = StageAlign.TOP_LEFT;
			RootReference.stage.addEventListener(Event.FULLSCREEN, resizeHandler);
			RootReference.stage.addEventListener(Event.RESIZE, resizeHandler);
			player.addEventListener(PlaylistEvent.JWPLAYER_PLAYLIST_ITEM, playlistHandler);
		}
		
		
		private function playlistHandler(evt:PlaylistEvent):void {

		}
		
		private function setupLayers():void {
			_backgroundLayer = setupLayer("background", 0);
			var background:MovieClip = new MovieClip();
			background.name = "background";
			_backgroundLayer.addChildAt(background, 0);
			background.graphics.beginFill(0,0.5);
			background.graphics.drawRect(0,0,1,1);
			background.graphics.endFill();

			_mediaLayer = setupLayer("media", 1);			

			_componentsLayer = setupLayer("components", 2);
			
			_pluginsLayer = setupLayer("plugins", 3);
		}
		
		private function setupLayer(name:String, index:Number):MovieClip {
			var layer:MovieClip = new MovieClip();
			RootReference.stage.addChildAt(layer, index);
			layer.name = name;
			layer.x = 0;
			layer.y = 0;
			return layer;
		}


		private function resizeHandler(event:Event):void{
			_backgroundLayer.getChildByName("background").width = RootReference.stage.stageWidth;
			_backgroundLayer.getChildByName("background").height = RootReference.stage.stageHeight;

			_components.resize(RootReference.stage.stageWidth,RootReference.stage.stageHeight);
		}
		
		
		public function set skin(skn:ISkin):void {
			_skin = skn;
			if (!_components) {
				setupComponents();
			}
		}
		
		//TODO: I think plugins and components have to go on the same level, otherwise the component layer will simply go over 
		private function setupComponents():void {
			_components = new PlayerComponents(_player);
			_componentsLayer.addChildAt(_components.display as MovieClip, 0);
			_componentsLayer.addChildAt(_components.controlbar as MovieClip, 1);
			//addToLayer(_playerComponents.controlbar as MovieClip, _components);
			//addToStage(_playerComponents.dock, _player.config.width, _player.config.height);
			//addToStage(_playerComponents.playlist, _player.config.width, _player.config.height);
		}
		
		
		public function get skin():ISkin {
			return _skin;
		}
		
		
		public function fullscreen(mode:Boolean = true):void {
		}
		
		
		public function redraw():void {
			for (var i:Number=0; i < _pluginsLayer.numChildren; i++) {
				var plug:IPlugin = _pluginsLayer.getChildAt(i) as IPlugin;
				if (plug) { 
					var cfg:PluginConfig = _player.config.pluginConfig((plug as DisplayObject).name);
					plug.resize(cfg.width, cfg.height);
				}
			}
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
				if (_pluginsLayer.getChildByName(name) == null && plugDO != null) {
					plugDO.name = name;
					_pluginsLayer.addChild(plugDO);
					_pluginsLayer[name] = plugDO;
				}
			} catch (e:Error) {
				dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false, e.message));
			}
		}
		
		
		public function loadedPlugins():Array {
			var list:Array = [];
			for each (var plugin:DisplayObject in _pluginsLayer) {
				if (plugin is IPlugin) {
					list.push(plugin.name);
				}
			}
			return list;
		}
		
		
		public function getPlugin(name:String):IPlugin {
			return _pluginsLayer.getChildByName(name) as IPlugin;
		}
	}
}