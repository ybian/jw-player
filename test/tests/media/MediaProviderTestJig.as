package tests.media {
	import com.longtailvideo.jwplayer.events.MediaEvent;
	import com.longtailvideo.jwplayer.events.PlayerEvent;
	import com.longtailvideo.jwplayer.events.PlayerStateEvent;
	import com.longtailvideo.jwplayer.media.MediaProvider;
	import com.longtailvideo.jwplayer.model.PlayerConfig;
	import com.longtailvideo.jwplayer.model.Playlist;
	import com.longtailvideo.jwplayer.model.PlaylistItem;
	import com.longtailvideo.jwplayer.player.PlayerState;
	import com.longtailvideo.jwplayer.utils.RootReference;
	import com.longtailvideo.jwplayer.utils.Strings;
	
	import events.*;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.setTimeout;
	
	
	public class MediaProviderTestJig extends EventDispatcher {
		/**
		 * Dispatched when the user presses the Button control.
		 * If the <code>autoRepeat</code> property is <code>true</code>,
		 * this event is dispatched repeatedly as long as the button stays down.
		 *
		 * @eventType IOErrorEvent.NETWORK_ERROR
		 */
		[Event(name="testReady", type="TestingEvent")]
		[Event(name="testBegin", type="TestingEvent")]
		[Event(name="testComplete", type="TestingEvent")]
		[Event(name="testError", type="TestingEvent")]
		/** The sequence of resulting events **/
		public static var MEDIAPROVIDER_PLAY:String = 'play';
		public static var MEDIAPROVIDER_PAUSE:String = 'pause';
		public static var MEDIAPROVIDER_LOAD:String = 'load';
		public static var MEDIAPROVIDER_SEEK:String = 'seek';
		public static var MEDIAPROVIDER_STOP:String = 'stop';
		public static var MEDIAPROVIDER_SETVOLUME:String = 'setvolume';
		protected static var mediaEventDefaults:Object = {bufferPercent: -1, duration: -1, metadata: {}, position: -1, volume: -1};
		protected static var stateDefaults:Object = {oldstate: "", newstate: ""};
		protected var _testDefinition:String;
		protected var _provider:MediaProvider;
		protected var _playlistItem:PlaylistItem;
		protected var _testDefintion:MediaProviderTestDefinition;
		protected var _currentState:Object;
		protected var _lastTime:Number;
		
		
		public function MediaProviderTestJig(source:MediaProvider, playlistItem:PlaylistItem, testDefintion:MediaProviderTestDefinition):void {
			_provider = source;
			source.initializeMediaProvider(new PlayerConfig());
			_playlistItem = playlistItem;
			_testDefintion = testDefintion;
			_currentState = testDefinition.getState(PlayerState.IDLE);
			addListeners();
		}
		
		
		private function addListeners():void {
			provider.addEventListener(MediaEvent.JWPLAYER_MEDIA_LOADED, loadHandler);
			provider.addEventListener(MediaEvent.JWPLAYER_MEDIA_VOLUME, eventHandler);
			provider.addEventListener(MediaEvent.JWPLAYER_MEDIA_BUFFER, eventHandler);
			provider.addEventListener(PlayerStateEvent.JWPLAYER_PLAYER_STATE, eventHandler);
			provider.addEventListener(MediaEvent.JWPLAYER_MEDIA_TIME, eventHandler);
			provider.addEventListener(MediaEvent.JWPLAYER_MEDIA_META, eventHandler);
			provider.addEventListener(MediaEvent.JWPLAYER_MEDIA_ERROR, errorHandler);
			provider.addEventListener(MediaEvent.JWPLAYER_MEDIA_COMPLETE, completeHandler);
		}
		
		
		public function load():void {
			provider.load(playlistItem);
		}
		
		
		private function loadHandler(evt:MediaEvent):void {
			if (provider.display) {
				RootReference.stage.addChild(provider.display);
			}
			eventHandler(evt);
			this.dispatchEvent(new TestingEvent(TestingEvent.TEST_READY, testDefinition.name));
		}
		
		
		public function run():void {
			var operation:Object = testDefinition.getNextOperation();
			while (operation) {
				var operationType:String = operation['operation'] as String;
				var time:Number = operation['time'] as Number;
				var params:Object = operation['params'] as Object
				switch (operationType) {
					case MEDIAPROVIDER_PLAY:
						setTimeout(provider.play, time);
						break;
					case MEDIAPROVIDER_PAUSE:
						setTimeout(provider.pause, time);
						break;
					case MEDIAPROVIDER_STOP:
						setTimeout(provider.stop, time);
						break;
					case MEDIAPROVIDER_SEEK:
						setTimeout(provider.seek, time, params);
						break;
				}
				operation = testDefinition.getNextOperation();
			}
			_currentState = testDefinition.getState(PlayerState.IDLE);
			dispatchTestBegin();
		}
		
		
		private function dispatchTestBegin():void {
			this.dispatchEvent(new TestingEvent(TestingEvent.TEST_BEGIN, testDefinition.name));
		}
		
		
		private function errorHandler(evt:MediaEvent):void {
			var result:Array = new Array();
			result.push(evt);
			this.dispatchEvent(new TestingEvent(TestingEvent.TEST_ERROR, testDefinition.name));
		}
		
		
		private function eventHandler(testEvent:PlayerEvent):void {
			var time:Date = new Date();
			switch (testEvent.type) {
				case PlayerStateEvent.JWPLAYER_PLAYER_STATE:
					var stateEvent:PlayerStateEvent = (testEvent as PlayerStateEvent);
					if (testDefinition.validTrasition(stateEvent.oldstate, stateEvent.newstate)) {
						trace(traceEvent(stateEvent, stateDefaults));
						_currentState = testDefinition.getState(stateEvent.newstate);
					} else {
						dispatchErrorEvent("Invalid state transition while running '" + testDefinition.name + "': " + traceEvent(stateEvent, stateDefaults));
					}
					break;
				default:
					if (currentState != null) {
						if (!testDefinition.validEvent(currentState['name'], testEvent.type)) {
							dispatchErrorEvent("Invalid event thrown while running '" + testDefinition.name + "' in the " + currentState['name'] + " state: " + traceEvent(testEvent, mediaEventDefaults));
						}
					} else {
						dispatchErrorEvent("Error: Recieved event while in an invalid state");
					}
					break;
			}
		}
		
		protected function completeHandler(evt:MediaEvent):void {
			hideDisplay();
			this.dispatchEvent(new TestingEvent(TestingEvent.TEST_COMPLETE, testDefinition.name));
		}
		
		
		protected function dispatchErrorEvent(errorMessage:String):void {
			hideDisplay();
			this.dispatchEvent(new TestingEvent(TestingEvent.TEST_COMPLETE, testDefinition.name, errorMessage));
		}
		
		
		protected function hideDisplay():void {
			if (provider.display) {
				provider.display.visible = false;
			}
		}
		
		
		private function traceEvent(event:Event, defaults:Object):String {
			var result:String = "[" + event.type + "] ";
			for (var property:String in defaults) {
				if (event[property] != defaults[property]) {
					if (typeof(event[property]) == "object") {
						var assignedValue:String = Strings.print_r(event[property]);
						var defaultValue:String = Strings.print_r(defaults[property]);
						if (defaultValue != assignedValue) {
							result += " " + property + ": " + assignedValue;
						}
					} else {
						result += " " + property + ": " + event[property];
					}
				}
			}
			return result;
		}
		
		
		protected function get provider():MediaProvider {
			return _provider;
		}
		
		
		protected function get playlistItem():PlaylistItem {
			return _playlistItem;
		}
		
		
		protected function get testDefinition():MediaProviderTestDefinition {
			return _testDefintion;
		}
		
		
		protected function get currentState():Object {
			return _currentState;
		}
	}
}