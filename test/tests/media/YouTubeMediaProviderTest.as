package tests.media {
	import com.longtailvideo.jwplayer.media.YouTubeMediaProvider;
	import com.longtailvideo.jwplayer.model.PlayerConfig;
	import com.longtailvideo.jwplayer.model.Playlist;
	
	
	
	public class YouTubeMediaProviderTest extends MediaProviderTest {
		private var _mediaSources:Array = [new YouTubeMediaProvider()];
		private var _playlist:Array = [{'duration':33, 'file':'http://youtube.com/watch?v=IBTE-RoMsvw'}];
			
		protected override function get mediaSources():Array {
			return _mediaSources;
		}
		
		protected override function get playlist():Array {
			return _playlist;
		}
	}
}