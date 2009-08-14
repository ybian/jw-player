package com.longtailvideo.jwplayer.player {
	import com.jeroenwijering.events.AbstractView;
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
	 * Main class for JW Flash Media Player
	 *
	 * @author Pablo Schklowsky
	 *
	 */
	public class Player extends Sprite {
		private var zq:AbstractView;

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
		 * @return
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
		 *
		 */
		public function get isBlocking():Boolean {
			return false;
		}

		/**
		 *
		 * @param target
		 * @return
		 *
		 */
		public function blockPlayback(target:IPlugin):Boolean {
			return false;
		}

		/**
		 *
		 * @param target
		 * @return
		 *
		 */
		public function unblockPlayback(target:IPlugin):Boolean {
			return false;
		}

	}
}