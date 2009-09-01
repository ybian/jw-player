package tests.skins {
	import com.longtailvideo.jwplayer.view.SWFSkin;
	
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

		[Test(async,timeout="5000")]
		public override function testLoad():void {
			Async.handleEvent(this, skin, Event.COMPLETE, skinLoaded);
			Async.failOnEvent(this, skin, ErrorEvent.ERROR);
			skin.load("http://developer.longtailvideo.com/svn/skins/modieus/modieus.swf");
		}
		
		public function skinLoaded(evt:Event, params:*):void {
			Assert.assertTrue("Testing for the existence of controlbar", skin.hasComponent('controlbar'));
			
			var chld:Object = skin.componentChildren('controlbar');
			for (var nam:String in chld) {
				trace(nam);	
			}
			
			Assert.assertTrue("Testing Controlbar.playButton", skin.getSkinElement('controlbar','playButton') is DisplayObject);	
			Assert.assertTrue("Testing Controlbar.muteButton", skin.getSkinElement('controlbar','muteButton') is DisplayObject);	
			Assert.assertTrue("Testing Controlbar.linkButton", skin.getSkinElement('controlbar','linkButton') is DisplayObject);	
			Assert.assertTrue("Testing Controlbar.pauseButton", skin.getSkinElement('controlbar','pauseButton') is DisplayObject);	
			Assert.assertTrue("Testing Controlbar.volumeSlider", skin.getSkinElement('controlbar','volumeSlider') is DisplayObject);	
			Assert.assertTrue("Testing Controlbar.timeSlider", skin.getSkinElement('controlbar','timeSlider') is DisplayObject);	
		}
			
	}
}
