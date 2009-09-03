package tests {
	import tests.parsers.ASXParserTest;
	import tests.parsers.ATOMParserTest;
	import tests.parsers.ITunesParserTest;
	import tests.parsers.MRSSParserTest;
	import tests.parsers.SMILParserTest;
	import tests.parsers.XSPFParserTest;

	[Suite]
	[RunWith("org.flexunit.runners.Suite")]
	public class ParserSuite {
		public var t1:ASXParserTest;
		public var t2:ATOMParserTest;
		public var t3:MRSSParserTest;
		public var t4:ITunesParserTest;
		public var t5:SMILParserTest;
		public var t6:XSPFParserTest;
	}
}