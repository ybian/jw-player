package com.longtailvideo.jwplayer.plugins {
	import com.jeroenwijering.events.PluginInterface;
	import com.longtailvideo.jwplayer.player.Player;
	import com.longtailvideo.jwplayer.player.PlayerV4Emulation;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;

	public class V4Plugin extends Sprite implements IPlugin {
		private var plug:PluginInterface;
		public var pluginName:String;

		public function V4Plugin(plugin:PluginInterface, pluginName:String) {
			plug = plugin;
			this.pluginName = pluginName;
			addChild(plug as DisplayObject);
		}

		public function initPlugin(player:Player, config:PluginConfig):void {
			if ((plug as Object).hasOwnProperty('config')) {
				(plug as Object).config = config;
			}
			plug.initializePlugin(PlayerV4Emulation.getInstance());
		}
		
		public function resize(width:Number, height:Number):void {
			(plug as DisplayObject).x = 0;
			(plug as DisplayObject).y = 0;
		}

	}

}