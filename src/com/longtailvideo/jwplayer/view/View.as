package com.longtailvideo.jwplayer.view {
	import com.longtailvideo.jwplayer.events.GlobalEventDispatcher;
	import com.longtailvideo.jwplayer.events.MediaEvent;
	import com.longtailvideo.jwplayer.events.PlayerEvent;
	import com.longtailvideo.jwplayer.events.PlayerStateEvent;
	import com.longtailvideo.jwplayer.events.PlaylistEvent;
	import com.longtailvideo.jwplayer.model.Model;
	import com.longtailvideo.jwplayer.player.Player;
	import com.longtailvideo.jwplayer.player.PlayerState;
	import com.longtailvideo.jwplayer.plugins.IPlugin;
	import com.longtailvideo.jwplayer.plugins.PluginConfig;
	import com.longtailvideo.jwplayer.utils.RootReference;
	import com.longtailvideo.jwplayer.utils.Stretcher;
	
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.display.StageAlign;
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

		private var _backgroundLayer:MovieClip;
		private var _mediaLayer:MovieClip;
		private var _imageLayer:MovieClip;
		private var _componentsLayer:MovieClip;
		private var _pluginsLayer:MovieClip;		
		
		private var _image:Loader;
		
		public function View(player:Player, model:Model) {
			_player = player;
			_model = model;
			
			setupLayers();
			RootReference.stage.scaleMode = StageScaleMode.NO_SCALE;
			RootReference.stage.stage.align = StageAlign.TOP_LEFT;
			RootReference.stage.addEventListener(Event.FULLSCREEN, resizeHandler);
			RootReference.stage.addEventListener(Event.RESIZE, resizeHandler);
			_model.addEventListener(MediaEvent.JWPLAYER_MEDIA_LOADED, mediaLoaded);
			_model.playlist.addEventListener(PlaylistEvent.JWPLAYER_PLAYLIST_ITEM, itemHandler);
			_model.addEventListener(PlayerStateEvent.JWPLAYER_PLAYER_STATE, stateHandler);
		}
		
		
		private function setupLayers():void {
			_backgroundLayer = setupLayer("background", 0);
			var background:MovieClip = new MovieClip();
			background.name = "background";
			_backgroundLayer.addChildAt(background, 0);
			background.graphics.beginFill(_player.config.backcolor, 1);
			background.graphics.drawRect(0,0,1,1);
			background.graphics.endFill();

			_mediaLayer = setupLayer("media", 1);			

			_imageLayer = setupLayer("image", 2);			
			_image = new Loader();
			_image.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, imageError);
			_image.contentLoaderInfo.addEventListener(Event.COMPLETE, imageComplete);

			_componentsLayer = setupLayer("components", 3);
			_pluginsLayer = setupLayer("plugins", 4);
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
			var width:Number = RootReference.stage.stageWidth;
			var height:Number = RootReference.stage.stageHeight;
			_backgroundLayer.getChildByName("background").width = width;
			_backgroundLayer.getChildByName("background").height = height;

			_components.resize(width, height);
			
			_player.config.width = width;
			_player.config.height = height;
			
			if (_imageLayer.numChildren) {
				Stretcher.stretch(_image, width, height, _player.config.stretching);
			}

			if (_mediaLayer.numChildren) {
				_model.media.resize(width, height);
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
			
			_components.controlbar.addGlobalListener(forward);
			
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
		
		/** Redraws the plugins **/
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
		
		private function mediaLoaded(evt:MediaEvent):void {
			while (_mediaLayer.numChildren) {
				_mediaLayer.removeChildAt(0);
			}
			_mediaLayer.addChild(_model.media.display);
			_model.media.resize(_player.config.width, _player.config.height);
		}
		
		private function itemHandler(evt:PlaylistEvent):void {
			if (_model.playlist.currentItem && _model.playlist.currentItem.image) {
				loadImage(_model.playlist.currentItem.image);
			}
		}

		private function loadImage(url:String):void {
			_image.load(new URLRequest(url));
		}
		
		private function imageComplete(evt:Event):void {
			while (_imageLayer.numChildren) { _imageLayer.removeChildAt(0); }
			_imageLayer.addChild(_image);
			Stretcher.stretch(_image, _player.config.width, _player.config.height, _player.config.stretching);
		}
		
		private function imageError(evt:IOErrorEvent):void {
			_image = null;
			dispatchEvent(new PlayerEvent(PlayerEvent.JWPLAYER_ERROR, evt.text));	
		}

		private function stateHandler(evt:PlayerStateEvent):void {
			switch (evt.newstate) {
				case PlayerState.IDLE:
					_mediaLayer.visible = false;
					_imageLayer.visible = true;
					break;
				case PlayerState.PLAYING:
					_mediaLayer.visible = true;
					_imageLayer.visible = false;
					break;
			}
		}
		
		private function forward(evt:Event):void {
			dispatchEvent(evt);
		}

	}
}