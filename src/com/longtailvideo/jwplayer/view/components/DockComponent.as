package com.longtailvideo.jwplayer.view.components {
	import flash.events.Event;
	import com.longtailvideo.jwplayer.view.interfaces.IDockComponent;
	import flash.display.DisplayObject;
	import com.longtailvideo.jwplayer.player.Player;
	
	
	public class DockComponent extends CoreComponent implements IDockComponent {
		public function DockComponent(player:Player) {
			//TODO: implement function
			super(player);
		}
		
		
		public function addButton(icon:DisplayObject, text:String, clickHandler:Function):void {
			//TODO: implement function
		}
		
		
		public function removeButton(name:String):void {
			//TODO: implement function
		}
		
		
		public function resize(width:Number, height:Number):void {
			//TODO: implement function
		}
	}
}