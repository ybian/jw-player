package tests.media {
	import com.longtailvideo.jwplayer.media.SoundMediaProvider;
	import com.longtailvideo.jwplayer.model.PlayerConfig;
	import com.longtailvideo.jwplayer.model.Playlist;

	public class SoundMediaProviderTest extends MediaProviderTest {
		private var _mediaSources:Array = [new SoundMediaProvider()];
		private var _playlist:Array = [{'duration': 5, 'file':'http://developer.longtailvideo.com/svn/testing/files/bunny.mp3'}];
		
		protected override function get mediaSources():Array {
			return _mediaSources;
		}
		
		protected override function get playlist():Array {
			return _playlist;
		}
	}
}