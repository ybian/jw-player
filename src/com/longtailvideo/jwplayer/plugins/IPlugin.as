package com.longtailvideo.jwplayer.plugins {
	import com.longtailvideo.jwplayer.player.Player;
	
	import flash.events.IEventDispatcher;

	/**
	 * All plugins must implement the <code>IPlugin</code> interface.
	 *  
	 * @author Pablo Schklowsky
	 */
	public interface IPlugin extends IEventDispatcher {
		function initializePlugin(player:Player, config:PluginConfig):void;
		function resize(width:Number, height:Number):void;
	}
}