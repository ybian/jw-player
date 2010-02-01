/**
 * Wrapper for playback of _video streamed over RTMP.
 *
 * All playback functionalities are cross-server (FMS, Wowza, Red5), with the exception of:
 * - The SecureToken functionality (Wowza).
 * - getStreamLength / checkBandwidth (FMS3).
 **/
package com.longtailvideo.jwplayer.media {
    import com.longtailvideo.jwplayer.events.MediaEvent;
    import com.longtailvideo.jwplayer.events.PlayerEvent;
    import com.longtailvideo.jwplayer.model.PlayerConfig;
    import com.longtailvideo.jwplayer.model.PlaylistItem;
    import com.longtailvideo.jwplayer.model.PlaylistItemLevel;
    import com.longtailvideo.jwplayer.player.PlayerState;
    import com.longtailvideo.jwplayer.utils.AssetLoader;
    import com.longtailvideo.jwplayer.utils.Configger;
    import com.longtailvideo.jwplayer.utils.Logger;
    import com.longtailvideo.jwplayer.utils.NetClient;
    import com.longtailvideo.jwplayer.utils.TEA;
    
    import flash.events.*;
    import flash.media.*;
    import flash.net.*;
    import flash.utils.*;

    /**
     * Wrapper for playback of video streamed over RTMP. Can playback MP4, FLV, MP3, AAC and live streams.
     * Server-specific features are:
     * - The SecureToken functionality of Wowza (with the 'token' flahvar).
     * - Load balancing with SMIL files (with the 'rtmp.loadbalance=true' flashvar).
     **/
    public class RTMPMediaProvider extends MediaProvider {
		/** Save if the bandwidth checkin already occurs. **/
		private var _bandwidthChecked:Boolean;
        /** Interval for bw checking - with dynamic streaming. **/
        private var _bandwidthInterval:Number;
		/** Whether to connect to a stream when bandwidth is detected. **/
		private var _bandwidthSwitch:Boolean;
        /** NetConnection object for setup of the video stream. **/
        private var _connection:NetConnection;
        /** Is dynamic streaming possible. **/
        private var _dynamic:Boolean;
		/** The currently playing RTMP stream. **/
		private var _currentFile:String;
        /** ID for the position interval. **/
        private var _positionInterval:Number;
        /** Loaders for loading SMIL files. **/
        private var _xmlLoaders:Dictionary;
        /** NetStream instance that handles the stream IO. **/
        private var _stream:NetStream;
        /** Interval ID for subscription pings. **/
        private var _subscribeInterval:Number;
        /** Offset in seconds of the last seek. **/
        private var _timeoffset:Number = -1;
        /** Sound control object. **/
        private var _transformer:SoundTransform;
        /** Save that a stream is streaming. **/
        private var _isStreaming:Boolean;
        /** Level to which we're transitioning. **/
        private var _transitionLevel:Number = -1;
        /** Video object to be instantiated. **/
        private var _video:Video;
		/** Whether or not the buffer is full **/
		private var _bufferFull:Boolean = false;

		public function RTMPMediaProvider() {
			super('rtmp');
		}
		
		
		/** Constructor; sets up the connection and display. **/
		public override function initializeMediaProvider(cfg:PlayerConfig):void {
			super.initializeMediaProvider(cfg);
            _connection = new NetConnection();
            _connection.addEventListener(NetStatusEvent.NET_STATUS, statusHandler);
            _connection.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);
            _connection.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
            _connection.addEventListener(AsyncErrorEvent.ASYNC_ERROR, errorHandler);
            _connection.objectEncoding = ObjectEncoding.AMF0;
            _connection.client = new NetClient(this);
			_xmlLoaders = new Dictionary();
            _transformer = new SoundTransform();
            _video = new Video(320, 240);
            _video.smoothing = config.smoothing;
        }

        /** Check if the player can use dynamic streaming (server versions and no load balancing). **/
        private function checkDynamic(str:String):void {
            var clt:Number = Number(PlayerEvent.client.split(' ')[1].split(',')[0]);
            var mjr:Number = Number(str.split(',')[0]);
            var mnr:Number = Number(str.split(',')[1]);
            if (!(getConfigProperty('loadbalance') && clt > 9 && (mjr > 3 || (mjr == 3 && mnr > 4)))) {
                _dynamic = true;
            } else {
                _dynamic = false;
            }
        }

        /** Try subscribing to livestream **/
        private function doSubscribe(id:String):void {
            _connection.call("FCSubscribe", null, id);
        }

        /** Catch security errors. **/
        private function errorHandler(evt:ErrorEvent):void {
            stop();
			sendMediaEvent(MediaEvent.JWPLAYER_MEDIA_ERROR, {message: evt.text});
		}

        /** Bandwidth checking for dynamic streaming. **/
        private function getBandwidth():void {
            try {
                var bdw:Number = Math.round(_stream.info.maxBytesPerSecond * 8 / 1024);
            } catch (err:Error) {
                clearInterval(_bandwidthInterval);
                return;
            }
            if (bdw < 100 || bdw > 99999) {
                return;
            } else {
                bdw = Math.round(config.bandwidth / 2 + bdw / 2);
            }
            config.bandwidth = bdw;
            Configger.saveCookie('bandwidth', bdw);
            if (item.levels.length > 0 && item.getLevel(config.bandwidth, config.width) != item.currentLevel) {
                swap(item.currentLevel);
            }
        }

        /** Extract the correct rtmp syntax from the file string. **/
        private function getID(url:String):String {
            var ext:String = url.substr(-4);
            if (url.indexOf(':') > -1) {
                return url;
            } else if (ext == '.mp3') {
                return 'mp3:' + url.substr(0, url.length - 4);
            } else if (ext == '.mp4' || ext == '.mov' || ext == '.m4v' || ext == '.aac' || ext == '.m4a' || ext == '.f4v') {
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
			_bufferFull = false;
			_bandwidthSwitch = false;			
            _timeoffset = item.start;
			if (item.levels.length > 0) { item.setLevel(item.getLevel(config.bandwidth, config.width)); }
            clearInterval(_positionInterval);
			setState(PlayerState.BUFFERING);
			sendBufferEvent(0);
            if (getConfigProperty('loadbalance')) {
				loadSmil();
			} else {
				finishLoad();
			}
        }

		/** Load a SMIL file for load-balancing **/
		private function loadSmil():void {
			if (!item.hasOwnProperty('smil')) { 
				item.smil = [];				
				if (item.levels.length > 0) {
					for (var i:Number = 0; i < item.levels.length; i++) {
						item.smil[i] = (item.levels[i] as PlaylistItemLevel).file;
					}
				} else {
					item.smil[0] = item.file;
				}
			} 
			
			var smilFile:String = item.levels.length > 0 ? item.smil[item.currentLevel] : item.smil[0];
			
			var loader:AssetLoader = new AssetLoader();
			loader.addEventListener(Event.COMPLETE, loaderHandler);
			loader.addEventListener(ErrorEvent.ERROR, errorHandler);
			_xmlLoaders[loader] = smilFile;
			loader.load(smilFile, XML);
		}
		
		/** Finalizes the loading process **/
		private function finishLoad():void {
			if (item.file.substr(-4) == '.mp3') {
				media = null;
			} else if (!media) {
				media = _video;
			}
			sendMediaEvent(MediaEvent.JWPLAYER_MEDIA_LOADED);
			_connection.connect(item.streamer);
		}
		
        /** Get the streamer / file from the loadbalancing XML. **/
        private function loaderHandler(evt:Event):void {
            var xml:XML = XML((evt.target as AssetLoader).loadedObject);
			var fileLocation:String = xml.body.video.@src.toString();
			var smilLocation:String = _xmlLoaders[evt.target];
			delete _xmlLoaders[evt.target];
			if (item.levels.length > 0) {
				var level:PlaylistItemLevel = item.levels[(item.smil as Array).indexOf(smilLocation)] as PlaylistItemLevel; 
				level.streamer = xml.head.meta.@base.toString();
				level.file = fileLocation;
			} else {
				item.streamer = xml.head.meta.@base.toString();
           		item.file = fileLocation;
			}
			finishLoad();
        }

        /** Get metadata information from netstream class. **/
        public function onClientData(dat:Object):void {
            if (dat.type == 'fcsubscribe') {
                if (dat.code == "NetStream.Play.StreamNotFound") {
					sendMediaEvent(MediaEvent.JWPLAYER_MEDIA_ERROR,{message: "Subscription failed: " + item.file}); 
                } else if (dat.code == "NetStream.Play.Start") {
                    setStream();
                }
                clearInterval(_subscribeInterval);
            }
            if (dat.width) {
				_video.width = dat.width;
				_video.height = dat.height;
				resize(_width, _height);
            }
            if (dat.duration && item.duration <= 0) {
                item.duration = dat.duration;
            }
            if (dat.type == 'complete') {
                clearInterval(_positionInterval);
				complete();
            }
            if (dat.type == 'close') {
                stop();
            }
            if (dat.type == 'bandwidth') {
                config.bandwidth = dat.bandwidth;
                Configger.saveCookie('bandwidth', dat.bandwidth);
				if (_bandwidthSwitch) {
					_bandwidthSwitch = false;
                	setStream();
				}
            }
            if (dat.code == 'NetStream.Play.TransitionComplete') {
				if (_transitionLevel >= 0) {
					Logger.log("Transition to level " + item.currentLevel + " complete");
                	_transitionLevel = -1;
				}
            }
			sendMediaEvent(MediaEvent.JWPLAYER_MEDIA_META, {metadata: dat});
        }

        /** Pause playback. **/
        override public function pause():void {
			if (isLivestream()) {
				stop();
				return;
			}
			
			clearInterval(_positionInterval);
			super.pause();
            if (_stream) { 
				Logger.log("NetStream.pause()");
				_stream.pause(); 
			}
        }

        /** Resume playing. **/
        override public function play():void {
			clearInterval(_positionInterval);
            if (state == PlayerState.PAUSED) {
				Logger.log("NetStream.resume()");
				_stream.resume();				
			}
			super.play();
			_positionInterval = setInterval(positionInterval, 100);
        }

        /** Interval for the position progress. **/
        private function positionInterval():void {
            var pos:Number = Math.round((_stream.time) * 10) / 10;
			var bfr:Number = _stream.bufferLength / _stream.bufferTime;

			if (bfr < 0.25 && pos < item.duration - 5 && state != PlayerState.BUFFERING) {
				_bufferFull = false;
				setState(PlayerState.BUFFERING);
            } else if (bfr > 1 && state != PlayerState.PLAYING) {
				if (state == PlayerState.BUFFERING && !isLivestream()) {
					_bufferFull = true;
					sendMediaEvent(MediaEvent.JWPLAYER_MEDIA_BUFFER_FULL, {bufferPercent: bfr});
				}
            }
            if (state != PlayerState.PLAYING) {
                return;
            }
            if (pos < item.duration) {
				_position = pos;
				sendMediaEvent(MediaEvent.JWPLAYER_MEDIA_TIME, {position: position, duration: item.duration});
            } else if (position > 0 && item.duration > 0) {
				Logger.log("NetStream.pause()");
                _stream.pause();
                clearInterval(_positionInterval);
				complete();
            }
        }

        /** Check if the level must be switched on resize. **/
        override public function resize(width:Number, height:Number):void {
            super.resize(width, height);
			if (state == PlayerState.PLAYING) {
            	if (item.levels.length > 0 && item.currentLevel != item.getLevel(config.bandwidth, config.width)) {
                	if (_dynamic) {
	                    swap(item.getLevel(config.bandwidth, config.width));
                	} else {
	                    seek(position);
                	}
				}
            }
        }

        /** Seek to a new position. **/
        override public function seek(pos:Number):void {
            super.seek(pos);
            _transitionLevel = -1;
			_timeoffset = pos;
            clearInterval(_positionInterval);
            clearInterval(_bandwidthInterval);
			if (item.levels.length > 0 && item.getLevel(config.bandwidth, config.width) != item.currentLevel) {
                item.setLevel(item.getLevel(config.bandwidth, config.width));
                if (getConfigProperty('loadbalance')) {
                    item.start = pos;
                    load(item);
                    return;
                }
            }
			if (state == PlayerState.PAUSED) {
				play();
			}
            if (getConfigProperty('subscribe')) {
				Logger.log("NetStream.play(" + getID(item.file) + ")");
                _stream.play(getID(item.file));
            } else {
                if (_currentFile != item.file) {
                    _currentFile = item.file;
					Logger.log("NetStream.play(" + getID(item.file) + ")");
					try {
                    	_stream.play(getID(item.file));
					} catch(e:Error) {
						Logger.log("Error: " + e.message);
					}
                }
                if (_timeoffset > 0 || state == PlayerState.IDLE) {
                    if (_stream) {
						Logger.log("NetStream.seek(" + _timeoffset + ")");
						_stream.seek(_timeoffset);
					}
                }
                if (_dynamic) {
                    _bandwidthInterval = setInterval(getBandwidth, 2000);
                }
            }
            _isStreaming = true;
            _positionInterval = setInterval(positionInterval, 100);
        }

        /** Start the netstream object. **/
        private function setStream():void {
			_stream = new NetStream(_connection);
			_stream.checkPolicyFile = true;
			_stream.addEventListener(NetStatusEvent.NET_STATUS, statusHandler);
			_stream.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			_stream.addEventListener(AsyncErrorEvent.ASYNC_ERROR, errorHandler);
			_stream.bufferTime = config.bufferlength;
			_stream.client = new NetClient(this);
			_video.attachNetStream(_stream);
			config.mute == true ? setVolume(0) : setVolume(config.volume);
			seek(_timeoffset);
        }

        /** Receive NetStream status updates. **/
        private function statusHandler(evt:NetStatusEvent):void {
            switch (evt.info.code) {
                case 'NetConnection.Connect.Success':
                    if (evt.info.secureToken != undefined) {
                      	_connection.call("secureTokenResponse", null, TEA.decrypt(evt.info.secureToken,
                                                                                  config.token));
                    }
                    if (evt.info.data) {
                        checkDynamic(evt.info.data.version);
                    }
                    if (getConfigProperty('subscribe')) {
                        _subscribeInterval = setInterval(doSubscribe, 1000, getID(item.file));
                        return;
                    } else {
                        if (item.levels.length > 0) {
                            if (_dynamic || _bandwidthChecked) {
                                setStream();
                            } else {
								_bandwidthChecked = true;
								_bandwidthSwitch = true;
                                _connection.call('checkBandwidth', null);
                            }
                        } else {
                            setStream();
                        }
                        if (item.file.substr(-4) == '.mp3' || item.file.substr(0,4) == 'mp3:') {
                            _connection.call("getStreamLength", new Responder(streamlengthHandler), getID(item.file));
                        }
                    }
                    break;
                case 'NetStream.Seek.Notify':
                    clearInterval(_positionInterval);
					_positionInterval = setInterval(positionInterval, 100);
                    break;
                case 'NetConnection.Connect.Rejected':
                    try {
                        if (evt.info.ex.code == 302) {
                            item.streamer = evt.info.ex.redirect;
                            setTimeout(load, 100, item);
                            return;
                        }
                    } catch (err:Error) {
                        stop();
                        var msg:String = evt.info.code;
                        if (evt.info['description']) {
                            msg = evt.info['description'];
                        }
                        stop();
						sendMediaEvent(MediaEvent.JWPLAYER_MEDIA_ERROR, {message: msg}); 
                    }
                    break;
				case 'NetStream.Failed':
                case 'NetStream.Play.StreamNotFound':
                    if (!_isStreaming) {
                        onClientData({type: 'complete'});
                    } else {
                        stop();
						sendMediaEvent(MediaEvent.JWPLAYER_MEDIA_ERROR, {message: "Stream not found: " + item.file}); 
                    }
                    break;
				case 'NetStream.Seek.Failed':
					if (!_isStreaming) {
						onClientData({type: 'complete'});
					} else {
						stop();
						sendMediaEvent(MediaEvent.JWPLAYER_MEDIA_ERROR, {message: "Could not seek: " + item.file}); 
					}
					break;
                case 'NetConnection.Connect.Failed':
                    stop();
					sendMediaEvent(MediaEvent.JWPLAYER_MEDIA_ERROR, {message: "Server not found: " + item.streamer}); 
                    break;
                case 'NetStream.Play.UnpublishNotify':
                    stop();
                    break;
				case 'NetStream.Buffer.Full':
					if (!_bufferFull) {
						_bufferFull = true;
						sendMediaEvent(MediaEvent.JWPLAYER_MEDIA_BUFFER_FULL);
					}
					break;
				case 'NetStream.Play.Transition':
					onClientData(evt.info);
					break;
            }
			sendMediaEvent(MediaEvent.JWPLAYER_MEDIA_META, {metadata: evt.info});
        }

        /** Destroy the stream. **/
        override public function stop():void {
            if (_stream && _stream.time) {
				Logger.log("NetStream.close()");
				_stream.close();
            }
            _isStreaming = false;
            _currentFile = undefined;
            _connection.close();
            clearInterval(_positionInterval);
            clearInterval(_bandwidthInterval);
            _position = 0;
            _timeoffset = item.start;
			super.stop();
			if (item.hasOwnProperty('smil')) {
				/** Replace file values with original redirects **/
				if (item.levels.length > 0) {
					for each (var level:PlaylistItemLevel in item.levels) { 
						for (var i:Number = 0; i < (item.smil as Array).length; i++) {
							level.file = item.smil[i];
						}
					}
				} else {
					item.file = item.smil[0];
				}
			}
		}

        /** Get the streamlength returned from the connection. **/
        private function streamlengthHandler(len:Number):void {
			Logger.log("duration: " + len);
            if (len && item.duration <= 0) {
                item.duration = len;
            }
        }

        /** Dynamically switch streams **/
        private function swap(newLevel:Number):void {
            if (_transitionLevel == newLevel) {
                Logger.log('Already tranisitioning to level ' + item.currentLevel + ' ; transition ignored');
            } else {
                _transitionLevel = newLevel;
				item.setLevel(newLevel);
                Logger.log('transition to level ' + newLevel + ' initiated');
                var nso:NetStreamPlayOptions = new NetStreamPlayOptions();
                nso.streamName = getID(item.file);
                nso.transition = NetStreamPlayTransitions.SWITCH;
				Logger.log("NetStream.play2(" + nso + ")");
                _stream.play2(nso);
            }
        }

        /** Set the volume level. **/
        override public function setVolume(vol:Number):void {
            _transformer.volume = vol / 100;
			
            if (_stream) {
                _stream.soundTransform = _transformer;
            }
			
			super.setVolume(vol);
        }
		
		/** Completes video playback **/
		override protected function complete():void {
			stop();
			sendMediaEvent(MediaEvent.JWPLAYER_MEDIA_COMPLETE);
			setState(PlayerState.IDLE);
		}
		
		/** Determines if the stream is a live stream **/
		private function isLivestream():Boolean {
			// We assume it's a livestream until we hear otherwise.
			return (!(item.duration > 0) && _stream && _stream.bufferLength > 0);
		}
		
		
    }
}