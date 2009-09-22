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
		protected var interval:Number;
		/** Interval for loading progress. **/
		private var loadinterval:uint;
		
		
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
			clearInterval(interval);
			setState(PlayerState.IDLE);
			sendMediaEvent(MediaEvent.JWPLAYER_MEDIA_COMPLETE);
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
			sound.load(new URLRequest(_item.file), context);
			play();
			if (_item.start > 0) {
				seek(_item.start);
			}
			loadinterval = setInterval(loadHandler, 200);
			_config.mute == true ? setVolume(0) : setVolume(_config.volume);
			setState(PlayerState.BUFFERING);
			sendMediaEvent(MediaEvent.JWPLAYER_MEDIA_BUFFER, {percentage: 0});
		}
		
		
		/** Interval for the loading progress **/
		private function loadHandler():void {
			var ldd:uint = sound.bytesLoaded;
			var ttl:int = sound.bytesTotal;
			sendMediaEvent(MediaEvent.JWPLAYER_MEDIA_LOADED, {loaded: ldd, total: ttl});
			if (ldd / ttl > 0.1 && _item.duration == 0) {
				sendMediaEvent(MediaEvent.JWPLAYER_MEDIA_META, {duration: sound.length / 1000 / ldd * ttl});
			}
			if (ldd == ttl && ldd > 0) {
				clearInterval(loadinterval);
			}
		}
		
		
		/** Pause the sound. **/
		override public function pause():void {
			channel.stop();
			clearInterval(interval);
			super.pause();
		}
		
		
		/** Play the sound. **/
		override public function play():void {
			channel = sound.play(_position * 1000, 0, transformer);
			channel.addEventListener(Event.SOUND_COMPLETE, completeHandler);
			interval = setInterval(positionInterval, 100);
			super.play();
		}
		
		
		/** Interval for the _position progress **/
		protected function positionInterval():void {
			_position = Math.round(channel.position / 100) / 10;
			if (sound.isBuffering == true && sound.bytesTotal > sound.bytesLoaded) {
				if (_config.state != PlayerState.BUFFERING) {
					setState(PlayerState.BUFFERING);
				} else {
					var pct:Number = Math.floor(sound.length / (channel.position + _config.bufferlength * 1000) * 100);
					sendMediaEvent(MediaEvent.JWPLAYER_MEDIA_BUFFER, {percentage: pct});
				}
			} else if (_config.state == PlayerState.BUFFERING && sound.isBuffering == false) {
				super.play();
			}
			if (_position < _item.duration) {
				sendMediaEvent(MediaEvent.JWPLAYER_MEDIA_TIME, {_position: _position, duration: _item.duration});
			} else if (_item.duration > 0) {
				pause();
				setState(PlayerState.IDLE);
				sendMediaEvent(MediaEvent.JWPLAYER_MEDIA_COMPLETE);
			}
		}
		
		
		/** Seek in the sound. **/
		override public function seek(pos:Number):void {
			_position = pos;
			clearInterval(interval);
			channel.stop();
			play();
		}
		
		
		/** Destroy the sound. **/
		override public function stop():void {
			if (channel) {
				channel.stop();
			}
			try {
				sound.close();
			} catch (err:Error) {
			}
			clearInterval(loadinterval);
			clearInterval(interval);
			super.stop();
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
