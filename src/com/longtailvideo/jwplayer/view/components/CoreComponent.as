package com.longtailvideo.jwplayer.view.components {
	import com.longtailvideo.jwplayer.events.GlobalEventDispatcher;
	import com.longtailvideo.jwplayer.events.IGlobalEventDispatcher;
	import com.longtailvideo.jwplayer.player.IPlayer;
	
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.Event;

	public class CoreComponent extends MovieClip implements IGlobalEventDispatcher {

		private var _dispatcher:IGlobalEventDispatcher;
		protected var _player:IPlayer;

		public function CoreComponent(player:IPlayer) {
			_dispatcher = new GlobalEventDispatcher();
			_player = player;
			super();
		}
		
		public function hide():void {
			this.visible = false;
		}
		
		public function show():void {
			this.visible = true;
		}
		
		protected function get player():IPlayer {
			return _player;
		}

		protected function getSkinElement(component:String, element:String):DisplayObject {
			return player.skin.getSkinElement(component,element);
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