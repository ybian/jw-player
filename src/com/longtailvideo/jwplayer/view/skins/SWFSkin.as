package com.longtailvideo.jwplayer.view.skins {
	import com.longtailvideo.jwplayer.utils.AssetLoader;
	import com.longtailvideo.jwplayer.view.interfaces.ISkin;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import com.longtailvideo.jwplayer.utils.Draw;

	public class SWFSkin extends SkinBase implements ISkin {
		
		private var props:SkinProperties;


		public function SWFSkin(loadedSkin:DisplayObject=null) {
			props = new SkinProperties();
			
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
			if (_skin.getChildByName('controlbar')) {
				props['controlbar.size'] = _skin.getChildByName('controlbar').height;
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
			return props;
		}
		
		public override function getSkinElement(component:String, element:String):DisplayObject {
			// Hack for the error icon
			if (component == 'display' && element == 'errorIcon') {
				if (super.getSkinElement(component, 'errorIcon')['icn']){
					var errorButton:Sprite = Draw.clone(super.getSkinElement('display','playIcon') as Sprite) as Sprite;
					errorButton.removeChild(errorButton['icn']);
					errorButton.x = 0;
					errorButton.y = 0;
					var errorIcon:Sprite = super.getSkinElement(component, 'errorIcon')['icn'];
					errorButton.addChild(errorIcon);
					var errorButttonBackground:DisplayObject = errorButton.getChildAt(0);
					errorIcon.x = errorButttonBackground.x + (errorButttonBackground.width - errorIcon.width) / 2;
					errorIcon.y = errorButttonBackground.y + (errorButttonBackground.height - errorIcon.height) / 2;
					return errorButton;
				}
			}
			return super.getSkinElement(component, element);
		}
		
		public function getTranslatedSkinElement(component:String, element:String):DisplayObject {
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
								result = getSubElement('icon', result);
								break;
							case 'ButtonBack':
								var button:MovieClip = super.getSkinElement(component, buttonName) as MovieClip;
								if (button) {
									(button.getChildByName("icon") as DisplayObject).alpha = 0;
									result = button;
								}
								break;
						}
					} else if (sliderStart > 0) {
						var sliderElement:String = element.substr(sliderStart, element.length);
						var sliderName:String = element.substr(0,sliderStart+6);
						result = super.getSkinElement(component, sliderName);
						switch (sliderElement) {
							case 'SliderRail':
								result = getSubElement('rail', result);
								break;
							case 'SliderBuffer':
								if (element == "volumeSliderBuffer"){
									result = null;
								} else {
									result = getSubElement('mark', result);
								}
								break;
							case 'SliderProgress':
								if (element == "volumeSliderProgress"){
									result = null;
								} else {
									result = getSubElement('done', result);
								}
								break;
							case 'SliderThumb':
								result = getSubElement('icon', result);
								break;
						}
					} else if (element == 'back' || element == 'shade') {
						super.getSkinElement(component, element);
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
		
		private function getSubElement(subElement:String, element:DisplayObject):DisplayObject {
			var result:DisplayObject;
			if (element) {
				result = element[subElement];
			}
			return result;
		}
		
		public override function getSWFSkin():Sprite {
			return _skin;
		}

	}
}