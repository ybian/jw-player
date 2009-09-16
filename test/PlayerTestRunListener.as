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
		
		
		public function PlayerTestRunListener(ptl:PlayerTestLauncher, ptrp:PlayerTestResultPrinter) {
			this.playerTestLauncher = ptl;
			this.playerTestResultPrinter = ptrp;
		}
		
		
		/** @inheritDoc **/
		public override function testRunStarted(description:IDescription):void {
			playerTestResultPrinter.logRunStarted(description);
		}
		
		
		/** @inheritDoc **/
		public override function testRunFinished(result:Result):void {
			playerTestResultPrinter.logRunFinished(result);
			var exitStatus:Number = result.successful ? 0 : 1;
			playerTestLauncher.complete(exitStatus);
		}
		
		
		/** @inheritDoc **/
		public override function testStarted(description:IDescription):void {
			playerTestResultPrinter.logTestStarted(description);
		}
		
		
		/** @inheritDoc **/
		public override function testFinished(description:IDescription):void {
			playerTestResultPrinter.logTestFinished(description);
		}
		
		
		/** @inheritDoc **/
		public override function testFailure(failure:Failure):void {
			playerTestResultPrinter.logTestFailure(failure);
		}
		
		
		/** @inheritDoc **/
		public override function testAssumptionFailure(failure:Failure):void {
			playerTestResultPrinter.logTestFailure(failure);
		}
		
		
		/** @inheritDoc **/
		public override function testIgnored(description:IDescription):void {
			playerTestResultPrinter.logTestIgnored(description);
		}
	}
}