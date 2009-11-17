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
		private var _player:IPlayer;
		private var _model:Model;
		private var _view:View;

		/** Setup completed **/
		private var _setupComplete:Boolean = false;
		/** Setup finalized **/
		private var _setupFinalized:Boolean = false;
		/** Whether to autostart on unlock **/
		private var _unlockAutostart:Boolean = false;
		/** Whether to resume on unlock **/
		private var _lockingResume:Boolean = false;
		/** Lock manager **/
		private var _lockManager:LockManager;
		
		
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


		private function setupComplete(evt:Event):void {
			_setupComplete = true;
			_view.completeView();
			finalizeSetup();
		}


		private function setupError(evt:ErrorEvent):void {
			Logger.log("STARTUP: Error occurred during player startup: " + evt.text);
			_view.completeView(true, evt.text);
			dispatchEvent(evt.clone());
		}


		private function finalizeSetup():void {
			if (!locking && _setupComplete && !_setupFinalized) {
				_setupFinalized = true;

				dispatchEvent(new PlayerEvent(PlayerEvent.JWPLAYER_READY));

				_model.playlist.addEventListener(PlaylistEvent.JWPLAYER_PLAYLIST_LOADED, playlistLoadHandler, false, 1000);
				_model.playlist.addEventListener(ErrorEvent.ERROR, errorHandler);
				_model.playlist.addEventListener(PlaylistEvent.JWPLAYER_PLAYLIST_ITEM, playlistItemHandler, false, 1000);

				_model.addEventListener(MediaEvent.JWPLAYER_MEDIA_COMPLETE, completeHandler);

				// Broadcast playlist loaded (which was swallowed during player setup);
				if (_model.playlist.length > 0) {
					dispatchEvent(new PlaylistEvent(PlaylistEvent.JWPLAYER_PLAYLIST_LOADED, _model.playlist));
				}

				RootReference.stage.dispatchEvent(new Event(Event.RESIZE));

				if (_player.config.autostart) {
					if (locking) {
						_unlockAutostart = true;
					} else {
						load(_model.playlist.currentItem);
					}
				}
			}
		}


		private function playlistLoadHandler(evt:PlaylistEvent=null):void {
			dispatchEvent(new PlaylistEvent(PlaylistEvent.JWPLAYER_PLAYLIST_LOADED, _model.playlist));
			if (_model.config.shuffle) {
				shuffleItem();
			} else {
				_model.playlist.currentIndex = _model.config.item;
			}
		}


		private function shuffleItem():void {
			_model.playlist.currentIndex = Math.floor(Math.random() * _model.playlist.length);
		}


		private function playlistItemHandler(evt:PlaylistEvent):void {
			_model.config.item = _model.playlist.currentIndex;
		}


		private function errorHandler(evt:ErrorEvent):void {
			errorState(evt.text);
		}


		private function errorState(message:String=""):void {
			dispatchEvent(new PlayerEvent(PlayerEvent.JWPLAYER_ERROR, message));
		}


		private function completeHandler(evt:MediaEvent):void {
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
				if (_player.state == PlayerState.BUFFERING || _player.state == PlayerState.PLAYING) {
					_model.media.pause();
					_lockingResume = true;
				}
				// If it wasn't playing
				if (_player.config.autostart || _lockingResume) {
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
					} else {
						_model.media.play();
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
			if (_model.config.shuffle) {
				shuffleItem();
				play();
				return true;
			} else if (_model.playlist.currentIndex == _model.playlist.length - 1) {
				_player.playlist.currentIndex = 0;
			} else {
				_player.playlist.currentIndex = _player.playlist.currentIndex + 1;
			}
			loadPlaylistItem(_player.playlist.currentItem);
			return true;
		}


		public function previous():Boolean {
			if (locking) {
				return false;
			}
			if (_model.playlist.currentIndex <= 0) {
				_model.playlist.currentIndex = _model.playlist.length - 1;
			} else {
				_player.playlist.currentIndex = _player.playlist.currentIndex - 1;
			}
			loadPlaylistItem(_player.playlist.currentItem);
			return true;
		}


		public function setPlaylistIndex(index:Number):Boolean {
			if (locking) {
				return false;
			}
			if (0 <= index && index < _player.playlist.length) {
				_player.playlist.currentIndex = index;
				load(index);
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
			} else if (item is Object) {
				return loadObject(item as Object);
			}
			return false;
		}


		private function loadPlaylistItem(item:PlaylistItem):Boolean {
			if (!_model.playlist.contains(item)) {
				_model.playlist.load(item);
			}
			dispatchEvent(new PlaylistEvent(PlaylistEvent.JWPLAYER_PLAYLIST_ITEM, _model.playlist));
			var result:Boolean = false;
			try {
				if (!item.provider) {
					JWParser.updateProvider(item);
				}

				if (setProvider(item)) {
					_model.media.addEventListener(MediaEvent.JWPLAYER_MEDIA_BUFFER_FULL, lockHandler);
					_model.media.load(item);
					result = true;
				} else if (item.file) {
					_model.playlist.load(item.file)
				}
			} catch (err:Error) {
				result = false;
			}
			return result;
		}


		private function loadString(item:String):Boolean {
			if (Strings.extension(item) == "xml") {
				_model.playlist.load(item);
				return true;
			} else {
				return loadPlaylistItem(new PlaylistItem({file: item}));
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
				return true;
			}

			return false;
		}


		private function mediaSourceLoaded(evt:Event):void {
			var loader:MediaProviderLoader = evt.target as MediaProviderLoader;
			var item:PlaylistItem = _delayedItem;
			_delayedItem = null;
			_model.setMediaProvider(item.provider, loader.loadedSource);
			load(item);
		}


		private function lockHandler(evt:MediaEvent):void {
			if (!locking) {
				_model.media.play();
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


		private function setCookie(name:String, value:*):void {
			Configger.saveCookie(name, value);
		}

	}
}