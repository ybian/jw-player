package com.longtailvideo.jwplayer.plugins {
	import com.longtailvideo.jwplayer.player.IPlayer;
	
	import flash.events.IEventDispatcher;

	/**
	 * All plugins must implement the <code>IPlugin</code> interface.
	 *  
	 * @author Pablo Schklowsky
	 */
	public interface IPlugin extends IEventDispatcher {
		function initPlugin(player:IPlayer, config:PluginConfig):void;
		function resize(width:Number, height:Number):void;
		function get id():String;
		function get visible():Boolean;
		function set visible(v:Boolean):void;
	}
}