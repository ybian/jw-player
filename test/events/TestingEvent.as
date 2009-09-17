package events {
	import flash.events.Event;

	/**
	 * Event class thrown by a TestingJig
	 * 
	 * @see TestingJig
	 * @author Pablo Schklowsky
	 */
	public class TestingEvent extends Event {
		
		/**
		 * The TestingEvent.TEST_READY constant defines the value of the
		 * <code>type</code> property of the event object
		 * for a <code>testReady</code> event.
		 *
		 * @see TestingJig
		 * @eventType testReady
		 */
		public static var TEST_READY:String = "testReady";
		
		/**
		 * The TestingEvent.TEST_BEGIN constant defines the value of the
		 * <code>type</code> property of the event object
		 * for a <code>testBegin</code> event.
		 *
		 * @see TestingJig
		 * @eventType testBegin
		 */
		public static var TEST_BEGIN:String = "testBegin";
		
		/**
		 * The TestingEvent.TEST_COMPLETE constant defines the value of the
		 * <code>type</code> property of the event object
		 * for a <code>testComplete</code> event.
		 *
		 * @see TestingJig
		 * @eventType testComplete
		 */
		public static var TEST_COMPLETE:String = "testComplete";

		/**
		 * The TestingEvent.TEST_ERROR constant defines the value of the
		 * <code>type</code> property of the event object
		 * for a <code>testError</code> event.
		 *
		 * @see TestingJig
		 * @eventType testError
		 */
		public static var TEST_ERROR:String = "testError";
		
		/** The type of test that was run **/
		public var testType:String;
		/** Whether the test was successful **/
		public var message:String;
		
		public function TestingEvent(type:String, testType:String, message:String = null) {
			super(type, false, false);
			this.testType = testType;
			this.message = message;
		}
	}
}