package com.longtailvideo.jwplayer.view.components {
	import com.longtailvideo.jwplayer.events.ViewEvent;
	import com.longtailvideo.jwplayer.utils.RootReference;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Rectangle;


	public class Slider extends Sprite {
		public static var HORIZONTAL:String = "horizontal";
		public static var VERTICAL:String = "vertical";
		protected var _rail:Sprite;
		protected var _buffer:Sprite;
		protected var _progress:Sprite;
		protected var _thumb:Sprite;
		protected var _orientation:String;
		protected var _currentThumb:Number = 0;
		protected var _currentProgress:Number = 0;
		protected var _currentBuffer:Number = 0;
		/** Color object for frontcolor. **/
		protected var _front:ColorTransform;
		/** Color object for lightcolor. **/
		protected var _light:ColorTransform;
		/** Current width and height **/
		protected var _width:Number;
		protected var _height:Number;
		/** Currently dragging thumb **/
		protected var _dragging:Boolean;
		/** Lock state of the slider **/
		protected var _lock:Boolean;


		//protected var _height:Number;
		public function Slider(rail:DisplayObject, buffer:DisplayObject, progress:DisplayObject, thumb:DisplayObject, orientation:String) {
			super();
			addEventListener(MouseEvent.MOUSE_DOWN, downHandler);
			addEventListener(MouseEvent.MOUSE_OVER, overHandler);
			addEventListener(MouseEvent.MOUSE_OUT, outHandler);
			_rail = addElement(rail, "rail", true);
			_buffer = addElement(buffer, "buffer");
			_progress = addElement(progress, "progress");
			_thumb = addElement(thumb, "thumb");
			_orientation = orientation;
		}


		private function addElement(element:DisplayObject, name:String, visible:Boolean=false):Sprite {
			if (!element) {
				element = new Sprite();
			}
			element.visible = visible;
			addChild(element);
			element.name = name;
			return element as Sprite;
		}


		protected function setThumb(progress:Number):void {
			_currentThumb = progress;
			if (_thumb) {
				_thumb.visible = true;
			}
		}


		public function setProgress(progress:Number):void {
			_currentProgress = progress;
			if (_progress) {
				_progress.visible = true;
			}
			setThumb(progress);
		}


		public function setBuffer(buffer:Number):void {
			_currentBuffer = buffer;
			if (_buffer) {
				_buffer.visible = true;
			}
		}


		public function resize(width:Number, height:Number):void {
			var scale:Number = this.scaleX;
			this.scaleX = 1;
			_width = width * scale;
			_height = height;
			if (_rail.getChildByName("bitmap")) {
				_rail.getChildByName("bitmap").width = _width;
				resizeElement(_rail);
			}
			if (_buffer.getChildByName("bitmap")) {
				_buffer.getChildByName("bitmap").width = _width;
				resizeElement(_buffer, _currentBuffer);
			}
			if (_progress.getChildByName("bitmap") && !_dragging) {
				_progress.getChildByName("bitmap").width = _width;
				resizeElement(_progress, _currentProgress);
			}
			if (_thumb && !_dragging) {
				_thumb.x = _width * _currentThumb / 100;
			}
			verticalCenter();
		}


		private function resizeElement(element:Sprite, maskpercentage:Number=100):void {
			if (element) {
				if (_width && _height) {
					var mask:Sprite;
					if (element.mask) {
						mask = element.mask as Sprite;
					} else {
						mask = new Sprite();
						mask.name = "mask";
						element.addChild(mask);
						element.mask = mask;
					}
					mask.x = 0;
					mask.graphics.clear();
					mask.graphics.beginFill(0x000000, 0);
					mask.graphics.drawRect(element.x, 0, _width * maskpercentage / 100, element.height);
					mask.graphics.endFill();
				}
			}
		}

		private function verticalCenter():void {
			var maxHeight:Number = 0;
			var element:DisplayObject;

			for(var i:Number = 0; i < numChildren; i++) {
				element = getChildAt(i);
				if (element.height > maxHeight) maxHeight = element.height;
			}
			
			for(i = 0; i < numChildren; i++) {
				element = getChildAt(i);
				element.y = (maxHeight - element.height) / 2;
			}
		}

		/** Handle mouse downs. **/
		private function downHandler(evt:MouseEvent):void {
			if (_thumb && !_lock) {
				var rct:Rectangle = new Rectangle(_rail.x, _thumb.y, _rail.width - _thumb.width, 0);
				_thumb.startDrag(true, rct);
				_dragging = true;
				RootReference.stage.addEventListener(MouseEvent.MOUSE_UP, upHandler);
			}
		}


		/** Handle mouse releases. **/
		private function upHandler(evt:MouseEvent):void {
			RootReference.stage.removeEventListener(MouseEvent.MOUSE_UP, upHandler);
			_thumb.stopDrag();
			_dragging = false;
			var percent:Number = (_thumb.x - _rail.x) / (_rail.width - _thumb.width);
			dispatchEvent(new ViewEvent(ViewEvent.JWPLAYER_VIEW_CLICK, percent));
			setThumb(percent * 100);
		}


		/** Handle mouseouts. **/
		private function outHandler(evt:MouseEvent):void {
			//slider.transform.colorTransform = front;
		}


		/** Handle mouseovers. **/
		private function overHandler(evt:MouseEvent):void {
			//slider.transform.colorTransform = light;
		}

		/** Reset the slider to it's original state**/
		public function reset():void {
			setBuffer(0);
			setProgress(0);
		}
		
		public function lock():void {
			_lock = true;
		} 
		
		public function unlock():void{
			_lock = false;
		}
	}
}