package com.longtailvideo.jwplayer.view {
	import com.longtailvideo.jwplayer.events.ViewEvent;
	import com.longtailvideo.jwplayer.utils.RootReference;
	
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Rectangle;
	
	
	public class Slider extends MovieClip {
		public static var HORIZONTAL:String = "horizontal";
		public static var VERTICAL:String = "vertical";
		protected var _rail:DisplayObject;
		protected var _buffer:DisplayObject;
		protected var _progress:DisplayObject;
		protected var _slider:DisplayObject;
		protected var _orientation:String;
		protected var _currentSlider:Number = 0;
		protected var _currentProgress:Number = 0;
		protected var _currentBuffer:Number = 0;
		/** Color object for frontcolor. **/
		protected var _front:ColorTransform;
		/** Color object for lightcolor. **/
		protected var _light:ColorTransform;

		
		public function Slider(rail:DisplayObject, buffer:DisplayObject, progress:DisplayObject, slider:DisplayObject, orientation:String) {
			super();
			addEventListener(MouseEvent.MOUSE_DOWN, downHandler);
			//TODO: Add color transform stuff for mouseover
			addEventListener(MouseEvent.MOUSE_OVER, overHandler);
			addEventListener(MouseEvent.MOUSE_OUT, outHandler);
			_rail = rail;
			addElement(_rail, "rail", 1, true);
			_buffer = buffer;
			addElement(_buffer, "buffer", 2);
			_progress = progress;
			addElement(_progress, "progress", 3);
			_slider = slider;
			addElement(_slider, "slider", 4);
			_orientation = orientation;
		}
		
		private function addElement(element:DisplayObject, name:String, index:Number, visible:Boolean = false):void {
			if (element) {
				//element.name = name;
				//addChildAt(element,index);
				element.visible = visible;
				addChild(element);
			}
		}
		
		public function setSlider(progress:Number):void {
			if (_slider) {
				_slider.visible = true;
			}
			_currentSlider = progress;
			resize(width,height);
		}
		
		public function setProgress(progress:Number):void {
			if (_progress) {
				_progress.visible = true;
			}
			_currentProgress = progress;
			setSlider(progress);
		}
		
		public function setBuffer(buffer:Number):void {
			if (_buffer) {
				_buffer.visible = true;
			}
			_currentBuffer = buffer;
			resize(width,height);
		}
		
		public function resize(width:Number, height:Number):void {
			resizeElement(_rail, width, height);
			resizeElement(_buffer, width * _currentBuffer / 100, height);
			resizeElement(_progress, width * _currentProgress / 100, height);
			if (_slider){
				_slider.x = width * _currentSlider / 100;
				_slider.width = _slider.width;
			}
		}
		
		private function resizeElement(element:DisplayObject, width:Number, height:Number):void {
			if (element){
				//element.height = height;
				element.width = width;
			}
		}
		
		/** Handle mouse downs. **/
		private function downHandler(evt:MouseEvent):void {
			if (_slider){
				var rct:Rectangle = new Rectangle(_rail.x,_slider.y,_rail.width-_slider.width,0);
				(_slider as MovieClip).startDrag(true,rct);
				RootReference.stage.addEventListener(MouseEvent.MOUSE_UP,upHandler);
			}
		}
		
		/** Handle mouse releases. **/
		private function upHandler(evt:MouseEvent):void {
			RootReference.stage.removeEventListener(MouseEvent.MOUSE_UP,upHandler);
			(_slider as MovieClip).stopDrag();
			var percent:Number = (_slider.x-_rail.x) / (_rail.width-_slider.width);
			dispatchEvent(new ViewEvent(ViewEvent.JWPLAYER_VIEW_CLICK, percent));
			setSlider(percent*100);
		}
		
		/** Handle mouseouts. **/
		private function outHandler(evt:MouseEvent):void {
			//slider.transform.colorTransform = front;
		}
		
		
		/** Handle mouseovers. **/
		private function overHandler(evt:MouseEvent):void {
			//slider.transform.colorTransform = light;
		}
		
		public function reset():void {
			setBuffer(0);
			setProgress(0);
		}
	}
}
