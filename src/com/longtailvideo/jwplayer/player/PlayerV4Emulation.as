package com.longtailvideo.jwplayer.player {
	import com.jeroenwijering.events.AbstractView;
	import com.jeroenwijering.events.ControllerEvent;
	import com.jeroenwijering.events.ModelEvent;
	import com.longtailvideo.jwplayer.controller.Controller;
	import com.longtailvideo.jwplayer.events.MediaEvent;
	import com.longtailvideo.jwplayer.events.PlayerEvent;
	import com.longtailvideo.jwplayer.events.PlayerStateEvent;
	import com.longtailvideo.jwplayer.events.PlaylistEvent;
	import com.longtailvideo.jwplayer.events.ViewEvent;
	import com.longtailvideo.jwplayer.model.Model;
	import com.longtailvideo.jwplayer.model.Playlist;
	import com.longtailvideo.jwplayer.model.PlaylistItem;
	import com.longtailvideo.jwplayer.plugins.PluginConfig;
	import com.longtailvideo.jwplayer.plugins.V4Plugin;
	import com.longtailvideo.jwplayer.utils.Logger;
	import com.longtailvideo.jwplayer.utils.TypeChecker;
	import com.longtailvideo.jwplayer.view.components.ControlbarComponent;
	
	import flash.display.DisplayObject;
	import flash.events.EventDispatcher;
	import flash.utils.describeType;
	import com.longtailvideo.jwplayer.view.components.ControlbarComponent;

	/**
	 * This singleton class acts as a wrapper between the Player and plugins or javascripts that were
	 * written for version 4 of the player.  It extends version 4's AbstractView class, and translates
	 * Player 5 event dispatches into their version 4 counterparts.
	 * 
	 * @see com.longtailvideo.jwplayer.plugins.V4Plugin  
	 */
	public class PlayerV4Emulation extends AbstractView {
		private static var instance:PlayerV4Emulation;
		private static var initialized:Boolean = false;
		
		private static var _player:Player;
		
		private var viewEventDispatcher:EventDispatcher;
		private var modelEventDispatcher:EventDispatcher;
		private var controllerEventDispatcher:EventDispatcher;
		
		private var id:String;
		private var client:String;
		private var version:String;
		
		public function PlayerV4Emulation(player:Player) {
			if (!initialized) {
				initialized = true;
				
				viewEventDispatcher = new EventDispatcher();
				modelEventDispatcher = new EventDispatcher();
				controllerEventDispatcher = new EventDispatcher();
				
				_player = player;
				_player.addEventListener(PlayerEvent.JWPLAYER_READY, playerReady);
				instance = this;
			}
		}
		
		public static function getInstance():PlayerV4Emulation {
			return instance;
		}
		
		private function playerReady(evt:PlayerEvent):void {
			var newEvt:PlayerEvent = new PlayerEvent("");
			id = newEvt.id;
			client = newEvt.client;
			version = newEvt.version;
			 
			dispatchEvent(new com.jeroenwijering.events.PlayerEvent(com.jeroenwijering.events.PlayerEvent.READY));
			setupListeners();
		}
		
		private function setupListeners():void {
			
			var m:Model;
			var v:ControlbarComponent;
			var c:Controller
			
			_player.addEventListener(PlayerEvent.JWPLAYER_ERROR, errorHandler);
			
			_player.addEventListener(MediaEvent.JWPLAYER_MEDIA_BUFFER, mediaBuffer);
			_player.addEventListener(MediaEvent.JWPLAYER_MEDIA_ERROR, mediaError);
			_player.addEventListener(MediaEvent.JWPLAYER_MEDIA_LOADED, mediaLoaded);
			_player.addEventListener(MediaEvent.JWPLAYER_MEDIA_TIME, mediaTime);
			_player.addEventListener(MediaEvent.JWPLAYER_MEDIA_VOLUME, mediaVolume);
			_player.addEventListener(PlayerStateEvent.JWPLAYER_PLAYER_STATE, stateHandler);

			_player.addEventListener(ViewEvent.JWPLAYER_VIEW_FULLSCREEN, viewFullscreen);
			_player.addEventListener(ViewEvent.JWPLAYER_VIEW_ITEM, viewItem);
			_player.addEventListener(ViewEvent.JWPLAYER_VIEW_LOAD, viewLoad);
			_player.addEventListener(ViewEvent.JWPLAYER_VIEW_MUTE, viewMute);
			_player.addEventListener(ViewEvent.JWPLAYER_VIEW_NEXT, viewNext);
			_player.addEventListener(ViewEvent.JWPLAYER_VIEW_PAUSE, viewPause);
			_player.addEventListener(ViewEvent.JWPLAYER_VIEW_PLAY, viewPlay);
			_player.addEventListener(ViewEvent.JWPLAYER_VIEW_PREV, viewPrev);
			_player.addEventListener(ViewEvent.JWPLAYER_VIEW_SEEK, viewSeek);
			_player.addEventListener(ViewEvent.JWPLAYER_VIEW_STOP, viewStop);
			_player.addEventListener(ViewEvent.JWPLAYER_VIEW_VOLUME, viewVolume);
			
			_player.playlist.addEventListener(PlaylistEvent.JWPLAYER_PLAYLIST_ITEM, playlistItem);
			_player.playlist.addEventListener(PlaylistEvent.JWPLAYER_PLAYLIST_LOADED, playlistLoad);
		}
		
		// Player Event Handlers
		
		private function errorHandler(evt:PlayerEvent):void {
			controllerEventDispatcher.dispatchEvent(new ControllerEvent(ControllerEvent.ERROR, {message:evt.message, id:id, client:client, version:version}));
		}
		
		// Media Event Handlers
		
		private function mediaBuffer(evt:MediaEvent):void {
			modelEventDispatcher.dispatchEvent(new ModelEvent(ModelEvent.BUFFER, {percentage:evt.bufferPercent, id:id, client:client, version:version}));
		}
		
		private function mediaError(evt:MediaEvent):void {
			modelEventDispatcher.dispatchEvent(new ModelEvent(ModelEvent.ERROR, {message:evt.message, id:id, client:client, version:version}));
		}
		
		private function mediaLoaded(evt:MediaEvent):void {
			modelEventDispatcher.dispatchEvent(new ModelEvent(ModelEvent.LOADED, {loaded:0, total:0, offset:0, id:id, client:client, version:version}));
		}
		
		private function mediaTime(evt:MediaEvent):void {
			modelEventDispatcher.dispatchEvent(new ModelEvent(ModelEvent.TIME, {duration:evt.duration, position:evt.position, id:id, client:client, version:version}));
		}
		
		private function mediaVolume(evt:MediaEvent):void {
			controllerEventDispatcher.dispatchEvent(new ControllerEvent(ControllerEvent.VOLUME, {percentage:evt.volume, id:id, client:client, version:version}));
		}
		
		private function stateHandler(evt:PlayerStateEvent):void {
			if (evt.newstate == PlayerState.IDLE && (evt.oldstate == PlayerState.BUFFERING || evt.oldstate == PlayerState.PLAYING)) {
				controllerEventDispatcher.dispatchEvent(new ControllerEvent(ControllerEvent.STOP, {id:id, client:client, version:version}));
			}
			
			modelEventDispatcher.dispatchEvent(new ModelEvent(ModelEvent.STATE, {oldstate:evt.oldstate, newstate:evt.newstate}));
		}

		// View Event Handlers

		private function viewFullscreen(evt:ViewEvent):void {
			viewEventDispatcher.dispatchEvent(new com.jeroenwijering.events.ViewEvent(com.jeroenwijering.events.ViewEvent.FULLSCREEN, {state:evt.data, id:id, client:client, version:version}));
		}
		
		private function viewItem(evt:ViewEvent):void {
			viewEventDispatcher.dispatchEvent(new com.jeroenwijering.events.ViewEvent(com.jeroenwijering.events.ViewEvent.ITEM, {index:evt.data, id:id, client:client, version:version}));
		}

		private function viewLoad(evt:ViewEvent):void {
			viewEventDispatcher.dispatchEvent(new com.jeroenwijering.events.ViewEvent(com.jeroenwijering.events.ViewEvent.LOAD, {object:evt.data, id:id, client:client, version:version}));
		}
		
		private function viewMute(evt:ViewEvent):void {
			viewEventDispatcher.dispatchEvent(new com.jeroenwijering.events.ViewEvent(com.jeroenwijering.events.ViewEvent.MUTE, {state:evt.data, id:id, client:client, version:version}));
			controllerEventDispatcher.dispatchEvent(new ControllerEvent(ControllerEvent.MUTE, {state:evt.data, client:client, version:version}));
		}
		
		private function viewNext(evt:ViewEvent):void {
			viewEventDispatcher.dispatchEvent(new com.jeroenwijering.events.ViewEvent(com.jeroenwijering.events.ViewEvent.NEXT, {id:id, client:client, version:version}));
		}
		
		private function viewPause(evt:ViewEvent):void {
			viewEventDispatcher.dispatchEvent(new com.jeroenwijering.events.ViewEvent(com.jeroenwijering.events.ViewEvent.PLAY, {state:false, id:id, client:client, version:version}));
			controllerEventDispatcher.dispatchEvent(new ControllerEvent(ControllerEvent.PLAY, {state:false, id:id, client:client, version:version}));
		}

		private function viewPlay(evt:ViewEvent):void {
			viewEventDispatcher.dispatchEvent(new com.jeroenwijering.events.ViewEvent(com.jeroenwijering.events.ViewEvent.PLAY, {state:true, id:id, client:client, version:version}));
			controllerEventDispatcher.dispatchEvent(new ControllerEvent(ControllerEvent.PLAY, {state:true, id:id, client:client, version:version}));
		}
		
		private function viewPrev(evt:ViewEvent):void {
			viewEventDispatcher.dispatchEvent(new com.jeroenwijering.events.ViewEvent(com.jeroenwijering.events.ViewEvent.PREV, {id:id, client:client, version:version}));
		}
		
		private function viewRedraw(width:Number, height:Number):void {
			viewEventDispatcher.dispatchEvent(new com.jeroenwijering.events.ViewEvent(com.jeroenwijering.events.ViewEvent.REDRAW, {id:id, client:client, version:version}));
			controllerEventDispatcher.dispatchEvent(new ControllerEvent(ControllerEvent.RESIZE, {width:width, height:height, fullscreen:_player.config.fullscreen, client:client, version:version}));
		}

		private function viewSeek(evt:ViewEvent):void {
			viewEventDispatcher.dispatchEvent(new com.jeroenwijering.events.ViewEvent(com.jeroenwijering.events.ViewEvent.SEEK, {position:evt.data, id:id, client:client, version:version}));
			controllerEventDispatcher.dispatchEvent(new ControllerEvent(ControllerEvent.SEEK, {position:evt.data, id:id, client:client, version:version}));
		}
		
		private function viewStop(evt:ViewEvent):void {
			viewEventDispatcher.dispatchEvent(new com.jeroenwijering.events.ViewEvent(com.jeroenwijering.events.ViewEvent.STOP, {id:id, client:client, version:version}));
		}
		
		private function viewVolume(evt:ViewEvent):void {
			viewEventDispatcher.dispatchEvent(new com.jeroenwijering.events.ViewEvent(com.jeroenwijering.events.ViewEvent.VOLUME, {state:evt.data, id:id, client:client, version:version}));
			controllerEventDispatcher.dispatchEvent(new ControllerEvent(ControllerEvent.VOLUME, {percentage:evt.data, id:id, client:client, version:version}));
		}
		
		// Playlist Event Handlers
		
		private function playlistItem(evt:PlaylistEvent):void {
			controllerEventDispatcher.dispatchEvent(new ControllerEvent(ControllerEvent.ITEM, {index:_player.playlist.currentIndex, id:id, client:client, version:version}));
		}

		private function playlistLoad(evt:PlaylistEvent):void {
			controllerEventDispatcher.dispatchEvent(new ControllerEvent(ControllerEvent.PLAYLIST, {playlist:playlistToArray(_player.playlist), id:id, client:client, version:version}));
		}
		
		
		// Listeners

		public override function addModelListener(type:String, listener:Function):void {
			modelEventDispatcher.addEventListener(type, listener);
		} 
		public override function removeModelListener(type:String, listener:Function):void {
			modelEventDispatcher.removeEventListener(type, listener);
		} 

		public override function addViewListener(type:String, listener:Function):void {
			viewEventDispatcher.addEventListener(type, listener);
		} 
		public override function removeViewListener(type:String, listener:Function):void {
			viewEventDispatcher.removeEventListener(type, listener);
		} 

		public override function addControllerListener(type:String, listener:Function):void {
			controllerEventDispatcher.addEventListener(type, listener);
		} 
		public override function removeControllerListener(type:String, listener:Function):void {
			controllerEventDispatcher.removeEventListener(type, listener);
		}
		
		// Event "dispatcher"
		
		public override function sendEvent(typ:String, prm:Object=undefined) : void {
			switch (typ) {
				case com.jeroenwijering.events.ViewEvent.FULLSCREEN:
					_player.fullscreen(prm['state']);
					break;
				case com.jeroenwijering.events.ViewEvent.ITEM:
					_player.playlist.currentIndex = prm['index'];
					break;
				case com.jeroenwijering.events.ViewEvent.LINK:
					_player.link(Number(prm['index']));
					break;
				case com.jeroenwijering.events.ViewEvent.LOAD:
					_player.load(prm['object']);
					break;
				case com.jeroenwijering.events.ViewEvent.MUTE:
					_player.mute(prm['state']);
					break;
				case com.jeroenwijering.events.ViewEvent.NEXT:
					_player.playlist.currentIndex++;
					break;
				case com.jeroenwijering.events.ViewEvent.PLAY:
					_player.play();
					break;
				case com.jeroenwijering.events.ViewEvent.PREV:
					_player.playlist.currentIndex--;
					break;
				case com.jeroenwijering.events.ViewEvent.REDRAW:
					_player.redraw();
					break;
				case com.jeroenwijering.events.ViewEvent.SEEK:
					_player.seek(prm['position']);
					break;
				case com.jeroenwijering.events.ViewEvent.STOP:
					_player.stop();
					break;
				case com.jeroenwijering.events.ViewEvent.TRACE:
					Logger.log(prm);
					break;
				case com.jeroenwijering.events.ViewEvent.VOLUME:
					_player.volume(prm['percentage']);
					break;
			}
		} 

		public override function get config():Object {
			var cfg:Object = {};
			
			for each (var i:String in describeType(_player.config).accessor.@name) {
				cfg[i] = TypeChecker.fromString(_player.config[i], TypeChecker.getType(_player.config, i));
			} 

			cfg['state'] = _player.state;
			
			return cfg;
		} 

		public override function get playlist():Array {
			return playlistToArray(_player.playlist);
		}
		
		private function playlistToArray(list:Playlist):Array {
			var arry:Array = [];
			
			for (var i:Number=0; i < list.length; i++) {
				arry.push(playlistItemToObject(list.getItemAt(i)));
			}
			
			return arry;
		}
		
		private function playlistItemToObject(item:PlaylistItem):Object {
			var obj:Object = {
				'author':		item.author,
				'date':			item.date,
				'description':	item.description,
				'duration':		item.duration,
				'file':			item.file,
				'image':		item.image,
				'link':			item.link,
				'start':		item.start,
				'streamer':		item.streamer,
				'tags':			item.tags,
				'type':			item.provider
			};
			
			for each (var i:String in item) {
				obj[i] = item[i];
			}
			
			return obj;
		}
		
		public override function getPluginConfig(plugin:Object):Object {
			var pluginParent:V4Plugin = (plugin as DisplayObject).parent as V4Plugin; 
			if (pluginParent) {
				return _player.config.pluginConfig(pluginParent.pluginName);
			} else {
				return new PluginConfig('');
			}
		}
		
		public function resize(width:Number, height:Number):void {
			viewRedraw(width, height);
		} 
		
	}
	
	
	
	
	
}