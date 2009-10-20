package com.longtailvideo.jwplayer.controller {
	import com.longtailvideo.jwplayer.events.GlobalEventDispatcher;
	import com.longtailvideo.jwplayer.events.MediaEvent;
	import com.longtailvideo.jwplayer.events.PlayerEvent;
	import com.longtailvideo.jwplayer.events.PlaylistEvent;
	import com.longtailvideo.jwplayer.events.ViewEvent;
	import com.longtailvideo.jwplayer.model.Model;
	import com.longtailvideo.jwplayer.model.PlaylistItem;
	import com.longtailvideo.jwplayer.parsers.JWParser;
	import com.longtailvideo.jwplayer.player.Player;
	import com.longtailvideo.jwplayer.player.PlayerState;
	import com.longtailvideo.jwplayer.plugins.IPlugin;
	import com.longtailvideo.jwplayer.utils.RootReference;
	import com.longtailvideo.jwplayer.utils.Strings;
	import com.longtailvideo.jwplayer.view.View;
	
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;

	/**
	 * Sent when the player has been initialized and skins and plugins have been successfully loaded.
	 *
	 * @eventType com.longtailvideo.jwplayer.events.PlayerEvent.JWPLAYER_READY
	 */
	[Event(name="jwplayerReady", type = "com.longtailvideo.jwplayer.events.PlayerEvent")]

	/**
	 * Sent when the player has entered the ERROR state
	 *
	 * @eventType com.longtailvideo.jwplayer.events.PlayerEvent.JWPLAYER_ERROR
	 */
	[Event(name="jwplayerError", type = "com.longtailvideo.jwplayer.events.PlayerEvent")]

	/**
	 * The Controller is responsible for handling Model / View events and calling the appropriate responders
	 *
	 * @author Pablo Schklowsky
	 */
	public class Controller extends GlobalEventDispatcher {

		/** MVC References **/
		private var _player:Player;
		private var _model:Model;
		private var _view:View;

		/** Current blocking state **/
		private var _blocking:Boolean = false;
		
		/** A list with legacy CDN classes that are now redirected to buit-in ones. **/
		private var cdns:Object = {
				bitgravity:{'http.startparam':'starttime', provider:'http'},
				edgecast:{'http.startparam':'ec_seek', provider:'http'},
				flvseek:{'http.startparam':'fs', provider:'http'},
				highwinds:{'rtmp.loadbalance':true, provider:'rtmp'},
				lighttpd:{'http.startparam':'start', provider:'http'},
				vdox:{'rtmp.loadbalance':true, provider:'rtmp'}
		};
		
		/** Reference to a PlaylistItem which has triggered an external MediaProvider load **/
		private var _delayedItem:PlaylistItem;
		
		public function Controller(player:Player, model:Model, view:View) {
			_player = player;
			_model = model;
			_view = view;
		}

		/**
		 * Begin player setup
		 * @param readyConfig If a PlayerConfig object is already available, use it to configure the player.
		 * Otherwise, load the config from XML / flashvars.
		 */
		public function setupPlayer():void {
			var setup:PlayerSetup = new PlayerSetup(_player, _model, _view);

			setup.addEventListener(Event.COMPLETE, setupComplete);
			setup.addEventListener(ErrorEvent.ERROR, errorHandler);

			addViewListeners();
			addModelListeners();

			setup.setupPlayer();
		}

		private function addViewListeners():void {
			_view.addEventListener(ViewEvent.JWPLAYER_VIEW_PLAY, playHandler);
			_view.addEventListener(ViewEvent.JWPLAYER_VIEW_PAUSE, pauseHandler);
			_view.addEventListener(ViewEvent.JWPLAYER_VIEW_STOP, stopHandler);
			_view.addEventListener(ViewEvent.JWPLAYER_VIEW_NEXT, nextHandler);
			_view.addEventListener(ViewEvent.JWPLAYER_VIEW_PREV, prevHandler);
			_view.addEventListener(ViewEvent.JWPLAYER_VIEW_SEEK, seekHandler);
			_view.addEventListener(ViewEvent.JWPLAYER_VIEW_MUTE, muteHandler);
			_view.addEventListener(ViewEvent.JWPLAYER_VIEW_VOLUME, volumeHandler);
			_view.addEventListener(ViewEvent.JWPLAYER_VIEW_FULLSCREEN, fullscreenHandler);
			_view.addEventListener(ViewEvent.JWPLAYER_VIEW_LOAD, loadHandler);
			_view.addEventListener(ViewEvent.JWPLAYER_VIEW_REDRAW, redrawHandler);
		}

		private function playHandler(evt:ViewEvent):void { play(); }
		private function stopHandler(evt:ViewEvent):void { stop(); }
		private function pauseHandler(evt:ViewEvent):void { pause(); }
		private function nextHandler(evt:ViewEvent):void { next(); }
		private function prevHandler(evt:ViewEvent):void { previous(); }
		private function seekHandler(evt:ViewEvent):void { seek(evt.data); }
		private function muteHandler(evt:ViewEvent):void { mute(evt.data); }
		private function volumeHandler(evt:ViewEvent):void { setVolume(evt.data); }
		private function fullscreenHandler(evt:ViewEvent):void { fullscreen(evt.data); }
		private function loadHandler(evt:ViewEvent):void { load(evt.data); }
		private function redrawHandler(evt:ViewEvent):void { redraw(); }

		private function addModelListeners():void {
			_model.playlist.addEventListener(PlaylistEvent.JWPLAYER_PLAYLIST_LOADED, playlistLoadHandler);
			_model.playlist.addEventListener(ErrorEvent.ERROR, errorHandler);
			_model.playlist.addEventListener(PlaylistEvent.JWPLAYER_PLAYLIST_ITEM, playlistItemHandler);
		}

		private function setupComplete(evt:Event):void {
			dispatchEvent(new PlayerEvent(PlayerEvent.JWPLAYER_READY));
			RootReference.stage.dispatchEvent(new Event(Event.RESIZE));
			loadFirstItem();
		}

		private function playlistLoadHandler(evt:PlaylistEvent):void {
			playlistItemHandler(evt);
			if (_player.config.autostart) { 
				load(_model.playlist.currentItem); 
			}
		}

		private function playlistItemHandler(evt:PlaylistEvent):void {
			var item:PlaylistItem = _model.playlist.currentItem;
		}

		private function errorHandler(evt:ErrorEvent):void {
			errorState(evt.text);
		}

		private function errorState(message:String=""):void {
			dispatchEvent(new PlayerEvent(PlayerEvent.JWPLAYER_ERROR, message));
		}

		////////////////////
		// Public methods //
		////////////////////

		public function get blocking():Boolean {
			return _blocking;
		}

		/**
		 * @private
		 * @copy com.longtailvideo.jwplayer.player.Player#blockPlayback
		 */
		public function blockPlayback(plugin:IPlugin):Boolean {
			if (!_blocking) {
				_blocking = true;
				return true;
			} else {
				return false;
			}
		}

		/**
		 * @private
		 * @copy com.longtailvideo.jwplayer.player.Player#unblockPlayback
		 */
		public function unblockPlayback(target:IPlugin):Boolean {
			if (_blocking) {
				_blocking = false;
				return true;
			} else {
				return false;
			}
		}

		public function setVolume(vol:Number):Boolean {
			if (_model.media) {
				_model.config.volume = vol;
				_model.media.setVolume(vol);
				return true;
			} else {
				return false;
			}
		}

		public function mute(muted:Boolean):Boolean {
			if (muted && !_model.mute) {
				_model.mute = true;
				return true;
			} else if (!muted && _model.mute) {
				_model.mute = false;
				return true;
			}

			return false;
		}

		public function play():Boolean {
			if (_model.playlist.currentItem) {
				switch (_player.state) {
					case PlayerState.IDLE:
						load(_model.playlist.currentItem);
						break;
					case PlayerState.PAUSED:
						_model.media.play();
						break;
				}
			}
			return true;
		}

		public function pause():Boolean {
			if (!_model.media)
				return false;

			switch (_model.media.state) {
				case PlayerState.PLAYING:
				case PlayerState.BUFFERING:
					_model.media.pause();
					return true;
					break;
			}

			return false;
		}

		public function stop():Boolean {
			if (!_model.media)
				return false;

			switch (_model.media.state) {
				case PlayerState.PLAYING:
				case PlayerState.BUFFERING:
				case PlayerState.PAUSED:
					_model.media.stop();
					return true;
					break;
			}

			return false;
		}

		public function next():Boolean {
			if (_model.playlist.currentIndex == _model.playlist.length-1) { 
				return false;
			} else {
				_player.playlist.currentIndex = _player.playlist.currentIndex+1;
				play();
				return true;
			} 
		}
		
		public function previous():Boolean {
			if (_model.playlist.currentIndex <= 0) {
				return false;
			} else {
				_player.playlist.currentIndex = _player.playlist.currentIndex-1;
				play();
				return true;
			}
		}
		
		public function setPlaylistIndex(index:Number):Boolean {
			if (0 <= index && index < _player.playlist.length) {
				_player.playlist.currentIndex = index;
				load(index);
				return true;
			}
			return false;
		}

		public function seek(pos:Number):Boolean {
			if (!_model.media)
				return false;

			switch (_model.media.state) {
				case PlayerState.PLAYING:
				case PlayerState.BUFFERING:
				case PlayerState.PAUSED:
					_model.media.seek(pos);
					return true;
					break;
			}

			return false;
		}

		public function load(item:*):Boolean {
			//if (!_model.media) return false;

			if (item is PlaylistItem) {
				return loadPlaylistItem(item as PlaylistItem);
			} else if (item is String) {
				return loadString(item as String);
			} else if (item is Number) {
				return loadNumber(item as Number);
			} else if (item is Object) {
				return loadObject(item as Object);
			}
			return false;
		}

		private function loadPlaylistItem(item:PlaylistItem):Boolean {
			var result:Boolean = false;
			try {
				if (!item.provider) {
					JWParser.updateProvider(item);
				}

				if (setProvider(item)) {
					_model.media.addEventListener(MediaEvent.JWPLAYER_MEDIA_BUFFER_FULL, lockHandler);
					_model.media.load(item);
					result = true;
				}
			} catch (err:Error) {
				result = false;
			}
			return result;
		}

		private function loadString(item:String):Boolean {
			if (Strings.extension(item) == "xml"){
				_model.playlist.load(item);
				return true;
			} else {
				return loadPlaylistItem(new PlaylistItem({file:item}));
			}
			return false;
		}

		private function loadNumber(item:Number):Boolean {
			if (item >= 0 && item < _model.playlist.length) {
				return loadPlaylistItem(_model.playlist.getItemAt(item));
			}
			return false;
		}

		private function loadObject(item:Object):Boolean {
			if ((item as Object).hasOwnProperty('file')) {
				return loadPlaylistItem(new PlaylistItem(item));
			}
			return false;
		}

		private function setProvider(item:PlaylistItem):Boolean {
			var provider:String = item.provider;
			if (provider) {
				
				// Backwards compatibility for CDNs in the 'type' flashvar.
				if (cdns.hasOwnProperty(provider)) {
					_model.config.setConfig(cdns[provider]);
					provider = cdns[provider]['provider'];
				}
				
				// If the model doesn't have an instance of the provider, load & instantiate it
				if (!_model.hasMediaProvider(provider)) {
					_delayedItem = item;
					
					var mediaLoader:MediaProviderLoader = new MediaProviderLoader();
					mediaLoader.addEventListener(Event.COMPLETE, mediaSourceLoaded);
					mediaLoader.addEventListener(ErrorEvent.ERROR, errorHandler);
					mediaLoader.loadSource(provider);
					return false;
				}
				
				_model.setActiveMediaProvider(provider);
			}
			
			return true;
		}
		
		private function mediaSourceLoaded(evt:Event):void {
			var loader:MediaProviderLoader = evt.target as MediaProviderLoader;
			var item:PlaylistItem = _delayedItem;
			_delayedItem = null;
			_model.setMediaProvider(item.provider, loader.loadedSource);
			load(item);
		}

		
		private function lockHandler(evt:MediaEvent):void {
			_model.media.play();
		}

		public function redraw():Boolean {
			_view.redraw();
			return true;
		}

		public function fullscreen(mode:Boolean):Boolean {
			_model.fullscreen = mode;
			_view.fullscreen(mode);
			return true;
		}

		public function link(playlistIndex:Number=NaN):Boolean {
			if (isNaN(playlistIndex))
				playlistIndex = _model.playlist.currentIndex;

			if (playlistIndex >= 0 && playlistIndex < _model.playlist.length) {
				navigateToURL(new URLRequest(_model.playlist.getItemAt(playlistIndex).link), _model.config.linktarget);
				return true;
			}

			return false;
		}
		
		private function loadFirstItem():void {
//			if (_model.playlist.currentItem) {
//				load(_model.playlist.currentItem);
//			}	
		}
		

	}
}