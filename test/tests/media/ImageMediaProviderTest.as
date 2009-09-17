package tests.media {
	import com.longtailvideo.jwplayer.media.ImageMediaProvider;
	import com.longtailvideo.jwplayer.model.PlayerConfig;
	import com.longtailvideo.jwplayer.model.Playlist;

	public class ImageMediaProviderTest extends MediaProviderTest {
		private var _mediaSources:Array = [new ImageMediaProvider()];
		private var _playlist:Array = [{'duration': 5, 'file':'http://developer.longtailvideo.com/svn/testing/files/bunny.jpg'},
			{'duration': 5, 'file':'http://developer.longtailvideo.com/svn/testing/files/bunny.png'}];
			
		protected override function get mediaSources():Array {
			return _mediaSources;
		}
		
		protected override function get playlist():Array {
			return _playlist;
		}
	}
}