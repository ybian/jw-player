package com.longtailvideo.jwplayer.model {
	import com.longtailvideo.jwplayer.events.GlobalEventDispatcher;
	import com.longtailvideo.jwplayer.media.MediaSource;
	import com.longtailvideo.jwplayer.media.MediaState;
	
	import flash.events.Event;

	/**
	 * @eventType com.longtailvideo.jwplayer.events.MediaEvent.JWPLAYER_MEDIA_BUFFER
	 */
	[Event(name="jwplayerMediaBuffer", type = "com.longtailvideo.jwplayer.events.MediaEvent")]

	/**
	 * @eventType com.longtailvideo.jwplayer.events.MediaEvent.JWPLAYER_MEDIA_ERROR
	 */
	[Event(name="jwplayerMediaError", type = "com.longtailvideo.jwplayer.events.MediaEvent")]

	/**
	 * @eventType com.longtailvideo.jwplayer.events.MediaEvent.JWPLAYER_MEDIA_LOADED
	 */
	[Event(name="jwplayerMediaLoaded", type = "com.longtailvideo.jwplayer.events.MediaEvent")]

	/**
	 * @eventType com.longtailvideo.jwplayer.events.MediaEvent.JWPLAYER_MEDIA_TIME
	 */
	[Event(name="jwplayerMediaTime", type = "com.longtailvideo.jwplayer.events.MediaEvent")]

	/**
	 * @eventType com.longtailvideo.jwplayer.events.MediaEvent.JWPLAYER_MEDIA_VOLUME
	 */
	[Event(name="jwplayerMediaVolume", type = "com.longtailvideo.jwplayer.events.MediaEvent")]

	/**
	 * @eventType com.longtailvideo.jwplayer.events.MediaStateEvent.JWPLAYER_MEDIA_STATE
	 */
	[Event(name="jwplayerMediaState", type = "com.longtailvideo.jwplayer.events.MediaStateEvent")]


	
	/**
	 * @author Pablo Schklowsky
	 */
	public class Model extends GlobalEventDispatcher {
		private var _config:PlayerConfig;
		private var _playlist:Playlist;

		private var _fullscreen:Boolean = false;
		private var _mute:Boolean = false;
		
		private var _currentMedia:MediaSource;
		
		private var _mediaSources:Object;
		
		/** Constructor **/
		public function Model() {
			_playlist = new Playlist();
			_config = new PlayerConfig(_playlist);
			
			_playlist.addGlobalListener(forwardEvents);
			
			setupMediaSources();
		}
		
		/** The player config object **/ 
		public function get config():PlayerConfig {
			return _config;
		}
		
		public function set config(conf:PlayerConfig):void {
			_config = conf;
		}

		/** The currently loaded MediaSource **/
		public function get media():MediaSource {
			return _currentMedia;
		}
		
		/**
		 * The current player state 
		 */
		public function get state():String {
			return _currentMedia ? _currentMedia.state : MediaState.IDLE;
		}

		/**
		 * The loaded playlist 
		 */
		public function get playlist():Playlist {
			return _playlist;
		}

		/** The current fullscreen state of the player **/
		public function get fullscreen():Boolean {
			return _fullscreen;
		}
		public function set fullscreen(b:Boolean):void {
			_fullscreen = b;
		}

		/** The current mute state of the player **/
		public function get mute():Boolean {
			return _mute;
		}
		public function set mute(b:Boolean):void {
			_mute = b;
		}
		

		private function setupMediaSources():void {
			_mediaSources = {
				'video':	new MediaSource(),
				'http':		new MediaSource(),
				'rtmp':		new MediaSource(),
				'sound':	new MediaSource(),
				'image':	new MediaSource(),
				'youtube':	new MediaSource()
			};
		}
		
		/**
		 * Whether the Model has a MediaSource handler for a given type.   
		 */
		public function hasMediaSource(type:String):Boolean {
			return (_mediaSources[type.toLowerCase()] is MediaSource);
		}
		
		/**
		 * Add a MediaSource to the list of available sources. 
		 */
		public function setMediaSource(type:String, source:MediaSource):void {
			if (!hasMediaSource(type)) {
				_mediaSources[type.toLowerCase()] = source;
			}
		}
		
		public function setActiveMediaSource(type:String):Boolean {
			if (!hasMediaSource(type)) type = "video";
			
			var newMedia:MediaSource = _mediaSources[type.toLowerCase()] as MediaSource;
			
			if (_currentMedia != newMedia) {
				_currentMedia.removeGlobalListener(forwardEvents);
				newMedia.addGlobalListener(forwardEvents);
			}
			
			return true;
		}
		
		private function forwardEvents(evt:Event):void {
			dispatchEvent(evt);
		}

	}
}