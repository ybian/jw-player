package {
		import org.flexunit.flexui.TestRunnerBase;
		import org.flexunit.listeners.UIListener;
		import org.flexunit.runner.FlexUnitCore;
		import flash.desktop.NativeApplication;	

	
	/**
	 * The test launcher sets up the FlexUnit enviroment for testing, adds the test suites, and
	 * creates the ResultPrinter.
	 * 
	 * @author zach@longtailvideo.com
	 * @date 2009-08-18
	 */
	public class PlayerTestLauncher extends TestRunnerBase {
		private var core:FlexUnitCore;			
		private var visualRunner:TestRunnerBase;

		public function PlayerTestLauncher(outputPath:String=null, visualRunner:TestRunnerBase=null) {
			
			var core:FlexUnitCore = new FlexUnitCore();
			if (visualRunner){
				this.visualRunner = visualRunner;
				core.addListener(new UIListener(visualRunner));
			}
			core.addListener(new PlayerTestRunListener(this, new PlayerTestResultPrinter(outputPath)));
			core.run(PlayerTestSuite);
		}
		
		/**
		 * Terminates the Air Debug Launcher, with an appropriate status code, when testing is done.
		 * @param status The appropriate exit code.
		 */
		public function complete(status:Number):void {
			if (!visualRunner){
				visualRunner = null;
				NativeApplication.nativeApplication.exit(status);
			}
		}
	}
}