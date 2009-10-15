package tests.config {
	import com.longtailvideo.jwplayer.model.PlayerConfig;
	import com.longtailvideo.jwplayer.model.Playlist;
	
	import org.flexunit.Assert;

	public class ConfigLoadObjectTest {
		private var config:PlayerConfig;
		private var inputObject:Object = {
			controlbar:'bottom',
			dock:false,
			height:'300',
			icons:true,
			playlist:'none',
			playlistsize:180,
			width:400,
			autostart:false,
			bufferlength:1,
			displayclick:'play',
			fullscreen:false,
			item:0,
			linktarget:'_blank',
			mute:false,
			repeat:'none',
			resizing:true,
			shuffle:false,
			smoothing:true,
			stretching:'uniform',
			volume:90,
			abouttext:"JW Player",
			aboutlink:"http://www.longtailvideo.com/players/jw-flv-player/",
			debug:'none',
			version:'4.6.248'
		};
		
		[Before]
		public function setup():void {
			config = new PlayerConfig();
		} 
		
		[Test]
		public function testObjectLoad():void {
			Assert.assertNotNull(inputObject);
			try {
				config.setConfig(inputObject);
			} catch (e:Error) {
				Assert.fail("Config could not be loaded: " + e.message);
			}
			
			for (var key:String in inputObject) {
				try {
					Assert.assertEquals("Config[" + key + "] = " + config[key], 
										inputObject[key].toString().toLowerCase(), 
										config[key].toString().toLowerCase());
				} catch (e:Error) {
					Assert.fail("Config failed: " + e.message);
				}
			}
			
		}
	}
}