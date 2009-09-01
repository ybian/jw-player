package com.longtailvideo.jwplayer.view {
	import com.longtailvideo.jwplayer.utils.AssetLoader;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.ErrorEvent;
	import flash.events.Event;

	public class SWFSkin extends SkinBase implements ISkin {

		public function SWFSkin(loadedSkin:DisplayObject=null) {
			if (loadedSkin) {
				overwriteSkin(loadedSkin);
			}
		}

		protected function overwriteSkin(newSkin:DisplayObject):void {
			if (newSkin is Sprite) {
				_skin = newSkin as Sprite;
			} else if (newSkin != null) {
				_skin = new Sprite();
				_skin.addChild(newSkin);
			}
		}

		public override function load(url:String=null):void {
			if (url) {
				var loader:AssetLoader = new AssetLoader();
				loader.addEventListener(Event.COMPLETE, loadComplete);
				loader.addEventListener(ErrorEvent.ERROR, loadError);
				loader.load(url, DisplayObject);
			} else if (_skin.numChildren == 0) {
				sendError("Skin must load from URL if skin is empty.");
			}
		}

		protected function loadComplete(evt:Event):void {
			var loader:AssetLoader = AssetLoader(evt.target);
			overwriteSkin(DisplayObjectContainer(loader.loadedObject).getChildByName('player'));
			dispatchEvent(new Event(Event.COMPLETE));
		}

		protected function loadError(evt:ErrorEvent):void {
			sendError(evt.text);
		}

		public override function getSkinProperties():SkinProperties {
			return null;
		}

	}
}