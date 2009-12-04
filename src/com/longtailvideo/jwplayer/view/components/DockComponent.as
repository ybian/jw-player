package com.longtailvideo.jwplayer.view.components {
	import com.longtailvideo.jwplayer.events.PlayerStateEvent;
	import com.longtailvideo.jwplayer.player.IPlayer;
	import com.longtailvideo.jwplayer.player.PlayerState;
	import com.longtailvideo.jwplayer.utils.Animations;
	import com.longtailvideo.jwplayer.utils.RootReference;
	import com.longtailvideo.jwplayer.view.interfaces.IDockComponent;
	import com.longtailvideo.jwplayer.view.skins.SWFSkin;
	
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	
	public class DockComponent extends CoreComponent implements IDockComponent {
		/** Default configuration vars for this plugin. **/
		public var defaults:Object = {
				align: 'right'
			};
		/** Object with all the buttons in the dock. **/
		private var buttons:Array;
		/** Timeout for hiding the buttons when the video plays. **/
		private var timeout:Number;
		/** Reference to the animations handler **/
		private var animations:Animations;
		
		public function DockComponent(player:IPlayer) {
			super(player, "dock");
			animations = new Animations(this);
			buttons = new Array();
			if (player.config.dock) {
				player.addEventListener(PlayerStateEvent.JWPLAYER_PLAYER_STATE, stateHandler);
				RootReference.stage.addEventListener(MouseEvent.MOUSE_MOVE, moveHandler);
			} else {
				visible = false;
			}
		}
		
		
		public function addButton(icon:DisplayObject, text:String, clickHandler:Function, name:String = null):MovieClip {
			var button:DockButton = new DockButton();
			if (name){
				button.name = name;
			}
			if (_player.skin is SWFSkin) {
				button.colorize = true;
			}
			button.setOutIcon(icon);
			button.outBackground = getSkinElement("button") as Sprite;
			button.overBackground = getSkinElement("buttonOver") as Sprite;
			button.assetColor = player.config.backcolor;
			button.outColor = player.config.frontcolor;
			button.overColor = player.config.lightcolor;
			button.clickFunction = clickHandler;
			button.init();
			button.text = text;
			addChild(button);
			buttons.push(button);
			resize(getConfigParam('width'), getConfigParam('height'));
			return button;
		}
		
		
		public function removeButton(name:String):void {
			try {
				removeChild(getChildByName(name));
			} catch (err:Error) {
			}
		}
		
		
		public function resize(width:Number, height:Number):void {
			if (buttons.length > 0) {
				var margin:Number = 10;
				var xStart:Number = width - buttons[0].width - margin;
				var usedHeight:Number = margin;
				var direction:Number = -1;
				if (getConfigParam('position') == 'left') {
					direction = 1;
					xStart = margin;
				}
				for (var i:Number = 0; i < buttons.length; i++) {
					var row:Number = Math.floor(usedHeight / height);
					if ((usedHeight + buttons[i].height + margin) > ((row + 1) * height)){
						usedHeight = ((row + 1) * height) + margin;
						row = Math.floor(usedHeight / height);
					}
					buttons[i].y = usedHeight % height;
					buttons[i].x = xStart + (buttons[i].width + margin) * row * direction;
					usedHeight += buttons[i].height + margin;
					(buttons[i] as DockButton).centerText();
				}
			}
		}
		
		
		/** Show the buttons on mousemove. **/
		private function moveHandler(evt:MouseEvent = null):void {
			clearTimeout(timeout);
			if (player.state == PlayerState.BUFFERING || player.state == PlayerState.PLAYING) {
				timeout = setTimeout(moveTimeout, 2000);
				if (alpha < 1) {
					animations.fade(1);
				}
			}
		}
		
		
		/** Hide the buttons again when move has timed out. **/
		private function moveTimeout():void {
			animations.fade(0);
		}
		
		
		/** Process state changes **/
		private function stateHandler(evt:PlayerStateEvent = undefined):void {
			switch (player.state) {
				case PlayerState.PLAYING:
				case PlayerState.BUFFERING:
					moveHandler();
					break;
				default:
					clearTimeout(timeout);
					animations.fade(1);
					break;
			}
		}
	}
}

