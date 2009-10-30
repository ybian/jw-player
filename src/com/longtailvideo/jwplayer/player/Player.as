package com.longtailvideo.jwplayer.player {
	import com.longtailvideo.jwplayer.controller.Controller;
	import com.longtailvideo.jwplayer.events.PlayerEvent;
	import com.longtailvideo.jwplayer.model.IPlaylist;
	import com.longtailvideo.jwplayer.model.Model;
	import com.longtailvideo.jwplayer.model.PlayerConfig;
	import com.longtailvideo.jwplayer.plugins.IPlugin;
	import com.longtailvideo.jwplayer.utils.Logger;
	import com.longtailvideo.jwplayer.utils.RootReference;
	import com.longtailvideo.jwplayer.view.IPlayerComponents;
	import com.longtailvideo.jwplayer.view.View;
	import com.longtailvideo.jwplayer.view.interfaces.IPlayerComponent;
	import com.longtailvideo.jwplayer.view.interfaces.ISkin;
	
	import flash.display.Sprite;
	import flash.events.Event;
	
	
	/**
	 * Sent when the player has been initialized and skins and plugins have been successfully loaded.
	 *
	 * @eventType com.longtailvideo.jwplayer.events.PlayerEvent.JWPLAYER_READY
	 */
	[Event(name="jwplayerReady", type="com.longtailvideo.jwplayer.events.PlayerEvent")]
	/**
	 * Main class for JW Flash Media Player
	 *
	 * @author Pablo Schklowsky
	 */
	public class Player extends Sprite implements IPlayer {
		private var model:Model;
		private var view:View;
		private var controller:Controller;
		
		
		/** Player constructor **/
		public function Player() {
			new RootReference(this);
			try {
				this.addEventListener(Event.ADDED_TO_STAGE, setupPlayer);
			} catch (err:Error) {
				setupPlayer();
			}
		}
		
		
		private function setupPlayer(event:Event = null):void {
			try {
				this.removeEventListener(Event.ADDED_TO_STAGE, setupPlayer);
			} catch (err:Error) {
			}
			model = new Model();
			view = new View(this, model);
			controller = new Controller(this, model, view);
			controller.addEventListener(PlayerEvent.JWPLAYER_READY, playerReady);
			controller.setupPlayer();
		}
		
		
		protected function playerReady(evt:PlayerEvent):void {
			// Only handle JWPLAYER_READY once
			controller.removeEventListener(PlayerEvent.JWPLAYER_READY, playerReady);
			var jsAPI:JavascriptAPI = new JavascriptAPI(this);
			model.addGlobalListener(forward);
			view.addGlobalListener(forward);
			controller.addGlobalListener(forward);
			forward(evt);
		}
		
		
		/**
		 * Forwards all MVC events to interested listeners.
		 * @param evt
		 */
		protected function forward(evt:PlayerEvent):void {
			Logger.log(evt.toString(), evt.type);
			dispatchEvent(evt);
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function get config():PlayerConfig {
			return model.config;
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function get version():String {
			return PlayerVersion.version;
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function get commercial():Boolean {
			return PlayerVersion.commercial;
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function get skin():ISkin {
			return view.skin;
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function get state():String {
			return model.state;
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function get playlist():IPlaylist {
			return model.playlist;
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function get isBlocking():Boolean {
			return controller.blocking;
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function blockPlayback(target:IPlugin):Boolean {
			return controller.blockPlayback(target);
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function unblockPlayback(target:IPlugin):Boolean {
			return controller.unblockPlayback(target);
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function volume(volume:Number):Boolean {
			return controller.setVolume(volume);
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function get mute():Boolean {
			return model.mute;
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function set mute(state:Boolean):void {
			controller.mute(state);
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function play():Boolean {
			return controller.play();
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function pause():Boolean {
			return controller.pause();
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function stop():Boolean {
			return controller.stop();
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function seek(position:Number):Boolean {
			return controller.seek(position);
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function load(item:*):Boolean {
			return controller.load(item);
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function playlistItem(index:Number):Boolean {
			return controller.setPlaylistIndex(index);
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function playlistNext():Boolean {
			return controller.next();
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function playlistPrev():Boolean {
			return controller.previous();
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function redraw():Boolean {
			return controller.redraw();
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function get fullscreen():Boolean {
			return model.fullscreen;
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function set fullscreen(on:Boolean):void {
			controller.fullscreen(on);
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function link(index:Number = NaN):Boolean {
			return controller.link(index);
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function get controls():IPlayerComponents {
			return view.components;
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function overrideComponent(plugin:IPlayerComponent):void {
			view.overrideComponent(plugin);
		}
	}
}