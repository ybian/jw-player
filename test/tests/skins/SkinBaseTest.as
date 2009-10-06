package tests.skins {
	import com.longtailvideo.jwplayer.view.skins.SkinBase;
	
	import flash.events.ErrorEvent;
	import flash.events.Event;
	
	import org.flexunit.Assert;
	import org.flexunit.async.Async;

	public class SkinBaseTest {
		
		protected var skin:SkinBase;
		
		[Before]
		public function setup():void {
			skin = new SkinBase();
		}

		[Test(async,timeout="1000")]
		public function testLoad():void {
			Async.handleEvent(this, skin, Event.COMPLETE, loadHandler);
			Async.failOnEvent(this, skin, ErrorEvent.ERROR);
			skin.load();
		}
		
		public function loadHandler(evt:Event, params:*):void {
			Assert.assertTrue(true);
		}

	}
}
