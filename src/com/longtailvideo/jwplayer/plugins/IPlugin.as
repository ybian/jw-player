package com.longtailvideo.jwplayer.plugins {
	import com.longtailvideo.jwplayer.player.IPlayer;

	/**
	 * All plugins must implement the <code>IPlugin</code> interface.
	 *  
	 * @author Pablo Schklowsky
	 */
	public interface IPlugin {
		function initPlugin(player:IPlayer, config:PluginConfig):void;
		function resize(width:Number, height:Number):void;
		function get id():String;
		function get visible():Boolean;
		function set visible(v:Boolean):void;
		function get x():Number;
		function set x(pos:Number):void;
		function get y():Number;
		function set y(pos:Number):void;
	}
}