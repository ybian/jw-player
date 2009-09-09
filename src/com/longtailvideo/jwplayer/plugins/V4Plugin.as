package com.longtailvideo.jwplayer.plugins {
	import com.jeroenwijering.events.AbstractView;
	import com.jeroenwijering.events.PluginInterface;

	import flash.display.Sprite;

	public class V4Plugin extends Sprite implements IPlugin {
		var vw:AbstractView;
		var plug:PluginInterface;

		public function V4Plugin(plugin:PluginInterface) {
			vw = new AbstractView();
			plug = plugin;
		}

		public function initializePlugin(player:Player, config:PluginConfig):void {
			plug.initializePlugin(vw);
		}

	}

}