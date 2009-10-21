package com.longtailvideo.jwplayer.utils {
	
	
	public class PlayerVersion {
		private static const version:String = '$Rev$';
		
		public static function getVersion():Number {
			return Number(version.replace('Rev: ','').replace('$','').replace(' $',''))+1;
		}
	}
}