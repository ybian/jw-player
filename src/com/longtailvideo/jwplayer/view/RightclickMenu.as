package com.longtailvideo.jwplayer.view {

	import com.longtailvideo.jwplayer.events.GlobalEventDispatcher;
	import com.longtailvideo.jwplayer.events.ViewEvent;
	import com.longtailvideo.jwplayer.model.Model;
	import com.longtailvideo.jwplayer.player.PlayerVersion;
	import com.longtailvideo.jwplayer.utils.Configger;
	import com.longtailvideo.jwplayer.utils.Logger;
	import com.longtailvideo.jwplayer.utils.Stretcher;
	
	import flash.display.MovieClip;
	import flash.events.ContextMenuEvent;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.system.Capabilities;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;

	/**
	 * Implement a rightclick menu with "fullscreen", "stretching" and "about" options.
	 **/
	public class RightclickMenu extends GlobalEventDispatcher {

		/** Player model. **/
		protected var _model:Model;
		/** Context menu **/
		protected var context:ContextMenu;

		/** About JW Player menu item **/
		protected var about:ContextMenuItem;
		/** Debug menu item **/
		protected var debug:ContextMenuItem;
		/** Fullscreen menu item **/
		protected var fullscreen:ContextMenuItem;
		/** Stretching menu item **/
		protected var stretching:ContextMenuItem;
	
		/** Constructor. **/
		public function RightclickMenu(model:Model, clip:MovieClip) {
			_model = model;
			context = new ContextMenu();
			context.hideBuiltInItems();
			clip.contextMenu = context;
			initializeMenu();
		}

		/** Add an item to the contextmenu. **/
		private function addItem(itm:ContextMenuItem, fcn:Function):void {
			itm.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, fcn);
			itm.separatorBefore = true;
			context.customItems.push(itm);
		}

		/** Initialize the rightclick menu. **/
		public function initializeMenu():void {
			try {
				fullscreen = new ContextMenuItem('Toggle Fullscreen...');
				addItem(fullscreen, fullscreenHandler);
			} catch (err:Error) {
			}
			stretching = new ContextMenuItem('Stretching is ' + _model.config.stretching + '...');
			addItem(stretching, stretchHandler);
			if (_model.config['abouttext'] == 'JW Player' || _model.config['abouttext'] == undefined) {
				about = new ContextMenuItem('About JW Player ' + PlayerVersion.version + '...');
			} else {
				about = new ContextMenuItem('About ' + _model.config['abouttext'] + '...');
			}
			addItem(about, aboutHandler);
			if (Capabilities.isDebugger == true) {
				debug = new ContextMenuItem('Logging to ' + _model.config.debug + '...');
				addItem(debug, debugHandler);
			}
		}

		/** jump to the about page. **/
		private function aboutHandler(evt:ContextMenuEvent):void {
			navigateToURL(new URLRequest(_model.config['aboutlink']), '_blank');
		}

		/** change the debug system. **/
		private function debugHandler(evt:ContextMenuEvent):void {
			var arr:Array = new Array(Logger.NONE, Logger.ARTHROPOD, Logger.CONSOLE, Logger.TRACE);
			var idx:Number = arr.indexOf(_model.config.debug);
			idx == arr.length - 1 ? idx = 0 : idx++;
			debug.caption = 'Logging to ' + arr[idx] + '...';
			setCookie('debug', arr[idx]);
			_model.config.debug = arr[idx];
		}

		/** Toggle the fullscreen mode. **/
		private function fullscreenHandler(evt:ContextMenuEvent):void {
			dispatchEvent(new ViewEvent(ViewEvent.JWPLAYER_VIEW_FULLSCREEN, !_model.fullscreen));
		}

		/** Change the stretchmode. **/
		private function stretchHandler(evt:ContextMenuEvent):void {
			var arr:Array = new Array(Stretcher.UNIFORM, Stretcher.FILL, Stretcher.EXACTFIT, Stretcher.NONE);
			var idx:Number = arr.indexOf(_model.config.stretching);
			idx == arr.length - 1 ? idx = 0 : idx++;
			_model.config.stretching = arr[idx];
			stretching.caption = 'Stretching is ' + arr[idx] + '...';
			dispatchEvent(new ViewEvent(ViewEvent.JWPLAYER_VIEW_REDRAW));
		}
		
		private function setCookie(name:String, value:*):void {
			Configger.saveCookie(name, value);			
		}

	}

}