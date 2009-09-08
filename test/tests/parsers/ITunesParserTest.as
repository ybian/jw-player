package tests.parsers {
	import com.longtailvideo.jwplayer.model.PlaylistItem;
	import com.longtailvideo.jwplayer.parsers.RSSParser;
	
	import org.flexunit.Assert;

	public class ITunesParserTest {
		private var parser:RSSParser = new RSSParser();
		private var xml:XML = <rss version="2.0" 
			xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd" 
			xmlns:jwplayer="http://developer.longtailvideo.com/trac/wiki/FlashFormats">
			<channel>
				<title>Example iTunes RSS playlist</title>
		
				<item>
					<title>FLV Video</title>
					<link>http://www.bigbuckbunny.org/</link>
					<description>Big Buck Bunny is a short animated film by the Blender Institute, part of the Blender Foundation.</description>
					<enclosure url="../../testing/files/bunny.flv" type="video/x-flv" length="1192846" />
					<itunes:author>the Peach Open Movie Project</itunes:author>
				</item>
		
				<item>
					<title>MP3 Audio with image</title>
					<link>http://www.bigbuckbunny.org/</link>
					<description>Big Buck Bunny is a short animated film by the Blender Institute, part of the Blender Foundation.</description>
					<enclosure url="files/bunny.mp3" type="audio/mpeg" length="1192846" />
					<itunes:author>the Peach Open Movie Project</itunes:author>
					<jwplayer:image>files/bunny.jpg</jwplayer:image>
				</item>
		
				<item>
					<title>PNG Image with duration</title>
					<description>Big Buck Bunny is a short animated film by the Blender Institute, part of the Blender Foundation.</description>
					<enclosure url="files/bunny.png" type="image/png" length="1192846" />
					<itunes:author>the Peach Open Movie Project</itunes:author>
					<itunes:duration>00:10</itunes:duration>
				</item>
		
				<item>
					<title>Youtube video with start</title>
					<link>http://www.bigbuckbunny.org/</link>
					<description>Big Buck Bunny is a short animated film by the Blender Institute, part of the Blender Foundation.</description>
					<enclosure url="http://youtube.com/watch?v=IBTE-RoMsvw" type="text/html" length="1192846" />
					<itunes:author>the Peach Open Movie Project</itunes:author>
					<jwplayer:start>10</jwplayer:start>
				</item>
		
			</channel>
		</rss>;

		[Test]
		public function testParse():void {
			var list:Array = parser.parse(xml);
			Assert.assertEquals(4, list.length);
			Assert.assertTrue(list[0] is PlaylistItem);
			Assert.assertTrue(list[1] is PlaylistItem);
			Assert.assertTrue(list[2] is PlaylistItem);
			Assert.assertTrue(list[3] is PlaylistItem);
		}		
		
	}

}