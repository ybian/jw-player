package com.longtailvideo.jwplayer.player {
	import com.longtailvideo.jwplayer.controller.Controller;
	import com.longtailvideo.jwplayer.model.Model;
	import com.longtailvideo.jwplayer.model.PlayerConfig;
	import com.longtailvideo.jwplayer.model.Playlist;
	import com.longtailvideo.jwplayer.plugins.IPlugin;
	import com.longtailvideo.jwplayer.view.ISkin;
	import com.longtailvideo.jwplayer.view.View;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.setTimeout;
	
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
		private var model:Model;
		private var view:View;
		private var controller:Controller;

		/** Player constructor **/
		public function Player() {
			// Small pause to allow Javascript to catch up
			setTimeout(initializePlayer, 50);
		}

		/** Initialize the Player **/
		protected function initializePlayer():void {
			model = new Model();
			view = new View();
			controller = new Controller(this, model, view);

			model.addGlobalListener(forward);
			view.addGlobalListener(forward);
			controller.addGlobalListener(forward);
		}

		/**
		 * Forwards all MVC events to interested listeners. 
		 * @param event
		 */
		protected function forward(event:Event):void {
			dispatchEvent(event);
		}

		/**
		 * The player's current configuration
		 */
		public function get config():PlayerConfig {
			return model.config;
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
			return false;
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
			return false;
		}

		/**
		 * Unblocks the player.  If the player was buffering or playing when it was blocked, playback will resume.
		 * 
		 * @param target Reference to the requesting plugin. 
		 * @return <code>true</code>, if <code>target</code> had previously requested player blocking.
		 *
		 */
		public function unblockPlayback(target:IPlugin):Boolean {
			return false;
		}

	}
}