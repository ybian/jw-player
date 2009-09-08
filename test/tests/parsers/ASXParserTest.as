package tests.parsers {

	import com.longtailvideo.jwplayer.model.PlaylistItem;
	import com.longtailvideo.jwplayer.parsers.ASXParser;
	
	import org.flexunit.Assert;

	public class ASXParserTest {
		private var parser:ASXParser = new ASXParser();
		private var xml:XML = <asx version="3.0">
			<title>Example ASX playlist</title>
		
			<entry>
				<title>FLV video</title>
				<author>the Peach Open Movie Project</author>
				<abstract>Big Buck Bunny is a short animated film by the Blender Institute, part of the Blender Foundation.</abstract>
				<moreinfo href="http://www.bigbuckbunny.org/" />
				<ref href="../../testing/files/bunny.flv" />
			</entry>
		
			<entry>
				<title>MP3 Audio with image</title>
				<author>the Peach Open Movie Project</author>
				<abstract>Big Buck Bunny is a short animated film by the Blender Institute, part of the Blender Foundation.</abstract>
				<ref href="files/bunny.mp3" />
				<moreinfo href="http://www.bigbuckbunny.org/" />
				<param name="image" value="files/bunny.jpg" />
			</entry>
		
			<entry>
				<title>PNG Image with duration</title>
				<author>the Peach Open Movie Project</author>
				<abstract>Big Buck Bunny is a short animated film by the Blender Institute, part of the Blender Foundation.</abstract>
				<ref href="files/bunny.png" />
				<duration value="00:00:10" />
			</entry>
		
			<entry>
				<title>Youtube video with start</title>
				<author>the Peach Open Movie Project</author>
				<abstract>Big Buck Bunny is a short animated film by the Blender Institute, part of the Blender Foundation.</abstract>
				<moreinfo href="http://www.bigbuckbunny.org/"/>
				<ref href="http://youtube.com/watch?v=IBTE-RoMsvw" />
				<starttime value="10" />
			</entry>
		</asx>;
		
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