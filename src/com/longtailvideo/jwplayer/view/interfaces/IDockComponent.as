package com.longtailvideo.jwplayer.view.interfaces {
	import com.longtailvideo.jwplayer.events.IGlobalEventDispatcher;
	
	import flash.display.DisplayObject;

	public interface IDockComponent extends IPlayerComponent {
		function addButton(icon:DisplayObject, text:String, clickHandler:Function):void;
		function removeButton(name:String):void;
		function show():void;
		function hide():void;
	}
}