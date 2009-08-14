package com.longtailvideo.jwplayer.model {
	import flash.events.EventDispatcher;
	

	/**
	 * Configuration data for the player 
	 * 
  	 * @author Pablo Schklowsky
	 */
	public class PlayerConfig extends EventDispatcher {
		public function PlayerConfig(config:Object) {
			for (var x:String in config) {
				try {
					this[x] = config[x];
				} catch (e:Error) {
					trace(x + " not found in PlayerConfig.");
				}
			}
		}
		
		public function get file():String { return ""; }
		public function set file(s:String):void { }
		
	}
}