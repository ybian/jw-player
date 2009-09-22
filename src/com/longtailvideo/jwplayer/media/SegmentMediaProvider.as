/**
 * Model that concatenates segmented streams into a single file.
 **/
package com.longtailvideo.jwplayer.media {
	import com.jeroenwijering.events.*;
	import com.longtailvideo.jwplayer.events.MediaEvent;
	import com.longtailvideo.jwplayer.model.PlayerConfig;
	import com.longtailvideo.jwplayer.model.PlaylistItem;
	import com.longtailvideo.jwplayer.utils.NetClient;
	import flash.events.*;
	import flash.media.*;
	import flash.net.*;
	import flash.utils.*;
	
	
	public class SegmentMediaProvider extends MediaProvider {
		/** Video object to be instantiated. **/
		protected var video:Video;
		/** NetConnection object for setup of the video stream. **/
		protected var connection:NetConnection;
		/** NetStream instance that handles the stream IO. **/
		protected var stream:NetStream;
		/** Sound control object. **/
		protected var transform:SoundTransform;
		/** ID for the _position interval. **/
		protected var interval:Number;
		/** Segmentation length in seconds. **/
		protected var increment:Number = 10;
		/** Currently playing segment. **/
		protected var segment:Number;
		
		
		/** Constructor; sets up the connection and display. **/
		public function SegmentMediaProvider():void {
		}
		
		public override function initializeMediaProvider(cfg:PlayerConfig, provider:String):void {
			super(cfg);
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
			transform = new SoundTransform();
		}
		
		
		/** Catch security errors. **/
		protected function errorHandler(evt:ErrorEvent):void {
			stop();
			sendMediaEvent(MediaEvent.JWPLAYER_MEDIA_ERROR, {message: evt.text});
		}
		
		
		/** Load content. **/
		override public function load(itm:PlaylistItem):void {
			_item = itm;
			_position = 0;
			_media = video;
			stream.checkPolicyFile = true;
			queue();
			interval = setInterval(positionInterval, 100);
			_config.mute == true ? setVolume(0) : setVolume(_config.volume);
			sendMediaEvent(MediaEvent.JWPLAYER_MEDIA_BUFFER, {percentage: 0});
			setState(PlayerState.BUFFERING);
		}
		
		
		/** Get metadata information from netstream class. **/
		public function onData(dat:Object):void {
			if (dat.width) {
				video.width = dat.width;
				video.height = dat.height;
			}
			sendMediaEvent(MediaEvent.JWPLAYER_MEDIA_META, dat);
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
		
		
		/** Interval for the _position progress **/
		protected function positionInterval():void {
			if (stream.time < increment) {
				_position = segment * increment + Math.round(stream.time * 10) / 10;
			}
			var bfr:Number = Math.round(stream.bufferLength / stream.bufferTime * 100);
			if (bfr > 95 && _config.state != PlayerState.PLAYING) {
				super.play();
			}
			if (_position < _item.duration) {
				sendMediaEvent(MediaEvent.JWPLAYER_MEDIA_TIME, {_position: _position, duration: _item.duration, segment: segment});
			} else if (_item.duration > 0) {
				stream.pause();
				clearInterval(interval);
				setState(PlayerState.COMPLETED);
			}
		}
		
		
		/** Seek to a new _position. **/
		override public function seek(pos:Number):void {
			_position = pos;
			clearInterval(interval);
			queue();
			interval = setInterval(positionInterval, 100);
			setState(PlayerState.BUFFERING);
		}
		
		
		/** Receive NetStream status updates. **/
		protected function statusHandler(evt:NetStatusEvent):void {
			switch (evt.info.code) {
				case "NetStream.Play.Stop":
					if (_position > _item.duration - increment / 2) {
						clearInterval(interval);
						setState(PlayerState.COMPLETED);
					} else {
						queue();
					}
					break;
				case "NetStream.Play.StreamNotFound":
					stop();
					sendMediaEvent(MediaEvent.JWPLAYER_MEDIA_ERROR, {message: 'Video not found or access denied: ' + _item.file});
					break;
			}
			sendMediaEvent(MediaEvent.JWPLAYER_MEDIA_META, {status: evt.info.code});
		}
		
		
		/** Queue the next segment for playback based upon the current _position. **/
		protected function queue():void {
			segment = Math.round(_position / increment);
			var stt:Number = segment * increment;
			var end:Number = (segment + 1) * increment;
			stream.play(_item.file + '?start=' + stt + '&end=' + end);
		}
		
		
		/** Destroy the video. **/
		override public function stop():void {
			if (stream.bytesLoaded < stream.bytesTotal) {
				stream.close();
			} else {
				stream.pause();
			}
			clearInterval(interval);
			super.stop();
		}
		
		
		/** Set the volume level. **/
		override public function setVolume(vol:Number):void {
			transform.volume = vol / 100;
			stream.soundTransform = transform;
		}
	}
}