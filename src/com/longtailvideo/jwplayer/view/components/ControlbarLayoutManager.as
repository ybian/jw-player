package com.longtailvideo.jwplayer.view.components {
	import flash.display.DisplayObject;
	import flash.text.TextField;
	
	
	public class ControlbarLayoutManager {
		protected var _controlbar:ControlbarComponent;
		protected var _currentLeft:Number;
		protected var _currentRight:Number;
		protected var _height:Number;
		
		
		public function ControlbarLayoutManager(controlbar:ControlbarComponent) {
			_controlbar = controlbar;
		}
		
		
		public function resize(width:Number, height:Number):void {
			if (width && height){
				_height = height;
				_currentLeft = 0;
				if (_controlbar.getButton('capLeft')){
					_currentLeft += _controlbar.getButton('capLeft').width;
				}
				_currentRight = width;
				if (_controlbar.getButton('capRight')){
					_currentRight -= _controlbar.getButton('capRight').width;
				}
				var controlbarPattern:RegExp = /\[(.+)\]\[(.+)\]\[(.+)\]/;
				var result:Object = controlbarPattern.exec(_controlbar.layout);
				positionLeft(result[1]);
				positionRight(result[3]);
				positionCenter(result[2]);
			}
		}
		
		
		private function positionLeft(left:String):void {
			var dividers:Array = left.split("|");
			for (var i:Number = 0; i < dividers.length; i++) {
				if (i > 0) {
					placeLeft(_controlbar.getButton("divider"));
				}
				var spacers:Array = (dividers[i] as String).split(" ");
				for (var j:Number = 0; j < spacers.length; j++) {
					var name:String = spacers[j];
					var button:DisplayObject = _controlbar.getButton(spacers[j]);
					placeLeft(_controlbar.getButton(spacers[j]));
				}
			}
		}
		
		
		private function placeLeft(displayObject:DisplayObject):void {
			if (displayObject) {
				displayObject.visible = true;
				if (!_controlbar.contains(displayObject)) {
					_controlbar.addChild(displayObject);
				}
				
				if (displayObject is TextField) {
					_currentLeft = _currentLeft + 5;
				}
				
				displayObject.x = _currentLeft;	
				displayObject.y = (_height - displayObject.height) / 2;

				_currentLeft = _currentLeft + displayObject.width;								

				if (displayObject is TextField) {
					_currentLeft = _currentLeft + 5;
				}
				
			}
		}
		
		
		private function positionRight(right:String):void {
			var dividers:Array = right.split("|");
			for (var i:Number = dividers.length - 1; i >= 0; i--) {
				if (i < dividers.length - 1) {
					placeRight(_controlbar.getButton("divider"));
				}
				var spacers:Array = (dividers[i] as String).split(" ");
				for (var j:Number = spacers.length - 1; j >= 0; j--) {
					var name:String = spacers[j];
					var button:DisplayObject = _controlbar.getButton(spacers[j]);
					placeRight(_controlbar.getButton(spacers[j]));
				}
			}
		}
		
		
		private function placeRight(displayObject:DisplayObject):void {
			if (displayObject) {
				displayObject.visible = true;
				if (!_controlbar.contains(displayObject)) {
					_controlbar.addChild(displayObject);
				}

				if (displayObject is TextField) {
					_currentRight = _currentRight - 5;
				}
				
				_currentRight = _currentRight - displayObject.width;
				displayObject.x = _currentRight;
				displayObject.y = (_height - displayObject.height) / 2;
				if (displayObject is TextField) {
					_currentRight = _currentRight - 5;
				}
			}
		}
		
		
		private function positionCenter(center:String):void {
			var centerPattern:RegExp = /\W/;
			var elements:Array = center.split(centerPattern);
			var dividers:Array = center.split("|");
			var divider:DisplayObject = _controlbar.getButton("divider");
			var dividerOffset:Number = 0;
			if (divider) {
				dividerOffset = divider.width * (dividers.length - 1);
			}
			var elementWidth:Number = (_currentRight - _currentLeft - dividerOffset) / elements.length;
			for (var i:Number = 0; i < dividers.length; i++) {
				if (i > 0) {
					placeLeft(divider);
				}
				var spacers:Array = (dividers[i] as String).split(" ");
				for (var j:Number = 0; j < spacers.length; j++) {
					var element:DisplayObject = _controlbar.getButton(spacers[j]);
					if (element) {
						if (element is ComponentButton){
							(element as ComponentButton).resize(elementWidth, element.height);
						} else if (element is Slider) {
							(element as Slider).resize(elementWidth, element.height);
						}
						placeLeft(element);
					}
				}
			}
		}
	}
}