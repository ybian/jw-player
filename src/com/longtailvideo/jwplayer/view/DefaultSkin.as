package com.longtailvideo.jwplayer.view
{
	import flash.display.DisplayObject;

	public class DefaultSkin extends SkinBase implements ISkin
	{
		[Embed(source="../../../../../assets/flash/skin/bluemetal.swf")]
		private var EmbeddedSkin:Class;
		private var loadedSkin:ISkin;

		public function DefaultSkin()
		{
			var skinObj:Object = new EmbeddedSkin();
			try {
				loadedSkin = new SWFSkin(skinObj as DisplayObject);
			} catch (e:Error) {
				// Skin error
			}
		}

		public override function hasComponent(component:String):Boolean
		{
			return loadedSkin.hasComponent(component);
		}
		
		public override function getSkinElement(component:String, element:String):DisplayObject
		{
			return loadedSkin.getSkinElement(component, element);
		}
		
		public override function addSkinElement(component:String, element:DisplayObject, name:String=null):void {
			return loadedSkin.addSkinElement(component, element, name);
		}
				
	}
}