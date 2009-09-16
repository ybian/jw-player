package tests.media {
	import com.longtailvideo.jwplayer.media.VideoMediaProvider;
	import com.longtailvideo.jwplayer.model.PlayerConfig;
	import com.longtailvideo.jwplayer.model.Playlist;
	
	public class VideoMediaProviderTest extends BaseMediaProviderTest {
		private var _mediaSources:Array = [new VideoMediaProvider(new PlayerConfig(new Playlist()))];
		private var _playlist:Array = [{'duration': 33, 'file':'http://developer.longtailvideo.com/svn/testing/files/bunny.flv'}];
		
		protected override function get mediaSources():Array {
			return _mediaSources;
		}
		
		protected override function get playlist():Array {
			return _playlist;
		}
	}
}
