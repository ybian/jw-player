package com.longtailvideo.jwplayer.events {
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;

	public class GlobalEventDispatcher extends EventDispatcher {
		
		private var _globalListeners:Dictionary = new Dictionary();
		
		public function addGlobalListener(listener:Function):void {
			_globalListeners[listener] = true;
		}
		
		public function removeGlobalListener(listener:Function):void {
			delete _globalListeners[listener];
		}
		
		public override function dispatchEvent(event:Event) : Boolean {
			for each (var listener:Function in _globalListeners) {
				listener(event);
			}
			return super.dispatchEvent(event);
		} 
		
	}
}