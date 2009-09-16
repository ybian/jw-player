package com.longtailvideo.jwplayer.model {
	import com.longtailvideo.jwplayer.events.GlobalEventDispatcher;
	import com.longtailvideo.jwplayer.media.HTTPMediaProvider;
	import com.longtailvideo.jwplayer.media.ImageMediaProvider;
	import com.longtailvideo.jwplayer.media.MediaProvider;
	import com.longtailvideo.jwplayer.media.MediaState;
	import com.longtailvideo.jwplayer.media.RTMPMediaProvider;
	import com.longtailvideo.jwplayer.media.SoundMediaProvider;
	import com.longtailvideo.jwplayer.media.VideoMediaProvider;
	import com.longtailvideo.jwplayer.media.YouTubeMediaProvider;
	
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
		
		private var _currentMedia:MediaProvider;
		
		private var _mediaSources:Object;
		
		/** Constructor **/
		public function Model() {
			_playlist = new Playlist();
			_config = new PlayerConfig(_playlist);
			
			_playlist.addGlobalListener(forwardEvents);
			
			setupMediaProviders();
		}
		
		/** The player config object **/ 
		public function get config():PlayerConfig {
			return _config;
		}
		
		public function set config(conf:PlayerConfig):void {
			_config = conf;
		}

		/** The currently loaded MediaProvider **/
		public function get media():MediaProvider {
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
		

		private function setupMediaProviders():void {
			_mediaSources = {
				'video':	new VideoMediaProvider(config),
				'http':		new HTTPMediaProvider(config),
				'rtmp':		new RTMPMediaProvider(config),
				'sound':	new SoundMediaProvider(config),
				'image':	new ImageMediaProvider(config),
				'youtube':	new YouTubeMediaProvider(config)
			};
		}
		
		/**
		 * Whether the Model has a MediaProvider handler for a given type.   
		 */
		public function hasMediaProvider(type:String):Boolean {
			return (_mediaSources[type.toLowerCase()] is MediaProvider);
		}
		
		/**
		 * Add a MediaProvider to the list of available sources. 
		 */
		public function setMediaProvider(type:String, source:MediaProvider):void {
			if (!hasMediaProvider(type)) {
				_mediaSources[type.toLowerCase()] = source;
			}
		}
		
		public function setActiveMediaProvider(type:String):Boolean {
			if (!hasMediaProvider(type)) type = "video";
			
			var newMedia:MediaProvider = _mediaSources[type.toLowerCase()] as MediaProvider;
			
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