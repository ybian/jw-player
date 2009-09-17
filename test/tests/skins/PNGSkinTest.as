package tests.skins {
	import com.longtailvideo.jwplayer.view.PNGSkin;
	
	import flash.display.DisplayObject;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	
	import org.flexunit.Assert;
	import org.flexunit.async.Async;

	public class PNGSkinTest extends SkinBaseTest {
		
		[Before]
		public override function setup():void {
			skin = new PNGSkin();
		}

		[Test(async,timeout="150000")]
		public override function testLoad():void {
			Async.handleEvent(this, skin, Event.COMPLETE, skinLoaded, 10000);
			Async.failOnEvent(this, skin, ErrorEvent.ERROR, 10000);
			skin.load("assets/skin/png/skin.xml");
		}
		
		public function skinLoaded(evt:Event, params:*):void {
			Assert.assertTrue("Testing for the existence of controlbar", skin.hasComponent('controlbar'));
			Assert.assertTrue("Testing Controlbar.back", skin.getSkinElement('controlbar','back') is DisplayObject);	
			Assert.assertTrue("Testing Controlbar.shade", skin.getSkinElement('controlbar','shade') is DisplayObject);	
			Assert.assertTrue("Testing Controlbar.playButton", skin.getSkinElement('controlbar','playButton') is DisplayObject);	
			Assert.assertTrue("Testing Controlbar.playButtonBack", skin.getSkinElement('controlbar','playButtonBack') is DisplayObject);	
			Assert.assertTrue("Testing Controlbar.playButtonOver", skin.getSkinElement('controlbar','playButtonOver') is DisplayObject);	
		}
			
	}
}
