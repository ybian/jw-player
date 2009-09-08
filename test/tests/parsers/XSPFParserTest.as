package tests.parsers {
	import com.longtailvideo.jwplayer.model.PlaylistItem;
	import com.longtailvideo.jwplayer.parsers.XSPFParser;
	
	import org.flexunit.Assert;

	public class XSPFParserTest {
		private var parser:XSPFParser = new XSPFParser();
		private var xml:XML = <playlist version="1" xmlns="http://xspf.org/ns/0/">
			<title>Example XSPF playlist</title>
			<tracklist>
		
				<track>
					<title>FLV video</title>
					<creator>the Peach Open Movie Project</creator>
					<info>http://www.bigbuckbunny.org/</info>
					<annotation>Big Buck Bunny is a short animated film by the Blender Institute, part of the Blender Foundation.</annotation>
					<location>../../testing/files/bunny.flv</location>
				</track>
		
				<track>
					<title>MP3 audio with thumb</title>
					<creator>the Peach Open Movie Project</creator>
					<info>http://www.bigbuckbunny.org/</info>
					<annotation>Big Buck Bunny is a short animated film by the Blender Institute, part of the Blender Foundation.</annotation>
					<location>files/bunny.mp3</location>
					<image>files/bunny.jpg</image>
				</track>
		
				<track>
					<title>PNG image with duration</title>
					<creator>the Peach Open Movie Project</creator>
					<annotation>Big Buck Bunny is a short animated film by the Blender Institute, part of the Blender Foundation.</annotation>
					<location>files/bunny.png</location>
					<meta rel="duration">10</meta>
				</track>
		
				<track>
					<title>Youtube video with start</title>
					<creator>the Peach Open Movie Project</creator>
					<info>http://www.bigbuckbunny.org/</info>
					<annotation>Big Buck Bunny is a short animated film by the Blender Institute, part of the Blender Foundation.</annotation>
					<location>http://youtube.com/watch?v=IBTE-RoMsvw</location>
					<meta rel="start">10</meta>
				</track>
		
			</tracklist>
		</playlist>;
		
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