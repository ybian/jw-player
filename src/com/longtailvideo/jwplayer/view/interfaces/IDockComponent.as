package com.longtailvideo.jwplayer.view.interfaces {
	import flash.display.DisplayObject;
	import flash.display.MovieClip;

	public interface IDockComponent extends IPlayerComponent {
		function addButton(icon:DisplayObject, text:String, clickHandler:Function, name:String = null):MovieClip;
		function removeButton(name:String):void;
		function show():void;
		function hide():void;
	}
}