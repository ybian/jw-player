/**
 * Model for playback of GIF/JPG/PNG images.
 **/
package com.longtailvideo.jwplayer.media {
	import com.jeroenwijering.events.*;
	import com.longtailvideo.jwplayer.events.MediaEvent;
	import com.longtailvideo.jwplayer.model.PlayerConfig;
	import com.longtailvideo.jwplayer.model.PlaylistItem;
	import com.longtailvideo.jwplayer.player.PlayerState;
	
	import flash.display.*;
	import flash.events.*;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	import flash.utils.*;
	
	
	public class ImageMediaProvider extends MediaProvider {
		/** Loader that loads the image. **/
		private var loader:Loader;
		/** ID for the _position interval. **/
		private var interval:Number;
		
		
		/** Constructor; sets up listeners **/
		public function ImageMediaProvider() {
		}

		public override function initializeMediaProvider(cfg:PlayerConfig):void {
			super.initializeMediaProvider(cfg);
			_provider = 'image';
			loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loaderHandler);
			loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, progressHandler);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
		}
		
		
		/** load image into screen **/
		override public function load(itm:PlaylistItem):void {
			_item = itm;
			_position = 0;
			loader.load(new URLRequest(_item.file), new LoaderContext(true));
			setState(PlayerState.BUFFERING);
			sendMediaEvent(MediaEvent.JWPLAYER_MEDIA_BUFFER, {bufferPercent: 0});
		}
		
		
		/** Catch errors. **/
		private function errorHandler(evt:ErrorEvent):void {
			stop();
			sendMediaEvent(MediaEvent.JWPLAYER_MEDIA_ERROR, {message: evt.text});
		}
		
		
		/** Load and place the image on stage. **/
		private function loaderHandler(evt:Event):void {
			media = loader;
			try {
				Bitmap(loader.content).smoothing = true;
			} catch (err:Error) {
			}
			sendMediaEvent(MediaEvent.JWPLAYER_MEDIA_LOADED);
			sendMediaEvent(MediaEvent.JWPLAYER_MEDIA_META, {metadata: {height: evt.target.height, width: evt.target.width}});
			play();
		}
		
		
		/** Pause playback of the_item. **/
		override public function pause():void {
			clearInterval(interval);
			super.pause();
		}
		
		
		/** Resume playback of the_item. **/
		override public function play():void {
			super.play();
			interval = setInterval(positionInterval, 100);
		}
		
		
		/** Interval function that pings the _position. **/
		protected function positionInterval():void {
			_position = Math.round(_position * 10 + 1) / 10;
			if (_position < _item.duration) {
				sendMediaEvent(MediaEvent.JWPLAYER_MEDIA_TIME, {position: _position, duration: _item.duration});
			} else if (_item.duration > 0) {
				pause();
				setState(PlayerState.IDLE);
				sendMediaEvent(MediaEvent.JWPLAYER_MEDIA_COMPLETE);
			}
		}
		
		
		/** Send load progress to player. **/
		private function progressHandler(evt:ProgressEvent):void {
			var pct:Number = Math.round(evt.bytesLoaded / evt.bytesTotal * 100);
			sendMediaEvent(MediaEvent.JWPLAYER_MEDIA_BUFFER, {bufferPercent: pct});
		}
		
		
		/** Seek to a certain _position in the_item. **/
		override public function seek(pos:Number):void {
			clearInterval(interval);
			_position = pos;
			play();
		}
		
		
		/** Stop the image interval. **/
		override public function stop():void {
			if (loader.contentLoaderInfo.bytesLoaded != loader.contentLoaderInfo.bytesTotal) {
				loader.close();
			} else {
				loader.unload();
			}
			clearInterval(interval);
			super.stop();
		}
	}
}