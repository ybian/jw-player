package tests.playlist {
	import com.longtailvideo.jwplayer.events.PlaylistEvent;
	import com.longtailvideo.jwplayer.model.Playlist;
	
	import flash.events.Event;
	
	import flexunit.framework.Assert;

	public class PlaylistEventsTest {
		private var list:Playlist;
		
		[Before]
		public function preTest():void {
			list = new Playlist();
		}
		
		[Test(async,timeout="500")]
		public function testLoad():void {
			list.addEventListener(PlaylistEvent.JWPLAYER_PLAYLIST_LOADED, testLoadResult);
			list.load(null);
			
		}
		
		private function testLoadResult(evt:Event):void {
			Assert.assertTrue(evt is PlaylistEvent);
		}
		
	}
}