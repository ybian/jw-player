package tests.controller {
	import com.longtailvideo.jwplayer.player.IPlayer;
	import com.longtailvideo.jwplayer.plugins.IPlugin;
	import com.longtailvideo.jwplayer.plugins.PluginConfig;


	public class TestPlugin1 implements IPlugin {
		public function TestPlugin1() {
			//TODO: implement function
		}


		public function initPlugin(player:IPlayer, config:PluginConfig):void {
			//TODO: implement function
		}


		public function resize(width:Number, height:Number):void {
			//TODO: implement function
		}


		public function get id():String {
			//TODO: implement function
			return null;
		}
	}
}