package com.longtailvideo.jwplayer.view {
	import com.longtailvideo.jwplayer.model.PlayerConfig;
	import com.longtailvideo.jwplayer.player.Player;
	import com.longtailvideo.jwplayer.view.interfaces.IControlbarComponent;
	import com.longtailvideo.jwplayer.view.interfaces.IDisplayComponent;
	import com.longtailvideo.jwplayer.view.interfaces.IDockComponent;
	import com.longtailvideo.jwplayer.view.interfaces.IPlaylistComponent;
	import com.longtailvideo.jwplayer.view.interfaces.ISkin;
	import com.longtailvideo.jwplayer.view.skins.SWFSkin;
	import com.longtailvideo.jwplayer.view.components.ControlbarComponentV4;
	import com.longtailvideo.jwplayer.view.components.ControlbarComponent;
	import com.longtailvideo.jwplayer.view.components.DisplayComponent;
	
	
	public class PlayerComponents {
		private var _controlbar:IControlbarComponent;
		private var _display:IDisplayComponent;
		private var _dock:IDockComponent;
		private var _playlist:IPlaylistComponent;
		private var _config:PlayerConfig;
		private var _skin:ISkin;
		
		
		public function PlayerComponents(player:Player) {
			if (player.skin is SWFSkin) {
				_controlbar = new ControlbarComponentV4(player);
			} else {
				_controlbar = new ControlbarComponent(player);
			}
			_display = new DisplayComponent(player);
		}
		
		
		public function get controlbar():IControlbarComponent {
			return _controlbar;
		}
		
		
		public function get display():IDisplayComponent {
			return _display;
		}
		
		
		public function get dock():IDockComponent {
			return _dock;
		}
		
		
		public function get playlist():IPlaylistComponent {
			return _playlist;
		}
		
		
		private function set controlbar(bar:IControlbarComponent):void {
			_controlbar = bar;
		}
		
		
		public function resize(width:Number, height:Number):void {
			display.resize(width, height);
			_controlbar.resize(width, height);
		}
	}
}