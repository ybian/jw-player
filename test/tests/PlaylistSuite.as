package tests {
	import tests.playlist.PlaylistEventsTest;
	import tests.playlist.PlaylistTest;

	[Suite]
	[RunWith("org.flexunit.runners.Suite")]
	public class PlaylistSuite {
		public var t1:PlaylistTest;
		public var t2:PlaylistEventsTest;
	}
}