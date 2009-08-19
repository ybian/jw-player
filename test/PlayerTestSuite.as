package {
	import flexunit.framework.TestSuite;
	
	import tests.*;
	
	
	/**
	 * The PlayerTestSuite runs unit tests for the JW Player. Simply reference the test class, and
	 * The {@link org.flexunit.runners.Suite} runner will call each of the public methods.
	 *
	 * @author zach@longtailvideo.com
	 * @date 2009-08-18
	 */
	[Suite]
	[RunWith("org.flexunit.runners.Suite")]
	public class PlayerTestSuite {
		public var exampleTest:ExampleTest;
	}
}