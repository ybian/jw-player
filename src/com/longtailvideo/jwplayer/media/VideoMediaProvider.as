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
	
	/**
	 * Wrapper for playback of progressively downloaded video.
	 **/
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
		protected var positionInterval:Number;
		/** Load offset for bandwidth checking. **/
		protected var loadTimer:Number;
		
		
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
			error(evt.text);
		}
		
		
		/** Load content. **/
		override public function load(itm:PlaylistItem):void {
			if (_item != itm || stream.bytesLoaded == 0) {
				_item = itm;
				media = video;
				stream.checkPolicyFile = true;
				stream.play(item.file);
			} else {
				seek(0);
			}
			positionInterval = setInterval(positionHandler, 200);
			loadTimer = setTimeout(loadTimerComplete, 3000);
			setState(PlayerState.BUFFERING);
			sendBufferEvent(0);
			sendMediaEvent(MediaEvent.JWPLAYER_MEDIA_LOADED);
			_config.mute == true ? setVolume(0) : setVolume(_config.volume);
		}
				
		
		/** timeout for checking the bitrate. **/
		protected function loadTimerComplete():void {
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
				resize(_width, _height);
			}
			if (dat.duration) {
				_item.duration = dat.duration;
			}
			sendMediaEvent(MediaEvent.JWPLAYER_MEDIA_META, {metadata: dat});
		}
		
		
		/** Pause playback. **/
		override public function pause():void {
			stream.pause();
			super.pause();
		}
		
		
		/** Resume playing. **/
		override public function play():void {
			if (!positionInterval) {
				positionInterval = setInterval(positionHandler, 100);
			}
			stream.resume();
			super.play();
		}
		
		
		/** Interval for the position progress **/
		protected function positionHandler():void {
			if (state == PlayerState.PLAYING) {
				position = Math.round(stream.time * 10) / 10;
			}
			var bufferPercent:Number = stream.bytesTotal == 0 ? 0 : Math.round(stream.bytesLoaded / stream.bytesTotal * 100);
			var bufferFill:Number = stream.bufferTime == 0 ? 0 : Math.round(stream.bufferLength / stream.bufferTime * 100);
			if (bufferFill < 95 && position < Math.abs(item.duration - stream.bufferTime - 1)) {
				if (state == PlayerState.PLAYING && bufferFill < 25) {
					stream.pause();
					setState(PlayerState.BUFFERING);
				}
				sendBufferEvent(bufferPercent);
			} else if (bufferFill > 95 && state == PlayerState.BUFFERING) {
				sendMediaEvent(MediaEvent.JWPLAYER_MEDIA_BUFFER_FULL);
				return;
			}
			
			if (state == PlayerState.BUFFERING){
				sendMediaEvent(MediaEvent.JWPLAYER_MEDIA_BUFFER, {bufferPercent:bufferPercent});
			} else if (position < item.duration) {
				if (state == PlayerState.PLAYING && position >= 0) {
					sendMediaEvent(MediaEvent.JWPLAYER_MEDIA_TIME, {position: position, duration: item.duration, bufferPercent:bufferPercent});
				}
			} else if (item.duration > 0) {
				complete();
			}
		}
		
		
		/** Seek to a new position. **/
		override public function seek(pos:Number):void {
			var bufferTime:Number = (stream.bytesLoaded / stream.bytesTotal) * item.duration;
			if ( pos <= bufferTime ) {
				super.seek(pos);
				clearInterval(positionInterval);
				positionInterval = undefined;
				stream.seek(position);
				play();
			}
		}
		
		
		/** Receive NetStream status updates. **/
		protected function statusHandler(evt:NetStatusEvent):void {
			switch (evt.info.code) {
				case "NetStream.Play.Stop":
					complete();
					break;
				case "NetStream.Play.StreamNotFound":
					error('Video not found or access denied: ' + item.file);
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
				stream.seek(0);
			}
			loadTimer = undefined;
			clearInterval(positionInterval);
			positionInterval = undefined;
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
