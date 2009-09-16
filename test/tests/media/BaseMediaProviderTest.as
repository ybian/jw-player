package tests.media {
	import com.longtailvideo.jwplayer.events.MediaEvent;
	import com.longtailvideo.jwplayer.media.MediaProvider;
	import com.longtailvideo.jwplayer.model.PlaylistItem;
	import com.longtailvideo.jwplayer.utils.Strings;
	
	import events.*;
	
	import flexunit.framework.Assert;
	
	import org.flexunit.async.Async;
	
	public class BaseMediaProviderTest {
		public var tester:MediaProviderTestJig;
		private var _mediaSources:Array = [];
		private var _playlist:Array = [];
		
		[Test(async,timeout="100000")]
		public function testMediaProvidersPlay():void {
			runTests('play');
		}
		
		
		[Test(async,timeout="40000")]
		public function testMediaProvidersStop():void {
			runTests('stop');
		}
		
		[Test(async,timeout="40000")]
		public function testMediaProvidersSeekBack():void {
			runTests('seekBack');
		}
		
		[Test(async,timeout="40000")]
		public function testMediaProvidersSeekAhead():void {
			runTests('seekAhead');
		}
		
		[Test(async,timeout="40000")]
		public function testMediaProvidersPause():void {
			runTests('pause');
		}
		
		private function runTests(testType:String):void {
			for each (var mediaSource:MediaProvider in mediaSources){
				for each (var playlistObject:Object in playlist){
					tester = new MediaProviderTestJig(mediaSource, new PlaylistItem(playlistObject), testType);
					var timeout:Number = playlistObject['duration']*1000+3000;
					Async.handleEvent(this, tester, TestingEvent.TEST_READY, runTest, timeout);
					Async.proceedOnEvent(this, tester, TestingEvent.TEST_BEGIN, timeout);
					Async.handleEvent(this, tester, TestingEvent.TEST_COMPLETE, completeTest, timeout);
					Async.failOnEvent(this, tester, TestingEvent.TEST_ERROR, timeout);
					tester.load();
					Assert.assertTrue(true);
				}
			}
		}
		
		private function runTest(evt:TestingEvent, param2:*):void {
			switch (evt.testType) {
				case 'play':
					tester.testPlay()
					break;
				case 'pause':
					tester.testPause();
					break;
				case 'stop':
					tester.testStop();
					break;
				case 'seekAhead':
					tester.testSeekAhead();
					break;
				case 'seekBack':
					tester.testSeekBack();
					break;
			}
		}
		
		private function completeTest(evt:TestingEvent, param2:*):void {
			Assert.assertNull(evt.testResult);
		}
		
		protected function get mediaSources():Array {
			return _mediaSources;
		}
		
		protected function get playlist():Array {
			return _playlist;
		}
	}
}