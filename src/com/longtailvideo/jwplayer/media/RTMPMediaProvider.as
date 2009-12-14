/**
 * Wrapper for playback of _video streamed over RTMP.
 *
 * All playback functionalities are cross-server (FMS, Wowza, Red5), with the exception of:
 * - The SecureToken functionality (Wowza).
 * - getStreamLength / checkBandwidth (FMS3).
 **/
package com.longtailvideo.jwplayer.media {
	import com.jeroenwijering.events.*;
	import com.longtailvideo.jwplayer.events.MediaEvent;
	import com.longtailvideo.jwplayer.model.PlayerConfig;
	import com.longtailvideo.jwplayer.model.PlaylistItem;
	import com.longtailvideo.jwplayer.player.PlayerState;
	import com.longtailvideo.jwplayer.utils.NetClient;
	import com.longtailvideo.jwplayer.utils.TEA;
	
	import flash.events.*;
	import flash.media.*;
	import flash.net.*;
	import flash.utils.*;


	public class RTMPMediaProvider extends MediaProvider {
		/** Video object to be instantiated. **/
		protected var _video:Video;
		/** NetConnection object for setup of the _video _stream. **/
		protected var _connection:NetConnection;
		/** Loader instance that loads the XML file. **/
		private var _loader:URLLoader;
		/** NetStream instance that handles the _stream IO. **/
		protected var _stream:NetStream;
		/** Sound control object. **/
		protected var _transformer:SoundTransform;
		/** Save the location of the XML redirect. **/
		private var _smil:String;
		/** Save that the _video has been _started. **/
		protected var _started:Boolean;
		/** ID for the position _positionInterval. **/
		protected var _positionInterval:Number;
		/** Save that a file is _unpublished. **/
		protected var _unpublished:Boolean;
		/** Whether the buffer has filled **/
		private var _bufferFull:Boolean;
		
		public function RTMPMediaProvider() {
			super('rtmp');
		}


		/** Constructor; sets up the connection and display. **/
		public override function initializeMediaProvider(cfg:PlayerConfig):void {
			super.initializeMediaProvider(cfg);
			_connection = new NetConnection();
			_connection.addEventListener(NetStatusEvent.NET_STATUS, statusHandler);
			_connection.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);
			_connection.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			_connection.addEventListener(AsyncErrorEvent.ASYNC_ERROR, errorHandler);
			_connection.objectEncoding = ObjectEncoding.AMF0;
			_connection.client = new NetClient(this);
			_loader = new URLLoader();
			_loader.addEventListener(Event.COMPLETE, loaderHandler);
			_loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);
			_loader.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			_video = new Video(320, 240);
			_video.smoothing = config.smoothing;
			_transformer = new SoundTransform();
		}


		/** Catch security errors. **/
		protected function errorHandler(evt:ErrorEvent):void {
			error(evt.text);
		}


		/** Extract the correct rtmp syntax from the file string. **/
		protected function getID(url:String):String {
			var ext:String = url.substr(-4);
			if (ext == '.mp3') {
				return 'mp3:' + url.substr(0, url.length - 4);
			} else if (ext == '.mp4' || ext == '.mov' || ext == '.aac' || ext == '.m4a' || ext == '.f4v') {
				return 'mp4:' + url;
			} else if (ext == '.flv') {
				return url.substr(0, url.length - 4);
			} else {
				return url;
			}
		}


		/** Load content. **/
		override public function load(itm:PlaylistItem):void {
			_item = itm;
			_position = 0;
			_bufferFull = false;
			setState(PlayerState.BUFFERING);
			sendBufferEvent(0);
			if (getConfigProperty('loadbalance') as Boolean == true) {
				_smil = item.file;
				_loader.load(new URLRequest(_smil));
			} else {
				finishLoad();
			}
		}


		/** Get the streamer / file from the loadbalancing XML. **/
		private function loaderHandler(evt:Event):void {
			var xml:XML = XML(evt.currentTarget.data);
			item.streamer = xml.children()[0].children()[0].@base.toString();
			item.file = xml.children()[1].children()[0].@src.toString();
			finishLoad();
		}


		/** Finalizes the loading process **/
		private function finishLoad():void {
			var ext:String = item.file.substr(-4);
			if (ext == '.mp3'){
				media = null;
			} else if (!media) {
				media = _video;
			}
			_connection.connect(item.streamer);
			config.mute == true ? setVolume(0) : setVolume(config.volume);
			sendMediaEvent(MediaEvent.JWPLAYER_MEDIA_LOADED);
		}


		/** Get metadata information from netstream class. **/
		public function onData(dat:Object):void {
			if (dat.width) {
				_video.width = dat.width;
				_video.height = dat.height;
				resize(_width, _height);
			}
			if (dat.duration && item.duration < 0) {
				item.duration = dat.duration;
			}
			if (dat.type == 'complete') {
				complete();
			} else if (dat.type == 'close') {
				stop();
			}
			if (config.ignoremeta != true) {
				sendMediaEvent(MediaEvent.JWPLAYER_MEDIA_META, {metadata: dat});
			}
		}

		
		/** Determines if the stream is a live stream **/
		private function get livestream():Boolean {
			return item.duration == 0;
		}

		/** Pause playback. **/
		override public function pause():void {
			_stream.pause();
			clearInterval(_positionInterval);
			_positionInterval = undefined;
			super.pause();
			if (_started && item.duration == 0) {
				stop();
			}
		}


		/** Resume playing. **/
		override public function play():void {
			/* 
			* Livestreams will reset their buffer if _stream.resume is called,
			* so we suppress them after the intial call
			*/
			if (!(livestream && _started)) {
				_stream.resume();
			}
			if (!_positionInterval) {
				_positionInterval = setInterval(positionInterval, 100);
			}
			super.play();
		}


		/** Interval for the position progress. **/
		protected function positionInterval():void {
			_position = Math.round(_stream.time * 10) / 10;

			var bfr:Number;
			if (!livestream) {
				var bufferTime:Number = _stream.bufferTime < (item.duration - position) ? _stream.bufferTime : (item.duration - position);
				bfr = Math.round(_stream.bufferLength / bufferTime * 100);
			} else {
				bfr = Math.round(_stream.bufferLength / _stream.bufferTime * 100);
			}
			
			if (bfr < 95 && position < Math.abs(item.duration - _stream.bufferTime - 1)) {
				if (state == PlayerState.PLAYING && bfr < 20) {
					_bufferFull = false;
					_stream.pause();
					setState(PlayerState.BUFFERING);
					_stream.bufferTime = config.bufferlength;
					sendMediaEvent(MediaEvent.JWPLAYER_MEDIA_META, {metadata: {bufferlength: config.bufferlength}});
				}
			} else if (bfr > 95 && state == PlayerState.BUFFERING) {
				_stream.bufferTime = config.bufferlength * 4;
				sendMediaEvent(MediaEvent.JWPLAYER_MEDIA_META, {metadata: {bufferlength: config.bufferlength * 4}});
				if (!_bufferFull){
					_bufferFull = true;
					sendMediaEvent(MediaEvent.JWPLAYER_MEDIA_BUFFER_FULL);
				}
			}

			if (state == PlayerState.BUFFERING || state == PlayerState.PAUSED) {
				//TODO: This works, but it looks weird, as the bufferTime is changing
				/*
				if (!_bufferingComplete){
					sendBufferEvent(_stream.bufferLength / _stream.bufferTime * item.duration);
				}
				*/
			} else if (position < item.duration) {
				if (state == PlayerState.PLAYING && position >= 0) {
					//TODO: This works, but it looks weird, as the bufferTime is changing
					//sendMediaEvent(MediaEvent.JWPLAYER_MEDIA_TIME, {position: position, duration: item.duration, bufferLength: _stream.bufferLength / _stream.bufferTime * item.duration});
					sendMediaEvent(MediaEvent.JWPLAYER_MEDIA_TIME, {position: position, duration: item.duration});
				}
			} else if (!isNaN(position) && item.duration > 0) {
				complete();
			}
		}


		/** Seek to a new position. **/
		override public function seek(pos:Number):void {
			_position = pos;
			clearInterval(_positionInterval);
			_positionInterval = undefined;
			_stream.seek(position);
			if (!_positionInterval) {
				_positionInterval = setInterval(positionInterval, 100);
			}
		}


		/** Start the netstream object. **/
		protected function setStream():void {
			_stream = new NetStream(_connection);
			_stream.checkPolicyFile = true;
			_stream.addEventListener(NetStatusEvent.NET_STATUS, statusHandler);
			_stream.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			_stream.addEventListener(AsyncErrorEvent.ASYNC_ERROR, errorHandler);
			_stream.bufferTime = config.bufferlength;
			_stream.client = new NetClient(this);
			_video.attachNetStream(_stream);
			if (!_positionInterval) {
				_positionInterval = setInterval(positionInterval, 100);
			}
			_stream.play(getID(item.file));
		}


		/** Receive NetStream status updates. **/
		protected function statusHandler(evt:NetStatusEvent):void {
			switch (evt.info.code) {
				case 'NetConnection.Connect.Success':
					if (evt.info.secureToken != undefined) {
						_connection.call("secureTokenResponse", null, TEA.decrypt(evt.info.secureToken, config.token));
					}
					setStream();
					var res:Responder = new Responder(streamlengthHandler);
					_connection.call("getStreamLength", res, getID(item.file));
					_connection.call("checkBandwidth", null);
					break;
				case 'NetStream.Play.Start':
					if (item.start > 0 && !_started) {
						seek(item.start);
					}
					_started = true;
					break;
				case 'NetStream.Seek.Notify':
					clearInterval(_positionInterval);
					_positionInterval = undefined;
					if (!_positionInterval) {
						_positionInterval = setInterval(positionInterval, 100);
					}
					break;
				case 'NetConnection.Connect.Rejected':
					try {
						if (evt.info.ex.code == 302) {
							item.streamer = evt.info.ex.redirect;
							setTimeout(load, 100, item);
							return;
						}
					} catch (err:Error) {
						var msg:String = evt.info.code;
						if (evt.info['description']) {
							msg = evt.info['description'];
						}
						error(msg);
					}
					break;
				case 'NetStream.Failed':
				case 'NetStream.Play.StreamNotFound':
					if (_unpublished) {
						onData({type: 'complete'});
						_unpublished = false;
					} else {
						error("Stream not found: " + item.file);
					}
					break;
				case 'NetConnection.Connect.Failed':
					error("Server not found: " + item.streamer);
					break;
				case 'NetStream.Play.UnpublishNotify':
					_unpublished = true;
					break;
				case 'NetStream.Buffer.Full':
					if (!_bufferFull) {
						_bufferFull = true;
						sendMediaEvent(MediaEvent.JWPLAYER_MEDIA_BUFFER_FULL);
					}
					break;
			}
			sendMediaEvent(MediaEvent.JWPLAYER_MEDIA_META, {metadata: evt.info});
		}


		/** Destroy the _stream. **/
		override public function stop():void {
			if (_stream && _stream.time) {
				_stream.close();
			}
			_connection.close();
			_started = false;
			clearInterval(_positionInterval);
			_positionInterval = undefined;
			super.stop();
			if (_smil) {
				item.file = _smil;
			}
		}


		/** Get the streamlength returned from the _connection. **/
		private function streamlengthHandler(len:Number):void {
			if (len > 0) {
				onData({type: 'streamlength', duration: len});
			}
		}


		/** Set the volume level. **/
		override public function setVolume(vol:Number):void {
			_transformer.volume = vol / 100;
			if (_stream) {
				try {
					_stream.soundTransform = _transformer;
					super.setVolume(vol);
				} catch (err:Error) {

				}
			}
		}
	}
}