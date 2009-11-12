package com.longtailvideo.jwplayer.view.components {
	import com.longtailvideo.jwplayer.model.Color;
	import com.longtailvideo.jwplayer.utils.Logger;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	public class ComponentButton extends MovieClip {
		protected var _background:DisplayObject;
		protected var _clickFunction:Function;
		protected var _clickLayer:Sprite;
		protected var _imageLayer:Sprite;
		protected var _outColor:Color;
		protected var _outIcon:DisplayObject;
		protected var _overColor:Color;
		protected var _overIcon:DisplayObject;

				
		public function ComponentButton () {
		}

	
		public function init ():void {
			if (_background) {
				nameDisplayObject("backgroundLayer", _background);
				addChild(_background);
				_background.x = 0;
				_background.y = 0;
			}
			_imageLayer = new Sprite();
			nameDisplayObject("imageLayer", _imageLayer);
			addChild(_imageLayer);
			_imageLayer.x = 0;
			_imageLayer.y = 0;
			setImage(_outIcon);
			addEventListener(MouseEvent.MOUSE_OVER, overHandler);
			addEventListener(MouseEvent.MOUSE_OUT, outHandler);
			addEventListener(MouseEvent.CLICK, clickHandler);
		}
		
		
		protected function outHandler (event:MouseEvent):void {
			if (_overIcon) {
				if (_imageLayer.contains(_overIcon)) {
					_imageLayer.removeChild(_overIcon);
				}
				setImage(_outIcon);
			}
		}
		
		
		protected function overHandler (event:MouseEvent):void {
			if (_overIcon) {
				if (_imageLayer.contains(_outIcon)) {
					_imageLayer.removeChild(_outIcon);
				}
				setImage(_overIcon);
			}
		}
		
				
		/** Handles mouse clicks **/
		protected function clickHandler (event:MouseEvent):void {
			try {
				_clickFunction(event);
			} catch (error:Error) {
				Logger.log(error.message);
			}
		}

		
		/**
		 * Change the image in the button.
		 *
		 * @param dpo	The new caption for the button.
		 **/
		protected function setImage (dpo:DisplayObject):void {
			if (dpo) {
				if (_imageLayer.contains(dpo)) {
					_imageLayer.removeChild(dpo);
				}
				_imageLayer.addChild(dpo);
				centerIcon(dpo);
			}
		}


		public function setBackground (background:DisplayObject = null):void {
			if (background) {
				_background = background;
				updateClickLayer();
			}
		}

		
		public function setOutIcon (outIcon:DisplayObject = null):void {
			if (outIcon) {
				_outIcon = outIcon;
			}
		}
		
		
		public function setOverIcon (overIcon:DisplayObject = null):void {
			if (overIcon) {
				_overIcon = overIcon;
			}
		}
		public function resize (width:Number, height:Number):void {
		}
		
		
		protected function centerIcon (icon:DisplayObject):void {
			if (icon) {
				if (_background) {
					icon.x = (_background.width - icon.width) / 2;
					icon.y = (_background.height - icon.height) / 2;
				} else {
					icon.x = 0;
					icon.y = 0;
				}
			}
		}


		protected function updateClickLayer ():void {
			if (_clickLayer && contains(_clickLayer)) {
				removeChild(_clickLayer);
			}
		/*_clickLayer = Draw.clone(_background as Sprite) as Sprite;
		   var overTransform:ColorTransform = new ColorTransform()
		   overTransform.color = 0;
		   _clickLayer.transform.colorTransform = overTransform;
		   _clickLayer.alpha = 1;
		   _clickLayer.name = "clickLayer";
		   addChild(_clickLayer);
		 _clickLayer.addEventListener(MouseEvent.MOUSE_OVER, tempHandler);*/
		}


		public function set outColor (outColor:Color):void {
			_outColor = outColor;
		}
		
		
		public function set overColor (overColor:Color):void {
			_overColor = overColor;
		}


		public function set clickFunction (clickFunction:Function):void {
			_clickFunction = clickFunction
		}


		private function nameDisplayObject (name:String, displayObject:DisplayObject):void {
			try {
				displayObject.name = name;
			} catch (error:Error) {
				
			}
		}
	}
}