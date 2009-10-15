package tests.config {
	import com.longtailvideo.jwplayer.model.PlayerConfig;
	import com.longtailvideo.jwplayer.model.Playlist;
	
	import org.flexunit.Assert;

	public class ConfigObjectTest {
		private var config:PlayerConfig;
		
		[Before]
		public function setup():void {
			config = new PlayerConfig();
		} 
		
		[Test]
		public function testPlaylistItems():void {
			try {
				var file:String = config.file;
				var desc:String = config.description;
				Assert.assertEquals(file + desc, ""); 
			} catch(e:Error) {
				Assert.fail("Accessors failed: " + e.message); 
			}
		}

		[Test]
		public function testTypes():void {
			
		}
	}
}