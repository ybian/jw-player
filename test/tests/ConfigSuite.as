package tests {
	import tests.config.ConfigLoadObjectTest;
	import tests.config.ConfigLoadXMLTest;
	import tests.config.ConfigObjectTest;
	import tests.config.TypeCheckerTest;

	[Suite]
	[RunWith("org.flexunit.runners.Suite")]
	public class ConfigSuite {
		public var configObjectTest:ConfigObjectTest;
		public var configLoadObjectTest:ConfigLoadObjectTest;
		public var configLoadXMLTest:ConfigLoadXMLTest;
		public var typeCheckerTest:TypeCheckerTest;	
	}
}