package com.longtailvideo.jwplayer.controller {
	import com.longtailvideo.jwplayer.events.GlobalEventDispatcher;
	import com.longtailvideo.jwplayer.events.PlayerEvent;
	import com.longtailvideo.jwplayer.media.MediaState;
	import com.longtailvideo.jwplayer.model.Model;
	import com.longtailvideo.jwplayer.model.PlaylistItem;
	import com.longtailvideo.jwplayer.player.Player;
	import com.longtailvideo.jwplayer.plugins.IPlugin;
	import com.longtailvideo.jwplayer.utils.Configger;
	import com.longtailvideo.jwplayer.utils.RootReference;
	import com.longtailvideo.jwplayer.view.DefaultSkin;
	import com.longtailvideo.jwplayer.view.ISkin;
	import com.longtailvideo.jwplayer.view.View;
	
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.utils.Timer;
	
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
		
		private var _player:Player;
		private var _model:Model;
		private var _view:View;

		private var _blocking:Boolean = false;

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
			var configger:Configger = new Configger();
			configger.addEventListener(Event.COMPLETE, configLoaded);
			configger.addEventListener(ErrorEvent.ERROR, configFailed);

			try {
				configger.loadConfig();
			} catch (e:Error) {
				errorState();
			}
		}

		private function configLoaded(evt:Event):void {
			var confHash:Object = (evt.target as Configger).config;
			_model.config.setConfig(confHash);
			loadSkin();
		}

		private function configFailed(evt:ErrorEvent):void {
			
		}
		
		private function loadSkin():void {
			var skin:ISkin = new DefaultSkin();
		}

		private function errorState():void {
			dispatchEvent(new PlayerEvent(PlayerEvent.JWPLAYER_ERROR));
		}

		private function insertDelay():void {
			var timer:Timer = new Timer(50, 1);
			timer.addEventListener(TimerEvent.TIMER_COMPLETE, delayComplete);
			timer.start();
		}

		private function delayComplete(evt:TimerEvent):void {

		}

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
			if (!_model.media) return false;
			
			if (item is PlaylistItem) {
				_model.media.load(item);
				return true;
			} else if (item is String) {
				// Todo: handle if string is a playlist 
				var newItem:PlaylistItem = new PlaylistItem();
				newItem.file = item;
				_model.media.load(newItem);
				return true;
			} else if (item is Number) {
				if (item >= 0 && item < _model.playlist.length) {
					_model.media.load(_model.playlist.getItemAt(item));
					return true;
				}	
			} else if (Object(item).hasOwnProperty('file')) {
				_model.media.load(new PlaylistItem(item));
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