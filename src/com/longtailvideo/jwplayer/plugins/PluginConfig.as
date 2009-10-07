package com.longtailvideo.jwplayer.plugins {
	

	public dynamic class PluginConfig {
		private var _name:String;

		public function PluginConfig(pluginName:String) {
			this._name = pluginName;
		}
		
		public function get name():String {
			return _name;
		}
		
	}
}