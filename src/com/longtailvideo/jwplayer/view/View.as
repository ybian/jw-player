package com.longtailvideo.jwplayer.view {
	import com.longtailvideo.jwplayer.events.GlobalEventDispatcher;
	import com.longtailvideo.jwplayer.events.MediaEvent;
	import com.longtailvideo.jwplayer.events.PlayerEvent;
	import com.longtailvideo.jwplayer.events.PlayerStateEvent;
	import com.longtailvideo.jwplayer.events.PlaylistEvent;
	import com.longtailvideo.jwplayer.events.ViewEvent;
	import com.longtailvideo.jwplayer.model.Model;
	import com.longtailvideo.jwplayer.player.IPlayer;
	import com.longtailvideo.jwplayer.player.PlayerState;
	import com.longtailvideo.jwplayer.player.PlayerV4Emulation;
	import com.longtailvideo.jwplayer.plugins.IPlugin;
	import com.longtailvideo.jwplayer.plugins.PluginConfig;
	import com.longtailvideo.jwplayer.utils.AssetLoader;
	import com.longtailvideo.jwplayer.utils.Draw;
	import com.longtailvideo.jwplayer.utils.Logger;
	import com.longtailvideo.jwplayer.utils.RootReference;
	import com.longtailvideo.jwplayer.utils.Stretcher;
	import com.longtailvideo.jwplayer.view.interfaces.IControlbarComponent;
	import com.longtailvideo.jwplayer.view.interfaces.IDisplayComponent;
	import com.longtailvideo.jwplayer.view.interfaces.IDockComponent;
	import com.longtailvideo.jwplayer.view.interfaces.IPlayerComponent;
	import com.longtailvideo.jwplayer.view.interfaces.IPlaylistComponent;
	import com.longtailvideo.jwplayer.view.interfaces.ISkin;
	
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.events.ErrorEvent;
	import flash.events.Event;


	public class View extends GlobalEventDispatcher {
		protected var _player:IPlayer;
		protected var _model:Model;
		protected var _skin:ISkin;
		protected var _components:IPlayerComponents;
		protected var _fullscreen:Boolean = false;
		protected var stage:Stage;

		protected var _root:MovieClip;

		protected var _backgroundLayer:MovieClip;
		protected var _mediaLayer:MovieClip;
		protected var _imageLayer:MovieClip;
		protected var _componentsLayer:MovieClip;
		protected var _logoLayer:MovieClip;
		protected var _pluginsLayer:MovieClip;
		protected var _plugins:Object;

		protected var _displayMasker:MovieClip;

		protected var _image:AssetLoader;
		protected var _logo:Logo;

		protected var layoutManager:PlayerLayoutManager;

		[Embed(source="../../../../../assets/flash/loader/loader.swf")]
		protected var LoadingScreen:Class;

		[Embed(source="../../../../../assets/flash/loader/error.swf")]
		protected var ErrorScreen:Class;

		protected var loaderScreen:Sprite;
		protected var loaderAnim:DisplayObject;


		public function View(player:IPlayer, model:Model) {
			_player = player;
			_model = model;

			RootReference.stage.scaleMode = StageScaleMode.NO_SCALE;
			RootReference.stage.stage.align = StageAlign.TOP_LEFT;

			loaderScreen = new Sprite();
			loaderScreen.name = 'loaderScreen';

			loaderAnim = new LoadingScreen() as DisplayObject;
			loaderScreen.addChild(loaderAnim);

			RootReference.stage.addChildAt(loaderScreen, 0);

			if (RootReference.stage.stageWidth > 0) {
				resizeStage();
			} else {
				RootReference.stage.addEventListener(Event.RESIZE, resizeStage);
				RootReference.stage.addEventListener(Event.ADDED_TO_STAGE, resizeStage);
			}

			_root = new MovieClip();
		}


		protected function resizeStage(evt:Event=null):void {
			RootReference.stage.removeEventListener(Event.RESIZE, resizeStage);
			RootReference.stage.removeEventListener(Event.ADDED_TO_STAGE, resizeStage);

			loaderScreen.graphics.clear();
			loaderScreen.graphics.beginFill(0, 1);
			loaderScreen.graphics.drawRect(0, 0, RootReference.stage.stageWidth, RootReference.stage.stageHeight);
			loaderScreen.graphics.endFill();

			loaderAnim.x = (RootReference.stage.stageWidth - loaderAnim.width) / 2;
			loaderAnim.y = (RootReference.stage.stageHeight - loaderAnim.height) / 2;
		}


		public function get skin():ISkin {
			return _skin;
		}


		public function set skin(skn:ISkin):void {
			_skin = skn;
		}


		public function setupView():void {
			RootReference.stage.addChildAt(_root, 0);
			_root.visible = false;

			setupLayers();
			setupComponents();

			RootReference.stage.addEventListener(Event.FULLSCREEN, resizeHandler);
			RootReference.stage.addEventListener(Event.RESIZE, resizeHandler);

			_model.addEventListener(MediaEvent.JWPLAYER_MEDIA_LOADED, mediaLoaded);
			_model.playlist.addEventListener(PlaylistEvent.JWPLAYER_PLAYLIST_ITEM, itemHandler);
			//_model.playlist.addEventListener(PlaylistEvent.JWPLAYER_PLAYLIST_LOADED, itemHandler);
			_model.playlist.addEventListener(PlaylistEvent.JWPLAYER_PLAYLIST_UPDATED, itemHandler);
			_model.addEventListener(PlayerStateEvent.JWPLAYER_PLAYER_STATE, stateHandler);

			layoutManager = new PlayerLayoutManager(_player);
			setupRightClick();

			redraw();
		}
		
		protected function setupRightClick():void {
			var menu:RightclickMenu = new RightclickMenu(_player, _root);
			menu.addGlobalListener(forward);
		}

		public function completeView(isError:Boolean=false, errorMsg:String=""):void {
			if (!isError) {
				_root.visible = true;
				RootReference.stage.removeChild(loaderScreen);
			} else {
				loaderScreen.removeChild(loaderAnim);
				var errorScreen:DisplayObject = new ErrorScreen() as DisplayObject;
				errorScreen.x = (loaderScreen.width - errorScreen.width) / 2;
				errorScreen.y = (loaderScreen.height - errorScreen.height) / 2;
				loaderScreen.addChild(errorScreen);
			}
		}


		protected function setupLayers():void {
			_backgroundLayer = setupLayer("background", 0);
			setupBackground();

			_mediaLayer = setupLayer("media", 1);
			_mediaLayer.visible = false;

			_imageLayer = setupLayer("image", 2);
			_image = new AssetLoader();

			_componentsLayer = setupLayer("components", 3);

			_pluginsLayer = setupLayer("plugins", 4);
			_plugins = {};
			
			setupLogo();
		}
		
		protected function setupLogo():void {
			_logoLayer = setupLayer("logo", 5);
			_logo = new Logo(_player);
			_logoLayer.addChild(_logo);
		}


		protected function setupLayer(name:String, index:Number):MovieClip {
			var layer:MovieClip = new MovieClip();
			_root.addChildAt(layer, index);
			layer.name = name;
			layer.x = 0;
			layer.y = 0;
			return layer;
		}


		protected function setupBackground():void {
			var background:MovieClip = new MovieClip();
			background.name = "background";
			_backgroundLayer.addChild(background);
			background.graphics.beginFill(_player.config.screencolor ? _player.config.screencolor.color : 0x000000, 1);
			background.graphics.drawRect(0, 0, 1, 1);
			background.graphics.endFill();
		}


		protected function setupDisplayMask():void {
			_displayMasker = new MovieClip();
			_displayMasker.graphics.beginFill(0x000000, 1);
			_displayMasker.graphics.drawRect(0, 0, _player.config.width, _player.config.height);
			_displayMasker.graphics.endFill();

			_backgroundLayer.mask = _displayMasker;
			_imageLayer.mask = _displayMasker;
			_mediaLayer.mask = _displayMasker;
		}


		protected function setupComponents():void {
			_components = new PlayerComponents(_player);

			setupComponent(_components.display, 0);
			setupComponent(_components.playlist, 1);
			setupComponent(_components.controlbar, 2);
			setupComponent(_components.dock, 3);
		}


		protected function setupComponent(component:IPlayerComponent, index:Number):void {
			component.addGlobalListener(forward);
			_componentsLayer.addChildAt(component as DisplayObject, index);
		}


		protected function resizeHandler(event:Event):void {
			redraw();

			var currentFSMode:Boolean = (RootReference.stage.displayState == StageDisplayState.FULL_SCREEN);
			if (_model.fullscreen != currentFSMode) {
				dispatchEvent(new ViewEvent(ViewEvent.JWPLAYER_VIEW_FULLSCREEN, currentFSMode));
			}
		}


		public function fullscreen(mode:Boolean=true):void {
			RootReference.stage.displayState = mode ? StageDisplayState.FULL_SCREEN : StageDisplayState.NORMAL;
		}


		/** Redraws the plugins and player components **/
		public function redraw():void {
			layoutManager.resize(RootReference.stage.stageWidth, RootReference.stage.stageHeight);

			_components.resize(_player.config.width, _player.config.height);

			resizeBackground();
			resizeMasker();

			if (_imageLayer.numChildren) {
				_imageLayer.x = _components.display.x;
				_imageLayer.y = _components.display.y;
				Stretcher.stretch(_image.loadedObject, _player.config.width, _player.config.height, _player.config.stretching);
			}

			if (_mediaLayer.numChildren && _model.media.display) {
				_mediaLayer.x = _components.display.x;
				_mediaLayer.y = _components.display.y;
				_model.media.resize(_player.config.width, _player.config.height);
			}

			if (_logoLayer.numChildren) {
				_logoLayer.x = _components.display.x;
				_logoLayer.y = _components.display.y;
				_logo.resize(_player.config.width, _player.config.height);
			}

			for (var i:Number = 0; i < _pluginsLayer.numChildren; i++) {
				var plug:IPlugin = _pluginsLayer.getChildAt(i) as IPlugin;
				var plugDisplay:DisplayObject = plug as DisplayObject;
				if (plug && plugDisplay) {
					var cfg:PluginConfig = _player.config.pluginConfig(plug.id);
					if (cfg['visible']) {
						plugDisplay.visible = true;
						plugDisplay.x = cfg['x'];
						plugDisplay.y = cfg['y'];
						try {
							plug.resize(cfg.width, cfg.height);
						} catch (e:Error) {
							Logger.log("There was an error resizing plugin '" + plug.id + "': " + e.message);
						}
					} else {
						plugDisplay.visible = false;
					}
				}
			}

			PlayerV4Emulation.getInstance(_player).resize(_player.config.width, _player.config.height);
		}


		protected function resizeBackground():void {
			var bg:DisplayObject = _backgroundLayer.getChildByName("background");
			bg.width = RootReference.stage.stageWidth;
			bg.height = RootReference.stage.stageHeight;
			bg.x = 0;
			bg.y = 0;
		}


		protected function resizeMasker():void {
			if (_displayMasker == null)
				setupDisplayMask();

			_displayMasker.graphics.clear();
			_displayMasker.graphics.beginFill(0, 1);
			_displayMasker.graphics.drawRect(_components.display.x, _components.display.y, _player.config.width, _player.config.height);
			_displayMasker.graphics.endFill();
		}


		public function get components():IPlayerComponents {
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


		public function addPlugin(id:String, plugin:IPlugin):void {
			try {
				var plugDO:DisplayObject = plugin as DisplayObject;
				if (!_plugins[id] && plugDO != null) {
					_plugins[id] = plugDO;
					_pluginsLayer.addChild(plugDO);
						//_pluginsLayer[id] = plugDO;
				}
			} catch (e:Error) {
				dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false, e.message));
			}
		}


		public function removePlugin(plugin:IPlugin):void {
			var id:String = plugin.id.toLowerCase();
			if (id && _plugins[id] is IPlugin) {
				_pluginsLayer.removeChild(_plugins[id]);
				delete _plugins[id];
			}
		}


		public function loadedPlugins():Array {
			var list:Array = [];
			for (var pluginId:String in _plugins) {
				if (_plugins[pluginId] is IPlugin) {
					list.push(pluginId);
				}
			}
			return list;
		}


		public function getPlugin(id:String):IPlugin {
			return _plugins[id] as IPlugin;
		}


		public function bringPluginToFront(id:String):void {
			var plugin:IPlugin = getPlugin(id);
			_pluginsLayer.setChildIndex(plugin as DisplayObject, _pluginsLayer.numChildren - 1);
		}


		protected function mediaLoaded(evt:MediaEvent):void {
			_mediaLayer.x = _components.display.x;
			_mediaLayer.y = _components.display.y;
			if (_model.media.display) {
				_model.media.resize(_player.config.width, _player.config.height);
				_mediaLayer.addChild(_model.media.display);
			}
		}


		protected function itemHandler(evt:PlaylistEvent):void {
			while (_mediaLayer.numChildren) {
				_mediaLayer.removeChildAt(0);
			}
			if (_model.playlist.currentItem && _model.playlist.currentItem.image) {
				loadImage(_model.playlist.currentItem.image);

			}
		}


		protected function loadImage(url:String):void {
			while (_imageLayer.numChildren) {
				_imageLayer.removeChildAt(0);
			}

			_image = new AssetLoader();
			_image.addEventListener(Event.COMPLETE, imageComplete);
			_image.addEventListener(ErrorEvent.ERROR, imageError);
			_image.load(url);
		}


		protected function imageComplete(evt:Event):void {
			if (_image.loadedObject is Bitmap) {
				Draw.smooth(_image.loadedObject as Bitmap);
				_imageLayer.addChild(_image.loadedObject);
				_imageLayer.x = _components.display.x;
				_imageLayer.y = _components.display.y;
				Stretcher.stretch(_image.loadedObject, _player.config.width, _player.config.height, _player.config.stretching);
			} else {
				_image = null;
				Logger.log('Error loading preview image.');
			}
		}


		protected function imageError(evt:ErrorEvent):void {
			_image = null;
			Logger.log('Error loading preview image: '+evt.text);
			//dispatchEvent(new PlayerEvent(PlayerEvent.JWPLAYER_ERROR, evt.text));
		}


		protected function stateHandler(evt:PlayerStateEvent):void {
			switch (evt.newstate) {
				case PlayerState.IDLE:
					_imageLayer.visible = true;
					_mediaLayer.visible = false;
					_logoLayer.visible = false;
					break;
				case PlayerState.PLAYING:
					if (_model.media.display) {
						_imageLayer.visible = false;
						_mediaLayer.visible = true;
					}
					_logoLayer.visible = true;
					break;
			}
		}


		protected function forward(evt:Event):void {
			if (evt is PlayerEvent)
				dispatchEvent(evt);
		}
	}
}