package com.longtailvideo.jwplayer.view {
	import com.longtailvideo.jwplayer.events.PlayerStateEvent;
	import com.longtailvideo.jwplayer.player.Player;
	import com.longtailvideo.jwplayer.player.PlayerState;
	import com.longtailvideo.jwplayer.utils.Animations;
	import com.longtailvideo.jwplayer.utils.Logger;
	
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	
	public class Logo extends MovieClip {
		/** Configuration defaults **/
		private var defaults:Object = {
			file: "http://logo.longtailvideo.com.s3.amazonaws.com/logo.png", 
			link: "http://www.longtailvideo.com/players/jw-flv-player/", 
			margin: 8, 
			out: 0.5, 
			over: 1, 
			state: false, 
			timeout: 3
		}
		/** Reference to the player **/
		private var _player:Player;
		/** Reference to the current fade timer **/
		private var timeout:uint;
		/** Reference to the loader **/
		private var loader:Loader;
		/** Animations handler **/
		private var animations:Animations;
		
		/** Dimensions **/
		private var _width:Number;
		private var _height:Number;
		
		/** Constructor **/
		public function Logo(player:Player) {
			super();
			this.buttonMode = true;
			this.mouseChildren = false;
			animations = new Animations(this);
			_player = player;
			player.addEventListener(PlayerStateEvent.JWPLAYER_PLAYER_STATE, stateHandler);
			addEventListener(MouseEvent.CLICK, clickHandler);
			addEventListener(MouseEvent.MOUSE_OVER, overHandler);
			addEventListener(MouseEvent.MOUSE_OUT, outHandler);
			if (getConfigParam('file')){
				loader = new Loader();
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE,loaderHandler);
				loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
				loader.load(new URLRequest(getConfigParam('file')));
			}
		}
		
		/** Logo loaded - add to display **/
		private function loaderHandler(evt:Event):void {
			visible = false;
			addChild(loader);
			resize(_width, _height);
		}
		
		/** Logo failed to load - die **/
		private function errorHandler(evt:IOErrorEvent):void {
			Logger.log("Failed to load logo: " + evt.text);
		}
		
		
		/** Handles mouse clicks **/
		private function clickHandler(evt:MouseEvent):void {
			_player.pause();
			if (getConfigParam('link')) {
				navigateToURL(new URLRequest(getConfigParam('link')));
			}
		}
		
		/** Handles mouse outs **/
		private function outHandler(evt:MouseEvent):void {
			alpha = getConfigParam('out');
		}
		
		
		/** Handles mouse overs **/
		private function overHandler(evt:MouseEvent):void {
			alpha = getConfigParam('over');
		}
		
		
		/** Handles state changes **/
		private function stateHandler(evt:PlayerStateEvent):void {
			if (_player.state == PlayerState.BUFFERING) {
				clearTimeout(timeout);
				show();
			}
		}
		
		
		/** Fade in **/
		private function show():void {
			visible = true;
			animations.fade(getConfigParam('out'), 0.1);
			timeout = setTimeout(hide, getConfigParam('timeout') * 1000);
			mouseEnabled = true;
		}
		
		
		/** Fade out **/
		private function hide():void {
			mouseEnabled = false;
			animations.fade(0, 0.1);
		}
		
		
		/** Resizes the logo **/
		public function resize(width:Number, height:Number):void {
			_width = width;
			_height = height;
			loader.x = defaults['margin'];
			loader.y = _height - loader.height - defaults['margin'];
		}
		
		
		/** Gets a configuration parameter **/
		private function getConfigParam(param:String):* {
			var result:*;
			result = defaults[param];
			if (Player.commercial && _player.config.pluginConfig("logo")[param]) {
				result = _player.config.pluginConfig("logo")[param];
			}
			return result;
		}
	}
}