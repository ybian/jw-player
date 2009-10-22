package com.longtailvideo.jwplayer.view.components {
	import com.longtailvideo.jwplayer.events.MediaEvent;
	import com.longtailvideo.jwplayer.events.PlayerEvent;
	import com.longtailvideo.jwplayer.events.PlayerStateEvent;
	import com.longtailvideo.jwplayer.events.ViewEvent;
	import com.longtailvideo.jwplayer.player.Player;
	import com.longtailvideo.jwplayer.player.PlayerState;
	import com.longtailvideo.jwplayer.view.interfaces.IDisplayComponent;
	
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.text.GridFitType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	import flash.text.TextFormat;	
	
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
			player.addEventListener(MediaEvent.JWPLAYER_MEDIA_MUTE, stateHandler);
			player.addEventListener(PlayerStateEvent.JWPLAYER_PLAYER_STATE, stateHandler);
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
			if (player.config.screencolor) {
				var colorTransform:ColorTransform = new ColorTransform();
				colorTransform.color = player.config.screencolor.color;
				background.transform.colorTransform = colorTransform;
			}
			_icon = new MovieClip();
			addChildAt(icon,1);
			_text = new TextField();
			var textColorTransform:ColorTransform = new ColorTransform();
			textColorTransform.color = player.config.frontcolor ? player.config.frontcolor.color : 0xFFFFFF;
			text.transform.colorTransform = textColorTransform;
			text.gridFitType = GridFitType.NONE;
			addChildAt(text,2);
		}
		
		public function resize(width:Number, height:Number):void {
			background.width = width;
			background.height = height;
			positionIcon();
			positionText();
			stateHandler();
		}
		
		public function setIcon(displayIcon:DisplayObject):void {
			try {
				removeChild(icon);
			} catch (err:Error) {
				
			}
			if (displayIcon){
				_icon = displayIcon;
				addChild(icon);
				positionIcon();
			}
		}

		private function positionIcon():void {
			icon.x = background.scaleX / 2;
			icon.y = background.scaleY / 2 ;
		}
		
		public function setText(displayText:String):void {
			text.text = displayText ? displayText : '';
			positionText();
		}
		
		private function positionText():void {
			if (text.width > background.scaleX * .75){
				text.width = background.scaleX * .75;
				text.wordWrap = true;
			} else {
				text.autoSize = TextFormatAlign.CENTER;
			}
			text.x = (background.scaleX - text.textWidth) / 2;
			text.y = icon.y + (icon.height / 2) + 10;
		}
		
		protected function setDisplay(displayIcon:DisplayObject, displayText:String = null):void {
			setIcon(displayIcon);
			setText(displayText);
		}
		
		protected function clearDisplay():void {
			setDisplay(null,null);
		}
		
		protected function stateHandler(event:PlayerEvent = null):void {
			//TODO: Handle mute button in error state
			switch (player.state) {
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
					if (player.mute){
						setDisplay(getSkinElement('display', 'muteIcon'));
					} else {
						clearDisplay();
					}
			}
		}

		protected function errorHandler(event:PlayerEvent):void {
			setDisplay(getSkinElement('display', 'errorIcon'), event.message);
		}
		
		protected function clickHandler(event:MouseEvent):void {
			var clickEvent:String = player.state == PlayerState.PLAYING ? ViewEvent.JWPLAYER_VIEW_PAUSE : ViewEvent.JWPLAYER_VIEW_PLAY;
			dispatchEvent(new ViewEvent(clickEvent));
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