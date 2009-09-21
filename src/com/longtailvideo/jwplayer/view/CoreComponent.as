package com.longtailvideo.jwplayer.view {
	import com.longtailvideo.jwplayer.events.GlobalEventDispatcher;
	import com.longtailvideo.jwplayer.events.IGlobalEventDispatcher;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.IEventDispatcher;

	public class CoreComponent extends MovieClip implements IGlobalEventDispatcher {

		private var _dispatcher:IGlobalEventDispatcher;

		public function CoreComponent() {
			_dispatcher = new GlobalEventDispatcher();
			super();
		}
		
		public function resize(width:Number, height:Number):void {
			return;
		}
		
		public function hide():void {
			return;
		}
		
		public function show():void {
			return;
		}
		
		public function block(name:String, timeout:Number):void {
			return;
		}
		
		public function unblock(name:String, timeout:Number):void {
			return;
		}
		
		public function lock(name:String, timeout:Number):void {
			return;
		}
		
		public function unlock(name:String, timeout:Number):void {
			return;
		}
		
		///////////////////////////////////////////		
		/// IGlobalEventDispatcher implementation
		///////////////////////////////////////////		
		/**
		 * @inheritDoc
		 */
		public function addGlobalListener(listener:Function):void {
			_dispatcher.addGlobalListener(listener);
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function removeGlobalListener(listener:Function):void {
			_dispatcher.removeGlobalListener(listener);
		}
		
		
		/**
		 * @inheritDoc
		 */
		public override function dispatchEvent(event:Event):Boolean {
			_dispatcher.dispatchEvent(event);
			return super.dispatchEvent(event);
		}
	}
}