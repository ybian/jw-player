package tests.skins {
	import com.longtailvideo.jwplayer.view.skins.PNGSkin;
	
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
			Assert.assertTrue("Testing Controlbar.background", skin.getSkinElement('controlbar','background') is DisplayObject);	
			Assert.assertTrue("Testing Controlbar.shade", skin.getSkinElement('controlbar','shade') is DisplayObject);	
			Assert.assertTrue("Testing Controlbar.playButton", skin.getSkinElement('controlbar','playButton') is DisplayObject);	
			Assert.assertTrue("Testing Controlbar.playButtonOver", skin.getSkinElement('controlbar','playButtonOver') is DisplayObject);	
			Assert.assertTrue("Testing Controlbar.timeSliderRail", skin.getSkinElement('controlbar','timeSliderRail') is DisplayObject);	
			Assert.assertTrue("Testing Controlbar.timeSliderBuffer", skin.getSkinElement('controlbar','timeSliderBuffer') is DisplayObject);	
			Assert.assertTrue("Testing Controlbar.timeSliderProgress", skin.getSkinElement('controlbar','timeSliderProgress') is DisplayObject);	
			Assert.assertTrue("Testing Controlbar.timeSliderThumb", skin.getSkinElement('controlbar','timeSliderThumb') is DisplayObject);	
			Assert.assertTrue("Testing Controlbar.volumeSliderRail", skin.getSkinElement('controlbar','volumeSliderRail') is DisplayObject);	
			Assert.assertTrue("Testing Controlbar.volumeSliderBuffer", skin.getSkinElement('controlbar','volumeSliderBuffer') is DisplayObject);	
			Assert.assertTrue("Testing Controlbar.volumeSliderProgress", skin.getSkinElement('controlbar','volumeSliderProgress') is DisplayObject);
			
			
			Assert.assertTrue("Testing for the existence of display", skin.hasComponent('display'));
			Assert.assertTrue("Testing Display.background", skin.getSkinElement('display','background') is DisplayObject);	
			Assert.assertTrue("Testing Display.playIcon", skin.getSkinElement('display','playIcon') is DisplayObject);	
			Assert.assertTrue("Testing Display.muteIcon", skin.getSkinElement('display','muteIcon') is DisplayObject);	
			Assert.assertTrue("Testing Display.errorIcon", skin.getSkinElement('display','errorIcon') is DisplayObject);	
			Assert.assertTrue("Testing Display.bufferIcon", skin.getSkinElement('display','bufferIcon') is DisplayObject);	

			Assert.assertTrue("Testing for the existence of dock", skin.hasComponent('dock'));
			Assert.assertTrue("Testing Dock.button", skin.getSkinElement('dock','button') is DisplayObject);	
			Assert.assertTrue("Testing Dock.buttonOver", skin.getSkinElement('dock','buttonOver') is DisplayObject);	

			Assert.assertTrue("Testing for the existence of playlist", skin.hasComponent('playlist'));
			Assert.assertTrue("Testing Playlist.item", skin.getSkinElement('playlist','item') is DisplayObject);	
			Assert.assertTrue("Testing Playlist.itemOver", skin.getSkinElement('playlist','itemOver') is DisplayObject);	
			Assert.assertTrue("Testing Playlist.sliderRail", skin.getSkinElement('playlist','sliderRail') is DisplayObject);	
			Assert.assertTrue("Testing Playlist.sliderThumb", skin.getSkinElement('playlist','sliderThumb') is DisplayObject);	
		}
			
	}
}
