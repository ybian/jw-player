package tests.config {
	import com.longtailvideo.jwplayer.utils.Configger;
	
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.utils.getQualifiedClassName;
	
	import org.flexunit.Assert;
	import org.flexunit.async.Async;

	public class ConfiggerTest {
		
		private var configger:Configger;
		
		[Before]
		public function setup():void {
			configger = new Configger();
		}

		[Test(async,timeout="1000")]
		public function testXML():void {
			Async.handleEvent(this, configger, Event.COMPLETE, xmlSuccess);
			Async.failOnEvent(this, configger, ErrorEvent.ERROR);
			configger.loadXML("assets/config.xml");
		}
		
		private function xmlSuccess(evt:Event, params:*):void {
			Assert.assertNotNull(configger.config);
			Assert.assertEquals(configger.config['hd.file'], 'hdfile.flv');
		}

		[Test(async,timeout="2000")]
		public function testFlashvars():void {
			Async.handleEvent(this, configger, Event.COMPLETE, flashvarsSuccess);
			Async.failOnEvent(this, configger, ErrorEvent.ERROR);
			configger.loadFlashvars({'file':'bunny.swf', other:'true'});
		}

		private function flashvarsSuccess(evt:Event, params:*):void {
			Assert.assertEquals(configger.config['file'], "bunny.swf");
			Assert.assertNotNull(configger.config);
			Assert.assertEquals(getQualifiedClassName(configger.config), "Object");
		}

	}
}
