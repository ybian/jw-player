package tests.config {
	import com.longtailvideo.jwplayer.model.Color;
	import com.longtailvideo.jwplayer.utils.TypeChecker;
	
	import org.flexunit.Assert;

	public class TypeCheckerTest {
		public var number:Number = 1;
		public var string:String = "1";
		public var boolean:Boolean = true;
		public var int:uint = 1;
		
		[Test]
		public function testNumericalFromString():void {
			var result:* = TypeChecker.fromString("1", "Number");
			Assert.assertTrue("Testing numerical", result is Number);
		}

		[Test]
		public function testStringFromString():void {
			var result:* = TypeChecker.fromString("Hello World", "String");
			Assert.assertTrue("Testing string", result is String);
		}

		[Test]
		public function testBooleanFromString():void {
			var result:* = TypeChecker.fromString("true", "Boolean");
			Assert.assertTrue("Testing boolean", result is Boolean);
		}

		[Test]
		public function testColorFromString():void {
			var result:* = TypeChecker.fromString("0x111111", "Color");
			Assert.assertTrue("Testing uint", result is Color);
		}

		[Test]
		public function testColors():void {
			Assert.assertEquals(0x00ff00, TypeChecker.stringToColor("#0F0"));
			Assert.assertEquals(0x123456, TypeChecker.stringToColor("0x123456"));
			Assert.assertEquals(0x877B31, TypeChecker.stringToColor("877B31"));
			
			Assert.assertEquals(0xFF0000, TypeChecker.stringToColor("Red"));
			Assert.assertEquals(0x00FF00, TypeChecker.stringToColor("GREEN"));
			Assert.assertEquals(0x0000FF, TypeChecker.stringToColor("blue"));
			Assert.assertEquals(0x00FFFF, TypeChecker.stringToColor("cyan"));
			Assert.assertEquals(0xFF00FF, TypeChecker.stringToColor("magenta"));
			Assert.assertEquals(0xFFFF00, TypeChecker.stringToColor("yeLLow"));
			Assert.assertEquals(0xFFFFFF, TypeChecker.stringToColor("white"));
			Assert.assertEquals(0, TypeChecker.stringToColor("black"));
			
			Assert.assertEquals(0, TypeChecker.stringToColor("asdf"));
		}
		
		[Test]
		public function testTypeChecker():void {
			Assert.assertEquals("Number", TypeChecker.getType(this, 'number'));
			Assert.assertEquals("String", TypeChecker.getType(this, 'string'));
			Assert.assertEquals("Boolean", TypeChecker.getType(this, 'boolean'));
			Assert.assertEquals("uint", TypeChecker.getType(this, 'int'));
		}

		[Test]
		public function testGuessType():void {
			Assert.assertEquals("String", TypeChecker.guessType("Foo"));
			Assert.assertEquals("Number", TypeChecker.guessType("1"));
			Assert.assertEquals("Color", TypeChecker.guessType("0x000000"));
			Assert.assertEquals("Color", TypeChecker.guessType("#000000"));
			Assert.assertEquals("Color", TypeChecker.guessType("0x123"));
			Assert.assertEquals("Color", TypeChecker.guessType("#456"));
			Assert.assertEquals("Number", TypeChecker.guessType("123456"));
			Assert.assertEquals("Boolean", TypeChecker.guessType("true"));
			Assert.assertEquals("Boolean", TypeChecker.guessType("false"));
			Assert.assertEquals("Boolean", TypeChecker.guessType("T"));
			Assert.assertEquals("Boolean", TypeChecker.guessType("F"));
		}

	}
}