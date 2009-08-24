package tests {
	import tests.config.ConfigLoadObjectTest;
	import tests.config.ConfigObjectTest;
	import tests.config.ConfiggerTest;
	import tests.config.TypeCheckerTest;

	[Suite]
	[RunWith("org.flexunit.runners.Suite")]
	public class ConfigSuite {
		public var t1:ConfigObjectTest;
		public var t2:ConfigLoadObjectTest;
		public var t3:TypeCheckerTest;
		public var t4:ConfiggerTest;
	}
}