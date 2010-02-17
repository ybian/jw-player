package tests {
	import tests.media.MediaProviderTest;
	import tests.media.HTTPMediaProviderTest;
	import tests.media.ImageMediaProviderTest;
	import tests.media.RTMPMediaProviderTest;
	import tests.media.SoundMediaProviderTest;
	import tests.media.VideoMediaProviderTest;
	import tests.media.YouTubeMediaProviderTest;

	[Suite]
	[RunWith("org.flexunit.runners.Suite")]
	public class MediaSuite {
		public var t0:MediaProviderTest;
		public var t1:VideoMediaProviderTest;
		public var t2:HTTPMediaProviderTest;
		public var t3:SoundMediaProviderTest;
		public var t4:ImageMediaProviderTest;
		public var t5:RTMPMediaProviderTest;
		public var t6:YouTubeMediaProviderTest;
	}
}