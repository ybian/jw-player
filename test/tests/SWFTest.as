package tests {
	import com.longtailvideo.jwplayer.utils.RootReference;
	
	import flash.events.ErrorEvent;
	import flash.events.Event;
	
	import flexunit.framework.Assert;
	
	import mx.controls.SWFLoader;
	
	/**
	 * This is an example test class. It should be instantiated by a {@link org.flexunit.runners.Suite}. 
	 * The {@link org.flexunit.runner.IRunner} will then call each public method.
	 * 
	 * @author zach@longtailvideo.com
	 * @date 2009-08-18
	 */
	public class SWFTest {
		[Test(async,timeout="2500")]
		public function testSWF():void {
			loadPlayer("file=test.mp4&plugins=blah1,blah2");
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
			loader.addEventListener(Event.COMPLETE, loadComplete);
			loader.addEventListener(ErrorEvent.ERROR, loadError);
			loader.load(url);
		}
		
		/**
		 * Called when the SWF loads successfully
		 * @param evt Event containing the loaded SWF
		 */
		private function loadComplete(evt:Event):void {
			var loadedSwf = evt.target.content;
			RootReference.stage.addChild(loadedSwf);
			Assert.assertTrue(true);
		}
		
		/**
		 * Called when the SWF fails to load.
		 * @param evt Error notification
		 */ 
		private function loadError(evt:ErrorEvent):void{
			Assert.assertTrue(false);
		}
	}
}