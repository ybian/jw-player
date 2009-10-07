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
		protected var connection:NetConnection;
		/** NetStream instance that handles the stream IO. **/
		protected var stream:NetStream;
		/** Video object to be instantiated. **/
		protected var video:Video;
		/** Sound control object. **/
		protected var transformer:SoundTransform;
		/** ID for the position interval. **/
		protected var interval:Number;
		/** Interval ID for the loading. **/
		protected var loadinterval:Number;
		/** Save whether metadata has already been sent. **/
		protected var meta:Boolean;
		/** Object with keyframe times and positions. **/
		protected var keyframes:Object;
		/** Offset in bytes of the last seek. **/
		protected var byteoffset:Number;
		/** Offset in seconds of the last seek. **/
		protected var timeoffset:Number;
		/** Boolean for mp4 / flv streaming. **/
		protected var mp4:Boolean;
		/** Load offset for bandwidth checking. **/
		protected var loadtimer:Number;
		/** Variable that takes reloading into account. **/
		protected var iterator:Number;
		/** Start parameter. **/
		private var startparam:String = 'start';
		
		
		/** Constructor; sets up the connection and display. **/
		public function HTTPMediaProvider() {	
		}
		
		public override function initializeMediaProvider(cfg:PlayerConfig):void {
			super.initializeMediaProvider(cfg);
			_provider = 'http';
			connection = new NetConnection();
			connection.connect(null);
			stream = new NetStream(connection);
			stream.checkPolicyFile = true;
			stream.addEventListener(NetStatusEvent.NET_STATUS, statusHandler);
			stream.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			stream.addEventListener(AsyncErrorEvent.ASYNC_ERROR, errorHandler);
			stream.bufferTime = _config.bufferlength;
			stream.client = new NetClient(this);
			video = new Video(320, 240);
			video.smoothing = _config.smoothing;
			video.attachNetStream(stream);
			transformer = new SoundTransform();
			byteoffset = timeoffset = 0;
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
			stop();
			sendMediaEvent(MediaEvent.JWPLAYER_MEDIA_ERROR, {message: evt.text});
		}
		
		
		/** Return a keyframe byteoffset or timeoffset. **/
		protected function getOffset(pos:Number, tme:Boolean = false):Number {
			if (!keyframes) {
				return 0;
			}
			for (var i:Number = 0; i < keyframes.times.length - 1; i++) {
				if (keyframes.times[i] <= pos && keyframes.times[i + 1] >= pos) {
					break;
				}
			}
			if (tme == true) {
				return keyframes.times[i];
			} else {
				return keyframes.filepositions[i];
			}
		}
		
		
		/** Create the video request URL. **/
		protected function getURL():String {
			var url:String = item.streamer;
			var off:Number = byteoffset;
			if (getConfigProperty('startparam') as String) {
				startparam = getConfigProperty('startparam');
			}
			if (item['streamer']) {
				url = item['streamer'];
				url = getURLConcat(url, 'file', item['file']);
			}
			if (mp4) {
				off = timeoffset;
			} else if (startparam == 'starttime') {
				startparam = 'start';
			}
			if (off > 0) {
				url = getURLConcat(url, startparam, off);
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
			_position = timeoffset;
			if (stream.bytesLoaded + byteoffset < stream.bytesTotal) {
				stream.close();
			}
			media = video;
			stream.play(getURL());
			iterator = 0;
			clearInterval(interval);
			interval = setInterval(positionInterval, 100);
			clearInterval(loadinterval);
			loadinterval = setInterval(loadHandler, 200);
			sendMediaEvent(MediaEvent.JWPLAYER_MEDIA_LOADED);
			setState(PlayerState.BUFFERING);
			_config.mute == true ? setVolume(0) : setVolume(_config.volume);
			sendBufferEvent(0);
		}
		
		
		/** Interval for the loading progress **/
		protected function loadHandler():void {
			var ldd:Number = stream.bytesLoaded;
			var ttl:Number = stream.bytesTotal;
			var pct:Number = timeoffset / (item.duration + 0.001);
			var off:Number = Math.round(ttl * pct / (1 - pct));
			ttl += off;
			try {
				sendBufferEvent(Math.round(ldd / ttl * 100));
			} catch (err:Error) {
				sendMediaEvent(MediaEvent.JWPLAYER_MEDIA_ERROR, {message: err.getStackTrace()});
			}
			if (ldd + off >= ttl && ldd > 0) {
				clearInterval(loadinterval);
			}
			if (!loadtimer) {
				loadtimer = setTimeout(loadTimeout, 3000);
			}
		}
		
		
		/** timeout for checking the bitrate. **/
		protected function loadTimeout():void {
			var obj:Object = new Object();
			obj.bandwidth = Math.round(stream.bytesLoaded / 1024 / 3 * 8);
			if (item.duration) {
				obj.bitrate = Math.round(stream.bytesTotal / 1024 * 8 / item.duration);
			}
			sendMediaEvent(MediaEvent.JWPLAYER_MEDIA_META, {metadata: obj});
		}
		
		
		/** Get metadata information from netstream class. **/
		public function onData(dat:Object):void {
			if (dat.width) {
				video.width = dat.width;
				video.height = dat.height;
			}
			if (dat['type'] == 'metadata' && !meta) {
				meta = true;
				if (dat.seekpoints) {
					mp4 = true;
					keyframes = convertSeekpoints(dat.seekpoints);
				} else {
					mp4 = false;
					keyframes = dat.keyframes;
				}
				if (item.start > 0) {
					seek(item.start);
				}
			}
			sendMediaEvent(MediaEvent.JWPLAYER_MEDIA_META, {metadata: dat});
		}
		
		
		/** Pause playback. **/
		override public function pause():void {
			stream.pause();
			clearInterval(interval);
			super.pause();
		}
		
		
		/** Resume playing. **/
		override public function play():void {
			stream.resume();
			interval = setInterval(positionInterval, 100);
			super.play();
		}
		
		
		/** Interval for the position progress **/
		protected function positionInterval():void {
			iterator++;
			if (iterator > 10) {
				_position = Math.round(stream.time * 10) / 10;
				if (mp4) {
					_position += timeoffset;
				}
			}
			var bfr:Number = Math.round(stream.bufferLength / stream.bufferTime * 100);
			if (bfr < 95 && position < Math.abs(item.duration - stream.bufferTime - 1)) {
				stream.pause();
				if (state == PlayerState.PLAYING && bfr < 25) {
					setState(PlayerState.BUFFERING);
				}
				sendBufferEvent(bfr);
			} else if (bfr > 95 && state == PlayerState.BUFFERING) {
				super.play();
				stream.resume();
			}
			if (position < item.duration) {
				if (state == PlayerState.PLAYING && position >= 0) {
					sendMediaEvent(MediaEvent.JWPLAYER_MEDIA_TIME, {position: position, duration: item.duration});
				}
			} else if (item.duration > 0) {
				// Playback completed
				stream.pause();
				clearInterval(interval);
				setState(PlayerState.IDLE);
				sendMediaEvent(MediaEvent.JWPLAYER_MEDIA_COMPLETE);
			}
		}
		
		
		/** Seek to a specific second. **/
		override public function seek(pos:Number):void {
			var off:Number = getOffset(pos);
			super.seek(pos);
			clearInterval(interval);
			if (off < byteoffset || off >= byteoffset + stream.bytesLoaded) {
				timeoffset = _position = getOffset(pos, true);
				byteoffset = off;
				load(item);
			} else {
				if (state == PlayerState.PAUSED) {
					stream.resume();
				}
				_position = pos;
				if (mp4) {
					stream.seek(getOffset(position - timeoffset, true));
				} else {
					stream.seek(getOffset(position, true));
				}
				play();
			}
		}
		
		
		/** Receive NetStream status updates. **/
		protected function statusHandler(evt:NetStatusEvent):void {
			switch (evt.info.code) {
				case "NetStream.Play.Stop":
					if (state != PlayerState.BUFFERING) {
						clearInterval(interval);
						setState(PlayerState.IDLE);
						sendMediaEvent(MediaEvent.JWPLAYER_MEDIA_COMPLETE);
					}
					break;
				case "NetStream.Play.StreamNotFound":
					stop();
					sendMediaEvent(MediaEvent.JWPLAYER_MEDIA_ERROR, {message: 'Video not found: ' + item.file});
					break;
			}
			sendMediaEvent(MediaEvent.JWPLAYER_MEDIA_META, {metadata: {status: evt.info.code}});
		}
		
		
		/** Destroy the HTTP stream. **/
		override public function stop():void {
			if (stream.bytesLoaded + byteoffset < stream.bytesTotal) {
				stream.close();
			} else {
				stream.pause();
			}
			clearInterval(interval);
			clearInterval(loadinterval);
			byteoffset = timeoffset = 0;
			keyframes = undefined;
			meta = false;
			super.stop();
		}
		
		
		/** Set the volume level. **/
		override public function setVolume(vol:Number):void {
			transformer.volume = vol / 100;
			stream.soundTransform = transformer;
			super.setVolume(vol);
		}
	}
}