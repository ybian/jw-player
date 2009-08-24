package com.longtailvideo.jwplayer.controller {
	import com.longtailvideo.jwplayer.events.GlobalEventDispatcher;
	import com.longtailvideo.jwplayer.events.PlayerEvent;
	import com.longtailvideo.jwplayer.model.Model;
	import com.longtailvideo.jwplayer.player.Player;
	import com.longtailvideo.jwplayer.utils.Configger;
	import com.longtailvideo.jwplayer.utils.RootReference;
	import com.longtailvideo.jwplayer.view.View;
	
	import flash.events.ErrorEvent;
	import flash.events.Event;

	/**
	 * Sent when the player has been initialized and skins and plugins have been successfully loaded.
	 *
	 * @eventType com.longtailvideo.jwplayer.events.PlayerEvent.JWPLAYER_READY
	 */
	[Event(name="jwplayerReady", type = "com.longtailvideo.jwplayer.events.PlayerEvent")]

	/**
	 * Sent when the player has entered the ERROR state
	 *
	 * @eventType com.longtailvideo.jwplayer.events.PlayerEvent.JWPLAYER_ERROR
	 */
	[Event(name="jwplayerError", type = "com.longtailvideo.jwplayer.events.PlayerEvent")]


	/**
	 * The Controller is responsible for handling Model / View events and calling the appropriate responders
	 *  
	 * @author Pablo Schklowsky
	 */
	public class Controller extends GlobalEventDispatcher {
		private var _player:Player;
		private var _model:Model;
		private var _view:View;
		
		public function Controller(player:Player, model:Model, view:View) {
			var rootRef:RootReference = new RootReference(player);
						
			_player = player;
			_model = model;
			_view = view;
			
		}
		
		public function setupPlayer():void {
			var configger:Configger = new Configger();
			configger.addEventListener(Event.COMPLETE, configLoaded);
			configger.addEventListener(ErrorEvent.ERROR, configFailed);
			
			try {
				configger.loadConfig();
			} catch(e:Error) {
				errorState();
			}
		}
		
		private function configLoaded(evt:Event):void {
			
		}

		private function configFailed(evt:ErrorEvent):void {
			
		}
		
		private function errorState():void {
			dispatchEvent(new PlayerEvent(PlayerEvent.JWPLAYER_ERROR));	
		}
		
	}
}