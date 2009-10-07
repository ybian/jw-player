package com.longtailvideo.jwplayer.view.components {
	import com.longtailvideo.jwplayer.events.MediaEvent;
	import com.longtailvideo.jwplayer.events.PlayerEvent;
	import com.longtailvideo.jwplayer.events.ViewEvent;
	import com.longtailvideo.jwplayer.player.Player;
	import com.longtailvideo.jwplayer.player.PlayerState;
	import com.longtailvideo.jwplayer.view.components.CoreComponent;
	import com.longtailvideo.jwplayer.view.interfaces.IDisplayComponent;
	
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.text.GridFitType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
	
	public class DisplayComponent extends CoreComponent implements IDisplayComponent {
		protected var _icon:DisplayObject;
		protected var _background:MovieClip;
		protected var _text:TextField;
		
		public function DisplayComponent(player:Player) {
			super(player);
			addListeners();
			setupDisplayObjects();
		}
		
		private function addListeners():void {
			player.addEventListener(MediaEvent.JWPLAYER_MEDIA_MUTE, muteHandler);
			player.addEventListener(PlayerEvent.JWPLAYER_STATE, stateHandler);
			player.addEventListener(PlayerEvent.JWPLAYER_ERROR, errorHandler);
			addEventListener(MouseEvent.CLICK, clickHandler);
		}
		
		private function setupDisplayObjects():void {
			_background = new MovieClip();
			background.name = "background";
			addChildAt(background, 0);
			background.graphics.beginFill(0,0);
			background.graphics.drawRect(0,0,1,1);
			background.graphics.endFill();
			var colorTransform:ColorTransform = new ColorTransform();
			colorTransform.color = player.config.screencolor;
			background.transform.colorTransform = colorTransform;
			_icon = new MovieClip();
			addChildAt(icon,1);
			_text = new TextField();
			var textColorTransform:ColorTransform = new ColorTransform();
			textColorTransform.color = player.config.frontcolor;
			text.transform.colorTransform = textColorTransform
			text.gridFitType = GridFitType.NONE;
			text.autoSize = TextFieldAutoSize.LEFT;
			addChildAt(text,2);
		}
		
		public function resize(width:Number, height:Number):void {
			background.width = width;
			background.height = height;
			positionIcon();
			positionText();
		}
		
		public function setIcon(displayIcon:DisplayObject):void {
			removeChild(icon)
			_icon = displayIcon;
			addChild(icon);
			positionIcon();
		}

		private function positionIcon():void {
			icon.x = width / 2;
			icon.y = height / 2;
		}
		
		public function setText(displayText:String):void {
			text.text = displayText;
			positionText();
		}
		
		private function positionText():void {
			text.x = (width - text.width - 60) / 2;
			text.y =  (height - icon.height / 2) / 2;
		}
		
		protected function setDisplay(displayIcon:DisplayObject, displayText:String = null):void {
			if (displayIcon) setIcon(displayIcon);
			if (displayText) setText(displayText);
		}
		
		protected function clearDisplay():void {
			setDisplay(null,null);
		}
		
		protected function stateHandler(event:PlayerEvent):void {
			switch (event.type) {
				case PlayerState.BUFFERING:
					setDisplay(getSkinElement('display', 'bufferIcon'));
					break;
				case PlayerState.PAUSED:
					setDisplay(getSkinElement('display', 'playIcon'));
					break;
				case PlayerState.IDLE:
					setDisplay(getSkinElement('display', 'playIcon'));
					break;
				default:
					clearDisplay();
			}
		}
		
		protected function muteHandler(event:MediaEvent):void {
			if (event.mute) {
				setDisplay(getSkinElement('display', 'muteIcon'));
			} else {
				clearDisplay();
			}
		}

		protected function errorHandler(event:PlayerEvent):void {
			setDisplay(getSkinElement('display', 'errorIcon'), event.message);
		}
		
		protected function clickHandler(event:MouseEvent):void {
			dispatchEvent(new ViewEvent(ViewEvent.JWPLAYER_VIEW_CLICK));
		}
		
		protected function get icon():DisplayObject {
			return _icon;
		}
		
		protected function get text():TextField {
			return _text;
		}
		
		protected function get background():MovieClip {
			return _background;
		}
		
		private function getSkinElement(component:String, element:String):DisplayObject {
			return player.skin.getSkinElement(component,element);
		}
	}
}