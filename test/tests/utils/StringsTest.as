package tests.utils {
	import com.longtailvideo.jwplayer.utils.Strings;
	
	import org.flexunit.Assert;

	public class StringsTest {
		
		[Test]
		public function testExtension():void {
			Assert.assertEquals("flv", Strings.extension("bunny.flv"));
			Assert.assertEquals("jpeg", Strings.extension("bunny.flv.jpeg"));
			Assert.assertEquals("wmv", Strings.extension("http://www.microsoft.com/bunny.wmv"));

			Assert.assertEquals("", Strings.extension("bunnyflv"));
		}
			
	}
}