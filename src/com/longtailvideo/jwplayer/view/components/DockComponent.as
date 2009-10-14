package com.longtailvideo.jwplayer.view.components {
	import com.longtailvideo.jwplayer.events.PlayerStateEvent;
	import com.longtailvideo.jwplayer.player.Player;
	import com.longtailvideo.jwplayer.player.PlayerState;
	import com.longtailvideo.jwplayer.utils.Animations;
	import com.longtailvideo.jwplayer.utils.RootReference;
	import com.longtailvideo.jwplayer.view.interfaces.IDockComponent;
	
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	
	public class DockComponent extends CoreComponent implements IDockComponent {
		/** Default configuration vars for this plugin. **/
		public var defaults:Object = {
			align: 'right'
		};
		/** Object with all the buttons in the dock. **/
		private var buttons:Object;
		/** Map with color transformation objects. **/
		private var colors:Object;
		/** Timeout for hiding the buttons when the video plays. **/
		private var timeout:Number;
		/** Reference to the animations handler **/
		private var animations:Animations;
		
		public function DockComponent(player:Player) {
			super(player);
			animations = new Animations(this);
			buttons = new Object();
			if (player.config.dock) {
				player.addEventListener(PlayerStateEvent.JWPLAYER_PLAYER_STATE, stateHandler);
				RootReference.stage.addEventListener(MouseEvent.MOUSE_MOVE, moveHandler);
			} else {
				visible = false;
			}
		}
		
		
		public function addButton(icon:DisplayObject, text:String, clickHandler:Function, name:String = null):void {
			var btn:DockButton = new DockButton(icon, text, clickHandler, player.config.frontcolor, player.config.backcolor, player.config.lightcolor);
			addChild(btn);
			buttons[name] = btn;
			resize(width, height);
		}
		
		
		public function removeButton(name:String):void {
			try {
				removeChild(buttons[name]);
			} catch (err:Error) {
			}
		}
		
		
		public function resize(width:Number, height:Number):void {
			y = getConfigParam('y');
			if (getConfigParam('align') == 'left') {
				x = getConfigParam('x');
			} else {
				x = getConfigParam('x') + getConfigParam('width') - width;
			}
			for (var i:Number = 0; i < buttons.length; i++) {
				buttons[i].y = buttons[i].height * i;
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
	}
}