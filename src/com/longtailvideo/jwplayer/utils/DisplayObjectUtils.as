package com.longtailvideo.jwplayer.utils {
	import flash.display.DisplayObjectContainer;
	import flash.display.DisplayObject;
	import flash.utils.getQualifiedClassName;
	
	
	
	public class DisplayObjectUtils {
		
		public static function enumerateChildren(displayObject:DisplayObjectContainer):void{
			try {
				for (var i:Number = 0 ; i < displayObject.numChildren; i++){
					Logger.log(displayObject.getChildAt(i).name+":"+flash.utils.getQualifiedClassName(displayObject.getChildAt(i)));
				}
			} catch (err:Error){
				
			}
		}
	}
}