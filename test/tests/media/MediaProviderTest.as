package tests.media {
	import com.longtailvideo.jwplayer.events.MediaEvent;
	import com.longtailvideo.jwplayer.media.MediaProvider;
	import com.longtailvideo.jwplayer.model.PlaylistItem;
	import com.longtailvideo.jwplayer.player.PlayerState;
	
	import events.*;
	
	import flexunit.framework.Assert;
	
	import org.flexunit.async.Async;
	
	public class MediaProviderTest {
		public var tester:MediaProviderTestJig;
		private var _mediaSources:Array = [];
		private var _playlist:Array = [];
		
		protected function getPlayTest():MediaProviderTestDefinition {
			var testDefinition:MediaProviderTestDefinition = new MediaProviderTestDefinition('play');

			testDefinition.addOperation(MediaProviderTestJig.MEDIAPROVIDER_PLAY,0);

			testDefinition.addState(PlayerState.IDLE,
				[PlayerState.PLAYING,PlayerState.BUFFERING],
				[MediaEvent.JWPLAYER_MEDIA_VOLUME, MediaEvent.JWPLAYER_MEDIA_LOADED,MediaEvent.JWPLAYER_MEDIA_META]);

			testDefinition.addState(PlayerState.BUFFERING,
				[PlayerState.PLAYING],
				[MediaEvent.JWPLAYER_MEDIA_BUFFER,MediaEvent.JWPLAYER_MEDIA_META]);

			testDefinition.addState(PlayerState.PLAYING,
				[PlayerState.BUFFERING,PlayerState.IDLE],
				[MediaEvent.JWPLAYER_MEDIA_TIME,MediaEvent.JWPLAYER_MEDIA_META,MediaEvent.JWPLAYER_MEDIA_COMPLETE]);
				
			return testDefinition;
		}
		
		protected function getStopTest():MediaProviderTestDefinition {
			var testDefinition:MediaProviderTestDefinition = new MediaProviderTestDefinition('stop');
			
			testDefinition.addOperation(MediaProviderTestJig.MEDIAPROVIDER_PLAY,0);
			testDefinition.addOperation(MediaProviderTestJig.MEDIAPROVIDER_STOP,2000);
			testDefinition.addOperation(MediaProviderTestJig.MEDIAPROVIDER_PLAY,4000);
			
			testDefinition.addState(PlayerState.IDLE,
				[PlayerState.PLAYING,PlayerState.BUFFERING],
				[MediaEvent.JWPLAYER_MEDIA_VOLUME, MediaEvent.JWPLAYER_MEDIA_LOADED,MediaEvent.JWPLAYER_MEDIA_META]);
			
			testDefinition.addState(PlayerState.BUFFERING,
				[PlayerState.PLAYING,PlayerState.IDLE],
				[MediaEvent.JWPLAYER_MEDIA_BUFFER,MediaEvent.JWPLAYER_MEDIA_META]);
			
			testDefinition.addState(PlayerState.PLAYING,
				[PlayerState.BUFFERING,PlayerState.IDLE],
				[MediaEvent.JWPLAYER_MEDIA_TIME,MediaEvent.JWPLAYER_MEDIA_META,MediaEvent.JWPLAYER_MEDIA_COMPLETE]);
			
			return testDefinition;
		}
		
		protected function getSeekBackTest():MediaProviderTestDefinition {			
			var testDefinition:MediaProviderTestDefinition = new MediaProviderTestDefinition('seekback');
			
			testDefinition.addOperation(MediaProviderTestJig.MEDIAPROVIDER_PLAY,0);
			testDefinition.addOperation(MediaProviderTestJig.MEDIAPROVIDER_SEEK,2000,0);
			testDefinition.addOperation(MediaProviderTestJig.MEDIAPROVIDER_PLAY,4000);
			
			testDefinition.addState(PlayerState.IDLE,
				[PlayerState.PLAYING,PlayerState.BUFFERING],
				[MediaEvent.JWPLAYER_MEDIA_VOLUME, MediaEvent.JWPLAYER_MEDIA_LOADED,MediaEvent.JWPLAYER_MEDIA_META]);
			
			testDefinition.addState(PlayerState.BUFFERING,
				[PlayerState.PLAYING],
				[MediaEvent.JWPLAYER_MEDIA_BUFFER,MediaEvent.JWPLAYER_MEDIA_META]);
			
			testDefinition.addState(PlayerState.PLAYING,
				[PlayerState.BUFFERING,PlayerState.IDLE],
				[MediaEvent.JWPLAYER_MEDIA_TIME,MediaEvent.JWPLAYER_MEDIA_META,MediaEvent.JWPLAYER_MEDIA_COMPLETE]);
				
			return testDefinition;
		}

		
		protected function getSeekAheadTest():MediaProviderTestDefinition {
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
				[MediaEvent.JWPLAYER_MEDIA_TIME,MediaEvent.JWPLAYER_MEDIA_META,MediaEvent.JWPLAYER_MEDIA_COMPLETE]);
			
			return testDefinition;
		}
		
		protected function getPauseTest():MediaProviderTestDefinition {
			var testDefinition:MediaProviderTestDefinition = new MediaProviderTestDefinition('pause');
			
			testDefinition.addOperation(MediaProviderTestJig.MEDIAPROVIDER_PLAY,0);
			testDefinition.addOperation(MediaProviderTestJig.MEDIAPROVIDER_PAUSE,2000);
			testDefinition.addOperation(MediaProviderTestJig.MEDIAPROVIDER_PLAY,4000);

			testDefinition.addState(PlayerState.IDLE,
				[PlayerState.PLAYING,PlayerState.BUFFERING],
				[MediaEvent.JWPLAYER_MEDIA_VOLUME, MediaEvent.JWPLAYER_MEDIA_LOADED,MediaEvent.JWPLAYER_MEDIA_META]);

			testDefinition.addState(PlayerState.PAUSED,
				[PlayerState.PLAYING,PlayerState.BUFFERING],
				[MediaEvent.JWPLAYER_MEDIA_META]);

			testDefinition.addState(PlayerState.BUFFERING,
				[PlayerState.PLAYING,PlayerState.PAUSED],
				[MediaEvent.JWPLAYER_MEDIA_BUFFER,MediaEvent.JWPLAYER_MEDIA_META]);

			testDefinition.addState(PlayerState.PLAYING,
				[PlayerState.BUFFERING,PlayerState.IDLE,PlayerState.PAUSED],
				[MediaEvent.JWPLAYER_MEDIA_TIME,MediaEvent.JWPLAYER_MEDIA_META,MediaEvent.JWPLAYER_MEDIA_COMPLETE]);
				
			return testDefinition;
		}	
				
		[Test(async,timeout="100000")]
		public function testMediaProvidersPlay():void {
			runTests(getPlayTest());
		}
		
		[Test(async,timeout="40000")]
		public function testMediaProvidersPause():void {
			runTests(getPauseTest());
		}
		
		[Test(async,timeout="40000")]
		public function testMediaProvidersStop():void {			
			runTests(getStopTest());
		}
		
		[Test(async,timeout="40000")]
		public function testMediaProvidersSeekBack():void {
			runTests(getSeekBackTest());
		}
				
		[Test(async,timeout="40000")]
		public function testMediaProvidersSeekAhead():void {				
			runTests(getSeekAheadTest());
		}
		
		private function runTests(testDefinition:MediaProviderTestDefinition):void {
			for each (var mediaSource:MediaProvider in mediaSources){
				for each (var playlistObject:Object in playlist){
					tester = new MediaProviderTestJig(mediaSource, new PlaylistItem(playlistObject), testDefinition);
					var timeout:Number = playlistObject['duration']*1000+5000;
					Async.handleEvent(this, tester, TestingEvent.TEST_READY, runTest, timeout);
					Async.proceedOnEvent(this, tester, TestingEvent.TEST_BEGIN, timeout);
					Async.handleEvent(this, tester, TestingEvent.TEST_COMPLETE, handleComplete, timeout);
					Async.failOnEvent(this, tester, TestingEvent.TEST_ERROR, timeout);
					tester.load();
					Assert.assertTrue(true);
				}
			}
		}
		
		private function runTest(evt:TestingEvent, param2:*):void {
			tester.run();
		}
		
		private function handleComplete(evt:TestingEvent, param2:*):void {
			Assert.assertNull(evt.message);
		}
		
		protected function get mediaSources():Array {
			return _mediaSources;
		}
		
		protected function get playlist():Array {
			return _playlist;
		}
	}
}