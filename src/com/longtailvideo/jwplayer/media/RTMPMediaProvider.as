/**
 * Wrapper for playback of video streamed over RTMP.
 *
 * All playback functionalities are cross-server (FMS, Wowza, Red5), with the exception of:
 * - The SecureToken functionality (Wowza).
 * - getStreamLength / checkBandwidth (FMS3).
 **/
package com.longtailvideo.jwplayer.media {
	import com.jeroenwijering.events.*;
	import com.longtailvideo.jwplayer.events.MediaEvent;
	import com.longtailvideo.jwplayer.model.PlayerConfig;
	import com.longtailvideo.jwplayer.model.PlaylistItem;
	import com.longtailvideo.jwplayer.player.PlayerState;
	import com.longtailvideo.jwplayer.utils.NetClient;
	import com.longtailvideo.jwplayer.utils.TEA;

	import flash.events.*;
	import flash.media.*;
	import flash.net.*;
	import flash.utils.*;


	public class RTMPMediaProvider extends MediaProvider {
		/** Video object to be instantiated. **/
		protected var video:Video;
		/** NetConnection object for setup of the video stream. **/
		protected var connection:NetConnection;
		/** Loader instance that loads the XML file. **/
		private var loader:URLLoader;
		/** NetStream instance that handles the stream IO. **/
		protected var stream:NetStream;
		/** Sound control object. **/
		protected var transformer:SoundTransform;
		/** Save the location of the XML redirect. **/
		private var smil:String;
		/** Save that the video has been started. **/
		protected var started:Boolean;
		/** ID for the position interval. **/
		protected var interval:Number;
		/** Save that a file is unpublished. **/
		protected var unpublished:Boolean;


		public function RTMPMediaProvider() {
		}


		/** Constructor; sets up the connection and display. **/
		public override function initializeMediaProvider(cfg:PlayerConfig):void {
			super.initializeMediaProvider(cfg);
			_provider = 'rtmp';
			connection = new NetConnection();
			connection.addEventListener(NetStatusEvent.NET_STATUS, statusHandler);
			connection.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);
			connection.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			connection.addEventListener(AsyncErrorEvent.ASYNC_ERROR, errorHandler);
			connection.objectEncoding = ObjectEncoding.AMF0;
			connection.client = new NetClient(this);
			loader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, loaderHandler);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);
			loader.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			video = new Video(320, 240);
			video.smoothing = _config.smoothing;
			transformer = new SoundTransform();
		}


		/** Catch security errors. **/
		protected function errorHandler(evt:ErrorEvent):void {
			error(evt.text);
		}


		/** Extract the correct rtmp syntax from the file string. **/
		protected function getID(url:String):String {
			var ext:String = url.substr(-4);
			if (ext == '.mp3') {
				return 'mp3:' + url.substr(0, url.length - 4);
			} else if (ext == '.mp4' || ext == '.mov' || ext == '.aac' || ext == '.m4a' || ext == '.f4v') {
				return 'mp4:' + url;
			} else if (ext == '.flv') {
				return url.substr(0, url.length - 4);
			} else {
				return url;
			}
		}


		/** Load content. **/
		override public function load(itm:PlaylistItem):void {
			_item = itm;
			_position = 0;
			setState(PlayerState.BUFFERING);
			sendBufferEvent(0);
			if (getConfigProperty('loadbalance') as Boolean == true) {
				smil = item.file;
				loader.load(new URLRequest(smil));
			} else {
				finishLoad();
			}
		}


		/** Get the streamer / file from the loadbalancing XML. **/
		private function loaderHandler(evt:Event):void {
			var xml:XML = XML(evt.currentTarget.data);
			item.streamer = xml.children()[0].children()[0].@base.toString();
			item.file = xml.children()[1].children()[0].@src.toString();
			finishLoad();
		}


		/** Finalizes the loading process **/
		private function finishLoad():void {
			if (!media) {
				media = video;
			}
			connection.connect(item.streamer);
			_config.mute == true ? setVolume(0) : setVolume(_config.volume);
			sendMediaEvent(MediaEvent.JWPLAYER_MEDIA_LOADED);
		}


		/** Get metadata information from netstream class. **/
		public function onData(dat:Object):void {
			if (dat.width) {
				video.width = dat.width;
				video.height = dat.height;
				resize(_width, _height);
			}
			if (dat.duration && item.duration < 0) {
				item.duration = dat.duration;
			}
			if (dat.type == 'complete') {
				complete();
			} else if (dat.type == 'close') {
				stop();
			}
			if (_config.ignoremeta != true) {
				sendMediaEvent(MediaEvent.JWPLAYER_MEDIA_META, {metadata: dat});
			}
		}


		/** Pause playback. **/
		override public function pause():void {
			stream.pause();
			clearInterval(interval);
			super.pause();
			if (started && item.duration == 0) {
				stop();
			}
		}


		/** Resume playing. **/
		override public function play():void {
			stream.resume();
			interval = setInterval(positionInterval, 100);
			super.play();
		}


		/** Interval for the position progress. **/
		protected function positionInterval():void {
			_position = Math.round(stream.time * 10) / 10;
			var bfr:Number = Math.round(stream.bufferLength / stream.bufferTime * 100);
			if (bfr < 95 && position < Math.abs(item.duration - stream.bufferTime - 1)) {
				if (state == PlayerState.PLAYING && bfr < 20) {
					stream.pause();
					setState(PlayerState.BUFFERING);
					stream.bufferTime = _config.bufferlength;
					sendMediaEvent(MediaEvent.JWPLAYER_MEDIA_META, {metadata: {bufferlength: _config.bufferlength}});
				}
			} else if (bfr > 95 && state == PlayerState.BUFFERING) {
				sendMediaEvent(MediaEvent.JWPLAYER_MEDIA_BUFFER_FULL);
				stream.bufferTime = _config.bufferlength * 4;
				sendMediaEvent(MediaEvent.JWPLAYER_MEDIA_META, {metadata: {bufferlength: _config.bufferlength * 4}});
			}

			var bufferPercent:Number = Math.round((_position + stream.bufferLength) / item.duration * 100);
			if (state == PlayerState.BUFFERING) {
				// Totally accurate, but it looks strange
				// sendBufferEvent(bufferPercent);
			} else if (position < item.duration) {
				if (state == PlayerState.PLAYING && position >= 0) {
					// Totally accurate, but it looks strange
					// sendMediaEvent(MediaEvent.JWPLAYER_MEDIA_TIME, {position: position, duration: item.duration, bufferPercent:bufferPercent});
					sendMediaEvent(MediaEvent.JWPLAYER_MEDIA_TIME, {position: position,
							duration: item.duration});
				}
			} else if (!isNaN(position) && item.duration > 0) {
				complete();
			}
		}


		/** Seek to a new position. **/
		override public function seek(pos:Number):void {
			_position = pos;
			clearInterval(interval);
			stream.seek(position);
			interval = setInterval(positionInterval, 100);
			//stream.resume();
			//super.play();
		}


		/** Start the netstream object. **/
		protected function setStream():void {
			stream = new NetStream(connection);
			stream.checkPolicyFile = true;
			stream.addEventListener(NetStatusEvent.NET_STATUS, statusHandler);
			stream.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			stream.addEventListener(AsyncErrorEvent.ASYNC_ERROR, errorHandler);
			stream.bufferTime = _config.bufferlength;
			stream.client = new NetClient(this);
			video.attachNetStream(stream);
			interval = setInterval(positionInterval, 100);
			stream.play(getID(item.file));
		}


		/** Receive NetStream status updates. **/
		protected function statusHandler(evt:NetStatusEvent):void {
			switch (evt.info.code) {
				case 'NetConnection.Connect.Success':
					if (evt.info.secureToken != undefined) {
						connection.call("secureTokenResponse", null, TEA.decrypt(evt.info.secureToken, _config.token));
					}
					setStream();
					var res:Responder = new Responder(streamlengthHandler);
					connection.call("getStreamLength", res, getID(item.file));
					connection.call("checkBandwidth", null);
					break;
				case 'NetStream.Play.Start':
					if (item.start > 0 && !started) {
						seek(item.start);
					}
					started = true;
					break;
				case 'NetStream.Seek.Notify':
					clearInterval(interval);
					interval = setInterval(positionInterval, 100);
					break;
				case 'NetConnection.Connect.Rejected':
					try {
						if (evt.info.ex.code == 302) {
							item.streamer = evt.info.ex.redirect;
							setTimeout(load, 100, item);
							return;
						}
					} catch (err:Error) {
						var msg:String = evt.info.code;
						if (evt.info['description']) {
							msg = evt.info['description'];
						}
						error(msg);
					}
					break;
				case 'NetStream.Failed':
				case 'NetStream.Play.StreamNotFound':
					if (unpublished) {
						onData({type: 'complete'});
						unpublished = false;
					} else {
						error("Stream not found: " + item.file);
					}
					break;
				case 'NetConnection.Connect.Failed':
					error("Server not found: " + item.streamer);
					break;
				case 'NetStream.Play.UnpublishNotify':
					unpublished = true;
					break;
			}
			sendMediaEvent(MediaEvent.JWPLAYER_MEDIA_META, {metadata: evt.info});
		}


		/** Destroy the stream. **/
		override public function stop():void {
			if (stream && stream.time) {
				stream.close();
			}
			connection.close();
			started = false;
			clearInterval(interval);
			super.stop();
			if (smil) {
				item.file = smil;
			}
		}


		/** Get the streamlength returned from the connection. **/
		private function streamlengthHandler(len:Number):void {
			if (len > 0) {
				onData({type: 'streamlength', duration: len});
			}
		}


		/** Set the volume level. **/
		override public function setVolume(vol:Number):void {
			transformer.volume = vol / 100;
			if (stream) {
				try {
					stream.soundTransform = transformer;
					super.setVolume(vol);
				} catch (err:Error) {

				}
			}
		}
	}
}