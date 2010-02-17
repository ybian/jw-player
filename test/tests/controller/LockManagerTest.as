package tests.controller {
	import com.longtailvideo.jwplayer.controller.LockManager;
	import com.longtailvideo.jwplayer.plugins.IPlugin;
	
	import org.flexunit.Assert;

	//import org.flexunit.Assert;
	
	public class LockManagerTest {
		private static var time:Number;
		private static var callbackValue:Number;
		private static var testPlugin1:TestPlugin1;
		private static var testPlugin2:TestPlugin2;
		private static var lockManager:LockManager;

		
		[Before]
		public function runBeforeClass():void {
			trace("Starting Test. Old time: "+time+" old value: "+callbackValue);
			time = (new Date()).time;
			callbackValue = 0;
			testPlugin1 = new TestPlugin1();
			testPlugin2 = new TestPlugin2();
			lockManager = new LockManager();
			Assert.assertFalse(lockManager.locked());
		}
		
		[Test]
		public function testNull():void {
		}
		
		[Test]
		public function testLock():void {
			lockManager.lock(testPlugin1, function():void{unlock(testPlugin1)});
			Assert.assertTrue(lockManager.locked());
		}
		
		[Test]
		public function testUnlock():void {
			Assert.assertFalse(lockManager.unlock(testPlugin1));
			Assert.assertFalse(lockManager.locked());
		}
		
		[Test]
		public function testCallback():void {
			lockManager.lock(testPlugin1, function():void{callbackValue = time;});
			lockManager.executeCallback();
			Assert.assertEquals(callbackValue, time);
			Assert.assertTrue(lockManager.locked());
		}
		
		[Test]
		public function testLockUnlock():void {
			lockManager.lock(testPlugin1, function():void{unlock(testPlugin1)});
			Assert.assertTrue(lockManager.locked());
			Assert.assertTrue(lockManager.unlock(testPlugin1));
			Assert.assertFalse(lockManager.locked());
		}
		
		[Test]
		public function testLockCallbackUnlock():void {
			lockManager.lock(testPlugin1, function():void{callbackValue = time;unlock(testPlugin1);});
			Assert.assertTrue(lockManager.locked());
			lockManager.executeCallback();
			Assert.assertEquals(callbackValue, time);
			Assert.assertFalse(lockManager.locked());
		}
		
		[Test]
		public function testLock1Lock2CallbackUnlock1():void {
			lockManager.lock(testPlugin1, function():void{callbackValue = time;unlock(testPlugin1);});
			Assert.assertTrue(lockManager.locked());
			lockManager.lock(testPlugin2, function():void{unlock(testPlugin2)}); 
			Assert.assertTrue(lockManager.locked());
			lockManager.executeCallback();
			Assert.assertEquals(callbackValue, time);
			Assert.assertFalse(lockManager.locked());
		}
		
		[Test]
		public function testLock1Lock2Unlock2():void {
			lockManager.lock(testPlugin1, function():void{unlock(testPlugin1)}); 
			Assert.assertTrue(lockManager.locked());
			lockManager.lock(testPlugin2, function():void{unlock(testPlugin2)}); 
			Assert.assertTrue(lockManager.locked());
			Assert.assertFalse(lockManager.unlock(testPlugin2));
			Assert.assertTrue(lockManager.locked());
		}
		
		[Test]
		public function testLock1Unlock1Lock2Unlock2():void {
			lockManager.lock(testPlugin1, function():void{unlock(testPlugin1)});
			Assert.assertTrue(lockManager.locked());
			Assert.assertTrue(lockManager.unlock(testPlugin1));
			Assert.assertFalse(lockManager.locked());
			lockManager.lock(testPlugin2, function():void{unlock(testPlugin2)});
			Assert.assertTrue(lockManager.locked());
			Assert.assertTrue(lockManager.unlock(testPlugin2));
			Assert.assertFalse(lockManager.locked());
		}
		
		
		[Test]
		public function testLock1Lock2CallbackUnlock1CallbackUnlock2():void {
			lockManager.lock(testPlugin1, function():void{callbackValue = time; unlock(testPlugin1);});
			Assert.assertTrue(lockManager.locked());
			lockManager.lock(testPlugin2, function():void{callbackValue = time;}); 
			Assert.assertTrue(lockManager.locked());
			lockManager.executeCallback();
			Assert.assertEquals(callbackValue, time);
			Assert.assertTrue(lockManager.locked());
			callbackValue = 0;
			lockManager.executeCallback();
			Assert.assertEquals(callbackValue, time);
			Assert.assertTrue(lockManager.unlock(testPlugin2));
			Assert.assertFalse(lockManager.locked());
		}
		
		private function unlock(plugin:IPlugin):void {
			lockManager.unlock(plugin);
		}
	}
}