package com.longtailvideo.jwplayer.controller {
	import com.jeroenwijering.events.ModelStates;
	import com.longtailvideo.jwplayer.events.GlobalEventDispatcher;
	import com.longtailvideo.jwplayer.events.MediaEvent;
	import com.longtailvideo.jwplayer.events.PlayerEvent;
	import com.longtailvideo.jwplayer.events.PlaylistEvent;
	import com.longtailvideo.jwplayer.events.ViewEvent;
	import com.longtailvideo.jwplayer.model.Model;
	import com.longtailvideo.jwplayer.model.PlaylistItem;
	import com.longtailvideo.jwplayer.parsers.JWParser;
	import com.longtailvideo.jwplayer.player.IPlayer;
	import com.longtailvideo.jwplayer.player.PlayerState;
	import com.longtailvideo.jwplayer.plugins.IPlugin;
	import com.longtailvideo.jwplayer.utils.Configger;
	import com.longtailvideo.jwplayer.utils.Logger;
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
		protected var _player:IPlayer;
		protected var _model:Model;
		protected var _view:View;

		/** Setup completed **/
		protected var _setupComplete:Boolean = false;
		/** Setup finalized **/
		protected var _setupFinalized:Boolean = false;
		/** Whether to autostart on unlock **/
		protected var _unlockAutostart:Boolean = false;
		/** Whether to resume on unlock **/
		protected var _lockingResume:Boolean = false;
		/** Lock manager **/
		protected var _lockManager:LockManager;
		/** Load after unlock - My favorite variable ever **/
		protected var _unlockAndLoad:Boolean;
		
		
		/** A list with legacy CDN classes that are now redirected to buit-in ones. **/
		protected var cdns:Object = {
				bitgravity:{'http.startparam':'starttime', provider:'http'},
				edgecast:{'http.startparam':'ec_seek', provider:'http'},
				flvseek:{'http.startparam':'fs', provider:'http'},
				highwinds:{'rtmp.loadbalance':true, provider:'rtmp'},
				lighttpd:{'http.startparam':'start', provider:'http'},
				vdox:{'rtmp.loadbalance':true, provider:'rtmp'}
		};
		
		/** Reference to a PlaylistItem which has triggered an external MediaProvider load **/
		protected var _delayedItem:PlaylistItem;
		
		public function Controller(player:IPlayer, model:Model, view:View) {
			_player = player;
			_model = model;
			_view = view;
			_lockManager = new LockManager();
		}

		/**
		 * Begin player setup
		 * @param readyConfig If a PlayerConfig object is already available, use it to configure the player.
		 * Otherwise, load the config from XML / flashvars.
		 */
		public function setupPlayer():void {
			var setup:PlayerSetup = new PlayerSetup(_player, _model, _view);

			setup.addEventListener(Event.COMPLETE, setupComplete);
			setup.addEventListener(ErrorEvent.ERROR, setupError);

			addViewListeners();

			setup.setupPlayer();
		}

		protected function addViewListeners():void {
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

		protected function playHandler(evt:ViewEvent):void { play(); }
		protected function stopHandler(evt:ViewEvent):void { stop(); }
		protected function pauseHandler(evt:ViewEvent):void { pause(); }
		protected function nextHandler(evt:ViewEvent):void { next(); }
		protected function prevHandler(evt:ViewEvent):void { previous(); }
		protected function seekHandler(evt:ViewEvent):void { seek(evt.data); }
		protected function muteHandler(evt:ViewEvent):void { mute(evt.data); }
		protected function volumeHandler(evt:ViewEvent):void { setVolume(evt.data); }
		protected function fullscreenHandler(evt:ViewEvent):void { fullscreen(evt.data); }
		protected function loadHandler(evt:ViewEvent):void { load(evt.data); }
		protected function redrawHandler(evt:ViewEvent):void { redraw(); }


		protected function setupComplete(evt:Event):void {
			_setupComplete = true;
			RootReference.stage.dispatchEvent(new Event(Event.RESIZE));
			_view.completeView();
			finalizeSetup();
		}


		protected function setupError(evt:ErrorEvent):void {
			Logger.log("STARTUP: Error occurred during player startup: " + evt.text);
			_view.completeView(true, evt.text);
			dispatchEvent(evt.clone());
		}


		protected function finalizeSetup():void {
			if (!locking && _setupComplete && !_setupFinalized) {
				_setupFinalized = true;

				dispatchEvent(new PlayerEvent(PlayerEvent.JWPLAYER_READY));

				_player.addEventListener(PlaylistEvent.JWPLAYER_PLAYLIST_LOADED, playlistLoadHandler);
				_player.addEventListener(ErrorEvent.ERROR, errorHandler);
				_player.addEventListener(PlaylistEvent.JWPLAYER_PLAYLIST_ITEM, playlistItemHandler);

				_model.addEventListener(MediaEvent.JWPLAYER_MEDIA_COMPLETE, completeHandler);

				// Broadcast playlist loaded (which was swallowed during player setup);
				if (_model.playlist.length > 0) {
					dispatchEvent(new PlaylistEvent(PlaylistEvent.JWPLAYER_PLAYLIST_LOADED, _model.playlist));
					//dispatchEvent(new PlaylistEvent(PlaylistEvent.JWPLAYER_PLAYLIST_ITEM, _model.playlist));
				}


				if (_player.config.autostart) {
					if (locking) {
						_unlockAutostart = true;
					} else {
						load(_model.playlist.currentItem);
					}
				}
			}
		}


		protected function playlistLoadHandler(evt:PlaylistEvent=null):void {
			if (_model.config.shuffle) {
				shuffleItem();
			} else {
				_model.playlist.currentIndex = _model.config.item;
			}
		}


		protected function shuffleItem():void {
			_model.playlist.currentIndex = Math.floor(Math.random() * _model.playlist.length);
		}


		protected function playlistItemHandler(evt:PlaylistEvent):void {
			_model.config.item = _model.playlist.currentIndex;
		}


		protected function errorHandler(evt:ErrorEvent):void {
			errorState(evt.text);
		}


		protected function errorState(message:String=""):void {
			dispatchEvent(new PlayerEvent(PlayerEvent.JWPLAYER_ERROR, message));
		}


		protected function completeHandler(evt:MediaEvent):void {
			switch (_model.config.repeat) {
				case RepeatOptions.SINGLE:
					play();
					break;
				case RepeatOptions.ALWAYS:
					if (_model.playlist.currentIndex == _model.playlist.length - 1 && !_model.config.shuffle) {
						_model.playlist.currentIndex = 0;
						play();
					} else {
						next();
					}
					break;
				case RepeatOptions.LIST:
					if (_model.playlist.currentIndex == _model.playlist.length - 1 && !_model.config.shuffle) {
						_lockingResume = false;
						_model.playlist.currentIndex = 0;
					} else {
						next();
					}
					break;
			}
		}


		////////////////////
		// Public methods //
		////////////////////

		public function get locking():Boolean {
			return _lockManager.locked();
		}


		/**
		 * @private
		 * @copy com.longtailvideo.jwplayer.player.Player#lockPlayback
		 */
		public function lockPlayback(plugin:IPlugin, callback:Function):void {
			var wasLocked:Boolean = locking;
			if (_lockManager.lock(plugin, callback)) {
				// If it was playing, pause playback and plan to resume when you're done
				if (_player.state == PlayerState.PLAYING || _player.state == PlayerState.BUFFERING) {
					_model.media.pause();
					_lockingResume = true;
				}
				
				// Tell everyone you're locked
				if (!wasLocked) {
					dispatchEvent(new PlayerEvent(PlayerEvent.JWPLAYER_LOCKED));
					_lockManager.executeCallback();
				}
			}
		}


		/**
		 * @private
		 * @copy com.longtailvideo.jwplayer.player.Player#unlockPlayback
		 */
		public function unlockPlayback(target:IPlugin):Boolean {
			if (_lockManager.unlock(target)) {
				if (!locking) {
					dispatchEvent(new PlayerEvent(PlayerEvent.JWPLAYER_UNLOCKED));
				}
				if (!_setupFinalized) {
					finalizeSetup();
				}
				if (!locking && (_lockingResume || _unlockAutostart)) {
					_lockingResume = false;
					if (_unlockAutostart) {
						load(_model.playlist.currentItem);
						_unlockAutostart = false;
					} else if (_unlockAndLoad) {
						load(_model.playlist.currentItem);
						_unlockAndLoad = false;
					} else {
						play();
					}
				}
				return true;
			}
			return false;
		}


		public function setVolume(vol:Number):Boolean {
			if (locking) {
				return false;
			}
			if (_model.media) {
				_model.config.volume = vol;
				_model.media.setVolume(vol);
				setCookie('volume', vol);
				return true;
			}
			return false;
		}


		public function mute(muted:Boolean):Boolean {
			if (locking) {
				return false;
			}
			if (muted && !_model.mute) {
				_model.mute = true;
				setCookie('mute', true);
				return true;
			} else if (!muted && _model.mute) {
				_model.mute = false;
				setCookie('mute', false);
				return true;
			}
			return false;
		}


		public function play():Boolean {
			if (locking) {
				return false;
			}
			if (_model.playlist.currentItem) {
				switch (_player.state) {
					case PlayerState.IDLE:
						load(_model.playlist.currentItem);
						break;
					case PlayerState.BUFFERING:
					case PlayerState.PLAYING:
						_model.media.seek(_model.playlist.currentItem.start);
					case PlayerState.PAUSED:
						_model.media.play();
						break;
				}
			}
			return true;
		}


		public function pause():Boolean {
			if (locking) {
				return false;
			}
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
			if (locking) {
				return false;
			}
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
			if (locking) {
				return false;
			}

			_lockingResume = true;
			if (_model.config.shuffle) {
				stop();
				shuffleItem();
				play();
			} else if (_model.playlist.currentIndex == _model.playlist.length - 1) {
				stop();
				_player.playlist.currentIndex = 0;
			} else {
				stop();
				_player.playlist.currentIndex = _player.playlist.currentIndex + 1;
			}
			
			if (!load(_player.playlist.currentItem)){
				_unlockAndLoad = true;
				return false;
			}

			return true;
		}


		public function previous():Boolean {
			if (locking) {
				return false;
			}

			_lockingResume = true;
			if (_model.playlist.currentIndex <= 0) {
				stop();
				_model.playlist.currentIndex = _model.playlist.length - 1;
			} else {
				stop();
				_player.playlist.currentIndex = _player.playlist.currentIndex - 1;
			}
			
			if (!load(_player.playlist.currentItem)){
				_unlockAndLoad = true;
				return false;	
			}
			
			return true;
		}


		public function setPlaylistIndex(index:Number):Boolean {
			if (locking) {
				return false;
			}

			_lockingResume = true;
			if (0 <= index && index < _player.playlist.length) {
				stop();
				_player.playlist.currentIndex = index;
				if(!load(index)){
					_unlockAndLoad = true;
					return false;
				}
				return true;
			}
			return false;
		}


		public function seek(pos:Number):Boolean {
			if (locking) {
				return false;
			}
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
			if (locking) {
				return false;
			}
			
			if (_model.state != ModelStates.IDLE) {
				_model.media.stop();
			}
			if (item is PlaylistItem) {
				return loadPlaylistItem(item as PlaylistItem);
			} else if (item is String) {
				return loadString(item as String);
			} else if (item is Number) {
				return loadNumber(item as Number);
			} else if (item is Array) {
				return loadArray(item as Array);
			} else if (item is Object) {
				return loadObject(item as Object);
			}
			return false;
		}


		protected function loadPlaylistItem(item:PlaylistItem):Boolean {
			if (!_model.playlist.contains(item)) {
				_model.playlist.load(item);
			}

			if (locking) {
				_lockingResume = true;
				return false;
			}
			try {
				if (!item.provider) {
					JWParser.updateProvider(item);
				}

				if (setProvider(item)) {
					if (!_delayedItem) {
						_model.media.addEventListener(MediaEvent.JWPLAYER_MEDIA_BUFFER_FULL, bufferFullHandler);
						_model.media.load(item);
					}
				} else if (item.file) {
					_model.playlist.load(item.file)
				}
			} catch (err:Error) {
				return false;
			}
			return true;
		}


		protected function loadString(item:String):Boolean {
			if (Strings.extension(item) == "xml") {
				_model.playlist.load(item);
				return true;
			} else {
				return loadPlaylistItem(new PlaylistItem({file: item}));
			}
			return false;
		}


		protected function loadArray(item:Array):Boolean {
			if (item.length > 0) {
				_model.playlist.load(item);
				return true;
			}
			return false;
		}

		protected function loadNumber(item:Number):Boolean {
			if (item >= 0 && item < _model.playlist.length) {
				return loadPlaylistItem(_model.playlist.getItemAt(item));
			}
			return false;
		}


		protected function loadObject(item:Object):Boolean {
			if ((item as Object).hasOwnProperty('file')) {
				return loadPlaylistItem(new PlaylistItem(item));
			}
			return false;
		}


		protected function setProvider(item:PlaylistItem):Boolean {
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
					return true;
				}

				_model.setActiveMediaProvider(provider);
				return true;
			}

			return false;
		}


		protected function mediaSourceLoaded(evt:Event):void {
			var loader:MediaProviderLoader = evt.target as MediaProviderLoader;
			var item:PlaylistItem = _delayedItem;
			_delayedItem = null;
			_model.setMediaProvider(item.provider, loader.loadedSource);
			load(item);
		}


		private function bufferFullHandler(evt:MediaEvent):void {
			if (!locking) {
				_model.media.play();
			} else {
				_lockingResume = true;
			}
		}


		public function redraw():Boolean {
			if (locking) {
				return false;
			}
			_view.redraw();
			return true;
		}


		public function fullscreen(mode:Boolean):Boolean {
			_model.fullscreen = mode;
			_view.fullscreen(mode);
			return true;
		}


		public function link(playlistIndex:Number=NaN):Boolean {
			if (locking) {
				return false;
			}
			if (isNaN(playlistIndex))
				playlistIndex = _model.playlist.currentIndex;

			if (playlistIndex >= 0 && playlistIndex < _model.playlist.length) {
				navigateToURL(new URLRequest(_model.playlist.getItemAt(playlistIndex).link), _model.config.linktarget);
				return true;
			}

			return false;
		}


		protected function setCookie(name:String, value:*):void {
			Configger.saveCookie(name, value);
		}

	}
}