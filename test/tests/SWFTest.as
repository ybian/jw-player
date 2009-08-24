package tests {
	import com.longtailvideo.jwplayer.utils.RootReference;
	
	import flash.display.DisplayObject;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	
	import org.flexunit.Assert;
	
	import mx.controls.Alert;
	import mx.controls.SWFLoader;
	
	import org.flexunit.async.Async;
	
	/**
	 * This is an example test class. It should be instantiated by a {@link org.flexunit.runners.Suite}. 
	 * The {@link org.flexunit.runner.IRunner} will then call each public method.
	 * 
	 * @author zach@longtailvideo.com
	 * @date 2009-08-18
	 */
	public class SWFTest {
		[Test(async)]
		public function testSWF():void {
			loadPlayer("file=test.mp4&plugins=blah1,blah2");
		}
		
		[Test(async)]
		public function testXMLConfig():void {
			loadPlayer("config=assets/config.xml&file=overwrite.flv");
		}

		/**
		 * Loads an instance of the JW Player with the specified flashvars
		 * @param flashvars
		 */
		private function loadPlayer(flashvars:String):void {
			loadSWF("player.swf?"+flashvars);
		}
		
		/**
		 * Loads a SWF from the specified URL
		 * @param url
		 */
		private function loadSWF(url:String):void {
			var loader:SWFLoader = new SWFLoader();
			loader.percentWidth = 100;
			loader.percentHeight = 100;
			loader.maintainAspectRatio = false;
			
//			loader.addEventListener(Event.COMPLETE, loadComplete);
//			loader.addEventListener(ErrorEvent.ERROR, loadError);
			Async.handleEvent(this, loader, Event.COMPLETE, loadComplete, 5000);
			Async.failOnEvent(this, loader, ErrorEvent.ERROR, 5000);
			
			loader.load(url);
		}
		
		/**
		 * Called when the SWF loads successfully
		 * @param evt Event containing the loaded SWF
		 */
		private function loadComplete(evt:Event, params:*):void {
			try {
				var loadedSwf:DisplayObject = (evt.target as SWFLoader).content;
				RootReference.stage.addChild(loadedSwf);
			} catch (e:Error) {
				Assert.fail(e.message);
			}
		}

	}
}