package com.longtailvideo.jwplayer.view {

	public class PlayerComponents {
		private var _controlbar:IControlbarComponent;
		private var _display:IDisplayComponent;
		private var _dock:IDockComponent;
		private var _playlist:IPlaylistComponent;
		
		private var _skin:ISkin;
		
		public function PlayerComponents(skin:ISkin) {
			_controlbar = new ControlBarComponent();
			_display = new DisplayComponent();
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

		internal function set controlbar(bar:IControlbarComponent):void {
			_controlbar = bar;
		}
		
	}
}