/**
 * A button from within the dock.
 **/
package com.longtailvideo.jwplayer.view.components {
	import flash.display.*;
	import flash.events.*;
	import flash.geom.ColorTransform;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import mx.utils.ColorUtil;
	
	
	public class DockButton extends ComponentButton {
		/** Reference to the text field **/
		private var text:TextField;
		/** Reference to the click handler **/
		private var clickFunction:Function;

		/**
		 * Constructor; sets up the button.
		 *
		 * @param icn	The image to display in the button.
		 * @param txt	The text to display in the button caption.
		 * @param fcn	The function to call when the button is clicked
		 * @param clr	The rollover color of the dock icon.
		 **/
		public function DockButton(icn:DisplayObject, txt:String, hdl:Function, frontColor:uint, outColor:uint, overColor:uint):void {
			//TODO: Make this work with the existing skin
			clickFunction = hdl;
			var background:Sprite = new Sprite();
			drawBackground(background, outColor);
			super(icn, null, null, outColor, overColor, background);
			text = new TextField();
			text.text = txt;
			text.x = 0;
			text.y = 30;
			text.width = 50;
			text.height = 20;
			var textFormat:TextFormat = new TextFormat();
			textFormat.align = TextFormatAlign.CENTER;
			text.setTextFormat(textFormat);
			_imageLayer.addChild(text);
			mouseChildren = false;
			buttonMode = true;
			if (icn) {
				setImage(icn);
			}
			//TODO: Figure out why you can't color transform this.
			//_outIcon.transform.colorTransform = new ColorTransform(frontColor);
			text.textColor = frontColor;
		}
		
		
		/** When rolling over, the background is color changed. **/
		protected override function overHandler(evt:MouseEvent):void {
			drawBackground(_backgroundLayer as Sprite, _overColor);
		}
		
		
		/** When rolling over, the background is color changed. **/
		protected override function outHandler(evt:MouseEvent):void {
			drawBackground(_backgroundLayer as Sprite, _outColor);
		}
		
		/** Draws the dock icon background **/
		private function drawBackground(backgroundSprite:Sprite, color:uint):void {
			backgroundSprite.graphics.clear();
			backgroundSprite.graphics.beginFill(color,1);
			backgroundSprite.graphics.drawRoundRect(0,0,50,50,10);
			backgroundSprite.graphics.endFill();
		}
		
		/** Handles mouse clicks **/
		protected override function clickHandler(event:MouseEvent):void {
			clickFunction();
		}
		
		
		/**
		 * Change the image in the button.
		 *
		 * @param dpo	The new caption for the button.
		 **/
		private function setImage(dpo:DisplayObject):void {
			if (_outIcon) {
				_imageLayer.removeChild(_outIcon);
			}
			if (dpo) {
				_outIcon = dpo;
				_imageLayer.addChild(_outIcon);
			}
			_outIcon.x = Math.round((_backgroundLayer.width - _outIcon.width) / 2);
			_outIcon.y = Math.round(_backgroundLayer.height / 2 - _outIcon.height);
		}
	}
}