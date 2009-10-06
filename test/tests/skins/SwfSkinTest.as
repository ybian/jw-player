package tests.skins {
	import com.longtailvideo.jwplayer.view.skins.SWFSkin;
	
	import flash.display.DisplayObject;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	
	import org.flexunit.Assert;
	import org.flexunit.async.Async;

	public class SwfSkinTest extends SkinBaseTest {
		
		[Before]
		public override function setup():void {
			skin = new SWFSkin();
		}

		[Test(async)]
		public override function testLoad():void {
			Async.handleEvent(this, skin, Event.COMPLETE, skinLoaded, 15000);
			Async.failOnEvent(this, skin, ErrorEvent.ERROR, 15000);
			skin.load("http://developer.longtailvideo.com/svn/skins/modieus/modieus.swf");
		}
		
		public function skinLoaded(evt:Event, params:*):void {
			Assert.assertTrue("Testing for the existence of controlbar", skin.hasComponent('controlbar'));
			Assert.assertTrue("Testing Controlbar.playButton", skin.getSkinElement('controlbar','playButton') is DisplayObject);	
			Assert.assertTrue("Testing Controlbar.muteButton", skin.getSkinElement('controlbar','muteButton') is DisplayObject);	
			Assert.assertTrue("Testing Controlbar.linkButton", skin.getSkinElement('controlbar','linkButton') is DisplayObject);	
			Assert.assertTrue("Testing Controlbar.pauseButton", skin.getSkinElement('controlbar','pauseButton') is DisplayObject);	
			Assert.assertTrue("Testing Controlbar.volumeSlider", skin.getSkinElement('controlbar','volumeSlider') is DisplayObject);	
			Assert.assertTrue("Testing Controlbar.timeSlider", skin.getSkinElement('controlbar','timeSlider') is DisplayObject);	
		}
			
	}
}
