package com.longtailvideo.jwplayer.view.components {
	import com.longtailvideo.jwplayer.events.ViewEvent;
	import com.longtailvideo.jwplayer.model.Color;
	
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	
	
	public class ComponentButton extends MovieClip {
		protected var _backgroundLayer:DisplayObject;
		protected var _imageLayer:Sprite;
		protected var _clickLayer:Sprite;
		protected var _outIcon:DisplayObject;
		protected var _overIcon:DisplayObject;
		protected var _outColor:Color;
		protected var _overColor:Color;
		protected var _text:String;
		protected var _clickEventType:String;
		protected var _clickEventData:*;


		public function ComponentButton(outIcon:DisplayObject, clickEventType:String = null, clickEventData:* = null, outColor:Color=null, overColor:Color=null, background:DisplayObject = null, overIcon:DisplayObject = null, text:String = null) {
			_backgroundLayer = background ? background : new Sprite();
			_backgroundLayer.name = "backgroundLayer";
			addChild(_backgroundLayer);
			_backgroundLayer.x = 0;
			_backgroundLayer.y = 0;
			_imageLayer = new Sprite();
			_imageLayer.name = "imageLayer";
			addChild(_imageLayer);
			_imageLayer.x = 0;
			_imageLayer.y = 0;
			_clickLayer = new Sprite();
			_clickLayer.graphics.beginFill(1,0);
			_clickLayer.graphics.drawRoundRect(0,0,_backgroundLayer.width,_backgroundLayer.height,5);
			_clickLayer.graphics.endFill();
			_clickLayer.name = "clickLayer";
			addChild(_clickLayer);
			_outIcon = outIcon;
			_outColor = outColor;
			if (_outIcon){
				_outIcon.x = (_backgroundLayer.width - _outIcon.width) / 2;
				_outIcon.y = (_backgroundLayer.height - _outIcon.height) / 2;
				//TODO: Figure out why you can't color transform this.
				//_outIcon.transform.colorTransform = new ColorTransform(outColor);
				_imageLayer.addChild(_outIcon);
			}
			if (overIcon){
				_overIcon = overIcon;
			}
			_overColor = overColor;
			_text = text;
			_clickEventType = clickEventType;
			_clickEventData = clickEventData;
			addEventListener(MouseEvent.MOUSE_OVER, overHandler);
			addEventListener(MouseEvent.MOUSE_OUT, outHandler);
			addEventListener(MouseEvent.CLICK, clickHandler);
		}
		
		
		protected function overHandler(event:MouseEvent):void {
			if (_overIcon) {
				_imageLayer.removeChild(_outIcon);
				_imageLayer.addChild(_overIcon);
			} else if (_overColor) {
				_outIcon.transform.colorTransform = new ColorTransform(_overColor.color);
			}
		}
		
		
		protected function outHandler(event:MouseEvent):void {
			if (_overIcon) {
				_imageLayer.removeChild(_overIcon);
				_imageLayer.addChild(_outIcon);
			} else if (_outColor) {
				_outIcon.transform.colorTransform = new ColorTransform(_outColor.color);
			}
		}
		
		protected function clickHandler(event:MouseEvent):void {
			dispatchEvent(new ViewEvent(_clickEventType, _clickEventData));
		}
		
		public function resize(width:Number, height:Number):void {

		}
	}
}