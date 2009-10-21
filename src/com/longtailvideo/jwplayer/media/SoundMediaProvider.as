/**
 * Wrapper for playback of mp3 sounds.
 **/
package com.longtailvideo.jwplayer.media {
	import com.jeroenwijering.events.*;
	import com.longtailvideo.jwplayer.events.MediaEvent;
	import com.longtailvideo.jwplayer.model.PlayerConfig;
	import com.longtailvideo.jwplayer.model.PlaylistItem;
	import com.longtailvideo.jwplayer.player.PlayerState;
	
	import flash.events.*;
	import flash.media.*;
	import flash.net.URLRequest;
	import flash.utils.*;
	
	
	public class SoundMediaProvider extends MediaProvider {
		/** sound object to be instantiated. **/
		private var sound:Sound;
		/** Sound control object. **/
		private var transformer:SoundTransform;
		/** Sound channel object. **/
		private var channel:SoundChannel;
		/** Sound context object. **/
		private var context:SoundLoaderContext;
		/** ID for the _position interval. **/
		protected var positionInterval:Number;
		
		
		/** Constructor; sets up the connection and display. **/
		public function SoundMediaProvider() {
		
		}
		
		public override function initializeMediaProvider(cfg:PlayerConfig):void {
			super.initializeMediaProvider(cfg);
			_provider = 'sound';
			transformer = new SoundTransform();
			context = new SoundLoaderContext(_config.bufferlength * 1000, true);
		}
		
		
		/** Sound completed; send event. **/
		private function completeHandler(evt:Event):void {
			complete();
		}
		
		
		/** Catch errors. **/
		private function errorHandler(evt:ErrorEvent):void {
			stop();
			sendMediaEvent(MediaEvent.JWPLAYER_MEDIA_ERROR, {message: evt.text});
		}
		
		
		/** Forward ID3 data from the sound. **/
		private function id3Handler(evt:Event):void {
			try {
				var id3:ID3Info = sound.id3;
				var obj:Object = {type: 'id3', album: id3.album, artist: id3.artist, comment: id3.comment, genre: id3.genre, name: id3.songName, track: id3.track, year: id3.year}
				sendMediaEvent(MediaEvent.JWPLAYER_MEDIA_META, obj);
			} catch (err:Error) {
			}
		}
		
		
		/** Load the sound. **/
		override public function load(itm:PlaylistItem):void {
			_item = itm;
			_position = 0;
			sound = new Sound();
			sound.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			sound.addEventListener(Event.ID3, id3Handler);
			sound.addEventListener(ProgressEvent.PROGRESS, positionHandler);
			sound.load(new URLRequest(_item.file), context);
			if (_item.start > 0) {
				seek(_item.start);
			}
			positionInterval = setInterval(positionHandler, 100);
			sendMediaEvent(MediaEvent.JWPLAYER_MEDIA_LOADED);
			_config.mute == true ? setVolume(0) : setVolume(_config.volume);
			setState(PlayerState.BUFFERING);
			sendBufferEvent(0);
		}
		
		
		/** Pause the sound. **/
		override public function pause():void {
			channel.stop();
			super.pause();
		}
		
		
		/** Play the sound. **/
		override public function play():void {
			if (!positionInterval) {
				positionInterval = setInterval(positionHandler, 100);
			}
			channel = sound.play(_position * 1000, 0, transformer);
			channel.addEventListener(Event.SOUND_COMPLETE, completeHandler);
			super.play();
		}
		
		
		/** Interval for the _position progress **/
		protected function positionHandler(progressEvent:ProgressEvent = null):void {
			var bufferPercent:Number;
			if (sound.bytesLoaded / sound.bytesTotal > 0.1 && _item.duration <= 0) {
				_item.duration = sound.length / 1000 / sound.bytesLoaded * sound.bytesTotal;
			}
			if (channel){
				_position = Math.round(channel.position / 100) / 10;
				bufferPercent = Math.floor(sound.bytesLoaded / sound.bytesTotal * 100);
			} else if (!channel && progressEvent) {
				bufferPercent = Math.floor(progressEvent.bytesLoaded / progressEvent.bytesTotal * 100);
			}
			if (sound.isBuffering == true && sound.bytesTotal > sound.bytesLoaded) {
				if (state != PlayerState.BUFFERING) {
					channel.stop();
					setState(PlayerState.BUFFERING);
				} else {
					sendMediaEvent(MediaEvent.JWPLAYER_MEDIA_BUFFER, {position: _position, duration: _item.duration, bufferPercent: bufferPercent});
				}
			} else if (state == PlayerState.BUFFERING && sound.isBuffering == false) {
				sendMediaEvent(MediaEvent.JWPLAYER_MEDIA_BUFFER_FULL);
			}
			if (_position < _item.duration) {
				sendMediaEvent(MediaEvent.JWPLAYER_MEDIA_TIME, {position: _position, duration: _item.duration, bufferPercent: bufferPercent});
			} else if (_item.duration > 0) {
				complete();
			}
		}
		
		private function complete():void {
			clearInterval(positionInterval);
			positionInterval = undefined;
			setState(PlayerState.IDLE);
			sendMediaEvent(MediaEvent.JWPLAYER_MEDIA_COMPLETE);
			_position = 0;
			channel.stop();
			channel = null;
		}
		
		
		/** Seek in the sound. **/
		override public function seek(pos:Number):void {
			clearInterval(positionInterval);
			positionInterval = undefined;
			_position = pos;
			channel.stop();
			play();
		}
		
		
		/** Destroy the sound. **/
		override public function stop():void {
			clearInterval(positionInterval);
			positionInterval = undefined;
			super.stop();
			if (channel) {
				channel.stop();
				channel = null;
			}
			try {
				sound.close();
			} catch (err:Error) {
			}
		}
		
		
		/** Set the volume level. **/
		override public function setVolume(vol:Number):void {
			transformer.volume = vol / 100;
			if (channel) {
				channel.soundTransform = transformer;
			}
		}
	}
}
