package com.longtailvideo.jwplayer.view {
	import flash.display.DisplayObject;
	import flash.text.TextField;
	
	
	public class ControlbarLayoutManager {
		protected var _controlbar:ControlBarComponent;
		protected var _currentLeft:Number;
		protected var _currentRight:Number;
		
		
		public function ControlbarLayoutManager(controlbar:ControlBarComponent) {
			_controlbar = controlbar;
		}
		
		
		public function resize(width:Number, height:Number):void {
			_currentLeft = 0;
			_currentRight = width;
			var controlbarPattern:RegExp = /\[(.*)\]\[(.*)\]\[(.*)\]/;
			var result:Object = controlbarPattern.exec(_controlbar.layout);
			positionLeft(result[1]);
			positionRight(result[3]);
			positionCenter(result[2]);
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
				if (!_controlbar.contains(displayObject)) {
					_controlbar.addChild(displayObject);
				}
				
				displayObject.x = _currentLeft;	
				displayObject.y = 0;
											
				if (displayObject is TextField) {
					//_currentLeft = _currentLeft + (displayObject as TextField).textWidth;
					_currentLeft = _currentLeft + displayObject.width;
				} else {
					_currentLeft = _currentLeft + displayObject.width;
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
				if (!_controlbar.contains(displayObject)) {
					_controlbar.addChild(displayObject);
				}
				if (displayObject is TextField) {
					//_currentRight = _currentRight - (displayObject as TextField).textWidth;
					_currentRight = _currentRight - displayObject.width;
				} else {
					_currentRight = _currentRight - displayObject.width;
				}
				displayObject.x = _currentRight;
				displayObject.y = 0;
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