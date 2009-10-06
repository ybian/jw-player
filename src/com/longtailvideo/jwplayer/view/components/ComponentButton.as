package com.longtailvideo.jwplayer.view.components {
	import com.longtailvideo.jwplayer.events.ViewEvent;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	
	
	public class ComponentButton extends Sprite {
		protected var _background:DisplayObject;
		protected var _outIcon:DisplayObject;
		protected var _overIcon:DisplayObject;
		protected var _outShade:uint;
		protected var _overShade:uint;
		protected var _text:String;
		protected var _clickEventType:String;
		protected var _clickEventData:*;
		
		public function ComponentButton(outIcon:DisplayObject, clickEventType:String = null, clickEventData:* = null, outShade:uint = 0, overShade:uint = 0, background:DisplayObject = null, overIcon:DisplayObject = null, text:String = null) {
			if (background) {
				background.x = 0;
				background.y = 0;
				addChildAt(background,0);
			}
			outIcon.x = 0;
			outIcon.y = 0;
			outIcon.scaleX = 1;
			outIcon.scaleY = 1;
			_outIcon = outIcon;
			_outIcon.transform.colorTransform = new ColorTransform(outShade);
			_outShade = outShade;
			if (overIcon){
				_overIcon = overIcon;
			}
			_overShade = overShade;
			_text = text;
			addEventListener(MouseEvent.MOUSE_OVER, overHandler);
			addEventListener(MouseEvent.MOUSE_OUT, outHandler);
			addEventListener(MouseEvent.CLICK, clickHandler);
			if (_outIcon){
				_outIcon.x = (background.width - _outIcon.width) / 2;
				_outIcon.y = (background.height - _outIcon.height) / 2;
				addChildAt(_outIcon,1);
			}
			_clickEventType = clickEventType;
			_clickEventData = clickEventData;
		}
		
		
		protected function overHandler(event:MouseEvent):void {
			if (_overIcon) {
				removeChild(_outIcon);
				addChildAt(_overIcon,1);
			} else {
				_outIcon.transform.colorTransform = new ColorTransform(_overShade);
			}
		}
		
		
		protected function outHandler(event:MouseEvent):void {
			if (_overIcon) {
				removeChild(_overIcon);
				addChildAt(_outIcon,1);
			} else {
				_outIcon.transform.colorTransform = new ColorTransform(_outShade);
			}
		}
		
		protected function clickHandler(event:MouseEvent):void {
			dispatchEvent(new ViewEvent(_clickEventType, _clickEventData));
		}
		
		public function resize(width:Number, height:Number):void {
						
		}
	}
}