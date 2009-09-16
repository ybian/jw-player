package tests.media {
	import com.longtailvideo.jwplayer.events.MediaEvent;
	import com.longtailvideo.jwplayer.events.MediaStateEvent;
	import com.longtailvideo.jwplayer.media.MediaProvider;
	import com.longtailvideo.jwplayer.media.MediaState;
	import com.longtailvideo.jwplayer.model.PlaylistItem;
	import com.longtailvideo.jwplayer.utils.RootReference;
	import com.longtailvideo.jwplayer.utils.Strings;
	
	import events.*;
	
	import flash.events.EventDispatcher;
	import flash.utils.setTimeout;
	
	import flexunit.framework.Assert;
	
	
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
		public var testResults:Array;
		public var source:MediaProvider;
		public var playlistItem:PlaylistItem;
		private var currentTestType:String;
		private static var mediaEventDefaults:Object = {bufferPercent: -1, duration: -1, metadata: {}, position: -1, volume: -1};
		private static var stateDefaults:Object = {oldstate: "", newstate: ""};
		
		
		public function MediaProviderTestJig(source:MediaProvider, playlistItem:PlaylistItem, testType:String):void {
			this.source = source;
			this.playlistItem = playlistItem;
			currentTestType = testType;
			this.addListeners();
			testResults = new Array();
		}
		
		
		private function addListeners():void {
			source.addEventListener(MediaEvent.JWPLAYER_MEDIA_LOADED, loadHandler);
			source.addEventListener(MediaEvent.JWPLAYER_MEDIA_VOLUME, eventHandler);
			source.addEventListener(MediaEvent.JWPLAYER_MEDIA_BUFFER, eventHandler);
			source.addEventListener(MediaStateEvent.JWPLAYER_MEDIA_STATE, stateHandler);
			source.addEventListener(MediaEvent.JWPLAYER_MEDIA_TIME, eventHandler);
			source.addEventListener(MediaEvent.JWPLAYER_MEDIA_META, eventHandler);
			source.addEventListener(MediaEvent.JWPLAYER_MEDIA_ERROR, errorHandler);
		}
		
		
		public function load():void {
			source.load(playlistItem);
		}
		
		
		private function loadHandler(evt:MediaEvent):void {
			if (source.display()) {
				RootReference.stage.addChild(source.display());
			}
			testResults.push({event: evt, time: new Date()});
			this.dispatchEvent(new TestingEvent(TestingEvent.TEST_READY, currentTestType));
		}
		
		
		public function testPlay():void {
			dispatchTestBegin();
			source.play();
		}
		
		
		public function testStop():void {
			dispatchTestBegin();
			source.play();
			setTimeout(source.stop, 1000);
			setTimeout(source.play, 2000);
		}
		
		
		public function testPause():void {
			dispatchTestBegin();
			source.play();
			setTimeout(source.pause, 1000);
			setTimeout(source.play, 2000);
		}
		
		
		public function testSeekBack():void {
			dispatchTestBegin();
			source.play();
			setTimeout(source.seek, 1000, 0);
		}
		
		
		public function testSeekAhead():void {
			dispatchTestBegin();
			source.play();
			setTimeout(source.seek, 4000, 10);
		}
		
		
		public function testSeekTooFar():void {
			dispatchTestBegin();
			source.play();
			setTimeout(source.seek, playlistItem.duration + 1000, 10);
		}
		
		
		private function dispatchTestBegin():void {
			this.dispatchEvent(new TestingEvent(TestingEvent.TEST_BEGIN, currentTestType));
		}
		
		
		private function eventHandler(evt:MediaEvent):void {
			testResults.push({event: evt, time: new Date()});
		}
		
		
		private function errorHandler(evt:MediaEvent):void {
			var result:Array = new Array();
			result.push(evt);
			this.dispatchEvent(new TestingEvent(TestingEvent.TEST_ERROR, currentTestType));
		}
		
		
		private function stateHandler(evt:MediaStateEvent):void {
			testResults.push({event: evt, time: new Date()});
			if (evt.newstate == MediaState.COMPLETED) {
				if (source.display()) {
					source.display().visible = false;
				}
				this.dispatchEvent(new TestingEvent(TestingEvent.TEST_COMPLETE, currentTestType, validateResult()));
			}
		}
		
		
		private function validateResult():String {
			var result:String;
			for (var i:Number = 0; i < testResults.length; i++) {
				var testMediaEvent:Object = testResults[i];
				switch (testMediaEvent['event'].type) {
					case 'jwplayerMediaState':
						result = traceEvent(currentTestType, testMediaEvent, stateDefaults);
						break;
					case 'jwplayerMediaBuffer':
						result = traceEvent(currentTestType, testMediaEvent, mediaEventDefaults);
						break;
					case 'jwplayerMediaLoaded':
						result = traceEvent(currentTestType, testMediaEvent, mediaEventDefaults);
						break;
					case 'jwplayerMediaMeta':
						result = traceEvent(currentTestType, testMediaEvent, mediaEventDefaults);
						break;
					case 'jwplayerMediaTime':
						result = traceEvent(currentTestType, testMediaEvent, mediaEventDefaults);
						break;
					case 'jwplayerMediaError':
						result = traceEvent(currentTestType, testMediaEvent, mediaEventDefaults);
						break;
					case 'jwplayerMediaVolume':
						result = traceEvent(currentTestType, testMediaEvent, mediaEventDefaults);
						break;
				}
			}
			return result;
		}
		
		
		private function traceEvent(testName:String, testMediaEvent:Object, defaults:Object):String {
			var mediaEvent:MediaEvent = testMediaEvent['event'];
			var result:String = "[" + (testMediaEvent['time'] as Date).time + "] " + testName + " " + mediaEvent.type;
			for (var property:String in defaults) {
				if (mediaEvent[property] != defaults[property]) {
					if (typeof(mediaEvent[property]) == "object") {
						var assignedValue:String = Strings.print_r(mediaEvent[property]);
						var defaultValue:String = Strings.print_r(defaults[property]);
						if (defaultValue != assignedValue) {
							result += " " + property + ": " + assignedValue;
						}
					} else {
						result += " " + property + ": " + mediaEvent[property];
					}
				}
			}
			return null;
		}
	}
}