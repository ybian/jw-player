/**
 * A button from within the dock.
 **/
package com.longtailvideo.jwplayer.view.components {
	import flash.display.*;
	import flash.events.*;
	import flash.geom.ColorTransform;
	import flash.text.TextField;
	
	
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
			clickFunction = hdl;
			var background:Sprite = new Sprite();
			background.graphics.drawRoundRect(10,10,50,50,5);
			background.transform.colorTransform = new ColorTransform(outColor);
			text = new TextField();
			text.x = 5;
			text.y = 40;
			text.width = 60;
			text.height = 20;
			addChild(text);
			super(icn, null, null, outColor, overColor, background);
			mouseChildren = false;
			buttonMode = true;
			if (icn) {
				setImage(icn);
			}
			text.text = txt;
			addEventListener(MouseEvent.CLICK, hdl);
			_outIcon.transform.colorTransform = new ColorTransform(frontColor);
			text.textColor = frontColor;
		}
		
		
		/** When rolling over, the background is color changed. **/
		protected override function overHandler(evt:MouseEvent):void {
			_background.transform.colorTransform = new ColorTransform(_overColor);
		}
		
		
		/** When rolling over, the background is color changed. **/
		protected override function outHandler(evt:MouseEvent):void {
			_background.transform.colorTransform =  new ColorTransform(_outColor);
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
				removeChild(_outIcon);
			}
			if (dpo) {
				_outIcon = dpo;
				addChild(_outIcon);
			}
			_outIcon.x = Math.round(width / 2 - _outIcon.width / 2);
			_outIcon.y = Math.round(height / 2 - _outIcon.height / 2);
		}
	}
}