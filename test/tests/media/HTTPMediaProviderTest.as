package tests.media {
	import com.longtailvideo.jwplayer.model.PlayerConfig;
	import com.longtailvideo.jwplayer.model.Playlist;
	import com.longtailvideo.jwplayer.media.HTTPMediaProvider;	
	
	public class HTTPMediaProviderTest extends MediaProviderTest {
		private var _mediaSources:Array = [new HTTPMediaProvider()];
		private var _playlist:Array = [{'duration': 33, 'file':'bunny.flv', 'streamer':'http://www.longtailvideo.com/jw/embed/xmoov.php'}];

		protected override function get mediaSources():Array {
			return _mediaSources;
		}
		
		protected override function get playlist():Array {
			return _playlist;
		}
	}
}