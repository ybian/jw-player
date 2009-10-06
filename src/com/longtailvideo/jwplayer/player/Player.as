package com.longtailvideo.jwplayer.player {
	import com.longtailvideo.jwplayer.controller.Controller;
	import com.longtailvideo.jwplayer.events.PlayerEvent;
	import com.longtailvideo.jwplayer.model.Model;
	import com.longtailvideo.jwplayer.model.PlayerConfig;
	import com.longtailvideo.jwplayer.model.Playlist;
	import com.longtailvideo.jwplayer.plugins.IPlugin;
	import com.longtailvideo.jwplayer.utils.Logger;
	import com.longtailvideo.jwplayer.utils.RootReference;
	import com.longtailvideo.jwplayer.view.interfaces.ISkin;
	import com.longtailvideo.jwplayer.view.PlayerComponents;
	import com.longtailvideo.jwplayer.view.View;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import com.longtailvideo.jwplayer.view.interfaces.ISkin;
	
	
	/**
	 * Sent when the player has been initialized and skins and plugins have been successfully loaded.
	 *
	 * @eventType com.longtailvideo.jwplayer.events.PlayerEvent.JWPLAYER_READY
	 */
	[Event(name="jwplayerReady", type = "com.longtailvideo.jwplayer.events.PlayerEvent")]


	/**
	 * Main class for JW Flash Media Player
	 *
	 * @author Pablo Schklowsky
	 */
	public class Player extends Sprite {
		private static var playerVersion:String = "5.0.1";
		
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

			model.addGlobalListener(forward);
			view.addGlobalListener(forward);
			controller.addGlobalListener(forward);

			// Initialize V4 "simulator" singleton
			var emu:PlayerV4Emulation = new PlayerV4Emulation(this);
			var jsAPI:JavascriptAPI = new JavascriptAPI(this);

			Logger.output = Logger.CONSOLE;

			controller.setupPlayer();
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
		 * The player's current configuration
		 */
		public function get config():PlayerConfig {
			return model.config;
		}

		/**
		 * Player version getter
		 */
		public static function get version():String {
			return playerVersion;
		}

		/**
		 * Reference to player's skin.  If no skin has been loaded, returns null.
		 */
		public function get skin():ISkin {
			return view.skin;
		}

		/**
		 * The current player state
		 */
		public function get state():String {
			return model.state;
		}

		/**
		 * The player's playlist
		 */
		public function get playlist():Playlist {
			return model.playlist;
		}

		/**
		 * Set to true when the player is blocking playback.
		 */
		public function get isBlocking():Boolean {
			return controller.blocking;
		}

		/**
		 * Request that the player block playback.  When the Player is blocking, the currently playing stream is 
		 * paused, and no new playback-related commands will be honored until <code>unblockPlayback</code> is 
		 * called. 
		 * 
		 * @param target Reference to plugin requesting playback blocking
		 * @return <code>true</code>, if the blocking request is successful.  If another plugin is blocking,returns
		 * <code>false</code>. 
		 */
		public function blockPlayback(target:IPlugin):Boolean {
			return controller.blockPlayback(target);
		}

		/**
		 * Unblocks the player.  If the player was buffering or playing when it was blocked, playback will resume.
		 * 
		 * @param target Reference to the requesting plugin. 
		 * @return <code>true</code>, if <code>target</code> had previously requested player blocking.
		 *
		 */
		public function unblockPlayback(target:IPlugin):Boolean {
			return controller.unblockPlayback(target);
		}
		
		public function volume(volume:Number):Boolean {
			return controller.setVolume(volume);
		}
		
		public function mute(state:Boolean):Boolean {
			return controller.mute(state);
		}
		
		public function play():Boolean {
			return controller.play();
		}

		public function pause():Boolean {
			return controller.pause();	
		}
		
		public function stop():Boolean {
			return controller.stop();
		}
		
		public function seek(position:Number):Boolean {
			return controller.seek(position);
		}
		
		public function load(item:*):Boolean {
			return controller.load(item);
		}
		
		public function playlistItem(index:Number):Boolean {
			return controller.load(index);
		}
		
		public function playlistNext():Boolean {
			return controller.load(model.playlist.currentIndex+1);
		}

		public function playlistPrev():Boolean {
			return controller.load(model.playlist.currentIndex-1);
		}
		
		/** Force a redraw of the player **/
		public function redraw():Boolean {
			return controller.redraw();
		}
	
		public function fullscreen(on:Boolean):Boolean {
			return controller.fullscreen(on);
		}
		
		public function link(index:Number=NaN):Boolean {
			return controller.link(index);
		}
		
		public function get uiComponents():PlayerComponents {
			return view.components;
		}

	}
}