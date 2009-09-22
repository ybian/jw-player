package tests.media {
	import com.longtailvideo.jwplayer.events.MediaEvent;
	import com.longtailvideo.jwplayer.media.VideoMediaProvider;
	import com.longtailvideo.jwplayer.player.PlayerState;
	
	public class VideoMediaProviderTest extends MediaProviderTest {
		private var _mediaSources:Array = [new VideoMediaProvider()];
		private var _playlist:Array = [{'duration': 33, 'file':'http://developer.longtailvideo.com/svn/testing/files/bunny.flv'}];
		
		protected override function get mediaSources():Array {
			return _mediaSources;
		}
		
		protected override function get playlist():Array {
			return _playlist;
		}
		
		protected override function getSeekAheadTest():MediaProviderTestDefinition {
			var testDefinition:MediaProviderTestDefinition = new MediaProviderTestDefinition('seekahead');
			
			testDefinition.addOperation(MediaProviderTestJig.MEDIAPROVIDER_PLAY,0);
			testDefinition.addOperation(MediaProviderTestJig.MEDIAPROVIDER_SEEK,2000,10000);
			testDefinition.addOperation(MediaProviderTestJig.MEDIAPROVIDER_PLAY,4000);
			
			testDefinition.addState(PlayerState.IDLE,
				[PlayerState.PLAYING,PlayerState.BUFFERING],
				[MediaEvent.JWPLAYER_MEDIA_VOLUME, MediaEvent.JWPLAYER_MEDIA_LOADED,MediaEvent.JWPLAYER_MEDIA_META]);
				
			testDefinition.addState(PlayerState.BUFFERING,
				[PlayerState.PLAYING],
				[MediaEvent.JWPLAYER_MEDIA_BUFFER,MediaEvent.JWPLAYER_MEDIA_META]);
				
			testDefinition.addState(PlayerState.PLAYING,
				[PlayerState.BUFFERING,PlayerState.IDLE],
				[MediaEvent.JWPLAYER_MEDIA_TIME,MediaEvent.JWPLAYER_MEDIA_META]);
			
			testDefinition.addState(PlayerState.IDLE,
				[PlayerState.BUFFERING,PlayerState.PLAYING],
				[MediaEvent.JWPLAYER_MEDIA_META,MediaEvent.JWPLAYER_MEDIA_COMPLETE]);
			
			return testDefinition;
		}
	}
}
