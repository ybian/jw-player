package com.longtailvideo.jwplayer.view.interfaces {
	import com.longtailvideo.jwplayer.events.IGlobalEventDispatcher;
	
	import flash.display.DisplayObject;

	public interface IDockComponent extends IGlobalEventDispatcher {
		function addButton(name:String, icon:DisplayObject, clickHandler:Function):void;
		function removeButton(name:String):void;
		function resize(width:Number, height:Number):void;
		function show():void;
		function hide():void;
	}
}