package tests {
	import org.flexunit.Assert;

	
	/**
	 * This is an example test class. It should be instantiated by a {@link org.flexunit.runners.Suite}. 
	 * The {@link org.flexunit.runner.IRunner} will then call each public method.
	 * 
	 * @author zach@longtailvideo.com
	 * @date 2009-08-18
	 */
	public class ExampleTest {
		[Test]
		public function testTrue():void {
			Assert.assertTrue(true);
		}

		[Test]
		public function testFalse():void {
			Assert.assertFalse(false);
		}
		
		[Test]
		private function testFail():void {
			Assert.assertTrue(false);
			Assert.assertFalse(true);
		}
	}
}