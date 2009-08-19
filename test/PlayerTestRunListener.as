package {
	import org.flexunit.runner.IDescription;
	import org.flexunit.runner.Result;
	import org.flexunit.runner.notification.Failure;
	import org.flexunit.runner.notification.RunListener;
	
	
	/**
	 * The FlexUnit runtime reports test progress to the PlayerTestRunListener.
	 *
	 * @author zach@longtailvideo.com
	 * @date 2009-08-18
	 */
	public class PlayerTestRunListener extends RunListener {
		/** Configures, launches, and shuts down FlexUnit **/
		private var playerTestLauncher:PlayerTestLauncher;
		/** Sends output to the system **/
		private var playerTestResultPrinter:PlayerTestResultPrinter;
		
		
		public function PlayerTestRunListener(ptv:PlayerTestRunner, ptrp:PlayerTestResultPrinter) {
			this.playerTestLauncher = ptv;
			this.playerTestResultPrinter = ptrp;
		}
		
		
		/** @inheritDoc **/
		public override function testRunStarted(description:IDescription):void {
			playerTestResultPrinter.logDescription("test run started", description);
		}
		
		
		/** @inheritDoc **/
		public override function testRunFinished(result:Result):void {
			playerTestResultPrinter.log("testing run finished");
			playerTestResultPrinter.log("failureCount: " + result.failureCount);
			playerTestResultPrinter.log("failures: " + result.failures.toString());
			playerTestResultPrinter.log("ignore count: " + result.ignoreCount);
			playerTestResultPrinter.log("runcount: " + result.runCount);
			playerTestResultPrinter.log("runtime: " + result.runTime);
			playerTestResultPrinter.log("successful: " + result.successful);
			playerTestResultPrinter.print();
			var exitStatus:Number = result.successful ? 0 : 1;
			playerTestLauncher.complete(exitStatus);
		}
		
		
		/** @inheritDoc **/
		public override function testStarted(description:IDescription):void {
			playerTestResultPrinter.logDescription("test started", description);
		}
		
		
		/** @inheritDoc **/
		public override function testFinished(description:IDescription):void {
			playerTestResultPrinter.logDescription("test finished", description);
		}
		
		
		/** @inheritDoc **/
		public override function testFailure(failure:Failure):void {
			playerTestResultPrinter.log("test failed: " + failure.testHeader);
			playerTestResultPrinter.log(failure.toString());
		}
		
		
		/** @inheritDoc **/
		public override function testAssumptionFailure(failure:Failure):void {
			playerTestResultPrinter.log("test failed: " + failure.testHeader);
			playerTestResultPrinter.log(failure.toString());
		}
		
		
		/** @inheritDoc **/
		public override function testIgnored(description:IDescription):void {
			playerTestResultPrinter.logDescription("test ignored", description);
		}
	}
}