/**
 * Wrapper for load and playback of Youtube videos through their API.
 **/
package com.longtailvideo.jwplayer.media {
	import com.jeroenwijering.events.*;
	import com.longtailvideo.jwplayer.events.MediaEvent;
	import com.longtailvideo.jwplayer.model.PlayerConfig;
	import com.longtailvideo.jwplayer.model.PlaylistItem;
	import com.longtailvideo.jwplayer.player.PlayerState;
	import com.longtailvideo.jwplayer.utils.RootReference;
	import flash.display.Loader;
	import flash.events.*;
	import flash.net.LocalConnection;
	import flash.net.URLRequest;
	import flash.system.Security;
	
	
	public class YouTubeMediaProvider extends MediaProvider {
		/** Loader for loading the YouTube proxy **/
		private var loader:Loader;
		/** 'Unique' string to use for proxy connection. **/
		private var unique:String;
		/** Connection towards the YT proxy. **/
		private var outgoing:LocalConnection;
		/** connection from the YT proxy. **/
		private var inbound:LocalConnection;
		/** Save that the meta has been sent. **/
		private var metasent:Boolean;
		/** Save that a load call has been sent. **/
		private var loading:Boolean;
		/** Save the connection state. **/
		private var connected:Boolean;
		/** URL of a custom youtube swf. **/
		private var location:String;
		
		
		/** Setup YouTube connections and load proxy. **/
		public function YouTubeMediaProvider(){
		}
		
		public override function initializeMediaProvider(cfg:PlayerConfig):void {
			super.initializeMediaProvider(cfg);
			_provider = 'youtube';
			Security.allowDomain('*');
			var url:String = RootReference.root.loaderInfo.url;
			if (url.indexOf('http://') == 0) {
				unique = Math.random().toString().substr(2);
				var str:String = url.substr(0, url.indexOf('.swf'));
				location = str.substr(0, str.lastIndexOf('/') + 1) + 'yt.swf?unique=' + unique;
			} else {
				unique = '1';
				location = 'yt.swf';
			}
			outgoing = new LocalConnection();
			outgoing.allowDomain('*');
			outgoing.allowInsecureDomain('*');
			outgoing.addEventListener(StatusEvent.STATUS, onLocalConnectionStatusChange);
			inbound = new LocalConnection();
			inbound.allowDomain('*');
			inbound.allowInsecureDomain('*');
			inbound.addEventListener(StatusEvent.STATUS, onLocalConnectionStatusChange);
			//inbound.addEventListener(AsyncErrorEvent.ASYNC_ERROR,errorHandler);
			inbound.client = this;
			loader = new Loader();
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
		}
		
		
		/** Catch load errors. **/
		private function errorHandler(evt:ErrorEvent):void {
			stop();
			sendMediaEvent(MediaEvent.JWPLAYER_MEDIA_ERROR, {message: evt.text});
		}
		
		
		/** xtract the current ID from a youtube URL **/
		private function getID(url:String):String {
			var arr:Array = url.split('?');
			var str:String = '';
			for (var i:String in arr) {
				if (arr[i].substr(0, 2) == 'v=') {
					str = arr[i].substr(2);
				}
			}
			if (str == '') {
				str = url.substr(url.indexOf('/v/') + 3);
			}
			if (str.indexOf('&') > -1) {
				str = str.substr(0, str.indexOf('&'));
			}
			return str;
		}
		
		
		/** Load the YouTube movie. **/
		override public function load(itm:PlaylistItem):void {
			_item = itm;
			_position = 0;
			loading = true;
			if (connected) {
				if (outgoing) {
					var gid:String = getID(_item.file);
					resize(_config.width, _config.width / 4 * 3);
					outgoing.send('AS3_' + unique, "loadVideoById", gid, _item.start);
					_media = loader;
				}
			} else {
				inbound.connect('AS2_' + unique);
				loader.load(new URLRequest(location));
			}
			sendMediaEvent(MediaEvent.JWPLAYER_MEDIA_BUFFER, {percentage: 0});
			setState(PlayerState.BUFFERING);
		}
		
		
		/** Pause the YouTube movie. **/
		override public function pause():void {
			outgoing.send('AS3_' + unique, "pauseVideo");
			super.pause();
		}
		
		
		/** Play or pause the video. **/
		override public function play():void {
			outgoing.send('AS3_' + unique, "playVideo");
			super.play();
		}
		
		
		/** SWF loaded; add it to the tree **/
		public function onSwfLoadComplete():void {
			_config.mute == true ? setVolume(0) : setVolume(_config.volume);
			connected = true;
			if (loading) {
				load(_item);
			}
		}
		
		
		/** error was thrown without this handler **/
		public function onLocalConnectionStatusChange(evt:StatusEvent):void {
			// sendMediaEvent(MediaEvent.JWPLAYER_MEDIA_META,{status:evt.code});
		}
		
		
		/** Catch youtube errors. **/
		public function onError(erc:String):void {
			sendMediaEvent(MediaEvent.JWPLAYER_MEDIA_ERROR, {message: "YouTube error (video not found?):\n" + _item.file});
			stop();
		}
		
		
		/** Catch youtube state changes. **/
		public function onStateChange(stt:Number):void {
			switch (Number(stt)) {
				case -1:
					// setState(PlayerState.IDLE);
					break;
				case 0:
					if (_config.state != PlayerState.BUFFERING && _config.state != PlayerState.IDLE) {
						setState(PlayerState.IDLE);
						sendMediaEvent(MediaEvent.JWPLAYER_MEDIA_COMPLETE);
					}
					break;
				case 1:
					super.play();
					break;
				case 2:
					super.pause();
					break;
				case 3:
					setState(PlayerState.BUFFERING);
					sendMediaEvent(MediaEvent.JWPLAYER_MEDIA_BUFFER, {percentage: 0});
					break;
			}
		}
		
		
		/** Catch Youtube load changes **/
		public function onLoadChange(ldd:Number, ttl:Number, off:Number):void {
			sendMediaEvent(MediaEvent.JWPLAYER_MEDIA_LOADED, {loaded: ldd, total: ttl, offset: off});
		}
		
		
		/** Catch Youtube _position changes **/
		public function onTimeChange(pos:Number, dur:Number):void {
			sendMediaEvent(MediaEvent.JWPLAYER_MEDIA_TIME, {_position: pos, duration: dur});
			if (!metasent) {
				sendMediaEvent(MediaEvent.JWPLAYER_MEDIA_META, {width: 320, height: 240, duration: dur});
				metasent = true;
			}
		}
		
		
		/** Resize the YT player. **/
		public function resize(wid:Number, hei:Number):void {
			outgoing.send('AS3_' + unique, "setSize", wid, hei);
		}
		
		
		/** Seek to _position. **/
		override public function seek(pos:Number):void {
			outgoing.send('AS3_' + unique, "seekTo", pos);
			play();
		}
		
		
		/** Destroy the youtube video. **/
		override public function stop():void {
			metasent = false;
			outgoing.send('AS3_' + unique, "stopVideo");
			super.stop();
		}
		
		
		/** Set the volume level. **/
		override public function setVolume(pct:Number):void {
			outgoing.send('AS3_' + unique, "setVolume", pct);
		}
	}
}