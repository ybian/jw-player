package com.longtailvideo.jwplayer.media {
	import com.longtailvideo.jwplayer.events.GlobalEventDispatcher;
	import com.longtailvideo.jwplayer.events.IGlobalEventDispatcher;
	import com.longtailvideo.jwplayer.events.MediaEvent;
	import com.longtailvideo.jwplayer.events.MediaStateEvent;
	import com.longtailvideo.jwplayer.model.PlayerConfig;
	import com.longtailvideo.jwplayer.model.PlaylistItem;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;

	/**
	 * Fired when a portion of the current media has been loaded into the buffer.
	 * 
	 * @eventType com.longtailvideo.jwplayer.events.MediaEvent.JWPLAYER_MEDIA_BUFFER
	 */
	[Event(name="jwplayerMediaBuffer", type = "com.longtailvideo.jwplayer.events.MediaEvent")]

	/**
	 * Fired if an error occurs in the course of media playback.
	 * 
	 * @eventType com.longtailvideo.jwplayer.events.MediaEvent.JWPLAYER_MEDIA_ERROR
	 */
	[Event(name="jwplayerMediaError", type = "com.longtailvideo.jwplayer.events.MediaEvent")]

	/**
	 * Fired after the MediaSource has loaded an item into memory.
	 * 
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

	public class MediaSource extends Sprite implements IGlobalEventDispatcher, IMediaSource {
		/** Reference to the player configuration. **/
		protected var _config:PlayerConfig;
		/** Reference to the currently active playlistitem. **/
		protected var _item:PlaylistItem;
		/** The current position inside the file. **/
		protected var _position:Number;
		/** The current volume of the audio output stream **/
		protected var _volume:Number;
		/** The playback state for the currently loaded media.  @see com.longtailvideo.jwplayer.model.ModelStates **/
		protected var _state:String;
		/** Graphical representation of the currently playing media **/
		protected var _media:DisplayObject;
		/** Most recent buffer data **/
		protected var bufferPercent:Number;
		/** Handles event dispatching **/
		protected var _dispatcher:GlobalEventDispatcher;

		public function MediaSource(cfg:PlayerConfig) {
			_config = cfg;
			_dispatcher = new GlobalEventDispatcher();
			_state = MediaState.IDLE;
		}

		/**
		 * Load a new playlist item
		 * @param itm The playlistItem to load
		 **/
		public function load(itm:PlaylistItem):void {
			_item = itm;
			dispatchEvent(new MediaEvent(MediaEvent.JWPLAYER_MEDIA_LOADED));
		}

		/** Pause playback of the item. **/
		public function pause():void {
			setState(MediaState.PAUSED);
		}

		/** Resume playback of the item. **/
		public function play():void {
			setState(MediaState.PLAYING);
		}

		/**
		 * Seek to a certain position in the item.
		 *
		 * @param pos	The position in seconds.
		 **/
		public function seek(pos:Number):void {
			_position = pos;
			sendMediaEvent(MediaEvent.JWPLAYER_MEDIA_TIME, {position: position});
		}

		/** Stop playing and loading the item. **/
		public function stop():void {
			_position = 0;
			setState(MediaState.IDLE);
		}

		/**
		 * Change the playback volume of the item.
		 *
		 * @param vol	The new volume (0 to 100).
		 **/
		public function setVolume(vol:Number):void {
			sendMediaEvent(MediaEvent.JWPLAYER_MEDIA_VOLUME, {'volume': vol});
		}

		/** Graphical representation of media **/
		public function display():DisplayObject {
			return _media;
		}

		/**
		 * Current state of the MediaSource.
		 * @see MediaStates
		 */
		public function get state():String {
			return _state;
		}

		/** Currently playing PlaylistItem **/
		public function get item():PlaylistItem {
			return _item;
		}

		/** Current position, in seconds **/
		public function get position():Number {
			return _position;
		}

		/**
		 * The current volume of the playing media
		 * <p>Range: 0-100</p> 
		 */
		public function get volume():Number {
			return _volume;
		}

		/**
		 * Sets the current state to a new state and sends a MediaStateEvent
		 * @param newState A state from ModelStates.
		 */
		protected function setState(newState:String):void {
			if (this._state != newState){
				var evt:MediaStateEvent = new MediaStateEvent(MediaStateEvent.JWPLAYER_MEDIA_STATE, newState, this._state);
				this._state = newState;
				dispatchEvent(evt);
			}
		}

		/**
		 * Sends a MediaEvent, simultaneously setting a property
		 * @param type
		 * @param property
		 * @param value
		 */
		protected function sendMediaEvent(type:String, properties:Object=null):void {
			var newEvent:MediaEvent = new MediaEvent(type);
			for (var property:String in properties){
				if (newEvent.hasOwnProperty(property)) {
					newEvent[property] = properties[property];
				}
			}
			dispatchEvent(newEvent);
		}
		
		/** Dispatches buffer change notifications **/
		public function sendBufferEvent(bufferPercent:Number):void {
			// TODO: Do you send buffering events when in the playing state?
			if (state == MediaState.BUFFERING && bufferPercent != this.bufferPercent) {
				this.bufferPercent = bufferPercent;
				sendMediaEvent(MediaEvent.JWPLAYER_MEDIA_BUFFER, {'bufferPercent': this.bufferPercent});
			}
		}

		///////////////////////////////////////////		
		/// IGlobalEventDispatcher implementation
		///////////////////////////////////////////		
		
		/**
		 * @inheritDoc 
		 */
		public function addGlobalListener(listener:Function):void {
			_dispatcher.addGlobalListener(listener);
		}
		
		/**
		 * @inheritDoc 
		 */
		public function removeGlobalListener(listener:Function):void {
			_dispatcher.removeGlobalListener(listener);
		}
		
		/**
		 * @inheritDoc 
		 */
		public override function dispatchEvent(event:Event):Boolean {
			_dispatcher.dispatchEvent(event);
			return super.dispatchEvent(event);
		}

	}
}