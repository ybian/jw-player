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
		private var _loader:Loader;
		/** 'Unique' string to use for proxy connection. **/
		private var _unique:String;
		/** Connection towards the YT proxy. **/
		private var _outgoing:LocalConnection;
		/** connection from the YT proxy. **/
		private var _inbound:LocalConnection;
		/** Save that a load call has been sent. **/
		private var _loading:Boolean;
		/** Save the connection state. **/
		private var _connected:Boolean;
		/** Buffer percent **/
		private var _bufferPercent:Number;
		/** Time offset **/
		private var _offset:Number = 0;


		/** Setup YouTube connections and load proxy. **/
		public function YouTubeMediaProvider() {
			super('youtube');
		}


		public override function initializeMediaProvider(cfg:PlayerConfig):void {
			super.initializeMediaProvider(cfg);
			Security.allowDomain('*');
			_outgoing = new LocalConnection();
			_outgoing.allowDomain('*');
			_outgoing.allowInsecureDomain('*');
			_outgoing.addEventListener(StatusEvent.STATUS, onLocalConnectionStatusChange);
			_inbound = new LocalConnection();
			_inbound.allowDomain('*');
			_inbound.allowInsecureDomain('*');
			_inbound.addEventListener(StatusEvent.STATUS, onLocalConnectionStatusChange);
			_inbound.client = this;
			_loader = new Loader();
			_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
		}


		/** Catch load errors. **/
		private function errorHandler(evt:ErrorEvent):void {
			error(evt.text);
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


		/** Get the location of yt.swf. **/
		private function getLocation():String {
			var loc:String;
			var url:String = RootReference.stage.loaderInfo.url;
			if (url.indexOf('http://') == 0) {
				_unique = Math.random().toString().substr(2);
				loc = url.substr(0, url.indexOf('.swf'));
				loc = loc.substr(0, loc.lastIndexOf('/') + 1) + 'yt.swf?unique=' + _unique;
			} else {
				_unique = '1';
				loc = 'yt.swf';
			}
			return loc;
		}


		/** Load the YouTube movie. **/
		override public function load(itm:PlaylistItem):void {
			_item = itm;
			_position = _offset = 0;
			_loading = true;
			setState(PlayerState.BUFFERING);
			sendBufferEvent(0);
			if (_connected) {
				completeLoad(itm);
			} else {
				_loader.load(new URLRequest(getLocation()));
				_inbound.connect('AS2_' + _unique);
			}
		}


		/** SWF loaded; add it to the tree **/
		public function onSwfLoadComplete():void {
			_connected = true;
			if (_loading) {
				completeLoad(_item);
			}
		}


		/** Everything loaded - play the video **/
		private function completeLoad(itm:PlaylistItem):void {
			if (_outgoing) {
				var gid:String = getID(_item.file);
				_outgoing.send('AS3_' + _unique, "cueVideoById", gid, _item.start);
				resize(config.width, config.width / 4 * 3);
				media = _loader;
				sendMediaEvent(MediaEvent.JWPLAYER_MEDIA_LOADED);
				config.mute == true ? setVolume(0) : setVolume(config.volume);
				sendMediaEvent(MediaEvent.JWPLAYER_MEDIA_BUFFER_FULL);
			}
		}


		/** Pause the YouTube movie. **/
		override public function pause():void {
			_outgoing.send('AS3_' + _unique, "pauseVideo");
			super.pause();
		}


		/** Play or pause the video. **/
		override public function play():void {
			_outgoing.send('AS3_' + _unique, "playVideo");
			super.play();
		}


		/** error was thrown without this handler **/
		public function onLocalConnectionStatusChange(evt:StatusEvent):void {
			// sendMediaEvent(MediaEvent.JWPLAYER_MEDIA_META,{status:evt.code});
		}


		/** Catch youtube errors. **/
		public function onError(erc:Number):void {
			var msg:String = 'Video not found or deleted: ' + getID(item['file']);
			if (erc == 101 || erc == 150) {
				msg = 'Embedding this video is disabled by its owner.';
			}
			error(msg);
		}


		/** Catch youtube state changes. **/
		public function onStateChange(stt:Number):void {
			switch (Number(stt)) {
				case -1:
					// setState(PlayerState.IDLE);
					break;
				case 0:
					if (state != PlayerState.BUFFERING && state != PlayerState.IDLE) {
						complete();
						_offset = 0;
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
					break;
			}
		}


		/** Catch Youtube load changes **/
		public function onLoadChange(ldd:Number, ttl:Number, off:Number):void {
			_bufferPercent = Math.round(ldd / ttl * 100);
			_offset = off / ttl * item.duration;
			sendBufferEvent(_bufferPercent, _offset);
		}


		/** Catch Youtube _position changes **/
		public function onTimeChange(pos:Number, dur:Number):void {
			if (item.duration < 0) {
				item.duration = dur;
			}
			if (state != PlayerState.PLAYING){
				super.play();
			}
			sendMediaEvent(MediaEvent.JWPLAYER_MEDIA_TIME, {position: pos, duration: item.duration, bufferPercent:_bufferPercent, offset: _offset});
		}


		/** Resize the YT player. **/
		public override function resize(wid:Number, hei:Number):void {
			_outgoing.send('AS3_' + _unique, "setSize", wid, hei);
		}


		/** Seek to _position. **/
		override public function seek(pos:Number):void {
			_outgoing.send('AS3_' + _unique, "seekTo", pos);
			play();
		}


		/** Destroy the youtube video. **/
		override public function stop():void {
			if (_connected) {
				_outgoing.send('AS3_' + _unique, "stopVideo");
			} else {
				_loading = false;
			}
			_position = _offset = 0;
			super.stop();
		}


		/** Set the volume level. **/
		override public function setVolume(pct:Number):void {
			_outgoing.send('AS3_' + _unique, "setVolume", pct);
			super.setVolume(pct);
		}
	}
}