package tests.config {
	import com.longtailvideo.jwplayer.model.Model;
	import com.longtailvideo.jwplayer.model.PlayerConfig;
	
	import flexunit.framework.Assert;

	public class ConfigLoadXMLTest {
		private var config:PlayerConfig;
		private var inputObject:XML =  <config>
				<controlbar>bottom</controlbar>
				<dock>false</dock>
				<height>300</height>
				<icons>true</icons>
				<playlist>none</playlist>
				<playlistsize>180</playlistsize>
				<width>400</width>
				<autostart>false</autostart>
				<bufferlength>1</bufferlength>
				<displayclick>play</displayclick>
				<fullscreen>false</fullscreen>
				<item>0</item>
				<linktarget>_blank</linktarget>
				<mute>false</mute>
				<repeat>none</repeat>
				<resizing>true</resizing>
				<shuffle>false</shuffle>
				<smoothing>true</smoothing>
				<stretching>uniform</stretching>
				<volume>90</volume>
				<abouttext>JW Player</abouttext>
				<aboutlink>http://www.longtailvideo.com/players/jw-flv-player/</aboutlink>
				<debug>none</debug>
				<version>4.6.248</version>
				<pluginconfig>
					<plugin name="hd">
						<file>hdfile.flv</file>
					</plugin>
					<plugin name="gapro">
						<id>abc123</id>
					</plugin>
				</pluginconfig>
			</config>;

		[Before]
		public function setup():void {
			config = new PlayerConfig(new Model());
		}

		[Test]
		public function testObjectLoad():void {
			Assert.assertNotNull(inputObject);
			try {
				config.setConfig(inputObject);
			} catch (e:Error) {
				Assert.fail("Config could not be loaded: " + e.message);
			}

			for each(var key:XML in inputObject.children()) {
				if (key.name() != "pluginconfig") {
					try {
						Assert.assertEquals("Config[" + key.name() + "] = " + config[key.name()], 
											key.toString().toLowerCase(),
											config[key.name()].toString().toLowerCase());
					} catch (e:Error) {
						Assert.fail("Config failed: " + e.message);
					}
				}
			}

		}
	}
}