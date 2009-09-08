package tests.parsers {
	import com.longtailvideo.jwplayer.model.PlaylistItem;
	import com.longtailvideo.jwplayer.parsers.RSSParser;
	
	import org.flexunit.Assert;

	public class MRSSParserTest {
		private var parser:RSSParser = new RSSParser();
		private var xml:XML = <rss version="2.0" 
			xmlns:media="http://search.yahoo.com/mrss/" 
			xmlns:jwplayer="http://developer.longtailvideo.com/trac/wiki/FlashFormats">
			<channel>
				<title>Example media RSS playlist</title>
		
				<item>
					<title>FLV Video</title>
					<link>http://www.bigbuckbunny.org/</link>
					<description>Big Buck Bunny is a short animated film by the Blender Institute, part of the Blender Foundation.</description>
					<pubDate>Sat, 07 Sep 2002 09:42:31 GMT</pubDate>
					<media:credit role="author">the Peach Open Movie Project</media:credit>
					<media:content url="../../testing/files/bunny.flv" />
				</item>
		
				<item>
					<title>MP3 Audio with thumb</title>
					<link>http://www.bigbuckbunny.org/</link>
					<description>Big Buck Bunny is a short animated film by the Blender Institute, part of the Blender Foundation.</description>
					<pubDate>Sat, 07 Sep 2002 09:42:31 GMT</pubDate>
					<media:credit role="author">the Peach Open Movie Project</media:credit>
					<media:content url="files/bunny.mp3" />
					<media:thumbnail url="files/bunny.jpg" />
				</item>
		
				<item>
					<title>PNG Image with duration</title>
					<description>Big Buck Bunny is a short animated film by the Blender Institute, part of the Blender Foundation.</description>
					<pubDate>Sat, 07 Sep 2002 09:42:31 GMT</pubDate>
					<media:group>
						<media:credit role="author">the Peach Open Movie Project</media:credit>
						<media:content url="files/bunny.png" duration="10" />
					</media:group>
				</item>
		
				<item>
					<title>Youtube video with start</title>
					<link>http://www.bigbuckbunny.org/</link>
					<description>Big Buck Bunny is a short animated film by the Blender Institute, part of the Blender Foundation.</description>
					<pubDate>Sat, 07 Sep 2002 09:42:31 GMT</pubDate>
					<media:group>
						<media:credit role="author">the Peach Open Movie Project</media:credit>
						<media:content url="http://youtube.com/watch?v=IBTE-RoMsvw" />
					</media:group>
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