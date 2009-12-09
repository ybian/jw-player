package com.longtailvideo.jwplayer.view.components {
	import com.longtailvideo.jwplayer.events.MediaEvent;
	import com.longtailvideo.jwplayer.events.PlayerEvent;
	import com.longtailvideo.jwplayer.events.PlayerStateEvent;
	import com.longtailvideo.jwplayer.events.ViewEvent;
	import com.longtailvideo.jwplayer.player.IPlayer;
	import com.longtailvideo.jwplayer.player.PlayerState;
	import com.longtailvideo.jwplayer.utils.Draw;
	import com.longtailvideo.jwplayer.view.interfaces.IDisplayComponent;
	import com.longtailvideo.jwplayer.view.skins.SWFSkin;
	
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.text.GridFitType;
	import flash.text.TextField;
	import flash.text.TextFormatAlign;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	
	
	public class DisplayComponent extends CoreComponent implements IDisplayComponent {
		protected var _icon:DisplayObject;
		protected var _background:MovieClip;
		protected var _text:TextField;
		protected var _icons:Object;
		protected var _rotateInterval:Number;
		protected var _bufferIcon:Sprite;
		protected var _rotate:Boolean = true;
		
		
		public function DisplayComponent(player:IPlayer) {
			super(player, "display");
			addListeners();
			setupDisplayObjects();
			setupIcons();
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
			background.graphics.beginFill(0, 0);
			background.graphics.drawRect(0, 0, 1, 1);
			background.graphics.endFill();
			if (player.config.screencolor) {
				var colorTransform:ColorTransform = new ColorTransform();
				colorTransform.color = player.config.screencolor.color;
				background.transform.colorTransform = colorTransform;
			}
			_icon = new MovieClip();
			addChildAt(icon, 1);

			_text = new TextField();
			var textColorTransform:ColorTransform = new ColorTransform();
			textColorTransform.color = player.config.frontcolor ? player.config.frontcolor.color : 0x999999;
			text.transform.colorTransform = textColorTransform;
			text.gridFitType = GridFitType.NONE;
			addChildAt(text, 2);
		}
		
		
		protected function setupIcons():void {
			_icons = {};
			setupIcon('buffer');
			setupIcon('play');
			setupIcon('mute');
			setupIcon('error');
		}
		
		
		protected function setupIcon(name:String):void {
			var back:Sprite = getSkinElement('background') as Sprite;
			var icon:Sprite = getSkinElement(name + 'Icon') as Sprite;
			if (back) {
				back.x = 0;
				back.y = 0;
				back.addChild(icon);
				icon.x = (back.width - icon.width) / 2;
				icon.y = (back.height - icon.height) / 2;
				_icons[name] = back;
			} else {
				_icons[name] = icon;
			}
			if (name == "buffer") {
				try {
					if (_icons[name] is MovieClip && (_icons[name] as MovieClip).totalFrames > 1) {
						// Buffer is already animated; no need to rotate.
						_rotate = false;
					} else {
						_bufferIcon = (_icons[name] as DisplayObjectContainer).getChildAt((_icons[name] as DisplayObjectContainer).numChildren - 1) as Sprite;
						_bufferIcon.getChildAt(0).x = Math.round(_bufferIcon.getChildAt(0).width / -2);
						_bufferIcon.getChildAt(0).y = Math.round(_bufferIcon.getChildAt(0).height / -2);
						_bufferIcon.x = back.width / 2 ;
						_bufferIcon.y = back.height - icon.height;
						var bufferBitmap:Bitmap = _bufferIcon.getChildByName('bitmap') as Bitmap;
						if (bufferBitmap) {
							Draw.smooth(bufferBitmap);
						}
					}
				} catch (err:Error){
					_rotate = false;	
				}
			}
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
			if (displayIcon) {
				_icon = displayIcon;
				addChild(icon);
				positionIcon();
			}
		}
		
		
		private function positionIcon():void {
			if (_player.skin is SWFSkin) {
				// SWF skins' display icons have centered origins
				icon.x = background.scaleX / 2;
				icon.y = background.scaleY / 2;
			} else {
				icon.x = (background.scaleX - icon.width) / 2;
				icon.y = (background.scaleY - icon.height) / 2;
			}
		}
		
		
		public function setText(displayText:String):void {
			if (_icon is Sprite && (_icon as Sprite).getChildByName('txt') is TextField) {
				((_icon as Sprite).getChildByName('txt') as TextField).text = displayText ? displayText : '';
				text.text = '';
			} else {
				text.text = displayText ? displayText : '';
			}
			positionText();
		}
		
		
		private function positionText():void {
			if (text.text) {
				text.visible = true;
				if (text.width > background.scaleX * .75) {
					text.width = background.scaleX * .75;
					text.wordWrap = true;
				} else {
					text.autoSize = TextFormatAlign.CENTER;
				}
				text.x = (background.scaleX - text.textWidth) / 2;
				if (_player.skin is SWFSkin) {
					text.y = icon.y + (icon.height/2) + 10;
				} else {
					text.y = icon.y + icon.height + 10;
				}
			} else {
				text.visible = false;
			}
		}
		
		
		protected function setDisplay(displayIcon:DisplayObject, displayText:String = null):void {
			setIcon(displayIcon);
			setText(displayText);
		}
		
		
		protected function clearDisplay():void {
			setDisplay(null, null);
		}
		
		
		protected function stateHandler(event:PlayerEvent = null):void {
			//TODO: Handle mute button in error state
			clearRotation();
			switch (player.state) {
				case PlayerState.BUFFERING:
					setDisplay(_icons['buffer']);
					if (_rotate){
						startRotation();
					}
					break;
				case PlayerState.PAUSED:
					setDisplay(_icons['play']);
					break;
				case PlayerState.IDLE:
					setDisplay(_icons['play']);
					break;
				default:
					if (player.mute) {
						setDisplay(_icons['mute']);
					} else {
						clearDisplay();
					}
			}
		}
		
		
		protected function startRotation():void {
			if (!_rotateInterval) {
				_rotateInterval = setInterval(updateRotation, 100);
			}
		}
		
		
		protected function updateRotation():void {
			if (icon is DisplayObjectContainer) {
				_bufferIcon.rotation += 15;
			}
		}
		
		
		protected function clearRotation():void {
			if (_rotateInterval) {
				clearInterval(_rotateInterval);
				_rotateInterval = undefined;
			}
		}
		
		
		protected function errorHandler(event:PlayerEvent):void {
			setDisplay(_icons['error'], event.message);
		}
		
		
		protected function clickHandler(event:MouseEvent):void {
			dispatchEvent(new ViewEvent(ViewEvent.JWPLAYER_VIEW_CLICK));
			if (player.state == PlayerState.PLAYING || player.state == PlayerState.BUFFERING) {
				player.pause();
			} else {
				player.play();
			}
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
		
	}
}