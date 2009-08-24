package {
		import org.flexunit.flexui.TestRunnerBase;
		import org.flexunit.listeners.UIListener;
		import org.flexunit.runner.FlexUnitCore;
		import org.flexunit.runner.notification.async.XMLListener;
		import flash.desktop.NativeApplication;	

	
	/**
	 * The test launcher sets up the FlexUnit enviroment for testing, adds the test suites, and
	 * creates the ResultPrinter.
	 * 
	 * @author zach@longtailvideo.com
	 * @date 2009-08-18
	 */
	public class PlayerTestLauncher {
		private var core:FlexUnitCore;			
		private var visualRunner:TestRunnerBase;
		private var outputPath:String;

		public function PlayerTestLauncher(outputPath:String=null, visualRunner:TestRunnerBase=null) {
			this.outputPath = outputPath;
			var core:FlexUnitCore = new FlexUnitCore();
			if (visualRunner){
				this.visualRunner = visualRunner;
				core.addListener(new UIListener(visualRunner));
			}
			core.addListener(new PlayerTestRunListener(this, new PlayerTestResultPrinter(outputPath)));
			core.addListener(new XMLListener());
			core.run(PlayerTestSuite);
		}
		
		/**
		 * Terminates the Air Debug Launcher, with an appropriate status code, when testing is done.
		 * @param status The appropriate exit code.
		 */
		public function complete(status:Number):void {
			if (outputPath){
				visualRunner = null;
				NativeApplication.nativeApplication.exit(status);
			}
		}
	}
}