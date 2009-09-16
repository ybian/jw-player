package com.longtailvideo.jwplayer.controller {
	import com.longtailvideo.jwplayer.events.GlobalEventDispatcher;
	import com.longtailvideo.jwplayer.events.PlayerEvent;
	import com.longtailvideo.jwplayer.events.PlaylistEvent;
	import com.longtailvideo.jwplayer.media.MediaState;
	import com.longtailvideo.jwplayer.model.Model;
	import com.longtailvideo.jwplayer.model.PlaylistItem;
	import com.longtailvideo.jwplayer.player.Player;
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
		
		/** File extensions of all supported mediatypes. **/
		private var EXTENSIONS:Object = {
			'3g2':'video',
			'3gp':'video',
			'aac':'video',
			'f4b':'video',
			'f4p':'video',
			'f4v':'video',
			'flv':'video',
			'gif':'image',
			'jpg':'image',
			'jpeg':'image',
			'm4a':'video',
			'm4v':'video',
			'mov':'video',
			'mp3':'sound',
			'mp4':'video',
			'png':'image',
			'rbs':'sound',
			'sdp':'video',
			'swf':'image',
			'vp6':'video'
		};
		

		public function Controller(player:Player, model:Model, view:View) {
			var rootRef:RootReference = new RootReference(player);

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
			
		}
		
		private function addModelListeners():void {
			_model.playlist.addEventListener(PlaylistEvent.JWPLAYER_PLAYLIST_LOADED, playlistLoadHandler);
			_model.playlist.addEventListener(ErrorEvent.ERROR, errorHandler);
		}
		
		private function setupComplete(evt:Event):void {
			trace("Setup complete");
		}
		
		private function playlistLoadHandler(evt:PlaylistEvent):void {
			for (var i:Number = 0; i < _model.playlist.length; i++) {
				if (!_model.hasMediaProvider(_model.playlist.getItemAt(i).type)) {
//					load the external media source					
//					loadMediaProvider(type);
				} 
			}
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
				_model.media.setVolume(0);
				return true;
			} else if (!muted && _model.mute) {
				_model.mute = false;
				_model.media.setVolume(_model.config.volume);
				return true;
			}
			
			return false;
		}

		public function play():Boolean {
			if (!_model.media) return false;
			
			switch (_model.media.state) {
				case MediaState.PLAYING:
				case MediaState.BUFFERING:
					return false;
					break;
				default:
					_model.media.play();
					break;
			}
			
			return true; 
		}

		public function pause():Boolean {
			if (!_model.media) return false;
			
			switch (_model.media.state) {
				case MediaState.PLAYING:
				case MediaState.BUFFERING:
					_model.media.pause();
					return true;
					break;
			}
			
			return false; 
		}

		public function stop():Boolean {
			if (!_model.media) return false;
			
			switch (_model.media.state) {
				case MediaState.PLAYING:
				case MediaState.BUFFERING:
				case MediaState.PAUSED:
					_model.media.stop();
					return true;
					break;
			}
			
			return false; 
		}

		public function seek(pos:Number):Boolean {
			if (!_model.media) return false;
			
			switch (_model.media.state) {
				case MediaState.PLAYING:
				case MediaState.BUFFERING:
				case MediaState.PAUSED:
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
			_model.setActiveMediaProvider(item.type);
			_model.media.load(item);
			return true;
		}

		private function loadString(item:String):Boolean {
			var ext:String = Strings.extension(item);
			if (EXTENSIONS.hasOwnProperty(ext)) {
				var type:String = EXTENSIONS[ext];
				_model.setActiveMediaProvider(type);
				_model.media.load(new PlaylistItem({file:item}));
			} else {
				_model.playlist.load(item);
			}
			return false;
		}
		
		private function loadNumber(item:Number):Boolean {
			if (item >= 0 && item < _model.playlist.length) {
				_model.media.load(_model.playlist.getItemAt(item));
				return true;
			}	
			return false;
		}
		
		private function loadObject(item:Object):Boolean {
			if (Object(item).hasOwnProperty('file')) {
				_model.media.load(new PlaylistItem(item));
				return true;
			}
			return false;
		}
		
		public function redraw():Boolean {
			_view.redraw();
			return true;
		}

		public function fullscreen(mode:Boolean):Boolean {
			_view.fullscreen(mode);
			return true;
		}
		
		public function link(playlistIndex:Number=NaN):Boolean {
			if (isNaN(playlistIndex)) playlistIndex = _model.playlist.currentIndex;
			
			if (playlistIndex >= 0 && playlistIndex < _model.playlist.length) {
				navigateToURL(new URLRequest(_model.playlist.getItemAt(playlistIndex).link), _model.config.linktarget);
				return true;
			} 
			
			return false;
		}
		
	}
}