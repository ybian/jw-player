package com.longtailvideo.jwplayer.view {
	import flash.display.DisplayObject;

	public interface IDockComponent {
		
		function addButton(icon:DisplayObject, clickHandler:Function):void;
		function hide(state:Boolean):void;

	}
}