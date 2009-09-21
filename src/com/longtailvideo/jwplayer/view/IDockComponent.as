package com.longtailvideo.jwplayer.view {
	import flash.display.DisplayObject;

	public interface IDockComponent {
		function addButton(name:String, icon:DisplayObject, clickHandler:Function):void;
		function removeButton(name:String):void;
	}
}