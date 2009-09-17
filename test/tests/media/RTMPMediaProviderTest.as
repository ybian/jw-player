package tests.media {
	import com.longtailvideo.jwplayer.media.RTMPMediaProvider;
	import com.longtailvideo.jwplayer.model.PlayerConfig;
	import com.longtailvideo.jwplayer.model.Playlist;
	
	public class RTMPMediaProviderTest extends MediaProviderTest {
		private var _mediaSources:Array = [new RTMPMediaProvider()];
		private var _playlist:Array = [{'duration': 35, 'file':'bunny.flv', 'streamer':'rtmp://edge01.fms.dutchview.nl/botr'}];

		protected override function get mediaSources():Array {
			return _mediaSources;
		}
		
		protected override function get playlist():Array {
			return _playlist;
		}
	}
}