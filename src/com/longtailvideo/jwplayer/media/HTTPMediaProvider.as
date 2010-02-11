/**
 * Manages playback of http streaming flv.
 **/
package com.longtailvideo.jwplayer.media {
	import com.longtailvideo.jwplayer.events.MediaEvent;
	import com.longtailvideo.jwplayer.model.PlayerConfig;
	import com.longtailvideo.jwplayer.model.PlaylistItem;
	import com.longtailvideo.jwplayer.player.PlayerState;
	import com.longtailvideo.jwplayer.utils.NetClient;
	
	import flash.events.*;
	import flash.media.*;
	import flash.net.*;
	import flash.utils.*;


	public class HTTPMediaProvider extends MediaProvider {
		/** NetConnection object for setup of the video stream. **/
		protected var _connection:NetConnection;
		/** NetStream instance that handles the stream IO. **/
		protected var _stream:NetStream;
		/** Video object to be instantiated. **/
		protected var _video:Video;
		/** Sound control object. **/
		protected var _transformer:SoundTransform;
		/** ID for the _position interval. **/
		protected var _positionInterval:uint;
		/** Save whether metadata has already been sent. **/
		protected var _meta:Boolean;
		/** Object with keyframe times and positions. **/
		protected var _keyframes:Object;
		/** Offset in bytes of the last seek. **/
		protected var _byteoffset:Number = 0;
		/** Offset in seconds of the last seek. **/
		protected var _timeoffset:Number = 0;
		/** Boolean for mp4 / flv streaming. **/
		protected var _mp4:Boolean;
		/** Variable that takes reloading into account. **/
		protected var _iterator:Number;
		/** Start parameter. **/
		private var _startparam:String = 'start';
		/** Whether the buffer has filled **/
		private var _bufferFull:Boolean;
		/** Whether the enitre video has been buffered **/
		private var _bufferingComplete:Boolean;
		/** Whether we have checked the bandwidth. **/
		private var _bandwidthSwitch:Boolean = true;
		/** Whether we have checked bandwidth **/
		private var _bandwidthChecked:Boolean;
		/** Bandwidth check delay **/
		private var _bandwidthTimeout:Number = 2000;
		
		/** Constructor; sets up the connection and display. **/
		public function HTTPMediaProvider() {
			super('http');
		}


		public override function initializeMediaProvider(cfg:PlayerConfig):void {
			super.initializeMediaProvider(cfg);
			_connection = new NetConnection();
			_connection.connect(null);
			_stream = new NetStream(_connection);
			_stream.checkPolicyFile = true;
			_stream.addEventListener(NetStatusEvent.NET_STATUS, statusHandler);
			_stream.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			_stream.addEventListener(AsyncErrorEvent.ASYNC_ERROR, errorHandler);
			_stream.bufferTime = config.bufferlength;
			_stream.client = new NetClient(this);
			_transformer = new SoundTransform();
			_video = new Video(320, 240);
			_video.smoothing = config.smoothing;
			_video.attachNetStream(_stream);
		}


		/** Convert seekpoints to keyframes. **/
		protected function convertSeekpoints(dat:Object):Object {
			var kfr:Object = new Object();
			kfr.times = new Array();
			kfr.filepositions = new Array();
			for (var j:String in dat) {
				kfr.times[j] = Number(dat[j]['time']);
				kfr.filepositions[j] = Number(dat[j]['offset']);
			}
			return kfr;
		}

		/** Catch security errors. **/
		protected function errorHandler(evt:ErrorEvent):void {
			error(evt.text);
		}

		/** Bandwidth is checked as long the stream hasn't completed loading. **/
		private function checkBandwidth(lastLoaded:Number):void {
			var currentLoaded:Number = _stream.bytesLoaded;
			var bandwidth:Number = Math.ceil((currentLoaded - lastLoaded) / 1024) * 8 / (_bandwidthTimeout / 1000);
			
			if (currentLoaded < _stream.bytesTotal) {
				if (bandwidth > 0) {
					config.bandwidth = bandwidth;
					var obj:Object = {bandwidth:bandwidth};
					if (item.duration > 0) {
						obj.bitrate = Math.ceil(_stream.bytesTotal / 1024 * 8 / item.duration);
					}
					sendMediaEvent(MediaEvent.JWPLAYER_MEDIA_META, {metadata: obj});
				}
				if (_bandwidthSwitch) {
					_bandwidthSwitch = false;
					if (item.currentLevel != item.getLevel(config.bandwidth, config.width)) {
						load(item);
						return;
					}
				}
				setTimeout(checkBandwidth, _bandwidthTimeout, currentLoaded);
			}
		}
		
		/** Return a keyframe byteoffset or timeoffset. **/
		protected function getOffset(pos:Number, tme:Boolean=false):Number {
			if (!_keyframes) {
				return 0;
			}
			for (var i:Number = 0; i < _keyframes.times.length - 1; i++) {
				if (_keyframes.times[i] <= pos && _keyframes.times[i + 1] >= pos) {
					break;
				}
			}
			if (tme == true) {
				return _keyframes.times[i];
			} else {
				return _keyframes.filepositions[i];
			}
		}


		/** Create the video request URL. **/
		protected function getURL():String {
			var url:String = item.file;
			var off:Number = _byteoffset;
			if (getConfigProperty('startparam') as String) {
				_startparam = getConfigProperty('startparam');
			}
			if (item.streamer) {
				if (item.streamer.indexOf('/') > 0) {
					url = item.streamer;
					url = getURLConcat(url, 'file', item.file);
				} else {
					_startparam = item.streamer;
				}
			}
			if (_mp4 || _startparam == 'starttime') {
				off = _timeoffset;
			}
			if (!_mp4 || off > 0) {
				url = getURLConcat(url, _startparam, off);
			}
			if (config['token'] || item['token']) {
				url = getURLConcat(url, 'token', item['token'] ? item['token'] : config['token']);
			}
			return url;
		}


		/** Concatenate a parameter to the url. **/
		private function getURLConcat(url:String, prm:String, val:*):String {
			if (url.indexOf('?') > -1) {
				return url + '&' + prm + '=' + val;
			} else {
				return url + '?' + prm + '=' + val;
			}
		}


		/** Load content. **/
		override public function load(itm:PlaylistItem):void {
			_item = itm;
			_position = _timeoffset;
			_bufferFull = false;
			_bufferingComplete = false;
			_bandwidthChecked = false;
			_bandwidthSwitch = true;
			
			if (item.levels.length > 0) { item.setLevel(item.getLevel(config.bandwidth, config.width)); }
			
			if (_stream.bytesLoaded + _byteoffset < _stream.bytesTotal) {
				_stream.close();
			}
			media = _video;
			_stream.play(getURL());
			
			clearInterval(_positionInterval);
			_positionInterval = setInterval(positionInterval, 100);
			
			setState(PlayerState.BUFFERING);
			sendBufferEvent(0, 0);
			sendMediaEvent(MediaEvent.JWPLAYER_MEDIA_LOADED);
			streamVolume(config.mute ? 0 : config.volume);
		}

		/** Get metadata information from netstream class. **/
		public function onClientData(dat:Object):void {
			if (dat.width) {
				_video.width = dat.width;
				_video.height = dat.height;
				resize(_width, _height);
			}
			if (dat['duration'] && item.duration <= 0) {
				item.duration = dat['duration'];
			}
			if (dat['type'] == 'metadata' && !_meta) {
				_meta = true;
				if (dat['seekpoints']) {
					_mp4 = true;
					_keyframes = convertSeekpoints(dat['seekpoints']);
				} else {
					_mp4 = false;
					_keyframes = dat['keyframes'];
				}
				if (item.start > 0) {
					seek(item.start);
				}
			}
			sendMediaEvent(MediaEvent.JWPLAYER_MEDIA_META, {metadata: dat});
		}


		/** Pause playback. **/
		override public function pause():void {
			_stream.pause();
			super.pause();
		}


		/** Resume playing. **/
		override public function play():void {
			_stream.resume();
			if (!_positionInterval) {
				_positionInterval = setInterval(positionInterval, 100);
			}
			super.play();
		}


		/** Interval for the position progress **/
		protected function positionInterval():void {
			_position = Math.round(_stream.time * 10) / 10;
			var percentoffset:Number;
			if (_mp4) {
				_position += _timeoffset;
			}
			
			var bufferPercent:Number;
			var bufferFill:Number;
			if (item.duration > 0) {
				percentoffset =  Math.round(_timeoffset /  item.duration * 100);
				bufferPercent = (_stream.bytesLoaded / _stream.bytesTotal) * (1 - _timeoffset / item.duration) * 100;
				var bufferTime:Number = _stream.bufferTime < (item.duration - position) ? _stream.bufferTime : Math.round(item.duration - position);
				bufferFill = _stream.bufferTime == 0 ? 0 : Math.ceil(_stream.bufferLength / bufferTime * 100);
			} else {
				percentoffset = 0;
				bufferPercent = 0;
				bufferFill = _stream.bufferLength/_stream.bufferTime * 100;
			}
	
			if (!_bandwidthChecked && _stream.bytesLoaded > 0 && _stream.bytesLoaded < _stream.bytesTotal) {
				_bandwidthChecked = true;
				setTimeout(checkBandwidth, _bandwidthTimeout, _stream.bytesLoaded);
			}
			
			if (bufferFill < 25 && state == PlayerState.PLAYING) {
				_bufferFull = false;
				_stream.pause();
				setState(PlayerState.BUFFERING);
			} else if (bufferFill > 95 && state == PlayerState.BUFFERING && _bufferFull == false) {
				_bufferFull = true;
				sendMediaEvent(MediaEvent.JWPLAYER_MEDIA_BUFFER_FULL);
			}

			if (!_bufferingComplete) {
				if ((bufferPercent + percentoffset) == 100 && _bufferingComplete == false) {
					_bufferingComplete = true;
				}
				sendBufferEvent(bufferPercent, _timeoffset);
			}
			
			if (state != PlayerState.PLAYING) {
				return;
			}
				
			if (_position < item.duration) {
				if (_position >= 0) {
					sendMediaEvent(MediaEvent.JWPLAYER_MEDIA_TIME, {position: _position, duration: item.duration, offset: _timeoffset});
				}
			} else if (item.duration > 0) {
				// Playback completed
				complete();
			}
		}

		/** Handle a resize event **/
		override public function resize(width:Number, height:Number):void {
			super.resize(width, height);
			if (item.levels.length > 0 && item.getLevel(config.bandwidth, config.width) != item.currentLevel) {
				_byteoffset = getOffset(position);
				_timeoffset = _position = getOffset(position,true);
				load(item);
			}
		}

		/** Seek to a specific second. **/
		override public function seek(pos:Number):void {
			var off:Number = getOffset(pos);
			super.seek(pos);
			clearInterval(_positionInterval);
			_positionInterval = undefined;
			if (off < _byteoffset || off >= _byteoffset + _stream.bytesLoaded) {
				_timeoffset = _position = getOffset(pos, true);
				_byteoffset = off;
				load(item);
			} else {
				if (state == PlayerState.PAUSED) {
					_stream.resume();
				}
				if (_mp4) {
					_stream.seek(getOffset(_position - _timeoffset, true));
				} else {
					_stream.seek(getOffset(_position, true));
				}
				play();
			}
		}


		/** Receive NetStream status updates. **/
		protected function statusHandler(evt:NetStatusEvent):void {
			switch (evt.info.code) {
				case "NetStream.Play.Stop":
					if (state != PlayerState.BUFFERING) {
						complete();
					}
					break;
				case "NetStream.Play.StreamNotFound":
					stop();
					error('Video not found: ' + item.file);
					break;
				case 'NetStream.Buffer.Full':
					if (!_bufferFull) {
						_bufferFull = true;
						sendMediaEvent(MediaEvent.JWPLAYER_MEDIA_BUFFER_FULL);
					}
					break;
			}
			sendMediaEvent(MediaEvent.JWPLAYER_MEDIA_META, {metadata: {status: evt.info.code}});
		}


		/** Destroy the HTTP stream. **/
		override public function stop():void {
			if (_stream.bytesLoaded + _byteoffset < _stream.bytesTotal) {
				_stream.close();
			} else {
				_stream.pause();
			}
			clearInterval(_positionInterval);
			_positionInterval = undefined;
			_position = _byteoffset = _timeoffset = 0;
			_keyframes = undefined;
			_meta = false;
			super.stop();
		}


		/** Set the volume level. **/
		override public function setVolume(vol:Number):void {
			streamVolume(vol);
			super.setVolume(vol);
		}

		/** Set the stream's volume, without sending a volume event **/
		protected function streamVolume(level:Number):void {
			_transformer.volume = level / 100;
			if (_stream) {
				_stream.soundTransform = _transformer;
			}
		}

	}
}