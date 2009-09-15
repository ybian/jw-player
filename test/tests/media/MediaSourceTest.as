package tests.media {
	import com.longtailvideo.jwplayer.events.MediaEvent;
	import com.longtailvideo.jwplayer.events.MediaStateEvent;
	import com.longtailvideo.jwplayer.media.MediaSource;
	import com.longtailvideo.jwplayer.media.MediaState;
	import com.longtailvideo.jwplayer.model.PlayerConfig;
	import com.longtailvideo.jwplayer.model.Playlist;
	import com.longtailvideo.jwplayer.model.PlaylistItem;
	
	import org.flexunit.Assert;
	import org.flexunit.async.Async;

	public class MediaSourceTest {
		protected var source:MediaSource;

		[Before]
		public function setup():void {
			var playerConfig:PlayerConfig = new PlayerConfig(new Playlist());
			source = new MediaSource(playerConfig);
		}

		[Test(async, timeout = "1000")]
		public function testMediaLoad():void {
			Async.handleEvent(this, source, MediaEvent.JWPLAYER_MEDIA_LOADED, mediaLoaded);
			Async.failOnEvent(this, source, MediaEvent.JWPLAYER_MEDIA_ERROR);
			source.load(new PlaylistItem());
		}

		private function mediaLoaded(event:MediaEvent, params:*):void {
			Assert.assertNotNull(event.target as MediaSource);
		}

		[Test(async, timeout = "1000")]
		public function testMediaPlay():void {
			Async.handleEvent(this, source, MediaStateEvent.JWPLAYER_MEDIA_STATE, mediaPlaying);
			Async.failOnEvent(this, source, MediaEvent.JWPLAYER_MEDIA_ERROR);
			source.play();
		}

		private function mediaPlaying(event:MediaStateEvent, params:*):void {
			Assert.assertNotNull(event.target as MediaSource);
			Assert.assertEquals(MediaState.PLAYING, event.newstate);
		}

	}
}