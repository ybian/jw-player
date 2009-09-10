package com.longtailvideo.jwplayer.plugins {
	import com.jeroenwijering.events.AbstractView;
	import com.jeroenwijering.events.PluginInterface;
	import com.longtailvideo.jwplayer.player.Player;
	
	import flash.display.Sprite;

	public class V4Plugin extends Sprite implements IPlugin {
		private var vw:AbstractView;
		private var plug:PluginInterface;

		public function V4Plugin(plugin:PluginInterface) {
			vw = new AbstractView();
			plug = plugin;
		}

		public function initializePlugin(player:Player, config:PluginConfig):void {
			plug.initializePlugin(vw);
		}
		
		public function resize(width:Number, height:Number):void {
			
		}

	}

}