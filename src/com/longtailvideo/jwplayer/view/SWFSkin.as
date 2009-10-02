package com.longtailvideo.jwplayer.view {
	import com.longtailvideo.jwplayer.utils.AssetLoader;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
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
		
		public override function getSkinElement(component:String, element:String):DisplayObject {
			var result:DisplayObject = super.getSkinElement(component, element);
			switch (component) {
				case 'controlbar':
					var buttonStart:Number = element.indexOf('Button');
					var sliderStart:Number = element.indexOf('Slider');
					if (buttonStart > 0) {
						var buttonElement:String = element.substr(buttonStart, element.length);
						var buttonName:String = element.substr(0,buttonStart+6);
						switch (buttonElement) {
							case 'Button':
								result = super.getSkinElement(component, buttonName)['icon'];
								break;
							case 'ButtonBack':
								result = super.getSkinElement(component, buttonName);
								//result = button.removeChild(button.getChildByName("icon"));
								break;
						}
					} else if (sliderStart > 0) {
						var sliderElement:String = element.substr(sliderStart, element.length);
						var sliderName:String = element.substr(0,sliderStart+6);
						switch (sliderElement) {
							case 'SliderRail':
								result = super.getSkinElement(component, sliderName)['rail'];
								break;
							case 'SliderBuffer':
								if (element == "volumeSliderBuffer"){
									//result = super.getSkinElement(component, sliderName)['mark'];
								} else {
									result = super.getSkinElement(component, sliderName)['mark'];
								}
								break;
							case 'SliderProgress':
								if (element == "volumeSliderProgress"){
									//result = super.getSkinElement(component, sliderName)['mark'];
								} else {
									result = super.getSkinElement(component, sliderName)['done'];
								}
								break;
							case 'SliderThumb':
								result = super.getSkinElement(component, sliderName)['icon'];
								break;
						}
					}
					break;
				case 'display':
					switch (element) {
						case 'errorIcon':
							if (result['icn']) {
								result = result['icn'];
							}
							break;
					}
			}
			return result;
		}

	}
}