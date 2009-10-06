package tests {
	import tests.skins.DefaultSkinTest;
	import tests.skins.PNGSkinTest;
	import tests.skins.SkinBaseTest;
	import tests.skins.SwfSkinTest;

	[Suite]
	[RunWith("org.flexunit.runners.Suite")]
	public class SkinSuite {
		public var t1:SkinBaseTest;
		public var t2:DefaultSkinTest;		
		public var t3:SwfSkinTest;
//		public var t4:PNGSkinTest;
	}
}