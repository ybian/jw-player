package tests.media {
	import com.longtailvideo.jwplayer.player.PlayerState;
	
	
	
	public class MediaProviderTestDefinition {
		/** An identifier for the test **/
		protected var _name:String;
		/** The allowable states, transitions, and events **/
		protected var _states:Object;
		/** The operations to perform and the time to perform it**/
		protected var _operations:Array;
		
		public function MediaProviderTestDefinition(name:String) {
			_name = name;
			_states = {};
			_operations = [];
		}
		
		public function addState(name:String, transitions:Array, events:Array):void {
			_states[name] = {'name':name, 'transitions':transitions, 'events':events};
		}
		
		public function getState(name:String):Object {
			return _states[name];
		}
		
		/**
		 * Adds an operation to the end of test's queue
		 * 
		 * @param operation The operation to be performed
		 * @param time The time (in milliseconds) after the test starts to perform the operation
		 */
		public function addOperation(operation:String, time:Number, params:Object = null):void {
			_operations.push({'operation': operation, 'time': time, 'params': params});
		}
		
		public function getNextOperation():Object {
			return _operations.shift();
		}

		public function get name():String {
			return _name;
		}
		
		public function validTrasition(oldstate:String, newstate:String):Boolean {
			var result:Boolean = false;
			if ((_states[oldstate]['transitions'] as Array).indexOf(newstate) >= 0){
				result = true;
			}
			return result;
		}
		
		public function validEvent(state:String, eventType:String):Boolean {
			var result:Boolean = false;
			if ((_states[state]['events'] as Array).indexOf(eventType) >= 0){
				result = true;
			}
			return result;
		}
	}
}