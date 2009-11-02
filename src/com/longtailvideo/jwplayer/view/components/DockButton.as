/**
 * A button from within the dock.
 **/
package com.longtailvideo.jwplayer.view.components {
	import com.longtailvideo.jwplayer.model.Color;
	import flash.display.*;
	import flash.events.*;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.geom.ColorTransform;
	import flash.text.TextFieldAutoSize;
	
	
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
			super.init();
			_imageLayer.addChild(_text);
			_assetColor = _assetColor ? _assetColor : new Color(0xFFFFFF);
			var iconColor:ColorTransform = new ColorTransform();
			iconColor.color = _assetColor.color;
			_outIcon.transform.colorTransform = iconColor;
			_text.textColor = _assetColor.color;
			mouseChildren = false;
			buttonMode = true;
		}
		
		
		/** When rolling over, the background is color changed. **/
		protected override function overHandler(evt:MouseEvent):void {
			if (_drawBackground) {
				drawBackground(_background as Sprite, _overColor);
			} else {
				_background.transform.colorTransform = new ColorTransform(_overColor.color);
			}
		}
		
		
		/** When rolling over, the background is color changed. **/
		protected override function outHandler(evt:MouseEvent):void {
			if (_drawBackground) {
				drawBackground(_background as Sprite, _outColor);
			} else {
				_background.transform.colorTransform = new ColorTransform(_outColor.color);
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