package com.longtailvideo.jwplayer.view.components {
	import com.longtailvideo.jwplayer.events.PlayerStateEvent;
	import com.longtailvideo.jwplayer.player.Player;
	import com.longtailvideo.jwplayer.player.PlayerState;
	import com.longtailvideo.jwplayer.utils.Animations;
	import com.longtailvideo.jwplayer.utils.RootReference;
	import com.longtailvideo.jwplayer.view.interfaces.IDockComponent;
	
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
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
		/** Map with color transformation objects. **/
		private var colors:Object;
		/** Timeout for hiding the buttons when the video plays. **/
		private var timeout:Number;
		/** Reference to the animations handler **/
		private var animations:Animations;
		
		public function DockComponent(player:Player) {
			super(player);
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
			//TODO: Make this work with the existing skin
			var btn:DockButton = new DockButton(icon, text, clickHandler, player.config.frontcolor, player.config.backcolor, player.config.lightcolor);
			addChild(btn);
			buttons[name] = btn;
			resize(width, height);
			return btn;
		}
		
		
		public function removeButton(name:String):void {
			try {
				removeChild(buttons[name]);
			} catch (err:Error) {
			}
		}
		
		
		public function resize(width:Number, height:Number):void {
			var margin:Number = 10;
			var usedHeight:Number = margin;
			var direction:Number = 1;
			if (getConfigParam('align') != 'left') {
				direction = -1;
			}
			for (var i:Number = 0; i < buttons.length; i++) {
				var row:Number = Math.floor(usedHeight / height);
				if ((usedHeight + buttons[i].height + margin) > ((row + 1) * height)){
					usedHeight = ((row + 1) * height) + margin;
					row = Math.floor(usedHeight / height);
				}
				buttons[i].y = usedHeight % height;
				buttons[i].x = (buttons[i].width + margin) * row * direction;
				usedHeight += buttons[i].height + margin;
			}
			setConfigParam('y', player.controls.display.y);
			if (getConfigParam('align') == 'left') {
				setConfigParam('x', player.controls.display.x + margin);
			} else {
				// No need to subtract the width: all of the positions are negative
				if (buttons.length > 0){
					setConfigParam('x', player.controls.display.x + player.controls.display.width - buttons[0].width - margin);
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
		
		/** Gets a configuration parameter **/
		private function getConfigParam(param:String):* {
			return _player.config.pluginConfig("dock")[param];
		}
		
		private function setConfigParam(param:String, value:*):void {
			_player.config.pluginConfig("dock")[param] = value;
		}
	}
}