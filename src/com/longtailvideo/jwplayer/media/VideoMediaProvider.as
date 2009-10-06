/**
 * Wrapper for playback of progressively downloaded video.
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
	
	
	public class VideoMediaProvider extends MediaProvider {
		/** Video object to be instantiated. **/
		protected var video:Video;
		/** NetConnection object for setup of the video stream. **/
		protected var connection:NetConnection;
		/** NetStream instance that handles the stream IO. **/
		protected var stream:NetStream;
		/** Sound control object. **/
		protected var transformer:SoundTransform;
		/** ID for the position interval. **/
		protected var interval:Number;
		/** Interval ID for the loading. **/
		protected var loadinterval:Number;
		/** Load offset for bandwidth checking. **/
		protected var loadtimer:Number;
		
		
		/** Constructor; sets up the connection and display. **/
		public function VideoMediaProvider() {
		}
		
		public override function initializeMediaProvider(cfg:PlayerConfig):void {
			super.initializeMediaProvider(cfg);
			_provider = 'video';
			connection = new NetConnection();
			connection.connect(null);
			stream = new NetStream(connection);
			stream.addEventListener(NetStatusEvent.NET_STATUS, statusHandler);
			stream.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			stream.addEventListener(AsyncErrorEvent.ASYNC_ERROR, errorHandler);
			stream.bufferTime = _config.bufferlength;
			stream.client = new NetClient(this);
			video = new Video(320, 240);
			video.smoothing = _config.smoothing;
			video.attachNetStream(stream);
			transformer = new SoundTransform();
		}
		
		
		/** Catch security errors. **/
		protected function errorHandler(evt:ErrorEvent):void {
			stop();
			sendMediaEvent(MediaEvent.JWPLAYER_MEDIA_ERROR, {message: evt.text});
		}
		
		
		/** Load content. **/
		override public function load(itm:PlaylistItem):void {
			_item = itm;
			_media = video;
			stream.checkPolicyFile = true;
			stream.play(item.file);
			//stream.pause();
			interval = setInterval(positionInterval, 100);
			loadinterval = setInterval(loadHandler, 200);
			// TODO: Moved up load event
			sendMediaEvent(MediaEvent.JWPLAYER_MEDIA_LOADED);
			_config.mute == true ? setVolume(0) : setVolume(_config.volume);
			setState(PlayerState.BUFFERING);
			sendBufferEvent(0);
		}
		
		
		/** Interval for the loading progress **/
		protected function loadHandler():void {
			var ldd:Number = stream.bytesLoaded;
			var ttl:Number = stream.bytesTotal;
			try {
				sendBufferEvent(Math.round(ldd / ttl * 100));
			} catch (err:Error) {
				sendMediaEvent(MediaEvent.JWPLAYER_MEDIA_ERROR, {message: err.getStackTrace()});
			}
			if (ldd == ttl && ldd > 0) {
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
			if (dat.duration) {
				_item.duration = dat.duration;
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
			_position = Math.round(stream.time * 10) / 10;
			var bfr:Number = Math.round(stream.bufferLength / stream.bufferTime * 100);
			if (bfr < 95 && position < Math.abs(item.duration - stream.bufferTime - 1)) {
				if (state == PlayerState.PLAYING && bfr < 25) {
					setState(PlayerState.BUFFERING);
				}
				sendBufferEvent(bfr);
			} else if (bfr > 95 && state == PlayerState.BUFFERING) {
				super.play();
			}

			if (position < item.duration) {
				if (state == PlayerState.PLAYING && position >= 0) {
					sendMediaEvent(MediaEvent.JWPLAYER_MEDIA_TIME, {position: position, duration: item.duration});
				}
			} else if (item.duration > 0) {
				stream.pause();
				clearInterval(interval);
				setState(PlayerState.IDLE);
				sendMediaEvent(MediaEvent.JWPLAYER_MEDIA_COMPLETE);
			}
		}

		protected function bufferUnderrun(bufferPercent:Number):Boolean {
			return (state == PlayerState.PLAYING && bufferPercent < 25 && (bufferPercent < 95 && position < Math.abs(item.duration - stream.bufferTime - 1)));
		}
		
		protected function bufferFull(bufferPercent:Number):Boolean {
			return (bufferPercent > 95 && state == PlayerState.BUFFERING);
		}
		
		
		/** Seek to a new position. **/
		override public function seek(pos:Number):void {
			super.seek(pos);
			clearInterval(interval);
			stream.seek(position);
			play();
		}
		
		
		/** Receive NetStream status updates. **/
		protected function statusHandler(evt:NetStatusEvent):void {
			switch (evt.info.code) {
				case "NetStream.Play.Stop":
					if (position > 1) {
						clearInterval(interval);
						setState(PlayerState.IDLE);
						sendMediaEvent(MediaEvent.JWPLAYER_MEDIA_COMPLETE);
					}
					break;
				case "NetStream.Play.StreamNotFound":
					stop();
					sendMediaEvent(MediaEvent.JWPLAYER_MEDIA_ERROR, {message: 'Video not found or access denied: ' + item.file});
					break;
			}
			sendMediaEvent(MediaEvent.JWPLAYER_MEDIA_META, {metadata: {status: evt.info.code}});
		}
		
		
		/** Destroy the video. **/
		override public function stop():void {
			if (stream.bytesLoaded < stream.bytesTotal) {
				stream.close();
			} else {
				stream.pause();
			}
			loadtimer = undefined;
			clearInterval(loadinterval);
			clearInterval(interval);
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
