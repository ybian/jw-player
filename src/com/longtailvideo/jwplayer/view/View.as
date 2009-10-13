package com.longtailvideo.jwplayer.view {
	import com.longtailvideo.jwplayer.events.GlobalEventDispatcher;
	import com.longtailvideo.jwplayer.events.MediaEvent;
	import com.longtailvideo.jwplayer.events.PlayerEvent;
	import com.longtailvideo.jwplayer.events.PlayerStateEvent;
	import com.longtailvideo.jwplayer.events.PlaylistEvent;
	import com.longtailvideo.jwplayer.events.ViewEvent;
	import com.longtailvideo.jwplayer.model.Model;
	import com.longtailvideo.jwplayer.player.Player;
	import com.longtailvideo.jwplayer.player.PlayerState;
	import com.longtailvideo.jwplayer.player.PlayerV4Emulation;
	import com.longtailvideo.jwplayer.plugins.IPlugin;
	import com.longtailvideo.jwplayer.plugins.PluginConfig;
	import com.longtailvideo.jwplayer.utils.RootReference;
	import com.longtailvideo.jwplayer.utils.Stretcher;
	import com.longtailvideo.jwplayer.view.interfaces.IControlbarComponent;
	import com.longtailvideo.jwplayer.view.interfaces.IDisplayComponent;
	import com.longtailvideo.jwplayer.view.interfaces.IDockComponent;
	import com.longtailvideo.jwplayer.view.interfaces.IPlayerComponent;
	import com.longtailvideo.jwplayer.view.interfaces.IPlaylistComponent;
	import com.longtailvideo.jwplayer.view.interfaces.ISkin;
	
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;

	public class View extends GlobalEventDispatcher {
		private var _player:Player;
		private var _model:Model;
		private var _skin:ISkin;
		private var _components:PlayerComponents;
		private var _fullscreen:Boolean = false;
		private var stage:Stage;

		private var _root:MovieClip;

		private var _backgroundLayer:MovieClip;
		private var _mediaLayer:MovieClip;
		private var _imageLayer:MovieClip;
		private var _componentsLayer:MovieClip;
		private var _logoLayer:MovieClip;
		private var _pluginsLayer:MovieClip;

		private var _image:Loader;
		private var _logo:Logo;

		public function View(player:Player, model:Model) {
			_player = player;
			_model = model;

			_root = new MovieClip();
			RootReference.stage.addChildAt(_root, 0);

			setupLayers();
			RootReference.stage.scaleMode = StageScaleMode.NO_SCALE;
			RootReference.stage.stage.align = StageAlign.TOP_LEFT;
			RootReference.stage.addEventListener(Event.FULLSCREEN, resizeHandler);
			RootReference.stage.addEventListener(Event.RESIZE, resizeHandler);
			_model.addEventListener(MediaEvent.JWPLAYER_MEDIA_LOADED, mediaLoaded);
			_model.playlist.addEventListener(PlaylistEvent.JWPLAYER_PLAYLIST_ITEM, itemHandler);
			_model.addEventListener(PlayerStateEvent.JWPLAYER_PLAYER_STATE, stateHandler);
			
			var menu:RightclickMenu = new RightclickMenu(model, _root);
			menu.addGlobalListener(forward);
		}

		private function setupLayers():void {
			_backgroundLayer = setupLayer("background", 0);
			var background:MovieClip = new MovieClip();
			background.name = "background";
			_backgroundLayer.addChildAt(background, 0);
			background.graphics.beginFill(_player.config.screencolor, 1);
			background.graphics.drawRect(0, 0, 1, 1);
			background.graphics.endFill();

			_mediaLayer = setupLayer("media", 1);

			_imageLayer = setupLayer("image", 2);
			_image = new Loader();
			_image.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, imageError);
			_image.contentLoaderInfo.addEventListener(Event.COMPLETE, imageComplete);

			_componentsLayer = setupLayer("components", 3);

			_logoLayer = setupLayer("logo", 4);
			_logo = new Logo(_player);
			_logoLayer.addChild(_logo);

			_pluginsLayer = setupLayer("plugins", 5);
		}

		private function setupLayer(name:String, index:Number):MovieClip {
			var layer:MovieClip = new MovieClip();
			_root.addChildAt(layer, index);
			layer.name = name;
			layer.x = 0;
			layer.y = 0;
			return layer;
		}

		private function resizeHandler(event:Event):void {
			var width:Number = RootReference.stage.stageWidth;
			var height:Number = RootReference.stage.stageHeight;
			_backgroundLayer.getChildByName("background").width = width;
			_backgroundLayer.getChildByName("background").height = height;

			var layoutManager:PlayerLayoutManager = new PlayerLayoutManager(_player);
			layoutManager.resize(width, height);

			redraw();

			var currentFSMode:Boolean = (RootReference.stage.displayState == StageDisplayState.FULL_SCREEN);
			if (_model.fullscreen != currentFSMode) {
				dispatchEvent(new ViewEvent(ViewEvent.JWPLAYER_VIEW_FULLSCREEN, currentFSMode));
			}
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
			
			setupComponent(_components.display, 0);
			setupComponent(_components.controlbar, 1);
			setupComponent(_components.playlist, 2);
		}
		
		private function setupComponent(component:IPlayerComponent, index:Number):void {
			component.addGlobalListener(forward);
			_componentsLayer.addChildAt(component as DisplayObject, index);
		}

		public function get skin():ISkin {
			return _skin;
		}

		public function fullscreen(mode:Boolean=true):void {
			RootReference.stage.displayState = mode ? StageDisplayState.FULL_SCREEN : StageDisplayState.NORMAL;
		}

		/** Redraws the plugins and player components **/
		public function redraw():void {
			_components.resize(_player.config.width, _player.config.height);

			if (_imageLayer.numChildren) {
				_imageLayer.x = _components.display.x;
				_imageLayer.y = _components.display.y;
				Stretcher.stretch(_image, _player.config.width, _player.config.height, _player.config.stretching);
			}
			
			if (_mediaLayer.numChildren) {
				_mediaLayer.x = _components.display.x;
				_mediaLayer.y = _components.display.y;
				_model.media.resize(_player.config.width, _player.config.height);
			}

			if (_logoLayer.numChildren) {
				_logo.resize(_components.display.width, _components.display.height);
				_logoLayer.x = _components.display.width - _logoLayer.width;
				_logoLayer.y = _components.display.height - _logoLayer.height;
			}
			
			for (var i:Number = 0; i < _pluginsLayer.numChildren; i++) {
				var plug:IPlugin = _pluginsLayer.getChildAt(i) as IPlugin;
				if (plug) {
					var cfg:PluginConfig = _player.config.pluginConfig((plug as DisplayObject).name);
					if (cfg['visible']) {
						plug.visible = true;
						plug.resize(cfg.width, cfg.height);
					} else {
						plug.visible = false;
					}
				}
			}
			PlayerV4Emulation.getInstance().resize(_player.config.width, _player.config.height);
		}

		public function get components():PlayerComponents {
			return _components;
		}

		public function overrideComponent(newComponent:IPlayerComponent):void {
			if (newComponent is IControlbarComponent) {
				// Replace controlbar
			} else if (newComponent is IDisplayComponent) {
				// Replace display
			} else if (newComponent is IDockComponent) {
				// Replace dock
			} else if (newComponent is IPlaylistComponent) {
				// Replace playlist
			} else {
				dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false, "Component must implement a component interface"));
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

		private function mediaLoaded(evt:MediaEvent):void {

			_model.media.resize(_player.config.width, _player.config.height);

			_mediaLayer.x = _components.display.x;
			_mediaLayer.y = _components.display.y;
			if (_model.media.display) {
				_mediaLayer.addChild(_model.media.display);
			}
		}

		private function itemHandler(evt:PlaylistEvent):void {
			while (_mediaLayer.numChildren) {
				_mediaLayer.removeChildAt(0);
			}
			if (_model.playlist.currentItem && _model.playlist.currentItem.image) {
				loadImage(_model.playlist.currentItem.image);

			}
		}

		private function loadImage(url:String):void {
			_image.load(new URLRequest(url));
		}

		private function imageComplete(evt:Event):void {
			while (_imageLayer.numChildren) {
				_imageLayer.removeChildAt(0);
			}
			_imageLayer.addChild(_image);
			_imageLayer.x = _components.display.x;
			_imageLayer.y = _components.display.y;
			Stretcher.stretch(_image, _player.config.width, _player.config.height, _player.config.stretching);
		}

		private function imageError(evt:IOErrorEvent):void {
			_image = null;
			dispatchEvent(new PlayerEvent(PlayerEvent.JWPLAYER_ERROR, evt.text));
		}

		private function stateHandler(evt:PlayerStateEvent):void {
			switch (evt.newstate) {
				case PlayerState.IDLE:
					_imageLayer.visible = true;
					_mediaLayer.visible = false;
					_logoLayer.visible = false;
					break;
				case PlayerState.PLAYING:
					_imageLayer.visible = false;
					_mediaLayer.visible = true;
					_logoLayer.visible = true;
					break;
			}
		}

		private function forward(evt:Event):void {
			if (evt is PlayerEvent) dispatchEvent(evt);
		}

	}
}