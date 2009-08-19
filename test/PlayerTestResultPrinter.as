package {
	import org.flexunit.runner.IDescription;
	import flash.filesystem.FileStream;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;

	/**
	 * The test runner sets up the FlexUnit enviroment for testing, adds the test suites, and
	 * creates the ResultPrinter.
	 * 
	 * @author zach@longtailvideo.com
	 * @date 2009-08-18
	 */
	public class PlayerTestResultPrinter {
		private var output:String;
		
		public function PlayerTestResultPrinter() {
			output = "";
		}
		
		public function logDescription(msg:String, description:IDescription):void {
			log("");
			log(msg);
			log("All metadata: "+description.getAllMetadata().toXMLString());
			log("Display name: "+description.displayName);
			log("Suite: "+description.isSuite);
			log("Test: "+description.isTest);
			log("Test count: "+description.testCount);
			log("Children: "+description.children.toString());				
			log("Children: "+description.children.toArray().toString());
			log("Empty: "+description.isEmpty);
			log("");
		}
		
		public function log(msg:String):void {
			this.output += "\n"+msg;
		}
			
		public function print():void {
			var newFile:File = File.documentsDirectory.resolvePath("result.xml");
			var fileStream:FileStream = new FileStream();
			fileStream.open(newFile, FileMode.WRITE);
			fileStream.writeUTFBytes(output);
			fileStream.close();
		}
	}
}