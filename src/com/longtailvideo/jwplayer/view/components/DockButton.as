/**
 * A button from within the dock.
 **/
package com.longtailvideo.jwplayer.view.components {
	import com.longtailvideo.jwplayer.model.Color;
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.ColorTransform;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	
	public class DockButton extends ComponentButton {
		/** Reference to the text field **/
		protected var _text:TextField;
		/** Asset color **/
		protected var _assetColor:Color;
		/** Whether skin contains a background **/
		private var _drawBackground:Boolean;
		
		
		/** Constructor **/
		public function DockButton():void {
			_text = new TextField();
			_text.x = 0;
			_text.y = 30;
			_text.width = 50;
			_text.height = 20;
		}
		
		
		/** Sets up the button **/
		public override function init():void {
			if (!_background){
				_drawBackground = true;
				_background = new Sprite();
				drawBackground(_background as Sprite, _outColor);
			}
			_background.transform.colorTransform = createColorTransform(_outColor);
			super.init();
			_imageLayer.addChild(_text);
			_assetColor = _assetColor ? _assetColor : new Color(0xFFFFFF);
			_outIcon.transform.colorTransform = createColorTransform(_assetColor);
			_text.textColor = _assetColor.color;
			mouseChildren = false;
			buttonMode = true;
		}
		
		
		protected function createColorTransform(color:Color):ColorTransform {
			var colorTransform:ColorTransform = new ColorTransform();
			colorTransform.color = color.color;
			return colorTransform;
		}
		
		/** When rolling over, the background is color changed. **/
		protected override function overHandler(evt:MouseEvent):void {
			if (_drawBackground) {
				drawBackground(_background as Sprite, _overColor);
			} else {
				_background.transform.colorTransform = createColorTransform(_overColor);
			}
		}
		
		
		/** When rolling over, the background is color changed. **/
		protected override function outHandler(evt:MouseEvent):void {
			if (_drawBackground) {
				drawBackground(_background as Sprite, _outColor);
			} else {
				_background.transform.colorTransform = createColorTransform(_outColor);
			}
		}
		
		protected override function clickHandler(evt:MouseEvent):void {
			super.clickHandler(evt);
			centerText();
		}
		
		
		/** Draws the dock icon background **/
		private function drawBackground(backgroundSprite:Sprite, color:Color):void {
			backgroundSprite.graphics.clear();
			backgroundSprite.graphics.beginFill(color ? color.color : 0x000000, 0.55);
			backgroundSprite.graphics.drawRect(0, 0, 50, 50);
			backgroundSprite.graphics.endFill();
			updateClickLayer();
		}
		
		
		public function set text(text:String):void {
			_text.text = text;
			centerText();
		}
		
		public function centerText():void {
			var textFormat:TextFormat = new TextFormat();
			textFormat.align = TextFormatAlign.CENTER;
			textFormat.font = "_sans";
			textFormat.size = 11;
			_text.setTextFormat(textFormat);
		}
		
		protected override function centerIcon(icon:DisplayObject):void {
			if (icon) {
				if (_background) {
					icon.x = (_background.width - icon.width) / 2;
					icon.y = (_background.height - icon.height * 1.5) / 2;
				} else {
					icon.x = 0;
					icon.y = 0;
				}
			}
		}
		
		public function set assetColor(assetColor:Color):void {
			_assetColor = assetColor;
		}
		
		/** Legacy support**/		
		public function get field():TextField {
			return _text;
		}
	}
}