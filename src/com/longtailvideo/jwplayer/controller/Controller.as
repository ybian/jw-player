package com.longtailvideo.jwplayer.controller {
	import com.longtailvideo.jwplayer.events.GlobalEventDispatcher;
	import com.longtailvideo.jwplayer.model.Model;
	import com.longtailvideo.jwplayer.player.Player;
	import com.longtailvideo.jwplayer.view.View;

	/**
	 * The Controller is responsible for handling Model / View events and calling the appropriate responders
	 *  
	 * @author Pablo Schklowsky
	 */
	public class Controller extends GlobalEventDispatcher {
		private var _player:Player;
		private var _model:Model;
		private var _view:View;
		
		public function Controller(player:Player, model:Model, view:View) {
			_player = player;
			_model = model;
			_view = view;
		}
	}
}