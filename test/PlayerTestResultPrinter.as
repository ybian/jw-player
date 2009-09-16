package {
	import org.flexunit.runner.Description;
	import org.flexunit.runner.IDescription;
	import org.flexunit.runner.Result;
	import org.flexunit.runner.notification.Failure;
	
	/**
	 * The test runner sets up the FlexUnit enviroment for testing, adds the test suites, and
	 * creates the ResultPrinter.
	 * 
	 * @author zach@longtailvideo.com
	 * @date 2009-08-18
	 */
	public class PlayerTestResultPrinter {
		private var tests:Object;
		private var run:IDescription;
		private var result:Result

		public function PlayerTestResultPrinter() {
			tests = {};
		}
		
		public function logRunStarted(description:IDescription):void {
			trace("Run started"+description.displayName);
			if (!run) {
				run = description;
			} else {
				throw new Error("Cannot start a duplicate run "+description.displayName);
			}
		}
		
		public function logRunFinished(result:Result):void {
			result = result;
			print();
		}
		
		public function logTestStarted(description:IDescription):void {
			if (!tests[description.displayName]) {
				tests[description.displayName] = {'start':description};
			} else {
				throw new Error("Cannot start a duplicate test "+description.displayName);
			}
		}
		
		public function logTestFinished(description:IDescription):void {
			tests[description.displayName]['result'] = description;
		}

		public function logTestFailure(failure:Failure):void {
			try {
				trace("description: "+failure.description);
				trace("exception: "+failure.exception);
				trace("message: "+failure.message);
				trace("stacktrace: "+failure.stackTrace);
				trace("testHeader: "+failure.testHeader);
				trace("string: "+failure.toString());
				tests[failure]['failure'] = failure;
			} catch (err:Error) {
				trace("\n"+err.toString()+"\n");
			}
		}

		public function logTestIgnored(description:IDescription):void {
			tests[description.displayName]['ignored'] = description;
		}

			
		public function print():void {
			/*try {
				log("");
				log(msg);
				log("All metadata: "+description.getAllMetadata().toXMLString());
				log("Display name: "+description.displayName);
				log("Suite: "+description.isSuite);
				log("Test: "+description.isTest);
				log("Test count: "+description.testCount);
				log("Children: "+description.children.toString());				
				log("Children: "+description.children.toArray().toString());
				log("Empty: "+description.isEmpty);
				log("");
			} catch (err:Error) {
				log(err.toString());
			}
			
			playerTestResultPrinter.log("testing run finished");
			playerTestResultPrinter.log("failureCount: " + result.failureCount);
			playerTestResultPrinter.log("failures: " + result.failures.toString());
			playerTestResultPrinter.log("ignore count: " + result.ignoreCount);
			playerTestResultPrinter.log("runcount: " + result.runCount);
			playerTestResultPrinter.log("runtime: " + result.runTime);
			playerTestResultPrinter.log("successful: " + result.successful);
			playerTestResultPrinter.print();
			
			trace(output);*/
		}
	}
}