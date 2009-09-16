package {
		import flash.system.System;
		
		import org.flexunit.flexui.TestRunnerBase;
		import org.flexunit.listeners.UIListener;
		import org.flexunit.runner.FlexUnitCore;
		import org.flexunit.runner.notification.async.XMLListener;
	
	/**
	 * The test launcher sets up the FlexUnit enviroment for testing, adds the test suites, and
	 * creates the ResultPrinter.
	 * 
	 * @author zach@longtailvideo.com
	 * @date 2009-08-18
	 */
	public class PlayerTestLauncher {
		private var visualRunner:TestRunnerBase;
		private var core:FlexUnitCore;			

		public function PlayerTestLauncher(visualRunner:TestRunnerBase = null) {
			try {
				core = new FlexUnitCore();
				if (visualRunner) {
					this.visualRunner = visualRunner;
					core.addListener(new UIListener(visualRunner));
				}
				core.addListener(new XMLListener("Astaire"));
				core.addListener(new PlayerTestRunListener(this, new PlayerTestResultPrinter()));
				core.run(PlayerTestSuite);
			} catch (err:Error){
				trace (err);
			}
		}
		
		/**
		 * Terminates the Air Debug Launcher, with an appropriate status code, when testing is done.
		 * @param status The appropriate exit code.
		 */
		public function complete(status:Number):void {
			flash.system.System.exit(status);
		}
	}
}