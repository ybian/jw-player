package com.longtailvideo.jwplayer.utils {
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.utils.getQualifiedClassName;
	import flash.display.DisplayObjectContainer;
	
	
	public class Draw {
		/**
		 * Clone a sprite / movieclip.
		 *
		 * @param tgt	Sprite to clone.
		 * @param adc	Add as child to the parent displayobject.
		 *
		 * @return		The clone; not yet added to the displaystack.
		 **/
		public static function clone(tgt:Sprite, adc:Boolean = false):DisplayObject {
			var nam:String = getQualifiedClassName(tgt);
			var cls:Class;
			try {
				cls = tgt.loaderInfo.applicationDomain.getDefinition(nam) as Class;
			} catch (e:Error) {
				cls = Object(tgt).constructor;
			}
			var dup:* = new cls();
			dup.transform = tgt.transform;
			dup.filters = tgt.filters;
			dup.cacheAsBitmap = tgt.cacheAsBitmap;
			dup.opaqueBackground = tgt.opaqueBackground;
			if (adc == true) {
				var idx:Number = tgt.parent.getChildIndex(tgt);
				tgt.parent.addChildAt(dup, idx + 1);
			}
			return dup;
		}
		
		
		/**
		 * Completely clear the contents of a displayobject.
		 *
		 * @param tgt	Displayobject to clear.
		 **/
		public static function clear(tgt:DisplayObjectContainer):void {
			var len:Number = tgt.numChildren;
			for (var i:Number = 0; i < len; i++) {
				tgt.removeChildAt(0);
			}
			tgt.scaleX = tgt.scaleY = 1;
		}
	}
}