package com.longtailvideo.jwplayer.view {
	import com.longtailvideo.jwplayer.events.PlayerStateEvent;
	import com.longtailvideo.jwplayer.player.IPlayer;
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
		protected var defaults:Object = {
			prefix: "http://l.longtailvideo.com/", 
			file: "logo.png", 
			link: "http://www.longtailvideo.com/players/jw-flv-player/", 
			margin: 8, 
			out: 0.5, 
			over: 1, 
			timeout: 3,
			hide: 'true'
		}
		/** Reference to the player **/
		protected var _player:IPlayer;
		/** Reference to the current fade timer **/
		protected var timeout:uint;
		/** Reference to the loader **/
		protected var loader:Loader;
		/** Animations handler **/
		protected var animations:Animations;
		
		/** Dimensions **/
		protected var _width:Number;
		protected var _height:Number;
		
		/** Constructor **/
		public function Logo(player:IPlayer) {
			super();
			this.buttonMode = true;
			this.mouseChildren = false;
			animations = new Animations(this);
			_player = player;
			player.addEventListener(PlayerStateEvent.JWPLAYER_PLAYER_STATE, stateHandler);
			addEventListener(MouseEvent.CLICK, clickHandler);
			addEventListener(MouseEvent.MOUSE_OVER, overHandler);
			addEventListener(MouseEvent.MOUSE_OUT, outHandler);
			
			loadFile();
		}
		
		protected function loadFile():void {
			var versionRE:RegExp = /(\d+)\.(\d+)\./;
			var versionInfo:Array = versionRE.exec(_player.version);
			if (defaults['file'] && defaults['prefix']) {
				defaults['file'] = defaults['prefix'] + versionInfo[1] + "/" + versionInfo[2] + "/" + defaults['file'];
			}
			
			if (getConfigParam('file')){
				loader = new Loader();
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE,loaderHandler);
				loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
				loader.load(new URLRequest(getConfigParam('file')));
			}
		}
		
		/** Logo loaded - add to display **/
		protected function loaderHandler(evt:Event):void {
			visible = false;
			addChild(loader);
			resize(_width, _height);
		}
		
		/** Logo failed to load - die **/
		protected function errorHandler(evt:IOErrorEvent):void {
			Logger.log("Failed to load logo: " + evt.text);
		}
		
		
		/** Handles mouse clicks **/
		protected function clickHandler(evt:MouseEvent):void {
			_player.pause();
			if (getConfigParam('link')) {
				navigateToURL(new URLRequest(getConfigParam('link')));
			}
		}
		
		/** Handles mouse outs **/
		protected function outHandler(evt:MouseEvent):void {
			alpha = getConfigParam('out');
		}
		
		
		/** Handles mouse overs **/
		protected function overHandler(evt:MouseEvent):void {
			alpha = getConfigParam('over');
		}
		
		
		/** Handles state changes **/
		protected function stateHandler(evt:PlayerStateEvent):void {
			if (_player.state == PlayerState.BUFFERING) {
				clearTimeout(timeout);
				show();
			}
		}
		
		
		/** Fade in **/
		protected function show():void {
			visible = true;
			animations.fade(getConfigParam('out'), 0.1);
			timeout = setTimeout(hide, getConfigParam('timeout') * 1000);
			mouseEnabled = true;
		}
		
		
		/** Fade out **/
		protected function hide():void {
			if (defaults['hide'] == 'true') {
				mouseEnabled = false;
				animations.fade(0, 0.1);
			}
		}
		
		
		/** Resizes the logo **/
		public function resize(width:Number, height:Number):void {
			_width = width;
			_height = height;
			loader.x = defaults['margin'];
			loader.y = _height - loader.height - defaults['margin'];
		}
		
		
		/** Gets a configuration parameter **/
		protected function getConfigParam(param:String):* {
			return defaults[param];
		}
	}
}