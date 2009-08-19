package {
	import org.flexunit.runner.FlexUnitCore;
	import flash.desktop.NativeApplication;	
	import flash.display.Sprite;
	
	
	/**
	 * The test launcher sets up the FlexUnit enviroment for testing, adds the test suites, and
	 * creates the ResultPrinter.
	 * 
	 * @author zach@longtailvideo.com
	 * @date 2009-08-18
	 */
	public class PlayerTestLauncher extends Sprite {
		private var core:FlexUnitCore;
		
		public function PlayerTestLauncher() {
				core = new FlexUnitCore();
				core.addListener(new PlayerTestRunListener(this, new PlayerTestResultPrinter()));
				core.run(PlayerTestSuite);
		}
		
		/**
		 * Terminates the Air Debug Launcher, with an appropriate status code, when testing is done.
		 * @param status The appropriate exit code.
		 */
		public function complete(status:Number):void {
			NativeApplication.nativeApplication.exit(status);
		}
	}
}