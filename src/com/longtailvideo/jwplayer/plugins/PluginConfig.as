package com.longtailvideo.jwplayer.plugins {
	

	public dynamic class PluginConfig {
		private var _name:String;

		public function PluginConfig(pluginName:String) {
			this._name = pluginName;
			this['width'] = 0;
			this['height'] = 0;
		}
		
		public function get name():String {
			return _name;
		}
		
	}
}