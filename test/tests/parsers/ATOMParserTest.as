package tests.parsers {
	import com.longtailvideo.jwplayer.model.PlaylistItem;
	import com.longtailvideo.jwplayer.parsers.ATOMParser;
	
	import org.flexunit.Assert;

	public class ATOMParserTest  {
		private var parser:ATOMParser = new ATOMParser();
		private var xml:XML = <feed xmlns='http://www.w3.org/2005/Atom' 
			xmlns:media='http://search.yahoo.com/mrss/'  
			xmlns:jwplayer='http://developer.longtailvideo.com/trac/wiki/FlashFormats'>
			<title>Example ATOM playlist</title>
		
			<entry>
				<title>FLV Video</title>
				<link rel="alternate" href="http://www.bigbuckbunny.org/" />
				<summary>Big Buck Bunny is a short animated film by the Blender Institute, part of the Blender Foundation.</summary>
				<media:credit role="author">the Peach Open Movie Project</media:credit>
				<media:content url="../../testing/files/bunny.flv" type="video/x-flv" />
			</entry>
		
			<entry>
				<title>MP3 Audio with thumb</title>
				<link rel="alternate" type="text/html" href="http://www.bigbuckbunny.org/" />
				<summary>Big Buck Bunny is a short animated film by the Blender Institute, part of the Blender Foundation.</summary>
				<media:group>
					<media:credit role="author">the Peach Open Movie Project</media:credit>
					<media:content url="files/bunny.mp3" type="audio/mpeg" />
					<media:thumbnail url="files/bunny.jpg" />
				</media:group>
			</entry>
		
			<entry>
				<title>PNG Image with duration</title>
				<summary>Big Buck Bunny is a short animated film by the Blender Institute, part of the Blender Foundation.</summary>
				<media:credit role="author">the Peach Open Movie Project</media:credit>
				<media:content url="files/bunny.png" type="image/png" duration="10" />
			</entry>
		
			<entry>
				<title>Youtube video with start</title>
				<link rel="alternate" href="http://www.bigbuckbunny.org/" />
				<summary>Big Buck Bunny is a short animated film by the Blender Institute, part of the Blender Foundation.</summary>
				<media:credit role="author">the Peach Open Movie Project</media:credit>
				<media:content url="http://youtube.com/watch?v=IBTE-RoMsvw" type="text/html"/>
				<jwplayer:start>10</jwplayer:start>
			</entry>
		
		</feed>;
		
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