package com.longtailvideo.jwplayer.player {

	import com.jeroenwijering.events.ControllerEvent;
	import com.jeroenwijering.events.ModelEvent;
	import com.jeroenwijering.events.ViewEvent;
	import com.longtailvideo.jwplayer.events.PlayerEvent;
	
	import flash.external.ExternalInterface;

	public class JavascriptAPI {
		private var _player:Player;
		private var _emu:PlayerV4Emulation;

		private var controllerCallbacks:Object;		
		private var modelCallbacks:Object;		
		private var viewCallbacks:Object;		

		public function JavascriptAPI(player:Player) {
			_player = player;
			_player.addEventListener(PlayerEvent.JWPLAYER_READY, playerReady);

			_emu = PlayerV4Emulation.getInstance(_player);
			
			controllerCallbacks = {};
			modelCallbacks = {};
			viewCallbacks = {};
			
			setupListeners();
		}
		
		private function playerReady(evt:PlayerEvent):void {
			var newEvt:PlayerEvent = new PlayerEvent("");
			
			var callbacks:String = _player.config.playerready ? _player.config.playerready + "," + "playerReady" : "playerReady";  

			if (ExternalInterface.available) {
				for each (var callback:String in callbacks.replace(/\s/,"").split(",")) {
					ExternalInterface.call(callback,{
						id:newEvt.id,
						client:newEvt.client,
						version:newEvt.version
					});
				}
			}			
		}
		
		private function setupListeners():void {
			if (ExternalInterface.available) {
				ExternalInterface.addCallback("addControllerListener",addJSControllerListener);
				ExternalInterface.addCallback("addModelListener",addJSModelListener);
				ExternalInterface.addCallback("addViewListener",addJSViewListener);
				ExternalInterface.addCallback("removeControllerListener",removeJSControllerListener);
				ExternalInterface.addCallback("removeModelListener",removeJSModelListener);
				ExternalInterface.addCallback("removeViewListener",removeJSViewListener);
				ExternalInterface.addCallback("getConfig",getConfig);
				ExternalInterface.addCallback("getPlaylist",getPlaylist);
				ExternalInterface.addCallback("getPluginConfig",getJSPluginConfig);
				ExternalInterface.addCallback("loadPlugin",loadPlugin);
				ExternalInterface.addCallback("sendEvent",sendEvent);
			}
		}
		

		private function addJSControllerListener(type:String,callback:String):Boolean {
			type = type.toUpperCase();
			if (!controllerCallbacks.hasOwnProperty(type)) { controllerCallbacks[type] = []; }
			if ( (controllerCallbacks[type] as Array).indexOf(callback) < 0) {
				(controllerCallbacks[type] as Array).push(callback);
				_emu.addControllerListener(type, forwardControllerEvents);
			}
			return true;
		}
		
		private function removeJSControllerListener(type:String,callback:String):Boolean {
			type = type.toUpperCase();
			var listeners:Array = (controllerCallbacks[type] as Array);
			var idx:Number = listeners ? listeners.indexOf(callback) : -1; 
			if (idx >= 0) {
				listeners.splice(idx, 1);
				_emu.removeControllerListener(type.toUpperCase(), forwardControllerEvents);
				return true;
			} 
			return false;
		}


		private function addJSModelListener(type:String,callback:String):Boolean {
			type = type.toUpperCase();
			if (!modelCallbacks.hasOwnProperty(type)) { modelCallbacks[type] = []; }
			if ( (modelCallbacks[type] as Array).indexOf(callback) < 0) {
				(modelCallbacks[type] as Array).push(callback);
				_emu.addModelListener(type, forwardModelEvents);
			}
			return true;
		}
		
		private function removeJSModelListener(type:String,callback:String):Boolean {
			type = type.toUpperCase();
			var listeners:Array = (modelCallbacks[type] as Array);
			var idx:Number = listeners ? listeners.indexOf(callback) : -1; 
			if (idx >= 0) {
				listeners.splice(idx, 1);
				_emu.removeModelListener(type.toUpperCase(), forwardModelEvents);
				return true;
			} 
			return false;
		}


		private function addJSViewListener(type:String,callback:String):Boolean {
			type = type.toUpperCase();
			if (!viewCallbacks.hasOwnProperty(type)) { viewCallbacks[type] = []; }
			if ( (viewCallbacks[type] as Array).indexOf(callback) < 0) {
				(viewCallbacks[type] as Array).push(callback);
				_emu.addViewListener(type.toUpperCase(), forwardViewEvents);
			}
			return true;
		}
		
		private function removeJSViewListener(type:String,callback:String):Boolean {
			type = type.toUpperCase();
			var listeners:Array = (viewCallbacks[type] as Array);
			var idx:Number = listeners ? listeners.indexOf(callback) : -1; 
			if (idx >= 0) {
				listeners.splice(idx, 1);
				_emu.removeViewListener(type.toUpperCase(), forwardViewEvents);
				return true;
			} 
			return false;
		}

		private function getConfig():Object {
			return _emu.config;
		}
		
		private function getPlaylist():Object {
			return _emu.playlist;
		}
		
		private function getJSPluginConfig(pluginId:String):Object {
			return _player.config.pluginConfig(pluginId);
		}
		
		private function loadPlugin(plugin:String):Object {
			return {error:'This function is no longer supported.'}
		}
		
		private function sendEvent(type:String, data:Object = null):void {
			var dat:Object = {};
			switch (type) {
				case com.jeroenwijering.events.ViewEvent.FULLSCREEN:
					dat['state'] = data;
					break;
				case com.jeroenwijering.events.ViewEvent.ITEM:
					dat['index'] = data;
					break;
				case com.jeroenwijering.events.ViewEvent.LINK:
					dat['index'] = data;
					break;
				case com.jeroenwijering.events.ViewEvent.LOAD:
					dat['object'] = data;
					break;
				case com.jeroenwijering.events.ViewEvent.MUTE:
					dat['state'] = data;
					break;
				case com.jeroenwijering.events.ViewEvent.SEEK:
					dat['position'] = data;
					break;
				case com.jeroenwijering.events.ViewEvent.VOLUME:
					dat['percentage'] = data;
					break;
				default:
					dat = data;
					break;
			}
			_emu.sendEvent(type.toUpperCase(), dat);
		}
		
		private function forwardControllerEvents(evt:ControllerEvent):void {
			if (controllerCallbacks.hasOwnProperty(evt.type)) {
				for each (var callback:String in controllerCallbacks[evt.type]) {
					if (ExternalInterface.available) {
						ExternalInterface.call(callback, evt.data);
					}
				}
			}
		}

		private function forwardModelEvents(evt:ModelEvent):void {
			if (modelCallbacks.hasOwnProperty(evt.type)) {
				for each (var callback:String in modelCallbacks[evt.type]) {
					if (ExternalInterface.available) {
						ExternalInterface.call(callback, evt.data);
					}
				}
			}
		}

		private function forwardViewEvents(evt:ViewEvent):void {
			if (viewCallbacks.hasOwnProperty(evt.type)) {
				for each (var callback:String in viewCallbacks[evt.type]) {
					if (ExternalInterface.available) {
						ExternalInterface.call(callback, evt.data);
					}
				}
			}
		}

	}

}