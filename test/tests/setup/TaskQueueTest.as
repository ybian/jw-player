package tests.setup {
	import com.longtailvideo.jwplayer.controller.TaskQueue;
	
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import org.flexunit.Assert;
	import org.flexunit.async.Async;

	public class TaskQueueTest extends EventDispatcher {
		private var tasker:TaskQueue;
		private var remainingTasks:Array;
		
		[Before]
		public function setup():void {
			tasker = new TaskQueue();
		}
		
		[Test(async,timeout="2000")]
		public function testTaskQueue():void {
			tasker.queueTask(task1, task1success);
			tasker.queueTask(task2);
			tasker.queueTask(task3, task3success);
			remainingTasks = ['task1','task2','task3'];
			Async.handleEvent(this, tasker, Event.COMPLETE, taskerSuccess, 10000);
			Async.failOnEvent(this, tasker, ErrorEvent.ERROR);
			tasker.runTasks();
			
		}
		
		private function task1():void {
			var timer1:Timer = new Timer(100, 1);
			timer1.addEventListener(TimerEvent.TIMER_COMPLETE, tasker.success);
			timer1.start();
		}
		
		private function task1success(event:Event):void {
			Assert.assertTrue("Task 1 success", event is TimerEvent);
			Assert.assertEquals("All tasks remaining", "task1,task2,task3", remainingTasks.join(","));
			remainingTasks.splice(remainingTasks.indexOf("task1"), 1);
			Assert.assertEquals("Tasks 2 and 3 remaining", "task2,task3", remainingTasks.join(","));
		}
		
		private function task2():void {
			Assert.assertTrue("Task 2 success", true);
			Assert.assertEquals("All tasks remaining", "task2,task3", remainingTasks.join(","));
			remainingTasks.splice(remainingTasks.indexOf("task2"), 1);
			Assert.assertEquals("Task 3 remaining", "task3", remainingTasks.join(","));
			tasker.success();
		}
		
		private function task3():void {
			addEventListener(Event.COMPLETE, tasker.success);
			dispatchEvent(new ErrorEvent(Event.COMPLETE));
		}
		
		private function task3success(evt:Event):void {
			Assert.assertTrue("Task 3 success", evt is Event);
			Assert.assertEquals("All tasks remaining", "task3", remainingTasks.join(","));
			remainingTasks.splice(remainingTasks.indexOf("task3"), 1);
			Assert.assertEquals("No tasks remaining", "", remainingTasks.join(","));
		}

		private function taskerSuccess(evt:Event, params:*):void {		
			Assert.assertTrue(true);
		}
		
		[Test(async,timeout="1000")]
		public function testQueueFailure():void {
			tasker.queueTask(task4, task4success, task4failure);
			Async.handleEvent(this, tasker, ErrorEvent.ERROR, taskFailureHandler);
			Async.failOnEvent(this, tasker, Event.COMPLETE);
			tasker.runTasks();
		}
		
		private function task4():void {
			addEventListener("task4success", tasker.success);
			addEventListener("task4failure", tasker.failure);
			dispatchEvent(new Event("task4failure"));			
		}
		
		private function taskFailureHandler(evt:Event, params:*):void {
			Assert.assertTrue("Successfully received an error", true);
		}
		
		private function task4success(evt:Event):void {
			Assert.fail("Shouldn't get here");
		}

		private function task4failure(evt:Event):void {
			Assert.assertTrue("Should be here");
		}
		 
	}
}