package com.longtailvideo.jwplayer.player {
	
	
	public class PlayerVersion {
		protected static var _version:String = "5.0.560 beta";
		protected static var _commercial:Boolean = Boolean(CONFIG::commercial);
		
		public static function get version():String{
			return _version;
		}
		
		public static function get commercial():Boolean{
			return _commercial;
		}
	}
}