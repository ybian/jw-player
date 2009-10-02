package com.longtailvideo.jwplayer.plugins {
	import com.longtailvideo.jwplayer.events.MediaEvent;
	import com.longtailvideo.jwplayer.events.MediaStateEvent;
	import com.longtailvideo.jwplayer.events.PlaylistEvent;
	import com.longtailvideo.jwplayer.player.Player;
	
	import flash.events.Event;
	import flash.display.DisplayObject;
	
	
	public class Display extends BasePlugin {
		public function Display() {
			player.skin.getSkinElement('display', 'playIcon');
			player.skin.getSkinElement('display', 'errorIcon');
			player.skin.getSkinElement('display', 'bufferIcon');
			player.skin.getSkinElement('display', 'muteIcon');
		}
		
		
		public override function initializePlugin(player:Player, config:PluginConfig):void {
			addEventListeners();
		}
		
		public function setIcon(icon:String):void {
			var displayIcon:DisplayObject = player.skin.getSkinElement('display', icon);
		}
		
		public function setText(icon:String):void {
			var displayIcon:DisplayObject = player.skin.getSkinElement('display', icon);
		}
		
		
		
		private function errorHandler(event:Event):void {
		}
		
		
		private function volumeHandler(event:Event):void {
		}
		
		
		private function bufferHandler(event:Event):void {
		}
		
		
		private function stateHandler(event:Event):void {
		}
		
		private function itemHandler(event:Event):void {
		}
		
		public override function resize(width:Number, height:Number):void {
			//TODO: implement function
		}
	}
}