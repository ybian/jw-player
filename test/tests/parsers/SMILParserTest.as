package tests.parsers {
	import com.longtailvideo.jwplayer.model.PlaylistItem;
	import com.longtailvideo.jwplayer.parsers.SMILParser;
	
	import org.flexunit.Assert;

	public class SMILParserTest {
		private var parser:SMILParser = new SMILParser();
		private var xml:XML = <smil xmlns="http://www.w3.org/2001/SMIL20/Language">
			<head>
				<meta name="title" content="Example SMIL playlist for the JW Player"/>
			</head>
			<body>
				<seq>
		
					<par>
						<video
							title="FLV video"
							src="../../testing/files/bunny.flv"
							author="the Peach Open Movie Project"
							alt="Big Buck Bunny is a short animated film by the Blender Institute, part of the Blender Foundation."
						/>
						<anchor href="http://www.bigbuckbunny.org/" />
					</par>
		
					<par>
						<audio
							title="MP3 audio with thumb"
							src="files/bunny.mp3"
							alt="Big Buck Bunny is a short animated film by the Blender Institute, part of the Blender Foundation."
							author="the Peach Open Movie Project"
						/>
						<img src="files/bunny.jpg"/>
						<anchor href="http://www.bigbuckbunny.org/"/>
					</par>
		
					<par>
						<img
							title="PNG image with duration"
							src="files/bunny.png"
							alt="Big Buck Bunny is a short animated film by the Blender Institute, part of the Blender Foundation."
							dur="10"
						/>
					</par>
		
					<par>
						<video
							title="Youtube video with start"
							src="http://youtube.com/watch?v=IBTE-RoMsvw"
							author="the Peach Open Movie Project"
							alt="Big Buck Bunny is a short animated film by the Blender Institute, part of the Blender Foundation."
							begin="10"
						/>
						<anchor href="http://www.bigbuckbunny.org/" />
					</par>
		
				</seq>
			</body>
		</smil>;
		
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